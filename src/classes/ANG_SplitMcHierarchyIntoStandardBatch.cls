/**
 * Class used to split an existing multicountry hierarchy
 * into multiple standard hierarchies (1 per BSP)
 * Intended to be used when: 
 * 	- Passing the "Confirm conversion" step from the OSCAR "Conversion from Multicountry to Standard" 
 * 	- An OSCAR change in a multicountry hierarchy results in an invalid hierarchy that needs to be converted to standard 
 */
global class ANG_SplitMcHierarchyIntoStandardBatch implements Database.Batchable<SObject>, Database.Stateful {
	private Id accountGE;
	private Boolean processSingleBsp;
	
	public ANG_SplitMcHierarchyIntoStandardBatch(Id accountGE, Boolean processSingleBsp) {
		this.accountGE = accountGE;
		this.processSingleBsp = processSingleBsp;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<String> fields = new List<String>();
		fields.add('IATA_ISO_Country__r.Name');
		fields.add('(SELECT Id, Hierarchy__c, Child_Account__c, Parent_Account__c FROM AMS_Agencies_relationships__r)');

		// all fields on account
		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();
		for (String field : schemaFieldMapAccounts.keySet())
			fields.add(field);
		
		List<String> locations = new List<String> { AMS_Utils.GE, AMS_Utils.HE, AMS_Utils.AE };

		return Database.getQueryLocator('' // 
			+ ' SELECT ' + String.join(fields, ', ') // 
			+ ' FROM Account ' // 
			+ ' WHERE (Id = :accountGE ' // 
			+ '        OR Top_Parent__c = :accountGE) ' // 
			+ '     AND Location_Type__c IN :locations ');
	}
	
	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		System.SavePoint sp = Database.setSavepoint();

		try {
			List<Account> accts = updateAccountInformation((List<Account>) scope);
			updateAccountHierarchy(accts);
			createConversionToSTProcess(accts);
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - execute] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - execute] Exception Stacktrace: ' + e.getStackTraceString());
			Database.rollback(sp);
			ANG_TechnicalLogHelper.commitTechnicalLogs(ANG_TechnicalLogHelper.createTechnicalLog('ANG_SplitMcHierarchyIntoStandardBatch - Changing hierarchy', e, JSON.serialize(scope)));
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	private List<Account> updateAccountInformation(List<Account> accts) {
		// change the location type, parents and accreditation model
		List<Account> heAccounts = new List<Account>();
		
		for (Account acct : accts) {
			if (acct.Location_Type__c == AMS_Utils.GE) {
				acct.Location_Type__c = AMS_Utils.HE;
			} else if (acct.Location_Type__c == AMS_Utils.HE) {
				acct.ParentId = null;
				acct.Top_Parent__c = null;
				heAccounts.add(acct);
			} else { // AE
				acct.Top_Parent__c = acct.ParentId;
			}
			
			acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
		}
		
		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountInformation] Updated accounts: ' + accts);
		update accts;

		return heAccounts;
	}

	private void updateAccountHierarchy(List<Account> accts) {
		List<AMS_Agencies_relationhip__c> arsToDelete = new List<AMS_Agencies_relationhip__c>();
		Map<Id, AMS_Agencies_Hierarchy__c> arsToCreate = new Map<Id, AMS_Agencies_Hierarchy__c>();

		for (Account acct : accts) {
			// remove the relationships with the parent GE
			arsToDelete.addAll(acct.AMS_Agencies_relationships__r);
			
			// create a new hierarchy
			AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy', Main_account__c = acct.Id);
			arsToCreate.put(acct.Id, ah);
			
			// update child account's hierarchy to the new one
			// made after the "AMS_Agencies_Hierarchy__c" insert
		}

		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountHierarchy] Deleted agency relationships: ' + arsToDelete);
		if (!arsToDelete.isEmpty())
			delete arsToDelete;
		
		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountHierarchy] Created agency hierarchies: ' + arsToCreate);
		if (!arsToCreate.isEmpty()) {
			insert arsToCreate.values();
			
			// update child account's hierarchy to the new one
			List<AMS_Agencies_relationhip__c> allArs = [SELECT Id, Parent_Account__c
													 FROM AMS_Agencies_relationhip__c
													 WHERE Parent_Account__c IN :arsToCreate.keySet()];
			for (AMS_Agencies_relationhip__c ar : allArs)
				ar.Hierarchy__c = arsToCreate.get(ar.Parent_Account__c).Id;
			
			System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountHierarchy] Updated agency relationships: ' + allArs);
			update allArs;
		}
	}

	private void createConversionToSTProcess(List<Account> accts) {
		Case c = getOscarCase(accountGE);
		Map<Id, AMS_OSCAR__c> oscars = createOscar(accts, getOscarFromCase(c));
		Map<Id, Case> cases = createOscarCase(accts, c, oscars);
		Map<Id, AMS_Pax_Accreditation_Form__c> paxs = createStagingArea(accts, cases);
		finalOscarUpdate(accts, oscars, cases, paxs);
	}

	private Case getOscarCase(Id acct) {
		List<Case> cases = [SELECT Id, Subject, Origin, CaseNumber, RecordTypeId, CaseArea__c, Reason, Reason1__c, Visible_on_ISS_Portal__c,
								Region__c, BSPCountry__c, AccountId, ContactId
							FROM Case
							WHERE AccountId = :acct
								AND reason1__c = 'Accreditation Type'
							ORDER BY CaseNumber DESC];
		return cases.get(0);
	}

	private AMS_OSCAR__c getOscarFromCase(Case c) {
		List<AMS_OSCAR__c> oscars = [SELECT Id
									 FROM AMS_OSCAR__c
									 WHERE Account__c = :accountGE
										 AND Oscar_Communication_Case_Id__c = :c.Id];
		return oscars.get(0);
	}

	private Map<Id, AMS_OSCAR__c> createOscar(List<Account> accts, AMS_OSCAR__c parentOscar) {
		Map<String, Object> fieldsToSetOnOscar = new Map<String, Object>();
		fieldsToSetOnOscar.put('Process__c', AMS_Utils.NGCONVERSIONMCTOST);
		fieldsToSetOnOscar.put('Status__c', 'Open');

		Map<Id, AMS_OSCAR__c> oscarsToInsert = new Map<Id, AMS_OSCAR__c>();

		for (Account acct : accts) {
			AMS_OSCAR__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NGCONVERSIONTOSTANDARD, acct.Id, fieldsToSetOnOscar);
			AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(new List<AMS_OSCAR__c> { oscar }, new Map<Id, Account> { acct.Id => acct });
			oscar.Step51__c = AMS_Utils.NOT_APPLICABLE;
			oscar.Parent_OSCAR__c = parentOscar.Id;
			oscarsToInsert.put(acct.Id, oscar);
		}
		
		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createOscar] Created oscars: ' + oscarsToInsert);
		if (!oscarsToInsert.isEmpty())
			insert oscarsToInsert.values();
		return oscarsToInsert;
	}

	private Map<Id, Case> createOscarCase(List<Account> accts, Case c, Map<Id, AMS_OSCAR__c> oscars) {
		Map<Id, Case> casesToInsert = new Map<Id, Case>();

		for (Account acct : accts) {
			AMS_OSCAR__c oscar = oscars.get(acct.Id);

			Map<String, Object> fieldsToSetOnCase = new Map<String, Object>();
			fieldsToSetOnCase.put('Oscar__c', oscar.Id);
			fieldsToSetOnCase.put('ContactId', c.ContactId);
			fieldsToSetOnCase.put('ParentId', c.Id);
			fieldsToSetOnCase.put('BSPCountry__c', acct.BillingCountry);
			fieldsToSetOnCase.put('CaseArea__c', c.CaseArea__c);
			fieldsToSetOnCase.put('ContactId', c.ContactId);
			fieldsToSetOnCase.put('Reason1__c', 'Accreditation Type');
			fieldsToSetOnCase.put('Region__c', acct.Region_formula__c);
			fieldsToSetOnCase.put('Subject', 'Accreditation Type - GoStandard - ' + acct.IATA_ISO_Country__r.Name);
			fieldsToSetOnCase.put('Visible_on_ISS_Portal__c', c.Visible_on_ISS_Portal__c);
			fieldsToSetOnCase.put('Origin', c.Origin);
			
			Case newCase = ANG_EntityCreator.createCase(c.RecordTypeId, acct.id, fieldsToSetOnCase);
			casesToInsert.put(acct.Id, newCase);
		}
		
		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createOscarCase] Created cases: ' + casesToInsert);
		if (!casesToInsert.isEmpty())
			insert casesToInsert.values();
		return casesToInsert;
	}

	private Map<Id, AMS_Pax_Accreditation_Form__c> createStagingArea(List<Account> accts, Map<Id, Case> cases) {
		Map<Id, AMS_Pax_Accreditation_Form__c> paxToInsert = new Map<Id, AMS_Pax_Accreditation_Form__c>();

		for (Account acct : accts) {
			Map<String, Object> fieldsToSetOnPax = ANG_MulticountryHelper.buildStagingAreaFieldsObject(acct);
			
			AMS_Pax_Accreditation_Form__c stagingArea = ANG_EntityCreator.createStagingArea(RecordTypeSingleton.getInstance()
				.getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Associate_Entity'), acct.Name, cases.get(acct.Id).Id,
					fieldsToSetOnPax);
			
			stagingArea.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
			paxToInsert.put(acct.Id, stagingArea);
		}
		
		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createStagingArea] Created pax: ' + paxToInsert);
		if (!paxToInsert.isEmpty())
			insert paxToInsert.values();
		return paxToInsert;
	}
	
	private void finalOscarUpdate(List<Account> accts, Map<Id, AMS_OSCAR__c> oscars, Map<Id, Case> cases, Map<Id, AMS_Pax_Accreditation_Form__c> paxs) {
		List<AMS_OSCAR__c> oscarToUpdate = new List<AMS_OSCAR__c>();
		
		for (Account acct : accts) {
			AMS_OSCAR__c oscar = oscars.get(acct.Id);
			
			Map<String, Object> fieldsToSetOnOscar = new Map<String, Object>();
			fieldsToSetOnOscar.put('AMS_Online_Accreditation__c', paxs.get(acct.Id).Id);
			fieldsToSetOnOscar.put('Oscar_Communication_Case_Id__c', cases.get(acct.Id).Id);
			ANG_EntityCreator.updateOscar(oscar, fieldsToSetOnOscar);
			oscarToUpdate.add(oscar);
		}
		
		System.debug(LoggingLevel.INFO, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - finalOscarUpdate] Updated oscars: ' + oscarToUpdate);
		if (!oscarToUpdate.isEmpty())
			update oscarToUpdate;
	}
}
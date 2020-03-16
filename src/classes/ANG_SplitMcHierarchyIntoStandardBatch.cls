/**
 * Class used to split an existing multicountry hierarchy
 * into multiple standard hierarchies (1 per BSP)
 * Intended to be used when: 
 * 	- Passing the "Confirm conversion" step from the OSCAR "Conversion from Multicountry to Standard" 
 * 	- An OSCAR change in a multicountry hierarchy results in an invalid hierarchy that needs to be converted to standard 
 */
global class ANG_SplitMcHierarchyIntoStandardBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
	private Id accountGE;
	private Id oscarId;
	private Boolean processSingleBsp;

	private Integer currentThreads = 0;
	private Integer finishedThreads = 0;
	
	/**
	 * Used when testing to limit the "start" method query. If the batch is executed in testing, it can only return 1 result.
	 */
	public static Id forceAccountForTesting = null;
	
	/**
	 * Creates and splits a MC hierarchy into multiple ST hierarchies. If <i>processSingleBsp</i> is <i>true</i>, only the parent GE
	 * 	BSP is considered.
	 * @param accountGE The MC hierarchy parent GE account;
	 * @param processSingleBsp When "false": normal MC split into ST; When "true": only consider the parent BSP.
	 */
	public ANG_SplitMcHierarchyIntoStandardBatch(Id oscarId, Id accountGE, Boolean processSingleBsp) {
		this.accountGE = accountGE;
		this.oscarId = oscarId;
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
			+ '     AND Location_Type__c IN :locations ' // 
			+ (Test.isRunningTest() && forceAccountForTesting != null ? ' AND Id = :forceAccountForTesting ' : ''));
	}
		
	public void execute(SchedulableContext sc) {
		Set<String> setStatusBatch = new Set<String> { 'Processing', 'Preparing' };
		if ([SELECT count() FROM AsyncApexJob WHERE JobType = 'BatchApex' AND Status IN :setStatusBatch] < 5)
			Database.executeBatch(this, 1);
		else
			scheduleBatch(this);
	}
	
	global void execute(Database.BatchableContext BC, List<SObject> scope) {
		currentThreads++;

		// bypass additional AccountTeamMember logic on the related Users
		ANG_UserTriggerHandler.doNotRun = true;

		System.SavePoint sp = Database.setSavepoint();

		List<Account> accts = filterAccounts((List<Account>) scope);

		try {
			updateAccountInformation(accts);
			updateAccountHierarchy(accts);
			Case c = getOscarCase(accountGE, oscarId);
			updateStagingArea(accts, c);
			createConversionMcToStProcess(accts, c);

			finishedThreads++;
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - execute] Exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - execute] Exception Stacktrace: ' + e.getStackTraceString());
			Database.rollback(sp);
			ANG_TechnicalLogHelper.commitTechnicalLogs(ANG_TechnicalLogHelper.createTechnicalLog('ANG_SplitMcHierarchyIntoStandardBatch - Changing hierarchy', e, JSON.serialize(scope)));
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		AMS_OSCAR__c oscar = getOscarFromCase(accountGE, getOscarCase(accountGE));

		if(currentThreads == finishedThreads){
			oscar.Child_OSCAR_Status__c = AMS_Utils.OSCAR_CHILD_PROCESSING_FINISHED;
		}
		else {
			oscar.Child_OSCAR_Status__c = AMS_Utils.OSCAR_CHILD_PROCESSING_ERROR;
			oscar.STEP51__c = AMS_Utils.FAILED;
		}

		update oscar;
	}

	private List<Account> filterAccounts(List<Account> accts) {
		List<Account> accounts = new List<Account>();

		for (Account acct : accts) {
			// when processSingleBsp = false, include all
			// when processSingleBsp = true, don't include accounts that are not child AE
			// always include inactive accounts
			if (!processSingleBsp || !isActiveAccount(acct) || acct.Id == accountGE
				|| (acct.ParentId == accountGE && acct.Location_Type__c == AMS_Utils.AE)) {
				accounts.add(acct);
			}
		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - filterAccounts] Filtered accounts: ' + accounts);
		return accounts;
	}

	private Case getOscarCase(Id acct) {
		List<Case> cases = [SELECT Id, Subject, Origin, CaseNumber, RecordTypeId, CaseArea__c, Reason, Reason1__c, Visible_on_ISS_Portal__c,
								Region__c, BSPCountry__c, AccountId, ContactId
							FROM Case
							WHERE AccountId = :acct
								AND reason1__c = 'Accreditation Type'
								AND RecordTypeId = :AMS_Utils.RECTYPE_OSCARCOMM
							ORDER BY CaseNumber DESC];
		return cases.get(0);
	}

	private Case getOscarCase(Id acct, Id oscar) {
		List<Case> cases = [SELECT Id, Subject, Origin, CaseNumber, RecordTypeId, CaseArea__c, Reason, Reason1__c, Visible_on_ISS_Portal__c,
								Region__c, BSPCountry__c, AccountId, ContactId
							FROM Case
							WHERE OSCAR__c = :oscar];

		return cases.get(0);
	}
	
	/**
	 * Updates the location type, parents and accreditation model based on the account location type (for active accounts).
	 */
	private void updateAccountInformation(List<Account> accts) {
		for (Account acct : accts) {
			if (!isActiveAccount(acct)) {
				acct.ParentId = null;
				acct.Top_Parent__c = null;
			} else {
				acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

				if (acct.Location_Type__c == AMS_Utils.GE) {
					acct.Location_Type__c = AMS_Utils.HE;
				} else if (acct.Location_Type__c == AMS_Utils.HE) {
					acct.ParentId = null;
					acct.Top_Parent__c = null;
				} else { // AE
					acct.Top_Parent__c = acct.ParentId;
				}
			}
		}
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountInformation] Updated accounts: ' + accts);
		ANG_ConversionHelper.isMigrationTool = true; // flag set to true to bypass the logic on ANG_AgencyEventsGenerator.run
		update accts;
		ANG_ConversionHelper.isMigrationTool = false;
	}

	/**
	 * Removed the relationship between HE and parent GE and between all inactive accounts (any location type).
	 */
	private void updateAccountHierarchy(List<Account> accts) {
		List<AMS_Agencies_relationhip__c> arsToDelete = new List<AMS_Agencies_relationhip__c>();
		Map<Id, AMS_Agencies_Hierarchy__c> arsToCreate = new Map<Id, AMS_Agencies_Hierarchy__c>();

		for (Account acct : accts) {
			if (! isActiveAccount(acct) || (acct.Location_Type__c == AMS_Utils.HE && acct.Id != accountGE)) {
				// remove the relationships with the parent GE or any relation on inactive accounts
				arsToDelete.addAll(acct.AMS_Agencies_relationships__r);
				
				// create a new hierarchy on HE accounts
				if (isActiveAccount(acct)) {
					AMS_Agencies_Hierarchy__c ah = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy', Main_account__c = acct.Id);
					arsToCreate.put(acct.Id, ah);
				}
				
				// update child account's hierarchy to the new one
				// made after the "AMS_Agencies_Hierarchy__c" insert
			}
		}

		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountHierarchy] Deleted agency relationships: ' + arsToDelete);
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
			
			System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateAccountHierarchy] Updated agency relationships: ' + allArs);
			update allArs;
		}
	}
	
	/**
	 * Update the information on the stating area of the GE account.
	 */
	private void updateStagingArea(List<Account> accts, Case c) {
		if (processSingleBsp)
			return;
		
		for (Account acct : accts) {
			if (acct.Id != accountGE)
				continue;
			
			AMS_Pax_Accreditation_Form__c pax = getStagingAreaFromCase(c);
			pax.Location_Type__c = AMS_Utils.HE;
			pax.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
		
			System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - updateStagingArea] Updated pax: ' + pax);
			update pax;
		}
	}

	private AMS_Pax_Accreditation_Form__c getStagingAreaFromCase(Case c) {
		return [SELECT Id FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__c = :c.Id].get(0);
	}

	/**
	 * Creates a single oscar for each HE account (hierarchy)
	 */
	private void createConversionMcToStProcess(List<Account> accts, Case c) {
		// get the HE accounts (active)
		List<Account> allHe = new List<Account>();
		Account geAccount = null;
		
		for (Account acct : accts) {
			if (acct.Id == accountGE && !processSingleBsp) // GE is treated as HE if "processSingleBsp"
				geAccount = acct;
			else if (isActiveAccount(acct) && acct.Location_Type__c == AMS_Utils.HE)
				allHe.add(acct);
		}

		AMS_OSCAR__c geOscar = processSingleBsp ? null : getOscarFromCase(accountGE, c);

		List<Account> allGeAndHe = new List<Account>(allHe);
		if (geAccount != null)
			allGeAndHe.add(geAccount);

		// create / update the entities
		Map<Id, AMS_OSCAR__c> oscars = createOscar(allHe, geOscar);
		if (!processSingleBsp) // processSingleBsp: oscar created on "createOscar", that is, already on the map
			oscars.put(accountGE, geOscar);

		addAeAccountInformationToOscar(allGeAndHe, oscars);
		Map<Id, Case> cases = createOscarCase(allHe, c, oscars);
		Map<Id, AMS_Pax_Accreditation_Form__c> paxs = createStagingArea(allHe, cases);
		createOwners(allHe, paxs);
		finalOscarUpdate(allHe, oscars, cases, paxs);
	}

	private AMS_OSCAR__c getOscarFromCase(Id acct, Case c) {
		if (c == null)
			return null;
		
		List<AMS_OSCAR__c> oscars = [SELECT Id
									 FROM AMS_OSCAR__c
									 WHERE Account__c = :acct
										 AND Oscar_Communication_Case_Id__c = :c.Id];
		return oscars.get(0);
	}

	/**
	 * Create the new oscars for the accounts (related to the parent GE oscar).
	 */
	private Map<Id, AMS_OSCAR__c> createOscar(List<Account> accts, AMS_OSCAR__c parentOscar) {
		Map<String, Object> fieldsToSetOnOscar = new Map<String, Object>();
		fieldsToSetOnOscar.put('Process__c', AMS_Utils.NGCONVERSIONMCTOST);
		fieldsToSetOnOscar.put('Status__c', 'Open');

		Map<Id, AMS_OSCAR__c> oscarsToInsert = new Map<Id, AMS_OSCAR__c>();

		for (Account acct : accts) {
			AMS_OSCAR__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NGCONVERSIONTOSTANDARD, acct.Id, fieldsToSetOnOscar);
			AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(new List<AMS_OSCAR__c> { oscar }, new Map<Id, Account> { acct.Id => acct });
			oscar.Step51__c = AMS_Utils.NOT_APPLICABLE;
			if (parentOscar != null)
				oscar.Parent_OSCAR__c = parentOscar.Id;
			oscarsToInsert.put(acct.Id, oscar);
		}
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createOscar] Created oscars: ' + oscarsToInsert);
		if (!oscarsToInsert.isEmpty())
			insert oscarsToInsert.values();
		return oscarsToInsert;
	}

	/**
	 * Creates a Process Details related to the oscar with the relationship between the oscar and the AE accounts
	 * 	in the hierarchy.
	 */
	private void addAeAccountInformationToOscar(List<Account> accts, Map<Id, AMS_OSCAR__c> oscars) {
		List<AMS_Process_Detail__c> processDetailLst = new List<AMS_Process_Detail__c>();
		
		for (Account acct : getChildAeAccounts(accts)) {
			AMS_Process_Detail__c pd = new AMS_Process_Detail__c();
			pd.Oscar__c = oscars.get(acct.ParentId).Id;
			pd.Account__c = acct.Id;
			pd.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');
			processDetailLst.add(pd);
		}
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - addAeAccountInformationToOscar] Created process detail: ' + processDetailLst);
		if (!processDetailLst.isEmpty())
			insert processDetailLst;
	}

	private List<Account> getChildAeAccounts(List<Account> accts) {
		return [SELECT Id, ParentId, Location_Type__c
				FROM Account
				WHERE ParentId = :accts
					AND Location_Type__c = :AMS_Utils.AE
					AND Status__c NOT IN ( '', null, :AMS_Utils.ACC_S4_LISTED, :AMS_Utils.ACC_S0_TERMINATED,
										   :AMS_Utils.ACC_S1_NOTACCREDITED, :AMS_Utils.ACC_S3_NOTINOPERATION )];
	} 

	/**
	 * Create the related Case to the newly created oscars.
	 */
	private Map<Id, Case> createOscarCase(List<Account> accts, Case c, Map<Id, AMS_OSCAR__c> oscars) {
		Map<Id, Case> casesToInsert = new Map<Id, Case>();

		for (Account acct : accts) {
			AMS_OSCAR__c oscar = oscars.get(acct.Id);

			Map<String, Object> fieldsToSetOnCase = new Map<String, Object>();
			fieldsToSetOnCase.put('Oscar__c', oscar.Id);
			fieldsToSetOnCase.put('ContactId', c.ContactId);
			if (!processSingleBsp)
				fieldsToSetOnCase.put('ParentId', c.Id);
			fieldsToSetOnCase.put('BSPCountry__c', acct.BillingCountry);
			fieldsToSetOnCase.put('CaseArea__c', c.CaseArea__c);
			fieldsToSetOnCase.put('ContactId', c.ContactId);
			fieldsToSetOnCase.put('Reason1__c', 'Accreditation Type');
			fieldsToSetOnCase.put('Region__c', acct.Region_formula__c);
			fieldsToSetOnCase.put('Subject', 'Accreditation Type - GoStandard - ' + acct.IATA_ISO_Country__r.Name);
			fieldsToSetOnCase.put('Visible_on_ISS_Portal__c', c.Visible_on_ISS_Portal__c);
			fieldsToSetOnCase.put('Origin', c.Origin);
			
			Case newCase = ANG_EntityCreator.createCase(AMS_Utils.RECTYPE_OSCARCOMM, acct.id, fieldsToSetOnCase);
			casesToInsert.put(acct.Id, newCase);
		}
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createOscarCase] Created cases: ' + casesToInsert);
		if (!casesToInsert.isEmpty())
			insert casesToInsert.values();
		return casesToInsert;
	}

	/**
	 * Creates the staging areas (PAX) to the newly created oscars.
	 */
	private Map<Id, AMS_Pax_Accreditation_Form__c> createStagingArea(List<Account> accts, Map<Id, Case> cases) {
		Map<Id, AMS_Pax_Accreditation_Form__c> paxToInsert = new Map<Id, AMS_Pax_Accreditation_Form__c>();

		for (Account acct : accts) {
			Map<String, Object> fieldsToSetOnPax = ANG_MulticountryHelper.buildStagingAreaFieldsObject(acct);
			
			AMS_Pax_Accreditation_Form__c stagingArea = ANG_EntityCreator.createStagingArea(AMS_Utils.RECTYPE_GENERAL_ONLINE_PAX,
				acct.Name, cases.get(acct.Id).Id, fieldsToSetOnPax);
			
			stagingArea.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_CASH;
			stagingArea.Remittance_frequency__c = acct.Remittance_frequency__c;
			paxToInsert.put(acct.Id, stagingArea);
		}
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createStagingArea] Created pax: ' + paxToInsert);
		if (!paxToInsert.isEmpty())
			insert paxToInsert.values();
		return paxToInsert;
	}

	private void createOwners(List<Account> accts, Map<Id, AMS_Pax_Accreditation_Form__c> paxs) {
		List<AMS_Accreditation_Contact__c> ownersToInsert = new List<AMS_Accreditation_Contact__c>();

		Map<Id, List<AMS_Account_Role__c>> owners = getAccountOwners(accts);

		for (Account acct : accts) {
			AMS_Pax_Accreditation_Form__c pax = paxs.get(acct.Id);
			if (owners.get(acct.Id) == null)
				continue;
			
			for (AMS_Account_Role__c o : owners.get(acct.Id)) {
				AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c();
				owner.AMS_Pax_Accreditation_Form__c = pax.Id;
				owner.Agency_owner__c = true;
				owner.Company__c = o.Owner_Account__c;
				owner.Contact__c = o.Contact__c;
				owner.Email__c = o.Contact_Email__c;
				owner.Financial_Assessment_Contact__c = o.Financial_Assessment_Contact__c;
				owner.Financial_interest__c = o.Percentage__c;
				owner.First_name__c = o.Contact__c != null
					? o.Contact__r.FirstName
					: o.Person__c != null
						? o.Person__r.First_Name__c
						: '';
				owner.Last_name__c = o.Contact__c != null
					? o.Contact__r.LastName
					: o.Person__c != null
						? o.Person__r.Lastname__c
						: o.Owner_Account__c == null
							? o.Owner_Name__c
							: '_';
				owner.Legacy_External_Id__c = o.Legacy_External_ID__c;
				owner.Name = o.Contact__c != null
					? o.Contact__r.FirstName + ' ' + o.Contact__r.LastName
					: o.Person__c != null
						? o.Person__r.Name
						: o.Owner_Account__c != null
							? o.Owner_Account__r.Name
							: o.Owner_Name__c;
				owner.Person_AMS__c = o.Person__c;
				owner.Phone__c = o.Contact_Phone__c;
				owner.RecordTypeId = o.Owner_Account__c == null ? AMS_Utils.AccreditationContactPersonRT : AMS_Utils.AccreditationContactCompanyRT;
				ownersToInsert.add(owner);
			}
		}
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - createOwners] Created owner: ' + ownersToInsert);
		if (!ownersToInsert.isEmpty())
			insert ownersToInsert;
	}

	private Map<Id, List<AMS_Account_Role__c>> getAccountOwners(List<Account> accts) {
		Map<Id, List<AMS_Account_Role__c>> owners = new Map<Id, List<AMS_Account_Role__c>>();

		for (AMS_Account_Role__c owner : [SELECT Id, Account__c, Owner_Account__c, Owner_Account__r.Name, Contact__c, Contact__r.FirstName,
											  Contact__r.LastName, Contact_Email__c, Financial_Assessment_Contact__c, Percentage__c,
											  Legacy_External_ID__c, Person__c, Person__r.First_Name__c, Person__r.Lastname__c,
											  Person__r.Contact__r.FirstName, Person__r.Contact__r.LastName, Person__r.Name,
											  Contact_Phone__c, Owner_Name__c
										  FROM AMS_Account_Role__c
										  WHERE Account__c IN :accts
											  AND active__c = true
											  AND RecordTypeId = :AMS_Utils.AccountRoleOwnershipRT]) {
			if (!owners.containsKey(owner.Account__c))
				owners.put(owner.Account__c, new List<AMS_Account_Role__c>());
			owners.get(owner.Account__c).add(owner);
		}

		return owners;
	}
	
	/**
	 * Final update to the oscars with the Case and PAX information.
	 */
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
		
		System.debug(LoggingLevel.FINE, '____ [cls ANG_SplitMcHierarchyIntoStandardBatch - finalOscarUpdate] Updated oscars: ' + oscarToUpdate);
		if (!oscarToUpdate.isEmpty())
			update oscarToUpdate;
	}

	private boolean isActiveAccount(Account acct) {
		return String.isNotBlank(acct.Status__c) && acct.Status__c != AMS_Utils.ACC_S4_LISTED
			&& acct.Status__c != AMS_Utils.ACC_S0_TERMINATED && acct.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED
			&& acct.Status__c != AMS_Utils.ACC_S3_NOTINOPERATION;
	}

	public static void scheduleOrRun(ANG_SplitMcHierarchyIntoStandardBatch batch) {
		if (System.isBatch())
			scheduleBatch(batch);
		else
			Database.executeBatch(batch, 1);
	}

	public static void scheduleBatch(ANG_SplitMcHierarchyIntoStandardBatch batch) {
		System.schedule('ScheduledJob ' + String.valueOf(Math.random()), nextScheduleDate(), batch);
	}

	public static String nextScheduleDate() {
		Datetime now = Datetime.now().addSeconds(10);
		
		String hour = String.valueOf(now.hour());
		String min = String.valueOf(now.minute());
		String ss = String.valueOf(now.second());
		String day = String.valueOf(now.day());
		String month = String.valueOf(now.month());
		String year = String.valueOf(now.year());

		return ss + ' ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
	}
}
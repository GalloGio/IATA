global class ANG_MulticountryOscarCreatorBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	
	global Set<Id> accountIds;

	global List<ANG_ConversionHelper.ConversionBatchItem> resultItems;

	global Map<Id,AMS_Pax_Accreditation_Form__c> accountAccreditationFormsMap;
	Case newCaseMC = null;
	Account acct = null;

	global ANG_MulticountryOscarCreatorBatch(Set<Id> accountIds) { 

		resultItems = new List<ANG_ConversionHelper.ConversionBatchItem>();

		List<String> fieldListAcct = new List<String>();
		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
			fieldListAcct.add(field);
		}

		fieldListAcct.add('IATA_ISO_Country__r.Name');
		
		this.accountIds = accountIds;	

		this.query = 'SELECT '+ String.join(fieldListAcct, ', ') + ' FROM Account WHERE Id in:accountIds';

		fetchAccreditationAreas();
	}
	
	global void fetchAccreditationAreas(){

		accountAccreditationFormsMap = new Map<Id,AMS_Pax_Accreditation_Form__c>();

		for(AMS_Pax_Accreditation_Form__c accr: [Select Id,ISSP_Branch_AccountId__c, (Select id,Case__c,name from AmazonFiles__r) from AMS_Pax_Accreditation_Form__c where ISSP_Branch_AccountId__c in:accountIds]){
			accountAccreditationFormsMap.put(accr.ISSP_Branch_AccountId__c,accr);
		}

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
		System.SavePoint sp = Database.setSavepoint();

		AMS_OSCAR__c oscar = null;
		AMS_Pax_Accreditation_Form__c stagingArea = null;
		
		try{
			
			acct = (Account) scope.get(0);
			Case c = [Select id, Subject, Origin, CaseNumber, RecordTypeId, CaseArea__c, Reason, Reason1__c, Visible_on_ISS_Portal__c, Region__c, BSPCountry__c, AccountId, ContactId from Case where accountid =: acct.Top_Parent__c AND reason1__c = 'New HE Multicountry'];
			System.debug('[ANG_MulticountryOscarCreatorBatch]Parent Case recordType = ' +c.recordTypeId);
			Map<String,Object> fieldsOfObject = new Map<String,Object>();

			sp = Database.setSavePoint();

			fieldsOfObject.put('Process__c', AMS_Utils.MCAE);
			fieldsOfObject.put('Status__c','Open');
			
			oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_MCAE, acct.Id, fieldsOfObject);

			AMS_OscarCaseTriggerHelper.assignOscarToRegionQueue(new List<AMS_OSCAR__c>{oscar}, new Map<Id, Account>{acct.Id => acct});

			insert oscar;

			fieldsOfObject = new Map<String,Object>();
			fieldsOfObject.put('Oscar__c',oscar.Id);
			fieldsOfObject.put('ContactId',c.ContactId);
			fieldsOfObject.put('ParentId',c.Id);
			fieldsOfObject.put('BSPCountry__c',acct.BillingCountry);
			fieldsOfObject.put('CaseArea__c',c.CaseArea__c);
			fieldsOfObject.put('ContactId',c.ContactId);
			fieldsOfObject.put('Reason1__c', 'New AE Multicountry');
			fieldsOfObject.put('Region__c',acct.Region_formula__c);
			fieldsOfObject.put('Subject', 'New Associate Entity - GoGlobal - ' + acct.IATA_ISO_Country__r.Name);
			fieldsOfObject.put('Visible_on_ISS_Portal__c', c.Visible_on_ISS_Portal__c);
			fieldsOfObject.put('Origin', c.Origin);
			
			newCaseMC = ANG_EntityCreator.createCase(c.RecordTypeId, acct.id, fieldsOfObject);
			System.debug('[ANG_MulticountryOscarCreatorBatch]new Case = ' + newCaseMC);
			
			insert newCaseMC;
			
			System.debug('accountAccreditationFormsMap is:'+accountAccreditationFormsMap);

			if(c.origin == 'Portal' && accountAccreditationFormsMap.get(acct.Id) != null){ 
				
				System.debug('Origin is Portal and has already an accreditation.');

				stagingArea = new AMS_Pax_Accreditation_Form__c(Id=accountAccreditationFormsMap.get(acct.Id).Id);
				stagingArea.SAAM_Case__c = newCaseMC.Id;
				update stagingArea;

			}else{

				System.debug('Origin is either not Portal or does not have  an accreditation.');
				
				fieldsOfObject = ANG_MulticountryHelper.buildStagingAreaFieldsObject(acct);
				
				stagingArea = ANG_EntityCreator.createStagingArea(RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Associate_Entity'), acct.Name, newCaseMC.Id, fieldsOfObject);
				
				insert stagingArea;
			}

			fieldsOfObject = new Map<String,Object>();
			fieldsOfObject.put('AMS_Online_Accreditation__c',stagingArea.Id);
			fieldsOfObject.put('Oscar_Communication_Case_Id__c', newCaseMC.Id);
			ANG_EntityCreator.updateOscar(oscar, fieldsOfObject);
						
			upsert oscar;
			
		}catch(Exception e){
			
			System.debug('[ANG_MulticountryOscarCreatorBatch] Exception processing account ' + acct.Id + ':' + e.getStackTraceString());
			
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), true, e.getMessage());

			System.debug(item);
			resultItems.add(item);
			Database.rollback(sp);

		}
	}
	
	global void finish(Database.BatchableContext BC) {
			
		if(accountAccreditationFormsMap != NULL && accountAccreditationFormsMap.containsKey(acct.Id)){
			List<AmazonFile__c> amazonFilesLst = accountAccreditationFormsMap.get(acct.Id).AmazonFiles__r;
			List<AmazonFile__c> amazonFilesToUpdate = new List<AmazonFile__c>();

			if(amazonFilesLst != NULl && !amazonFilesLst.isEmpty()){
				Set<String> attatchmentsNameToTransfer = new Set<String>();
				List<WrapperAttach> attatchments = WrapperAttach.getListAttachments(amazonFilesLst.get(0).case__c);

				for(AmazonFile__c a : amazonFilesLst){
					attatchmentsNameToTransfer.add(a.name);
					amazonFilesToUpdate.add(new AmazonFile__c(id = a.id, case__c = newCaseMC.id));
				}

				for(WrapperAttach wa : attatchments){
					if(attatchmentsNameToTransfer.contains(wa.fileAmazon.amazonFile.name)){
						wa.transfer(newCaseMC.id);
						wa.moveToBucket();
					}
				}
				update amazonFilesToUpdate;
			}
		}
	}
	
}
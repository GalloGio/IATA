public class ProcessIDCardMassApplications extends TriggerAction {
	
	private Set<String> idCardAppToUpdate;

	/**
	 * Method that checks if the relevant fields for this action were changed
	 * @param s the affected record
	 * @return true if the relevant fields for this action were changed and false if not
	 */
	protected override Boolean isRelevant(SObject s) {

		ID_Card_Application__c idCardAppRecord = (ID_Card_Application__c) s;

		Map<Id, ID_Card_Application__c> oldMap = (Map<Id, ID_Card_Application__c>) Trigger.oldMap;

		if(idCardAppRecord.RecordTypeId == IDCardUtil.IDCARDMASSAPPLICATION_RTID 
			&& (Trigger.isInsert || (Trigger.isUpdate && idCardAppRecord.Application_Status__c != oldMap.get(idCardAppRecord.Id).Application_Status__c)))
			return true;

		return false;
	}

	/**
	 * Method to process mass applications 
	 * @param records relevant records
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		idCardAppToUpdate = new Set<String>();

		Map<Id, ID_Card_Application__c> oldMap = (Map<Id, ID_Card_Application__c>) Trigger.oldMap;

		List<ID_Card_Application__c> mustBeLaunchedApps = new List<ID_Card_Application__c>();
		Map<String, Account> accountPerIATACode = new Map<String, Account>();

		//determine all account
		List<String> iataCodes = new List<String>();
		for(ID_Card_Application__c app : (List<ID_Card_Application__c>) records) {
			iataCodes.add(app.IATA_Code__c);
		}

		if(!iataCodes.isEmpty()){
			for(Account a : [SELECT Id, IATACode__c, ID_Card_KeyAccount_features__c , IDCard_Key_Account__c, BillingCountry FROM Account where IATACode__c IN :iataCodes])
				accountPerIATACode.put(a.IATACode__c, a);
		}

		for (ID_Card_Application__c app : (List<ID_Card_Application__c>) records) {
			Account acc = accountPerIATACode.get(app.IATA_Code__c);
			//according to account we have to process or not
			String appStatus = app.Application_Status__c;
			String accFeatures = acc.ID_Card_KeyAccount_features__c;

			//don t want npe, and keep code readable ;)
			if(appStatus == null)appStatus = '';
			if(accFeatures == null)accFeatures = '';

			//check status
			System.debug('____ [cls ProcessIDCardMassApplications - execute] for app ' + app.Id + ' Status ' + appStatus + '  /  Feat.:' + accFeatures);

			//credit card
			if(appStatus.tolowerCase().equals('paid') && app.Payment_Type__c == IDCardUtil.PAYMENT_TYPE_CC) {
				//process for New OR is updatestatus only.
				System.debug('____ [cls ProcessIDCardMassApplications - execute: process card 1]');
				mustBeLaunchedApps.add(app);

			} else if(appStatus.tolowerCase().equals('paid') && Trigger.isInsert && accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) ) {
				//process for New OR is updatestatus only.
				System.debug('____ [cls ProcessIDCardMassApplications - execute: process card 1]');
				mustBeLaunchedApps.add(app);

			} else if(app.Payment_Type__c != IDCardUtil.PAYMENT_TYPE_CC && accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) && appStatus.tolowerCase().equals('pending') ) {
				//process for New OR is updatestatus only.
				System.debug('____ [cls ProcessIDCardMassApplications - execute: process card 2]');
				mustBeLaunchedApps.add(app);

			} else if(app.Payment_Type__c != IDCardUtil.PAYMENT_TYPE_CC && Trigger.isUpdate && !appStatus.equals(oldMap.get(app.Id).Application_Status__c) && !accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) && appStatus.tolowerCase().equals('paid') ) {
				//process for New OR is updatestatus only.
				System.debug('____ [cls ProcessIDCardMassApplications - execute: process card 2]');
				mustBeLaunchedApps.add(app);

			} else if(appStatus.tolowerCase().equals('paid') || ( trigger.isUpdate && app.Payment_Date__c != NULL && !app.Payment_Date__c.equals(oldMap.get(app.Id).Payment_Date__c) )) {
				//should update all id cards application related to this one as paid.
				System.debug('____ [cls ProcessIDCardMassApplications - execute: update card paymnent status]');
				idCardAppToUpdate.add(app.Id);
				registerFuture();
				
			} else {
				System.debug('____ [cls ProcessIDCardMassApplications - execute: do nothing]');
			}
		}

		for (ID_Card_Application__c app : mustBeLaunchedApps) {
			System.debug('____ [cls ProcessIDCardMassApplications - execute: process card 1] Mass Apps which should be starteed : ' + app.Id + ' and session id = ' + UserInfo.getSessionid());

			IDCardMassApplicationBatch.startJob(app.Id, 'IDCA_MASS_PROCESS_' + app.Name, UserInfo.getSessionid());
		}
	}

	protected override void futureAction(UnitOfWork uw) {
		List<ID_Card_Application__c> singleApps = IDCardMassApplicationBatch.triggerPaidMassApplication(idCardAppToUpdate);

		if(!singleApps.isEmpty()) {
			Map<String, SObjectField> sObjectFieldMap = Schema.getGlobalDescribe().get('ID_Card_Application__c').getDescribe().fields.getMap();
			uw.registerDirty(singleApps, new List<SObjectField>{sObjectFieldMap.get('Payment_Credit_Card_Number__c'),sObjectFieldMap.get('Payment_Type__c'),
																sObjectFieldMap.get('Payment_Currency__c'),sObjectFieldMap.get('Payment_Transaction_Number__c'),
																sObjectFieldMap.get('Payment_Date__c'),sObjectFieldMap.get('Application_Status__c')});
		}
	}
}
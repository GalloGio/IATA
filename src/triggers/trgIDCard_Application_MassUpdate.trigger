trigger trgIDCard_Application_MassUpdate on ID_Card_Application__c (after insert, after update) {


	String massAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');

	//INC195282 -  the respective mass CASE should have Status = Closed and ID Card Status = Cancelled whenever a mass IDCA has Application Status = Cancelled.
	List<ID_Card_Application__c> listMassApps = new List<ID_Card_Application__c>();
	if (trigger.isUpdate) {
		for (ID_Card_Application__c app : trigger.new) {
			if (app.Application_Status__c == 'Cancelled' && massAppRT.equals(app.RecordTypeId))
				listMassApps.add(app);
		}
	}

	List<Case> listCases = [SELECT Id, Status, ID_Card_Status__c from Case WHERE Related_ID_Card_Application__c in :listMassApps];

	for (Case c : listCases) {
		c.status = 'Closed';
		c.ID_Card_Status__c = 'Cancelled';
	}
	update listCases;


	List<ID_Card_Application__c> mustBeLaunchedApps = new List<ID_Card_Application__c>();
	Map<String, Account> accountPerIATACode = new Map<String, Account>();

	//determine all account
	List<String> iataCodes = new List<String>();
	for (ID_Card_Application__c app : trigger.new) {
		if (massAppRT.equals(app.RecordTypeId))
			iataCodes.add(app.IATA_Code__c);
	}

	if(iataCodes.size()>0)
	for (Account a : [select Id, IATACode__c, ID_Card_KeyAccount_features__c , IDCard_Key_Account__c, BillingCountry from Account where IATACode__c in :iataCodes]) {
		accountPerIATACode.put(a.IATACode__c, a);
	}

	for (ID_Card_Application__c app : trigger.new) {
		if (app.RecordTypeId != null && massAppRT.equals(app.RecordTypeId)) {
			Account acc = accountPerIATACode.get(app.IATA_Code__c);
			//according to account we have to process or not
			String appStatus = app.Application_Status__c;
			String accFeatures = acc.ID_Card_KeyAccount_features__c;

			//don t want npe, and keep code readable ;)
			if (appStatus == null)appStatus = '';
			if (accFeatures == null)accFeatures = '';

			//check status
			system.debug('[trgIDCard_Application_MassUpdate] for app ' + app.Id + ' Status ' + appStatus + '  /  Feat.:' + accFeatures);
			//only consider this action if Application_Status__c had been updated.
			if (Trigger.isInsert || (Trigger.isUpdate &&  app.Application_Status__c != Trigger.oldMap.get(app.Id).Application_Status__c)) {

				//credit card
				if ( appStatus.tolowerCase().equals('paid')  && app.Payment_Type__c == IDCardUtil.PAYMENT_TYPE_CC) {
					//process for New OR is updatestatus only.
					system.debug('[trgIDCard_Application_MassUpdate] process card 1');
					mustBeLaunchedApps.add(app);
				} else if (    appStatus.tolowerCase().equals('paid') && Trigger.isInsert && accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) ) {
					//process for New OR is updatestatus only.
					system.debug('[trgIDCard_Application_MassUpdate] process card 1');
					mustBeLaunchedApps.add(app);
				} else if  (app.Payment_Type__c != IDCardUtil.PAYMENT_TYPE_CC && accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) && appStatus.tolowerCase().equals('pending') ) {
					//process for New OR is updatestatus only.
					system.debug('[trgIDCard_Application_MassUpdate] process card 2');
					mustBeLaunchedApps.add(app);
				} else if  (app.Payment_Type__c != IDCardUtil.PAYMENT_TYPE_CC && Trigger.isUpdate && !appStatus.equals(Trigger.oldMap.get(app.Id).Application_Status__c) && !accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) && appStatus.tolowerCase().equals('paid') ) {
					//process for New OR is updatestatus only.
					system.debug('[trgIDCard_Application_MassUpdate] process card 2');
					mustBeLaunchedApps.add(app);
				} else if (appStatus.tolowerCase().equals('paid') || ( trigger.isUpdate && app.Payment_Date__c != NULL && !app.Payment_Date__c.equals(Trigger.oldMap.get(app.Id).Payment_Date__c) )) {
					//should update all id cards application related to this one as paid.
					system.debug('[trgIDCard_Application_MassUpdate]update card paymnent status');
					IDCardMassApplicationBatch.triggerPaidMassApplication(APP.Id);
				} else
					system.debug('[trgIDCard_Application_MassUpdate] do nothing');

			}
		}

	}

	//insert toInsertCase; --> INC158853
	//for all selected items, launch a batch.
	//batch will be destroy by itself once terminated.
	//be carefull: limited to <90 batch in same time...
	for (ID_Card_Application__c app : mustBeLaunchedApps) {
		system.debug('[trgIDCard_Application_MassUpdate] Mass Apps which should be starteed : ' + app.Id + ' and session id = ' + UserInfo.getSessionid());

		IDCardMassApplicationBatch.startJob(app.Id, 'IDCA_MASS_PROCESS_' + app.Name, UserInfo.getSessionid());
	}	
}
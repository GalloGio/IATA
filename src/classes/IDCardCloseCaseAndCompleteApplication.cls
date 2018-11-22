public class IDCardCloseCaseAndCompleteApplication extends TriggerAction {
	/**
	 * Method that checks if Sent_to_AIMS_on__c field is null
	 * @param s the affected record
	 * @return true if the field is not null false if it is null
	 */
	protected override Boolean isRelevant(SObject s) {

		ID_Card__c idCardRecord = (ID_Card__c) s;

		Map<Id, ID_Card__c> oldMap = (Map<Id, ID_Card__c>) Trigger.oldMap;

		if(idCardRecord.Card_Status__c == 'Valid ID Card' && oldMap.get(idCardRecord.Id).Card_Status__c != 'Valid ID Card')
			return true;

		return false;
	}

	/**
	 * Method that adds a error if the user is not administrator or automated process
	 * @param records records with Sent_to_AIMS_on__c not null
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		List<String> singleApplicationIds = new List<String>();
		List<String> massApplicationIds =  new List<String>();
		Map<String, List<ID_Card_Application__c>> allSingleAppPerMassId  = new Map<String, List<ID_Card_Application__c>>();
		Map<String,String> massAppIdFromSingleAppid  = new Map<String,String>();
		Map<String,Boolean> massAppStatus = new Map<String, Boolean>();
		List<ID_Card_Application__c> idcardAppToUpdate = new List<ID_Card_Application__c>();

		//GET APPLICATIONS FROM CARD WITH STATUS PRINTED/DELIVED
		for(ID_Card__c idCard : (List<ID_Card__c>) records)
			singleApplicationIds.add(idCard.ID_Card_Application__c);

		if(singleApplicationIds.isEmpty()) return;

		System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [UP]Should consider ' + singleApplicationIds.size() + ' ID CARD for update ');

		List<ID_Card_Application__c> singlesApplication = [SELECT Id , Application_Status__c, Mass_order_Application__c FROM ID_Card_Application__c WHERE recordTypeID = :IDCardUtil.IDCARDSINGLEAPPLICATION_RTID and Id in :singleApplicationIds ];
		
		//Get Mass application from single App
		for(ID_Card_Application__c singleApp :singlesApplication){

			massApplicationIds.add(singleApp.Mass_order_Application__c);
			massAppStatus.put(singleApp.Mass_order_Application__c, true);
			idcardAppToUpdate.add(singleApp);
		}

		List<ID_Card_Application__c> massApplication = new List<ID_Card_Application__c>();
		if(!massApplicationIds.isEmpty()) {

			System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [UP] Should consider ' + singlesApplication.size() + ' Single APp for ' + massAppStatus.size() + ' mass appli');
			
			massApplication = [SELECT Id , Mass_order_Application__c FROM ID_Card_Application__c WHERE recordTypeID = :IDCardUtil.IDCARDMASSAPPLICATION_RTID and Id in :massApplicationIds ];
		}

		for(ID_Card_Application__c ma : massApplication){

			allSingleAppPerMassId.put(ma.Id, new List<ID_Card_Application__c>());
		}

		System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [UP]  Got  ' + allSingleAppPerMassId.size() + ' mass appli');
		
		System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [DOWN] ');

		//Now get all all single from all mass and get all card card from all single
		List<ID_Card_Application__c> allSinglesApplication = new List<ID_Card_Application__c>();
		if(!allSingleAppPerMassId.isEmpty()){

			allSinglesApplication = [select Id , Mass_order_Application__c from ID_Card_Application__c where recordTypeID = :IDCardUtil.IDCARDSINGLEAPPLICATION_RTID and Mass_order_Application__c in :allSingleAppPerMassId.keySet() ];
		}
		
		for(ID_Card_Application__c sa:allSinglesApplication){

			allSingleAppPerMassId.get(sa.Mass_order_Application__c).add(sa);
			massAppIdFromSingleAppid.put(sa.Id, sa.Mass_order_Application__c);
		}

		List<ID_Card__c> allCard = new List<ID_Card__c>();
		if(!massAppIdFromSingleAppid.isEmpty()){

			System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [DOWN] All single from MAss:  ' + allSinglesApplication.size());

			allCard = [select Id , Card_Status__c, ID_Card_Application__c from ID_Card__c where ID_Card_Application__c in :massAppIdFromSingleAppid.keySet() ];
			
			System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [DOWN] All card from Mass: ' + allCard.size());
		}
		
		//from all card: if card status isn t printed/delvied: then mass related application status shlould be false
		//else we let it at true.
		for(ID_Card__c acard : allCard){

			if(acard.Card_Status__c != 'Valid ID Card'){

				massAppStatus.put( massAppIdFromSingleAppid.get(acard.ID_Card_Application__c) ,false);
				System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [DOWN] FIND A card which should cancel the update for his mass.');
			}
		}
		
		//now we know which application should have their case updated
		List<String> massApplicationIdForCaseUpdate = new List<String>();
			
		for(String key : massAppStatus.keySet()) {

			if(massAppStatus.get(key)){

				massApplicationIdForCaseUpdate.add(key);
				System.debug('____ [cls IDCardCloseCaseAndCompleteApplication - execute] [FINAL] FIND a mass to update case:  ' + key);
			}
		}
			
		if(!massApplicationIdForCaseUpdate.isEmpty()){

			List<Case> cases2update = [select Id,Status, Related_ID_Card_Application__c from Case  where Related_ID_Card_Application__c in :massApplicationIdForCaseUpdate];
			
			for(Case acase : cases2update)
				acase.Status = 'Closed';

			if(!cases2update.isEmpty()) {

				Map<String, SObjectField> sObjectFieldMapCase = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();

				uw.registerDirty(cases2update, new List<SObjectField>{sObjectFieldMapCase.get('Status')});
			}		
		}

		if(!idcardAppToUpdate.isEmpty()){

			for(ID_Card_Application__c idapp : idcardAppToUpdate)
				idapp.Application_Status__c = 'Completed';

			if(!idcardAppToUpdate.isEmpty()) {

				Map<String, SObjectField> sObjectFieldMapIDCardApp = Schema.getGlobalDescribe().get('ID_Card_Application__c').getDescribe().fields.getMap();

				uw.registerDirty(idcardAppToUpdate, new List<SObjectField>{sObjectFieldMapIDCardApp.get('Application_Status__c')});
			}
		}
	}
}
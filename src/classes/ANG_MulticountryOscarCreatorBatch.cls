global class ANG_MulticountryOscarCreatorBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	
	global Set<Id> accountIds;

	global List<ANG_ConversionHelper.ConversionBatchItem> resultItems;

	global Map<String,String> oscarProcess = new Map<String, String> {
        AMS_Utils.HE => AMS_Utils.NEWHESTANDARD,
		AMS_Utils.AE => AMS_Utils.NEWAE	
	};

	global ANG_MulticountryOscarCreatorBatch(Set<Id> accountIds) {

		resultItems = new List<ANG_ConversionHelper.ConversionBatchItem>();

		List<String> fieldListAcct = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
			fieldListAcct.add(field);
		}
		
		this.accountIds = this.accountIds;	

		this.query = 'SELECT '+ String.join(fieldListAcct, ', ') + ' FROM Account WHERE Id in:accountIds';

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
		System.SavePoint sp;

		Account acct = (Account) scope.get(0);
		
        System.debug('[ANG_MulticountryOscarCreatorBatch] Starting to process account ' + acct);

		try{
	
			sp = Database.setSavePoint();

			String oscarId = null;//AMS_RecordCreatorWebservice.createAccreditation(acct.Id,AccreditationId,oscarProcess.get(acct.Location_Type__c), caseId)

			System.debug('[ANG_MulticountryOscarCreatorBatch] Oscar Created with ID:'+oscarId);

		}catch(Exception e){
			
            System.debug('[ANG_MulticountryOscarCreatorBatch] Exception processing account ' + acct.Id + ':' + e.getStackTraceString());
            
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), true, e.getMessage());

			System.debug(item);resultItems.add(item);Database.rollback(sp);

		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}
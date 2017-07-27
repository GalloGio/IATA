global class ANG_IEPChangecodeInvocationBatch implements Database.Batchable<sObject>, Database.Stateful {

	String query;

	global Integer run;

	global List<String> changeCodesIATACodes;

	global Map<String,ANG_CalloutMapping__c> changeCodeList;

	global Map<String,Id> changeCodeIdMap;
	
	global ANG_IEPChangecodeInvocationBatch(Map<String,ANG_CalloutMapping__c> changeCodeListInput, Map<String,Id> changeCodeIdMapInput) {
		
		this.changeCodeList = changeCodeListInput;

		this.changeCodeIdMap = changeCodeIdMapInput;

		changeCodesIATACodes = new List<String>(changeCodeList.keySet());

		Integer queryResults = changeCodesIATACodes.size();

		this.query = 'SELECT Id from Account LIMIT ' + queryResults;
		
		this.run = -1;
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		System.SavePoint sp;

   		try{

   			this.run++;
   			
   			sp = Database.setSavePoint();

   			String item = changeCodesIATACodes.get(run);

			ANG_IEP_CalloutHelper.invokeChangeCodeImpl(changeCodeList.get(item),item,changeCodeIdMap.get(item), true);

		}catch(Exception e){
			
			Database.rollback(sp);throw e;

		}


	}

		//Finish Method
	global void finish(Database.BatchableContext BC){}
	
	
}
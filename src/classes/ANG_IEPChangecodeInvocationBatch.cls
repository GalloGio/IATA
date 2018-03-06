public class ANG_IEPChangecodeInvocationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	String query;

	public Integer run;

	public list<ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper> recList;
	
	
	public ANG_IEPChangecodeInvocationBatch() {
	}

	public ANG_IEPChangecodeInvocationBatch(list<ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper> recList) {
		
		this.recList = new List<ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper>(recList);

		Integer queryResults = recList.size();

		this.query = 'SELECT Id from Account LIMIT ' + queryResults;
		
		this.run = -1;
		
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	public void execute(Database.BatchableContext BC, List<sObject> scope) {
   		system.debug('EXECUTING BATCH');

   		try{

   			this.run++;

   			ANG_IEP_CalloutHelper.ANG_calloutHelperWrapper item = recList.get(run);

			ANG_IEP_CalloutHelper.invokeChangeCodeImpl(item.calloutMapping,item.rec2Send,item.changeCodeId,item.agencyUpdateId,item.rec2Send.IATACode, true);

		}catch(Exception e){
			
			throw e;

		}

	}

		//Finish Method
	public void finish(Database.BatchableContext BC){}
	
	
}
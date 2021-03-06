public class RecordUpdater implements Schedulable {

	List<SObject> scope = new List<SObject>();

	public boolean isExpiryREBatch;

	public RecordUpdater(List<SObject> scope){
		this.scope = scope;
		this.isExpiryREBatch = false;
	}

	public RecordUpdater(List<SObject> scope, Boolean isExpiryREBatchIn){
		this.scope = scope;
		isExpiryREBatch = isExpiryREBatchIn;
	}

	public void schedule(Datetime runningTime){
		System.schedule('RecordUpdater '+System.now().format('dd/MM/yyyy hh:MM:ss.SSS'),
						runningTime.format('ss mm HH dd MM ? yyyy'), this);
	}

	public void execute(SchedulableContext sc){

	   try{

		   if(isExpiryREBatch)
				ANG_AccountTriggerHandler.isExpiration = true;

		   update scope;
	   }catch(Exception e){
			insert new Technical_Logs__c(Operation__c= 'RecordUpdater Job Id '+sc.getTriggerId(),
										Status__c= 'Error',
										Log__c= e.getMessage() + '/' + e.getStackTraceString());
	   }

	}

}

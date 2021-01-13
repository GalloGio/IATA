global class IDCard_CleanUp_Batch implements Database.Batchable<sObject>{


		global  list<ID_Card_Application__c> UnpaidIDCardApplication  = new list<ID_Card_Application__c>();


		global  list<ID_Card_Application__c> start(Database.BatchableContext BC){
				return UnpaidIDCardApplication;
		}

		//changes case status to Financial Security requested
		global void execute(Database.BatchableContext BC,  list<ID_Card_Application__c> scope){

		 try
		 {
						//delete the unpaid (that have not case associated)
						delete scope;
		 }
		 catch(Exception e)
		 {
				 System.debug(' IDCard_CleanUp_Batch  Error '+ e);
		 }

		}

		global void finish(Database.BatchableContext BC){
		}


}

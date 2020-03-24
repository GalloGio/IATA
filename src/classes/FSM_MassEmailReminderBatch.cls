global class FSM_MassEmailReminderBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
	global List<Case> caseList = new List<Case>();

	global List<Case> start(Database.BatchableContext BC){
		return caseList;
	}

	//changes case status to Financial Security requested
	global void execute(Database.BatchableContext BC, List<Case> scope){
		Boolean b = FSM_Webservice.sendListFSRequestedLetter(scope);
	}

	global void finish(Database.BatchableContext BC){}
}

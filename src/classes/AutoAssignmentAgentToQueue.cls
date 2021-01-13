// *************************************
// Vanja Djurdjevic | vanja.djurdjevic@b-i.com
// 1/11/2018
// Autoassign a case that has an offline (status logged off) agent owner, back to a corresponding queue
// *************************************
// This functionality works only for Global Product Queues (SIS, ICH,...)
// It matches cases by a record type Cases_Global. All other cases are skipped and
// are not treated by this class. The intention is not to conflict with previously
// implemented functionalities
global class AutoAssignmentAgentToQueue implements Database.Batchable<sObject> {

	global Iterable<sObject> start(Database.BatchableContext bc) {
		Iterable<sObject> cases = getPendingCasesWithOfflineOwner();
		return cases;
	}

	global void execute(Database.BatchableContext BC, list<sObject> scope) {
		for (sObject c : scope)
			assignCaseBackToQueue((case)c);
	}

	global void finish(Database.BatchableContext BC) {
		try {
			AutoAssignmentAgentToQueue assignBatch = new AutoAssignmentAgentToQueue();

			//schedule the next batch
			System.scheduleBatch(assignBatch, 'AutoAssignmentAgentToQueueBatch', 10, 10);

			AsyncApexJob a = [SELECT Id, Status, CompletedDate, JobItemsProcessed, ExtendedStatus, NumberOfErrors FROM AsyncApexJob WHERE Id = :BC.getJobId()];

			if (a != null && a.Status == 'Failed') {
				TransformationHelper.sendEmailSupport('AutoAssignmentAgentToQueueBatch: Job failed!', 'Job Id: ' + a.Id
																									+ '. CompletedDate: ' + a.CompletedDate
																									+ '. Number of Cases processed: ' + a.JobItemsProcessed 
																									+ '. Number of errors: ' + a.NumberOfErrors 
																									+ '. Error: ' + a.ExtendedStatus);
			}

		} catch (Exception ex) {
			TransformationHelper.sendEmailSupport('AutoAssignmentAgentToQueueBatch: Job failed!', ex.getMessage());
		}

	}

/*
* Returns a list of cases that have a record type: Cases_Global and have their owner agent offline
*/
	public static List<Case> getPendingCasesWithOfflineOwner() {
		List<Case> casesToReturn = new List<Case>();
		try {
			// get logged off agents
			Agents__c[] agents = [SELECT Id, User__c  FROM Agents__c WHERE Logged_on__c=False
								  AND Log_Off_Time_After_Timeout__c < :DateTime.now()];
			System.debug('logged off agents: '+agents);
			Id[] agentsToUsers = new List<Id>();
			Id[] recordTypes = new List<Id>();
			recordTypes.add(RecordTypeSingleton.getInstance().getRecordTypeId('Case','Cases_Global'));
			//recordTypes.add(RecordTypeSingleton.getInstance().getRecordTypeId('Case','ComplaintIDFS'));
			for(Agents__c agent: agents)
				agentsToUsers.add(agent.User__c);
			// get all the cases that these agents / users own
			// limited by case status, record type and case area
			casesToReturn = [SELECT Id FROM Case
							 WHERE status in ('Open', 'Action Needed', 'Reopen')
							 AND RecordTypeId IN :recordTypes
							 AND OwnerId in :agentsToUsers
							];
		} catch (Exception ex)   {
			System.debug('Something went wrong while fetching objects for reverse auto assignment.');
		}

		return casesToReturn;
	}

	public static void assignCaseBackToQueue(case currentCase) {
		try {
			//when case is assigned to a BPO User, reassign it using standard assignment rules
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule = true;
			currentCase.setOptions(dmo);
			update currentCase;
		} catch (Exception e) {
			TransformationHelper.sendEmailSupport('AutoAssignmentAgentToQueueBatch: Failed!', e.getMessage() + '   '  + e.getStacktraceString());
		}
	}
}
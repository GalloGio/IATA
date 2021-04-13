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
	
	public static string TestType;

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
			Integer Timeout = 60;
			//get the timeout
			Case_Agent_To_Queue_Assignment_Timeout__mdt defaultTimeout = [SELECT Timeout_In_Minutes__c FROM Case_Agent_To_Queue_Assignment_Timeout__mdt WHERE DeveloperName='Default_Timeout'];
			if(defaultTimeout != null) Timeout = Integer.valueOf(defaultTimeout.Timeout_In_Minutes__c);
			dateTime logoffTimeToConsider = Datetime.now().addMinutes(-1 * Timeout);
			
	
			//get the users to consider, AKA the one assigned to customer service profile
			set<string> setProfileToConsider = new set<string>{'GCS - Management - AI', 'GCS - Staff - AI'};
			set<id> setUserToConsider = new set<id>();
			for(User us:[select ID FROM user WHERE profile.name in:setProfileToConsider and isActive = True]){
				setUserToConsider.add(us.Id);
			}
	
			//exclude who is online
			for(UserServicePresence USP: [SELECT UserId FROM UserServicePresence WHERE UserId in: setUserToConsider and IsCurrentState = True]){
				if(setUserToConsider.contains(USP.UserId))
					setUserToConsider.remove(USP.UserId);
			}

			//getLoggedOff agents
			//Limit the scope to last 3 days to avoid having TOO MANY SOQL ROWS 50001 issue
			AggregateResult[] groupedResults = [select userid, max(StatusEndDate) from UserServicePresence where StatusEndDate<>null and userId in: setUserToConsider and  createdDate>=LAST_N_DAYS:3  group by userId];
			for(AggregateResult ar : groupedResults){
				id UserId = id.valueOf(string.Valueof(ar.get('userid')));
				if(datetime.valueOf(ar.get('expr0'))>logoffTimeToConsider)
					if(setUserToConsider.contains(UserId))
						setUserToConsider.remove(UserId);
			}
	
			Id[] recordTypes = new List<Id>();
			recordTypes.add(RecordTypeSingleton.getInstance().getRecordTypeId('Case','Cases_Global'));
			//recordTypes.add(RecordTypeSingleton.getInstance().getRecordTypeId('Case','ComplaintIDFS'));
			
			//In test classes there is no way to create record in UserServicePresence table nor to simulate user logging in/off omnichannel
			//Hence, we simulate it
			if(test.isRunningTest()){
				if(TestType=='reassign')
					setUserToConsider.add(UserInfo.getUserId());
				else{
					if(setUserToConsider.contains(UserInfo.getUserId()))
						setUserToConsider.remove(UserInfo.getUserId());
				}
			}

			// get all the cases that these agents / users own
			// limited by case status, record type and case area
			casesToReturn = [SELECT Id FROM Case
							 WHERE status in ('Open', 'Action Needed', 'Reopen')
							 AND RecordTypeId IN :recordTypes
							 AND OwnerId in :setUserToConsider
							];
		} catch (Exception e){
			System.debug(loggingLevel.FINEST, '____ [cls AutoAssignmentAgentToQueueBatch - getPendingCasesWithOfflineOwner] Exception - ' + e.getMessage() + '   '  + e.getStacktraceString());
			TransformationHelper.sendEmailSupport('AutoAssignmentAgentToQueueBatch: Something went wrong while fetching objects for reverse auto assignment.!', e.getMessage() + '   '  + e.getStacktraceString());
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

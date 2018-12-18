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
            System.debug('+++ the batch just ran');
            Iterable<sObject> cases = getPendingCasesWithOfflineOwner();
            System.debug('+++ pending cases: '+ cases);
            return cases;
        }
    
    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        for (sObject c : scope)
            assignCaseBackToQueue(c.Id);
    }
    
    global void finish(Database.BatchableContext BC) {
        try {
            AutoAssignmentAgentToQueue assignBatch = new AutoAssignmentAgentToQueue();

            //schedule the next batch
            System.scheduleBatch(assignBatch, 'AutoAssignmentAgentToQueueBatch', 10, 10);

            AsyncApexJob a = [SELECT Id, Status, CompletedDate, JobItemsProcessed FROM AsyncApexJob WHERE Id = :BC.getJobId()];

            if (a != null && a.Status == 'Failed') {
                String mailSubject = 'AutoAssignmentAgentToQueueBatch: Job failed!';
                String errorMessage = 'CompletedDate: ' + a.CompletedDate + 'Number of Cases processed: ' + a.JobItemsProcessed;

                //Todo: test coverage not met for this method so avoid using it for now
                //emailAlert(mailSubject, errorMessage, getUserIds(getSupportEmails()));
				System.debug('AutoAssignmentAgentToQueueBatch: Job failed!');
            }

        } catch (Exception ex) {
            //emailAlert('AutoAssignmentAgentToQueueBatch', ex.getMessage() + ' ' + ex.getStackTraceString(), null, getUserIds(getSupportEmails()));
        	System.debug('AutoAssignmentAgentToQueueBatch: Job failed! '+ ex.getMessage());
        }

    }
    
    /**
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
            recordTypes.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                             .get('Cases_Global').getRecordTypeId());
            recordTypes.add(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                             .get('ComplaintIDFS').getRecordTypeId());
            for(Agents__c agent: agents)
                agentsToUsers.add(agent.User__c);
            System.debug('+++ Agent users: '+agentsToUsers);
            // get all the cases that these agents / users own
            // limited by case status, record type and case area
            casesToReturn = [SELECT Id FROM Case 
                             WHERE status in ('Open', 'Action Needed', 'Reopen', 'In progress')
                             AND RecordTypeId IN :recordTypes
                             AND OwnerId in :agentsToUsers
                            ];
        } catch (Exception ex)   {
            System.debug('Something went wrong while fetching objects for reverse auto assignment.');
        }
        
        return casesToReturn;
    }
    
    public static void assignCaseBackToQueue(string idCase) {
        try {
            
            System.debug('+++ starting assigning back...');
            Case currentCase = [SELECT Id, CaseArea__c, Topic__c FROM Case WHERE Id=:idCase];
            GCS_Product_to_Queue_Assignment__mdt[] areaToQueue; 
            System.debug('+++ case Id: '+currentCase.Id);
            if(currentCase.CaseArea__c != null) {
                System.debug('Case Area on case found: '+ currentCase.CaseArea__c);
                areaToQueue= [SELECT Queue_API_Name__c FROM GCS_Product_to_Queue_Assignment__mdt
                              WHERE GCS_Product_Topic__c=:currentCase.CaseArea__c LIMIT 1];
                
                System.debug('Metadata assignemnts found (first try): '+areaToQueue);
            } else if(currentCase.Topic__c != null) {
                System.debug('Queue not found based on case area, not falling back to topic: '+currentCase.Topic__c);
                areaToQueue = [SELECT Queue_API_Name__c FROM GCS_Product_to_Queue_Assignment__mdt
                               WHERE Product_Topic__c =:currentCase.Topic__c LIMIT 1];
                
            } else
                System.debug('Failed to match by case area or topic...');
            
            if(areaToQueue.size() > 0) {
                System.debug('found a coresponding product queue '+ areaToQueue);
                Group[] queue = [SELECT Id FROM
                                 Group WHERE Type='Queue' 
                                 AND DeveloperName=:areaToQueue[0].Queue_API_Name__c];
                System.debug('+++ Queue found by API Name: '+queue);
                if(queue.size() > 0) {
                    currentCase.OwnerId = queue[0].Id;
                    update currentCase;
                } else
                    System.debug('Found Queue not active, not assigning!');
            }
            else {
                System.debug('Area to Queue entry is null');
            }
        } catch (Exception e) {
            TransformationHelper.sendEmailSupport('AutoAssignmentEngineSF', e.getMessage() + '   '  + e.getStacktraceString());
        }
    }
}
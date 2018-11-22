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
	// TODO: rewrite as custom settings
    private static Integer offlineTimeoutMinutes = 20;
    private static String[] productList = new List<String>{'ICH', 'SIS', 'iiNet', 'E&F'};
    
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
		System.debug('+++ The job just finished!');
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
            for(Agents__c agent: agents)
                agentsToUsers.add(agent.User__c);
            System.debug('+++ Agent users: '+agentsToUsers);
            // get all the cases that these agents / users own
            // limited by case status, record type and case area
            casesToReturn = [SELECT Id FROM Case 
                             WHERE status in ('Open', 'Action Needed', 'Reopen', 'In progress')
                             AND RecordTypeId=
                             :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                             .get('Cases_Global').getRecordTypeId()
                             AND OwnerId in :agentsToUsers
                             //AND CaseArea__c in :productList
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
            GCS_Product_to_Queue_Assignment__mdt areaToQueue;
            if(currentCase.CaseArea__c != null) {
                areaToQueue= [SELECT Queue_Id__c FROM GCS_Product_to_Queue_Assignment__mdt
                              WHERE GCS_Product_Topic__c=:currentCase.CaseArea__c LIMIT 1];

                System.debug('Metadata assignemnts found (first try): '+areaToQueue);
            } else if(currentCase.Topic__c != null) {
                System.debug('Queue not found based on case area, not falling back to topic');
                areaToQueue = [SELECT Queue_Id__c FROM GCS_Product_to_Queue_Assignment__mdt
                               WHERE Product_Topic__c =:currentCase.Topic__c LIMIT 1];

            } else
                System.debug('No queue matching found, finishing...');

            if(areaToQueue != null) {
                System.debug('found a coresponding product queue '+ areaToQueue
                            + ' matched by '+currentCase.Topic__c);
                System.debug('area to queue id: '+ areaToQueue.Queue_Id__c);
                Auto_Queue__c[] autoQueue = [select Queue_ID__c, Name from Auto_Queue__c
                                             where Active__c = true
                                             and Queue_ID__c=:areaToQueue.Queue_Id__c];
                System.debug('+++3 '+autoQueue);
                if(autoQueue != null) {
                    currentCase.OwnerId = autoQueue[0].Queue_ID__c;
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
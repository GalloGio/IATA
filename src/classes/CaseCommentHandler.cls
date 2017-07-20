public with sharing class CaseCommentHandler {

    public static void doBeforeInsert(list<CaseComment> listComments) {
        
        // chck if the incoming casecomment comes from E2CP process
        if (getE2cpRunUsers().contains(UserInfo.getUSerId())) {
            preventInsertionInClosedCases(listComments);
        }
    }
    
    /**
        If an input case comment tries to insert then it is blocked, but only if:
            - case belongs to a list of RTs
            - Case is closed for more than 2 weeks
            - Incoming case comment is public
    **/
    private static void preventInsertionInClosedCases(list<CaseComment> listComments) {
        Set<Id> caseIds = new Set<Id>();
        for (CaseComment caseComment : listComments) {
            caseIds.add(caseComment.parentId);
        }

        Map<Id, Case> casesMap = new Map<Id, Case>([
            SELECT Id, ClosedDate
            FROM Case
            WHERE Id IN :caseIds
            AND RecordType.DeveloperName IN :EmailMessageHandler.LIST_VALID_RT]);

        List<CaseComment> caseComments = new List<CaseComment>();
        for (CaseComment caseComment : listComments) {
            Case parentCase = casesMap.get(caseComment.ParentId);
            if (caseComment.IsPublished && parentCase!=null && parentCase.ClosedDate < Date.today().addDays(-14)) {
                caseComment.addError('Case Comment ignored because the parent case is closed for more than 2 weeks'); // prevent insertion
            }
        }
    }
    
    /**
        Get an id list of all users runing the E2CP email service
        To check this manually go to:
            Setup->EmailService->select 'ProcessMessage' service->Check run users
    **/
    public static set<Id> TEST_E2CPRUNUSERS = new set<id>();
    private static set<Id> getE2cpRunUsers() {
        set<Id> listRunUsers = new set<Id>();
        // Apex class in Email to Case Premium used to process incoming emails
        list<ApexClass> listClasses = [Select Id  from ApexClass where Name = 'ProcessMessage'];
        //Find run as users related to the E2CP service
        for (EmailServicesAddress serviceAddress: [
                SELECT Id, RunAsUserId
                FROM EmailServicesAddress
                WHERE Function.ApexClassId IN :listClasses])
        {
            listRunUsers.add(serviceAddress.RunAsUserId);
        }
        return Test.isRunningTest()? TEST_E2CPRUNUSERS: listRunUsers;
    }
}
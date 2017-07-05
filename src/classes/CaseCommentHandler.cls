public with sharing class CaseCommentHandler {

    public static void doBeforeInsert(list<CaseComment> listComments) {
        User currentUser = [SELECT Id, IsPortalEnabled FROM User WHERE id = :UserInfo.getUSerId()];
        if (currentUser.IsPortalEnabled) {
            preventInsertionInClosedCases(listComments);
        }
    }
    
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
            if (parentCase!=null && parentCase.ClosedDate < Date.today().addDays(-14)) {
                caseComment.addError('Case Comment ignored because the parent case is closed for more than 2 weeks'); // prevent insertion
            }
        }
    }
}
public with sharing class AutomateCaseCommentToChildCase {

    /* This function is meant to be called from a process (from process builder) and is supposed to receive a list with only 1 case */
    @InvocableMethod(label='Copy comment to child cases' description='Copy a case coment to his child cases')
    public static List<Boolean> copyCommentToChilds(List<Id> caseIds){
        System.debug('Entered copyCommentToChilds');
        String comment = [SELECT E2CP__Most_Recent_Public_Comment__c FROM Case WHERE Id = :caseIds.get(0)].E2CP__Most_Recent_Public_Comment__c;
        List<Case> cases  = [SELECT Id FROM Case WHERE ParentId = :caseIds.get(0)];

        if(comment != null && comment != '' && cases.size() > 0){
            System.debug('Entered conditional block');
            List<CaseComment> newComents = new List<CaseComment>();
            for(Case c: cases){
                newComents.add(
                    new CaseComment(
                        CommentBody = comment,
                        ParentId =  c.Id
                    )
                );
            }
            try {
                insert newComents;
            } catch (Exception e) {
                System.debug('Failed');
                return new List<Boolean>{false};
            }
        }
           System.debug('Succeded');
        return new List<Boolean>{true};
    }
}
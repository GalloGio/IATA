public with sharing class NewCommentController {

    public Id objectiveId;

    public NewCommentController(ApexPages.standardController controller) {
        this.objectiveId = ApexPages.CurrentPage().getParameters().get('parent');
    }

    public Pagereference redirect() {
        Comment__c comment = new Comment__c();
        if (this.objectiveId == null ){
            comment.Parent_Objective__c = null;
            comment.RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Comment__c', 'Objective_Independent');
            
        } else {
            comment.Parent_Objective__c = this.objectiveId;
            comment.RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Comment__c', 'Objective_Related');
        }
        insert comment;

        Pagereference pageref = new Pagereference('/'+comment.Id + '/e');
        pageref.getParameters().put('retURL','/' + this.objectiveId);
        pageref.setRedirect(true);
        return pageref;
    }

}
public with sharing class QualityApprovalController {
    
    public static final String SUCCESS = 'success';
    public static final String WARNING = 'warning';
    public static final String DANGER = 'danger';
    public static final String INFO = 'info';

    public Quality__c quality {get;set;}
    public map<Id,User> mapUsers {get;set;}
    public Id userId {get;set;}
    public User user {get;set;}
    public String searchString {get;set;}
    public Integer showstep {get;set;}
    public MessageWrapper step1Message {get;set;}
    public MessageWrapper messageResult {get;set;}
    
    public QualityApprovalController(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) controller.addFields(new list<String>{'Status__c','Deadline_for_Approval__c'});
        this.quality = (Quality__c)controller.getRecord();
        goToStep1();
    }
    
    /**
        query users searching by name
    **/
    public void searchUsers() {
        String str = '%' + this.searchString + '%';
        this.mapUsers = new map<Id,User>([
            SELECT Id, Name
            FROM User
            WHERE Name LIKE :str
            AND IsActive = true 
            AND IsPortalEnabled = false
            LIMIT 100]);
    }
    
    /**
        get the list of users in the user map
    **/
    public list<User> getListUser() {
        if (this.mapUsers==null) {
            this.mapUsers = new map<Id,User>();
        }
        return this.mapUsers.values();
    }
    
    /**
        First step is checking the parent record, before starting the approval 
        process we verify if the process is allowed
    **/
    public Pagereference goToStep1() {
        this.showstep=1;
        this.step1Message = new MessageWrapper();
        if (isSubmittedForApproval()) {
            this.step1Message.text = 'This record is in an approval process';
            this.step1Message.type = WARNING;
            
        } else if ( quality.Status__c == 'Under Investigation' || quality.Status__c == 'Pending Input' ) {
            if (quality.Deadline_for_Approval__c != null && quality.Deadline_for_Approval__c > DateTime.now() ) {
                this.step1Message.text = 'Once you submit this record for approval, you might not be able to edit it or recall it from the approval process depending on your settings.\n\nThe Deadline for Approval is: ' + quality.Deadline_for_Approval__c + '.\n\nIf the DfA is incorrect, please click on Cancel below in order to go back and edit it.\n\nContinue?';
                this.step1Message.type = INFO;
                //show approval
            } else {
                this.step1Message.text = 'Please select a valid Deadline for Approval date before submitting the record for approval.';
                this.step1Message.type = WARNING;
            }
        } else {
            this.step1Message.text = 'Once you submit this record for approval, you might not be able to edit it or recall it from the approval process depending on your settings.\nContinue?';
            this.step1Message.type = INFO;
        }
        return null;
    }
    
    /**
        Return tru if there is a another approval process awaiting
    **/
    private Boolean isSubmittedForApproval() {
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :this.quality.Id 
        ];
        return workItems.size()>0;
    }
    
    /**
        Move to step 2, where the user search and selects the approval user
    **/
    public Pagereference goToStep2() {
        this.showstep=2;
        searchUsers();
        return null;
    }
    
    /**
        Move to step 3, where the user finally confirms the approval process
    **/
    public Pagereference goToStep3() {
        this.showstep=3;
        this.user = this.mapUsers.get(this.userId);
        return null;
    }
    
    /**
        Create an approval request for the Exception
    **/
    public Pagereference goToStep4() {
        try {
            Approval.ProcessSubmitRequest req1 = 
                new Approval.ProcessSubmitRequest();
            req1.setObjectId(quality.id);
            req1.setNextApproverIds(new list<Id>{userId});
            Approval.ProcessResult result = Approval.process(req1);
            
            this.messageResult = new MessageWrapper();
            if (result.isSuccess() ) {
                this.messageResult.text = 'Approval process submitted';
                this.messageResult.type = SUCCESS;
            } else {
                this.messageResult.text = '';
                for (Database.Error error: result.getErrors()) {
                    this.messageResult.text += error.getMessage() + '\n';
                }
                this.messageResult.type = DANGER;
            }
        } catch(Exception e) {
            this.messageResult = new MessageWrapper();
            this.messageResult.text = e.getMessage();
            this.messageResult.type = DANGER;
        }
        this.showstep=4;
        return null;
    }
    
    public class MessageWrapper {
        public String text {get;set;}
        public String type {get;set;}
    }
}
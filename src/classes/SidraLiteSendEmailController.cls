public with sharing class SidraLiteSendEmailController {

    public Case cse {get;set;}
    public Case dummyCase {get;set;}
    public String selectedToCase {get;set;}
    public String selectedCustomize {get;set;}
    public String selectedType {get;set;}
    public EmailTemplate emailTemplate {get;set;}
    public MailmergeTemplate mergeTemplate {get;set;}


    public SidraLiteSendEmailController() {
        Id caseId = ApexPages.currentPage().getParameters().get('id');
        if (caseId == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Parameter case ID required'));
            return;
        }
        list<Case> listCase = [Select Id, CaseNumber, Parent.CaseNumber, Subject, Parent.Subject, Contact.Id, Contact.Name, Parent.Id, Parent.Contact.Id, Parent.Contact.Name, Recordtype.Name, BSPCountry__c,
            Activate_Agent_in_Systems__c, Confirm_IRR_Withdrawal_to_AG__c, Confirm_Reinstatement_to_AG__c, Deactivate_Agent_in_Systems__c,
            Inform_Agent_DEF__c, Inform_Airlines_Locally_Default__c, Inform_Airlines_REI_DEFWD__c, Issue_Declaration_of_Default_to_Agent__c,
            NOI_sent__c, NOT_Sent__c, Notify_TER_to_AG__c, Open_TKT_System__c, Shut_Down_TKT_System_GDS_and_BSPlink__c,
            Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_TER__c,
            SIDRA_Lite_Reason__c, Region__c, Account.Type
            from Case where id = :caseId];
        if (listCase.isEmpty()) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'No case found with id ' + caseId));
            return;
        }

        this.cse = listCase[0];
        if (this.cse.ParentId==null) {
            this.selectedToCase = 'current';
        }
        this.dummyCase = new Case();
    }

    public void findTemplates() {
        try {
            String templateId = SidraLiteUtil.getEmailTemplate(this.cse, this.selectedType);
            this.emailTemplate = [Select Id, Name from EmailTemplate where id = :templateId];
        } catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            this.selectedCustomize = 'true';
        }
        try {
            String templateId = SidraLiteUtil.getMergeTemplate(this.cse, this.selectedType);
            this.mergeTemplate = [Select Id, Name from MailmergeTemplate where id = :templateId];
        } catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            this.selectedCustomize = 'true';
        }
    }

    public PageReference goToCongaSendEmail() {
        if (!checkFields()) {
            return null;
        }
        if (this.selectedType=='IRR') {
            this.cse.NOI_sent__c = this.dummyCase.NOI_sent__c;
            this.cse.Update_AIMS_IRR__c = this.dummyCase.Update_AIMS_IRR__c;
        }
        if (this.selectedType=='IRRWD') {
            this.cse.Confirm_IRR_Withdrawal_to_AG__c = this.dummyCase.Confirm_IRR_Withdrawal_to_AG__c;
            this.cse.Update_AIMS_IRRWITH__c = this.dummyCase.Update_AIMS_IRRWITH__c;
        }
        if (this.selectedType=='DEF') {
            this.cse.Update_AIMS_DEF__c = this.dummyCase.Update_AIMS_DEF__c;
            this.cse.Inform_Agent_DEF__c = this.dummyCase.Inform_Agent_DEF__c;
            this.cse.Inform_Airlines_Locally_Default__c = this.dummyCase.Inform_Airlines_Locally_Default__c;
            this.cse.Issue_Declaration_of_Default_to_Agent__c = this.dummyCase.Issue_Declaration_of_Default_to_Agent__c;
            this.cse.Shut_Down_TKT_System_GDS_and_BSPlink__c = this.dummyCase.Shut_Down_TKT_System_GDS_and_BSPlink__c;
            this.cse.Deactivate_Agent_in_Systems__c = this.dummyCase.Deactivate_Agent_in_Systems__c;
        }
        if (this.selectedType=='DEFWD' || this.selectedType=='REI') {
            this.cse.Confirm_Reinstatement_to_AG__c = this.dummyCase.Confirm_Reinstatement_to_AG__c;
            this.cse.Activate_Agent_in_Systems__c = this.dummyCase.Activate_Agent_in_Systems__c;
            this.cse.Open_TKT_System__c = this.dummyCase.Open_TKT_System__c;
            this.cse.Inform_Airlines_REI_DEFWD__c = this.dummyCase.Inform_Airlines_REI_DEFWD__c;
            this.cse.Ticketing_Authority_Re_assigned__c = this.dummyCase.Ticketing_Authority_Re_assigned__c;
        }
        if (this.selectedType=='NOT') {
            this.cse.NOT_Sent__c = this.dummyCase.NOT_Sent__c;
        }
        if (this.selectedType=='TER') {
            this.cse.Notify_TER_to_AG__c = this.dummyCase.Notify_TER_to_AG__c;
            this.cse.Update_AIMS_TER__c = this.dummyCase.Update_AIMS_TER__c;
        }

        try {
            update this.cse;
            return new PageReference(getURLCongaMerge());

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            return null;
        }
    }

    private Boolean checkFields() {
        Boolean result = true;
        if (this.selectedToCase==null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Select an option for email to'));
            result = false;
        }
        if (this.selectedCustomize==null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Select a template option'));
            result = false;
        }
        if (this.selectedType==null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING, 'Select a type'));
            result = false;
        }
        return result;
    }

    public class SendEmailException extends Exception{}

    private String getURLCongaMerge() {
        //Select id,

        // get 'From Email' using predefined custom setting 'RecordTypeEmail'
        String fromEmail = IDFS_Util.getRecordTypeEmail(cse.Recordtype.Name, cse.BSPCountry__c);
        list<OrgWideEmailAddress> listadd = [
            Select Id, DisplayName, Address
            From OrgWideEmailAddress
            Where Address = :fromEmail];

        if (listadd.isEmpty()) {
            throw new SendEmailException('No Organization Wide Address found');
        }

        // get Case to use as 'To email'
        Case selectedCase;
        if (this.selectedToCase=='current') {
            selectedCase = this.cse;
        } else {
            selectedCase = this.cse.Parent;
        }

        // return conga url
        if (this.selectedCustomize == 'true') {
            // cutomize template version
            return CongaManager.goToSendEmailConga(UserInfo.getSessionId(), selectedCase.Id, selectedCase.ContactId, listadd[0].id);
        } else {
            // automated version with given templates
            return CongaManager.sendEmailURL(UserInfo.getSessionId(), selectedCase.Id, selectedCase.ContactId, this.mergeTemplate.Id, this.emailTemplate.Id, listadd[0].id);
        }
    }

    public PageReference returnToCase() {
        if (this.cse!=null) {
            return new PageReference('/' + this.cse.Id);
        } else {
            return new PageReference('/');
        }
    }

}

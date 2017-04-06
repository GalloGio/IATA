public  class ISSP_Ctrl_AccountStatements_Accept {

    public Portal_Application_Right__c appRight {get;set;}
    public list<String> errorMessage {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}

    public ISSP_Ctrl_AccountStatements_Accept() {
        this.errorMessage = new list<String>();
        try {
            User user = [
                Select Id, ContactId, Contact.AccountId
                From User
                Where id = :UserInfo.getUserId()];

            String strId = user.ContactId;
            this.appRight = [
                Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c
                From Portal_Application_Right__c
                Where ContactId__c = :strId.left(15)
                And Portal_Application__r.Name = :ISSP_Ctrl_AccountStatements.APP_NAME
            ];
        } catch(Exception e) {
            this.errorMessage.add(e.getMessage());
        }
    }

    public PageReference acceptTerms() {
        if (this.appRight.Terms_Acceptance__c == false) {
            this.errorMessage.add(Label.ISSP_Accept_Terms_Warning);
            return null;
        }

        this.appRight.Terms_Acceptance_Date__c = DateTime.now();
        update this.appRight;

        PageReference pageref = new PageReference('/ISSP_AccountStatements' + commParam);
        pageref.setRedirect(true);
        return pageref;
    }

    public PageReference rejectTerms() {
        PageReference pageref = new PageReference('/ISSP_Homepage' + commParam);
        pageref.setRedirect(true);
        return pageref;
    }
}
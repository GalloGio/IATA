public without sharing class ISSP_CurrencyCenterTandCController {

	public Portal_Application_Right__c appRight {get;set;}
    public list<String> errorMessage {get; set;}
    public Boolean isAcceptChecked {get;set;}

    public ISSP_CurrencyCenterTandCController() {
        this.errorMessage = new list<String>();
        this.isAcceptChecked = false;
        try {
            User user = [
                Select Id, ContactId
                From User
                Where id = :UserInfo.getUserId()];

            this.appRight = [
                Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c
                From Portal_Application_Right__c
                Where Contact__c = :user.ContactId
                And Application_Start_URL__c = '/ISSP_CurrencyCenterHome'
            ];
        } catch(Exception e) {
            this.errorMessage.add(e.getMessage());
        }
    }

    public PageReference acceptTerms() {
        //if (this.appRight.Terms_Acceptance__c == false) {
        if (!this.isAcceptChecked) {
            this.errorMessage.add(Label.ISSP_Accept_Terms_Warning);
            return null;
        }
        
        this.appRight.Terms_Acceptance__c = this.isAcceptChecked;
        this.appRight.Terms_Acceptance_Date__c = DateTime.now();
        update this.appRight;
        
        PageReference pageref = new PageReference('/ISSP_CurrencyCenterHome');
        pageref.setRedirect(true);
        return pageref;
    }

    public PageReference rejectTerms() {
        PageReference pageref = new PageReference('/ISSP_Homepage');
        pageref.setRedirect(true);
        return pageref;
    }
}
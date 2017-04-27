public class vfExceptionPage{
    public Case c {get;private set;}
    public String ContactName {get;private set;}
    public String communityName {get;private set;}

    // //CNS
    // public String communityName{ get{
    //     // return ApexPages.currentPage().getParameters().get('CommunityName');
    //     return 'com ' +
    // }set;}

    public vfExceptionPage(){
        this.c = new Case();
        this.c.Subject = 'Error portal - broken VF page';
        this.c.Description = 'the user was on the following page before the error occurred »  https://'+Site.getDomain()+Site.getOriginalUrl()+ '\n'+ Site.getErrorDescription();
        User u = [select Id,Name,ContactId,Contact.Account.BillingCountry,Contact.CNS_Contact__c from User where Id = :UserInfo.getUserId()];
        this.ContactName  = u.Name;
        this.c.ContactId = u.ContactId;
        this.c.BSPCountry__c = u.Contact.Account.BillingCountry;
        this.communityName = 'IATA';
        if(u.Contact.CNS_Contact__c) this.communityName = 'CNS';
    }
    public void CreateCase() {

        //insert this.c;
        //this.c = [select Id,CaseNumber,Description,Subject  from case where Id = :this.c.Id];
    }
}
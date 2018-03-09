public without sharing class ISSP_TIP_Home_Controller {
    
    private static String STANDARD_ACCOUNT_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId;
    private static String PAYMENT_PROVIDER_RECORD_TYPE_ID = Schema.SObjectType.Account.RecordTypeInfosByName.get('Payment Provider').RecordTypeId;


    public ISSP_TIP_Home_Controller(){
    	popContact();
    }
/*
    public string teste {get;set;}
    public string sortExpression {get;set;}
    public string sortdirection {get;set;}*/
    public string currNavState {get;set;}
    
    public Contact con {get; set;}
    public Account acc {get;set;}
    public boolean btnEnabled {get;set;}
    public boolean isAdmin {get; set;}     //identify if a user is an administrator or not
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public IATA_ISO_Country__c isocountry {get; set;}
	
	public Boolean getnewlabels() {
        if (isocountry==null) return false;
        return isocountry.AMS_Accreditation_New_Labels__c;
    }



    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);

        //if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
            isAdmin = false;

        acc = [SELECT id, recordtypeid, category__c FROM ACCOUNT WHERE ID = :con.AccountId];

        if(acc.recordtypeid == STANDARD_ACCOUNT_RECORD_TYPE_ID && acc.category__c=='Payment Provider')
        	btnEnabled = true;
        else
        	btnEnabled = false;
    }

    public List<Case> getCases(){
    	return [SELECT id,status,CaseNumber, subject, createddate  FROM Case WHERE AccountId = :con.AccountId];
    }
	
	public void refresh(){}
}
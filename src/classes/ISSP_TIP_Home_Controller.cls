public without sharing class ISSP_TIP_Home_Controller {
    
    private static String STANDARD_ACCOUNT_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard Account');      
    private static String PAYMENT_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Payment Provider');
    
    private static String PROCESS_CASE_RECORD_TYPE_ID     = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');


    public ISSP_TIP_Home_Controller(){
    	popContact();
    }

    public string currNavState {get;set;}    
    public Contact con {get; set;}
    public Account acc {get;set;}
    public boolean btnEnabled {get;set;}
    public boolean isAdmin {get; set;}     //identify if a user is an administrator or not
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public IATA_ISO_Country__c isocountry {get; set;}


    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);

        //if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
        if (con.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM ) isAdmin = true;

        acc = [SELECT id, recordtypeid, category__c FROM ACCOUNT WHERE ID = :con.AccountId];

        btnEnabled = (acc.recordtypeid == STANDARD_ACCOUNT_RECORD_TYPE_ID && acc.category__c=='Payment Provider');
    }

    public List<Case> getCases(){
    	Set<string> closedStatusesList = createListOfClosedStatuses();

    	return [SELECT id,status,CaseNumber, subject, createddate,CaseArea__c  FROM Case 
    	WHERE AccountId = :con.AccountId 
    	and recordtypeid = :PROCESS_CASE_RECORD_TYPE_ID 
    	and CaseArea__c like '%Transparency in Payments%'
    	AND (Status = 'Draft' OR Status Not In :closedStatusesList)];
    }
	
    public Set<string> createListOfClosedStatuses() {
        Set<string> closedStatusesList = new Set<string>();
        Schema.DescribeFieldResult caseDescribe = case.Status.getDescribe();

        List<Schema.PicklistEntry> caseStatusValues = caseDescribe.getPicklistValues();

        List<String> caseStatuesStrValues = new List<String>();

        for (Schema.PicklistEntry csv : caseStatusValues)
            caseStatuesStrValues.add(csv.getValue());

        for (casestatus cs : [Select Apiname, IsClosed from casestatus where ApiName IN: caseStatuesStrValues And IsClosed = true])
            closedStatusesList.add(cs.apiname);

        return closedStatusesList;
    }

}
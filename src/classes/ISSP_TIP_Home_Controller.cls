public without sharing class ISSP_TIP_Home_Controller {
    
    private static String STANDARD_ACCOUNT_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account');      
    private static String PAYMENT_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('TIP_Payment_Provider');
    
    private static String PROCESS_CASE_RECORD_TYPE_ID     = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');

    private static String TIP_PRODUCT_RECORD_TYPE_ID      = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Partner_products__c').get('TIP_Product');


    public string currNavState {get;set;}    
    public Contact con {get; set;}
    public Account acc {get;set;}
    public boolean isPaymentProvider {get;set;} 
    public boolean btnEnabled {get;set;}
    public boolean isAdmin {get; set;}     //identify if a user is an administrator or not
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public IATA_ISO_Country__c isocountry {get; set;}
    public List<productWrapper> products {get ;set;}


    public ISSP_TIP_Home_Controller(){
        popContact();
        fillProducts();
    }


    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);


        //if (con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
        isAdmin = (con.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM);
        

        acc = [SELECT id, recordtypeid, category__c FROM ACCOUNT WHERE ID = :con.AccountId];

        /*btnEnabled = (acc.recordtypeid == STANDARD_ACCOUNT_RECORD_TYPE_ID && acc.category__c=='Payment Provider');
        isPaymentProvider = (acc.category__c=='Payment Provider');*/

        btnEnabled = (acc.recordtypeid == STANDARD_ACCOUNT_RECORD_TYPE_ID && acc.category__c=='Payment Provider');
        isPaymentProvider = (acc.recordtypeid == PAYMENT_PROVIDER_RECORD_TYPE_ID);

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

    private void fillProducts(){
        products = new List<productWrapper> ();
        for(Partner_products__c p :[SELECT id, name, PP_Payment_network__c, PP_Effective_to_Date__c, PP_Effective_from_Date__c, PP_status__c
          FROM Partner_products__c 
          WHERE Provider__c  = :con.AccountId
            AND recordtypeid = :TIP_PRODUCT_RECORD_TYPE_ID]){
            
            products.add(new productWrapper(p.id,p.name, p.PP_Payment_network__c,p.PP_Effective_to_Date__c,p.PP_Effective_from_Date__c, p.PP_status__c));
        }


    }


    public class productWrapper{
        public ID id {get;set;}
        public String name {get;set;}
        public String paymentNetwork {get;set;}
        public String effectiveToDate {get;set;}
        public String effectiveFromDate {get;set;}
        public String status {get;set;}

        public productWrapper(ID id, String name, String paymentNetwork, Date effectiveToDate, Date effectiveFromDate, String status){
            this.id = id;
            this.name = name;
            this.paymentNetwork = paymentNetwork;
            this.status = status;

            if(effectiveToDate != null)
                this.effectiveToDate = effectiveToDate.year() + '-' + effectiveToDate.month() + '-' + effectiveToDate.day();
            else 
                this.effectiveToDate = '';            

            if(effectiveFromDate != null)
                this.effectiveFromDate = effectiveFromDate.year() + '-' + effectiveFromDate.month() + '-' + effectiveFromDate.day();
            else 
                this.effectiveFromDate = '';
                        
        }

    } 



}
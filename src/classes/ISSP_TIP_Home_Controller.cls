public with sharing class ISSP_TIP_Home_Controller {

    private static String STANDARD_ACCOUNT_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account');      
    private static String PAYMENT_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('TIP_Payment_Provider');
    private static String PROCESS_CASE_RECORD_TYPE_ID     = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');
    private static String TIP_PRODUCT_RECORD_TYPE_ID      = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Partner_products__c').get('TIP_Product');


    //##======================VARIABLES=================================##

    //home Page
    public string currNavState {get;set;}    
    public Contact con {get; set;}
    public Account acc {get;set;}
    public boolean isPaymentProvider {get;set;} 
    public boolean btnEnabled {get;set;}
    public boolean isAdmin {get; set;}     //identify if a user is an administrator or not
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public IATA_ISO_Country__c isocountry {get; set;}
    public List<productWrapper> products {get ;set;}
    public boolean editMode{get;set;}
    public String binRangeChangeRequestText{get;Set;}

    //
    public String applyLanguage {get; set;}
    public String displayLanguage {get; set;}   

    public User user {get; set;}
    //public Contact con {get; set;}
    public Account account {get; set;}
    public Partner_products__c newpp {get; set;}
    private Id accountID {get; set;}
    private Case newCase {get; set;}
    public boolean isNew {get; set;}
    public list<BinRangeRec> binRangeList{get; set;}
    public String[] paymentGuaranteeVal{get;set;}
    public String[] acceptedTransactionVal{get;set;}
    public Decimal binRangeLen{get;set;}
    private map<string,Decimal> paymentNetworkMap{
            get{
                if(paymentNetworkMap==null) paymentNetworkMap= new map<string,Decimal>();
                for(TIP_Payment_Network_Config__c tpnc: TIP_Payment_Network_Config__c.getall().values()){
                    paymentNetworkMap.put(tpnc.Payment_Network__c,tpnc.Maximum_Length__c);
                }
                return paymentNetworkMap;
            }
            set;}
    private list<TIP_BIN_Range__c> deletedBinRangeList{
        get{
            if(deletedBinRangeList==null) deletedBinRangeList= new list<TIP_BIN_Range__c>();
            return deletedBinRangeList;
        } 
        set;}
    public BinRangeRec selectedBinRange{get;set;}


    
    public List<selectOption> paymentGuaranteeOptList{
        get{        
            List<SelectOption> paymentGuaranteeOptList = new List<SelectOption>();      
            for( Schema.PicklistEntry f : Partner_products__c.PP_Payment_guarantee__c.getDescribe().getPicklistValues()) paymentGuaranteeOptList.add(new SelectOption(f.getValue(), f.getLabel()));
            return paymentGuaranteeOptList;
        }
        set;}

    public List<selectOption> acceptedTransactionsOptList{
        get{        
            List<SelectOption> acceptedTransactionsOptList = new List<SelectOption>();      
            for( Schema.PicklistEntry f : Partner_products__c.PP_Accepted_transactions__c.getDescribe().getPicklistValues()) acceptedTransactionsOptList.add(new SelectOption(f.getLabel(), f.getValue()));
            return acceptedTransactionsOptList;
        }
        set;}

    //##======================Constructors=================================##

    public ISSP_TIP_Home_Controller(){
        popContact();
        fillProducts();
    }

    //##======================Methods================================##  

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

    	List<Case> caseList = [SELECT id, status, CaseNumber, subject, createddate, CaseArea__c, Reason1__c, IsClosed  FROM Case 
        WHERE AccountId = :con.AccountId 
        and recordtypeid = :PROCESS_CASE_RECORD_TYPE_ID 
        and CaseArea__c like '%Transparency in Payments%'
        AND (Status = 'Draft' OR Status Not In :closedStatusesList)];

        for (Case c: caseList) {
            if (!c.IsClosed && c.Status != 'Draft' && c.Reason1__c == TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT) {
                btnEnabled = false;
                break;
            }
        }

        return caseList;
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
            AND recordtypeid = :TIP_PRODUCT_RECORD_TYPE_ID
            ORDER BY PP_status__c DESC]){
            
            products.add(new productWrapper(p.id,p.name, p.PP_Payment_network__c,p.PP_Effective_to_Date__c,p.PP_Effective_from_Date__c, p.PP_status__c));
        }


    }

    //##======================Sidekick classes=================================##

    //product enrollment Page
    public class BinRangeRec{ 
        public TIP_BIN_Range__c binRange{get;set;}
        public integer pos{get;set;}
        public string action{get;set;}//N- new M-modified D-deleted
        public BinRangeRec(TIP_BIN_Range__c tbr,integer p,string a){
            pos=p;
            binRange=tbr;
            action=a;
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

    //======================Product Enrollment Page Methods =====================================
    public Pagereference NewEditProduct(){
        isNew=true;
        editMode=true;
        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage(); 

        newpp= new Partner_products__c(PP_Payment_Product_Network_type__c='Open Loop');
        binRangeList= new list<BinRangeRec>();
        deletedBinRangeList= new list<TIP_BIN_Range__c>();
        String selectedProdId=System.currentPageReference().getParameters().get('prodId');
        if(!String.isBlank(selectedProdId)){
            list<Partner_products__c> prodlist=[Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_network__c,PP_GDS_Integration__c,PP_VAN_type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_status__c,PP_Payment_Product_Network_type__c,  
                                                    (select id,TIP_Range_Start__c,TIP_Range_End__c,TIP_Status__c from BIN_Ranges__r) 
                                                from Partner_products__c where id=:selectedProdId];
            if(prodList.size()>0){
                isNew=false;
                newpp= prodlist.get(0);
                editMode=newpp.PP_status__c==TIP_Utils.PARTNER_PRODUCT_STATUS_DRAFT;
                integer pos=0;
                if(!editMode) binRangeChangeRequestText = Label.ISSP_TIP_Submit_case_to_IATA_to_update_bin_range;
                acceptedTransactionVal=String.isBlank(newpp.PP_Accepted_transactions__c)?null:newpp.PP_Accepted_transactions__c.split(';');
                paymentGuaranteeVal=String.isBlank(newpp.PP_Payment_guarantee__c)?null:newpp.PP_Payment_guarantee__c.split(';');
                
                binRangeLen= String.isBlank(newpp.PP_Payment_network__c)?0:paymentNetworkMap.get(newpp.PP_Payment_network__c);
                for(TIP_BIN_Range__c tbr:newpp.BIN_Ranges__R){
                    binRangeList.add(new BinRangeRec(tbr,pos++,''));
                }

                changePaymentNetwork();//refresh payment network len
            }
        }
        PageReference pr= Page.ISSP_TIP_Product_Enrollment;
        pr.setRedirect(false);
        return pr;

    }

    public Pagereference cancelNewEditProd(){
        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(false);
        return pr;
    }

    public void newEditBinRange(){
        String binRangeRecPos=System.currentPageReference().getParameters().get('binRangeRecPos');
        selectedBinRange= new BinRangeRec( 
                new TIP_BIN_Range__c(
                    recordTypeId=TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID
                    ),0,'N');
        if(!String.isBlank(binRangeRecPos)){
            selectedBinRange= binRangeList.get(Integer.ValueOf(binRangeRecPos));
            selectedBinRange.action='M';            
        }      
    }

    public void addUpdateBinRange(){
        if(selectedBinRange.action=='N'){   
            selectedBinRange.pos=binRangeList.size();
            selectedBinRange.binRange.TIP_Status__c='Draft';
            if(!String.isBlank(selectedBinRange.binRange.TIP_Range_Start__c) || !String.isBlank(selectedBinRange.binRange.TIP_Range_End__c)){
                if(!binRangeList.isEmpty()) binRangeList.add(0,selectedBinRange);
                else binRangeList.add(selectedBinRange);
            }
            integer c=0;
            for(binRangerec brr:binRangeList)brr.pos=c++;
        }
    }
    public void deleteBinRange(){
        String binRangeRecPos=System.currentPageReference().getParameters().get('binRangeRecPos');
        if(!String.isBlank(binRangeRecPos)){
            selectedBinRange= binRangeList.get(Integer.ValueOf(binRangeRecPos));
            if(!String.isBlank(selectedBinRange.binRange.id))deletedBinRangeList.add(selectedBinRange.binRange);
            binRangeList.remove(Integer.valueOf(binRangeRecPos));
            
            // refreshing records index
            integer c=0;
            for(binRangerec brr:binRangeList)brr.pos=c++;
        }
    }
    public void changePaymentNetwork(){
        binRangeLen= String.isBlank(newpp.PP_Payment_network__c)?0:paymentNetworkMap.get(newpp.PP_Payment_network__c);
        system.debug('PF binRangeLen'+binRangeLen);
        system.debug('PF newpp.PP_Payment_network__c'+newpp.PP_Payment_network__c);
        for(binRangeRec brr:binRangeList){
            if(brr.binRange.TIP_Status__c=='Draft'){               
                brr.binRange.TIP_Range_Start__c=brr.binRange.TIP_Range_Start__c.rightPad(Integer.ValueOf(binRangeLen),'0');
                brr.binRange.TIP_Range_End__c=brr.binRange.TIP_Range_End__c.rightPad(Integer.ValueOf(binRangeLen),'9');
            }
        }
        selectedBinRange=null;
        system.debug('PF binRangeList'+binRangeList);
    }

    public Pagereference saveDraft(){
        try{
            if(isNew){
                user usr=[select id,Contact.accountId,Contact.account.name,Contact.account.IATA_ISO_Country__r.region__c,Contact.account.IATA_ISO_Country__r.Name from user where id =:UserInfo.getUserId()];

                newpp.Provider__c=usr.Contact.accountID;
                //newpp.PP_Accepted_transactions__c=String.isBlank(newpp.PP_Accepted_transactions__c)?'':newpp.PP_Accepted_transactions__c.substring(1,newpp.PP_Accepted_transactions__c.length() -1).replace(',',';');
                //newpp.PP_Payment_guarantee__c=String.isBlank(newpp.PP_Payment_guarantee__c)?'':newpp.PP_Payment_guarantee__c.substring(1,newpp.PP_Payment_guarantee__c.length() -1).replace(',',';');
                newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');
                newpp.PP_status__c='Draft';
                
                insert newpp;
                
                //create Case
                newCase = new Case();
                newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
                newcase.AccountId = usr.contact.accountId; 
                newcase.Visible_on_ISS_Portal__c = true;
                newcase.Reason = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT ;
                newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS; 
                newcase.Status = 'Draft';
                newcase.Subject = TIP_Utils.CASE_SUBJECT_NEW_PRODUCT_ENROLMENT+' - '+ newpp.name;
                newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
                newcase.Region__c = usr.Contact.account.IATA_ISO_Country__r.region__c;
                newcase.Origin = 'Portal';
                newcase.BSPCountry__c = usr.Contact.account.IATA_ISO_Country__r.Name;
                newcase.Country_concerned_by_the_query__c = usr.Contact.account.IATA_ISO_Country__r.Name;

                insert newCase;
               
            } else {            

                if(editMode){
                    newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                    newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');

                    update newpp;
                }

                //Update Bin ranges
                list<TIP_BIN_Range__c> upsertBinRangeList= new list<TIP_BIN_Range__c>();
                for(BinRangeRec tbr: binRangeList){
                    if(tbr.action !=''){
                        tbr.binRange.TIP_Payment_Provider_Product__c =newpp.id;
                        upsertBinRangeList.add(tbr.binRange);   
                    }
                }
                if(!upsertBinRangeList.isEmpty())upsert upsertBinRangeList;
                if(!deletedBinRangeList.isEmpty())delete deletedBinRangeList;
            }
            fillProducts();
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            return null;
        }

        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(false);
        return pr;

    }

}
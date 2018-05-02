public without sharing class ISSP_TIP_Home_Controller {

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

    public Account account {get; set;}
    public Partner_products__c newpp {get; set;}
    private Id accountID {get; set;}
    private Case newCase {get; set;}
    public boolean isNew {get; set;}
    public list<BinRangeRec> binRangeList{get; set;}
    public BinRangeRec selectedBinRange{get;set;}

    public String[] paymentGuaranteeVal{get;set;}
    public String[] acceptedTransactionVal{get;set;}
    public Decimal binRangeLen{get;set;}




    //produc country config vars
    public list<ProvProdConfigRec> provProdConfList{get; set;}
    public ProvProdConfigRec selectedProvProdConf{get; set;}
    public boolean renderCountryCondifPopup{get;set;}

    public list<string> selectProvConfigCountriesList{get;set;}
    public set<string> filterCountryList{get;set;}// list of countries that will be removed from the multiSelect for adding new product country config  


    
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

    private list<TIP_Pay_Prov_Prod_Country_Config__c> deletedCountryConfigList{
        get{
            if(deletedCountryConfigList==null) deletedCountryConfigList= new list<TIP_Pay_Prov_Prod_Country_Config__c>();
            return deletedCountryConfigList;
        } 
        set;}

    
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
            for( Schema.PicklistEntry f : Partner_products__c.PP_Accepted_transactions__c.getDescribe().getPicklistValues()) acceptedTransactionsOptList.add(new SelectOption(f.getValue(), f.getLabel()));
            return acceptedTransactionsOptList;
        }
        set;}


    private map<string,IATA_ISO_Country__C> isoCodeCountryMap{
        get{
            if(isoCodeCountryMap==null){
                isoCodeCountryMap= new map<string,IATA_ISO_Country__C>();
                for(IATA_ISO_Country__C  isoc:[select id,ISO_Code__c,name from IATA_ISO_Country__C order by name asc]){
                    isoCodeCountryMap.put(isoc.ISO_Code__c,isoc);    
                }
            }
            return isoCodeCountryMap;
        }
        set;
    }
    

    public List<selectOption> bspCountrList{
        get{
            if(bspCountrList==null){
                bspCountrList= refreshBspList();
            }
            return bspCountrList;

        }
        set;
    }
   

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

        btnEnabled = (acc.recordtypeid == TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID && acc.category__c==TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER);
        isPaymentProvider = (acc.recordtypeid == TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID);

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
        for(Partner_products__c p :[SELECT id, name, PP_Payment_Network__c, PP_Effective_to_Date__c, PP_Effective_from_Date__c, toLabel(PP_status__c)
          FROM Partner_products__c 
          WHERE Provider__c  = :con.AccountId
            AND recordtypeid = :TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID
            ORDER BY PP_status__c DESC]){
            
            products.add(new productWrapper(p.id,p.name, p.PP_Payment_Network__c,p.PP_Effective_to_Date__c,p.PP_Effective_from_Date__c, p.PP_status__c));
        }
    }

    //##======================Sidekick classes=================================##

    //product enrollment Page
    public class BinRangeRec{ 
        public TIP_BIN_Range__c binRange{get;set;}
        public integer pos{get;set;}
        public string action{get;set;}//N- new M-modified D-deleted
        public boolean renderBtn{get;set;}
        public string error{get;set;}
        public BinRangeRec(TIP_BIN_Range__c tbr,integer p,string a,boolean rb){
            pos=p;
            binRange=tbr;
            action=a;
            renderBtn=rb;
            error=null;
        }

    }
    public class ProvProdConfigRec{ 
        public TIP_Pay_Prov_Prod_Country_Config__c prodConfig{get;set;}
        public integer pos{get; public set;}
        public string action{get;set;}//N- new M-modified D-deleted
        public string countryName{get;set;}
        public boolean renderBtn{get;set;}
        public ProvProdConfigRec(TIP_Pay_Prov_Prod_Country_Config__c tpc,integer p,string a,string cn,boolean rb){
            pos=p;
            prodConfig=tpc;
            action=a;
            countryName=cn;
            renderBtn=rb;
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

    private map<id,String> bspIdIsoCodeMap{
        get{
            if(bspIdIsoCodeMap==null){
                bspIdIsoCodeMap= new map<id,String>();
            }
            return bspIdIsoCodeMap;
        }
        set;
    }

    private List<selectOption> refreshBspList(){
        List<selectOption> bspCountrList= new List<selectOption>();
        set<string> tempBspCountrySet = new set<string>();
        bspIdIsoCodeMap=null;
        system.debug('PF refreshBspList filterCountryList'+filterCountryList);
        for(AMS_Settlement_System__c iss:[select id,BSP_Billing__c from AMS_Settlement_System__c where BSP_Billing__c not in:filterCountryList order by BSP_Billing__c asc]){
            tempBspCountrySet.add(iss.BSP_Billing__c);  
        }

        for(string isoCode :isoCodeCountryMap.keySet()){
            if(tempBspCountrySet.contains(isoCode)){

                bspCountrList.add(new SelectOption(isoCodeCountryMap.get(isoCode).id,isoCodeCountryMap.get(isoCode).name));
            }
            bspIdIsoCodeMap.put(isoCodeCountryMap.get(isoCode).id,isoCode);
        }
        system.debug('PF bspCountrList'+bspCountrList);
        return bspCountrList;

    }
    //======================Product Enrollment Page Methods =====================================
    public Pagereference NewEditProduct(){
        isNew=true;
        editMode=true;
        renderCountryCondifPopup=false;
        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage(); 

        newpp= new Partner_products__c(PP_Payment_Product_Network_type__c=TIP_Utils.PARTNER_PRODUCT_NETWORK_TYPE_OPEN_LOOP);
        binRangeList= new list<BinRangeRec>();
        deletedBinRangeList= new list<TIP_BIN_Range__c>();

        filterCountryList= new set<string>();

        provProdConfList= new list<ProvProdConfigRec>();
        deletedCountryConfigList= new list<TIP_Pay_Prov_Prod_Country_Config__c>();
        String selectedProdId=System.currentPageReference().getParameters().get('prodId');

        if(!String.isBlank(selectedProdId)){
            list<Partner_products__c> prodlist=[Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_Network__c,PP_GDS_Integration__c,PP_VAN_Type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_status__c,PP_Payment_Product_Network_type__c,  
                                                    (select id,TIP_Range_Start__c,TIP_Range_End__c,ToLabel(TIP_Status__c) from BIN_Ranges__r),
                                                    (select id  from cases__r where RecordTypeId =: TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID AND
                                                        Reason1__c = :TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT AND
                                                        CaseArea__c =: TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS),
                                                    (select id,TIP_BSP_Country__c,TIP_BSP_Country__r.name,TIP_BSP_Country__r.ISO_Code__c,TIP_Interchange_Fee__c,Network_Fee__c,ToLabel(TIP_Status__c),TIP_Effective_To_Date__c,TIP_Effective_From_Date__c from Payment_Product_Country_Configs__r order by TIP_Status__c desc, name asc)
                                                from Partner_products__c where id=:selectedProdId];
            if(prodList.size()>0){
                isNew=false;
                newpp= prodlist.get(0);
                editMode=newpp.PP_status__c==TIP_Utils.PARTNER_PRODUCT_STATUS_DRAFT;
                integer pos=0;
                if(!editMode) binRangeChangeRequestText = Label.ISSP_TIP_Submit_case_to_IATA_to_update_bin_range;
                acceptedTransactionVal=String.isBlank(newpp.PP_Accepted_transactions__c)?null:newpp.PP_Accepted_transactions__c.split(';');
                paymentGuaranteeVal=String.isBlank(newpp.PP_Payment_guarantee__c)?null:newpp.PP_Payment_guarantee__c.split(';');
                
                binRangeLen= String.isBlank(newpp.PP_Payment_Network__c)?0:paymentNetworkMap.get(newpp.PP_Payment_Network__c);
                for(TIP_BIN_Range__c tbr:newpp.BIN_Ranges__R){
                    binRangeList.add(new BinRangeRec(tbr,pos++,'',tbr.TIP_Status__c =='Draft'));
                }

                changePaymentNetwork();//refresh payment network len
                pos=0;
                selectProvConfigCountriesList=new list<string>();
                for(TIP_Pay_Prov_Prod_Country_Config__c pcr:newpp.Payment_Product_Country_Configs__r){
                    provProdConfList.add(new ProvProdConfigRec(pcr,pos++,'',pcr.TIP_BSP_Country__r.name,pcr.TIP_Status__c =='Draft'));
                    filterCountryList.add(pcr.TIP_BSP_Country__r.ISO_Code__c);
                }
            }
        }

        PageReference pr= Page.ISSP_TIP_Product_Enrollment;
        pr.setRedirect(false);
        return pr;

    }

    public Pagereference cancelNewEditProd(){
        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(true);
        return pr;
    }

    // ============================== BIN RANGE ======================================
    public void newEditBinRange(){
        String binRangeRecPos=System.currentPageReference().getParameters().get('binRangeRecPos');
        selectedBinRange= new BinRangeRec( 
                new TIP_BIN_Range__c(
                    recordTypeId=TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID
                    ),0,'N',true);
        if(!String.isBlank(binRangeRecPos)){
            selectedBinRange= binRangeList.get(Integer.ValueOf(binRangeRecPos));
            selectedBinRange.action='M';            
        }
        renderCountryCondifPopup=false;      
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
        binRangeLen= String.isBlank(newpp.PP_Payment_Network__c)?0:paymentNetworkMap.get(newpp.PP_Payment_Network__c);
       
        for(binRangeRec brr:binRangeList){
            if(brr.binRange.TIP_Status__c=='Draft'){               
                brr.binRange.TIP_Range_Start__c=brr.binRange.TIP_Range_Start__c.rightPad(Integer.ValueOf(binRangeLen),'0');
                brr.binRange.TIP_Range_End__c=brr.binRange.TIP_Range_End__c.rightPad(Integer.ValueOf(binRangeLen),'9');
            }
        }
        selectedBinRange=null;
        system.debug('PF binRangeList'+binRangeList);
    }



    // ============================== PRODUCT COUNTRY CONFIGURATION ======================================

    public void newEditCountryConfig(){
        String countryConfigPos=System.currentPageReference().getParameters().get('countryConfigPos');
        selectedProvProdConf= new ProvProdConfigRec( 
                new TIP_Pay_Prov_Prod_Country_Config__c(
                    ),0,'N','',true);
        selectProvConfigCountriesList= new list<string>();
        if(!String.isBlank(countryConfigPos)){
            selectedProvProdConf= provProdConfList.get(Integer.ValueOf(countryConfigPos));
            selectedProvProdConf.action='M';       
        }
        bspCountrList= refreshBspList();
        renderCountryCondifPopup=true;  
    }

    public void addUpdateCountryConfig(){
        if(selectedProvProdConf.action=='N'){
            for(string c :selectProvConfigCountriesList){
                TIP_Pay_Prov_Prod_Country_Config__c npcc=new TIP_Pay_Prov_Prod_Country_Config__c(
                    TIP_Status__c='Draft',
                    TIP_BSP_Country__c=c,
                    TIP_Interchange_Fee__c=selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c,
                    Network_Fee__c=selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c
                    );
                filterCountryList.add(bspIdIsoCodeMap.get(c));
                if(!provProdConfList.isEmpty()) provProdConfList.add(0,new ProvProdConfigRec(npcc,provProdConfList.size(),'N',isoCodeCountryMap.get(bspIdIsoCodeMap.get(c)).name,true));
                else provProdConfList.add(new ProvProdConfigRec(npcc,0,'N',isoCodeCountryMap.get(bspIdIsoCodeMap.get(c)).name,true));
            }
            integer c=0;
            for(ProvProdConfigRec pcr:provProdConfList)pcr.pos=c++;
        }
    }

    public void deleteCountryConfig(){
        String countryConfigPos=System.currentPageReference().getParameters().get('countryConfigPos');
        if(!String.isBlank(countryConfigPos)){
            selectedProvProdConf= provProdConfList.get(Integer.ValueOf(countryConfigPos));
            filterCountryList.remove(bspIdIsoCodeMap.get(selectedProvProdConf.prodConfig.TIP_BSP_Country__c));
            
            if(!String.isBlank(selectedProvProdConf.prodConfig.id)) deletedCountryConfigList.add(selectedProvProdConf.prodConfig);
            provProdConfList.remove(Integer.valueOf(countryConfigPos));
            
            // refreshing records index
            integer c=0;
            for(ProvProdConfigRec pcr:provProdConfList)pcr.pos=c++;
        }
    }




    // =============================== SAVE AND SUBMIT ===================================================

    public Pagereference saveDraft(){
       return doDMLRecords(TIP_Utils.PARTNER_PRODUCT_STATUS_DRAFT);
    }
 
    

    public Pagereference submitProduct(){
        try{
           set<string> mandatoryFieldsToSubmitSet= new set<string>{'PP_Settlement_terms__c','is_PCI_DSS_required__c','PP_Chargeback_airlines__c','PP_Pay_in_model__c','PP_Chargeback_airlines_duration__c','PP_Category__c','PP_VAN_Type__c'}; 
           boolean missingValues=false;
           for(string field:mandatoryFieldsToSubmitSet){
                if(String.isBlank(String.valueOf(newpp.get(field)))){
                    missingValues=true;
                }
           }

           if(missingValues){

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_TIP_MISSING_FIELDS));
                return null;
            
            } 

            if(binRangeList.isEmpty()){

                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_TIP_INSERT_BIN_RANGE));
                 return null;
             
             } 


            // Check Bin Range Sizes
            boolean incorrectBinRangeSize=false;
            for(BinRangeRec tbr: binRangeList){
                if(tbr.binRange.TIP_Status__c =='Draft'){
                    if(tbr.binRange.TIP_Range_Start__c.length()!= Integer.valueOf(binRangeLen)){
                        incorrectBinRangeSize=true;
                        tbr.binRange.TIP_Range_Start__c+='*';
                    }
                    if(tbr.binRange.TIP_Range_End__c.length()!= Integer.valueOf(binRangeLen)){
                        incorrectBinRangeSize=true;
                        tbr.binRange.TIP_Range_End__c+='*';
                    }
                }
            }
            if(incorrectBinRangeSize){
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_TIP_CHECK_BIN_RANGE_LENGHT));
                 return null;
            } 


            if(provProdConfList.isEmpty()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_TIP_INSERT_ONE_COUNTRY_CONFIG));
                return null; 
            } 

           

        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }

        PageReference pr=  doDMLRecords(TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS);
        pr.setRedirect(true);
        return pr;

    }

    public Pagereference doDMLRecords(String status){
        try{
            if(isNew){
                user usr=[select id,Contact.accountId,Contact.account.name,Contact.account.IATA_ISO_Country__r.region__c,Contact.account.IATA_ISO_Country__r.Name from user where id =:UserInfo.getUserId()];

                newpp.Provider__c=usr.Contact.accountID;
                newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');
                newpp.PP_status__c=status;
                
                insert newpp;
                
                //create Case
                newCase = new Case();
                newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
                newcase.AccountId = usr.contact.accountId; 
                newcase.Visible_on_ISS_Portal__c = true;
                newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT ;
                newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS; 
                newcase.Status = status;
                newcase.Subject = TIP_Utils.CASE_SUBJECT_NEW_PRODUCT_ENROLMENT+' - '+ newpp.name;
                newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
                newcase.Region__c = usr.Contact.account.IATA_ISO_Country__r.region__c;
                newcase.Origin = 'Portal';
                newcase.BSPCountry__c = usr.Contact.account.IATA_ISO_Country__r.Name;
                newcase.TIP_Partner_Product__C=newpp.id;
                newcase.Country_concerned_by_the_query__c = usr.Contact.account.IATA_ISO_Country__r.Name;

                newpp.cases__R.add(newCase);
               
            } else {
                newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');
                newpp.PP_status__c=status;

                update newpp;
            }

            if(!newpp.cases__R.isEmpty()){
                newpp.cases__R.get(0).Status = status;

                if(status==TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS){
                    newpp.cases__R.get(0).Status = AMS_Utils.OPEN;

                    List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'Cases_Transparency_in_Payment_Service' LIMIT 1];
                    
                    if(groups == null || groups.isEmpty()) System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
                    else{
                        newpp.cases__R.get(0).OwnerId = groups[0].id;
                    }
                }

                upsert newpp.cases__R;
            }

            //Update Bin ranges
            list<TIP_BIN_Range__c> upsertBinRangeList= new list<TIP_BIN_Range__c>();
            for(BinRangeRec tbr: binRangeList){
                if(!String.isBlank(tbr.action)|| tbr.binRange.TIP_Status__c==TIP_Utils.BIN_RANGE_STATUS_DRAFT){
                    if(String.isBlank(tbr.binRange.id))tbr.binRange.TIP_Payment_Provider_Product__c =newpp.id;
                    tbr.binRange.TIP_Status__c =status;
                    upsertBinRangeList.add(tbr.binRange);   
                }
            }
            if(!upsertBinRangeList.isEmpty()) upsert upsertBinRangeList;
            if(!deletedBinRangeList.isEmpty()) delete deletedBinRangeList;

            //Update Ayment country Configs
            list<TIP_Pay_Prov_Prod_Country_Config__c> upsertProdConfigList= new list<TIP_Pay_Prov_Prod_Country_Config__c>();
            for(ProvProdConfigRec ppcr: provProdConfList){
                if(!String.isBlank(ppcr.action)|| ppcr.prodConfig.TIP_Status__c==TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_DRAFT){
                    if(String.isBlank(ppcr.prodConfig.id))ppcr.prodConfig.TIP_Product__c =newpp.id;
                    ppcr.prodConfig.TIP_Status__c=status;
                    upsertProdConfigList.add(ppcr.prodConfig);   
                }
            }
            if(!upsertProdConfigList.isEmpty())upsert upsertProdConfigList;
            if(!deletedCountryConfigList.isEmpty())delete deletedCountryConfigList;

            fillProducts();
        }catch(exception e){

            if(status==TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS)  doDMLRecords(TIP_Utils.PARTNER_PRODUCT_STATUS_DRAFT);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            return null;
        }

        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(true);
        return pr;

    }

}
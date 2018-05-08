public without sharing class ISSP_TIP_Home_Controller {

    //##======================VARIABLES=================================##

    public String applyLanguage {get; set;}
    public String displayLanguage {get; set;}   
    
    //home Page
    public string currNavState {get;set;}    
    public Contact con {get; set;}
    public boolean isPaymentProvider {get;set;} 
    public boolean btnEnabled {get;set;}
    public boolean isAdmin {get; set;}     //identify if a user is an administrator or not
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public List<productWrapper> products {get ;set;}
    public boolean editMode{get;set;}
    public String binRangeChangeRequestText{get;Set;}

    //enrolment page
    public String conID {get; set;}
    public Contact newContact {get;set;} 
    public List <Contact> contactList {get; set;}
    public Boolean isEmailDuplicated {get; set;}

    public User user {get; set;}
    public Account account {get; set;}
    public Partner_products__c newpp {get; set;}
    private Case newCase {get; set;}
    public boolean isNew {get; set;}
    public list<BinRangeRec> binRangeList{get; set;}
    public String[] paymentGuaranteeVal{get;set;}
    public String[] acceptedTransactionVal{get;set;}
    public Decimal binRangeLen{get;set;}
    public BinRangeRec selectedBinRange{get;set;}
    
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

    //##======================Constructors=================================##

    public ISSP_TIP_Home_Controller(){
        popContact();
        fillProducts();

         pageReference currentPage = new PageReference(ApexPages.currentPage().getURL());
        Map<String, String> params  =  currentPage.getParameters(); 
        params.remove('prodId');
        params.remove('caseId');
        currentPage.getParameters().putAll(params);

        //pre-load pages
        if (currentPage.getURL() == Page.ISSP_TIP_Enrolment.getURL() && !String.isBlank(Apexpages.currentPage().getParameters().get('caseId')))  startEnrolmentAccount();
        else if (currentPage.getURL() == Page.ISSP_TIP_Product_Enrollment.getURL() && !String.isBlank(Apexpages.currentPage().getParameters().get('prodId')))  NewEditProduct();
        
    }

    //##======================Methods================================##  

    public Pagereference checkForCase(){
        if (!String.isBlank(Apexpages.currentPage().getParameters().get('caseId'))) return startEnrolmentAccount();
        else if (!String.isBlank(Apexpages.currentPage().getParameters().get('prodId'))) return NewEditProduct();
    
        return null;
    }

    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);
        isAdmin = (con.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM);
        
        fetchHQAccountDetails();

        btnEnabled = (account.recordtypeid == TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID && account.category__c=='Payment Provider');
        isPaymentProvider = (account.recordtypeid == TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID);

    }

    public List<Case> getCases(){
        Set<string> closedStatusesList = createListOfClosedStatuses();

    	List<Case> caseList = [SELECT id, status, CaseNumber, subject, createddate, CaseArea__c, Reason1__c, IsClosed  FROM Case 
        WHERE AccountId = :con.AccountId 
        and recordtypeid = :TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID 
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

    //======================Enrollment Page Methods =====================================
    
        public PageReference startEnrolmentAccount() {

        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage();

        user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
        fetchHQAccountDetails();
        getISOCountry();
        List <Case> accountCases;
        String caseId = Apexpages.currentPage().getParameters().get('caseId');
        if (!String.isBlank(caseId)){
            accountCases = [SELECT ID,Reason1__c,RecordTypeid,RecordType.Name,CaseArea__c,Status,Visible_on_ISS_Portal__c,Subject,Region__c,
                            Origin,BSPCountry__c,Country_concerned_by_the_query__c,Description
                            FROM Case 
                                WHERE ID = :caseId]; 
        }
        else{
            accountCases = [SELECT ID,Reason1__c,RecordTypeid,RecordType.Name,CaseArea__c,Status,Visible_on_ISS_Portal__c,Subject,Region__c,
                            Origin,BSPCountry__c,Country_concerned_by_the_query__c,Description
                            FROM Case 
                                WHERE RecordTypeid = :TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID 
                                AND Accountid = :con.AccountId 
                                AND Visible_on_ISS_Portal__c = true
                                AND Reason1__c = :TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT
                                AND CaseArea__c = :TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS 
                                AND Status = 'Draft'
                            LIMIT 1]; 
        }
        if(accountCases != null && !accountCases.isEmpty()){ newCase = accountCases[0]; }
        fillContactList();
        newContact = new Contact();
        PageReference pr= Page.ISSP_TIP_Enrolment;
        pr.setRedirect(false);
        return pr; 
    }

    public Pagereference submitAccountEnrolmentToIATA() {

        //confirm that required fields are fill

        if(String.isEmpty(account.Name)){
            account.Name.addError('Please fill the Legal name');
            return null;
        }

        if(String.isEmpty(account.PhoneNational__c)){
            account.PhoneNational__c.addError('Please fill the Office Phone');
            return null;
        }

        if(String.isEmpty(account.Email__c)){
            account.Email__c.addError('Please fill the Office Email');
            return null;
        }

        if(String.isEmpty(account.BillingStreet)){
            account.BillingStreet.addError('Please fill the Billing Street');
            return null;
        }

        if(String.isEmpty(account.BillingCity)){
            account.BillingCity.addError('Please fill the Billing City');
            return null;
        }
        
        if(String.isEmpty(account.TIP_HQ_Location__c)){
            account.TIP_HQ_Location__c.addError('Please Choose the Location of Headquarter');
            return null;
        }

        //confirm that primary contact is choosen
        Boolean hasPrimaryContact = false;
        for(Contact c : contactList){
            if (c.Primary_Contact__c) hasPrimaryContact = true;
        }

        if(!hasPrimaryContact){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select a primary contact'));
            return null;
        }

        //Update or create case with status Open
        updateCase();
        newcase.Status = 'Open';
        
        //force case auto-response rules to fire
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerAutoResponseEmail= true;
        newCase.setOptions(dmo);

        update account;
        upsert newCase;

        //assign to TIP HO queue
        List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'Cases_Transparency_in_Payment_Service' LIMIT 1];
        
        if(groups == null || groups.isEmpty()) System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
        else{
            newCase.OwnerId = groups[0].id;
            upsert newcase;
        }

        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(false);
        return pr; 
    }

    public Pagereference saveAccountEnrolmentAsDraft() {

        updateCase();
        update account;
        upsert newCase;
        try{
            upsert contactList;
        }catch(Exception e){}
        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(false);
        return pr; 
    }

    public void fetchHQAccountDetails () {
        account = [
                        SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,TIP_Documents__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordTypeid, RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c,
                        IATA_ISO_Country__r.Name, IATA_ISO_Country__r.region__c, TIP_HQ_Location__c,Country_ISO_Code__c
                        FROM Account
                        WHERE Id = :con.AccountId
                                   LIMIT 1
                    ];
    }

    private void updateCase(){

        if (newCase == null) newCase = new Case();
        newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
        newcase.Accountid = account.id; 
        newcase.Visible_on_ISS_Portal__c = true;
        newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT;
        newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS; 
        newcase.Status = 'Draft';
        newcase.Subject = 'Request for Enlistment as Payment provider - ' + account.name;
        newCase.Description = 'Request for Enlistment as Payment provider';
        newcase.Region__c = account.IATA_ISO_Country__r.region__c;
        newcase.Origin = 'Portal';
        newcase.BSPCountry__c = account.IATA_ISO_Country__r.Name;
        newcase.Country_concerned_by_the_query__c = account.IATA_ISO_Country__r.Name;
    }

    public List<SelectOption> getISOCountry() {
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('',Label.ISSP_SELECT_COUNTRY));
        for(IATA_ISO_Country__c iso:[select Id,Name,ISO_Code__c, IEC_Zip_Postal_Code_required__c from IATA_ISO_Country__c
                                    where Name != 'All Countries' and Name != 'NO COUNTRY' order by Name]){
            options.add(new SelectOption(iso.Id,iso.Name));
        }
        return options;
    }

    private void fillContactList() {
        contactList = [SELECT id,Name, Email,Salutation, FirstName, LastName, Phone, Primary_Contact__c,MobileNational__c,Membership_Function__c,Title,MobilePhone

                FROM Contact
                WHERE Status__c = 'Active' and Accountid = :con.AccountId];
    }

    public void updateRadioButtonStatus() {
        ID contactID = Apexpages.currentPage().getParameters().get('contactIDtoPrimary');
        for (Contact c: contactList) {
            c.Primary_Contact__c = false;
            if(c.id == contactID) c.Primary_Contact__c = true;
        }
    }

    public void createContact(){

        newContact.AccountId = con.AccountId;

        try{
            upsert newContact;
            isEmailDuplicated = false;
            system.debug('##done inserting: ' +isEmailDuplicated);
        }catch(Exception e){
            system.debug('##Error inserting: ' +isEmailDuplicated);
            isEmailDuplicated = true;
            return;
        }
        fillContactList();
        newContact = new Contact();
    }

    public Pagereference setContactToEdit(){
        
        String contactID = Apexpages.currentPage().getParameters().get('contactIDToEdit');
        if (String.isBlank(contactID)) newContact = new Contact();
        else{
            for (Contact c: contactList) {
                if(c.id == contactID) newContact = c;
            }
        }
        return null;

    }

    public PageReference securityCheckForEnrolmentPage(){
        if(account.recordtypeid != TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID 
            || con.User_Portal_Status__c != ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM // return new PageReference('/ISSP_TIP_Home');// {pr = Page.ISSP_TIP_Home;pr.setRedirect(false);}
            ||(newCase != null && newCase.status != 'Draft') )
                return new PageReference('/ISSP_Case?caseId='+newCase.id);
        return null;
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
            list<Partner_products__c> prodlist=[Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_Network__c,PP_GDS_Integration__c,PP_VAN_Type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_status__c,PP_Payment_Product_Network_type__c,  
                                                    (select id,TIP_Range_Start__c,TIP_Range_End__c,ToLabel(TIP_Status__c) from BIN_Ranges__r) 
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
        pr.setRedirect(true);
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
        binRangeLen= String.isBlank(newpp.PP_Payment_Network__c)?0:paymentNetworkMap.get(newpp.PP_Payment_Network__c);
        system.debug('PF binRangeLen'+binRangeLen);
        system.debug('PF newpp.PP_Payment_Network__c'+newpp.PP_Payment_Network__c);
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
                newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');
                newpp.PP_status__c='Draft';
                
                insert newpp;
                
                //create Case
                newCase = new Case();
                newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
                newcase.AccountId = usr.contact.accountId; 
                newcase.Visible_on_ISS_Portal__c = true;
                newcase.Reason = TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT ;
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
                        if(String.isBlank(tbr.binRange.id))tbr.binRange.TIP_Payment_Provider_Product__c =newpp.id;
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
        pr.setRedirect(true);
        return pr;

    }

}
public without sharing class ISSP_TIP_Home_Controller {

    //##======================VARIABLES=================================##

    public String applyLanguage {get; set;}
    public String displayLanguage {get; set;}   
    
    //home Page
    public string currNavState {get;set;}    
    public Contact con {get; set;}
    public boolean isPaymentProvider {get;set;} 
    public boolean btnEnabled {get;set;}
    public boolean btnVoluntReliqEnabled {get;set;} //ACAMBAS . TIP-241   
    public boolean isAdmin {get; set;}     //identify if a user is an administrator or not
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public List<productWrapper> products {get ;set;}
    public List<Account_Contact_Role__c> primaryContacts {get ;set;} //ACAMBAS - TIP-281
    public boolean editMode{get;set;}
    public boolean activeProduct{get;set;} //ACAMBAS - TIP-244
    public String binRangeChangeRequestText{get;Set;}

    //enrolment page
    public String conID {get; set;}
    public Contact newContact {get;set;} 
    public List <Contact> contactList {get; set;}
    public list<Account_Contact_Role__c> AccountContactRoleList	{get; set;}
    public Boolean isEmailDuplicated {get; set;}
    public Account_Role__c TheAccountRole	{get; set;}

    public User user {get; set;}

    public Account account {get; set;}
    public Partner_products__c newpp {get; set;}
    @TestVisible private Case newCase {get; set;}
    public boolean isNew {get; set;}
    public list<BinRangeRec> binRangeList{get; set;}
    public BinRangeRec selectedBinRange{get;set;}
    public String terminationReason {get; set;} //ACAMBAS - TIP-244
    public String terminationDate {get; set;} //ACAMBAS - TIP-244
    public Integer terminationMaxDays {get; set;} //ACAMBAS - TIP-244
    public String voluntaryReliqReason {get; set;} //ACAMBAS - TIP-241
    public String voluntaryReliqDate {get; set;} //ACAMBAS - TIP-241
    public Integer voluntaryReliqMinDays {
        get {
            if(voluntaryReliqMinDays == null) 
                voluntaryReliqMinDays = (Integer) TIP_Configuration__c.getOrgDefaults().Voluntary_Reliquishment_Min_Days__c; 
            return voluntaryReliqMinDays;  
        } 
        set;} //ACAMBAS - TIP-241

    public String[] paymentGuaranteeVal{get;set;}
    public String[] acceptedTransactionVal{get;set;}
    public Decimal binRangeLen{get;set;}

    public boolean acceptedTaC{get;set;}

    //produc country config vars
    public list<ProvProdConfigRec> provProdConfList{get; set;}
    public ProvProdConfigRec selectedProvProdConf{get; set;}
    public boolean renderCountryCondifPopup{get;set;}
    public boolean renderTerminateProdPopup{get;set;} //ACAMBAS - TIP-244
    public boolean renderReqVoluntRelinq{get;set;} //ACAMBAS - TIP-241
    
    public list<string> selectProvConfigCountriesList{get;set;}
    public set<string> filterCountryList{get;set;}// list of countries that will be removed from the multiSelect for adding new product country config  

    public List<selectOption> paymentNetworkOptList{
        get{        
            List<SelectOption> paymentNetworkOptList = new List<SelectOption>();      
            paymentNetworkOptList.add(new selectOption('', '- None -'));
            for( Schema.PicklistEntry f : Partner_products__c.PP_Payment_Network__c.getDescribe().getPicklistValues()){
                if(!f.getLabel().contains('Other'))
                paymentNetworkOptList.add(new SelectOption(f.getValue(), f.getLabel()));
            }
                
            return paymentNetworkOptList;
        }
        set;}

    
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
        fillPrimaryContacts(); //ACAMBAS - TIP-281

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

    public Pagereference initActions(){
    	system.debug('DTULLO START initActions');
	User user = DAL_ISSP.getUser(Userinfo.getUserId());
      
        try {
        	CreateAccountRole(user);
        	
            Portal_Application_Right__c appRight = [
                Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c,Right__c
                From Portal_Application_Right__c
                Where ContactId__c = :String.valueOf(user.ContactId).left(15)
                And Portal_Application__r.Name = :TIP_Utils.PORTAL_SERVICE_NAME_TIP
            ];

            // If user has no rights to access to Account statements app then is redirected to Home
            if (appRight.Right__c!='Access Granted') {
                Pagereference pageref = new PageReference('/ISSP_Homepage');
                pageref.setRedirect(true);
                return pageref;
            }
            // if terms and conditions are not accepted is redirected to Terms page
            if (!appRight.Terms_Acceptance__c) {
                Pagereference pageref = Page.ISSP_TIP_TermsAndConditions;
                pageref.setRedirect(true);
                return pageref;
            }
        } catch(Exception e) {
            //if error happens return to home page
	    Pagereference pageref = new PageReference('/ISSP_Homepage');
            pageref.setRedirect(true);
            return pageref;
        }

        if (!String.isBlank(Apexpages.currentPage().getParameters().get('caseId'))) return startEnrolmentAccount();
        else if (!String.isBlank(Apexpages.currentPage().getParameters().get('prodId'))) return NewEditProduct();
    
        return null;
    }

    private void popContact() {
        user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);
        isAdmin = (con.User_Portal_Status__c == ANG_Risk_Helper.USER_PORTAL_STATUS_APPROVED_ADIM);
        
        fetchHQAccountDetails();

        btnEnabled = (account.recordtypeid == TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID && account.category__c=='Payment Provider');
        btnVoluntReliqEnabled = isAdmin && ((TheAccountRole != null) ? (TheAccountRole.Status__c == TIP_Utils.PARTNER_STATUS_ACTIVE) : false); //ACAMBAS - TIP-241
        //isPaymentProvider = (account.recordtypeid == TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID);
    }

    public List<Case> getCases(){
        Set<string> closedStatusesList = createListOfClosedStatuses();

    	List<Case> caseList = [SELECT id, toLabel(status), CaseNumber, subject, createddate, CaseArea__c, Reason1__c, IsClosed  FROM Case 
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
        for(Partner_products__c p :[SELECT id, name, toLabel(PP_Payment_Network__c), PP_Effective_to_Date__c, PP_Effective_from_Date__c, toLabel(PP_status__c)
          FROM Partner_products__c 
          WHERE Provider__c  = :con.AccountId
            AND recordtypeid = :TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID
            ORDER BY PP_status__c DESC]){
            
            products.add(new productWrapper(p.id,p.name, p.PP_Payment_Network__c,p.PP_Effective_to_Date__c,p.PP_Effective_from_Date__c, p.PP_status__c));
        }
    }

    //ACAMBAS - TIP-281 - Start 
    private void fillPrimaryContacts() {
        if(TheAccountRole != null) {
            primaryContacts =  [SELECT id, First_Name__c, Last_Name__c, Email__c
                                FROM Account_Contact_Role__c 
                                WHERE Account_Role__c  = :TheAccountRole.Id AND is_primary__c = True];
        }
    }
    //ACAMBAS - TIP-281 - End

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
        public boolean isSelected{get;set;}
        public ProvProdConfigRec(TIP_Pay_Prov_Prod_Country_Config__c tpc,integer p,string a,string cn,boolean rb){
            pos=p;
            prodConfig=tpc;
            action=a;
            countryName=cn;
            renderBtn=rb;
            isSelected=false;
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
                                WHERE ID = :caseId AND Status = 'Draft' AND accountid =:con.accountid]; 
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
        
        //ACAMBAS - TIP-234 ----------
        //if(String.isEmpty(account.TIP_HQ_Location__c)){
        if(String.isEmpty(TheAccountRole.HQ_Location__c)){
        //----------------------------
            account.TIP_HQ_Location__c.addError('Please Choose the Location of Headquarter');
            return null;
        }

        //confirm that primary contact is choosen
        Boolean hasPrimaryContact = false;
        //ACAMBAS - TIP-234 ----------
        /*for(Contact c : contactList){
            if (c.Primary_Contact__c) hasPrimaryContact = true;
        }*/
        for(Account_Contact_Role__c c : AccountContactRoleList){
            if (c.is_primary__c) hasPrimaryContact = true;
        }
        //----------------------------

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
        update theAccountRole;
        upsert newCase;
        if(AccountContactRoleList != null) upsert AccountContactRoleList;

        //assign to TIP HO queue
        List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND developerName = 'Cases_Transparency_in_Payment_Service' LIMIT 1];
        
        if(groups == null || groups.isEmpty()) System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
        else{
            newCase.OwnerId = groups[0].id;
            upsert newcase;
        }

        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(true);
        return pr; 
    }

    public Pagereference saveAccountEnrolmentAsDraft() {

        updateCase();
        update account;
        upsert newCase;
        upsert AccountContactRoleList;     
        try{
            update theAccountRole;
            upsert contactList;
        }catch(Exception e){}
        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(false);
        return pr; 
    }

    public void fetchHQAccountDetails () {
        account = [
                        SELECT Id, Name, Quality__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Legal_name__c,
                        TradeName__c, Membership_status__c, IATACode__c, Sector__c, Category__c, Due_Diligence_Status__c,
                        Due_Diligence_Remarks__c, Level_of_risk__c, Email__c, Website, Phone, PhoneNational__c, Fax, FaxNational__c,
                        Mobile__c, MobileNational__c , Location_Type__c, ParentId, ShippingStreet, ShippingCity, ShippingState,
                        ShippingPostalCode, ShippingCountry, VAT_Number__c, Short_Name__c, Location_Class__c, IATA_ISO_Country__c,
                        Iso_State__c, Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c,
                        VAT_Number_2__c, CASS_Number__c,Company_Type__c,RecordTypeid, RecordType.DeveloperName,Status__c,IATA_ISO_Country__r.ISO_Code__c,ANG_Accreditation_Model__c,
                        IATA_ISO_Country__r.Name, IATA_ISO_Country__r.region__c,Country_ISO_Code__c, Account_Role__c,
                        (Select Account__c, Any_Other_Information__c, Effective_From_Date__c, Effective_To_Date__c, HQ_Location__c, 
        					   Last_Review_Date__c, Provider_Code__c, Provider_Type__c, Status__c, UniqueKey__c
        					   from Account_Roles__r
        					   where RecordTypeId =: TIP_Utils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID
        					   limit 1
						)
                        FROM Account
                        WHERE Id = :con.AccountId
                                   LIMIT 1
                    ];
		
		set<string> setServiceProvided = new set<string>();
		
		if(Account!=null){
			if(string.isNotBlank(Account.Account_Role__c)){
				setServiceProvided.addAll(Account.Account_Role__c.split(';'));
			}
			if(!Account.Account_Roles__r.isEmpty())
				TheAccountRole = Account.Account_Roles__r;
		}
		
        //ACAMBAS - TIP-236 ---------
		//isPaymentProvider = setServiceProvided.contains(TIP_Utils.ACCOUNT_SERVICE_PROVIDED_PAYMENT_PROVIDER);
        isPaymentProvider = setServiceProvided.contains(TIP_Utils.ACCOUNT_SERVICE_PROVIDED_PAYMENT_PROVIDER) && !String.isBlank(account.Quality__c) ? account.Quality__c.contains('YES') : false;
        //---------------------------
        
    }
    
    //Method invoked by Action on visualforce page
    //it checks if the Account Role with type Payment Provider already exist
    //if not, it creates a new one
    public void CreateAccountRole(user TheUser){
    	Account acc = [select Id, 
    						(Select Id From Account_Roles__r where RecordTypeId =: TIP_Utils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID)
    				   from Account 
    				   where Id = :TheUser.Contact.AccountID limit 1];
    	
    	if(acc!= null){
    		if(Acc.Account_Roles__r.isEmpty()) {
    			try{
    				Account_Role__c accrole = new Account_Role__c(Account__c = acc.Id, RecordTypeId = TIP_Utils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID);
    				insert accrole;
    				
    				insert new Account_Contact_Role__c(Contact__c = TheUser.ContactId, Service_Rendered__c = TIP_Utils.ACCOUNT_CONTACT_ROLE_SERVICE_TIP, Account__c = acc.Id, Contact_Role__c = TIP_Utils.ACCOUNT_CONTACT_ROLE_PRIMARY, Account_Role__c = accrole.Id);
    			}catch(exception  e){
    				system.debug('DTULLO --> exception while creating account role: ' + e.getMessage());
    			}
    		}
    	}
    }

    public void updateCase(){

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
    	set<id> SetConId = new set<id>();
    	//Looking into account Contact Role first
    	AccountContactRoleList = [Select id, Account__c, Account_Role__c, Business_Phone__c, Contact__c, Contact_Role__c
    							  , Email__c, First_Name__c, Last_Name__c, Service_Rendered__c, Contact__r.Primary_Contact__c
    							  , Contact__r.Phone, is_primary__c
    							  from Account_Contact_Role__c
    							  where Contact__r.Status__c = 'Active' and Contact__r.Accountid = :con.AccountId
    							  and Service_Rendered__c =:TIP_Utils.ACCOUNT_CONTACT_ROLE_SERVICE_TIP];
    	
    	for(Account_Contact_Role__c acr:AccountContactRoleList)	SetConId.add(acr.Contact__c);
    	
        contactList = [SELECT id,Name, Email,Salutation, FirstName, LastName, Phone, Primary_Contact__c,MobileNational__c,Membership_Function__c,Title,MobilePhone
                FROM Contact
//                WHERE Status__c = 'Active' and Accountid = :con.AccountId];
				where id in:SetConId];
    }

    public void updateRadioButtonStatus() {
        ID contactID = Apexpages.currentPage().getParameters().get('contactIDtoPrimary');
        for (Contact c: contactList) {
            c.Primary_Contact__c = false;
            if(c.id == contactID) c.Primary_Contact__c = true;
        }

        //ACCOUNT_CONTACT_ROLE_PRIMARY
        for (Account_Contact_Role__c conRole: AccountContactRoleList){
        	if(conRole.Contact__c == contactID)
        		conRole.Contact_Role__c = TIP_Utils.ManageMultiPicklist(conRole.Contact_Role__c, TIP_Utils.ACCOUNT_CONTACT_ROLE_PRIMARY, 'Add');
        	else
				conRole.Contact_Role__c = TIP_Utils.ManageMultiPicklist(conRole.Contact_Role__c, TIP_Utils.ACCOUNT_CONTACT_ROLE_PRIMARY, 'Remove');
        }
        
      
        
        //fillContactList();
    }
    
    
    public void createContact(){

        newContact.AccountId = con.AccountId;

        try{
            upsert newContact;
            isEmailDuplicated = false;
            UpsertContactRole(newContact, false);
            system.debug('##done inserting: ' +isEmailDuplicated);
        }catch(Exception e){
            system.debug('##Error inserting: ' +isEmailDuplicated);
            isEmailDuplicated = true;
            return;
        }
        fillContactList();
        newContact = new Contact();
    }
    
    private void UpsertContactRole(Contact theCon, boolean bIsPrimary){
    	Account_Contact_Role__c theContactRole = new Account_Contact_Role__c();
	        theContactRole.Account__c = con.AccountId;
	        theContactRole.Contact__c = theCon.Id;
	        theContactRole.Account_Role__c = TheAccountRole.Id;
	        theContactRole.Service_Rendered__c = TIP_Utils.ACCOUNT_CONTACT_ROLE_SERVICE_TIP;
            theContactRole.UniqueKey__c = TIP_Utils.AccountContactRoleGenerateUniquekey(theContactRole);
	        if(bIsPrimary){
	        	theContactRole.Contact_Role__c = '';
	        }
       upsert theContactRole UniqueKey__c;
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
        renderCountryCondifPopup=true;// render country config popup by default
        applyLanguage = UserInfo.getLanguage();
        displayLanguage = UserInfo.getLanguage(); 

        //ACAMBAS - TIP-249 -----------------------
        //newpp= new Partner_products__c(PP_Payment_Product_Network_type__c=TIP_Utils.PARTNER_PRODUCT_NETWORK_TYPE_OPEN_LOOP);
        newpp= new Partner_products__c();
        //-----------------------------------------
        
        binRangeList= new list<BinRangeRec>();
        deletedBinRangeList= new list<TIP_BIN_Range__c>();

        filterCountryList= new set<string>();

        provProdConfList= new list<ProvProdConfigRec>();
        deletedCountryConfigList= new list<TIP_Pay_Prov_Prod_Country_Config__c>();
        String selectedProdId=System.currentPageReference().getParameters().get('prodId');

        if(!String.isBlank(selectedProdId)){
            list<Partner_products__c> prodlist=[Select id,name,PP_Settlement_terms__c,PP_Issuer_name__c,is_PCI_DSS_required__c,PP_Chargeback_airlines__c,PP_Pay_in_model__c,PP_Category__c,PP_Banking_license__c,PP_Payment_Network__c,PP_GDS_Integration__c,PP_VAN_Type__c,PP_Interchange_fee__c,PP_Payment_guarantee__c,PP_Network_Fee__c,PP_Accepted_transactions__c,PP_Chargeback_airlines_duration__c,Provider__c,PP_status__c,PP_Payment_Product_Network_type__c,PP_Effective_to_Date__c, 
                                                    (select id,TIP_Range_Start__c,TIP_Range_End__c,ToLabel(TIP_Status__c) from BIN_Ranges__r),
                                                    (select id  from cases__r where RecordTypeId =: TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID AND
                                                        Reason1__c = :TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT AND
                                                        CaseArea__c =: TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS),
                                                    (select id,TIP_BSP_Country__c,TIP_BSP_Country__r.name,TIP_BSP_Country__r.ISO_Code__c,TIP_Interchange_Fee__c,Network_Fee__c,ToLabel(TIP_Status__c),TIP_Effective_To_Date__c,TIP_Effective_From_Date__c from Payment_Product_Country_Configs__r order by TIP_Status__c desc, name asc)
                                                from Partner_products__c where id=:selectedProdId];
            if(prodList.size()>0){
                isNew=false;
                newpp= prodlist.get(0);
                editMode=newpp.PP_status__c==TIP_Utils.PARTNER_PRODUCT_STATUS_DRAFT;
                activeProduct=newpp.PP_status__c==TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE; //ACAMBAS - TIP-244
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
        renderTerminateProdPopup=false; //ACAMBAS - TIP-244     
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
        renderTerminateProdPopup=false; //ACAMBAS - TIP-244  
    }

    public void addUpdateCountryConfig(){
        if(selectedProvProdConf.action=='N'){
            for(string c :selectProvConfigCountriesList){
                TIP_Pay_Prov_Prod_Country_Config__c npcc=new TIP_Pay_Prov_Prod_Country_Config__c(
                    TIP_Status__c='Draft',
                    TIP_BSP_Country__c=c,
                    TIP_Interchange_Fee__c=selectedProvProdConf.prodConfig.TIP_Interchange_Fee__c,
                    Network_Fee__c=selectedProvProdConf.prodConfig.Network_Fee__c
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

    public void deleteMassCountryConfig(){
        list<ProvProdConfigRec> removeList= new list<ProvProdConfigRec>();
        integer p=0;
        while(p<provProdConfList.size()){
        //for(ProvProdConfigRec pcr:){
        system.debug('PF provProdConfList '+provProdConfList);
        ProvProdConfigRec pcr=provProdConfList.get(p);
            if(pcr.isSelected){
                filterCountryList.remove(bspIdIsoCodeMap.get(pcr.prodConfig.TIP_BSP_Country__c));
                if(!String.isBlank(pcr.prodConfig.id)) deletedCountryConfigList.add(pcr.prodConfig);
                provProdConfList.remove(p);
            }else{
                p++;
            }
        }

        // refreshing records index
        integer c=0;
        for(ProvProdConfigRec pcr:provProdConfList)pcr.pos=c++;
    }



    // =============================== SAVE AND SUBMIT ===================================================

    public Pagereference saveDraft(){
       return doDMLRecords(TIP_Utils.PARTNER_PRODUCT_STATUS_DRAFT);
    }
 
    

    public Pagereference submitProduct(){
        try{
           set<string> mandatoryFieldsToSubmitSet= new set<string>{'PP_Settlement_terms__c','is_PCI_DSS_required__c','PP_Chargeback_airlines__c','PP_Pay_in_model__c','PP_Category__c','PP_Payment_Product_Network_type__c'}; 
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

            //ACAMBAS - TIP-249 - Start
            /*if(binRangeList.isEmpty()){

                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.ISSP_TIP_INSERT_BIN_RANGE));
                 return null;
             
            } */
            //ACAMBAS - TIP-249 - End


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
            list<case> caseList= newpp.cases__R.isEmpty()?new list<case>():newpp.cases__R;
            if(isNew){
                user usr=[select id,Contact.accountId,Contact.account.name,Contact.account.IATA_ISO_Country__r.region__c,Contact.account.IATA_ISO_Country__r.Name from user where id =:UserInfo.getUserId()];

                newpp.Provider__c=usr.Contact.accountID;
                newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');
                newpp.PP_status__c=status;
                newpp.Payment_Provider_Account_Role__c = TheAccountRole.id; //ACAMBAS
                
                insert newpp;
                
                //create Case
                newCase = new Case();
                newcase.RecordTypeid = TIP_Utils.CASE_PROCESS_IDFS_RECORD_TYPE_ID;
                newcase.AccountId = usr.contact.accountId; 
                newcase.Visible_on_ISS_Portal__c = true;
                newcase.Reason1__c = TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT ;
                newcase.CaseArea__c = TIP_Utils.CASE_AREA_TRANSPARENCY_IN_PAYMENTS; 
                newcase.Status = status;
                newcase.Subject = TIP_Utils.CASE_SUBJECT_NEW_PRODUCT_ENROLMENT+' - '+ newpp.name;
                newCase.Description = TIP_Utils.CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER;
                newcase.Region__c = usr.Contact.account.IATA_ISO_Country__r.region__c;
                newcase.Origin = 'Portal';
                newcase.BSPCountry__c = usr.Contact.account.IATA_ISO_Country__r.Name;
                newcase.TIP_Partner_Product__C=newpp.id;
                newcase.Country_concerned_by_the_query__c = usr.Contact.account.IATA_ISO_Country__r.Name;

                caseList.add(newCase);
               
            } else {
                newpp.PP_Accepted_transactions__c=String.join(acceptedTransactionVal,';');
                newpp.PP_Payment_guarantee__c=String.join(paymentGuaranteeVal,';');
                newpp.PP_status__c=status;

                update newpp;
            }

            if(!caseList.isEmpty()){
                caseList.get(0).Status = status;

                if(status==TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS){
                    caseList.get(0).Status = AMS_Utils.OPEN;

                    List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND NAME = 'Cases - Transparency in Payment Service' LIMIT 1];
                    
                    if(groups == null || groups.isEmpty()) System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
                    else{
                        caseList.get(0).OwnerId = groups[0].id;
                    }
                }

                upsert caseList;
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



    //============================== TERMS AND CONDITIONS METHODS =============================
    public PageReference acceptTerms() {

        Portal_Application_Right__c appRight = [
            Select Id, Terms_Acceptance__c, Terms_Acceptance_Date__c,Right__c
            From Portal_Application_Right__c
            Where ContactId__c = :String.valueOf(user.ContactId).left(15)
            And Portal_Application__r.Name = :TIP_Utils.PORTAL_SERVICE_NAME_TIP
        ];
        system.debug('PF'+acceptedTaC);
        if (acceptedTaC == false || acceptedTaC==null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,Label.ISSP_Accept_Terms_Warning));
            return null;
        }
        
        appRight.Terms_Acceptance__c = acceptedTaC;
        appRight.Terms_Acceptance_Date__c = DateTime.now();
        update appRight;

        PageReference pageref = Page.ISSP_TIP_Home;
        pageref.setRedirect(true);
        return pageref;
    }

    public PageReference rejectTerms() {
        PageReference pageref = new PageReference('/ISSP_Homepage');
        pageref.setRedirect(true);
        return pageref;
    }

    // ACAMBAS - TIP-244 - Start -------------
    //============================== TERMINATE PRODUT =============================

    public void terminateProduct() {
        renderTerminateProdPopup = true; 
        renderCountryCondifPopup = false; 
        terminationMaxDays = (Integer) TIP_Configuration__c.getOrgDefaults().Product_Termination_Max_Days__c; 
    }

    public Pagereference submitProductTerminationRequest() {

        //Update or create case with status Open
        updateCase();
        newcase.Status = 'Open';
        newcase.Subject = 'Product Termination Request - ' + account.name + ' / ' + newpp.name;
        newcase.Description = terminationReason + '\n\nRequested termination date:\n' + terminationDate + ' (mm/dd/yyyy)';
        newcase.Reason1__c = TIP_Utils.CASE_REASON_PRODUCT_MANAGEMENT;
        newcase.TIP_Partner_Product__c = newpp.Id;
       
        //assign to TIP HO queue
        List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND developerName = 'Cases_Transparency_in_Payment_Service' LIMIT 1];
        
        if(groups == null || groups.isEmpty()) {
            System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
        }
        else {
            newCase.OwnerId = groups[0].id;
        }

        insert newCase;


        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(true);
        return pr; 

    }

    // ACAMBAS - TIP-244 - End -----------------
    
    // ACAMBAS - TIP-241 - Start -------------
    //============================== VOLUNTARY RELINQUISHMENT =============================
    
    public Pagereference submitVoluntaryRelinquishmentReq() {

        //Update or create case with status Open
        updateCase();
        newcase.Status = 'Open';
        newcase.Subject = 'ATM Provide Account Closure - ' + account.name;
        newcase.Description = voluntaryReliqReason + '\n\nRequested closure date:\n' + voluntaryReliqDate + ' (mm/dd/yyyy)';
        newcase.Reason1__c = TIP_Utils.CASE_REASON_PAYMENT_PROVIDER_MANAGMENT;
       
        //assign to TIP HO queue
        List<Group> groups =  [SELECT Id FROM Group WHERE Type = 'Queue' AND developerName = 'Cases_Transparency_in_Payment_Service' LIMIT 1];
        
        if(groups == null || groups.isEmpty()) {
            System.debug('ERROR! Cases_Transparency_in_Payment_Service Queue not found proceeding without assign');
        }
        else {
            newCase.OwnerId = groups[0].id;
        }

        insert newCase;


        PageReference pr= Page.ISSP_TIP_Home;
        pr.setRedirect(true);
        return pr; 

    }
    
    // ACAMBAS - TIP-241 - End -----------------
    
}

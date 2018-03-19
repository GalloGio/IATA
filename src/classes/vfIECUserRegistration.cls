public without sharing class vfIECUserRegistration  extends IECPageController {
    
    
    /*********************************************************************************************************************/
    /* Variables, Constants and Maps
    /*********************************************************************************************************************/

  //  Public string userprofile {get{ return( [Select u.email From User u where u.Id =: UserInfo.getUserId() ][0].email + '       '    + [Select u.id From User u where u.Id =: UserInfo.getUserId() ][0].id + '   UserInfo.getUserType()   '    +UserInfo.getUserType() );} }
    public Contact con                  {get; set;}
    public Account acc                  {get; set;}
    public boolean bAccept              {get; set;}
    public boolean bExistingEmail       {get; set;}
    public boolean bInvalidIATACode     {get; set;}
    public string sExistingUserName     {get; set;}
    public string selectedCustomerType  {get; set;}
    public String sIATACode             {get; set;}
    public String sIATALocation         {get; set;}
    public String sCompanyName          {get; set;}
    
    public IECVATUtil.VATConfiguration vatConfig { get; set; }    
    
    public vfIECreCAPTCHA  reCAPTCHA    {get; set;}
    
    public boolean bShowIATACode        {get; set;}
    public boolean bShowIATALocation    {get; set;}
    public boolean bShowCompanyName     {get; set;}
    public boolean bShowRECAPTCHA       {get; set;}
    
    public List<SelectOption> lFilteredType { get;set;}
    public List<SelectOption> lFilteredIndustry { get;set;}

    
    public List<SelectOption> lSearchOptios {get; set;}
    public String sSelectedAccount          {get; set;}
    
    public Integer iRegistrationStep            {get; set;}
    
    public Integer constEMAILCAPTURE            {get {return 1;}}
    public Integer constCONTACTINFO             {get {return 2;}}
    public Integer constACCOUNTSEARCH           {get {return 3;}}
    public Integer constCREATENEWACCOUNT        {get {return 4;}}
    public Integer constEMAILCONFIRMATION       {get {return 5;}}
    public Integer constCHANGEEMAIL             {get {return 6;}}
    public Integer constALREADYREGISTERED       {get {return 7;}}
    
    
    //WorkflowSteps 
    //      EMAILCAPTURE -->    CONTACTINFO -->     ACCOUNTSEARCH -->   EMAILCONFIRMATION
    //      EMAILCAPTURE -->    CONTACTINFO -->     ACCOUNTSEARCH -->   CREATENEWACCOUNT -->    EMAILCONFIRMATION
    //      EMAILCAPTURE -->    CONTACTINFO -->     ACCOUNTSEARCH -->   CHANGEEMAIL -->         EMAILCONFIRMATION
    //      EMAILCAPTURE -->    CONTACTINFO -->     EMAILCONFIRMATION
    public enum WorkflowStep {
                                EMAILCAPTURE, 
                                CONTACTINFO, 
                                ACCOUNTSEARCH, 
                                CREATENEWACCOUNT,
                                EMAILCONFIRMATION, 
                                CHANGEEMAIL
                            }
                            
                            
    //Maps used to filter Accounts types based on customer types
    private FINAL  map<string,string> TYPEPerType = new map<string,string>{

                IECConstants.PARAM_CUSTOMERTYPE_AIRLINE + '_ Cargo Only'=>'Cargo Only',
                IECConstants.PARAM_CUSTOMERTYPE_AIRLINE + '_ Passenger and cargo'=>'Passenger and cargo',
                IECConstants.PARAM_CUSTOMERTYPE_AIRLINE + '_ Passenger Only'=>'Passenger Only',                
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Airline Point of Sale' =>'Airline Point of Sale',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Associations' =>'Associations',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Airline Point of Sale' =>'Airline Point of Sale',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ CASS Associates' =>'CASS Associates',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Couriers' =>'Couriers',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Domestic Agent' =>'Domestic Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ ERSP Agent' =>'ERSP Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ GSA General Sales Agent' =>'GSA General Sales Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Handling Agent' =>'Handling Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ IATA Cargo Agent' =>'IATA Cargo Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ IATA Passenger Sales Agent' =>'IATA Passenger Sales Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Import Agent' =>'Import Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ MSO Member Sales Office' =>'MSO Member Sales Office',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ NISI' =>'NISI',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ SSI' =>'SSI',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ TIDS Agent' =>'TIDS Agent',
                IECConstants.PARAM_CUSTOMERTYPE_GAS +     '_ GSSA Cargo' => 'GSSA Cargo',
                IECConstants.PARAM_CUSTOMERTYPE_GAS +     '_ IBCS consolidator' => 'IBCS consolidator'
        };
    
    
   //Maps used to filter Accounts industries based on customer types
   private FINAL  map<string,string> industryPerType = new map<string,string>{

                IECConstants.PARAM_CUSTOMERTYPE_AIRLINE + '_ Airline'=>'Airline',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Travel Agent' =>'Travel Agent',
                IECConstants.PARAM_CUSTOMERTYPE_AGENCY +  '_ Cargo Agent' =>'Cargo Agent',
                IECConstants.PARAM_CUSTOMERTYPE_GAS +     '_ General Sales Agent' => 'General Sales Agent'

    };
    
    
    
    /*********************************************************************************************************************/
    /* Constructor Method
    /*********************************************************************************************************************/
     
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Controller class constructor
    public vfIECUserRegistration(){
        
        //Set starting "step"
        if (IECUserManager.isUserLoggedIn()) {
            iRegistrationStep = constALREADYREGISTERED;
        }
        else {
            iRegistrationStep = constEMAILCAPTURE; //constAccountSearch; //temporary to test account search and creation. It should be: constEmailCapture;
        }
        bAccept = false;
        bExistingEmail = false;
        bInvalidIATACode = false;
        sExistingUserName = '';

        con = new Contact(User_IECPortal_Status__c = IECConstants.NEW_CONTACT_STATUS);
        String contactOwner = IECUserManager.getIECContactOwnerId();
        if (contactOwner != null && contactOwner != '')
            con.OwnerId = IECUserManager.getIECContactOwnerId();
        reCAPTCHA = new vfIECreCAPTCHA();
        reCAPTCHA.verified = false;
        bShowRECAPTCHA = true;
        
        
        
        
        
        //%%%%%%%%%%%%%%%%%%%%%%%%TEST   
      // iRegistrationStep =4;
       
    }
    
    
    /*********************************************************************************************************************/
    /* Getters for list values
    /*********************************************************************************************************************/
     
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of countries pairs: id-name
    public List<SelectOption> getISOCountry() {
        List<SelectOption> options = new List<SelectOption>();
        for(IATA_ISO_Country__c iso:[select Id,Name,ISO_Code__c from IATA_ISO_Country__c order by Name]){
        options.add(new SelectOption(iso.Id,iso.Name));
        }
        return options;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of countries pairs: nama-name
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-Select a Country-'));
        
        for(IATA_ISO_Country__c iso:[select Id,Name,ISO_Code__c from IATA_ISO_Country__c order by Name]){
        options.add(new SelectOption(iso.Name,iso.Name));
        }
        return options;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of customer types
    public List<SelectOption> getCustomerTypes() {
        
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','-Select a Customer Type-'));
        options.add(new SelectOption(IECConstants.PARAM_CUSTOMERTYPE_AIRLINE,'Airline'));
        options.add(new SelectOption(IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE,'Non-Airline Supplier'));
        options.add(new SelectOption(IECConstants.PARAM_CUSTOMERTYPE_AGENCY,'IATA Agency'));
        options.add(new SelectOption(IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY,'Non-IATA Agency'));
        options.add(new SelectOption(IECConstants.PARAM_CUSTOMERTYPE_GAS,'General Sales Agents'));
        options.add(new SelectOption(IECConstants.PARAM_CUSTOMERTYPE_OTHER,'Other'));

        return options;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of provinces of Canada
    public List<SelectOption> getCanadaProvinces() {
        return IECConstants.getCanadaProvinces();
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Returns the list of states in US 
    public List<SelectOption> getUSAStates() {
        return IECConstants.getUSAStates();
    }
    
    
 
 
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Filter Accounts types and Industries based on customer type
    public void filterAccountIndustryAndType(){
        
        try {
            
            
            //For Airline customer, only Airline will be available as Industry and will be automatically selected
            List<SelectOption> IndustryOptions = (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AIRLINE) ? new List<SelectOption>() : new List<SelectOption>{new SelectOption('','-Select an Industry-')};
            List<SelectOption> TypeOptions =new List<SelectOption>{  new SelectOption('','-Select a Type-')};
       
            //If customer types 
            for(string key: industryPerType.keyset()){
                if(key.contains(selectedCustomerType +'_')){
                    IndustryOptions.add(new SelectOption(industryPerType.get(key),industryPerType.get(key)));
                }
            }
      
            for(string key: TYPEPerType.keyset()){
                if(key.contains(selectedCustomerType +'_'))
                    TypeOptions.add(new SelectOption(TYPEPerType.get(key),TYPEPerType.get(key)));
                }
      
                //For custumers other than Airline, Agency and GAS, all industries and types are available to be selected
                if(selectedCustomerType != IECConstants.PARAM_CUSTOMERTYPE_AIRLINE && 
                    selectedCustomerType != IECConstants.PARAM_CUSTOMERTYPE_AGENCY && 
                    selectedCustomerType != IECConstants.PARAM_CUSTOMERTYPE_GAS ){

                    //Get Account industry picklist values
                    Schema.DescribeFieldResult fieldResult1 =  Account.Industry.getDescribe();
                    List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();            
                    
                    for( Schema.PicklistEntry f1 : ple1){
                        IndustryOptions.add(new SelectOption(f1.getLabel(), f1.getValue()));
                    }            

                    //Get Account type picklist values
                    Schema.DescribeFieldResult fieldResult2 =  Account.Type.getDescribe();
                    List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();            
           
                    for( Schema.PicklistEntry f2 : ple2){
                        TypeOptions.add(new SelectOption(f2.getLabel(), f2.getValue()));
                    }            

                }
          
                lFilteredType = TypeOptions;
                lFilteredIndustry = IndustryOptions;
            
            if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AIRLINE)
                acc.Sector__c = 'Airline';
             
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An Error occurred. Please contact support.' + e.getMessage() ));
        }
    }    
    
    
    
    /*********************************************************************************************************************/
    /* Validation Methods
    /*********************************************************************************************************************/
     
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Validate email capture
    public boolean pageIsValid(){
//throw new TransformationException('' + con + '   bAccept '   +  bAccept);
        if(con.Email==null || con.Email=='' ){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter an Email' ));
            return false;
        }
        else {
            if (!IECUtil.validateEmail(con.Email)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_InvalidEmail));
                return false;
            }
        }

        if(!Test.isRunningTest() && !reCAPTCHA.verified && !reCAPTCHA.verify()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'reCAPTCHA verification Failed' ));
            return false;
        }

        if(!bAccept){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please accept the General Conditions' ));
            return false;
        }

        
        reCAPTCHA.verified = true;
        bShowRECAPTCHA = false;
        return true;
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Validate existence of email address as contact / user
    public PageReference validateUserEmail() {
        try {

            //Reset existing email message to hidden
            bExistingEmail = false;
            sExistingUserName = '';

            //Chack if all required information is OK
            if(!pageIsValid()) {
                // throw new TransformationException(' page not valid'  );
                return null;
            }


            list<User> userList =[select Id, IsActive from User where email=: String.escapeSingleQuotes(con.Email.trim())  and IsActive = : true];
         //   throw new TransformationException(''+ userList );
            if(userList != null && userList.size() > 0) {
                //There is a contact and user with the same entered email
                //Show up the existing email message
                bExistingEmail = true;
                sExistingUserName = con.Email;
                return null;
            }
         

            //Show up Contact capture form. Either for capturing new contact information or showing up exiting user information
            iRegistrationStep = constCONTACTINFO; //constContactInfo;

        
            String rtId = IECUserManager.getContactRecordTypeForIEC();  
        
            //Find if there is a Contact using the entered email
            list<Contact> conList = [select Salutation, LastName, FirstName, Email, AccountId, RecordTypeId, Title, Phone
                                    from Contact 
                                    where Email =: String.escapeSingleQuotes(con.Email.trim()) ];
        
            /* Search should be performed over all contacts regardless their record type
            list<Contact> conList = [select Salutation, LastName, FirstName, Email, AccountId
                                    from Contact 
                                    where Email =:con.Email.trim() and RecordTypeId=:rtId];
            */

            if( conList.size()>0){
                //There is a contact existing with same email. Prefill information fields
                Contact con2 = conList.get(0);
                
                con.Id = con2.Id;
                con.LastName = con2.LastName;
                con.FirstName = con2.FirstName;
                con.Salutation = con2.Salutation;
                con.Title = con2.Title;
                con.Phone = con2.Phone;
                con.AccountId = con2.AccountId;
                con.RecordTypeId = con2.RecordTypeId;
                
                acc = [SELECT Id, Name, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity 
                FROM Account WHERE Id =: con.Accountid];
            }
            else {
                con.RecordTypeId = rtId;
            }
        }
        catch(exception ex){
             //        throw new TransformationException(''+ ex.getMessage() );


           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
           return null;
        }
        
        return null;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Check for the IATA Code. If at least 1 account exist with that IATA code, returns true
    public Boolean isValidIATACode(String iataCode) {
        
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add(IECConstants.Account_RecordType_Airline);
        recordTypeNames.add(IECConstants.Account_RecordType_BranchAirline);

        List<Account> iataAccounts = [SELECT Id FROM Account WHERE IATACode__c = :sIATACode AND RecordType.DeveloperName IN:recordTypeNames LIMIT 1];

        if (iataAccounts != null && iataAccounts.size() > 0)
            return true;
            
        return false;
    }
    
    /*********************************************************************************************************************/
    /* Workflow Navigation methods
    /*********************************************************************************************************************/
     
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Validates contact information (on new contact) and jump to search account page
    public PageReference goToSearchAccount() {
        
        
        if (iRegistrationStep == constCONTACTINFO) {
            if (con.id == null) {
            
                if (con.FirstName == null || con.FirstName == '' || con.LastName == null || con.LastName == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration requires a Name and Last Name' )); 
                    return null;
                }
        
                if (con.Title == null || con.Title == '')  {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration requires Job Title' ));  
                    return null;
                }
            
                if (con.Phone == null || con.Phone == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration requires Phone number' )); 
                    return null;
                }
            
                iRegistrationStep = constACCOUNTSEARCH;
            }
            else if (acc.Id != null) {
                
                //If contact exist and it's linked to an account, Skip account search/cration. 
                //Uses the account already binded to contact
                sSelectedAccount = acc.Id;
                registerPortalUser();
                
            }
            
        }
        else if (iRegistrationStep == constCREATENEWACCOUNT) {
            iRegistrationStep = constACCOUNTSEARCH;
        } 
        else if (iRegistrationStep == constACCOUNTSEARCH) {
            iRegistrationStep = constCONTACTINFO;
        }
        else if (iRegistrationStep == constCHANGEEMAIL) {
            iRegistrationStep = constACCOUNTSEARCH;
        }
        
        
        return null;
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Shows the New Account creation page       
    public PageReference nextToCreateAccount() {
        
        
        String accountRT = IECUsermanager.getAccountRecordTypeByName('Standard_Account');
        
        acc = new Account(RecordTypeId = accountRT);
        
        if (sIATACode != null && sIATACode != '')
            acc.IATACode__c = sIATACode;
            
        if (sCompanyName != null && sCompanyName != '')
            acc.Name = sCompanyName;

        
        filterAccountIndustryAndType();
        
        iRegistrationStep = constCREATENEWACCOUNT;

        
        return null;
    }    
    
    
    
    
    /*********************************************************************************************************************/
    /* Search Account Methods
    /*********************************************************************************************************************/
     
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type criteria
    public PageReference searchAccount() {
        try {
            
            bInvalidIATACode = false;
            
            if (selectedCustomerType == null || selectedCustomerType == null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Customer Type is required for searching accounts' ));
                return null;
            }
            
            if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AIRLINE)
                return searchAirlineAccount();
            else if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE)
                return searchNonAirlineAccount();
            else if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AGENCY)
                return searchAgencyAccount();
            else if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_GAS)
                return searchGSAAccount();
            else if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY)
                return searchNonIATAAgencyAccount();
            else if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_OTHER)
                return searchOtherAccount();
                
        
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error searching account: ' + ex.getMessage() ));
        }
        
        return null;
    }
    



    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type AIRLINE
    public PageReference searchAirlineAccount() {
        
        lSearchOptios = new List<SelectOption>();

        
        //Validate search fields
        if (sIATACode == null || sIATACode == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'IATA Code is required.' ));
            bInvalidIATACode = true;
            return null;
        }
        else if (sIATACode.length() != 3) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter 3 numeric digits for the IATA Code.' ));
            bInvalidIATACode = true;
            return null;            
        }
        else if (sIATACode.length() == 3) {
            try {
                decimal d = decimal.valueOf(sIATACode);
            }
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter 3 numeric digits for the IATA Code.' ));
                bInvalidIATACode = true;
                return null;
            }
        }

        if (sIATALocation == null || sIATALocation == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Location is required.'));
            bInvalidIATACode = true; 
            return null;
        }            
        

        //Perform the search
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add(IECConstants.Account_RecordType_Airline);
        recordTypeNames.add(IECConstants.Account_RecordType_BranchAirline);
        
        String hqRTId = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);

        List<Account> searchSesult = [SELECT Id, Name, IATACode__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                                        FROM Account 
                                        WHERE IATACode__c = :  String.escapeSingleQuotes(sIATACode)
                                            AND IATA_ISO_Country__c =: sIATALocation 
                                            AND RecordType.DeveloperName IN:recordTypeNames 
                                            order by RecordType.DeveloperName ASC];

        //system.debug('Searching result  [' + searchSesult + '] for IATACode [' + sIATACode + '] and LocationId [' + sIATALocation + ']' + ' for RecordType [' + hqRTId +']');

        //If search result is empty, then validate the IATA code used
        if (searchSesult == null || searchSesult.size() == 0) {
            bInvalidIATACode = !isValidIATACode(sIATACode);
            
            if (bInvalidIATACode) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The IATA Code you entered does not exist.' ));
                return null;
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The search result is empty.' ));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Check your search criterias and try again or create a new account.' ));
                return null;
            }
        }

        //////////////////////////
        //Display results

        //Get Airline HQ Id
        for (Account a :searchSesult) {
            if (a.RecordTypeId == hqRTId)
                lSearchOptios.add(new SelectOption(a.Id, a.Name + ' [HQ]' + billingAddress(a)));
            else 
                lSearchOptios.add(new SelectOption(a.Id, a.Name + billingAddress(a)));
        }
        
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type AGENCY
    public PageReference searchAgencyAccount() {
        lSearchOptios = new List<SelectOption>();

        //Validate search fields
        if (sIATACode == null || sIATACode == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'IATA Code is required.'));
            bInvalidIATACode = true;
            return null;
        }
        else if (sIATACode.length() != 8 && sIATACode.length() != 11) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter 8 or 11 numeric digits for the IATA Code.'));
            bInvalidIATACode = true;
            return null;            
        }
        else if (sIATACode.length() == 8 || sIATACode.length() == 11) {
            try {
                decimal d = decimal.valueOf(sIATACode);
            }
            catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter 8 or 11 numeric digits for the IATA Code.'));
                bInvalidIATACode = true;
                return null;
            }
        }

        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add('IATA_Agency');

        List<Account> searchSesult = [SELECT Id, Name, IATACode__c, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                                        FROM Account 
                                        WHERE IATACode__c = :  String.escapeSingleQuotes(sIATACode) 
                                            AND RecordType.DeveloperName IN:recordTypeNames 
                                            order by Name ASC];



        //If search result is empty, show message to the user
        if (searchSesult == null || searchSesult.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The search result is empty.' ));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Check your search criterias and try again or create a new account.' ));
            return null;
        }
        
        for (Account a :searchSesult) 
            lSearchOptios.add(new SelectOption(a.Id, a.Name + billingAddress(a)));
        
        return null;
    }
        
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type GSA
    public PageReference searchGSAAccount() {
        lSearchOptios = new List<SelectOption>();

        //Validate search fields
        if (sIATACode == null || sIATACode == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'IATA Code is required.'));
            bInvalidIATACode = true;
            return null;
        }
        else if (sIATACode.length() != 3) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter 3 letters for the IATA Code.' ));
            bInvalidIATACode = true;
            return null;
        }
        
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add('IATA_GSA');

        List<Account> searchSesult = [SELECT Id, Name, IATACode__c, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                                        FROM Account 
                                        WHERE IATACode__c = : String.escapeSingleQuotes(sIATACode) 
                                            AND RecordType.DeveloperName IN:recordTypeNames 
                                            order by Name ASC];


        //If search result is empty, show message to the user
        if (searchSesult == null || searchSesult.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The search result is empty.' ));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Check your search criterias and try again or create a new account.' ));
            return null;
        }

        for (Account a :searchSesult) 
            lSearchOptios.add(new SelectOption(a.Id, a.Name + billingAddress(a)));
                    
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type Non Airline
    public PageReference searchNonAirlineAccount() {
        lSearchOptios = new List<SelectOption>();

        //Validate search fields
        if (sCompanyName == null || sCompanyName == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Name is required'));
            bInvalidIATACode = true;
            return null;
        }
    
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add('Others');

        List<Account> searchSesult;

        if (sIATALocation != null && sIATALocation != '') {
            
            searchSesult = [SELECT Id, Name, IATA_ISO_Country__c, IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                            FROM Account 
                            WHERE IATA_ISO_Country__c = :sIATALocation 
                            AND Name like :  String.escapeSingleQuotes(sCompanyName) +'%'
                            AND RecordType.DeveloperName IN:recordTypeNames 
                            order by Name ASC];
        }
        else {
            searchSesult = [SELECT Id, Name, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                            FROM Account 
                            WHERE Name like : String.escapeSingleQuotes(sCompanyName) +'%'
                            AND RecordType.DeveloperName IN:recordTypeNames 
                            order by Name ASC];
        }


        //If search result is empty, show message to the user
        if (searchSesult == null || searchSesult.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The search result is empty.' ));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Check your search criterias and try again or create a new account.' ));
            return null;
        }
        
        
        for (Account a :searchSesult) 
            lSearchOptios.add(new SelectOption(a.Id, a.Name + billingAddress(a)));
        
        return null;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type NON IATA AGENCY
    public PageReference searchNonIATAAgencyAccount() {

        lSearchOptios = new List<SelectOption>();

        
        //Validate search fields
        if (sCompanyName == null || sCompanyName == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Name is required'));
            return null;
        }

    
    
        //Validate search fields
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add('Others');

        List<Account> searchSesult;

        if (sIATALocation != null && sIATALocation != '') {
            
            searchSesult = [SELECT Id, Name, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                            FROM Account 
                            WHERE IATA_ISO_Country__c = :sIATALocation 
                            AND Name like : String.escapeSingleQuotes(sCompanyName) +'%'
                            AND RecordType.DeveloperName IN:recordTypeNames 
                            order by Name ASC];
        }
        else {
            searchSesult = [SELECT Id, Name, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                            FROM Account 
                            WHERE Name like : String.escapeSingleQuotes(sCompanyName) +'%'
                            AND RecordType.DeveloperName IN:recordTypeNames 
                            order by Name ASC];
        }


        //If search result is empty, show message to the user
        if (searchSesult == null || searchSesult.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The search result is empty.' ));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Check your search criterias and try again or create a new account.' ));
            return null;
        }
        
        
        for (Account a :searchSesult) 
            lSearchOptios.add(new SelectOption(a.Id, a.Name + billingAddress(a)));
        
        return null;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Search account based on customer type OTHER
    public PageReference searchOtherAccount() {
        lSearchOptios = new List<SelectOption>();

        //Validate search fields
        if (sCompanyName == null || sCompanyName == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Company Name is required'));
            bInvalidIATACode = true;   
            return null;     
        }
    
        //Validate search fields
        List<String> recordTypeNames = new List<String>();
        recordTypeNames.add('Others');

        List<Account> searchSesult;

        if (sIATALocation != null && sIATALocation != '') {
            
            searchSesult = [SELECT Id, Name, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                            FROM Account 
                            WHERE IATA_ISO_Country__c = :sIATALocation 
                            AND Name like : String.escapeSingleQuotes(sCompanyName) +'%'
                            AND RecordType.DeveloperName IN:recordTypeNames 
                            order by Name ASC];
        }
        else {
            searchSesult = [SELECT Id, Name, IATA_ISO_Country__c,IATA_ISO_Country__r.Name, BillingStreet, BillingState, BillingPostalCode, BillingCity, RecordTypeId
                            FROM Account 
                            WHERE Name like : String.escapeSingleQuotes(sCompanyName) +'%'
                            AND RecordType.DeveloperName IN:recordTypeNames 
                            order by Name ASC];
        }


        //If search result is empty, show message to the user
        if (searchSesult == null || searchSesult.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The search result is empty.' ));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Check your search criterias and try again or create a new account.' ));
            return null;
        }

        for (Account a :searchSesult) 
            lSearchOptios.add(new SelectOption(a.Id, a.Name + billingAddress(a)));
        
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Handles the required search parameters based on the type of customer
    public PageReference  TypeOfCustomerChange() {
        
        bInvalidIATACode = false;
        lSearchOptios = null;
        sIATACode = '';
        sCompanyName = '';
        sIATALocation = '';
        
        //Show IATA CODE
        bShowIATACode = false;
        if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AIRLINE || 
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_GAS ||  
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AGENCY)
            bShowIATACode = true;
            
        //Show COUNTRY LOCATION
        bShowIATALocation = false;
        if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_AIRLINE || 
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE ||
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY ||
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_PARTNER ||
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_OTHER) 
            bShowIATALocation = true;
        
        //Show COMPANY NAME
        bShowCompanyName = false;
        if (selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY ||
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE ||
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_PARTNER ||
            selectedCustomerType == IECConstants.PARAM_CUSTOMERTYPE_OTHER) 
            bShowCompanyName = true;
            
            
        return null;
    }

    public PageReference CountryChanged() {
        
        vatConfig = IECVATUtil.GetVATConfiguration(acc.BillingCountry);
        
        if (vatConfig != null && 
            vatConfig.Country != acc.BillingCountry) {
                
            vatConfig = IECVATUtil.GetVATConfiguration(acc.BillingCountry);
            con.Tax_1_ID__c = null;
            con.Tax_2_ID__c = null;
        }
                
        return null;
    }

    /*********************************************************************************************************************/
    /* Registration Methods
    /*********************************************************************************************************************/

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Creates a new user if no user already exist in SF


    public boolean createNewUser(Contact con){        
    
    
    String userId;
        String accountId;
        

        try {


            
          userId= Comm_User_Helper.createNewUser(con,selectedCustomerType, 'IEC');

          if (userId != null) {
            RecordType rt = [Select r.Id,r.Name, r.DeveloperName From RecordType r where  DeveloperName='Standard_Contact'];

            //conList = [select accountId,firstName,lastName,Email from Contact where Email =:con.email.trim() and RecordTypeId=:rt.Id];
               contact conIDCard = [select accountId,firstName,lastName,Email,User_Portal_Status__c,
                            (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE Is_Active_Card__c = true)
                            from Contact where id =:con.id and RecordTypeId=:rt.Id];
        

                //TF - SP10-N2
                if (!conIDCard.ID_Cards__r.isEmpty()){
                    conIDCard.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
                }
                else{
                    conIDCard.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS ;
                }

    

            try { 
                conIDCard.community__c= 'E-Commerce';
                upsert conIDCard;        
            } catch (Exception ex) {
                    transformationHelper.sendSFDevsAlertMessage('error',
                     '   ' +ex.getmessage() + '   '+ ex.getstackTraceString(),  new list<string>{'sfdcadmin@iata.org'});
            }
                
                   return true;



            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'General Error. User cannot be created'));

                return false;
            }


        }
        catch(exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));


            return false;
         }
       
        return false;
    }

    public PageReference registerUserWithEmailChange() {
        IECUtil.DomainValidation validation = IECUtil.validateContactEmailDomain(con.Email, sSelectedAccount);
        
        if (validation != IECUtil.DomainValidation.ERROR) {
            if (validation == IECUtil.DomainValidation.MATCHINGDOMAIN)
                con.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
            
            Account oAccount = [SELECT BillingStreet, BillingState, BillingPostalCode, BillingCity, BillingCountry,IATA_ISO_Country__r.Name FROM Account WHERE Id = :sSelectedAccount];
            con.AccountId = oAccount.Id;
            if (vatConfig == null) vatConfig = IECVATUtil.GetVATConfiguration(oAccount.BillingCountry);
            if (vatConfig != null) con.VAT_Country_Code__c = (vatConfig.VATValidationRequired) ? vatConfig.CountryCode : null;


            con.MailingCountry  = oAccount.BillingCountry;
            con.MailingState  =  oAccount.BillingState;

            
            //Register the contact
            con.community__c = 'E-Commerce';
            upsert con;
            
            // Add a Contact Billing Address to the IECAddress table 
            RegisterContactBillingAddress(oAccount, con);
        
            //Create the new User
            if (createNewUser(con) == true)
                iRegistrationStep = constEMAILCONFIRMATION;
        }
        else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error validating email: ' + con.Email));
        }

        return null;
    }

    public void registerPortalUser() {
 
        try {
            if (sSelectedAccount == null || sSelectedAccount == '') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Registration requires an Account to be selected or created' ));
                return;
            }
        
            //Validate Email Domain 
            IECUtil.DomainValidation validation = IECUtil.validateContactEmailDomain(con.Email, sSelectedAccount);
        
            //Show up the option to change the email address (only if user has selected an account from existing ones)
            if (iRegistrationStep == constACCOUNTSEARCH && validation == IECUtil.DomainValidation.NOTMATCHINGDOMAINS) {
            
                iRegistrationStep = constCHANGEEMAIL;
                return;
            }
        
            if (validation == IECUtil.DomainValidation.MATCHINGDOMAIN)
                con.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
            
            Account oAccount = [SELECT BillingStreet, BillingState, BillingPostalCode, BillingCity, BillingCountry, IATA_ISO_Country__r.Name FROM Account WHERE Id = :sSelectedAccount];
            con.AccountId = oAccount.Id;
            if (vatConfig == null) vatConfig = IECVATUtil.GetVATConfiguration(oAccount.BillingCountry);
            if (vatConfig != null) con.VAT_Country_Code__c = (vatConfig.VATValidationRequired) ? vatConfig.CountryCode : null;
            con.MailingCountry  = oAccount.BillingCountry;
            con.MailingState  =  oAccount.BillingState;

            
            //Register the contact
             con.community__c = 'E-Commerce';

            upsert con;
            
            // Add a Contact Billing Address to the IECAddress table 
            RegisterContactBillingAddress(oAccount, con);
        
            //Create the new User
            if (createNewUser(con) == true)
                iRegistrationStep =  constEMAILCONFIRMATION;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }

    public PageReference registerNewAccount() {
        //Validate required account information
        if (acc.Name == null  || acc.Name == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Company Name' ));
            return null;
        }
        
        if (acc.Sector__c == null  || acc.Sector__c == '' || acc.Category__c == null  || acc.Category__c == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Industry and Type' ));
            return null; 
        }
        
        if (acc.Phone == null  || acc.Phone == '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Company Public Phone' ));
            return null;
        }

        if (acc.BillingCountry == 'Canada') {
            if (acc.BillingStreet == null  || acc.BillingStreet == '' ||
                acc.BillingCity == null  || acc.BillingCity == ''||
                acc.BillingState == null  || acc.BillingState == '' ||
                acc.BillingPostalCode == null  || acc.BillingPostalCode == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Street, City, Province, Postal Code and Country' ));
                    return null;
                }
                
            if (acc.BillingPostalCode.length() > 20) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Postal Code is too long' ));
            }
                
                
                    
        } else if (acc.BillingCountry == 'USA') {
            if (acc.BillingStreet == null  || acc.BillingStreet == '' ||
                acc.BillingCity == null  || acc.BillingCity == ''||
                acc.BillingState == null  || acc.BillingState == '' ||
                acc.BillingPostalCode == null  || acc.BillingPostalCode == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + '  Street, City, State, Zip Code and Country' ));
                    return null;
                }
                
            if (acc.BillingPostalCode.length() > 20) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Zip Code is too long' ));
            }
        }
        else { 
            if (acc.BillingCountry == null  || acc.BillingCountry == '' ||
                acc.BillingStreet == null  || acc.BillingStreet == '' ||
                acc.BillingCity == null  || acc.BillingCity == '') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' Street, City and Country' ));
                    return null;
                }
                
            if (acc.BillingPostalCode != null && acc.BillingPostalCode.length() > 20) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Postal/Zip Code is too long' ));
            }
        }   
        
        //Check for Tax information
        if (vatConfig != null && vatConfig.TaxIDMandatory) {
            if (vatConfig.ShowTax1) {
                if (String.isBlank(con.Tax_1_ID__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + vatConfig.Tax1Label ));
                    return null;
                }
                else if (vatConfig.VATValidationRequired) {
                    IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
                    try {
                        IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, con.Tax_1_ID__c);
                        if (!res.valid) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + vatConfig.Tax1Label ));
                            return null;
                        }                           
                    }
                    catch (System.CalloutException ex) {
                        if (ex.getMessage().contains('SERVER_BUSY')) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_VATWSBusy ));
                            return null;
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                            return null;
                        }                       
                    }
                }                           
            }
            if (vatConfig.ShowTax2) {
                if (String.isBlank(con.Tax_2_ID__c)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Required_field + ' ' + vatConfig.Tax2Label ));
                    return null;
                }
                else if (vatConfig.VATValidationRequired) {
                    IECVATUtil.VATWebService ws = new IECVATUtil.VATWebService();
                    try {
                        IECVATUtil.VATResponse res = ws.ValidateVAT(vatConfig.CountryCode, con.Tax_2_ID__c);
                        if (!res.valid) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_Invalid_VAT + vatConfig.Tax2Label ));
                            return null;
                        }
                    }
                    catch (System.CalloutException ex) {
                        if (ex.getMessage().contains('SERVER_BUSY')) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.IEC_Error_VATWSBusy ));
                            return null;
                        }
                        else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() ));
                            return null;
                        }                       
                    }
                }
            }
        }
        
        try {

            //Complete account information
            IATA_ISO_Country__c iso = [select Id, Name from IATA_ISO_Country__c where Name=: acc.BillingCountry limit 1];
            acc.IATA_ISO_Country__c =  iso.Id; // ISOCountry.getValue();//
            acc.Reason_for_creation__c = 'Created by customer';
            
            //Set owner Id with privileges to attach portal user to new created account
            String accountOwner = IECUserManager.getIECAccountOwnerId();
            if (accountOwner != null && accountOwner != '')
                acc.OwnerId = IECUserManager.getIECAccountOwnerId(); //'00511000000m1if';

            //Save the new Account          
            insert acc;
            
            
            //Create the user associated the the account
            if (acc.Id != null) {
                sSelectedAccount = acc.Id;
                registerPortalUser();
            }
            else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating new account' ));
            }
            
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error creating new account: ' + ex.getMessage() ));
        }
        
        return null;
    }
    
    
    /**
     * Handles the logout link
     */
    public Pagereference logout() {
        try {
            // delete shopping cart cookie
            IECCookieHelper.deleteShoppingCartCookie();

            PageReference pr = Page.IECLogout; //new PageReference('/secur/logout.jsp');
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    /*********************************************************************************************************************/
    /* Other Private Methods
    /*********************************************************************************************************************/
     
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Builds one line address string from Accound address components
    private String billingAddress(Account a) {
        String address = '';
        
        if (a.BillingStreet != null )
            address = a.BillingStreet;
        
        if (a.BillingCity != null) 
            address += (address == '') ? a.BillingCity : ', ' + a.BillingCity;
        
        if (a.BillingState != null) 
            address += (address == '') ? a.BillingState : ', ' + a.BillingState;
        
        if (a.BillingPostalCode != null) 
            address += (address == '') ? a.BillingPostalCode : ', ' + a.BillingPostalCode;
        
        if (address != '') address = ' - ' + address;   
        
        return address;
    }
    
    private void RegisterContactBillingAddress(Account oAccount, Contact oContact) {
        
        //---Create Bill To Location if not Exist
        List<Location__c> lstBillingLocation = Location_Sel.getLocationByContact(oContact.Id, IECConstants.IECAddress_AddressType_Billing); 
		Location__c oBillingLocation = (!lstBillingLocation.isEmpty())
			? lstBillingLocation[0]
			: new Location__c(
                Contact__c = oContact.Id
                , Account__c = oAccount.Id
                , Type__c = 'Bill To'
                , Active__c = true
            );
        	
        string temp = (oAccount.IATA_ISO_Country__r.Name == null) ? oAccount.BillingCountry+'' : oAccount.IATA_ISO_Country__r.Name+'';

        List<IATA_ISO_Country__c> isoCountries = [SELECT Id FROM IATA_ISO_Country__c WHERE Name = :temp];
        List<IATA_ISO_State__c> isoStates = [SELECT Id FROM IATA_ISO_State__c WHERE Name = :oAccount.BillingState];
 
        IECAddress__c oBillingAddress = new IECAddress__c(
            Contact__c = oContact.Id
            , City__c = oAccount.BillingCity
            , Street__c = oAccount.BillingStreet
            , ZipCode__c = oAccount.BillingPostalCode
            , ISO_Country__c = (isoCountries.size() > 0) ? isoCountries[0].Id : null
	        , ISO_State__c = (isoStates.size() > 0) ? isoStates[0].Id : null 
        );
        insert oBillingAddress;

        oBillingLocation.Address__c = oBillingAddress.Id;
        upsert oBillingLocation;

        //EXISTING CODE
       /*string temp = (oAccount.IATA_ISO_Country__r.Name == null) ? oAccount.BillingCountry+'' : oAccount.IATA_ISO_Country__r.Name+'';
        
        insert new IECAddress__c(
            Contact__c = oContact.Id
            , Address_Type__c = IECConstants.IECAddress_AddressType_Billing
            , City__c = oAccount.BillingCity
            , Country__c =  temp
            , State__c = oAccount.BillingState
            , Street__c = oAccount.BillingStreet
            , ZipCode__c = oAccount.BillingPostalCode
        );*/
    }
}
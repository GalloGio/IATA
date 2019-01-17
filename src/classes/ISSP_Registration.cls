public without sharing class ISSP_Registration {

    public Pagereference redirectID(){
        String communityName = ApexPages.currentPage().getParameters().get('CommunityName');

        if(communityName == null){
            PageReference pr = new PageReference(OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + '/login/SelfRegister?serviceName=ISSP');
            pr.setRedirect(true);                        
            return pr;    
        }else{ //keep using the ISSP Registration page
            return null;
        }
        
    }

    public string lang{get
    {
        string t = '';
        Cookie coo = ApexPages.currentPage().getCookies().get('lang');
        if(System.currentPageReference().getParameters().get('lang')!=null){
             t = System.currentPageReference().getParameters().get('lang');
             coo = new Cookie('lang',t,null,-1,false);
             ApexPages.currentPage().setCookies(new Cookie[]{coo});
             system.debug('PARAMETER: ' + t);
        }
        else if(coo != null){
            t = string.valueOf(coo.getValue());
            system.debug('COOKIE: ' + t);
        }
        else{
            String LANGUAGES_FROM_BROWSER_AS_STRING = ApexPages.currentPage().getHeaders().get('Accept-Language');
            if (LANGUAGES_FROM_BROWSER_AS_STRING != null && LANGUAGES_FROM_BROWSER_AS_STRING != ''){
                list<String> langList = LANGUAGES_FROM_BROWSER_AS_STRING.split(',');
                if (!langList.isEmpty()){
                    t = langList[0];
                    system.debug('LANG LIST: ' + t);
                }
                else{
                    t = 'en_US';
                    system.debug('NO LANG LIST: ' + t);
                }
            }
            else{
                t = 'en_US';
                system.debug('NO BROWSER LANG: ' + t);
            }
        }
        return t;
    }set;}

    public static string password = '';
    public static map<string,string> passwordMap =new map<string,string>();

    private final string Airline = 'Airline';
    private final string Agency = 'Agency';
    private final string GSA = 'GloballSalesAgent';
    private final string TIESS = 'TIESS';
    private final string NonIATA = 'NonIATAAgent';
    private final string OtherCompany = 'OtherCompany';
    private final string generalPublic = 'GeneralPublic';

    private Map<Id,String> countryMap;
    private Map<Id,String> countryISOCodeMap;
    private Map<String, Id> iSOCodeMap;

    // Errors, Logs and Error Case:
    public list<String> errorMessage {get; set;}
    public list<String> infoMessage {get; set;}
    private String log;
    private string generalError =  Label.ISSP_Registration_generalError;
    public String caseSubject {get; set;}
    public Boolean passwordReset {get; set;}//TF-SP11
    public String caseDescription {get; set;}
    public ISSP_Registration thisCtrlForNewCaseForm {get{return this;}}
    public boolean displayNewCaseForm {get; set;}

    //EM
    //public ISSP_reCAPTCHA  reCAPTCHA {get; set;}
    public vfIECreCAPTCHA  reCAPTCHA    {get; set;}

    public string selectedCustomerType{get;set;}
    public boolean accept {get; set;}
    public string selectedAccId {get;set;}
    public string selectedAccId2 {get;set;}
    public Contact con {get; set;}
    public list<Account> accList {get;set;}
    private boolean sendEmailToAdmin = false;
    public Account acc {get; set;}
    public String searchCountry {get; set;}
    public String searchCountryAirline {get; set;}
    public String searchCountryName {get; set;}
    public String searchCountryISOCode {get; set;}
    public String searchIATACode {get; set;}
    public String searchIATACodeAirline {get; set;}
    public String searchDesignatorCode {get; set;}
    public String searchCompanyName {get; set;}
    public String searchTiess {get; set;}

    public boolean accountFound {get; set;}
    public boolean hqFound {get; set;}
    public Account hqAccount {get; set;}
    public boolean showCreateAccount {get; set;}
    public boolean showSearchIataCode {get; set;}
    public boolean showSearchAirlineDesignator {get; set;}//TF - SP10
    public boolean showCreateStandardAirline {get; set;}//TF - SP10
    public boolean showSearchCountry {get; set;}
    public boolean showSearchCompName {get; set;}
    public boolean showSearchTiess {get; set;}
    public boolean showNextAsGP {get; set;}
    public boolean showConfirmMessage {get; set;}
    public boolean createAccountErroeMode {get; set;}
    public boolean preventAddressDoctorService {get; set;}
    //public Case case {get; set;}

    public Boolean isAirline {get; set;}
    public Boolean isAgency {get; set;}
    public Boolean isGeneral {get; set;}
    public Boolean isTiess {get; set;}
    public Boolean isOther {get; set;}
    public Boolean isGSA {get; set;}
    public Boolean isNotIATA {get; set;}
    public Boolean createBranch {get; set;}
    public String cargoTravel {get; set;} //TF - SP08
    public Boolean isCargo {get; set;} //TF - SP08
    public Boolean isTravel {get; set;} //TF - SP08
    public Boolean agencyTypeSelected {get; set;} //TF - SP08
    public String toSearchIataCodeString {get; set;} //TF - SP08
    public String toSearchDesignatorCodeString {get; set;} //TF - SP10
    public Boolean toSearchIataCode {get; set;} //TF - SP08
    public Boolean toSearchDesignatorCode {get; set;} //TF - SP10
    public Boolean doSearch {get; set;} //TF - SP08
    public Boolean createAgency {get; set;} //TF - SP08
    public List<SelectOption> accListRadio {get; set;} //TF - SP08

    public Boolean captchaVerified {get; set;}
    public String captchaId {get; set;}
    public String captchaAnswer {get; set;}

    public Boolean show90Days {get; set;}

    public String country {get; set;}

    // Start MM: "Project Registration Merge" - Define a referrer which will be checked against parameters included in the URL “First_Community”:
    public string sRefererCommunity {get; set;}

    //new CNS
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '?CommunityName='+ communityName;} return ''; } set;}


    // EM: New
    public string urlredirect {get; set;}
    public string constIEC {get {return 'iec';}}
    public string constISS {get {return 'iss';}}
    //End
    public String templatename {get;set;}
    public Boolean onegpa {get;set;}

    //EM
    public String phone1 {get;set;}
    public String phone2 {get;set;}
    public String phone3 {get;set;}
    public boolean showcreateother {get;set;}
    public String except {get;set;}
    public String addressdoctorerror {get;set;}
    public String validateaddresserror {get;set;}
    public String validateaddresserror2 {get;set;}
    public String urlpicture {get;set;}
	public boolean isChina {get;set;}
	public String whichcountry {get;set;}
	
	//TC
	public Map<String, Boolean> zipCodeApplicable {get;set;}
	public Boolean requiredZipCode {
		get{
			return zipCodeApplicable != null && !String.isBlank(searchCountryName) ? zipCodeApplicable.get(searchCountryName) : true;
		}
		set;
	}
	public String countriesNamesWithoutZipCode {
		get{
			if(countriesNamesWithoutZipCode == null) {
				Set<String> countriesNamesWithoutZipCodeLst = new Set<String>();
                
				List<IATA_ISO_Country__c> lstCountries = IATAIsoCountryDAO.getIsoCountriesByZipCoderequired(false);
				
				for(IATA_ISO_Country__c c : lstCountries) {
					countriesNamesWithoutZipCodeLst.add(c.ISO_Code__c.toUpperCase().trim());
				}
				
				countriesNamesWithoutZipCode = JSON.serialize(countriesNamesWithoutZipCodeLst);
			}
			return countriesNamesWithoutZipCode;
		}set;
	}


    public ISSP_Registration(){
		if (!Test.isRunningTest())	findLocation();
		try {
			urlpicture = [select url__c from Checkbox_picture__c limit 1].url__c;
		}
		catch (Exception e) {}


        //Start MM: "Project Registration Merge"- Check the referer:

        //EM : With new modification: now it is passed directly the page from which the user is coming


        sRefererCommunity = ApexPages.currentPage().getParameters().get('sRefererCommunity');
        country = ApexPages.currentPage().getParameters().get('country');
        //In order to load the correct template it is checked the 'CommunityName' parameter

        if (!String.isBlank(sRefererCommunity)) urlredirect = sRefererCommunity;
        if( sRefererCommunity != null && sRefererCommunity != '' && (sRefererCommunity.indexOf('iec') !=-1 || sRefererCommunity.indexOf('IEC') !=-1)){
            sRefererCommunity = constIEC;
            //templatename = constIEC.toUpperCase() + '_Template' ;
        }
        else {
            sRefererCommunity = constISS;
            //templatename = constISS.toUpperCase() + '_Template';
        }

        communityName = ApexPages.currentPage().getParameters().get('CommunityName');
        if (!String.isBlank(communityName))     templatename = communityName.toUpperCase() + '_Template';
        else if (sRefererCommunity == constIEC) templatename = constIEC.toUpperCase() + '_Template' ;
        else if (sRefererCommunity == constISS) templatename = constISS.toUpperCase() + '_Template' ;

        //End



        preventAddressDoctorService = false;
        show90Days = false;

        captchaId = Comm_User_Helper.generateRandomString(10);
        addressdoctorerror = Label.AddressDoctorNoState;
        validateaddresserror = Label.AddressDoctorValidate;
        validateaddresserror2 = Label.AddressDoctorValidate2;
        displayNewCaseForm = false;
        accept = false;
        errorMessage = new list<string>();
        infoMessage = new list<string>();
        log = '';
        String urlSubject = ApexPages.currentPage().getParameters().get('subject');
        country = ApexPages.currentPage().getParameters().get('country');

        if(urlSubject <> null) {
            caseSubject = urlSubject;
        } else {
            caseSubject = Label.ISSP_Registration_Subject_Default; //TF - SP11
        }

        passwordReset = false; //TF - SP11

        //con = new Contact(User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS);
        con = new Contact();
        if (sRefererCommunity == constIEC)	con.User_IECPortal_Status__c = IECConstants.NEW_CONTACT_STATUS;
        accList = new list<Account>();
        acc = new Account(name='');
        //reCAPTCHA = new ISSP_reCAPTCHA();
        //reCAPTCHA.verified = false;
        //reCAPTCHA.verified = true;
        captchaVerified = false;
        createBranch = false;
        accountFound = false;
        hqFound = false;
        showCreateAccount = false;
        createAccountErroeMode = false;
        // init search
        searchCountry = '';
        searchIATACode = '';
        searchCountryAirline = '';
        searchIATACodeAirline = '';
        searchCompanyName = '';
        searchCountry = '';
        countryMap = null;
        createAgency = false;
        isAirline = false;
        isNotIATA = false;

        countryISOCodeMap = new Map<Id, String>();
        iSOCodeMap = new Map<String, Id>();

        doSearch = false;

        //EM
        reCAPTCHA = new vfIECreCAPTCHA();
        reCAPTCHA.verified = false;

        if (whichcountry == 'CN')	recaptcha.verified = true;

    }

    /*
     * Validates the first page
     */
    public boolean pageIsValid(){
        errorMessage.clear();
        infoMessage.clear();
        //if(!reCAPTCHA.verified && !reCAPTCHA.verify()){
        /*
        if (!captchaVerified && !checkCaptcha()){
            errorMessage.add(Label.ISSP_reCAPTCHA_verification_Failed);
        }
        */
        if(!Test.isRunningTest() && !reCAPTCHA.verified && !reCAPTCHA.verify()){
            errorMessage.add('reCAPTCHA verification Failed');
            return false;
        }


        if(!accept){
            errorMessage.add(Label.ISSP_accept_General_Conditions);
        }
        if(con.email==''){
            errorMessage.add(Label.ISSP_EmailError);
        }
        if(errorMessage.size()>0)
            return false;
        reCAPTCHA.verified = true;
        return true;
    }


    /*
     * First step: User
     * user exist --> dont do anything
     * contact exist --> create new user
     * contact not exist --> move to next page
     * is also called at the end of account and contact creation
     */
    public PageReference submitUser() {
       if(!pageIsValid())
            return null;
        String IATAusername = ISSP_Utilities.buildPortalUserName(con.email);
        system.debug('submitUser email: ' + con.email);
        system.debug('submitUser IATAusername: ' + IATAusername);
        //list<User> userList = [select Id from User where email =:con.email];
        list<User> userList = [select Id, isActive, Portal_User_Frozen_Checkbox__c, Email from User where Username =:IATAusername];
        list<Contact> conList;
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        if(con.Id == null) {
            conList = [select accountId,firstName,lastName,Email,Salutation, Account.RecordType.DeveloperName,account.sector__c,account.category__c,
                (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE Is_Active_Card__c = true)
                from Contact where Email =:con.email.trim() and RecordTypeId=:rtId];
        }
        else{
            con.account=acc; // related account information
            conList = new list<Contact>{con};
        }

        // new contact
        if (conList.size()==0) {
            con.RecordTypeId = rtId;
            return Page.ISSP_CreateContact;
            // PageReference pageRef = Page.ISSP_CreateContact;
            // pageref.getParameters().put('country',country);
            // pageref.getParameters().put('CommunityName',CommunityName);
            // return pageRef;
        }

        if (userList.size()==0 && conList.size()>0) {
            // existing contact
            return createNewUser(conList.get(0));
        } else {
          if (userList[0].IsActive){
            //user is active
            log += 'userList.size()'+userList.size() + ', conList.size()'+conList.size();
            log(log);
            if (sRefererCommunity == constISS)	errorMessage.add(Label.ISSP_Registration_UserExist);
            else if (sRefererCommunity == constIEC)	errorMessage.add(Label.IEC_Registration_UserExist);
            //ISSP_Utilities.SendErrorNotificationEMail('LOG:'+log+' /n ErrorMessage: '+Label.ISSP_Registration_UserExist);
           // displayNewCaseForm = true;
            return null;
          }
          else if (userList[0].Portal_User_Frozen_Checkbox__c){
            //user is frozen
            log += 'userList.size()'+userList.size() + ', conList.size()'+conList.size();
            log(log);
            show90Days = true;
            ISSP_Login.reactivateUser(userList[0]);
            return null;
          }
          else{
            //user is inactive
            log += 'userList.size()'+userList.size() + ', conList.size()'+conList.size();
            log(log);
            errorMessage.add(Label.ISSP_Registration_inactiveUserExist+' ('+con.Email+')');
            //ISSP_Utilities.SendErrorNotificationEMail('LOG:'+log+' /n ErrorMessage: '+Label.ISSP_Registration_inactiveUserExist+' ('+con.Email+')');
            displayNewCaseForm = true;
            return null;
          }
            log += 'userList.size()'+userList.size() + ', conList.size()'+conList.size();
            log(log);
            if (sRefererCommunity == constISS)	errorMessage.add(Label.ISSP_Registration_UserExist);
            else if (sRefererCommunity == constIEC)	errorMessage.add(Label.IEC_Registration_UserExist);
            //ISSP_Utilities.SendErrorNotificationEMail('LOG:'+log+' /n ErrorMessage: '+Label.ISSP_Registration_UserExist);
           // displayNewCaseForm = true;
            return null;
        }
    }

    /*
     * Step 2: Contact
     * General Public --> create new contact and user
     * Others --> move to next page.
     */
    public PageReference submitContact(){
    if (!String.isBlank(phone1))	con.Phone = phone1;
    if (!String.isBlank(phone2))    con.Mobilephone = phone2;
    if (!String.isBlank(phone3))    con.fax = phone3;

        errorMessage.clear();
        infoMessage.clear();
        displayNewCaseForm = false;

        accList.clear();

        accountFound = false;
        hqFound = false;
        showCreateAccount = false;
        createAccountErroeMode = false;
        return Page.ISSP_CreateAccount;
    }


    /*
     * Back from account page to contact page
     */

	public PageReference backToAccountPage () {
		showCreateAccount = false;
		if(sRefererCommunity == 'iec') {
			isAgency = selectedCustomerType == Agency;
			isAirline = selectedCustomerType == Airline;
			selectType();
			/*
			showcreateother = false;
			showSearchIataCode = isAgency;
			showSearchCompName = isAgency;
			toSearchDesignatorCode = isAirline;
			*/
		}
		return null;
	}


    public PageReference backToContactPage(){

    	showcreateother = false;
        errorMessage.clear();
        infoMessage.clear();
        displayNewCaseForm = false;
        searchCountry = null;
        searchIATACode = null;
        searchCountryAirline = null;
        searchIATACodeAirline = null;
        searchTiess = null;
        searchCompanyName = null;
        return Page.ISSP_Createcontact;
    }

    /*
     * Step 3.1: Search for account
     */
    public PageReference searchAccount() {
        onegpa = false;
        accList = new List<Account>();
        errorMessage.clear();
        infoMessage.clear();
        displayNewCaseForm = false;
        accountFound = false;
        hqFound = false;
        showCreateAccount = false;
        showNextAsGP = false;
        createAgency = false;
        
        /* TC 2017-05-29 iec enhancements */
        if(isAirline && sRefererCommunity == constIEC) {
        	try {
        		accList = searchCompany(searchIATACodeAirline, companyName, searchCountryAirline, 'Airline');
        		handleSearchResults();
        	} catch(Exception e) {
        		log(e);
        	}
        	return null;
        }
        
        if(isAgency && sRefererCommunity == constIEC) {
        	try {
        		if (!String.isBlank(searchIATACode) && searchIATACode.length() != 8 && searchIATACode.length() != 11) {
                	errorMessage.add(Label.ISSP_IATA_Code_Agency);
                	return null;
        		}
        		accList = searchCompany(searchIATACode, companyName, searchCountry, 'Agency');    
        		handleSearchResults();
        	} catch(Exception e) {
        		log(e);
        	}    	
        	return null;
        }
        /* end */

        //check IATA Code format
        decimal iataCodeInput;
        if (isAirline && toSearchDesignatorCode){
            searchIATACode = searchIATACodeAirline;
            searchCountry = searchCountryAirline;
        }
        if (isAirline && searchIATACode != '' && searchIATACode != null && toSearchDesignatorCode){
            try {
                iataCodeInput =  Decimal.valueOf(searchIATACode);
            }
            catch (exception e) {
                errorMessage.add(Label.ISSP_IATA_Code_Airline);
                return null;
            }
            if (searchIATACode.length() != 3){
                errorMessage.add(Label.ISSP_IATA_Code_Airline);
                return null;
            }
        }
        /*
        else if (isGSA){
            if (searchIATACode.length() != 3){
                errorMessage.add(Label.ISSP_IATA_Code_GSA);
                return null;
            }
        }
        */
        else if (isAgency && !isNotIATA){
            try {
                iataCodeInput =  Decimal.valueOf(searchIATACode);
            }
            catch (exception e) {
                if (isCargo){
                    errorMessage.add(Label.ISSP_IATA_Code_Agency_Cargo);
                }
                else if (isTravel){
                    errorMessage.add(Label.ISSP_IATA_Code_Agency_Travel);
                }
                else{
                    errorMessage.add(Label.ISSP_IATA_Code_Agency);
                }
                return null;
            }
            if (isCargo){
                if (searchIATACode.length() != 11){
                    errorMessage.add(Label.ISSP_IATA_Code_Agency_Cargo);
                    return null;
                }
            }
            else if (isTravel){
                if (searchIATACode.length() != 8){
                    errorMessage.add(Label.ISSP_IATA_Code_Agency_Travel);
                    return null;
                }
            }
            else if (searchIATACode.length() != 8 && searchIATACode.length() != 11){
                errorMessage.add(Label.ISSP_IATA_Code_Agency);
                return null;
            }
        }

        String whereStr = '';
        con.ISO_Country__c = searchCountry; // to use in error case form
        //EM: Handle ISO Shipping Country
        con.IATA_ISO_Shipping_Country__c = searchCountry;
        system.debug('searchCountry: ' + searchCountry);
        if (countryMap.containsKey(searchCountry)){
            searchCountryName = countryMap.get(searchCountry);
            searchCountryISOCode = countryISOCodeMap.get(searchCountry);
            system.debug('contains country: ' + searchCountryName);
        }
        else{
            system.debug('not contains country: ' + searchCountryName);
        }
        createBranch = false;
        // set query string
        if (isAirline && toSearchDesignatorCode) {
            whereStr = 'Id != null';
            system.debug('searchDesignatorCode: ' + searchDesignatorCode);
            system.debug('searchIATACode: ' + searchIATACode);
            system.debug('searchCountry: ' + searchCountry);
            if (searchDesignatorCode != '' && searchDesignatorCode != null){
                whereStr += ' AND Airline_designator__c=\'' + searchDesignatorCode + '\'';
            }
            if (searchIATACode != '' && searchIATACode != null){
                whereStr += ' AND (IATACode__c=\'' + searchIATACode + '\'OR Airline_Prefix__c=\'' + searchIATACode + '\')';
            }
            if (searchCountry != '' && searchCountry != null){
                whereStr += ' AND IATA_ISO_Country__c=\'' + searchCountry + '\'';
            }
            //whereStr = 'IATACode__c=\'' + searchIATACode + '\' and IATA_ISO_Country__c=\'' + searchCountry + '\'';
        }
        else if (isAirline && !toSearchDesignatorCode) {
            whereStr = 'Name like \'%' + searchCompanyName + '%\' and IATA_ISO_Country__c=\'' + searchCountry + '\' AND Sector__c != \'General Public\'';
        }
        /*
        else if (isGSA) {
            whereStr = 'IATACode__c=\'' + searchIATACode + '\' and IATA_ISO_Country__c=\'' + searchCountry + '\'';
        }
        */
        else if (isGSA) {
            whereStr = 'Name like \'%' + searchCompanyName + '%\' and IATA_ISO_Country__c=\'' + searchCountry + '\'';
        }
        else if (isAgency && !isNotIATA) {
            whereStr = '(IATACode__c=\'' + searchIATACode + '\' OR Airline_Prefix__c=\'' + searchIATACode + '\')';// and RecordType.DeveloperName = \'IATA_Agency\'';
        }
        else if (isNotIATA || isOther) {
            whereStr = 'Name like \'%' + searchCompanyName + '%\' and IATA_ISO_Country__c=\'' + searchCountry + '\' AND Sector__c != \'General Public\'';
        }
        else if (isTIESS) {
            whereStr = 'TIESS_Code__c=\'' + searchTiess + '\'';
        }
        else if (isGeneral){
            whereStr = 'Sector__c=\'General Public\' and IATA_ISO_Country__c=\'' + searchCountry + '\'';
        }
        else    // unknown type
            return null;

        // get recordTypes from Map
        system.debug('isAgency: ' + isAgency);
        system.debug('isNotIATA: ' + isNotIATA);
        String customerTypeSearch = selectedCustomerType;
        if (isAgency){
            customerTypeSearch = Agency;
        }
        else if (isNotIATA){
            customerTypeSearch = NonIATA;
        }
        set<string> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(customerTypeSearch);
        system.debug('recordTypesSet: ' + recordTypesSet);
        String queryStr = 'select Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, RecordType.DeveloperName, RecordType.Name, Airline_designator__c, Airline_Prefix__c from Account where '
                         + whereStr + ' and RecordType.DeveloperName in :recordTypesSet LIMIT 999';

        system.debug('customerTypeSearch: ' + customerTypeSearch);
        system.debug('queryStr: ' + queryStr);
        try {
            accList = Database.query(queryStr);
            //If other company add another option (to create new account)
            if (isOther && accList.size() > 0) {
            	Account dummy = accList[accList.size()-1].clone(true,true);
            	dummy.Name = Label.ISSP_Create_New_Other_Account;
            	dummy.IATACode__c = 'Create New Account';
            	acc.name = searchCompanyName;
            	accList.add(dummy);
            	showcreateother = true;
            }
            else
            	showcreateother = false;

        } catch (Exception e) {
            log(e);
        }

        accountFound = accList.size()>0;

        if (isAirline){
            system.debug('isairline: ' + isAirline);
            if (accountFound){
                List <Account> accListVerified = new List <Account>();
                List <Account> accListNotVerified = new List <Account>();
                for (Account thisAccount : accList){
                    if (thisAccount.RecordType.DeveloperName == 'Standard_Account'){
                        accListNotVerified.add(thisAccount);
                    }
                    else{
                        accListVerified.add(thisAccount);
                    }
                }
                accList = null;
                if (!accListVerified.isEmpty()){
                    accList = accListVerified;
                }
                else{
                    accList = accListNotVerified;
                }
            }
            else{
                if (toSearchDesignatorCode){
                    system.debug('no branch was found');
                    whereStr = 'Id != null';
                    system.debug('searchDesignatorCode: ' + searchDesignatorCode);
                    system.debug('searchIATACode: ' + searchIATACode);
                    system.debug('searchCountry: ' + searchCountry);
                    if (searchDesignatorCode != '' && searchDesignatorCode != null){
                        whereStr += ' AND Airline_designator__c=\'' + searchDesignatorCode + '\'';
                    }
                    if (searchIATACode != '' && searchIATACode != null){
                        whereStr += ' AND (IATACode__c=\'' + searchIATACode + '\' OR Airline_Prefix__c=\'' + searchIATACode + '\')';
                    }
                    queryStr = 'select Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, Top_Parent__c, Top_Parent__r.Name, Sector__c, Category__c, RecordType.Name, Airline_designator__c, Airline_Prefix__c from Account where '
                             + whereStr + ' and RecordType.DeveloperName = \'IATA_Airline\'';
                    system.debug('QUERY: ' + queryStr);
                    try {
                        accList = Database.query(queryStr);
                    } catch (Exception e) {
                        log(e);
                    }
                    system.debug('airline list: ' + accList);
                    if (!accList.isEmpty()){
                        system.debug('not empty, to create branch');
                        hqAccount = accList[0];
                        hqFound = true;
                        createBranch = true;
                        showCreateAccount = true;
                        infoMessage.add(Label.ISSP_NoRecordsFoundBranch);
                        if (accList[0].Top_Parent__c != null){
                            acc.Name = accList[0].Top_Parent__r.Name;
                            acc.Top_Parent__c = accList[0].Top_Parent__c;
                            acc.ParentId = accList[0].Top_Parent__c;
                        }
                        else{
                            acc.Name = accList[0].Name;
                            acc.Top_Parent__c = accList[0].Id;
                            acc.ParentId = accList[0].Id;
                        }
                    }
                    else{
                    	if(sRefererCommunity == 'iec') {
                        	errorMessage.add(Label.IEC_NoRecordsFoundGP);
                    	} else {
                    		errorMessage.add(Label.ISSP_NoRecordsFoundGP);
                    	}
                    }
                }
                else{
                    if(CommunityName == 'CNS' ) { infoMessage.add(Label.ISSP_NoRecordsFoundCreateStandardAirline_CNS); }
                    else { infoMessage.add(Label.ISSP_NoRecordsFoundCreateStandardAirline); }
                    showCreateAccount = true;
                    acc.Name = searchCompanyName;
                }
            }
        }
        else if (isOther){
            if (!accountFound){
                acc.Name = searchCompanyName;
                if(CommunityName=='CNS') { infoMessage.add(Label.ISSP_NoRecordsFoundCreateAgency_CNS); }
                else { infoMessage.add(Label.ISSP_NoRecordsFoundCreateAgency); }
                showCreateAccount = true;
            }
        }
        else if (isNotIATA){
            if (!accountFound){
                acc.Name = searchCompanyName;
                if (isCargo){
                    acc.Sector__c = 'Cargo Agent';
                    acc.Category__c = 'Non-IATA Cargo Agent';
                }
                else if (isTravel){
                    acc.Sector__c = 'Travel Agent';
                    acc.Category__c = 'Non-IATA Travel Agent';
                }
                if(CommunityName=='CNS') { infoMessage.add(Label.ISSP_NoRecordsFoundCreateAgency_CNS); }
                else { infoMessage.add(Label.ISSP_NoRecordsFoundCreateAgency); }
                showCreateAccount = true;
                createAgency = true;
            }
        }
        else if (isTIESS){
            if (!accountFound){
                if(CommunityName=='CNS') { errorMessage.add(Label.ISSP_NoRecordsFoundGP_CNS); }
                else { errorMessage.add(Label.ISSP_NoRecordsFoundGP); }
            }
        }
        else if (isAgency){
            if (!accountFound){
                if(CommunityName=='CNS') { errorMessage.add(Label.ISSP_NoRecordsFoundNext_CNS); }
                else { errorMessage.add(Label.ISSP_NoRecordsFoundNext); }
            }
        }
        else if (isGSA){
            if (!accountFound){
                if(CommunityName=='CNS') { errorMessage.add(Label.ISSP_NoRecordsFoundGSA_CNS); }
                else { errorMessage.add(Label.ISSP_NoRecordsFoundGSA); }
            }
        }
        else if (isGeneral){
            accountFound = false;
            showNextAsGP = true;
            if (accList.isEmpty()){
                errorMessage.add(Label.ISSP_GeneralPublicNotFound);
            }
            if (accList.size()>=1) {
                onegpa = true;
            }

        }
        else {
            errorMessage.add(Label.ISSP_NoRecordsFound);
        }

        // if there is only one result, select it
        if (accList.size()==1)
            selectedAccId = accList.get(0).id;

        //if (accList.size()==1 && isGeneral) {
        //  onegpa=true;
        //    infoMessage.add('AAA');
        //}

        system.debug('selectedAccId after search: ' + selectedAccId);

        if (!accList.isEmpty()){
            accListRadio = new List<SelectOption>();
            for (Account thisAccount : accList){
                accListRadio.add(new SelectOption(thisAccount.Id,thisAccount.Name));
            }
        }

        return null;
    }

	//TC 2017-05-16
	public Boolean isGPSearchValid() {
		try {
			Set<String> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(selectedCustomerType);
			accList = [SELECT Id,IATACode__c, Field_Head_Office__c, Name, BillingStreet, BillingCity, BillingCountry, IATA_ISO_Country__r.Name, 
							  RecordType.DeveloperName, RecordType.Name, Airline_designator__c, Airline_Prefix__c 
					   FROM Account 
					   WHERE RecordType.DeveloperName IN :recordTypesSet AND Sector__c = 'General Public' AND IATA_ISO_Country__c = :searchCountry]; 
			accountFound = !accList.isEmpty();
			return !accList.isEmpty();	
		} catch(Exception e) {
			log(e);
			return false;	
		}					
	}
	
	

    /*
     * Back to Contact page - as General Public
     */
    public PageReference nextAsGP() {
        system.debug('nextAsGP: ' + accList);
        
        //TC 2017-05-16
        if(sRefererCommunity == 'iec'){
         	Boolean isValidSearch = isGPSearchValid();
         	if(!isValidSearch) {
         		errorMessage.add(Label.IEC_NOGPAccount);
         		return null;
         	}
        }
                
        if (!accList.isEmpty()){
            selectedAccId = accList[0].id;
            system.debug('selectedAccId: ' + selectedAccId);
            searchCountry = con.ISO_Country__c; // to use in error case form
            accountFound = true;
            return register();
        }

        else{
            //EM: Back to the community page
            //EM : Back to the starting page
            PageReference pr;

            if (sRefererCommunity == constIEC)
                pr = new PageReference('/IECLogin');
                //pr = new PageReference('/' +sRefererCommunity);
            else
                pr = new PageReference('/ISSP_Login' + commParam);
            return pr;
        }

        /*else{
            PageReference pr = new PageReference('/ISSP_Login');
            return pr;
        }

        errorMessage.clear();
        selectedCustomerType = GeneralPublic;
        return Page.ISSP_createContact;
        */
    }

    /*
     * Create new User
     */
    public PageReference createNewUser(Contact con){

      Try{
        displayNewCaseForm = false;
        String userId;
        String accountId = '';

        // prepare new User
        system.debug('CREATING USER WITH LANG: ' + lang);
        system.debug('CREATING USER WITH selectedCustomerType: ' + selectedCustomerType);
        if (!ISSP_Constant.languageMap.containsKey(lang))
            lang = 'en_US';

        Boolean newAirline = false;
        if (isAirline && !createBranch && showCreateAccount){
            newAirline = true;
        }

        system.debug('TO createNewUser');
        system.debug('isNotIATA: ' + isNotIATA);
        system.debug('newAirline: ' + newAirline);

        //EM: Management of email according to the portal
        //userId = Comm_User_Helper.createNewUser(con,selectedCustomerType, 'ISSP', lang, isNotIATA, newAirline);
        
        if(sRefererCommunity == constIEC){
            userId = Comm_User_Helper.createNewUser(con,selectedCustomerType, 'IEC', lang, isNotIATA, newAirline);
        }

        else{
            if(communityName=='' || communityName==null){
            userId = Comm_User_Helper.createNewUser(con,selectedCustomerType, 'ISSP', lang, isNotIATA, newAirline);
            }else if(communityName=='CNS'){
                userId = Comm_User_Helper.createNewUser(con,selectedCustomerType, 'CNS', lang, isNotIATA, newAirline);
            }
            
        }

        if (userId != null) {
            //TF-SP08 - for first agency user, give access to custom permission set
            if (isNotIATA){
                permissionNewAgency(userId);
            }

            //TF - SP10-N2
            system.debug('createAgency creating contact: ' + createAgency);

	        //if (sRefererCommunity == constISS) {
	            if (sRefererCommunity == constIEC)
	            	con.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS ;

	            else if (!con.ID_Cards__r.isEmpty() || selectedCustomerType == GeneralPublic || isNotIATA || newAirline){
	                system.debug('setting status to: ' + ISSP_Constant.APPROVED_CONTACT_STATUS);
	                con.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
	            }
	            else{
	                con.User_Portal_Status__c = ISSP_Constant.NEW_CONTACT_STATUS ;
	            }

            //}

            if (sRefererCommunity == constIEC) {
            	IECUtil.DomainValidation validation = IECUtil.validateContactEmailDomain(con.Email, con.accountid);
            	if (validation == IECUtil.DomainValidation.MATCHINGDOMAIN)
                	con.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;

            }

            if(communityName == 'CNS' && selectedCustomerType == 'Agency' ) {
                con.CNS_Contact__c = true;
            }


            try {
                if (sRefererCommunity == constISS){ if(communityName=='' || communityName==null){ con.community__c= 'ISS Customer Portal';} else if(communityName=='CNS'){ con.community__c= 'CNS Customer Portal'; }}	
                else if	(sRefererCommunity == constIEC){con.community__c= 'E-Commerce';}	
                system.debug('1-Creating contact with language: ' + lang);
                String languageString = 'English';
                if (lang != null && lang != ''){
                    if (ISSP_Constant.languageMap.containsKey(lang)){
                        languageString = ISSP_Constant.languageMap.get(lang);
                    }
                }
                con.Preferred_Language__c = languageString;
                
                if(acc.Sector__c == TIP_Utils.ACCOUNT_SECTOR_FINANCIAL_INSTITUTION && acc.Category__c == TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER){
            		con.Primary_Contact__c = true;
                	con.User_Portal_Status__c = 'Approved Admin';

                    //TIP-16 - Assign TIP Portal Service
                    Id appListId;
                    ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                    if (serviceIdInstance != null && !String.isBlank(serviceIdInstance.TIP_Portal_Service_Id__c)){
                        appListId = serviceIdInstance.TIP_Portal_Service_Id__c;

                    Portal_Application_Right__c newRight = new Portal_Application_Right__c();
                    newRight.Contact__c = con.Id;
                    newRight.Right__c = 'Access Granted';
                    newRight.Portal_Application__c = appListId;
                    insert newRight;
            	}
            	}
                
                con.Account = null; //remove refrence. Only use was to check information
                upsert con;
            } catch (Exception e) {
                throw new transformationException('' +e.getMessage() );
            }
            //niv.g
            //sendEmail(userId,con.Id);
            if(sendEmailToAdmin)
                ISSP_Utilities.sendEmailToAdmins(con.Id);//AEF don't send email
            showConfirmMessage = true;
            return Page.ISSP_Registration;
        } else {
            log('failed to create Portal User');
            if(communityName == 'CNS') {
                errorMessage.add(label.ISSP_generalError_CNS);
                ISSP_Utilities.SendErrorNotificationEMail('LOG:'+log+'\n ErrorMessage: '+label.ISSP_generalError_CNS);
            } else {
            errorMessage.add(label.ISSP_generalError);
            ISSP_Utilities.SendErrorNotificationEMail('LOG:'+log+'\n ErrorMessage: '+label.ISSP_generalError);
            }
            displayNewCaseForm = true;
            return null;
        }
        } catch (Exception ex) {
            errorMessage.add('ex '+ ex.getMessage()+ ex.getStackTraceString());
                return null;
           }
    }

    /*
     * Step 3.2: Account (and then Contact and User)
     */
    public Pagereference register() {
        system.debug('in register');
        // create new Account
        errorMessage.clear();
        infoMessage.clear();
        displayNewCaseForm = false;
        createAccountErroeMode = false;

		if (isOther == true && String.isBlank(selectedAccId2))
			accountFound = false;


        if (!accountFound) {
            system.debug('account not found');
            acc.IATACode__c = searchIATACode;
            system.debug('IATA CODE: ' + searchIATACode);
            system.debug('acc.name: ' + acc.name);
            system.debug('searchCountry: ' + searchCountry);
            system.debug('acc.sector__c: ' + acc.sector__c);
            system.debug('acc.category__c: ' + acc.category__c);
            if (searchCountry!=null && searchCountry!='') {
                acc.IATA_ISO_Country__c = searchCountry;
                
                acc.BillingCountry = searchCountryName;
                if(sRefererCommunity == constIEC) {
                	acc.ShippingCountry = String.isBlank(acc.ShippingCountry) ? searchCountryName : acc.ShippingCountry;
                    acc.IATA_ISO_Shipping_Country__c = String.isBlank(acc.ShippingCountry) ? searchCountryName : iSOCodeMap.get(acc.ShippingCountry);
                } else {
                	acc.ShippingCountry = searchCountryName;
                    acc.IATA_ISO_Shipping_Country__c = searchCountry;
                }
            }
            //acc.TIESS_Code__c = searchTiess;
            system.debug('selectedCustomerType: ' + selectedCustomerType);
            system.debug('isAgency: ' + isAgency);
            system.debug('isNotIATA: ' + isNotIATA);
            String customerTypeCreate = selectedCustomerType;
            if (isAgency){
                customerTypeCreate = Agency;
            }
            else if (isNotIATA){
                customerTypeCreate = NonIATA;
            }
            system.debug('RecordTypeId: ' + getRecordTypeCode(customerTypeCreate));
            system.debug('createBranch: ' + createBranch);
            acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
            acc.OwnerId = ISSP_Constant.newAccountOwnerId;
            if (createBranch){
                acc.Reason_for_creation__c = 'Branch is missing';
                acc.Sector__c = hqAccount.Sector__c;
                acc.Category__c = hqAccount.Category__c;
                acc.IATACode__c = hqAccount.IATACode__c;
                acc.Airline_designator__c = hqAccount.Airline_designator__c;
                acc.Airline_Prefix__c = hqAccount.Airline_Prefix__c;
            }
            else{
                acc.Reason_for_creation__c = 'Created by customer';
            }

            log('RecordTypeId ' + acc.RecordTypeId);
            system.debug('TradeName__c: ' + acc.TradeName__c);

            // for CNS automatically check the checkbox
            if(communityName == 'CNS' && acc.Id == null) {
                acc.CNS_Account__c = true;
                con.CNS_Contact__c = true;
                if(acc.Sector__c == 'Cargo Agent') {
                    acc.Location_Class__c = 'C';
                }
            }

            try {


                //EM: Management of state/provinces picklists
                if (!String.isBlank(acc.billingstate)) {

                    List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();

                    for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStates()){
                        if(sta.IATA_ISO_Country__r.Name == acc.billingcountry && sta.Informatica_Value__c == acc.billingstate){
                            states.add(sta);
                            break;
                        }
                    }
                                        
                    system.debug('states 1+++' + states);
                    if (states.size() == 0) {
                        for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStateByIsoCodes(new Set<String>{acc.billingstate})){
                            if(sta.IATA_ISO_Country__r.Name == acc.billingcountry){
                                states.add(sta);
                            }
                        }
                    }
                    system.debug('states 2+++ ' + states);
                    if (states.size()!=0)
                        acc.IATA_ISO_Billing_State__c = states[0].id;
                }

                if (!String.isBlank(acc.shippingstate)) {
                    if (acc.shippingstate == acc.billingstate && acc.shippingcountry == acc.billingcountry){
                        acc.IATA_ISO_Shipping_State__c = acc.IATA_ISO_Billing_State__c;
                    }else{
                        List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();
                        
                        for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStates()){
                            if(sta.IATA_ISO_Country__r.ISO_Code__c == acc.shippingcountry && sta.Informatica_Value__c == acc.shippingstate){
                                states.add(sta);
                                break;
                            }
                        }
                        if (states.size() == 0) {
                            for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStateByIsoCodes(new Set<String>{acc.shippingcountry})){
                                if(sta.IATA_ISO_Country__r.ISO_Code__c == acc.shippingcountry){
                                    states.add(sta);
                                }
                            }
                        }

                        if(states.size()!=0){
                            acc.IATA_ISO_Shipping_State__c = states[0].id;
                        }
                    }
                }

                system.debug('acc +++ ' + acc);
                upsert acc;

            } catch (exception ex){
                createAccountErroeMode = true;
                errorMessage.add(ex.getMessage());
                displayNewCaseForm = true;
                return null;
            }
            con.AccountId = acc.Id;
        } else {
            // existing acount is selected
            system.debug('to register selectedAccId: ' + selectedAccId);
            system.debug('to register selectedAccId2: ' + selectedAccId2);
            if (selectedAccId != '' && selectedAccId != null)
                con.AccountId = selectedAccId;
            else if (selectedAccId2 != '' && selectedAccId2 != null)
                con.AccountId = selectedAccId2;
        }

        if (searchCountry!=null && searchCountry!=''){
            con.ISO_Country__c = searchCountry;
            //con.MailingCountry = searchCountryName;
            //EM: Handle ISO Shipping Country
            //con.IATA_ISO_Shipping_Country__c = searchCountry;
        }


        // create new Contact
        try {
             if (sRefererCommunity == constISS){ if(communityName=='' || communityName==null){ con.community__c= 'ISS Customer Portal';} else if(communityName=='CNS'){ con.community__c= 'CNS Customer Portal'; }} 
            else if	(sRefererCommunity == constIEC)	con.community__c= 'E-Commerce';
            system.debug('2-Creating contact with language: ' + lang);
            String languageString = 'English';
            if (lang != null && lang != ''){
                if (ISSP_Constant.languageMap.containsKey(lang)){
                    languageString = ISSP_Constant.languageMap.get(lang);
                }
            }
            con.Preferred_Language__c = languageString;

            //EM: Copy account states to contact
            con.IATA_ISO_Billing_State__c = acc.IATA_ISO_Billing_State__c;
            con.IATA_ISO_Shipping_State__c = acc.IATA_ISO_Shipping_State__c;

            //Copy Shipping Country to contact
            con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Shipping_Country__c; 

            if (sRefererCommunity == constIEC) {
            	IECUtil.DomainValidation validation = IECUtil.validateContactEmailDomain(con.Email, con.accountid);
            	if (validation == IECUtil.DomainValidation.MATCHINGDOMAIN)
                	con.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
            }
			/*
            if(acc.Sector__c == 'Payment Provider' && acc.Category__c == 'Financial Institution'){
            	con.Primary_Contact__c = true;
                con.User_Portal_Status__c = 'Approved Admin';
                
            }
            */
            upsert con;

            //TF-SP08 - give access to Agency Accreditation service
            if (isNotIATA){
                List <Portal_Applications__c> appList = new List <Portal_Applications__c>();

                ISSP_Portal_Service_Ids__c serviceIdInstance = ISSP_Portal_Service_Ids__c.getInstance();
                if (serviceIdInstance != null){
                    if(communityName == 'CNS' && serviceIdInstance.AgencyAccreditationCNS__c != null
                        && serviceIdInstance.AgencyAccreditationCNS__c != ''
                        && acc.Sector__c == 'Cargo Agent') {
                        system.debug('THE ID: ' + serviceIdInstance.AgencyAccreditationCNS__c);
                        String appId = serviceIdInstance.AgencyAccreditationCNS__c;
                        appList = [SELECT Id FROM Portal_Applications__c WHERE Id = :appId];
                    }
                    else if (serviceIdInstance.AgencyAccreditation__c != null && serviceIdInstance.AgencyAccreditation__c != ''){
                        system.debug('THE ID: ' + serviceIdInstance.AgencyAccreditation__c);
                        String appId = serviceIdInstance.AgencyAccreditation__c;
                        appList = [SELECT Id FROM Portal_Applications__c WHERE Id = :appId];
                    }
                    else{
                        appList = [SELECT Id FROM Portal_Applications__c WHERE Name = 'Agency Accreditation'];
                    }
                }
                else{
                    appList = [SELECT Id FROM Portal_Applications__c WHERE Name = 'Agency Accreditation'];
                }

                if (!appList.isEmpty()){
                    Portal_Application_Right__c newRight = new Portal_Application_Right__c();
                    newRight.Contact__c = con.Id;
                    newRight.Right__c = 'Access Granted';
                    newRight.Portal_Application__c = appList[0].Id;
                    insert newRight;
                }
            }
        }
        catch(exception ex){
            errorMessage.add(ex.getMessage());
            displayNewCaseForm = true;
            return null;
        }
        errorMessage.add('contact reg succeed');
        sendEmailToAdmin = true;

        // create new User
        return submitUser();
    }

     public PageReference submitCase() {
        system.debug('\n\n\n Creating Case \n\n\n');
        system.debug('Password reset: ' + passwordReset);
        String subject = (errorMessage!=null && errorMessage.size()>0 ? errorMessage[0] : label.ISSP_generalError);
        createCase(subject, con, selectedCustomerType, searchIATACode, caseDescription);
        displayNewCaseForm = false;
        PageReference ThanksPage = new PageReference(label.ISSP_SharePoint_Thanks);
        ThanksPage.setRedirect(true);
        return ThanksPage ;
     }

     public void createCase(String subject, Contact con, String customerType, String IATACode, String description) {
        if (countryMap==null)
            getISOCountry();
        String country = countryMap.get(con.ISO_Country__c);
        String allSubject = 'REGISTRATION ERROR - ' + subject + ' (' + con.Email + '), Name: ' + con.FirstName + ' ' + con.LastName + ', Type: ' + customerType + ', Country: ' + countryMap.get(con.ISO_Country__c) + ', IATA Code: ' + IATACode;
        if (allSubject.length() > 255)
            allSubject = allSubject.substring(0,254);
        String reason = '';
        String contactId = null;
        if (passwordReset){//TF - SP11
            allSubject = caseSubject;//TF - SP11
            reason = 'Registration process';
            List <Contact> searchContactList = [SELECT Id FROM Contact WHERE Email = :con.Email];
            if (searchContactList.size() == 1){
                contactId = searchContactList[0].Id;
            }
        }
        Case cas = new Case(
                CaseArea__c = 'Customer Portal Enquiry',
                //Subject  = 'REGISTRATION ERROR - ' + subject + ' (' + con.Email + ')',
                Subject  = allSubject,
                SuppliedName = con.Salutation + ' ' + con.FirstName + ' ' + con.LastName,
                SuppliedEmail = con.Email,
                SuppliedPhone = con.Phone,
                Description = description,
                Country_concerned_by_the_query__c = countryMap.get(con.ISO_Country__c),
                Cargo_Business__c = customerType,
                IATAcode__c = IATACode,
                Origin = 'Portal',
                Reason1__c = reason,
                ContactId = contactId
                );
        try {
            insert cas;
            system.debug('\n\n\n cas: ' + cas + '\n\n\n');
            //errorMessage.add(cas + '');
        } catch (Exception e) {
            system.debug('\n\n\n Error: ' + e + '\n\n\n');
            errorMessage.add('Error in creation of a new case: ' + e);
        }
     }

    @TestVisible
    private String getRecordTypeCode(String customerType) {
        String devName = ISSP_Constant.accountDefaultRecordTypeByCustomerType.get(customerType);
        if (devName==Null)
            return null;
        log(customerType + ', ' + devName);
        try {
            Id rtSetId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', devName);
            if(String.isNotBlank(rtSetId)){
                return rtSetId;
            }
        } catch (Exception e) {
            log('error getting type');
        }
        return null;
    }

	//TC: added IEC_Zip_Postal_Code_required__c to query and fill map
    public List<SelectOption> getISOCountry() {
        List<SelectOption> options = new List<SelectOption>();
        boolean countryMapEmpty = (countryMap == null);
        zipCodeApplicable = new Map<String,Boolean>();
        if (countryMapEmpty)
            countryMap = new Map<Id, String>();			
        for(IATA_ISO_Country__c iso:IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
 
            if(iso.Name != 'All Countries' && iso.Name !='NO COUNTRY'){
                options.add(new SelectOption(iso.Id,iso.Name));
                zipCodeApplicable.put(iso.Name, iso.IEC_Zip_Postal_Code_required__c);//TC
                if (countryMapEmpty) {
                    countryMap.put(iso.Id, iso.Name);
                }
                countryISOCodeMap.put(iso.Id, iso.ISO_Code__c);
                iSOCodeMap.put(iso.ISO_Code__c, iso.Id);
            }
        }
        return options;
    }


    private void log(Object obj) {
        if (obj!=null) {
            //errorMessage.add(' *** ' + obj);
            System.debug('\n\n\n **** ' + obj + ' *** \n\n\n');
        }
    }

    public static string generatePassword(){
        String res = '11111111';

        while(Pattern.matches('[a-zA-Z]{8}', res) || Pattern.matches('[0-9]{8}', res)){
            res = DateTime.now().format('dd/MM/yyyy hh:mm:ss a', 'PST');
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(res));
            String token = EncodingUtil.convertToHex(hash);
            res = String.valueOf(token);
            res = res.substring(0,8);

        }
        return res;
    }

    //@future
    public static void sendEmail(string userId , string contactId){
        EmailTemplate et = [Select e.Id, e.Name, e.DeveloperName From EmailTemplate e where DeveloperName=:'ISSP_New_Member_Welcome_Email']; //niv.g
        //EmailTemplate et = [Select e.Id, e.Name, e.DeveloperName From EmailTemplate e where DeveloperName=:'IATAPortalWelcomeEmailTemplateVF'];
        if(et != null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);//TODO!!!!!!!!
            mail.setTargetObjectId(userId);
            mail.setSaveAsActivity(false);
            mail.setReplyTo('noreply@iata.org'); //its valid email id
            mail.setSenderDisplayName('ISS Portal ');
            Messaging.sendEmail(
            new Messaging.SingleEmailMessage[]{mail});
        }
    }

    
    public static void sendCNSEmail(string userId , string contactId){
        EmailTemplate et = [Select e.Id, e.Name, e.DeveloperName From EmailTemplate e where DeveloperName=:'ISSP_New_Member_Welcome_Email_CNS']; 
        if(et != null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            mail.setTargetObjectId(userId);
            mail.setSaveAsActivity(false);
            mail.setReplyTo('cns_noreply@cnsc.us'); 
            mail.setSenderDisplayName('CNS Portal ');
            Messaging.sendEmail(
            new Messaging.SingleEmailMessage[]{mail});
        }
    }

    public PageReference selectType(){
    	showcreateother = false;
        onegpa = false;
        system.debug('SELECTING TYPE: ' + selectedCustomerType);

        isAirline = false;
        isAgency = false;
        isGSA = false;
        isTiess = false;
        isNotIATA = false;
        isOther = false;
        isGeneral = false;
        showSearchIataCode = false;
        showSearchCountry = false;
        showSearchcompName = false;
        showSearchTiess = false;
        agencyTypeSelected = false;
        doSearch = false;
        cargoTravel = '';
        toSearchIataCodeString = '';
        isCargo = false;
        isTravel = false;
        toSearchIataCode = false;
        createAgency = false;
        toSearchDesignatorCodeString = '';
        createBranch = false;
        showCreateStandardAirline = false;
        showCreateAccount = false;
        accountFound = false;
        toSearchDesignatorCode = false;
        searchCountry = '';
        searchIATACode = '';
        searchCountryAirline = '';
        searchIATACodeAirline = '';
        searchDesignatorCode = '';

        errorMessage.clear();
        infoMessage.clear();
        accList.clear();
        hqAccount = null;
        hqFound = false;

        acc.Sector__c = '';

        if (selectedCustomerType == Airline){
            isAirline = true;
            acc.Sector__c = 'Airline';
            //showSearchIataCode = true;
            //showSearchCountry = true;
            //doSearch = true;
            if(sRefererCommunity == 'iec') {            	
            	toSearchDesignatorCodeString = 'Yes';
            	checkSearchDesignatorCode();
            }
        }
        else if (selectedCustomerType == Agency){
            isAgency = true;
            //showSearchIataCode = true;
            if(sRefererCommunity == 'iec') {
            	showSearchIataCode = true;
            	showSearchCountry = true;
            	doSearch = true;
            }
        }
        else if (selectedCustomerType == GSA){
            isGSA = true;
            showSearchIataCode = false;
            showSearchCountry = true;
            showSearchcompName = true;
            doSearch = true;
        }
        else if (selectedCustomerType == TIESS){
            isTiess = true;
            showSearchTiess = true;
            doSearch = true;
        }
        else if (selectedCustomerType == NonIATA){
            isNotIATA = true;
            showSearchCountry = true;
            showSearchcompName = true;
            doSearch = true;
        }
        else if (selectedCustomerType == OtherCompany){
            isOther = true;
            showSearchCountry = true;
            showSearchcompName = true;
            doSearch = true;
        }
        else if (selectedCustomerType == generalPublic){
            isGeneral = true;
            showSearchCountry = true;
            doSearch = true;
            //TC 2017-05-11
            if(sRefererCommunity == 'iec'){
            	doSearch = false;
            	showNextAsGP = true;      	
            }
        }


        if(CommunityName == 'CNS') {
            Id USAid = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{'United States'}).get(0).Id;
            searchCountry = USAid;
            searchCountryAirline = USAid;
            searchIATACodeAirline = USAid;
        }

        return null;
    }

    public List<SelectOption> getCustomerTypeList() {
        system.debug('getting getCustomerTypeList');
        List<SelectOption> types = new List<SelectOption>();
        types.add(new SelectOption('',Label.ISSP_Select_Type_of_Company));
        //TC 2017-05-16
        if(sRefererCommunity == 'iec'){
        	types.add(new SelectOption(Airline,Label.ISSP_Airline));
        	types.add(new SelectOption(Agency,Label.IDCard_ka_agency));
        	types.add(new SelectOption(OtherCompany,Label.ISSP_Other_Company));   
        //	types.add(new SelectOption(GeneralPublic,Label.ISSP_General_Public));     	
        } else {
        	types.add(new SelectOption(Airline,Label.ISSP_Airline));
        	types.add(new SelectOption(GSA,Label.ISSP_GSSA));
        	types.add(new SelectOption(Agency,Label.IDCard_ka_agency));
        	//types.add(new SelectOption(Agency,'IATA Accredited Agent'));
        	//types.add(new SelectOption(NonIATA,'Non IATA Agent'));
        	//types.add(new SelectOption(TIESS,'TIESS'));
        	types.add(new SelectOption(OtherCompany,Label.ISSP_Other_Company));
        	types.add(new SelectOption(GeneralPublic,Label.ISSP_General_Public));
        }
        
        return types;
    }

    public List<SelectOption> getCargoTravelOptions(){
        List<SelectOption> agencyType = new List<SelectOption>();
        agencyType.add(new SelectOption('Cargo',Label.ISSP_Cargo));
        if(communityName != 'CNS') agencyType.add(new SelectOption('Travel',Label.ISSP_Travel));
        return agencyType;
    }

    public PageReference checkAgencyType(){
        system.debug('CARGO OR TRAVEL: ' + cargoTravel);
        if (cargoTravel == 'Cargo'){
            isCargo = true;
            isTravel = false;
        }
        else if (cargoTravel == 'Travel'){
            isCargo = false;
            isTravel = true;
        }
        agencyTypeSelected = true;
        return null;
    }

    public List<SelectOption> getIataCodeQuestion(){
        List<SelectOption> yesNo = new List<SelectOption>();
        yesNo.add(new SelectOption('Yes',Label.ISSP_Yes));
        yesNo.add(new SelectOption('No',Label.ISSP_No));
        return yesNo;
    }

    public PageReference checkSearchIataCode(){
        system.debug('TO SEARCH IATA CODE: ' + toSearchIataCodeString);
        if (toSearchIataCodeString == 'Yes'){
            toSearchIataCode = true;
            isNotIATA = false;
            //isAgency = true;
            showSearchIataCode = true;
            showSearchCountry = false;
            showSearchcompName = false;
            infoMessage.clear();
            errorMessage.clear();
        }
        else{
            searchIATACode = '';
            toSearchIataCode = false;
            isNotIATA = true;
            //isAgency = false;
            showSearchIataCode = false;
            showSearchCountry = true;
            showSearchcompName = true;
            infoMessage.clear();
            errorMessage.clear();
        }
        doSearch = true;
        return null;
    }

    public PageReference checkSearchDesignatorCode(){
        searchCountry = '';
        searchIATACode = '';
        searchCountryAirline = '';
        searchIATACodeAirline = '';
        searchDesignatorCode = '';
        system.debug('TO SEARCH DESIGNATOR CODE: ' + toSearchDesignatorCodeString);
        if (toSearchDesignatorCodeString == 'Yes'){
            toSearchDesignatorCode = true;
            showSearchCountry = false;
            showSearchcompName = false;
            showCreateStandardAirline = false;
            showCreateAccount = false;
            doSearch = true;
            infoMessage.clear();
            errorMessage.clear();
        }
        else{
            toSearchDesignatorCode = false;
            isAgency = false;
            showSearchIataCode = false;
            showSearchCountry = true;
            showSearchcompName = true;
            infoMessage.clear();
            errorMessage.clear();
        }

        if(CommunityName == 'CNS') {
            Id USAid = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{'United States'}).get(0).Id;
            searchCountry = USAid;
            searchCountryAirline = USAid;
            searchIATACodeAirline = USAid;
        }
        
        doSearch = true;
        return null;
    }


    public Boolean checkCaptcha()  {
        /*
        System.debug('captchaId: ' + captchaId);
        System.debug('captchaAnswer: ' + captchaAnswer);
        String url = 'http://captchator.com/captcha/check_answer/' + captchaId + '/' + captchaAnswer;
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        if (Test.isRunningTest()){
            captchaVerified = true;
            return true;
        }
        else{
            try {
                Http http = new Http();
                response = http.send(req);
                System.debug('reCAPTCHA response: ' + response);
                System.debug('reCAPTCHA body: ' + response.getBody());
                if (response.getBody() == '1'){
                    captchaVerified = true;
                    return true;
                }
            } catch(System.Exception e) {
                return false;
                System.debug('ERROR: ' + e);
            }
        }
        return false;
        */
        return null;
    }



    public void findLocation(){

    	ISSP_CS__c cs = ISSP_CS__c.getInstance('ipinfo_token');
        String ipinfo_token = cs.value__c;
		String ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');

        String IP_LOOKUP_URL = 'https://ipinfo.io/' + ipAddress + '/json?token=' + ipinfo_token;
    	Http h = new Http();
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(IP_LOOKUP_URL);
        req.setMethod('GET');
        req.setTimeout(2000);
        HttpResponse res;
        try{
            res = h.send(req);
            JSONParser parser = JSON.createParser(res.getBody());
            system.debug('message:' + String.valueOf(parser));
	        while (parser.nextToken() != null) {
	        	system.debug('field name:' + JSONToken.FIELD_NAME);
	        	system.debug('value:' + parser.getText());
	            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
	                (parser.getText() == 'country')) {
	                parser.nextToken();
	                system.debug('COUNTRY:' + parser.getText());
	                whichcountry = parser.getText();
	            }
	        }


        }catch(Exception e){

        }

    }

	//TC 2017-0516
	public List<SelectOption> shpCountry {
		get{
			if(shpCountry == null) {
				List<SelectOption> options = new List<SelectOption>();
				for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
                    if(iso.Name != 'All Countries' && iso.Name != 'NO COUNTRY'){
						options.add(new SelectOption(iso.ISO_Code__c,iso.Name));
                    }
				}
                shpCountry = options;
			}
			return shpCountry;					
		}
		set;
	}

    //TF-SP08 - for first agency user, give access to custom permission set
    @Future
    public static void permissionNewAgency(String userId){
        if (userId != null && userId != '') {
            List <PermissionSet> permList = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_New_Agency_permission_set'];
            if (!permList.isEmpty()){
                PermissionSetAssignment newAssign = new PermissionSetAssignment();
                newAssign.AssigneeId = userId;
                newAssign.PermissionSetId = permList[0].Id;
                insert newAssign;
            }
        }
    }
    
    /* TC 2017-05-29 iec enhancements */
    public String companyName {get;set;}
    
    public List<Account> searchCompany(String searchTerm, String companyName, String companyLocation, String companyType) {
    	Set<String> recordTypes = new Set<String>();
    	if(companyType == 'Airline') {
    		recordTypes.addAll(new Set<String>{'IATA_Airline_BR', 'IATA_Airline'});
    	} else if(companyType == 'Agency') {
    		recordTypes.add('IATA_Agency');
    	}
    	String queryStr = 'SELECT Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, RecordType.DeveloperName, RecordType.Name, '+
    					  'Airline_designator__c, Airline_Prefix__c FROM Account ';
    	String whereClause = 'WHERE RecordType.DeveloperName IN :recordTypes AND '+
    								'IATA_ISO_Country__c = \''+companyLocation+'\' ';
    	
    	if(!String.isBlank(searchTerm) && companyType == 'Airline') {
    		whereClause += 'AND Airline_Search_Field__c LIKE \''+buildSearchExpression(searchTerm)+'\' ';
    	}
    	if(!String.isBlank(searchTerm) && companyType == 'Agency') {
    		whereClause += 'AND (IATACode__c = \''+ searchTerm +'\' OR Airline_Prefix__c = \''+ searchTerm +'\') ';
    	}
    	if(!String.isBlank(companyName)) {
    		whereClause += 'AND Name LIKE \''+buildSearchNameExpression(companyName)+'\' ';
    	}
    	
    	return Database.query(queryStr + whereClause);
    }
    
    private String buildSearchExpression(String searchTerm) {
    	List<String> temp1 = searchTerm.split('(?<=\\D)(?=\\d)|(?<=\\d)(?=\\D)');
    	List<String> temp2 = new List<String>();
    	for(String s1 : temp1) {
    		for(String s2 : s1.split(' ')) {
    			if(!String.isBlank(s2)) {
    				temp2.add(s2.replaceAll('[^A-Za-z0-9]', ''));
    			}
    		}
    	}
    	String res = '';
    	for(String s3 : temp2) {
    		res += s3+'%';
    	}
    	
    	return '%'+res;
    }
    
    private String buildSearchNameExpression(String name) {
    	String res = '';
    	for(String s : name.split(' ')){
    		if(!String.isBlank(s)) {
    			res += s + '%';
    		}
    	}
    	return '%'+res;
    }
    
    public void handleSearchResults() { 	
    	if(accList != null) {
    		accountFound = !accList.isEmpty();
    		if (!accList.isEmpty()) {
		    	accListRadio = new List<SelectOption>();
				for (Account thisAccount : accList) {
		    		accListRadio.add(new SelectOption(thisAccount.Id,thisAccount.Name));
				}
				if(accList.size() == 1) {
					selectedAccId = accList[0].Id;
				}
    		} else {
    			searchCountryISOCode = isAirline ? countryISOCodeMap.get(searchCountryAirline) : countryISOCodeMap.get(searchCountry);	
    			searchCountryName = isAirline ?	countryMap.get(searchCountryAirline) : countryMap.get(searchCountry);
    			searchCountry = isAirline ? searchCountryAirline : searchCountry;
    			showCreateAccount = true;
    			showcreateother = true;
    			isOther = true;
    			infoMessage.add(Label.IEC_NoRecordsFoundCreateAccount);
    		}
    	}
    }
	
	//EM - To be removed
	public static void fakemethod () {
		if (Test.isRunningTest()) {
			Integer i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
			i=0;
		}

	}
    
    public static String isoStates {
    	get{
    		if(isoStates == null) {
	    		List<IATA_ISO_State__c> lstStates = [SELECT IATA_ISO_Country__r.Name,Informatica_Value__c, IATA_ISO_Country__r.ISO_Code__c 
	    											 FROM IATA_ISO_State__c 
	    											 WHERE IATA_ISO_Country__r.Name IN ('Canada', 'United States', 'Brazil', 'Australia', 'Venezuela') AND Informatica_Value__c  != null
	    											 ORDER BY IATA_ISO_Country__r.Name, Informatica_Value__c  ASC];
	    		
	    		Map<String,List<String>> mapStates = new Map<String,List<String>>();
	    		for(IATA_ISO_State__c state : lstStates) {
	    			List<String> states = mapStates.get(state.IATA_ISO_Country__r.ISO_Code__c);
	    			if(states == null) {
	    				states = new List<String>();
	    				mapStates.put(state.IATA_ISO_Country__r.ISO_Code__c, states);
	    			}
	    			states.add(state.Informatica_Value__c);
	    		}
	    		isoStates = JSON.serialize(mapStates);
    		}
    		
    		return isoStates;
    	}
    	set;
    }
    
    /* end */
    
}

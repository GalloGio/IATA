public without sharing class OneIdVfDSEController {


    public string lang{get
        {
            string t = '';
            Cookie coo = ApexPages.currentPage().getCookies().get('language');
            if(System.currentPageReference().getParameters().get('language')!=null){
                t = System.currentPageReference().getParameters().get('language');
                coo = new Cookie('language',t,null,-1,false);
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

    // Errors, Logs and Error Case:
    public list<String> errorMessage {get; set;}
    public list<String> infoMessage {get; set;}
    private String log;
    private string generalError =  Label.ISSP_Registration_generalError;
    public Boolean passwordReset {get; set;}//TF-SP11
    public boolean displayNewCaseForm {get; set;}

    //EM
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

    public Boolean show90Days {get; set;}

    public String country {get; set;}

    // Start MM: "Project Registration Merge" - Define a referrer which will be checked against parameters included in the URL �First_Community�:
    // EM: New
    //End
    public String templatename {get;set;}
    public Boolean onegpa {get;set;}

    //EM
    public boolean showcreateother {get;set;}
    public String except {get;set;}
    public String addressdoctorerror {get;set;}
    public String validateaddresserror {get;set;}
    public String validateaddresserror2 {get;set;}
    public String urlpicture {get;set;}
    //public boolean isChina {get;set;}
    public String whichcountry {get;set;}

    public enum ReturnToParentEnum {AccountContactAndUserSuccess, ReturnToLogin}
    public ReturnToParentEnum returnToParent {get;set;}
    
    private String theContact = 'XX';

    public OneIdVfDSEController(){


        findLocation();

        try {
            urlpicture = [select url__c from Checkbox_picture__c limit 1].url__c;
        }
        catch (Exception e) {}

        //sRefererCommunity = '';
        templatename = 'OneIdVfDSETemplate';

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
        country = ApexPages.currentPage().getParameters().get('country');
        lang = ApexPages.currentPage().getParameters().get('language');

        passwordReset = false; //TF - SP11

        con = new Contact();
        accList = new list<Account>();
        acc = new Account(name='');
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

        doSearch = false;

        //EM
        reCAPTCHA = new vfIECreCAPTCHA();
        reCAPTCHA.verified = false;

        if (whichcountry == 'CN')   recaptcha.verified = true;

        //getISOCountry();
        searchCountryISOCode = whichcountry;


    }


    /*
     * Back from account page to contact page
     */

    public PageReference backToAccountPage () {
        showCreateAccount = false;
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
        return Page.OneIdVfDSE;
    }

    /*
     * Step 3.1: Search for account
     */
    public PageReference searchAccount() {

        System.debug('Starting searchAccount');

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
            
        else if (isAgency){
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
            else if (searchIATACode.length() != 8 || searchIATACode.length() != 11){
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
            
        else if (isGSA) {
            whereStr = 'Name like \'%' + searchCompanyName + '%\' and IATA_ISO_Country__c=\'' + searchCountry + '\'';
        }
        else if (isAgency) {
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
        String queryStr = 'select Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, RecordType.DeveloperName, RecordType.Name, Airline_designator__c from Account where '
                + whereStr + ' and RecordType.DeveloperName in :recordTypesSet';

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
                    queryStr = 'select Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, Top_Parent__c, Top_Parent__r.Name, Sector__c, Category__c, RecordType.Name, Airline_designator__c from Account where '
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
                        errorMessage.add(Label.OneId_NoRecordsFoundGP);
                    }
                }
                else{
                    infoMessage.add(Label.ISSP_NoRecordsFoundCreateStandardAirline);
                    showCreateAccount = true;
                    acc.Name = searchCompanyName;
                }
            }
        }
        else if (isOther){
            if (!accountFound){
                acc.Name = searchCompanyName;
                infoMessage.add(Label.ISSP_NoRecordsFoundCreateAgency);
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
                infoMessage.add(Label.ISSP_NoRecordsFoundCreateAgency);
                showCreateAccount = true;
                createAgency = true;
            }
        }
        else if (isTIESS){
            if (!accountFound){
                errorMessage.add(Label.OneId_NoRecordsFoundGP);
            }
        }
        else if (isAgency){
            if (!accountFound){
                errorMessage.add(Label.ISSP_NoRecordsFoundNext);
            }
        }
        else if (isGSA){
            if (!accountFound){
                errorMessage.add(Label.ISSP_NoRecordsFoundGSA);
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

        system.debug('selectedAccId after search: ' + selectedAccId);

        if (!accList.isEmpty()){
            accListRadio = new List<SelectOption>();
            for (Account thisAccount : accList){
                accListRadio.add(new SelectOption(thisAccount.Id,thisAccount.Name));
            }
        }

        return null;
    }


    /*
     * Back to Contact page - as General Public
     */
    public PageReference nextAsGP() {
        system.debug('nextAsGP: ' + accList);
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
            //PageReference pr;

            returnToParent = ReturnToParentEnum.ReturnToLogin;
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
                acc.IATA_ISO_Shipping_Country__c = searchCountry;
                acc.BillingCountry = searchCountryName;
                acc.ShippingCountry = searchCountryName;
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
            }
            else{
                acc.Reason_for_creation__c = 'Created by customer';
            }

            log('RecordTypeId ' + acc.RecordTypeId);
            system.debug('TradeName__c: ' + acc.TradeName__c);
            try {


                //EM: Management of state/provinces picklists
                if (!String.isBlank(acc.billingstate)) {
                    List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();
                    for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStates()){
                        if(sta.IATA_ISO_Country__r.Name == acc.billingcountry && sta.Informatica_value__c == acc.billingstate){
                            states.add(sta);
                            break;
                        }
                    }

                    system.debug('states 1+++ ' + states);
                    if (states.size() == 0) {
                        for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStatesByIds(new Set<String>{acc.billingstate})){
                            if(sta.IATA_ISO_Country__r.Name == acc.billingcountry){
                                states.add(sta);
                                break;
                            }
                        }
                    }
                    system.debug('states 2+++ ' + states);
                    if (states.size()!=0)
                        acc.IATA_ISO_Billing_State__c = states[0].id;
                }

                if (!String.isBlank(acc.shippingstate)) {
                    if (acc.shippingstate == acc.billingstate && acc.shippingcountry == acc.billingcountry)
                        acc.IATA_ISO_Shipping_State__c = acc.IATA_ISO_Billing_State__c;
                    else {
                        List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();
                        for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStates()){
                            if(sta.IATA_ISO_Country__r.Name == acc.shippingcountry && sta.Informatica_value__c == acc.shippingstate){
                                states.add(sta);
                                break;
                            }
                        }

                        if (states.size() == 0) {
                            for(IATA_ISO_State__c sta : IATAIsoStateDAO.getIsoStatesByIds(new Set<String>{acc.shippingstate})){
                                if(sta.IATA_ISO_Country__r.Name == acc.shippingcountry){
                                    states.add(sta);
                                    break;
                                }
                            }
                        }
                        if (states.size()!=0)
                            acc.IATA_ISO_Shipping_State__c = states[0].id;
                    }
                }
                system.debug('acc +++ ' + acc);
                //upsert acc;

            } catch (exception ex){
                createAccountErroeMode = true;
                errorMessage.add(ex.getMessage());
                displayNewCaseForm = true;
                return null;
            }
            con.AccountId = acc.Id;

            System.debug('*** Contact: ' + con);
        } else {
            // existing acount is selected
            system.debug('to register selectedAccId: ' + selectedAccId);
            system.debug('to register selectedAccId2: ' + selectedAccId2);
            if (selectedAccId != '' && selectedAccId != null)
                con.AccountId = selectedAccId;
            else if (selectedAccId2 != '' && selectedAccId2 != null)
                con.AccountId = selectedAccId2;


            if(acc <> null && con.AccountId <> null) acc.id = con.AccountId;
        }

        if (searchCountry!=null && searchCountry!=''){
            con.ISO_Country__c = searchCountry;
            //EM: Handle ISO Shipping Country
            con.IATA_ISO_Shipping_Country__c = searchCountry;
            con.Country__c = searchCountryName;
        }


        // create new Contact
        try {

            System.debug('Contact management start');
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

            System.debug('Contact management upsert ' + con);
            //upsert con;

        }
        catch(exception ex){
            System.debug(ex);
            errorMessage.add(ex.getMessage());
            displayNewCaseForm = true;
            return null;

        }

        sendEmailToAdmin = true;

        acc.Legal_name__c = acc.Name;
        String languageString = 'English';
        if (lang != null && lang != ''){
            if (ISSP_Constant.languageMap.containsKey(lang)){
                languageString = ISSP_Constant.languageMap.get(lang);
            }
        }
        
        con.Preferred_Language__c = languageString;

        Savepoint sp = Database.setSavepoint();
        try {
            String returnedString = LightningRegistrationProcess.createContactAndAccount(con,acc,selectedCustomerType);
            if (returnedString.contains('line:')){
                Database.rollback(sp);

                System.debug(returnedString);
                errorMessage.add(System.Label.ISSP_Registation_LogCase1);
                //errorMessage.add(returnedString);
                //displayNewCaseForm = true;
                return null;            
            }
            else {
                showConfirmMessage = true;
                returnToParent = ReturnToParentEnum.AccountContactAndUserSuccess;
                errorMessage.add(System.Label.ISSP_Registration_Thank_you_GeneralAccount + ' ' + System.Label.ISSP_Registration_Redirection15s);
                //errorMessage.add(System.Label.ISSP_Registration_Thank_you_GeneralAccount);
                //errorMessage.add(System.Label.ISSP_Registration_Redirection15s);

                return null;
            }
        }
        catch(Exception ex){
            Database.rollback(sp);

            System.debug(ex.getMessage());
            errorMessage.add(System.Label.ISSP_Registation_LogCase1);
            //errorMessage.add(ex.getMessage());
            //displayNewCaseForm = true;
            return null;         
        }

    }

    @TestVisible
    private String getRecordTypeCode(String customerType) {
        String devName = ISSP_Constant.accountDefaultRecordTypeByCustomerType.get(customerType);
        if (devName==Null)
            return null;
        log(customerType + ', ' + devName);
        try {
            Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', devName);
            if(String.isNotBlank(rtId)){
                return rtId;
            }
        } catch (Exception e) {
            log('error getting type');
        }
        return null;
    }

    public List<SelectOption> getISOCountry() {
        List<SelectOption> options = new List<SelectOption>();
        boolean countryMapEmpty = (countryMap == null);
        if (countryMapEmpty)
            countryMap = new Map<Id, String>();

        for(IATA_ISO_Country__c iso: IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
            if (iso.Name != 'All Countries'){
                options.add(new SelectOption(iso.Id,iso.Name));
                if (countryMapEmpty) {
                    countryMap.put(iso.Id, iso.Name);
                }
                countryISOCodeMap.put(iso.Id, iso.ISO_Code__c);
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
/*
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
*/

    /*
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
*/
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
        searchCompanyName = '';

        errorMessage.clear();
        infoMessage.clear();
        accList.clear();
        hqAccount = null;
        hqFound = false;
        showNextAsGP = false;

        acc.Sector__c = '';

        if (selectedCustomerType == Airline){
            isAirline = true;
            acc.Sector__c = 'Airline';
            //showSearchIataCode = true;
            //showSearchCountry = true;
            //doSearch = true;
        }
        else if (selectedCustomerType == Agency){
            isAgency = true;
            //showSearchIataCode = true;
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
        }

        return null;
    }

    public List<SelectOption> getCustomerTypeList() {
        system.debug('getting getCustomerTypeList');
        List<SelectOption> types = new List<SelectOption>();
        types.add(new SelectOption('',Label.ISSP_Select_Type_of_Company));
        types.add(new SelectOption(Airline,Label.ISSP_Airline));
        types.add(new SelectOption(GSA,Label.ISSP_GSSA));
        types.add(new SelectOption(Agency,Label.IDCard_ka_agency));
        //types.add(new SelectOption(Agency,'IATA Accredited Agent'));
        //types.add(new SelectOption(NonIATA,'Non IATA Agent'));
        //types.add(new SelectOption(TIESS,'TIESS'));
        types.add(new SelectOption(OtherCompany,Label.ISSP_Other_Company));
        types.add(new SelectOption(GeneralPublic,Label.ISSP_General_Public));
        return types;
    }

    public List<SelectOption> getCargoTravelOptions(){
        List<SelectOption> agencyType = new List<SelectOption>();
        agencyType.add(new SelectOption('Cargo',Label.ISSP_Cargo));
        agencyType.add(new SelectOption('Travel',Label.ISSP_Travel));
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
            isAgency = true;
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
            isAgency = false;
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
        doSearch = true;
        return null;
    }


    //public Boolean checkCaptcha()  {
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
        //return null;
    //}



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

                    System.debug('Site User is located in ' + whichcountry);
                }
            }


        }catch(Exception e){

        }


    }




    //TF-SP08 - for first agency user, give access to custom permission set
   /* @Future
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
    }*/
    // to be used in visualforce page OneIdVfCreateAccount
    public Static String getHostURL(){
        return OneIdUtils.getOrgUrl();
    }
    public void PassingTheContact(){
        //String theContact=Apexpages.currentPage().getParameters().get('theContact');
        System.debug('PassingTheContact ' + theContact);
        con = (Contact)JSON.deserialize(theContact, Type.forName('Contact'));
        System.debug('PassingTheContact ' + con);
    }

    public void setConStr(String n) {
        theContact = n;
    }
            
    public String getConStr() {
        return theContact;
    }

    public Static String getCommunityName(){
        return OneIdUtils.getCommunityUrlName();
    }    
}
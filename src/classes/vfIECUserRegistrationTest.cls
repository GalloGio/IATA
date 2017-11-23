/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 */
@isTest(SeeAllData=true)

private class vfIECUserRegistrationTest {

    private static IATA_ISO_Country__c ISOCountryUSA;
    private static IATA_ISO_Country__c ISOCountryCAN;
    private static IATA_ISO_Country__c ISOCountryFRA;
    private static String acc5Id;


    //Account creation
    private static Account createNewAccount(string nameSufix, string recordTypeId, IATA_ISO_Country__c country, string iataCode, Account parentAcc) {
        String ownerId = IECUserManager.getIECAccountOwnerId();

        Account acc = new Account();
        acc.OwnerId =   ownerId;
        acc.Name = 'Account ' + nameSufix;
        acc.RecordTypeId = recordTypeId;
        acc.IATA_ISO_Country__c = country.Id;
        acc.BillingCountry = country.Name;
        acc.BillingCity = 'City ' + nameSufix;
        acc.BillingPostalCode = 'PC ' + nameSufix;
        acc.BillingStreet = '1234 Street ' + nameSufix;
        acc.BillingState = 'State ' + nameSufix;
        acc.IATACode__c = iataCode;

        if (parentAcc != null)
            acc.ParentId = parentAcc.Id;

        return acc;
    }


    //Account creation
    private static Contact createNewContact(string nameSufix, string accountId) {

        String ownerId = IECUserManager.getIECContactOwnerId();
        String recordTypeId = IECUserManager.getContactRecordTypeForIEC();

        Contact con = new Contact();
        con.User_IECPortal_Status__c = IECConstants.NEW_CONTACT_STATUS;
        con.RecordTypeId = recordTypeId;
        con.AccountId = accountId;
        con.FirstName = 'FirstName ' + nameSufix;
        con.LastName = 'LastName ' + nameSufix;
        con.Email = 'contact' + nameSufix + '@iata.org.ecom';
        con.OwnerId = ownerId;

        return con;
    }




    private static void addDomainNameToAccount(String domainName, String accountId) {

        Account_Domain__c domain = new Account_Domain__c();
        domain.Name = domainName;
        domain.Account__c = accountId;

        insert domain;
    }

    private static void createIsoCountry(){
        //check if 'US' ISO_Code exists
        List<IATA_ISO_Country__c> isoCountriesUS = new List<IATA_ISO_Country__c>();
        isoCountriesUS = [SELECT Name, ISO_Code__c, Iso_Code_Numeric__c, CurrencyIsoCode, VAT_Validation_Required__c, Tax_ID_Mandatory__c, Tax_1_Label__c, Tax_2_Label__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'US' limit 1];

        if(!isoCountriesUS.isEmpty()){
            //populate with correct data
            isoCountriesUS[0].Name = 'United States';
            isoCountriesUS[0].VAT_Validation_Required__c = true;
            isoCountriesUS[0].Tax_ID_Mandatory__c = false;
            //isoCountriesUS[0].Tax_1_Label__c = 'tax1';
            //isoCountriesUS[0].Tax_2_Label__c = 'tax2';
            update isoCountriesUS[0];
        }else{
            //create new
            IATA_ISO_Country__c isoCountryUS = new IATA_ISO_Country__c();
            isoCountryUS.Name = 'United States';
            isoCountryUs.ISO_Code__c = 'US';
            isoCountryUS.ISO_Code_Numeric__c = 999; //not real code
            isoCountryUS.CurrencyIsoCode = 'USD';
            isoCountryUS.AIMS_Area_ID__c = '1'; //not real code
            isoCountryUS.VAT_Validation_Required__c = true;
            isoCountryUS.Tax_ID_Mandatory__c = false;
            //isoCountryUS.Tax_1_Label__c = 'tax1';
            //isoCountryUS.Tax_2_Label__c = 'tax2';
            insert isoCountryUS;
        }
        //check if 'CA' ISO_Code exists
        List<IATA_ISO_Country__c> isoCountriesCA = new List<IATA_ISO_Country__c>();
        isoCountriesCA = [SELECT Name, ISO_Code__c, Iso_Code_Numeric__c, CurrencyIsoCode, VAT_Validation_Required__c, Tax_ID_Mandatory__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CA' limit 1];

        if(!isoCountriesCA.isEmpty()){
            //populate with correct data
            isoCountriesCA[0].Name = 'Canada';
            isoCountriesCA[0].VAT_Validation_Required__c = true;
            isoCountriesCA[0].Tax_ID_Mandatory__c = false;
            //isoCountriesCA[0].Tax_1_Label__c = 'tax1';
            //isoCountriesCA[0].Tax_2_Label__c = 'tax2';
            update isoCountriesCA[0];
        }else{
            IATA_ISO_Country__c isoCountryCA = new  IATA_ISO_Country__c();
            isoCountryCA.Name = 'Canada';
            isoCountryCA.ISO_Code__c = 'CA';
            isoCountryCA.ISO_Code_Numeric__c = 888; //not real code
            isoCountryCA.CurrencyIsoCode = 'CAD';
            isoCountryCA.AIMS_Area_ID__c = '1'; //not real code
            isoCountryCA.VAT_Validation_Required__c = true;
            isoCountryCA.Tax_ID_Mandatory__c = false;
            //isoCountryCA.Tax_1_Label__c = 'tax1';
            //isoCountryCA.Tax_2_Label__c = 'tax2';
            insert isoCountryCA;
        }

        List<IATA_ISO_Country__c> isoCountriesFR = new List<IATA_ISO_Country__c>();
        isoCountriesFR = [SELECT Name, ISO_Code__c, Iso_Code_Numeric__c, CurrencyIsoCode, VAT_Validation_Required__c, Tax_ID_Mandatory__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'FR' limit 1];

        if(!isoCountriesFR.isEmpty()){
            //populate with correct data
            isoCountriesFR[0].Name = 'France';
            isoCountriesFR[0].VAT_Validation_Required__c = true;
            isoCountriesFR[0].Tax_ID_Mandatory__c = false;
            isoCountriesFR[0].Tax_1_Label__c = 'FR';
            isoCountriesFR[0].Tax_2_Label__c = '123456789012345678';
            update isoCountriesFR[0];
        }else{
            IATA_ISO_Country__c isoCountryFR = new  IATA_ISO_Country__c();
            isoCountryFR.Name = 'France';
            isoCountryFR.ISO_Code__c = 'FR';
            isoCountryFR.ISO_Code_Numeric__c = 777; //not real code
            isoCountryFR.CurrencyIsoCode = 'EUR';
            isoCountryFR.AIMS_Area_ID__c = '1'; //not real code
            isoCountryFR.VAT_Validation_Required__c = true;
            isoCountryFR.Tax_ID_Mandatory__c = true;
            isoCountryFR.Tax_1_Label__c = 'FR';
            isoCountryFR.Tax_2_Label__c = '123456789012345678';
            insert isoCountryFR;
        }
    }


    private static Contact InitExistingContact() {

        createIsoCountry();

        String airlineHQAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);
        String contactRT = IECUserManager.getContactRecordTypeForIEC();
        ISOCountryCAN = [SELECT id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c =: 'CA' limit 1 ];


        Account acc = createNewAccount('03.1', airlineHQAccountRT, ISOCountryCAN, '030', null);
        insert acc;
        Contact con = createNewContact('03.1', acc.Id);
        insert con;

        return con;
    }

    private static void InitSearchAccounts() {

        createIsoCountry();

        String standardAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Standard);
        String airlineBRAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_BranchAirline);
        String airlineHQAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);
        String agencyAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Agency);
        String gasAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_GSA);
        String othersAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Others);

        String contactRT = IECUserManager.getContactRecordTypeForIEC();

        ISOCountryCAN = [SELECT id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c =: 'CA' limit 1 ];

        //Creates an Airline Account HQ and BR
        Account acc4 = createNewAccount('04', airlineHQAccountRT, ISOCountryCAN, '040', null);
        insert acc4;
        
        List<Account> l = new List<Account>();
        Account acc7 = createNewAccount('07', airlineBRAccountRT, ISOCountryCAN, '070', acc4);
		l.add(acc7);
        
        //Creates a GAS Account
        Account acc8 = createNewAccount('08', gasAccountRT, ISOCountryCAN, '080', null);
        l.add(acc8);

        //Creates an Agency Account
        Account acc9 = createNewAccount('09', agencyAccountRT, ISOCountryCAN, '09009009', null);
        l.add(acc9);

        //Creates a Non Agency Account
        Account acc10 = createNewAccount('10', othersAccountRT, ISOCountryCAN, '010', null);
        l.add(acc10);

        //Creates a Non Airline Account
        Account acc11 = createNewAccount('11', othersAccountRT, ISOCountryCAN, '011', null);
        l.add(acc11);

        //Creates a Non Airline Account
        Account acc12 = createNewAccount('12', othersAccountRT, ISOCountryCAN, '012', null);
        l.add(acc12);
        
        insert l;
    }


    private static String InitRegistration(){

        createIsoCountry();

        String airlineHQAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);
        String contactRT = IECUserManager.getContactRecordTypeForIEC();
        ISOCountryCAN = [SELECT id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c =: 'CA' limit 1 ];

        //Creates an Account with Contact and portal user
        Account acc3 = createNewAccount('03', airlineHQAccountRT, ISOCountryCAN, '030', null);
        insert acc3;

        return acc3.Id;
    }


    private static Account InitEmailDomainValidation(String accName, String emailDomain) {

        createIsoCountry();

        //Creates an Airline BR Account with email domains registered
        String airlineBRAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_BranchAirline);
        String airlineHQAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);
        ISOCountryCAN = [SELECT id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c =: 'CA' limit 1 ];

        //Creates 2 accounts: HQ and Branch.
        Account accHQ = createNewAccount(accName + 'HQ', airlineHQAccountRT, ISOCountryCAN, '040', null);
        insert accHQ;
        Account acc = createNewAccount(accName + 'BR', airlineBRAccountRT, ISOCountryCAN, '050', accHQ);
        insert acc;

        //Add the domain to the parent HQ account
        if (emailDomain != null)
                addDomainNameToAccount(emailDomain, accHQ.Id);

        //Returns the branch account
        return acc;
    }




    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the workflow creation for an existing user
    static testMethod void triesExisitingUser_Test() {

        //InitExistingUser();

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
                    User existingUser = [SELECT Name, Id, Username,email,contact.email  FROM User  WHERE contactID <> null and contact.email <> null limit 1];

        System.runAs(usr) {




            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //pgCont.con.Email = 'contact03@iata.org.ecom';
            pgCont.con.Email = existingUser.contact.email;
            pgCont.bAccept = true;
            pgCont.validateUserEmail();
        //    system.assert(pgCont.bExistingEmail, 'Existing user email' + pgCont.con.Email);

        }

    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the workflow creation for non existing user with an exiting contact
    static testMethod void triesExisitingContact_Test() {

        Contact contact = InitExistingContact();

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {


            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //pgCont.con.Email = 'contact03@iata.org.ecom';
            pgCont.con.Email = contact.Email;
            pgCont.bAccept = true;
            pgCont.validateUserEmail();
            system.assertNotEquals(pgCont.con.Id, null);
            system.assert(!pgCont.bExistingEmail, 'No exisinting user email' + pgCont.con.Email);

        }

    }




    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the workflow creation for new user, contact
    static testMethod void createsContactUser_Test() {

        String accId = InitRegistration();

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        Test.startTest();
        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();


            //Test Email Capture validation
            pgCont.validateUserEmail();
            //system.assert(pgCont.errorMessage.size() == 2, 'Page validation failed: email and terms and condition');


            pgCont.con.Email = 'testclass_01';
            pgCont.validateUserEmail();
            //system.assert(pgCont.errorMessage.size() == 2, 'Page validation failed: email and terms and condition');


            pgCont.con.Email = 'testclass_01@iata.org.ecom';
            pgCont.validateUserEmail();
            //system.assert(pgCont.errorMessage.size() == 1, 'Page validation failed: terms and condition');

            pgCont.bAccept = true;
            pgCont.validateUserEmail();
            //system.assert(pgCont.errorMessage.size() == 0, 'Page validation');

            system.assert(!pgCont.bExistingEmail, 'Existing user email');

            system.assertEquals(pgCont.iRegistrationStep, pgCont.constCONTACTINFO);
            system.assertEquals(pgCont.con.Id, null);

            //Test User Information
            pgCont.goToSearchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'User Information no missing information');

            pgCont.con.FirstName = 'First Name';
            pgCont.con.LastName = 'Last Name';
            pgCont.con.Title = 'Title';
            pgCont.con.Phone = '51412234345';
            pgCont.con.Membership_Function__c = 'Other';
            pgCont.goToSearchAccount();
            //system.assert(pgCont.errorMessage.size() == 0, 'User Information missing information');


            pgCont.sSelectedAccount = accId;
            pgCont.registerPortalUser();

            system.assertNotEquals(pgCont.con.Id,null);
        }
        Test.stopTest();
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the workflow creation for new user, contact and account
    static testMethod void createsContactUserAccount_Test() {

        createIsoCountry();

        ISOCountryCAN = [SELECT id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c =: 'CA' limit 1 ];
        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            Test.startTest();
            //Fill email
            pgCont.con.Email = 'testclass_02@iata.org';
            pgCont.validateUserEmail();
            pgCont.bAccept = true;
            pgCont.validateUserEmail();

            //User Information
            pgCont.con.FirstName = 'First Name';
            pgCont.con.LastName = 'Last Name';
            pgCont.con.Title = 'Title';
            pgCont.con.Phone = '51412234345';
            pgCont.con.Membership_Function__c = 'Other';
            pgCont.goToSearchAccount();

            //Search for an Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AIRLINE;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATACode = '040';
            pgCont.sIATALocation = ISOCountryCAN.Id;
            pgCont.searchAccount();

            //Go to Create a New Account
            pgCont.nextToCreateAccount();

            //Validate transfer of IATA Code
            system.assert(pgCont.acc.IATACode__c == '040', 'IATA Code transfered to new Account form');


            //Clear IATACode and validates error messages
            pgCont.registerNewAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'New Account missing fields');

            //Fill Account information
            pgCont.acc.Name = 'Account Name';
            pgCont.acc.Industry = 'Industry';
            pgCont.acc.Sector__c = 'IATA';
            pgCont.acc.Category__c = 'IATA Cargo Agent';
            pgCont.acc.Type = 'Type';
            pgCont.acc.Phone = '1234567';

            pgCont.acc.BillingCountry = 'USA';
            pgCont.registerNewAccount();

            pgCont.acc.BillingCountry = '';
            pgCont.registerNewAccount();

            pgCont.acc.BillingCountry = 'Canada';
            pgCont.acc.BillingStreet = '1234 Main Street';
            pgCont.acc.BillingCity = 'Montreal';
            pgCont.acc.BillingState = 'QC';
            pgCont.acc.BillingPostalCode = 'Zip Code';

            //Creates the account
            pgCont.registerNewAccount();
            system.assert(pgCont.acc != null , 'New Account Creation');

            //There will be an error creating the portal user after the account is created
            //system.assert(pgCont.errorMessage.size() == 1, 'No error message due to missing fields' + pgCont.errorMessage);
            Test.stopTest();

            //further coverage
            pgCont.countryChanged();
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the email validation for account domain
    static testMethod void emailDomainValidation_Test() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        Account account1 = InitEmailDomainValidation('01', null);

        Contact con = new Contact();
        con.Email = 'contact@iata.org';

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            Test.startTest();
            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //Validate No Email registered under account
            IECUtil.DomainValidation validation1 = IECUtil.validateContactEmailDomain(con.Email, account1.Id);
            system.assert(validation1 == IECUtil.DomainValidation.NOREGISTEREDDOMAIN, 'Email validation NOREGISTEREDDOMAIN');
					
			Test.stopTest();
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the email validation for account domain
    static testMethod void emailDomainValidation_Test_2() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        Account account2 = InitEmailDomainValidation('02', 'noemail.com');

        Contact con = new Contact();
        con.Email = 'contact@iata.org';

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            Test.startTest();
            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();
			
            //Validate Email not matching a registered Email domain under the account
            IECUtil.DomainValidation validation2 = IECUtil.validateContactEmailDomain(con.Email, account2.Id);
            system.assert(validation2 == IECUtil.DomainValidation.NOTMATCHINGDOMAINS,  'Email validation NOTMATCHINGDOMAINS');
			
			Test.stopTest();
        }
    }    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the search of different Accounts based on Customer type
    static testMethod void searchAccounts_Test() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

        InitSearchAccounts();

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //Searches an Airline Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AIRLINE;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATACode = '040';
            pgCont.sIATALocation = ISOCountryCAN.Id;
            pgCont.searchAccount();
            system.assert(pgCont.lSearchOptios.size() > 0, 'Search Ariline result empty');



            //Searches a GAS Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_GAS;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATACode = '080';
            pgCont.searchAccount();
            system.assert(pgCont.lSearchOptios.size() > 0, 'Search GAS result empty');



            //Searches an Agency Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AGENCY;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATACode = '09009009';
            pgCont.searchAccount();
            system.assert(pgCont.lSearchOptios.size() > 0, 'Search AGENCY result empty');


            //Searches a Non Agenty Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY;
            pgCont.TypeOfCustomerChange();
            pgCont.sCompanyName = 'Account 10';
            pgCont.searchAccount();
            system.assert(pgCont.lSearchOptios.size() > 0, 'Search NON AGENCY result empty');


            //Searches a Non Airline Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE;
            pgCont.TypeOfCustomerChange();
            pgCont.sCompanyName = 'Account 11';
            pgCont.searchAccount();
            system.assert(pgCont.lSearchOptios.size() > 0, 'Search NON AIRLINE result empty');


            //Searches an Other Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_OTHER;
            pgCont.TypeOfCustomerChange();
            pgCont.sCompanyName = 'Account 12';
            pgCont.searchAccount();
            system.assert(pgCont.lSearchOptios.size() > 0, 'Search OTHER result empty');
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the search of different Accounts based on Customer type
    static testMethod void searchFailedAccounts_Test() {
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;

        InitSearchAccounts();

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();


            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'Airline search criteria missing paramenters');

            //Searches an Airline Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AIRLINE;
            pgCont.TypeOfCustomerChange();
            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'Airline search criteria missing paramenters');

            pgCont.sIATACode = '1234';
            pgCont.sIATALocation = ISOCountryCAN.Id;
            pgCont.searchAccount();
            system.assert(pgCont.bInvalidIATACode, 'Invalid IATA CODE validation');

            //Searches a GAS Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_GAS;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATACode = null;
            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'GAS search criteria missing paramenters');

            //Searches an Agency
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AGENCY;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATACode = null;
            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'Agency search criteria missing paramenters');

            //Searches a Non Agenty Accountt with no results
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATALocation = null;
            pgCont.sCompanyName = null;
            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'Agency search criteria missing paramenters');

            //Searches a Non Airlina Accountt with no results
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATALocation = null;
            pgCont.sCompanyName = null;
            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'Agency search criteria missing paramenters');

            //Searches an Other Account
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_OTHER;
            pgCont.TypeOfCustomerChange();
            pgCont.sIATALocation = null;
            pgCont.sCompanyName = null;
            pgCont.searchAccount();
            //system.assert(pgCont.errorMessage.size() > 0, 'Agency search criteria missing paramenters');
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the filter of account industries and and types based on customer type
    static testMethod void getListValues_Test() {

                PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //Test Counties by Name
            List<SelectOption> countries = pgCont.getCountries();
            system.assertNotEquals(countries, null);

            //Test Counties by Name - Id
            List<SelectOption> ISOCountries = pgCont.getISOCountry();
            system.assertNotEquals(ISOCountries, null);

            //Test Customer Types
            List<SelectOption> customerTypes = pgCont.getCustomerTypes();
            system.assertNotEquals(customerTypes, null);

            //Test Provinces of Canada
            List<SelectOption> canadaProvinces = pgCont.getCanadaProvinces();
            system.assertNotEquals(canadaProvinces, null);

            //Test States of USA
            List<SelectOption> usaStates = pgCont.getUSAStates();
            system.assertNotEquals(usaStates, null);

        }

    }



    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the filter of account industries and and types based on customer type
    static testMethod void filterAccountIndustriesAndTypes_Test() {
        //filterAccountIndustryAndType()

         PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //Test Airline type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AIRLINE;
            pgCont.TypeOfCustomerChange();
            pgCont.filterAccountIndustryAndType();
            system.assert(pgCont.lFilteredIndustry.size() == 1, 'Only Airline industry');
            system.assert(pgCont.lFilteredType.size() == 4, 'Only 4 Airline types');



            //Test GAS type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_GAS;
            pgCont.TypeOfCustomerChange();
            pgCont.filterAccountIndustryAndType();
            system.assert(pgCont.lFilteredIndustry.size() == 2, '2 industries');
            system.assert(pgCont.lFilteredType.size() == 3, '3 GAS types');


            //Test Non IATA Agency type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY;
            pgCont.TypeOfCustomerChange();
            pgCont.filterAccountIndustryAndType();
            system.assert(pgCont.lFilteredIndustry.size() > 10, 'More than 10 Industries');
            system.assert(pgCont.lFilteredType.size() > 10, 'More than 10 types');


        }
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test the filter of account industries and and types based on customer type
    static testMethod void customerChange_Test() {


        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            //Instantiate Controller
            vfIECUserRegistration pgCont = new vfIECUserRegistration();

            //Test cleanup of valirables
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AIRLINE;
            pgCont.sIATACode = '1233445';
            pgCont.sIATALocation = 'Location';
            pgCont.sCompanyName = 'Name';
            pgCont.TypeOfCustomerChange();
            system.assertEquals(pgCont.sIATACode, '');
            system.assertEquals(pgCont.sIATALocation, '');
            system.assertEquals(pgCont.sCompanyName, '');

            //Test Airline type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AIRLINE;
            pgCont.TypeOfCustomerChange();
            system.assert(pgCont.bShowIATACode, 'IATA Code should be visible');
            system.assert(pgCont.bShowIATALocation, 'IATA Location should be visible');
            system.assert(!pgCont.bShowCompanyName, 'Company Name should not be visible');

            //Test GAS type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_GAS;
            pgCont.TypeOfCustomerChange();
            system.assert(pgCont.bShowIATACode, 'IATA Code should be visible');
            system.assert(!pgCont.bShowIATALocation, 'IATA Location should not be visible');
            system.assert(!pgCont.bShowCompanyName, 'Company Name should not be visible');

            //Test Agency type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_AGENCY;
            pgCont.TypeOfCustomerChange();
            system.assert(pgCont.bShowIATACode, 'IATA Code should be visible');
            system.assert(!pgCont.bShowIATALocation, 'IATA Location should not be visible');
            system.assert(!pgCont.bShowCompanyName, 'Company Name should not be visible');

            //Test Non IATA Agency type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONIATAAGENCY;
            pgCont.TypeOfCustomerChange();
            system.assert(!pgCont.bShowIATACode, 'IATA Code should not be visible');
            system.assert(pgCont.bShowIATALocation, 'IATA Location should be visible');
            system.assert(pgCont.bShowCompanyName, 'Company Name should be visible');

            //Test Non IATA Airline type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_NONAIRLINE;
            pgCont.TypeOfCustomerChange();
            system.assert(!pgCont.bShowIATACode, 'IATA Code should not be visible');
            system.assert(pgCont.bShowIATALocation, 'IATA Location should be visible');
            system.assert(pgCont.bShowCompanyName, 'Company Name should be visible');

            //Test Partner type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_PARTNER;
            pgCont.TypeOfCustomerChange();
            system.assert(!pgCont.bShowIATACode, 'IATA Code should not be visible');
            system.assert(pgCont.bShowIATALocation, 'IATA Location should be visible');
            system.assert(pgCont.bShowCompanyName, 'Company Name should be visible');

            //Test Other type
            pgCont.selectedCustomerType = IECConstants.PARAM_CUSTOMERTYPE_OTHER;
            pgCont.TypeOfCustomerChange();
            system.assert(!pgCont.bShowIATACode, 'IATA Code should not be visible');
            system.assert(pgCont.bShowIATALocation, 'IATA Location should be visible');
            system.assert(pgCont.bShowCompanyName, 'Company Name should be visible');

        }


    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test logout call
    static testMethod void logout_Test() {

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        User usr = IECTestUtil.createSampleGuestUserAndLogin();

        System.runAs(usr) {

            vfIECUserRegistration pgCont = new vfIECUserRegistration();
            pgCont.logout();

        }
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Test register user with email change
    static testMethod void testRegisterUserWithEmailChange() {

        createIsoCountry();

        ISOCountryCAN = [SELECT id, Name, ISO_Code__c FROM IATA_ISO_Country__c WHERE ISO_Code__c =: 'CA' limit 1 ];
        String airlineHQAccountRT = IECUsermanager.getAccountRecordTypeByName(IECConstants.Account_RecordType_Airline);

        Account acc = createNewAccount('01', airlineHQAccountRT, ISOCountryCAN, '010', null);
        insert acc;
        
        Contact con = createNewContact('TestUserReg', acc.Id);
        insert con;

        PageReference pgRef = Page.IECUserRegistration;
        Test.setCurrentPage(pgRef);

        //Instantiate Controller
        vfIECUserRegistration pgCont = new vfIECUserRegistration();
        pgCont.con = con;
        pgCont.acc = acc;
        pgCont.sSelectedAccount = acc.Id;

        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr){

            Test.startTest();

            pgCont.registerUserWithEmailChange();

            System.assertEquals(true, pgCont.con.community__c == 'E-Commerce');
            System.assertEquals(true, pgCont.iRegistrationStep ==  pgCont.constEMAILCONFIRMATION);

            Test.stopTest();
        }
    }
}
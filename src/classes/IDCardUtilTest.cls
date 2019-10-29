/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class IDCardUtilTest {

    ///////////////////////
    // TEST METHODS
    
    static testMethod void testGetRandoms() {

        system.debug('Userinfo.getSessionId(): ' + Userinfo.getSessionId());
        system.debug('GUID: ' + IDCardUtil.NewGuid());
        system.debug('Pad with zeros: ' + String.valueOf(1).leftpad(3).replace(' ', '0'));
        system.debug('Pad with zeros: ' + String.valueOf(12).leftpad(3).replace(' ', '0'));
        system.debug('Pad with zeros: ' + String.valueOf(123).leftpad(3).replace(' ', '0'));
        system.debug('Pad with zeros: ' + String.valueOf(12345).leftpad(6).replace(' ', '0'));
        system.debug('Pad with zeros: ' + String.valueOf(123456).leftpad(6).replace(' ', '0'));
        
        String UIR = 'CA123456';
        String GUIDPhoto = '6cf2eac6-86e8-455c-b689-63797d73f3bb.jpg';
        Integer indexOfDot = GUIDPhoto.indexOf('.');
        String extension = GUIDPhoto.substring(indexOfDot);
        String newFilename = UIR + extension;
        
        system.debug('UIR: ' + UIR);
        system.debug('GUIDPhoto: ' + GUIDPhoto);
        system.debug('indexOfDot: ' + indexOfDot);
        system.debug('extension: ' + extension);
        system.debug('newFilename: ' + newFilename);
    }
    
    TestMethod static void TestEncryptDecript(){
        string keyToEncrypt = 'The Key';
        
        // Test Encrypt decrypt method successful test
        string encryptedKey = IDCardUtil.EncryptEncodeParameter(keyToEncrypt);
        System.assertEquals(keyToEncrypt, IDCardUtil.DecodeDecryptParameter(encryptedKey));
        
        try{
            string encryptedKey2 = IDCardUtil.EncryptEncodeParameter('');
        }
        catch(IDCardApplicationException ex){
            system.assert(true);
        }
        
        try{
            string encryptedKey3 = IDCardUtil.DecodeDecryptParameter('');
        }
        catch(IDCardApplicationException ex){
            system.assert(true);
        }
    }

    TestMethod static void GetApplicableFeeTest(){
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        Price_Table__c pt = new Price_Table__c();
        pt.Type_Class_of_Agent__c = 'TIDS';
        pt.Region__c = 'IDCA';
        pt.ID_Card_Fee__c = 35;
        pt.IATA_Package__c = 167;
        pt.Expedite__c = 35;
        pt.CurrencyIsoCode = 'CAD';
        pt.ISO_Country__c = country.id;
        
        insert pt;
        
        Price_Table__c[] listPriceTables = [Select ID, IATA_Package__c, ID_Card_Fee__c, Type_Class_of_Agent__c, Expedite__c, Name From Price_Table__c p where p.Type_Class_of_Agent__c = 'TIDS' and p.ISO_Country__r.Name = 'Canada'];
        
        if (listPriceTables == null || listPriceTables.size() == 0) {
            throw new IDCardApplicationException();
        }
        
        decimal applicableFee = IDCardUtil.GetApplicableFee(listPriceTables[0], true, true, true, null);     
        decimal applicableFee2 = IDCardUtil.GetApplicableFee(listPriceTables[0], false, true, true, null);
        
        Promotion__c promo = new Promotion__c();
        promo.CurrencyIsoCode = 'USD';
        promo.Promotion_Code__c = 'IDCFRR';
        promo.Promotion_Value__c = 50;
        promo.Promotion_Duration_Valid_From__c = Date.newInstance(2013, 1, 1); // '2013-01-01';
        promo.Promotion_Duration_Valid_Up_to__c = date.newInstance(2013, 6, 1); // '2013-06-01';
        
        insert promo;
        
        decimal applicableFee3 = IDCardUtil.GetApplicableFee(listPriceTables[0], false, true, true, promo);
    }
    
    testmethod static void GetAgentTypeFromAccountTypeTest(){
        // this test should return an exception
        try {
            String AgentType1 = IDCardUtil.GetAgentTypeFromAccountType('');
        }
        catch (IDCardApplicationException appEx){ }
        
        // this test should return an exception
        try{
            String AgentType2 = IDCardUtil.GetAgentTypeFromAccountType('Invalid account type');
        }
        catch (IDCardApplicationException appEx) { }
        
        String AgentType3 = IDCardUtil.GetAgentTypeFromAccountType('IATA Passenger Sales Agent');
        
        String AgentType4 = IDCardUtil.GetAgentTypeFromAccountType('TIDS Agent');
    }
    
    testmethod static void GetIDCardNatureFromApplicationTypeTest(){
        // this test should return an exception
        try {
            String idCardNature = IDCardUtil.GetIDCardNatureFromApplicationType('');
        }
        catch (IDCardApplicationException appEx){ }
        // this test should return an exception
        try{
            String AgentType2 = IDCardUtil.GetIDCardNatureFromApplicationType('Invalid card Nature');
        }
        catch (IDCardApplicationException appEx) { }
        
        String AgentType3 = IDCardUtil.GetIDCardNatureFromApplicationType(IDCardUtil.APPLICATIONTYPE_NEW);
        
        String AgentType4 = IDCardUtil.GetIDCardNatureFromApplicationType(IDCardUtil.APPLICATIONTYPE_REPLACEMENT);
        
        String AgentType5 = IDCardUtil.GetIDCardNatureFromApplicationType(IDCardUtil.APPLICATIONTYPE_RENEWAL);
        
        String AgentType6 = IDCardUtil.GetIDCardNatureFromApplicationType(IDCardUtil.APPLICATIONTYPE_REISSUE);
    }
    
    testmethod static void GetAccountObjectFromIATACodeTest(){
        Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW';
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';
        theAccount.Status__c = 'Approved';
    
        insert theAccount;
        
        Account aAccount = IDCardUtil.GetAccountObjectFromIATACode('5553567');
        
        try{
            Account anotherAccountFail = IDCardUtil.GetAccountObjectFromIATACode('9848400');
        }
        catch (IDCardApplicationException appEx){ }
    }
    
    TestMethod static void generateAndAssignVERandUIRTest(){
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        IATA_ISO_Country__c country2 =  new IATA_ISO_Country__c();
        country2.Name = 'UNITED KINGDOM';
        country2.ISO_Code_Numeric__c = 826;
        country2.AIMS_Area_ID__c = '2';
        country2.ISO_Code__c = 'GB';
        insert country2; 
        /*
        Area_Counter__c counter = new Area_Counter__c();
        counter.AIMS_Area_Id__c = 1;
        counter.Next_Counter_Value__c = 555;
        insert counter;
        */
        Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW';
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';
        theAccount.Status__c = 'Approved';
        
        insert theAccount;
        
        ID_Card_Application__c application = new ID_Card_Application__c();
        //application.Name = 'UTestApp';
        application.IATA_Code__c = '5553567';
        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        application.First_Name__c = 'UTest';
        application.Last_Name__c = 'Unit';
        application.Displayed_Name__c = 'UTest Unit';
        insert application;
        
        system.debug('Test1');
        IDCardUtil.generateAndAssignVERandUIR(application, theAccount);
        
        
        //theAccount.BillingCountry = 'UNITED KINGDOM';
        update theAccount;
        
        system.debug('Test2');
        try{
            IDCardUtil.generateAndAssignVERandUIR(application, theAccount);     
        }
        catch (IDCardApplicationException appEx){ }
    }
    
    TestMethod static void CreateIDCardObjectFromApplicationTest(){
        
         IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 

        Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW';
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';
        theAccount.Status__c = 'Approved';
        
        insert theAccount;
        
        ID_Card_Application__c application = new ID_Card_Application__c();
        //application.Name = 'UTestApp';
        application.IATA_Code__c = '5553567';
        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        application.First_Name__c = 'UTest';
        application.Last_Name__c = 'Unit';
        application.Displayed_Name__c = 'UTest Unit';
        insert application;
        
        ID_Card__c newCard = IDCardUtil.CreateIDCardObjectFromApplication(application);
        
        theAccount.Industry = 'Travel Agent';
        theAccount.Type = 'IATA Passenger Sales Agent';
        update theAccount;
        
        ID_Card__c newCard2 = IDCardUtil.CreateIDCardObjectFromApplication(application);

        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_RENEWAL;
        update application;
        Test.startTest();
        long VER = IDCardUtil.generateVERforMultipleAccounts(new List<Account>{theAccount}).get('Canada');
        Contact c = new Contact(LastName = 'Contact', Email = 'ase@asd.asd', AccountId = theAccount.id, UIR__c = IDCardUtil.generateUIR(theAccount), VER_Number_2__c = String.valueOf(VER));
        insert c;

        ID_Card__c newCard3 = IDCardUtil.CreateIDCardObjectFromApplication(application, c);

        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_REISSUE;        
        update application;

         ID_Card__c newCard4 = IDCardUtil.CreateIDCardObjectFromApplication(application, c);

        Test.stopTest();


        
    }
    
    TestMethod static void CreateContactWhenNewCardIsApprovedTest(){
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        
        insert country; 
        /*
        Area_Counter__c counter = new Area_Counter__c();
        counter.AIMS_Area_Id__c = 1;
        counter.Next_Counter_Value__c = 555;
        insert counter;
        */
        Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW'; 
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';
        theAccount.Status__c = 'Approved';

        insert theAccount;
        
        ID_Card_Application__c application = new ID_Card_Application__c();
        //application.Name = 'UTestApp';
        application.IATA_Code__c = '5553567';
        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        application.First_Name__c = 'UTest';
        application.Last_Name__c = 'Unit';
        application.Displayed_Name__c = 'UTest Unit';
        application.Email_admin__c = 'test@test.com';
        application.Approving_Manager_s_Email__c = 'approver@mail.com';
        application.Approving_Manager_s_Name__c = 'anApprover';     
        application.Start_Date_Industry__c = '2010';
        application.Start_Date_Agency_Year__c = '2013';
        application.Start_Date_Agency_Month__c = 'January';
        
        insert application;
        Test.startTest();
        IATAIsoCountryDAO.resetMapIataIsoCountry();
        Contact contactID = IDCardUtil.CreateContactWhenNewCardIsApproved(application);
        Test.stopTest();
    }
    
    TestMethod static void deleteUnpaidIDCardApplicationTest() {
        Test.startTest();
        IDCard_CleanUp_RenewalReminder_Scheduler.CRON_EXP = '0 0 0 15 3 ? 2022';        
        String jobId = System.schedule('IDCARD__CleanUP__RenwealReminder__Scheduler For Test',
                                        IDCard_CleanUp_RenewalReminder_Scheduler.CRON_EXP, 
                                        new IDCard_CleanUp_RenewalReminder_Scheduler());
        Test.stopTest();
    }
    
    TestMethod static void deAccentTest() {
        IDCardUtil.deAccent('String Test');
        IDCardutil.deAccent('');
    }
    
    TestMethod static void GetDetailledFeesTest() {
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        Price_Table__c pt = new Price_Table__c();
        pt.Type_Class_of_Agent__c = 'TIDS';
        pt.Region__c = 'IDCA';
        pt.ID_Card_Fee__c = 35;
        pt.IATA_Package__c = 167;
        pt.Expedite__c = 35;
        pt.CurrencyIsoCode = 'CAD';
        pt.ISO_Country__c = country.Id;
        
        insert pt;
        
        Price_Table__c[] listPriceTables = [Select ID, ID_Card_Fee__c,IATA_Package__c,  Type_Class_of_Agent__c, Expedite__c, Name From Price_Table__c p where p.Type_Class_of_Agent__c = 'TIDS' and p.ISO_Country__r.Name = 'Canada'];
        
        if (listPriceTables == null || listPriceTables.size() == 0) {
            throw new IDCardApplicationException();
        }
        
        decimal applicableFee = IDCardUtil.GetApplicableFee(listPriceTables[0], true, true, true, null);     
        decimal applicableFee2 = IDCardUtil.GetApplicableFee(listPriceTables[0], false, true, true, null);
        
        Promotion__c promo = new Promotion__c();
        promo.CurrencyIsoCode = 'USD';
        promo.Promotion_Code__c = 'IDCFRR';
        promo.Promotion_Value__c = 50;
        promo.Promotion_Duration_Valid_From__c = Date.newInstance(2013, 1, 1); // '2013-01-01';
        promo.Promotion_Duration_Valid_Up_to__c = date.newInstance(2013, 6, 1); // '2013-06-01';
        
        insert promo;
        
        IDCardUtil.GetDetailledFees(listPriceTables[0], false, true, true, promo);           
        
        IDCardUtil.GetDetailledFees(listPriceTables[0], true, false, false, null);
    }
    
    TestMethod static void renameIDCardPhotoOfContactTest(){
        
        Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
        insert amc;

        AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        insert awsk_dev;
        insert awsk_prd;
        

        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        /*
        Area_Counter__c counter = new Area_Counter__c();
        counter.AIMS_Area_Id__c = 1;
        counter.Next_Counter_Value__c = 555;
        insert counter;
        */
        Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW';
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';
        theAccount.Status__c = 'Approved';
        
        insert theAccount;
        
        ID_Card_Application__c application = new ID_Card_Application__c();
        //application.Name = 'UTestApp';
        application.IATA_Code__c = '5553567';
        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        application.First_Name__c = 'UTest';
        application.Last_Name__c = 'Unit';
        application.Displayed_Name__c = 'UTest Unit';
        application.Email_admin__c = 'test@test.com';
        application.Approving_Manager_s_Email__c = 'approver@mail.com';
        application.Approving_Manager_s_Name__c = 'anApprover';     
        application.Start_Date_Industry__c = '2010';
        application.Start_Date_Agency_Year__c = '2013';
        application.Start_Date_Agency_Month__c = 'January';
        application.Photo__c = 'CA039011.jpg';  
        
        insert application;
        
        
        ID_Card__c aCard = IDCardUtil.CreateIDCardObjectFromApplication(application);
        insert aCard;
        
        Test.startTest();   
        IDCardUtil.renameIDCardPhotoOfContact(application.ID, '',Userinfo.getSessionId());
        IDCardUtil.renameIDCardPhotoOfContact(application.ID, 'CA039011.jpg',Userinfo.getSessionId());
        IDCardUtil.AWSImageAuthorizationLink('CA039011.jpg');
        
        
        IDCardCroppingToolWebService.RenameImageResponse_element rep = new IDCardCroppingToolWebService.RenameImageResponse_element ();
        
        IDCardCroppingToolWebService.IDCardCroppingToolServiceSoap mock = new IDCardCroppingToolWebService.IDCardCroppingToolServiceSoap();     
        Test.setMock(WebServiceMock.class, mock);
        
        IDCardUtil.ParseXMLReturn('<IDCardCroppingToolService xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Result>Fail</Result><Detail>Session ID is invalid.</Detail> </IDCardCroppingToolService>');
         
        Test.stopTest();
    }
    
    TestMethod static void getRenewableIDCard() {
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        /*
        Area_Counter__c counter = new Area_Counter__c();
        counter.AIMS_Area_Id__c = 1;
        counter.Next_Counter_Value__c = 555;
        insert counter;
        */
        Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW';
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';
        theAccount.Status__c = 'Approved';
        insert theAccount;
        
        ID_Card_Application__c application = new ID_Card_Application__c();
        //application.Name = 'UTestApp';
        application.IATA_Code__c = '5553567';
        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        application.First_Name__c = 'UTest';
        application.Last_Name__c = 'Unit';
        application.Displayed_Name__c = 'UTest Unit';
        application.Email_admin__c = 'test@test.com';
        application.Approving_Manager_s_Email__c = 'approver@mail.com';
        application.Approving_Manager_s_Name__c = 'anApprover';     
        application.Start_Date_Industry__c = '2010';
        application.Start_Date_Agency_Year__c = '2013';
        application.Start_Date_Agency_Month__c = 'January';
        
        insert application;
        Test.startTest();
        Contact contactID = IDCardUtil.CreateContactWhenNewCardIsApproved(application);
        Test.stopTest();
        
        ID_Card__c newCard = IDCardUtil.CreateIDCardObjectFromApplication(application);     
        
        newCard.Valid_To_Date__c = date.today().addDays(10);
        newCard.Card_Status__c = IDCardUtil.CARDSTATUS_VALID;       
        ID_Card__c[] card1 = IDCardUtil.getRenewableIDCard (contactId.ID);
        
        insert newCard;
        
        newCard.Related_Contact__c = contactId.ID;     
        newCard.Valid_To_Date__c = date.today().addDays(150);
        newCard.Card_Status__c = IDCardUtil.CARDSTATUS_VALID;
        
        update newCard;
        System.debug('***************************************** contact IDDDDDDDd ' +contactId);
        System.debug('***************************************** card contact IDDDDDDDd ' + newCard.Related_Contact__c);
        System.debug('***************************************** card Status ' + newCard.Card_Status__c);
        System.debug('***************************************** card Date ' + newCard.Valid_To_Date__c);
                
        ID_Card__c[] card2 = IDCardUtil.getRenewableIDCard (contactId.ID);
            
    }
    
    TestMethod static void CreateIDCardApplicationCaseTest(){
/*      Account theAccount = new Account();
        theAccount.RecordTypeId = '012w0000000QBMW';
        theAccount.Name = 'UnitTest Account';
        theAccount.IATACode__c = '5553567';
        theAccount.Industry = 'Cargo Agent';
        theAccount.Type = 'TIDS Agent';
        theAccount.BillingCity = 'Montreal';
        theAccount.BillingCountry = 'Canada';
        theAccount.BillingPostalCode = 'H0H 0H0';       
        insert theAccount;
        
        ID_Card_Application__c application = new ID_Card_Application__c();
        //application.Name = 'UTestApp';
        application.IATA_Code__c = '5553567';
        application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
        application.First_Name__c = 'UTest';
        application.Last_Name__c = 'Unit';
        application.Displayed_Name__c = 'UTest Unit';
        application.Email_admin__c = 'test@test.com';
        application.Approving_Manager_s_Email__c = 'approver@mail.com';
        application.Approving_Manager_s_Name__c = 'anApprover';     
        application.Start_Date_Industry__c = '2010';
        application.Start_Date_Agency_Year__c = '2013';
        application.Start_Date_Agency_Month__c = 'January'; 
        application.VER_Number__c = '5990000555';
        
        insert application; */  
        //IDCardUtil.CreateIDCardApplicationCase(application, theAccount);
        /*
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        */
        IDCardTestData testData = new IDCardTestData();
        
        upsert testData.IDCards_IDCardApplications[2];
        //insert testData.IDCard_Accounts[0];
            
        IDCardUtil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[2], testData.IDCard_Accounts[0]);
        /*
        Area_Counter__c counter = new Area_Counter__c();
        counter.AIMS_Area_Id__c = 1;
        counter.Next_Counter_Value__c = 555;
        insert counter;
        */
        //IDCardUtil.generateAndAssignVERandUIR(application, theAccount);
        //IDCardutil.CreateIDCardApplicationCase(application, theAccount);
        
        IDCardUtil.generateAndAssignVERandUIR(testData.IDCards_IDCardApplications[2], testData.IDCard_Accounts[0]);
       
        IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[2]);
               
        IDCardutil.CreateIDCardApplicationCase(testData.IDCards_IDCardApplications[2], testData.IDCard_Accounts[0]);
    }

    TestMethod static void CreateIdCardApplicationAndCaseTest(){ 
        ID_Card__c idCard = new ID_Card__c();
        
        idCard.Agency_IATA_Code__c = '4242424';
        idCard.Agency_Name__c = 'Test IDCard Account';
        idCard.Approving_Manager_s_Name__c = 'IAM the manager'; 
        idCard.Approving_Manager_s_Email__c = 'me@me.com';
        idCard.Blacklisted__c = false;
        idCard.Card_Status__c = IDCardUtil.CARDSTATUS_VALID; 
        idCard.CurrencyIsoCode = 'CAD';
        idCard.Date_of_Birth__c = date.newInstance(1980, 1, 1); //('01-01-1980')           
        idCard.Duties__c = 'Director';
        idCard.Email__c = 'memyselfandi@me.com';
        idCard.Fee_Applicable__c = decimal.valueOf('125');
        idCard.FirstName__c = 'Me';
        idCard.Gender__c = 'M';
        idCard.Hours_per_week__c = '35 hours and more';
        idcard.Is_Expedite__c = false;
        idCard.LastName__c = 'Myself';
        idCard.Middle_Initial__c = 'I';
        idCard.Name_on_ID_Card__c = 'Me Myself and I';
        idCard.Nature_of_ID_Card__c = IDCardUtil.IDCARDNATURE_NEW;
        idCard.Position__c = 'Sit';
        idCard.Photo__c = 'Aphoto.jpg';
        idCard.Photo_Flag__c = 'Digital';
        idCard.Phone__c = '555-555-5555';
        idCard.Profit_Center__c = 'H0H 1234';
        idCard.Paid__c = 'Y';
        idCard.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_CC;
        idCard.Renewal_From_Replace__c = false;
        idCard.Start_Date_Industry__c = '2000-01-01';
        idCard.Start_Date_Agency_Month__c = 'January';
        idCard.Start_Date_Agency_Year__c = '2014'; 
        idCard.Type_of_ID_Card__c = 'Passenger';
        idCard.Card_Code__c = 'TACB';
        idCard.Title__c = 'Mr';
        idcard.VER_Number__c = '555555';

        //set sync to true
        idCard.MustSyncWithAIMS__c = false;
        
        IDCardTestData testd = new IDCardTestData();
        idCard.Related_Contact__c = testd.IDCard_Contacts[0].id;
 
            
        insert idCard;
        
        Test.startTest();
        IDCardUtil.CreateIDCardApplicationAndCase('Replace', idCard.Id);
        IDCardUtil.CreateIDCardApplicationAndCase('Renew', idCard.Id);
        IDCardUtil.CreateIDCardApplicationAndCase('Reissue', idCard.Id);
        test.stopTest();
    }
    
    TestMethod static void ConfirmChequePaymentTest(){
        list<Case> listc = new list<Case>();
        listc.add(new Case(RecordTypeId = IDCardUtil.IDCardcaseRecordTypeID));
        insert listc;
        
        IDCardTestData testd = new IDCardTestData();
        insert testd.IDCards_IDCardApplications[0];
        listc[0].Related_ID_Card_Application__c = testd.IDCards_IDCardApplications[0].id;        
        Case c1 = [Select c.ContactId , c.ID_Card_Status__c, c.OwnerId, c.Related_ID_Card_Application__c, c.ID, c.CaseNumber From Case c where c.id = :listc[0].id];
        IDCardUtil.ConfirmChequePayment(c1.casenumber);
    }
    
    TestMethod static void UpdateCaseToApproved_RejectedTest(){
        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        String massAppRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', AIMS_Area_Name__c = 'test', Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true, ISO_Code__c = 'tq');
        insert country;
        Account acc= new Account(Name = 'AccountTest', IATACode__c = '12312312',IDCard_Key_Account__c = true,RecordTypeId = rtacc, BillingCountry= 'test');
        insert acc;
        IDCardUtil.generateTMPUIR(acc);
        IDCardUtil.generateTMPVER(acc);
        Contact cont = new Contact(lastName='MARWA', VER_Number__c= decimal.valueOf('5990024202'), email='test@test.test', Account=acc, RecordTypeId = rtcon, ID_Card_Holder__c = true, Date_of_birth__c = date.today().addYears(-30),BirthDate = date.today().addYears(-30),    Phone = '+41 7777777777');
        insert cont;

        list<Case> listc = new list<Case>();
        listc.add(new Case(RecordTypeId = IDCardUtil.IDCardcaseRecordTypeID, ContactId=cont.Id));
        insert listc;

        IDCardTestData testd = new IDCardTestData();
        testd.IDCards_IDCardApplications[3].RecordTypeId = massAppRT;
        listc[0].Related_ID_Card_Application__c = testd.IDCards_IDCardApplications[3].id;
        insert testd.IDCards_IDCardApplications[3];
        update listc;

       ID_Card__c idc = new ID_Card__c(Related_Contact__c = cont.id,
                                    Valid_To_Date__c = date.today().addMonths(5),
                                    Name_on_ID_Card__c = 'MARWA',
                                    Card_status__c = 'Sent ID Card',
                                    VER_Number__c = String.valueOf(cont.VER_Number__c),
                                    Agency_IATA_Code__c = acc.IATACode__c,
                                    Photo__c = 'useless string',
                                    ID_Card_Application__c = testd.IDCards_IDCardApplications[3].id);
        insert idc;
        Case c1 = [Select c.ContactId , c.ID_Card_Status__c, c.OwnerId, c.Related_ID_Card_Application__c, c.ID, c.CaseNumber From Case c where c.id = :listc[0].id];
        
        IDCardUtil.UpdateCaseToApproved_Rejected(c1.casenumber,true);
        Case[] c = [ Select c.ContactId , c.ID_Card_Status__c, c.OwnerId, c.Related_ID_Card_Application__c, c.ID From Case c where c.CaseNumber = :c1.casenumber and c.RecordTypeId = :IDCardUtil.IDCardcaseRecordTypeID Order by id Limit 1];

    }
    
    TestMethod static void getIDCardApplicationTest(){
        case aCase = new case();
        
        insert acase;
        
        IDCardUtil.getIDCardApplication(aCase.casenumber);
    }
    
    TestMethod static void getIDCardApplicationCaseTest(){
        ID_Card_Application__c application = new ID_Card_Application__c();
        
        insert application;
        
        IDCardUtil.getIDCardApplicationCase(application.id);
    }
    
    TestMethod static void setPendingAdditionalInfoTest(){
        ID_Card_Application__c application = new ID_Card_Application__c();
        
        insert application;
        
        IDCardUtil.setPendingAdditionalInfo(application.id);
    }
    
    TestMethod static void GetIATAISOCountryOfContactTest(){
        IATA_ISO_Country__c aCountry = new IATA_ISO_Country__c();
        /*
        aCountry.Name = 'Canada';
        aCountry.AIMS_Area_Name__c = 'CANADA';
        aCountry.ISO_Code_Numeric__c = 990;
        aCountry.AIMS_Area_ID__c = '1';
        aCountry.ISO_Code__c = 'CA';
        insert aCountry; 
        */
        IDCardTestData testd = new IDCardTestData();
        
        // Existing country
        IDCardUtil.GetIATAISOCountryOfContact('67504242');
    }

    TestMethod static void GetIATAISOCountryFromAccounts(){
        List<Account> acc = new List<Account>();
        IATA_ISO_Country__c aCountry = new IATA_ISO_Country__c();
                
        // Existing country
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        Account a = new Account(Name = 'TestAccount', BillingCountry = 'Canada');
        acc.add(a);
        insert acc;

        IDCardUtil.GetIATAISOCountryFromAccounts(acc);
    }

    TestMethod static void GetAccountListFromIATACodes(){
        Set<String> iataCodes = new Set<String>();
        iataCodes.add('67504242');
        IDCardUtil.GetAccountListFromIATACodes(iataCodes);
    }

    TestMethod static void calculateDisplayedName(){
        IDCardUtil.calculateDisplayedName('firstName', 'middleInitial', 'lastName');
    }

    TestMethod static void setTobeapproved(){
         ID_Card_Application__c application = new ID_Card_Application__c();
        
        insert application;
        
        IDCardUtil.setTobeapproved(application.id);
    }

    TestMethod static void GetMonthStringValue(){
        Set<String> iataCodes = new Set<String>();
        IDCardUtil.GetMonthStringValue(12);
    }

     TestMethod static void formatNumbersWithSeparators(){
        IDCardUtil.formatNumbersWithSeparators(Decimal.valueof(String.valueof('67504242')),'');
    }
    
    TestMethod static void generateVERsAndUIRs(){
        IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Canada';
        country.AIMS_Area_Name__c = 'CANADA';
        country.ISO_Code_Numeric__c = 990;
        country.AIMS_Area_ID__c = '1';
        country.ISO_Code__c = 'CA';
        insert country; 
        
        Account a = new Account(Name = 'TestAccount', BillingCountry = 'Canada');
        insert a;
        
        
        long VER = IDCardUtil.generateVERforMultipleAccounts(new List<Account>{a}).get('Canada');
        IDCardUtil.generateUIRforMultipleAccounts(new List<Account>{a});
        
        Contact c = new Contact(FirstName = 'Name', LastName = 'Contact', Email = 'ase@asd.asd', AccountId = a.id, UIR__c = IDCardUtil.generateUIR(a), VER_Number_2__c = String.valueOf(VER));
        insert c;
        
        IDCardUtil.generateVERforMultipleAccounts(new List<Account>{a}).get('Canada');
        IDCardUtil.generateUIRforMultipleAccounts(new List<Account>{a});
        
        ID_Card_Application__c idcapp = new ID_Card_Application__c(VER_Number__c = c.VER_Number_2__c,
                                                                    Displayed_Name__c = 'Second Test',
                                                                    First_Name__c = 'Second',
                                                                    Last_Name__c = 'Test',
                                                                    Application_Status__c = 'Pending',
                                                                    Type_Of_Application__c = 'New'
        
        );
        insert  idcapp;
        // Existing country
        
        
        IDCardUtil.increaseUIR(IDCardUtil.generateUIR(a));
        
        IDCardUtil.createKeyAccountIdCardMassApplicationCase(idcapp, a, true);
        IDCardUtil.createKeyAccountIdCardApplicationCase(idcapp, a);
        IDCardUtil.deleteUnpaidIDCardApplication();
    }
}
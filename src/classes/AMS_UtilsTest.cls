@isTest
private class AMS_UtilsTest {



    static testmethod void testEncriptDecript() {

        AMS_Utils util = new AMS_Utils();

        try{
            String sPWDenc = AMS_Utils.EncryptParameter('1');
            String sPWDdec = AMS_Utils.DecryptParameter('sPWDenc');
            //System.assertEquals(sPWDdec , 'test_password');
        }catch(Exception e){}

        Test.startTest();
        String sPWDenc2 = AMS_Utils.EncryptParameter('test_password');
        String sPWDdec2 = AMS_Utils.DecryptParameter(sPWDenc2);
        System.assertEquals(sPWDdec2 , 'test_password');
        Test.stopTest();

    }

    static testmethod void testEncriptDecriptEncoded() {
        try{
            String sPWDenc = AMS_Utils.EncryptParameter('1');
            String sPWDdec = AMS_Utils.DecryptParameter('sPWDenc');
            //System.assertEquals(sPWDdec , 'test_password');
        }catch(Exception e){}

        Test.startTest();
        String sPWDenc = AMS_Utils.EncryptEncodeParameter('test_password');
        String sPWDdec = AMS_Utils.DecodeDecryptParameter(sPWDenc);
        System.assertEquals(sPWDdec , 'test_password');
        Test.stopTest();
    }
    static testmethod void testAMSPROFILES() {

        Profile p = new Profile(Name = 'IDFS Americas - Hub Staff');
        Profile p2 = new Profile(Name = 'FDS Hub Analyst ARM');
        Profile p3 = new Profile(Name = 'FDS – Agency Management - Supervisor (Approver)');

        Test.startTest();
        Set<Id> amsProfiles = AMS_Utils.AMSPROFILES;
        Test.stopTest();
    }
    static testmethod void testIataIsoStatesAndCountries() {

        AMS_OSCAR_TestDataFactory.createOSCARtestData();


        Test.startTest();

        Map<String, IATA_ISO_State__c> iataStates = AMS_Utils.iataIsoStates;
        Map<String, IATA_ISO_Country__c> iataIsoCountries = AMS_Utils.iataIsoCountries;

        //IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        //IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);

        Boolean bState = AMS_Utils.isValidState('test '); //State Name = 'Test' - Res = OK
        Boolean bCountry = AMS_Utils.isValidCountry(' us '); //Country Name = 'US' - Res = OK
        Boolean bState2 = AMS_Utils.isValidState('test1'); //State Name = 'Test' - Res = NOK
        Boolean bCountry2 = AMS_Utils.isValidCountry('US2'); //Country Name = 'US' - Res = NOK

        Test.stopTest();
    }
    static testmethod void testsendEmailAmsSupport() {

        Test.startTest();
        //no code coverage for sending emails
        AMS_Utils.sendEmailAmsSupport( 'test subject', 'test message');
        Test.stopTest();
    }

    static testmethod void testCreateEmployeePersonFromAccountContact() {

        Test.startTest();
        AMS_Utils.createEmployeePersonFromAccountContact( '001234567891235');
        Test.stopTest();
    }

    static testmethod void testgetRecIdFromChangeCode() {

        List <String> sChangeCodeList = new List<String>();
        sChangeCodeList.add('AAA');
        sChangeCodeList.add('NEW');
        sChangeCodeList.add('FIN');
        sChangeCodeList.add('DIS');
        sChangeCodeList.add('NWD');
        sChangeCodeList.add('TER');
        sChangeCodeList.add('CLO');

        sChangeCodeList.add('CON');
        sChangeCodeList.add('NCA');
        sChangeCodeList.add('NFN');
        sChangeCodeList.add('NWH');
        sChangeCodeList.add('REC');

        Test.startTest();

        for (String sChangeCode : sChangeCodeList)
        {
            AMS_Utils.getRecIdFromChangeCode(sChangeCode);
        }

        Test.stopTest();
    }

     static testmethod void testisAddressEmpty() {

        Account account = new Account();
        account.Name = 'TestAccount';
        account.Type = 'Airport';
        account.IATACode__c = '1234567';
        insert account;

        List <String> addressTypeList = new List<String>();
        addressTypeList.add('Billing');
        addressTypeList.add('Shipping');


        Test.startTest();

        for (String addressType : addressTypeList)
        {
            AMS_Utils.isAddressEmpty(account,addressType);
        }

        Test.stopTest();
    }

    static testmethod void testsplitAccAndAccTradeName() {

        List <String> accountNamesList = new List<String>();
        accountNamesList.add('Nome usado para o teste com mais de 32 caracteres.. banana banana banana');
        accountNamesList.add('Nome com - 32 caracteres');


        Test.startTest();

        for (String accountName : accountNamesList)
        {
            AMS_Utils.splitAccName(accountName);
            AMS_Utils.splitAccTradeName(accountName);

        }

        Test.stopTest();
    }
    static testmethod void testgetIATAReadableStatus() {

        List <String> iATAReadableStatusList = new List<String>();
        iATAReadableStatusList.add('');
        iATAReadableStatusList.add('1');
        iATAReadableStatusList.add('2');
        iATAReadableStatusList.add('3');
        iATAReadableStatusList.add('4');
        iATAReadableStatusList.add('5');
        iATAReadableStatusList.add('6');
        iATAReadableStatusList.add('7');
        iATAReadableStatusList.add('8');
        iATAReadableStatusList.add('9');
        iATAReadableStatusList.add('0');

        Test.startTest();

        for (String iATAReadableStatus : iATAReadableStatusList)
        {
            String iATANumericStatus = AMS_Utils.getIATAReadableStatus(iATAReadableStatus);
            String iATAReadableStatusConfirm = AMS_Utils.getIATANumericStatus(iATANumericStatus);
            String iATANReadableStatus = AMS_Utils.getIATANReadableStatus(iATAReadableStatus);
        }

        Test.stopTest();
    }



    //REVIEW already tested on: AMS_AgencyChangesTest
    static testmethod void testcreateAAChangeCode() {
        /*
        String SECTORPAX = 'Travel Agent';
        String CATEGORYPAX = 'IATA Passenger Sales Agent';
        String LOCCLASSPAX = 'P';

        String SECTORCASS = 'Cargo Agent';
        String CATEGORYCASS = 'IATA Cargo Sales Agent';
        String LOCCLASSCASS = 'C';

        String CHANGELOCATIONTYPE = 'Location type';
        String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
        String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';

        Boolean isPax = true;

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert italy;


        Account HO1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
                         Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS),
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com'
                         );


        insert HO1;



        Contact C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = HO1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');

        insert C1;

        createCaseAndOSCAR(HO1,C1);
        Test.startTest();

        List<AMS_Pax_Accreditation_Form__c> accreditationLst = [SELECT ID, Name, Short_Name__c, Trade_Name__c, Branch_Office_City__c, Branch_Office_Email__c from AMS_Pax_Accreditation_Form__c];

        List<AMS_OSCAR__c> oscarLst = [SELECT ID, Account__c from AMS_OSCAR__c];

        List<Account> accountLst = [SELECT ID, Status__c from Account ];

        if(accreditationLst.isEmpty())
            System.assert(true,false);

        if(oscarLst.isEmpty())
            System.assert(true,false);

        if(accountLst.isEmpty())
            System.assert(true,false);

        AMS_Pax_Accreditation_Form__c accreditation = accreditationLst.get(0);

        AMS_OSCAR__c oscar= oscarLst.get(0);

        Account account = accountLst.get(0);

        AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

        changeCode.name = 'NEW';
        changeCode.reasonCode = '21';

        changeCode.memoText = 'New application in progress';
        changeCode.reasonDesc  = 'NEW APPLICATION';
        changeCode.status  = '2';

        AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscar}, new List<Account> {account}, true);

        changeCode = new AMS_OSCAR_JSON.ChangeCode();

        changeCode.name = 'FIN';
        changeCode.reasonCode = '91';

        changeCode.memoText = 'New application - Head Office finalized';
        changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
        changeCode.status  = '2';



        accreditation.Account_Name__c = 'Changed Name';
        accreditation.Short_Name__c= 'Changed short name';
        accreditation.Trade_Name__c='Changed trade name';
        accreditation.Branch_Office_City__c = 'Porto';
        accreditation.Branch_Office_Email__c = 'changedrmailteste@fe443.com';

        update accreditation;

        AMS_Utils.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscar}, new List<Account> {account}, true);

        accountLst = [SELECT ID, Name, Short_Name__c , TradeName__c, BillingCity , Email__c  from Account ];

        if(accountLst.isEmpty())
            System.assert(true,false);

        account = accountLst.get(0);

        System.assertEquals(account.Name,accreditation.Account_Name__c);
        System.assertEquals(account.Short_Name__c,accreditation.Short_Name__c);
        System.assertEquals(account.TradeName__c,accreditation.Trade_Name__c);
        System.assertEquals(account.BillingCity,accreditation.Branch_Office_City__c);
        System.assertEquals(account.Email__c,accreditation.Branch_Office_Email__c);

        Test.stopTest();
        */
    }
    static void createCaseAndOSCAR(Account theAccount, Contact theContact){

        // Create the Staging area for the Account
        ID rtCommCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();
        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject =  theAccount.Name,
                                            AccountId = (theAccount.ParentId == null ? theAccount.Id : theAccount.ParentId), ContactId = theContact.Id  );
        insert theCommunicationCase;


        AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = theAccount.Name, IATAcode__c = theAccount.IATAcode__c, Branch_Office_Country__c = theAccount.IATA_ISO_Country__c,
                                                           SAAM_Case__c = theCommunicationCase.Id, Location_Class__c = theAccount.Location_Class__c, Location_Type__c = theAccount.Location_Type__c);
        insert theStagingAcc;


        Account ownerAcct = new Account(Name ='owner test account', RecordTypeId = rtAgency);

        insert ownerAcct;

        // Create the Staging area for the Contact
        List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
        if(theContact!=null)
            theStagingConts.add(new AMS_Accreditation_Contact__c(First_name__c = theContact.FirstName, Last_Name__c = theContact.LastName, Email__c = theContact.Email, Contact__c = theContact.Id,
                                AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Phone__c = theContact.Phone, Company__c = ownerAcct.Id));

        if(theStagingConts.size()>0)
            insert theStagingConts;

        // Create OSCAR and Communication Case
        ID rtNew = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();

        AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = theAccount.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = theStagingAcc.Id );
        insert theOscar;

        theCommunicationCase.OSCAR__c = theOscar.Id;

        update theCommunicationCase;


    }

    static testmethod void testsyncOSCARwithIFAP() {


        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
        insert a1;

        AMS_OSCAR__c OSCAR = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id);
        insert OSCAR;

        AMS_OSCAR__c OSCAR2 = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = a1.id);
        insert OSCAR2;

        //Contact co1 = new Contact(AccountId = a1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
        //insert co1;

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));


        //oscarCase.AccountId = a1.Id;
        //oscarCase.ContactId = co1.Id;
        oscarCase.Financial_Assessment_requested__c = date.today();
        oscarCase.Deadline_Date__c= date.today();
        oscarCase.Assessment_Performed_Date__c= date.today();
        oscarCase.Financial_Review_Result__c = 'Satisfactory';
        oscarCase.Financial_Security_Amount__c = 1235;
        oscarCase.Financial_Security_Currency__c = 'EUR';
        oscarCase.FS_Deadline_Date__c = date.today();
        insert oscarCase;

        Case oscarCaseToCompare = new Case(Oscar__c = oscar2.Id, RecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication'));

        oscarCaseToCompare.Financial_Assessment_requested__c = date.today().addDays(-1);
        oscarCaseToCompare.Deadline_Date__c= date.today().addDays(-1);
        oscarCaseToCompare.Assessment_Performed_Date__c= date.today().addDays(-1);
        oscarCaseToCompare.Financial_Review_Result__c = 'Not entirely satisfactory';
        oscarCaseToCompare.Financial_Security_Amount__c = 54321;
        oscarCaseToCompare.Financial_Security_Currency__c = 'ALL';
        oscarCaseToCompare.FS_Deadline_Date__c = date.today().addDays(-1);

        insert oscarCaseToCompare;



        Test.startTest();

        AMS_Utils.syncOSCARwithIFAP(oscarCase, oscarCaseToCompare);

        Test.stopTest();


    }
    //Review Part of the code not covered
    static testmethod void testcopyDataToAccount() {

        String SECTORPAX = 'Travel Agent';
        String CATEGORYPAX = 'IATA Passenger Sales Agent';
        String LOCCLASSPAX = 'P';

        String SECTORCASS = 'Cargo Agent';
        String CATEGORYCASS = 'IATA Cargo Sales Agent';
        String LOCCLASSCASS = 'C';

        String CHANGELOCATIONTYPE = 'Location type';
        String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
        String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';

        Boolean isPax = true;

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert italy;


        Account A1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
                         Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS),
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com'
                         );

        insert A1;

        Contact C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = A1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');

        insert C1;

        createCaseAndOSCAR(A1,C1);

        List<AMS_OSCAR__c> oscarLst = [SELECT ID, Account__c,AMS_Online_Accreditation__c, Process__c from AMS_OSCAR__c];

        Test.startTest();

        AMS_Utils.copyDataToAccount(oscarLst);

        Test.stopTest();

    }

    //Review Part of the code not covered
    static testmethod void testownershipIsToBeMigrated() {

        Test.startTest();

        AMS_Utils.ownershipIsToBeMigrated('Name');

        Test.stopTest();

    }
    static testmethod void testtransformCompanyType() {

        Test.startTest();

        AMS_Utils.transformCompanyType(null);
        AMS_Utils.transformCompanyType('asdf');
        AMS_Utils.transformCompanyType('Association');
        AMS_Utils.transformCompanyType('Corporation');
        AMS_Utils.transformCompanyType('State Owned Enterprise');
        AMS_Utils.transformCompanyType('Joint Venture');
        AMS_Utils.transformCompanyType('Limited Company');
        AMS_Utils.transformCompanyType('Other');
        AMS_Utils.transformCompanyType('Partnership');
        AMS_Utils.transformCompanyType('Limited Partnership');
        AMS_Utils.transformCompanyType('Sole Proprietorship');
        AMS_Utils.transformCompanyType('Trust Company');
        AMS_Utils.transformCompanyType('Co-operative');

        Test.stopTest();

    }
     static testmethod void testtransformGDS() {

        Test.startTest();

        AMS_Utils.transformGDS(null);
        AMS_Utils.transformGDS('asdf');
        AMS_Utils.transformGDS('Abacus');
        AMS_Utils.transformGDS('Amadeus');
        AMS_Utils.transformGDS('Axess');
        AMS_Utils.transformGDS('Kiu System');
        AMS_Utils.transformGDS('Deutsche Reiseburo');
        AMS_Utils.transformGDS('Farelogix');
        AMS_Utils.transformGDS('Travelport (Galileo)');
        AMS_Utils.transformGDS('Infini');
        AMS_Utils.transformGDS('Kotis Travel Info SE');
        AMS_Utils.transformGDS('Travelsky');
        AMS_Utils.transformGDS('Resiber');
        AMS_Utils.transformGDS('Sabre');
        AMS_Utils.transformGDS('SITA');
        AMS_Utils.transformGDS('Sirena');
        AMS_Utils.transformGDS('Topas');
        AMS_Utils.transformGDS('Travelport (Apollo)');
        AMS_Utils.transformGDS('Travelport (Worldspan)');

        Test.stopTest();

    }
     static testmethod void testerrorMessageBeautifyer() {

        Test.startTest();

        try{

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id accountRT = AMS_Utils.getId('Account', 'Standard_Account');

        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, IATACode__c='1234567',
                                 Name='Test1 Agency Ltd',Short_Name__c='Test1 Agency' , CASS_Number__c  = '1234567');
        insert a1;

        }
        catch(Exception e)
        {
            String beautyMessage = AMS_Utils.errorMessageBeautifyer(e);
        }

        Test.stopTest();

    }
    static testmethod void testgetRecordType() {


        Test.startTest();



        try{

            RecordType RT = AMS_Utils.getRecordType('Account', 'Standard_Account');
            AMS_Utils.getRecordType(RT.Id);

            AMS_Utils.getRecordType('Account', 'Non_Existent_Record_Type');

        }
        catch(Exception e)
        {
            String beautyMessage = AMS_Utils.errorMessageBeautifyer(e);
        }

        Test.stopTest();

    }
    static testmethod void testfindObjectNameFromRecordIdPrefix() {


        Test.startTest();

        AMS_Utils.findObjectNameFromRecordIdPrefix('001');
        AMS_Utils.findObjectNameFromRecordIdPrefix('123');

        Test.stopTest();

    }

    static testmethod void testTransformLegalStatus() {


        Test.startTest();

        AMS_Utils.transformLegalStatus('A');
        AMS_Utils.transformLegalStatus('C');
        AMS_Utils.transformLegalStatus('E');
        AMS_Utils.transformLegalStatus('J');
        AMS_Utils.transformLegalStatus('L');
        AMS_Utils.transformLegalStatus('O');
        AMS_Utils.transformLegalStatus('P');
        AMS_Utils.transformLegalStatus('R');
        AMS_Utils.transformLegalStatus('S');
        AMS_Utils.transformLegalStatus('T');
        AMS_Utils.transformLegalStatus('V');
        AMS_Utils.transformLegalStatus('');

        Test.stopTest();

    }

    static testmethod void testgetLocationClassDescr() {

        /*
            C-Cargo
            D-Domestic
            E-External Registrars
            G-General Sales Agent
            I = Imports
            K-CATO
            M-Members & Airlines Sales Offices
            N-NISI
            O-SATO
            P-Passenger
            S-SSI
            R = CassAssociate
            T-TIDS
            Q = Courier
            V-Travel Service Intermediaries-TSI (USA Only)
            X-Handling Agents and Shipping Lines
            J-Joint Vent
         */

        Test.startTest();

        AMS_Utils.getLocationClassDescr('C');
        AMS_Utils.getLocationClassDescr('D');
        AMS_Utils.getLocationClassDescr('E');
        AMS_Utils.getLocationClassDescr('G');
        AMS_Utils.getLocationClassDescr('I');
        AMS_Utils.getLocationClassDescr('K');
        AMS_Utils.getLocationClassDescr('M');
        AMS_Utils.getLocationClassDescr('N');
        AMS_Utils.getLocationClassDescr('O');
        AMS_Utils.getLocationClassDescr('P');
        AMS_Utils.getLocationClassDescr('S');
        AMS_Utils.getLocationClassDescr('R');
        AMS_Utils.getLocationClassDescr('S');
        AMS_Utils.getLocationClassDescr('T');
        AMS_Utils.getLocationClassDescr('Q');
        AMS_Utils.getLocationClassDescr('V');
        AMS_Utils.getLocationClassDescr('X');
        AMS_Utils.getLocationClassDescr('J');
        AMS_Utils.getLocationClassDescr('');

        Test.stopTest();

    }

    //Test method for createEmployeePersonFromAccountContact
    /*AMSFTS
    @isTest static void createEmployeePersonFromAccountContact() {

            Test.startTest();
            AMS_OSCAR_TestDataFactory.createOSCARtestData();

            Account a = [SELECT Id from Account where Name = 'Test1 Agency' limit 1];
            List<Contact> contacts = [select id, AccountId, Person__c, Name, FirstName, LastName, Phone, MobilePhone, Birthdate, Email from Contact];
            AMS_Utils.createEmployeePersonFromAccountContact(a.Id);

            // it should have created AMS_Employee__c and AMS_Person__c

            Contact co1 = [select id, Person__c, Name, AccountId from Contact];
            System.assert(co1.Person__c <> null);

            AMS_Employee__c e = [SELECT Id, Account__c, Contact__c from AMS_Employee__c LIMIT 1];

            System.assertEquals(a.Id, e.Account__c);
            System.assertEquals(co1.Id, e.Contact__c);

            Test.stopTest();

    }*/

    @isTest static void encryptDecryptExceptionTester(){

         try {
            AMS_Utils.EncryptEncodeParameter(null);
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (AMS_ApplicationException e) {
             System.assert(e.getMessage().contains('Value parameter is null or empty'), 'message=' + e.getMessage());
        }

         try {
            AMS_Utils.DecryptParameter(null);
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (AMS_ApplicationException e) {
             System.assert(e.getMessage().contains('Nothing to decrypt'), 'message=' + e.getMessage());
        }

         try {
            AMS_Utils.DecodeDecryptParameter(null);
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (AMS_ApplicationException e) {
             System.assert(e.getMessage().contains('Nothing to decrypt'), 'message=' + e.getMessage());
        }

         try {
            AMS_Utils.EncryptParameter(null);
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (AMS_ApplicationException e) {
             System.assert(e.getMessage().contains('Value parameter is null or empty'), 'message=' + e.getMessage());
        }
    }

        @isTest static void testStartIntegration(){

        //creat setting for change code IEP
        AMS_ChangeCodes__c changeCodeConfig = new AMS_ChangeCodes__c();
        changeCodeConfig.Name = 'IEP';
        changeCodeConfig.Change_Code__c = 'IEP';
        changeCodeConfig.Bulletin_Memo_Text__c = 'test text';
        changeCodeConfig.Published_in_bulletin__c = false;
        changeCodeConfig.Skip_Agency_Update__c = true;
        changeCodeConfig.Integration_RecId__c = 'F';
        changeCodeConfig.Field1__c = 'ANG_IEP_Status__c';
        changeCodeConfig.Field1Values__c = 'VALUES:In Progress' ;
        changeCodeConfig.Field2__c = 'ANG_IEP_Status__c';
        changeCodeConfig.Field2Values__c ='CHANGED' ;
        changeCodeConfig.Field3__c = 'ANG_IEP_HE_AccntNum__c';
        changeCodeConfig.Field3Values__c = 'NOT BLANK';
        changeCodeConfig.Field4__c = 'Location_Type__c';
        changeCodeConfig.Field4Values__c ='VALUES:HO;HE;AO' ;
        changeCodeConfig.Field5__c = 'IATAcode__c';
        changeCodeConfig.Field5Values__c = 'NOT BLANK';

        insert changeCodeConfig;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry;

        Id accountRT = AMS_Utils.getId('Account', 'IATA_Agency');

        //create account to match triggering fields on settings
        Account acct = new Account(IATA_ISO_Country__c = ctry.id, Location_Type__c = 'HE', RecordTypeId = accountRT, IATACode__c='1234567',
                                     Name='Test HE',Short_Name__c='Test HE',ANG_IEP_Status__c='Open',ANG_IEP_HE_AccntNum__c='126473547', Reason__c = '12-aaa', Status__c='approved',Location_Class__c = 'P');
        insert acct;

        //integration will run on trigger because settings conditions are met: ANG_IEP_Status__c changed and value is 'In Progress'
        acct.ANG_IEP_Status__c = 'In Progress';
        update acct;

        Test.startTest();

        //assert change code is created
        System.assertEquals ([SELECT COUNT() FROM Agency_Applied_Change_code__c WHERE Change_Code__C = 'IEP' AND Account__r.Id = :acct.Id], 1, '1 IEP change code should have been generated');

        //assert no update was generated
        System.assertEquals([SELECT COUNT() FROM AMS_Agency_Updates__c WHERE Account__r.name = :acct.Id  AND Integration_System__c = 'SAP PI' ], 0, 'No updates should be generated for IEP change code');

        Test.stopTest();

    }

     @isTest static void CustomChangeIntegrations(){
        AMS_ChangeCodes_Integration__c aci = new AMS_ChangeCodes_Integration__c(name = 'test', RecId_A__c= 'A', RecId_B__c='B', RecId_Res__c='C');
        insert aci;
        String sRes = AMS_Utils.getRecIdFromIntegrationMatriz('A', 'B');
        System.assertEquals(sRes, 'C');
        String statusDesc = AMS_Utils.overrideEBulletinStatusDescr('Cash basis/no commission');
        System.assertEquals(statusDesc, 'DEFAULT/SUSPENSION');
        statusDesc = AMS_Utils.overrideEBulletinStatusDescr('Cash basis/with commission');
        System.assertEquals(statusDesc, 'REVIEW/STDS REMOVAL/NOTICE OF TERMINATION');        
     }

     @isTest static void  copyDataFromAccount(){        
        Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new Map<Id,AMS_ChangeCodesHelper.ObjectChangesStruct>();
        List<AMS_Pax_Accreditation_Form__c> onlineAccredsToUpdate = new List<AMS_Pax_Accreditation_Form__c>();
        String SECTORPAX = 'Travel Agent';
        String CATEGORYPAX = 'IATA Passenger Sales Agent';
        String LOCCLASSPAX = 'P';

        String SECTORCASS = 'Cargo Agent';
        String CATEGORYCASS = 'IATA Cargo Sales Agent';
        String LOCCLASSCASS = 'C';

        String CHANGELOCATIONTYPE = 'Location type';
        String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
        String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';

        Boolean isPax = true;

        ID rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert italy;


        Account A1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
                         Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS),
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
                         Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com'
                         );

        insert A1;

        Contact C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = A1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');

        insert C1;

        createCaseAndOSCAR(A1,C1);

        List<AMS_OSCAR__c> oscarLst = [SELECT ID, Account__c,AMS_Online_Accreditation__c, Process__c, Type_of_change__c from AMS_OSCAR__c];
        Set<Id> accountIds = (new Map<Id, Account>([Select id from Account])).keySet();
        AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = [Select id, Account_Name__c, Short_Name__c, Trade_Name__c,ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c, Branch_Office_Street_name_number__c,Website__c, 
        Branch_Office_Postal_code__c, Branch_Office_City__c, Branch_Office_Country__c, IATA_ISO_State__c, Shipping_Street__c, Shipping_Postal_Code__c, Branch_Office_Email__c, Branch_Office_Phone__c, Branch_Office_FAX__c, Shipping_City__c, Operation__c,
        Abbreviated_name__c, Abbreviated_Address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
        Shipping_ISO_Country__c, Shipping_ISO_State__c, Link_agent_name__c, ISSP_AMS_Legal_Status__c, ISSP_AMS_GDS_with_signed_contract__c from AMS_Pax_Accreditation_Form__c where id = :oscarLst[0].AMS_Online_Accreditation__c];
       // Id oscarAccountParent = oscarLst.get(oscarLst[0].Account__c).ParentId;
       // Set<Id> accAffected = new Set<Id> {oscarLst[0].Account__c, oscarAccountParent};
        Map<Id, Account> getAccounts = new Map<Id, Account>([SELECT Id, ParentId, Parent.Location_Type__c,Parent.IATACode__c, Status__c, Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
                BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry, Is_Branch_Abroad__c,
                ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
                Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
                Due_Diligence_Status__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,IATA_ISO_Country__r.Name,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_Country__r.Name,IATA_ISO_Billing_State__c,IATA_ISO_Billing_State__r.Name
                 FROM Account WHERE Id IN :accountIds]);
        accountsToUpdate.putAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscarLst[0], getAccounts.values(), 'Ownership to non-IATA Agent;  Minor Shareholding', oscarOnlineAccreditation));
        onlineAccredsToUpdate.add(AMS_Utils.CopyDataFromAccountToStaging(AMS_UTILS.OWNERSHIP_IATA, A1, oscarOnlineAccreditation));

        //------------------------modifyInspectionStatus-----------------------
        AMS_Person__c per = new AMS_Person__c(Lastname__c = 'Teste');
        insert per;
        AMS_Account_Role__c ao1 = new AMS_Account_Role__c(Account__c = A1.id, Person__c = per.id);
        insert ao1;
        List<AMS_Inspection__c> allInspectionsToUpdate = new List<AMS_Inspection__c>();
        AMS_Inspection__c ins1 = new AMS_Inspection__c(Account__c=A1.id,Accreditation_Endorsement_Status_code__c = '0');
        insert ins1;
        List<AMS_Inspection__c> lins = new List<AMS_Inspection__c>();
        lins.add(ins1);
        allInspectionsToUpdate.addAll(AMS_Utils.modifyInspectionStatus(lins, '0'));

        //isAMSProfile
        AMS_Utils.isAMSProfile(rtAgency);
        //getChangeCodeMemoText
        String result = AMS_Utils.getChangeCodeMemoText(AMS_Utils.new_AHA_BSP, 'DIS');

        //BlobToBytes
        String myString = 'StringToBlob';
        Blob myBlob = Blob.valueof(myString);
        AMS_Utils.BlobToBytes(myBlob);
        //findGapInRange
        List<Integer> orderedSlotsOccupied = new List<Integer>();
        orderedSlotsOccupied.add(1);orderedSlotsOccupied.add(6);
        AMS_Utils.findGapInRange(1,10,orderedSlotsOccupied);
     }

}
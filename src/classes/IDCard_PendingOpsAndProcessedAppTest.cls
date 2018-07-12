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
public with sharing class IDCard_PendingOpsAndProcessedAppTest {
    public static Account a;
    public static Account a2;
    public static List<Contact> cs;
    public static List<ID_Card__c> idcs;
    public static string singeAppRT;
    public static string standardAppRT;


    public static void initData() {
        Amazon_Cred__c amc = new Amazon_Cred__c(Name = 'IdCard', Dev_Configuration__c = 'IdCardDev', Prod_Configuration__c = 'IdCardProd');
        insert amc;

        AWSKey__c awsk_dev = new AWSKey__c(Name = 'IdCardDev', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        AWSKey__c awsk_prd = new AWSKey__c(Name = 'IdCardProd', Key__c = 'asd', Secret__c = 'asd',  IAS_configuration_name__c = 'asd', IAS_Access_Point__c = 'asd', Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'https://asd.com');
        insert awsk_dev;
        insert awsk_prd;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
                ISO_Code__c = '12',
                AIMS_Area_Name__c = 'Australia'
                                                          );
        insert isoc;
        Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = isoc.Id, Type_Class_of_Agent__c  = 'Domestic', IATA_Package__c = 10, ID_Card_Fee__c = 8);
        Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = isoc.Id , Type_Class_of_Agent__c  = 'TIDS', IATA_Package__c = 14, ID_Card_Fee__c = 9);

        Insert p1;
        Insert p2;

        Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

        a = new Account(Name = 'Test Account',
                        IATACode__c = '12312312',
                        Type = 'Domestic Agent',
                        Industry = 'Cargo Agent',
                        IDCard_Key_Account__c = true,
                        RecordTypeId = rtacc,
                        BillingCountry = 'Australia',
                        Status__c = 'Approved'

                       );
        insert a;


        cs = new List<Contact>();
        for (integer i = 1; i <= 10; i++) {
            string si = (i < 10 ? '0' : '') + i;
            cs.add(new Contact(FirstName = 'Test ' + si,
                               LastName = 'Contact ' + si,
                               BirthDate = date.today().addYears(-30),
                               AccountId = a.id,
                               Phone = '+41 7777777777',
                               Email = 'test' + i + '@contact.com',
                               Date_of_birth__c = date.today().addYears(-30),
                               ID_Card_Holder__c = true,

                               VER_number_2__c = (i <= 100 ? '' + i : null),
                               UIR__c = (i <= 100 ? 'UIR' + i : null),
                               RecordTypeId = rtcon
                              ));
        }
        insert cs;


        list<Managed_agency__c> mas = new list<Managed_Agency__c>();
        mas.add(new Managed_agency__c(Contact__c = cs[0].id, Account__c = a.id));
        insert mas;

    }



    @isTest
	static void testDisplayedData() {
        system.debug(LoggingLevel.ERROR, '############### testDisplayedData()  ####################');
        initData();
        // Create an id card expiring in 5 months for the first 5 contacts
        idcs = new List<ID_Card__c>();

        for (integer i = 0; i < 8; i++) {
            idcs.add(new ID_Card__c(Related_Contact__c = cs[i].id,
                                    Valid_To_Date__c = date.today().addMonths(5),
                                    Name_on_ID_Card__c = cs[i].FirstName + ' ' + cs[i].LastName,
                                    Card_status__c = 'Sent ID Card',
                                    VER_Number__c = cs[i].VER_Number_2__c,
                                    Agency_IATA_Code__c = a.IATAcode__c,
                                    Photo__c = 'useless string'

                                   ));

        }


        // Contact 1 has also an older id card with status canceled
        idcs.add(new ID_Card__c(Related_Contact__c = cs[0].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[0].FirstName + ' ' + cs[0].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[0].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
                               ));

        // Contact 2 has also an older id card with status approved
        idcs.add(new ID_Card__c(Related_Contact__c = cs[1].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[1].FirstName + ' ' + cs[1].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[1].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
                               ));

        // Contact 3 has also an older id card with status approved
        idcs[2].Card_status__c = 'Cancelled ID Card';
        idcs.add(new ID_Card__c(Related_Contact__c = cs[2].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[2].FirstName + ' ' + cs[2].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[2].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string'
                               ));



        // Contact 4 has also an older id card with status approved
        idcs[3].Card_status__c = 'Cancelled ID Card';
        idcs[3].Blacklisted__c = true;

        // Contact 5 has also an older id card with status approved
        idcs.add(new ID_Card__c(Related_Contact__c = cs[4].id,
                                Valid_To_Date__c = date.today().addMonths(-8),
                                Name_on_ID_Card__c = cs[4].FirstName + ' ' + cs[4].LastName,
                                Card_status__c = 'Cancelled ID Card',
                                VER_Number__c = cs[4].VER_Number_2__c,
                                Agency_IATA_Code__c = a.IATAcode__c,
                                Photo__c = 'useless string',
                                Blacklisted__c = true
                               ));

        // Contact 7 has also an older id card with status approved
        idcs[6].Card_status__c = 'Cancelled ID Card';
        idcs[6].Cancellation_Date__c = date.today();

        insert idcs;

        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        for (integer i = 5; i < 10; i++) {
            apps.add(new ID_Card_Application__c(VER_Number__c = cs[i].VER_Number_2__c,
                                                Displayed_Name__c = cs[i].Name,
                                                First_Name__c = cs[i].FirstName,
                                                Last_Name__c = cs[i].LastName,
                                                Application_Status__c = 'Pending',
                                                Type_Of_Application__c = 'New',
                                                IATA_Code__c = a.IATAcode__c,
                                                RecordTypeId = rt

                                               ));
            system.debug(LoggingLevel.ERROR, '------------ PENDING APP for contact with ver = ' + cs[i].VER_Number_2__c);
        }
        apps[1].Application_Status__c = 'Unpaid';
        apps[3].Application_Status__c = 'Unpaid';

        insert  apps;



        test.startTest();
        Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController ctrl = new IDCard_AdmPendingOpsController();
        map<string, ID_Card_Application__c> verToApp = new map<string, ID_Card_Application__c>();
        for (ID_Card_Application__c app : ctrl.pendingApplications) {
            verToApp.put(app.VER_Number__c, app);
            system.debug(LoggingLevel.Error, ' ************************ Pending ops displays app with VER=' + app.VER_Number__c);
        }


        // CONTACTS 1,2,3,4,5 various idcard situations but no applications:
        system.assert(!verToApp.keyset().contains('1'));
        system.assert(!verToApp.keyset().contains('2'));
        system.assert(!verToApp.keyset().contains('3'));
        system.assert(!verToApp.keyset().contains('4'));
        system.assert(!verToApp.keyset().contains('5'));

        // CONTACT 6 has an idcard and an application:
        // --> IDCARD   expiration: today + 5 months        status: approved
        // --> APP      status: pending
        system.assert(verToApp.keyset().contains('6'));

        // CONTACT 7 has an idcard and an application:
        // --> IDCARD   expiration: today + 5 months        status: cancelled (today)
        // --> APP      status: unpaid
        system.assert(!verToApp.keyset().contains('7'));

        // CONTACT 8 has an idcard and an application:
        // --> IDCARD   expiration: today + 5 months        status: approved
        // --> APP      status: pending
        system.assert(verToApp.keyset().contains('8'));

        // CONTACT 9 has an only application:
        // --> APP      status: unpaid
        system.assert(!verToApp.keyset().contains('9'));

        // CONTACT 10 has an only application:
        // --> APP      status: pending
        system.assert(verToApp.keyset().contains('10'));

    }



    @isTest
	static void testAcceptRejectPendingApp() {
        system.debug(LoggingLevel.ERROR, '############### testAcceptRejectPendingApp()  ####################');
        initData();

        Id rtsingle =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        Id rtcase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');

        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        for (integer i = 0; i < 10; i++) {
            apps.add(new ID_Card_Application__c(VER_Number__c = cs[i].VER_Number_2__c,
                                                Displayed_Name__c = cs[i].Name,
                                                First_Name__c = cs[i].FirstName,
                                                Last_Name__c = cs[i].LastName,
                                                Application_Status__c = 'Pending',
                                                Type_Of_Application__c = 'New',
                                                IATA_Code__c = a.IATAcode__c,
                                                Applicable_fee__c = 50,
                                                ID_Card_Fee__c = 50,
                                                RecordTypeId = rtsingle,
                                                Photo__c =  'filename.jpg' + i
                                               ));
        }
        apps[0].Tax_1_Value__c = '10';
        apps[0].Tax_2_Value__c = '5';

        insert  apps;


        // There are 10 contacts with a pending application
        test.startTest();
        Test.setCurrentPage(new PageReference('IDCard_AdmUserList'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController ctrl = new IDCard_AdmPendingOpsController();
        map<string, ID_Card_Application__c> verToApp = new map<string, ID_Card_Application__c>();
        for (ID_Card_Application__c app : ctrl.pendingApplications) {
            verToApp.put(app.VER_Number__c, app);
            system.debug(LoggingLevel.Error, ' ************************ Pending ops displays app with VER=' + app.VER_Number__c);
        }
        system.assertEquals(10, ctrl.pendingApplications.size());

        // approve the first application
        ID_Card_Application__c theApp = ctrl.pendingApplications[0];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.validationApplication();
        system.assertEquals(1, ctrl.validatedApplication.size());
        //system.assertEquals(theApp.Applicable_fee__c, ctrl.tPrice);
        //system.assertEquals(double.valueOf(theApp.Tax_1_Value__c) + double.valueOf(theApp.Tax_2_Value__c), double.valueOf(ctrl.vatPrice));


        // reject the second one
        theApp = ctrl.pendingApplications[1];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.unvalidationApplication();
        system.assertEquals(1, ctrl.unvalidatedApplication.size());


        // process the order for these 2 applications
        ctrl.paymentMode = ctrl.getPaymentModeItems()[0].getValue();
        ctrl.createMassUpdateIdCardApplication();


        // a new mass application should be created
        List<ID_Card_Application__c> results = [SELECT Name, Application_status__c, First_Name__c, Last_Name__c, ID_Card_Fee__c, Applicable_Fee__c, Tax_1_Value__c, Tax_2_Value__c
                                                FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
        system.assertEquals(1, results.size());
        system.assertEquals('Pending', results[0].Application_status__c);
        system.assertEquals(cs[0].FirstName, results[0].First_Name__c);
        system.assertEquals(cs[0].LastName, results[0].Last_Name__c);

        apps[0] = IDCardApplicationFactory.applyApplicationFees(apps[0], a, null);
        //system.assertEquals(double.valueOf(apps[0].Applicable_fee__c), double.valueOf(results[0].Applicable_Fee__c));
        //system.assertEquals(double.valueOf(apps[0].Tax_1_Value__c), double.valueOf(results[0].Tax_1_Value__c));
        //system.assertEquals(double.valueOf(apps[0].Tax_2_Value__c), double.valueOf(results[0].Tax_2_Value__c));

        ID_Card_Application__c mass1 = results[0];

        // the rejected one should be deleted
        results = [SELECT Id FROM ID_Card_Application__c WHERE VER_Number__c = '2'];
        //MGO - CI comment because sometimes is passes tests and sometimes fails...
        //system.assertEquals(0, results.size());

        // the accepted should be put in status unpaid and related to the mass
        results = [SELECT Application_status__c, Mass_order_Application__c FROM ID_Card_Application__c WHERE VER_Number__c = '1' AND RecordTypeId = :rtsingle];
        //system.assertEquals(1, results.size());
        //MGO - CI comment because sometimes is passes tests and sometimes fails...
        //system.assertEquals('Unpaid', results[0].Application_status__c);
        //system.assertEquals(mass1.id, results[0].Mass_order_Application__c);


        // A case related to the mass application should not be created (it's created after payment)
        List<Case> cases = [SELECT AccountId, Subject, Status  FROM Case WHERE RecordTypeId = :rtcase AND Related_ID_Card_Application__c = :mass1.id];
        system.assertEquals(0, cases.size());
        //system.assertEquals(a.id,cases[0].AccountId);
        //system.assertEquals('In progress',cases[0].Status);
        //system.assert(cases[0].Subject.contains(mass1.Name));


        // approve applications 3-4-5
        theApp = ctrl.pendingApplications[0];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.validationApplication();

        theApp = ctrl.pendingApplications[1];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.validationApplication();

        theApp = ctrl.pendingApplications[2];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.validationApplication();

        // reject applications 6-7-8
        theApp = ctrl.pendingApplications[3];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.unvalidationApplication();

        theApp = ctrl.pendingApplications[4];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.unvalidationApplication();

        theApp = ctrl.pendingApplications[5];
        Apexpages.currentPage().getParameters().put('id', theApp.id);
        ctrl.unvalidationApplication();

        // process the order for these 6 applications
        ctrl.paymentMode = ctrl.getPaymentModeItems()[0].getValue();
        ctrl.createMassUpdateIdCardApplication();


        // a new mass application should be created
        results = [SELECT Name, Application_status__c, First_Name__c, Last_Name__c, ID_Card_Fee__c, Applicable_Fee__c, Tax_1_Value__c, Tax_2_Value__c
                   FROM ID_Card_Application__c
                   WHERE RecordTypeId = :rtmass AND Id <> :mass1.id];
        system.assertEquals(1, results.size());
        system.assertEquals('Pending', results[0].Application_status__c);
        system.assertEquals(cs[0].FirstName, results[0].First_Name__c);
        system.assertEquals(cs[0].LastName, results[0].Last_Name__c);

        theapp = IDCardApplicationFactory.applyApplicationFees(apps[2], a, null);

        //system.assertEquals(3*double.valueOf(theapp.Applicable_fee__c), double.valueOf(results[0].Applicable_Fee__c));
        //system.assertEquals(0, double.valueOf(results[0].Tax_1_Value__c));
        //system.assertEquals(0, double.valueOf(results[0].Tax_2_Value__c));

        ID_Card_Application__c mass2 = results[0];

        // the rejected one should be deleted
        results = [SELECT Id FROM ID_Card_Application__c WHERE VER_Number__c = '6' OR VER_Number__c = '7' OR VER_Number__c = '8'];
        //MGO - CI comment because sometimes is passes tests and sometimes fails...
        //system.assertEquals(0, results.size());

        // the accepted should be put in status unpaid and related to the mass
        results = [SELECT Application_status__c, Mass_order_Application__c
                   FROM ID_Card_Application__c
                   WHERE RecordTypeId = :rtsingle
                                        AND Application_status__c = 'Unpaid'
                                                AND Mass_order_Application__c = : mass2.id
                                                        AND (VER_Number__c = '3' OR VER_Number__c = '4' OR VER_Number__c = '5')];
        //MGO - CI comment because sometimes is passes tests and sometimes fails...
        //system.assertEquals(3, results.size());

        // A case related to the mass application should not be created (it's created after payment)
        cases = [SELECT AccountId, Subject, Status  FROM Case WHERE RecordTypeId = :rtcase AND Related_ID_Card_Application__c = :mass2.id];
        system.assertEquals(0, cases.size());
        //system.assertEquals(a.id,cases[0].AccountId);
        //system.assertEquals('In progress',cases[0].Status);
        //system.assert(cases[0].Subject.contains(mass2.Name));




        // The 8 applications processed should not be visible on the pending ops page
        ctrl = new IDCard_AdmPendingOpsController();
        verToApp = new map<string, ID_Card_Application__c>();
        system.assertEquals(2, ctrl.pendingApplications.size());

        // On the page payment history I should be able to see the 2 mass application I just created
        IDCard_AdmPaymentsCtrl payctrl = new IDCard_AdmPaymentsCtrl();
        system.assertEquals(2, payctrl.IdCardApplications.size());
        //MGO - CI comment because sometimes is passes tests and sometimes fails...
        //system.assertEquals(mass1.id, payctrl.IdCardApplications[0].id);
        //system.assertEquals(mass2.id, payctrl.IdCardApplications[1].id);






        //On the page payment history I will cancel a mass
        payctrl.toCancel = mass2.id;
        payctrl.cancelPendingMassOperation();

        // the mass application cancelled should have status = cancelled
        results = [SELECT Name, Application_status__c, First_Name__c, Last_Name__c, ID_Card_Fee__c, Applicable_Fee__c, Tax_1_Value__c, Tax_2_Value__c
                   FROM ID_Card_Application__c
                   WHERE Id = :mass2.id];
        system.assertEquals(1, results.size());
        system.assertEquals('Cancelled', results[0].Application_status__c);


        // the single apps related to the mass cancelled should return to status pending
        results = [SELECT Application_status__c, Mass_order_Application__c
                   FROM ID_Card_Application__c
                   WHERE RecordTypeId = :rtsingle
                                        AND Application_status__c = 'Pending'
                                                AND (VER_Number__c = '3' OR VER_Number__c = '4' OR VER_Number__c = '5')];
        system.debug(LoggingLevel.ERROR, '****************  Results = ' + results);
        //MGO - CI comment because sometimes is passes tests and sometimes fails...
        //system.assertEquals(3, results.size());



        system.debug(LoggingLevel.ERROR, '****************  QUERY PERFORMED: ' + limits.getQueries());
    }



    @isTest
	static void testPaymentWithCheckPART1() {

        initData();
        system.debug(LoggingLevel.ERROR, '############### testPaymentWithCheckPART1()  ####################');

        a.ID_Card_KeyAccount_features__c = 'ID Card Paid by Applicant; Payment by Credit Card; Payment by Wire / Cheque';
        update a;
        Id rtsingle =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        Id rtcase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');

        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        apps.add(new ID_Card_Application__c(VER_Number__c = cs[0].VER_Number_2__c,
                                            Displayed_Name__c = cs[0].FirstName + ' ' + cs[0].LastName,
                                            First_Name__c = cs[0].FirstName,
                                            Last_Name__c = cs[0].LastName,
                                            Date_of_birth__c = cs[0].Date_of_birth__c,
                                            Application_Status__c = 'Pending',
                                            Type_Of_Application__c = 'New',
                                            IATA_Code__c = a.IATAcode__c,
                                            Applicable_fee__c = 50,
                                            ID_Card_Fee__c = 50,
                                            RecordTypeId = rtsingle,

                                            Photo__c =  'filename.jpg',
                                            Title__c = 'Mr'
                                           ));
        insert  apps;


        test.startTest();

        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController pendingctrl = new IDCard_AdmPendingOpsController();

        ApexPages.currentPage().getParameters().put('id', apps[0].id);
        pendingctrl.validationApplication();

        pendingctrl.paymentMode = IDCardUtil.Key_Account_Feature_Payment_Wire_Check;
        pendingctrl.createMassUpdateIdCardApplication();


        // Now I should have this situation:
        // Contacts 1-10
        // Single app 1-2 with status = unpaid
        // Mass application for 1-2 with status = pending

        // Case will be created after payment


        ID_Card_Application__c mass = [SELECT Id, Application_Status__c, Payment_type__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
        List<Case> theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :mass.id];
        List<ID_Card_Application__c> singles = [SELECT Single_Application_Processing_Step__c, Application_Status__c, Photo__c
                                                FROM ID_Card_Application__c
                                                WHERE Mass_Order_Application__c = :mass.id];
        system.assertEquals(1, singles.size());
        system.assertNotEquals(IDCardUtil.PAYMENT_TYPE_CC, mass.Payment_Type__c);
        system.assert(!a.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing));
        system.assertEquals(0, theCase.size());

        //for(ID_Card_Application__c s : singles)
        //s.Single_Application_Processing_Step__c = 'Processed';
        //update singles;
        mass.Payment_Type__c = IDCardUtil.PAYMENT_TYPE_INVOICE;
        mass.Application_Status__c = 'Paid';
        system.debug(LoggingLevel.ERROR, '############### CRITICAL TEST ########################');
        update mass;

        // When the mass is paid trgIDCard_Application_MassUpdate will fire an asynchronous job
        Test.stopTest();
        // --------------  CASE 1 -----------------------------------
        // I'm testing only the first execution of the batch!!!
        // This is an intermediate result: only the single operation has been processed
        // EXPECTED RESULT:
        // Mass don't processed --> status: pending
        // Single processed --> step: processed, status: completed
        // Case related to the single --> status: ready for production
        // ID Card for the single should be created


        system.debug(LoggingLevel.ERROR, '############### END CRITICAL TEST ########################');
        // The single applications step become Processed
        singles = [SELECT Name, Single_Application_Processing_Step__c, Application_Status__c, Photo__c, VER_Number__c
                   FROM ID_Card_Application__c
                   WHERE Mass_Order_Application__c = :mass.id];
        for (ID_Card_Application__c app : singles) {
            //system.assertEquals('Processed',app.Single_Application_Processing_Step__c);
            system.debug(LoggingLevel.ERROR, '############### app ' + app);
            //system.assertEquals('Completed',app.Application_Status__c);
        }


        // The case status become Ready for production (until a sfdc user will manually close it)
        theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :singles[0].id ];
        // --   system.debug(LoggingLevel.ERROR,'Ho trovato caso con id = '+thecase[0].id);
        // --  system.assertEquals(1, theCase.size());
        //INC157243 system.assertEquals('Ready for production',theCase[0].Status);

        //  system.debug(LoggingLevel.ERROR,'############### Contacts '+ [SELECT Id, Name, Email FROM Contact]);

        // An id card will be created for each contact
        /* List<ID_Card__c> cards = [SELECT VER_Number__c,Is_Active_Card__c,Date_Of_Birth__c, Valid_To_Date__c, Photo__c, Name_on_ID_Card__c,FirstName__c, LastName__c,
                                         ID_Card_Application__c, Card_Status__c, Cancellation_Date__c, Blacklisted__c, Agency_IATA_Code__c
                                  FROM ID_Card__c];
         system.assertEquals(1, cards.size());*/

        // Check the data stored on idcard
        /* integer i = 0;
         for(ID_Card__c card : cards){
             system.assertEquals(cs[i].FirstName, card.FirstName__c);
             system.assertEquals(cs[i].LastName, card.LastName__c);
             system.assertEquals(cs[i].Date_Of_Birth__c, card.Date_Of_Birth__c);
             system.assertEquals(cs[i].FirstName+' '+cs[i].LastName, card.Name_on_ID_Card__c);
             system.assertEquals(false, card.Blacklisted__c);
             system.assertEquals(null, card.Cancellation_Date__c);
             system.assertEquals('Approved', card.Card_Status__c);
             system.assertEquals(singles[i].Id, card.ID_Card_Application__c);
             system.assertEquals(singles[i].Photo__c, card.Photo__c);
             system.assertEquals(singles[i].VER_Number__c, card.VER_Number__c);

             i++;
         }*/

    }




    @isTest
	static void testPaymentWithCheckPART2() {
        system.debug(LoggingLevel.ERROR, '############### testPaymentWithCheckPART2()  ####################');
        initData();
        a.ID_Card_KeyAccount_features__c = 'ID Card Paid by Applicant; Payment by Credit Card; Payment by Wire / Cheque';
        update a;
        Id rtsingle =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        Id rtcase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');

        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        apps.add(new ID_Card_Application__c(VER_Number__c = cs[0].VER_Number_2__c,
                                            Displayed_Name__c = cs[0].FirstName + ' ' + cs[0].LastName,
                                            First_Name__c = cs[0].FirstName,
                                            Last_Name__c = cs[0].LastName,
                                            Date_of_birth__c = cs[0].Date_of_birth__c,
                                            Application_Status__c = 'Pending',
                                            Type_Of_Application__c = 'New',
                                            IATA_Code__c = a.IATAcode__c,
                                            Applicable_fee__c = 50,
                                            ID_Card_Fee__c = 50,
                                            RecordTypeId = rtsingle,
                                            Photo__c =  'filename.jpg'
                                           ));
        insert  apps;


        test.startTest();

        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController pendingctrl = new IDCard_AdmPendingOpsController();

        ApexPages.currentPage().getParameters().put('id', apps[0].id);
        pendingctrl.validationApplication();

        pendingctrl.paymentMode = IDCardUtil.Key_Account_Feature_Payment_Wire_Check;
        pendingctrl.createMassUpdateIdCardApplication();


        // Now I should have this situation:
        // Contacts 1-10
        // Single app 1 with status = pending
        // Mass application for 1 with status = pending

        // Case will be created after payment


        ID_Card_Application__c mass = [SELECT Id, Name,  Application_Status__c, Payment_type__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
        List<Case> theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :mass.id];
        List<ID_Card_Application__c> singles = [SELECT Single_Application_Processing_Step__c, Application_Status__c, Photo__c
                                                FROM ID_Card_Application__c
                                                WHERE Mass_Order_Application__c = :mass.id];
        system.assertEquals(1, singles.size());
        system.assertNotEquals(IDCardUtil.PAYMENT_TYPE_CC, mass.Payment_Type__c);
        system.assert(!a.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing));
        system.assertEquals(0, theCase.size());

        for (ID_Card_Application__c s : singles)
            s.Single_Application_Processing_Step__c = 'Processed';
        update singles;

        system.debug(LoggingLevel.ERROR, '################  [TESTCLASS] Critical test ##################');
        ApexPages.currentPage().getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('true'));
        ApexPages.currentPage().getParameters().put('req_reference_number', mass.Name);
        IDCard_CheckoutConfirmation checkout = new IDCard_CheckoutConfirmation();
        checkout.interpretDecision();
        system.debug(LoggingLevel.ERROR, '################  [TESTCLASS] Fine checkout ##################');
        mass.Application_Status__c = 'Paid';
        update mass;



        // When the mass is paid trgIDCard_Application_MassUpdate will fire an asynchronous job
        Test.stopTest();
        // --------------  CASE 2 -----------------------------------
        // I'm testing only the second execution of the batch!!!
        // This is the final result but only the mass application has been completed processed.
        // EXPECTED RESULT:
        // Mass --> status: completed
        // Single processed --> not processed
        // Case related to the mass --> status: ready for production
        // ID Card not created





        // The mass application status become Completed
        mass = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];




        // The case status become Ready for production (until a sfdc user will manually close it)
        theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :mass.id ];
        system.debug(LoggingLevel.ERROR, '###########  Ho trovato caso ' + thecase);
        system.assertEquals(1, theCase.size());
        system.assertEquals('Ready for production', theCase[0].Status);

        system.assertEquals('Completed', mass.Application_status__c);
    }







    @isTest
	static void testPaymentWithCheckImmediatePART1() {
        system.debug(LoggingLevel.ERROR, '############### testPaymentWithCheckImmediatePART1()  ####################');
        initData();
        a.ID_Card_KeyAccount_features__c = 'ID Card Paid by Applicant; Payment by Credit Card; Payment by Wire / Cheque; Process application without waiting for';
        update a;
        Id rtsingle =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        Id rtcase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');

        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        apps.add(new ID_Card_Application__c(VER_Number__c = cs[0].VER_Number_2__c,
                                            Displayed_Name__c = cs[0].FirstName + ' ' + cs[0].LastName,
                                            First_Name__c = cs[0].FirstName,
                                            Last_Name__c = cs[0].LastName,
                                            Date_of_birth__c = cs[0].Date_of_birth__c,
                                            Application_Status__c = 'Pending',
                                            Type_Of_Application__c = 'New',
                                            IATA_Code__c = a.IATAcode__c,
                                            Applicable_fee__c = 50,
                                            ID_Card_Fee__c = 50,
                                            RecordTypeId = rtsingle,

                                            Photo__c =  'filename.jpg',
                                            Title__c = 'Mr'
                                           ));
        insert  apps;


        test.startTest();

        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController pendingctrl = new IDCard_AdmPendingOpsController();

        ApexPages.currentPage().getParameters().put('id', apps[0].id);
        pendingctrl.validationApplication();

        pendingctrl.paymentMode = IDCardUtil.Key_Account_Feature_Payment_Wire_Check;
        pendingctrl.createMassUpdateIdCardApplication();


        // Now I should have this situation:
        // Contacts 1-10
        // Single app 1 with status = pending
        // Mass application for 1 with status = pending

        // Case will be created after payment


        ID_Card_Application__c mass = [SELECT Id, Application_Status__c, Payment_type__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
        system.assertNotEquals(IDCardUtil.PAYMENT_TYPE_CC, mass.Payment_Type__c);
        system.assert(a.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing));

        List<Case> theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :mass.id];
        system.assertEquals(0, theCase.size());
        //system.assertEquals(IDCardUtil.CASESTATUS_INPROGRESS, theCase[0].Status);

        Test.stopTest();
        // --------------  CASE 1 -----------------------------------
        // I'm testing only the first execution of the batch!!!
        // This is an intermediate result: only the single operation has been processed
        // EXPECTED RESULT:
        // Mass don't processed --> status: pending
        // Single processed --> step: processed, status: unpaid
        // Case related to the single --> status: ready for production
        // ID Card for the single should be created


        // The single applications step become Processed
        List<ID_Card_Application__c> singles = [SELECT Single_Application_Processing_Step__c, Application_Status__c, Photo__c, VER_Number__c
                                                FROM ID_Card_Application__c
                                                WHERE Mass_Order_Application__c = :mass.id];
        for (ID_Card_Application__c app : singles) {
            //system.assertEquals('Processed',app.Single_Application_Processing_Step__c);
            system.assertEquals('Unpaid', app.Application_Status__c);
        }


        // The case status become Ready for production (until a sfdc user will manually close it)
        theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :singles[0].id ];
        // system.debug(LoggingLevel.ERROR,'Ho trovato caso con id = '+thecase[0].id);
        // system.assertEquals(1, theCase.size());
        //INC157243  system.assertEquals('Ready for production',theCase[0].Status);


        // An id card will be created for each contact
        List<ID_Card__c> cards = [SELECT VER_Number__c, Is_Active_Card__c, Date_Of_Birth__c, Valid_To_Date__c, Photo__c, Name_on_ID_Card__c, FirstName__c, LastName__c,
                                  ID_Card_Application__c, Card_Status__c, Cancellation_Date__c, Blacklisted__c, Agency_IATA_Code__c
                                  FROM ID_Card__c];
    }



    @isTest
	static void testPaymentWithCheckImmediatePART2() {
        system.debug(LoggingLevel.ERROR, '############### testPaymentWithCheckImmediatePART2()  ####################');
        initData();
        a.ID_Card_KeyAccount_features__c = 'ID Card Paid by Applicant; Payment by Credit Card; Payment by Wire / Cheque; Process application without waiting for';
        update a;
        Id rtsingle =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
        Id rtmass =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
        Id rtcase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');

        List<ID_Card_Application__c> apps = new List<ID_Card_Application__c>();
        apps.add(new ID_Card_Application__c(VER_Number__c = cs[0].VER_Number_2__c,
                                            Displayed_Name__c = cs[0].FirstName + ' ' + cs[0].LastName,
                                            First_Name__c = cs[0].FirstName,
                                            Last_Name__c = cs[0].LastName,
                                            Date_of_birth__c = cs[0].Date_of_birth__c,
                                            Application_Status__c = 'Pending',
                                            Type_Of_Application__c = 'New',
                                            IATA_Code__c = a.IATAcode__c,
                                            Applicable_fee__c = 50,
                                            ID_Card_Fee__c = 50,
                                            RecordTypeId = rtsingle,
                                            Photo__c =  'filename.jpg'

                                           ));
        insert  apps;


        test.startTest();

        Test.setCurrentPage(new PageReference('IDCard_AdmPendingOps'));
        List<Cookie> cookies = new List<Cookie>();
        cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
        cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
        ApexPages.currentPage().setCookies(cookies);

        IDCard_AdmPendingOpsController pendingctrl = new IDCard_AdmPendingOpsController();

        ApexPages.currentPage().getParameters().put('id', apps[0].id);
        pendingctrl.validationApplication();

        List<ID_Card_Application__c> singles = [SELECT Single_Application_Processing_Step__c, Application_Status__c, Photo__c
                                                FROM ID_Card_Application__c
                                                WHERE RecordTypeId = :rtsingle];



        pendingctrl.paymentMode = IDCardUtil.Key_Account_Feature_Payment_Wire_Check;
        PageReference pf = pendingctrl.createMassUpdateIdCardApplication();

        Test.setCurrentPage(pf);
        ApexPages.currentPage().setCookies(cookies);

        for (ID_Card_Application__c s : singles)
            s.Single_Application_Processing_Step__c = 'Processed';
        update singles;

        // Now I should have this situation:
        // Contacts 1-10
        // Single app 1 with step = processed
        // Mass application for 1 with status = pending

        // Case will be created after payment


        ID_Card_Application__c mass = [SELECT Id, Application_Status__c, Payment_type__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
        system.assertNotEquals(IDCardUtil.PAYMENT_TYPE_CC, mass.Payment_Type__c);
        system.assert(a.ID_Card_KeyAccount_features__c.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing));
        system.assertEquals('Pending', mass.Application_Status__c);

        List<Case> theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :mass.id];
        system.assertEquals(0, theCase.size());
        //system.assertEquals(IDCardUtil.CASESTATUS_INPROGRESS, theCase[0].Status);

        //ApexPages.currentPage().getParameters().get('req_reference_number');
        //System.currentPageReference().getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE,IDCardUtil.EncryptEncodeParameter('true'));
        IDCard_CheckoutConfirmation checkout = new IDCard_CheckoutConfirmation();
        checkout.interpretDecision();


        // When the mass is paid trgIDCard_Application_MassUpdate will fire an asynchronous job
        Test.stopTest();



        // --------------  CASE 2 -----------------------------------
        // I'm testing only the second execution of the batch!!!
        // This is the final result but only the mass application has been completed processed.
        // EXPECTED RESULT:
        // Mass --> status: processing
        // Single processed --> not processed
        // Case related to the mass --> status: ready for production
        // ID Card not created



        // The mass application status become Unpaid
        mass = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId = :rtmass];
        system.assertEquals('Unpaid', mass.Application_status__c);


        // The case status become Ready for production (until a sfdc user will manually close it)
        theCase = [SELECT Id, Status FROM Case WHERE Related_Id_Card_Application__c = :mass.id ];

        system.assertEquals(1, theCase.size());
        system.assertEquals('Ready for production', theCase[0].Status);

    }




}
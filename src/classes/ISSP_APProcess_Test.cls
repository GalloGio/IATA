/**
 * This class tests the airline participation class.
 * Last update by: Niv.Goldenberg, 11-11-14.
 */
@isTest
private class ISSP_APProcess_Test
{
    @testSetup
    static void insertCustomSetting() {
        List<ISSP_CS__c> settings = new List<ISSP_CS__c> {
            new ISSP_CS__c(Name = 'EasyPay Opt-In Days', Value__c = '0'),
            new ISSP_CS__c(Name = 'EasyPay Opt-Out Days', Value__c = '30')
        };
        insert settings;    
    }

    @isTest static void test_method_a()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal', Airline_EasyPay_Opt_Out_Date__c = Date.today());
        insert country;
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);
        //Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.Top_Parent__c = parent.Id;
        insert child;
        System.debug('child Id: ' + child.Id);
        Contact con = ISSP_ObjectFactory.createNewContact();
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        con.AccountId= child.Id;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;        
        /*
        AccountShare newShare = new AccountShare();
        newShare.AccountAccessLevel = 'Edit';
        newShare.CaseAccessLevel = 'Edit';
        newShare.ContactAccessLevel = 'Edit';
        newShare.OpportunityAccessLevel  = 'Edit';
        newShare.AccountId = parent.Id;
        newShare.UserOrGroupId = newUser.Id;
        insert newShare;
        AccountShare newShare2 = new AccountShare();
        newShare2.AccountAccessLevel = 'Edit';
        newShare2.CaseAccessLevel = 'Edit';
        newShare2.ContactAccessLevel = 'Edit';
        newShare2.OpportunityAccessLevel  = 'Edit';
        newShare2.AccountId = child.Id;
        newShare2.UserOrGroupId = newUser.Id;
        insert newShare2;
        */
        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Portugal';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.IFAP_Country_ISO__c = 'PT';
             
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('caseId', testCase.Id);
            Test.setCurrentPage(pr);
            ISSP_APProcess ctrl = new ISSP_APProcess();
            System.assertEquals(ctrl.vCaseId, testCase.Id);
            ctrl.getIsNewCountryProcess();
            insert new ISSP_CS__c(Name='ISSP_APProcess_New_Countries', Value__c='CH');
            ctrl.getIsNewCountryProcess();
        }
        Test.stopTest();

    }

    @isTest static void test_method_b()
    {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', ISO_Code__c = 'CN', Case_BSP_Country__c = 'test');
        insert country;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'CN',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test',
                                                                Name = 'test1');
        insert csCity;


        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);
        //Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        insert child;
        child.Top_Parent__c = null;
        update child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        con.AccountId= child.Id;
        con.Title = 'test';
        con.FirstName = 'fName';
        con.LastName = 'lName';
        con.Email = 'testas123as1@test.com';
        insert con;
        System.debug('con Id: ' + con.Id);

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        System.runAs(newUser)
        {

            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'China';
            testCase.IFAP_Country_ISO__c = 'CN';
            testCase.Reason1__c = 'BSP HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Pending Customer';
            testCase.Verification__c = 'BSP';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);

            Test.startTest();

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('ctryreq', 'false');
            Test.setCurrentPage(pr);
            pr.getParameters().put('step', '4');
            pr.getParameters().put('retURL', '/ISSP_TEST');
            ISSP_APProcess ctrl = new ISSP_APProcess();
            ctrl.typeOfChangeRequested = new List<String>();
            ctrl.newCase = testCase;
            ctrl.strOperationType = 'BSP';
            ctrl.newForm.Accept_terms_and_conditions__c = true;
            ctrl.newForm.Case__c = testCase.Id;
            ctrl.save();
            System.assertEquals(ctrl.newForm.Case__c, testCase.Id);
            ctrl.strOperationType = 'BSP';
            ctrl.save();
            System.assertEquals(ctrl.newForm.Case__c, testCase.Id);
            ctrl.strOperationType = 'CASS Export';
            ctrl.save();
            System.assertEquals(ctrl.newForm.Case__c, testCase.Id);


            ctrl.getAPTypes();
            ctrl.APQueue('Airline Participation - Head Office');

            PageReference prSteps = ctrl.saveBSPFormAndGoForward();
            System.assert(prSteps.getUrl().endsWith('step=4'));
            prSteps = ctrl.saveBSPFormAndGoBack();
            System.assert(prSteps.getUrl().endsWith('step=2'));
            prSteps = ctrl.saveBSPFormAndLeave();
            System.assert(prSteps.getUrl().endsWith('ISSP_APCases'));
            prSteps = ctrl.goToStep1();
            System.assert(prSteps.getUrl().endsWith('step=1'));
            //ctrl.goToStep2();
            prSteps = ctrl.goToStep3();
            System.assert(prSteps.getUrl().endsWith('step=3'));
            //ctrl.goToStep4();
            prSteps = ctrl.goToFinalStep();
            System.assert(prSteps == null);
            //ctrl.redirectToCasesList(); //called from saveBSPFormAndLeave
            //ctrl.redirectToCasesListForDupe(); //called from save
            prSteps = ctrl.cancel();
            System.assert(prSteps.getUrl().endsWith('ISSP_TEST'));
            List<SelectOption> options = ctrl.getItems();
            System.assertEquals(options.size(), 1);
            options = ctrl.getAPTypes();
            System.assertEquals(options.size(), 4);
            List<Case> lstCases = ctrl.getAPDraftCases();
            System.assertEquals(lstCases.size(), 0);
            prSteps = ctrl.redirect('https://www.test.com/');
            System.assert(prSteps.getUrl().endsWith('test.com/'));
            prSteps = ctrl.checkRedirect();
            System.assert(prSteps == null);
            Boolean bool = ctrl.getIsEmpty();
            System.assertEquals(bool, true);
            bool = ctrl.getIsNotEmpty();
            System.assertEquals(bool, false);
            prSteps = ctrl.UploadFile();
            System.assert(prSteps == null);
            List<Attachment> lstAttachcs = ctrl.getAttachList();
            System.assertEquals(lstAttachcs.size(), 0);
            options = ctrl.countryNameList;
            System.assertEquals('test', options[1].getValue());
        }
        Test.stopTest();

    }

    @isTest static void test_method_c()
    {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal', Airline_EasyPay_Opt_Out_Date__c = Date.today());
        insert country;
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);
        //Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        insert child;
        child.Top_Parent__c = null;
        update child;
        System.debug('child Id: ' + child.Id);
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'CN',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test',
                                                                Name = 'test1');
        insert csCity;

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'China';
            testCase.Reason1__c = 'BSP HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Action Needed';
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            testCase.IFAP_Country_ISO__c = 'PT';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);

            //AP_Process_Form__c ap = (AP_Process_Form__c)ISSP_ObjectFactory.createSObject('AP_Process_Form__c',false,1);
            AP_Process_Form__c ap = new AP_Process_Form__c();
            ap.Case__c = testCase.Id;
            ap.Accept_payment_Cards_for_BSP_ticket__c = 'Yes';
            ap.Accept_terms_and_conditions__c = true;
            ap.Colombia_City_selection__c = 'test1;test2';
            ap.Colombia_City_percentage__c = '20;30';
            insert ap;

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('step', 'Final');
            pr.getParameters().put('caseId', testCase.Id);
            ISSP_APProcess ctrl = new ISSP_APProcess();

            AP_Country_specs__c testSpec = new AP_Country_specs__c();
            testSpec.Name = 'DEFAULT-BankMandate';
            testSpec.Link_label__c = 'Test1';
            testSpec.Download_URL__c = 'Test1';
            insert testSpec;

            ISSP_AP_Cities inlinepage = new ISSP_AP_Cities(new Apexpages.Standardcontroller(ap));

            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('ctryreq', 'false');
            Test.setCurrentPage(pr);
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '1');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '2');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '3');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '4');
            ctrl = new ISSP_APProcess();

            ctrl.fileBody = Blob.toPDF('test');
            ctrl.fileName = 'testName';
            PageReference prAttach = ctrl.UploadFile();
            System.assert(prAttach == null);
            List<Attachment> lstAttachcs = ctrl.getAttachList();
            System.assertEquals(lstAttachcs.size(), 1);
        }
        Test.stopTest();

    }

    @isTest static void test_method_d()
    {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal', Airline_EasyPay_Opt_Out_Date__c = Date.today());
        insert country;
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);
        //Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        insert child;
        child.Top_Parent__c = null;
        update child;
        System.debug('child Id: ' + child.Id);
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'CN',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test',
                                                                Name = 'test1');
        insert csCity;

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'China';
            testCase.Reason1__c = 'CASS HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Action Needed';
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            testCase.IFAP_Country_ISO__c = 'PT';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);

            //AP_Process_Form__c ap = (AP_Process_Form__c)ISSP_ObjectFactory.createSObject('AP_Process_Form__c',false,1);
            AP_Process_Form__c ap = new AP_Process_Form__c();
            ap.Case__c = testCase.Id;
            ap.Accept_payment_Cards_for_BSP_ticket__c = 'Yes';
            ap.Accept_terms_and_conditions__c = true;
            insert ap;

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('step', 'Final');
            pr.getParameters().put('caseId', testCase.Id);
            ISSP_APProcess ctrl = new ISSP_APProcess();

            AP_Country_specs__c testSpec = new AP_Country_specs__c();
            testSpec.Name = 'DEFAULT-BankMandate';
            testSpec.Link_label__c = 'Test1';
            testSpec.Download_URL__c = 'Test1';
            insert testSpec;

            ISSP_AP_Cities inlinepage = new ISSP_AP_Cities(new Apexpages.Standardcontroller(ap));

            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('ctryreq', 'false');
            Test.setCurrentPage(pr);
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '1');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '2');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '3');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '4');
            ctrl = new ISSP_APProcess();

            ctrl.fileBody = Blob.toPDF('test');
            ctrl.fileName = 'testName';
            PageReference prAttach = ctrl.UploadFile();
            System.assert(prAttach == null);
            List<Attachment> lstAttachcs = ctrl.getAttachList();
            System.assertEquals(lstAttachcs.size(), 1);


        }


        Test.stopTest();

    }

    @isTest static void test_method_e()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal');
        insert country;
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        insert child;
        child.Top_Parent__c = null;
        update child;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        insert con;
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test1',
                                                                Name = 'test1');
        insert csCity;

        AP_Country_Cities__c csCity2 = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test2',
                                                                Name = 'test2');
        insert csCity2;

        AP_Country_Cities__c csCity3 = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test3',
                                                                Name = 'test3');
        insert csCity3;

        AP_Country_Requierment__c cReq = new AP_Country_Requierment__c(
                                        Country__c = country.Id,
                                        Line_of_business__c = 'BSP');
        insert cReq;

        Test.startTest();
        System.runAs(newUser)
        {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Portugal';
            testCase.Reason1__c = 'BSP HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Action Needed';
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            testCase.IFAP_Country_ISO__c = 'PT';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);

            AP_Process_Form__c ap = new AP_Process_Form__c();
            ap.Case__c = testCase.Id;
            ap.Accept_payment_Cards_for_BSP_ticket__c = 'Yes';
            ap.Accept_terms_and_conditions__c = true;
            ap.Colombia_City_selection__c = 'test1;test2';
            ap.Colombia_City_percentage__c = '20;30';
            insert ap;

            AP_Country_specs__c testSpec = new AP_Country_specs__c();
            testSpec.Name = 'DEFAULT-BankMandate';
            testSpec.Link_label__c = 'Test1';
            testSpec.Download_URL__c = 'Test1';
            insert testSpec;

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('caseId', testCase.Id);
            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('ctryreq', 'false');
            Test.setCurrentPage(pr);
            pr.getParameters().put('step', '3');
            pr.getParameters().put('retURL', '/ISSP_TEST');
            ISSP_APProcess ctrl = new ISSP_APProcess();
            ctrl.getCityData();
            ctrl.cityList[0].selected = true;
            ctrl.cityList[1].selected = true;
            PageReference prSteps = ctrl.saveBSPFormAndGoForward();
            System.assert(prSteps.getUrl().endsWith('step=4'));

        }
        Test.stopTest();

    }
    
    @isTest static void test_method_f()
    {
        AMS_Settlement_System__c issOperation = new AMS_Settlement_System__c(
            DPC_System__c = 'Maestro'
        );
        insert issOperation;
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name= 'test country',
            ISO_Code__c = 'AA',
            AMS_Settlement_System__c = issOperation.Id
        );
        insert country;

        IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal', Airline_EasyPay_Opt_Out_Date__c = Date.today());
        insert countryPT;
        
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        System.debug('parent Id: ' + parent.Id);
        //Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.IATA_ISO_Country__c = country.Id;
        insert child;
        child.Top_Parent__c = null;
        update child;
        System.debug('child Id: ' + child.Id);
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        insert con;
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'CN',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test',
                                                                Name = 'test1');
        insert csCity;

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'China';
            testCase.Reason1__c = 'CASS HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Action Needed';
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            testCase.CaseArea__c = 'Airline Joining';
            testCase.IFAP_Country_ISO__c = 'PT';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);

            //AP_Process_Form__c ap = (AP_Process_Form__c)ISSP_ObjectFactory.createSObject('AP_Process_Form__c',false,1);
            AP_Process_Form__c ap = new AP_Process_Form__c();
            ap.Case__c = testCase.Id;
            ap.Accept_payment_Cards_for_BSP_ticket__c = 'Yes';
            ap.Accept_terms_and_conditions__c = true;
            ap.Participate_in_any_Commission_Control__c = 'Yes';
            insert ap;

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('step', 'Final');
            pr.getParameters().put('caseId', testCase.Id);
            ISSP_APProcess ctrl = new ISSP_APProcess();

            AP_Country_specs__c testSpec = new AP_Country_specs__c();
            testSpec.Name = 'DEFAULT-BankMandate';
            testSpec.Link_label__c = 'Test1';
            testSpec.Download_URL__c = 'Test1';
            insert testSpec;

            ISSP_AP_Cities inlinepage = new ISSP_AP_Cities(new Apexpages.Standardcontroller(ap));

            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('ctryreq', 'false');
            Test.setCurrentPage(pr);
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '1');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '2');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '3');
            ctrl = new ISSP_APProcess();
            pr.getParameters().put('step', '4');
            ctrl = new ISSP_APProcess();

            ctrl.fileBody = Blob.toPDF('test');
            ctrl.fileName = 'testName';
			/*
            PageReference prAttach = ctrl.UploadFile();
            System.assert(prAttach == null);
            List<Attachment> lstAttachcs = ctrl.getAttachList();
            System.assertEquals(lstAttachcs.size(), 1);
			*/

        }


        Test.stopTest();

    }

    @isTest static void test_method_1()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal');
        insert country;

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        insert child;
        child.Top_Parent__c = null;
        update child;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        insert con;
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test1',
                                                                Name = 'test1');
        insert csCity;

        AP_Country_Cities__c csCity2 = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test2',
                                                                Name = 'test2');
        insert csCity2;

        AP_Country_Cities__c csCity3 = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test3',
                                                                Name = 'test3');
        insert csCity3;

        AP_Country_Requierment__c cReq = new AP_Country_Requierment__c(
                                        Country__c = country.Id,
                                        Line_of_business__c = 'BSP');
        insert cReq;

        Test.startTest();
        System.runAs(newUser)
        {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Portugal';
            testCase.Reason1__c = 'BSP HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Action Needed';
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            testCase.IFAP_Country_ISO__c = 'PT';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);


            AP_Process_Form__c ap = new AP_Process_Form__c();
            ap.Case__c = testCase.Id;
            ap.Accept_payment_Cards_for_BSP_ticket__c = 'Yes';
            ap.Accept_terms_and_conditions__c = true;
            ap.Colombia_City_selection__c = 'test1;test2';
            ap.Colombia_City_percentage__c = '20;30';
            insert ap;

            AP_Country_specs__c testSpec = new AP_Country_specs__c();
            testSpec.Name = 'DEFAULT-BankMandate';
            testSpec.Link_label__c = 'Test1';
            testSpec.Download_URL__c = 'Test1';
            insert testSpec;

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('caseId', testCase.Id);
            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('proc', 'chg');
            Test.setCurrentPage(pr);
            pr.getParameters().put('step', '3');
            pr.getParameters().put('retURL', '/ISSP_TEST');
            ISSP_APProcess ctrl = new ISSP_APProcess();
            ctrl.getCityData();
            ctrl.cityList[0].selected = true;
            ctrl.cityList[1].selected = true;
            ctrl.cassairlineid = 'as';
            ctrl.isocountry = country;
            ctrl.isStep4 = true;
            ctrl.BankMandateUrl = 'as';
            ctrl.fileName = 'as';
            ctrl.strCountryspecURL = 'as';
            ctrl.strCountryspecLinkLabel = 'as';
            ctrl.strCountryspecURL2 = 'as';
            ctrl.strCountryspecLinkLabel2 = 'as';
            ctrl.strCountryspecURL3 = 'as';
            ctrl.strCountryspecLinkLabel3 = 'as';
            ctrl.strGSSAName = 'as';
            ctrl.gssaCountryISOCode = 'as';
            ctrl.category = 'IBCS consolidator';
            ctrl.getAPTypes();
            ctrl.category = 'test';
            ctrl.getAPTypes();
            ctrl.strGSSAAddress = 'as';
            ctrl.isGSSAUser = true;
            ctrl.countryNameList = null;
            ctrl.getCassAirlines();
            ctrl.getAPDraftCases();
            ctrl.APQueue('Airline Participation - Drafts');
            ctrl.goToFinalStep();
            ctrl.getChangeItems();


            PageReference prSteps = ctrl.saveBSPFormAndGoForward();
            System.assert(prSteps.getUrl().endsWith('step=4'));

        }
        Test.stopTest();

    }

    @isTest static void test_method_2() {

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'Portugal', ISO_Code__c = 'PT', Case_BSP_Country__c = 'Portugal');
        insert country;

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        insert child;
        child.Top_Parent__c = null;
        update child;
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        insert con;
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AP_Country_Cities__c csCity = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test1',
                                                                Name = 'test1');
        insert csCity;

        AP_Country_Cities__c csCity2 = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test2',
                                                                Name = 'test2');
        insert csCity2;

        AP_Country_Cities__c csCity3 = new AP_Country_Cities__c(Country_ISO_Code__c = 'PT',
                                                                Operation__c = 'BSP',
                                                                City__c = 'test3',
                                                                Name = 'test3');
        insert csCity3;

        AP_Country_Requierment__c cReq = new AP_Country_Requierment__c(
                                        Country__c = country.Id,
                                        Line_of_business__c = 'BSP');
        insert cReq;

        Test.startTest();
        System.runAs(newUser)
        {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Portugal';
            testCase.Reason1__c = 'BSP HOT';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Status = 'Action Needed';
            testCase.Account_Concerned__c = child.Id;
            testCase.Verification__c = 'BSP';
            testCase.IFAP_Country_ISO__c = 'PT';
            insert testCase;
            System.debug('testCase Id: ' + testCase.Id);


            AP_Process_Form__c ap = new AP_Process_Form__c();
            ap.Case__c = testCase.Id;
            ap.Accept_payment_Cards_for_BSP_ticket__c = 'Yes';
            ap.Accept_terms_and_conditions__c = true;
            ap.Colombia_City_selection__c = 'test1;test2';
            ap.Colombia_City_percentage__c = '20;30';
            insert ap;

            AP_Country_specs__c testSpec = new AP_Country_specs__c();
            testSpec.Name = 'DEFAULT-BankMandate';
            testSpec.Link_label__c = 'Test1';
            testSpec.Download_URL__c = 'Test1';
            insert testSpec;

            PageReference pr = Page.ISSP_APCases;
            pr.getParameters().put('caseId', testCase.Id);
            pr.getParameters().put('cdupetype', 'test');
            pr.getParameters().put('isMandatory', 'test');
            pr.getParameters().put('proc', 'chg');
            Test.setCurrentPage(pr);
            pr.getParameters().put('step', '3');
            pr.getParameters().put('retURL', '/ISSP_TEST');
            ISSP_APProcess ctrl = new ISSP_APProcess();
            ctrl.showNewGSTNumberFields();
            ctrl.newGSTInfo.India_Local_VAT_Number__c = '123456';
            ctrl.newGSTInfo.India_Local_VAT_Street__c = 'Street'; 
            ctrl.newGSTInfo.India_Local_VAT_City__c = 'City';
            ctrl.checkAllFieldGST();
            ctrl.newGSTInfo.India_Local_VAT_State_Name__c = 'State';
            ctrl.newGSTInfo.India_Local_VAT_State_Code__c = 'ST';
            ctrl.checkAllFieldGST();
            ctrl.addGSTInfo();
            System.assertEquals(ctrl.list_GSTNumber.size(), 1);
            GST_Information__c info = [SELECT Id FROM GST_Information__c];
            pr.getParameters().put('recordIdEdit', info.Id);
            ctrl.editGSTNumber();
            pr.getParameters().put('recordIdDel', info.Id);
            ctrl.delGSTNumber();
            ctrl.showNewGSTNumberFields();
            ctrl.closePopup();

            System.assertEquals(ctrl.list_GSTNumber.size(), 0);

        }
        Test.stopTest();
    }

    @isTest static void testOptInOut() {
        Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'Stuff');
        insert portalApp;

        List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

        IATA_ISO_Country__c countryUS = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US', ANG_Portal_Service__c = portalApp.Id, Airline_EasyPay_Opt_Out_Date__c = Date.today()-1);
        countries.add(countryUS);
        IATA_ISO_Country__c countryES = new IATA_ISO_Country__c (Name = 'ES', ISO_Code__c = 'ES', ANG_Portal_Service__c = portalApp.Id, Airline_EasyPay_Opt_Out_Date__c = Date.today()-1);
        countries.add(countryES);
        IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c (Name = 'PT', ISO_Code__c = 'PT', ANG_Portal_Service__c = portalApp.Id, Airline_EasyPay_Opt_Out_Date__c = Date.today()-1);
        countries.add(countryPT);

        insert countries;

        Id airlineBranchRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
        Id airlineHeadquartersRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

        Account headquarter = new Account(Name = 'Emirates',
                                          Field_Head_Office__c = 'Headquarter',
                                          Airline_Designator__c = 'LH',
                                          IATACode__c = '220',
                                          Airline_Prefix__c = '220',
                                          Sector__c = 'Airline',
                                          Category__c = 'Passenger and Cargo',
                                          Key_Customer_Reason__c = 'Volume',
                                          TradeName__c = 'Emirates',
                                          Legal_name__c = 'Stuff',
                                          Name_on_AOC__c = 'Stuff',
                                          IATA_ISO_Country__c = countryUS.Id,
                                          RecordTypeId = airlineHeadquartersRT);

        insert headquarter;

        List<Account> airlines = new List<Account>();

        Account branch1 = new Account(Name = 'Emirates',
                                          Field_Head_Office__c = 'Headquarter',
                                          Airline_Designator__c = 'LH',
                                          IATACode__c = '220',
                                          Airline_Prefix__c = '220',
                                          Sector__c = 'Airline',
                                          Category__c = 'Passenger and Cargo',
                                          Key_Customer_Reason__c = 'Volume',
                                          TradeName__c = 'Emirates',
                                          Legal_name__c = 'Stuff',
                                          Name_on_AOC__c = 'Stuff',
                                          IATA_ISO_Country__c = countryES.Id,
                                          RecordTypeId = airlineBranchRT,
                                          ParentId = headquarter.Id);

        Account branch2 = new Account(Name = 'Emirates',
                                          Field_Head_Office__c = 'Headquarter',
                                          Airline_Designator__c = 'LH',
                                          IATACode__c = '220',
                                          Airline_Prefix__c = '220',
                                          Sector__c = 'Airline',
                                          Category__c = 'Passenger and Cargo',
                                          Key_Customer_Reason__c = 'Volume',
                                          TradeName__c = 'Emirates',
                                          Legal_name__c = 'Stuff',
                                          Name_on_AOC__c = 'Stuff',
                                          IATA_ISO_Country__c = countryPT.Id,
                                          RecordTypeId = airlineBranchRT,
                                          ParentId = headquarter.Id);

        airlines.add(branch1);
        airlines.add(branch2);
        insert airlines;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = headquarter.Id;
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        List<Services_Rendered__c> services = new List<Services_Rendered__c>();

        Services_Rendered__c serviceBranch1 = new Services_Rendered__c(Services_Rendered_to_Airline__c = branch1.Id,
                                                                 Services_Rendered_By__c = headquarter.Id,
                                                                 Services_Rendered_Type__c = 'BSP Participation',
                                                                 Services_Rendered_Status__c = 'Active',
                                                                 ANG_IATA_EasyPay_Opt_out__c = true);

        Services_Rendered__c serviceBranch2 = new Services_Rendered__c(Services_Rendered_to_Airline__c = branch2.Id,
                                                                 Services_Rendered_By__c = headquarter.Id,
                                                                 Services_Rendered_Type__c = 'BSP Participation',
                                                                 Services_Rendered_Status__c = 'Active',
                                                                 ANG_IATA_EasyPay_Opt_out__c = false);

        services.add(serviceBranch1);
        services.add(serviceBranch2);

        insert services;



        Test.startTest();
        System.runAs(newUser) {

            PageReference pr = Page.ISSP_APCases;
            List<String> countriesOut = new List<String> {countryES.Id, countryPT.Id};
            String optInOutParam = 'OUT';

            pr.getParameters().put('optInOutParam', optInOutParam);
            pr.getParameters().put('countriesParam', System.JSON.serialize(countriesOut));
            pr.getParameters().put('effectiveDateParam', '2999-09-10');

            Test.setCurrentPage(pr);

            ISSP_APProcess ctrl = new ISSP_APProcess();
            ctrl.submitOptInOutServer();

            List<Case> resultingCases = [SELECT Id FROM Case WHERE Reason1__c = 'IATA Easy Pay' AND Subject LIKE '%Airline Participation - IATA EasyPay%'];

            System.assertEquals(countriesOut.size(), resultingCases.size());
        }
        
        Test.stopTest();
    }
}
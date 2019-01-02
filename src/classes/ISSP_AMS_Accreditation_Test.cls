@isTest
private class ISSP_AMS_Accreditation_Test {
    @testSetup static void customSettingSetup() {
        insert new ISSP_CS__c(Name = 'ISSP AMS ALLOWED AGENCY URL', Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)([.])(([a-zA-Z]{3})|([a-zA-Z]{2}))');
        insert new ISSP_CS__c(Name = 'No Notification Email Contact Id', Value__c = null);
        insert new ISSP_CS__c(Name = 'ISSP Portal Login URL', Value__c = 'anything');

        insert new Amazon_Cred__c(Name = 'ACLI', Prod_Configuration__c = 'aprodconf', Dev_Configuration__c = 'adevconf');

        insert new AWSKey__c(Name = 'adevconf', Key__c = 'asd', Secret__c = 'asd', IAS_configuration_name__c = 'asdas', IAS_Access_Point__c = 'asd',
                    Bucket__c = 'asd', AWS_ENDPOINT_URL__c = 'asd', WS_Endpoint__c = 'apoint');

        Amazon_Cred__c amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c genericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
        creds.add(amazon_Cred);
        creds.add(genericAttach);
        creds.add(recycleBin);
        insert creds;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'testOptOut', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tp',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', Region__c = 'Europe',
                                    Informatica_Value__c = 'test');
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'testOptOut2', ISO_Code__c = 'tl', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;
    }

    @isTest static void ISSP_AMS_Accreditation_Test_1() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            ctrl.getnewlabels();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_17() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = null;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';

        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId', Value__c = newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        ISSP_Constant cons = new ISSP_Constant();
        Map<String, String> customSeting = ISSP_Constant.customSetingMap;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO;Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;


        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.Validation_ERRORS__c = true;
            newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            newForm.ISSP_AMS_Online_Agency_Application__c = 'test';
            newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = 'test';
            newForm.ISSP_AMS_Previous_default__c = 'test';

            insert newForm ;


            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '4');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            ctrl.iatacode = '1234567';
            ctrl.companyModalNameOfEmployer = 'employee';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();
            ctrl.isNewCase = true;
            ctrl.save();

            ctrl.createBranchAccount();
        }
        Test.stopTest();
    }


    @isTest static void ISSP_AMS_Accreditation_Test_2() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '2');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

        }
        Test.stopTest();
    }


    @isTest static void ISSP_AMS_Accreditation_Test_3() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;
            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '3');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            Decimal InternationalCharges_Collected_Total = ctrl.InternationalCharges_Collected_Total;
            Decimal InternationalPrepaid_Collected_Total  = ctrl.InternationalPrepaid_Collected_Total;


        }
        Test.stopTest();
    }


    @isTest static void ISSP_AMS_Accreditation_Test_4() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '4');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;


        }
        Test.stopTest();
    }


    @isTest static void ISSP_AMS_Accreditation_Test_5() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingStreet = 'test';
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Cargo Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingStreet = 'test2';
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Cargo Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist1 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist1.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist1.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist1.License_required__c = true ;
        AMS_Acc_Checklist1.Registration_required__c = true ;
        AMS_Acc_Checklist1.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist1;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist2 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist2.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist2.Operation__c = 'Cargo Agent';
        AMS_Acc_Checklist2.License_required__c = true ;
        AMS_Acc_Checklist2.Registration_required__c = true ;
        AMS_Acc_Checklist2.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist2;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req1 = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req1.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist1.Id ;
        ISSP_AMS_Accreditation_Acc_Req1.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req1.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req1.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req1.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req1.Name = 'TestReq1';
        ISSP_AMS_Accreditation_Acc_Req1.File_Identifier2__c = 'CV';
        ISSP_AMS_Accreditation_Acc_Req1.File_to_Upload__c = 'Optional';
        insert ISSP_AMS_Accreditation_Acc_Req1;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req2 = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req2.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist2.Id ;
        ISSP_AMS_Accreditation_Acc_Req2.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req2.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req2.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req2.Sort_Order__c = 2;
        ISSP_AMS_Accreditation_Acc_Req2.Name = 'TestReq2';
        ISSP_AMS_Accreditation_Acc_Req2.File_Identifier2__c = 'DATA_PROT';
        ISSP_AMS_Accreditation_Acc_Req2.File_to_Upload__c = 'Optional';
        insert ISSP_AMS_Accreditation_Acc_Req2;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo Agent';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.Validation_ERRORS__c = true;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.Agency_owner__c = true;
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ApexPages.currentPage().getParameters().put('retURL' , '/ISSP_Homepage?mid=M0S1');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';

            ctrl.amsOfficeType = 'HO';
            ctrl.sector = 'Cargo Agent';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;



            ctrl.getIATAMemberAirlines();
            ctrl.getOfficeTypes();
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.Save();
            ctrl.createAgencyContact();


            ctrl.createInternationalSales();
            ctrl.cancelAgentUpdate();
            ctrl.editSalesId = AMS_SIS.Id;
            ctrl.editInternationalSales();
            ctrl.cancelSalesUpdate();
            ctrl.deleteInternationalSales();
            ctrl.editAgencyContact();
            ctrl.updateAgencyDetails();
            ctrl.goToStep1();
            ctrl.goToStep2();
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.saveAMSForm();
            ctrl.goToStep3();
            ctrl.goToStep4();
            ctrl.goToStep5();
            ctrl.saveAMSFormAndGoForward();
            ctrl.saveAMSFormAndGoBack();
            ctrl.saveAMSFormAndLeave();
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_when_incorporated__c = null;
            ctrl.newForm.ISSP_AMS_Entity_with_listed_shares__c = null;
            ctrl.newForm.ISSP_AMS_Online_Agency_Application__c = 'Yes';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c = null;
            ctrl.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = 'Yes';
            ctrl.newForm.Cargo_Agent_Account__c = null;
            ctrl.newForm.ISSP_AMS_Previous_default__c = 'Yes';
            ctrl.newForm.ISSP_AMS_Prev_default_explanation__c = null;
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.sector = 'Travel Agent';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();
            ctrl.amsOfficeType = 'Branch';
            ctrl.newForm.Wholly_owned_by_this_Head_Office__c = null;
            ctrl.newForm.Wholly_managed_by_this_Head_Office__c = null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_when_incorporated__c = null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_where_incorporated__c = null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_Entity_with_listed_shares__c = null;
            ctrl.newForm.Branch_Office_Street_name_number__c = null;
            ctrl.newForm.Branch_Office_City__c = null;
            ctrl.newForm.Branch_Office_Phone__c = null;
            ctrl.newForm.ISSP_AMS_License_No__c = null;
            ctrl.newForm.ISSP_AMS_Date_license_granted__c = null;
            ctrl.newForm.ISSP_AMS_VAT_number__c = null;
            ctrl.newForm.ISSP_AMS_Previous_default__c = null;
            ctrl.newForm.ISSP_AMS_Previous_default__c = 'YES';
            ctrl.newForm.ISSP_AMS_Prev_default_explanation__c = null;
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = null;
            ctrl.isocountry.ISO_Code__c = 'CN';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            ctrl.sector = 'Cargo Agent';
            AMS_Acc_Checklist1.Operation__c = 'Cargo Agent';
            Update AMS_Acc_Checklist1;
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            ctrl.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            ctrl.getIsEmpty();
            ctrl.getIsNotEmpty();
            ctrl.getPrevWorkedForItems();

            ctrl.cancel();
            ctrl.setPageLegalStatusLabels();
            ctrl.legalStatus = 'association';
            ctrl.setPageLegalStatusLabels();
            ctrl.legalStatus = 'co-operative';
            ctrl.setPageLegalStatusLabels();
            ctrl.updateAmsCountry();



        }

    }



    @isTest static void ISSP_AMS_Accreditation_Test_NOC_1s() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Location_Type__c = 'BR';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist2 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist2.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist2.Operation__c = 'Cargo Agent';
        AMS_Acc_Checklist2.License_required__c = true ;
        AMS_Acc_Checklist2.Registration_required__c = true ;
        insert AMS_Acc_Checklist2;


        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req2 = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req2.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist2.Id ;
        ISSP_AMS_Accreditation_Acc_Req2.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req2.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req2.Type_Of_Change__c = 'bank account details;legal name;location;ownership or shareholding';
        ISSP_AMS_Accreditation_Acc_Req2.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req2.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req2.Name = 'TestReq2';
        insert ISSP_AMS_Accreditation_Acc_Req2;

        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo Agent';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = null;
            testCase.IFAP_Country_ISO__c = 'tp';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.HO_Account__c = parent.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            Test.startTest();

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' , 'true');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' , 'true');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            ctrl.securityCheck();
            List<AMS_Accreditation_Contact__c> owners_list = ctrl.List_PreviousOwners;
            owners_list = ctrl.List_CurrentOwners;
            owners_list = ctrl.List_CurrentCompanies;
            owners_list = ctrl.List_PreviousCompanies;
            owners_list = ctrl.List_Prev_Ownership_Summary;
            owners_list = ctrl.List_Curr_Ownership_Summary ;
            Double ownership_total = ctrl.Curr_Ownership_Total;
            ownership_total = ctrl.Prev_Ownership_Total;

            ctrl.agencyCodesConcerned = new List<SelectOption>();
            ctrl.amsOfficeType = 'Branch';
            ctrl.sector = 'Cargo Agent';
            ctrl.iatacode = '12345678';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            ctrl.brAccountId = parent.Id;

            ctrl.getBranchAccounts();
            ctrl.isocountry.OSCAR_enabled__c = true;
            ctrl.Save();
            ctrl.createAgencyContact();

            ctrl.cancelAgentUpdate();
            ctrl.cancelFormUpdate();
            ctrl.editAgencyContact();
            ctrl.updateAgencyDetails();
            ctrl.isocountry.OSCAR_enabled__c = true;
            ctrl.updateNoCAgencyLocation();
            ctrl.goToStep3Section1();
            ctrl.goToStep3Section2();
            ctrl.goToStep3Section3();
            ctrl.goToStep3Section4();
            ctrl.goToStep1();
            ctrl.goToStep2();
            ctrl.goToStep3();
            ctrl.goToStep4();
            ctrl.goToStep5();
            ctrl.saveAMSFormAndGoForward();
            ctrl.saveAMSFormAndGoBack();
            ctrl.saveAMSFormAndLeave();
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            ctrl.newForm.IATA_Registered_IATAN_Agent__c = null;
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.highLightPageForErrors();
            ctrl.goToFinalStep();

            ctrl.newForm.IATA_Registered_IATAN_Agent__c = 'Yes';
            ctrl.newForm.IATAN_Agent_Account__c = null;
            ctrl.hqAccount.Name = null;
            ctrl.hqAccount.Phone = null;
            ctrl.hqAccount.Status__c = 'Approved';
            ctrl.hqAccount.BillingStreet = null;
            ctrl.hqAccount.BillingCity = null;

            ctrl.newForm.Branch_Office_Fax_National__c = null;
            ctrl.newCase.Reason1__c = AMS_Utils.CASE_REASON_ASSOCIATE_ENTITY_STANDARD;
            ctrl.highLightPageForErrors();



            ctrl.newform.Accept_terms_and_conditions__c = true;

            ctrl.goToFinalStep();

        }

    }

    @isTest static void ISSP_AMS_Accreditation_Test_NOC_2s() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                Local_language_Agency_details_required__c = true );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', Local_language_Agency_details_required__c = true);
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Location_Type__c = 'BR';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist2 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist2.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist2.Operation__c = 'Cargo Agent';
        AMS_Acc_Checklist2.License_required__c = true ;
        AMS_Acc_Checklist2.Registration_required__c = true ;
        AMS_Acc_Checklist2.Statement_of_International_Sales__c = true ;

        insert AMS_Acc_Checklist2;


        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req2 = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req2.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist2.Id ;
        ISSP_AMS_Accreditation_Acc_Req2.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req2.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req2.Type_Of_Change__c = 'bank account details;legal name;location;ownership or shareholding';
        ISSP_AMS_Accreditation_Acc_Req2.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req2.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req2.Name = 'TestReq2';
        insert ISSP_AMS_Accreditation_Acc_Req2;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo Agent';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = null;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.HO_Account__c = parent.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' , 'false');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' , 'true');
            ApexPages.currentPage().getParameters().put('communityName' , 'CNS');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            ctrl.securityCheck();
            ctrl.getIsEmptySumbittedCases();
            String loginURL = ctrl.Portal_Login_URL;
            String txtHelpTrainedStaffOrganization = ctrl.txtHelpTrainedStaffOrganization;
            String txtHelpTrainedStaffReference = ctrl.txtHelpTrainedStaffReference;

            ctrl.amsOfficeType = 'HO';
            ctrl.sector = 'Cargo Agent';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            ctrl.brAccountId = parent.Id;

            ctrl.getBranchAccounts();
            ctrl.agencyCodesConcerned = new List<SelectOption>();
            ctrl.newForm.Is_change_location__c = true;
            ctrl.newForm.Is_change_legal_name__c = true;
            ctrl.newForm.Is_change_ownership_or_shareholding__c = true;
            ctrl.newForm.Branch_Office_Street_name_number__c   = 'test street';
            ctrl.newForm.Branch_Office_City__c  = 'test city';
            ctrl.newForm.Branch_Office_Email__c  = 'test_email@gmail.com';
            ctrl.Save();
            ctrl.createAgencyContact();

            ctrl.cancelAgentUpdate();
            ctrl.cancelFormUpdate();
            ctrl.editAgencyContact();
            ctrl.updateAgencyDetails();
            ctrl.updateNoCAgencyLocation();
            ctrl.goToStep3Section1();
            ctrl.goToStep3Section2();
            ctrl.goToStep3Section3();
            ctrl.goToStep3Section4();
            ctrl.goToStep1();
            ctrl.goToStep2();
            ctrl.goToStep3();
            ctrl.goToStep4();
            ctrl.goToStep5();
            ctrl.saveAMSFormAndGoForward();
            ctrl.saveAMSFormAndGoBack();
            ctrl.saveAMSFormAndLeave();
            ctrl.setPageLegalStatusAfterChangeLabels();
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();
            ctrl.validateDangerousGoods(5);

        }

    }

    @isTest static void ISSP_AMS_Accreditation_Test_NOC_3s() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                Local_language_Agency_details_required__c = true );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', Local_language_Agency_details_required__c = true);
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        insert new ISSP_PDF_Per_Region__c(Name = 'Region');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Location_Type__c = 'BR';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist2 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist2.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist2.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist2.License_required__c = true ;
        AMS_Acc_Checklist2.Registration_required__c = true ;
        AMS_Acc_Checklist2.Statement_of_International_Sales__c = true ;

        insert AMS_Acc_Checklist2;


        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req2 = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req2.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist2.Id ;
        ISSP_AMS_Accreditation_Acc_Req2.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req2.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req2.Type_Of_Change__c = 'bank account details;legal name;location;ownership or shareholding';
        ISSP_AMS_Accreditation_Acc_Req2.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req2.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req2.Name = 'TestReq2';
        insert ISSP_AMS_Accreditation_Acc_Req2;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Travel Agent';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = null;
            testCase.IFAP_Country_ISO__c = 'tq';
            testCase.Region__c = 'Region';
            insert testCase;

            insert new AmazonFile__c(Name = 'File', Case__c = testCase.Id, Full_Name_Unique__c = 'cenas1', File_Identifier__c = 'CV');

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.HO_Account__c = parent.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' , 'false');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' , 'true');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            ctrl.securityCheck();
            ctrl.getIsEmptySumbittedCases();
            String loginURL = ctrl.Portal_Login_URL;

            ctrl.amsOfficeType = 'HO';
            ctrl.sector = 'Travel Agent';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            ctrl.brAccountId = parent.Id;

            ctrl.getBranchAccounts();
            ctrl.agencyCodesConcerned = new List<SelectOption>();
            ctrl.newForm.Is_change_location__c = true;
            ctrl.newForm.Is_change_legal_name__c = true;
            ctrl.newForm.Is_change_ownership_or_shareholding__c = true;
            ctrl.newForm.Branch_Office_Street_name_number__c   = 'test street';
            ctrl.newForm.Branch_Office_City__c  = 'test city';
            ctrl.newForm.Branch_Office_Email__c  = 'test_email@gmail.com';
            ctrl.Save();
            ctrl.createAgencyContact();

            ctrl.cancelAgentUpdate();
            ctrl.cancelFormUpdate();
            ctrl.editAgencyContact();
            ctrl.updateAgencyDetails();
            ctrl.updateNoCAgencyLocation();
            ctrl.goToStep3Section1();
            ctrl.goToStep3Section2();
            ctrl.goToStep3Section3();
            ctrl.goToStep3Section4();
            ctrl.goToStep1();
            ctrl.goToStep2();
            ctrl.goToStep3();
            ctrl.goToStep4();
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.goToStep5();
            ctrl.saveAMSFormAndGoForward();
            ctrl.saveAMSFormAndGoBack();
            ctrl.saveAMSFormAndLeave();
            ctrl.setPageLegalStatusAfterChangeLabels();
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.sectorValue = 'Travel_Agent';
            ctrl.fetchCountryRequirements();
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();
            ctrl.validateDangerousGoods(5);

            ctrl.redirectToCountryRequirementPage();

        }

    }

    @isTest static void ISSP_AMS_Accreditation_Test_NOC_4s() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                Local_language_Agency_details_required__c = true, ANG_Enable_NewGen__c = true );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', Local_language_Agency_details_required__c = true, ANG_Enable_NewGen__c = true);
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HE';
        parent.Location_Class__c = 'P';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.Category__c = 'IATA Passenger Sales Agent';
        parent.ANG_Accreditation_Model__c = 'Cashless';
        parent.IATA_ISO_Country__c = country.Id;
        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        parent.Category__c = 'IATA Passenger Sales Agent';
        child.Top_Parent__c = parent.Id;
        child.ParentId = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.Location_Type__c = 'AE';
        child.Location_Class__c = 'P';
        child.IATACode__c = '1001';
        child.ANG_Accreditation_Model__c = 'Cashless';
        child.IATA_ISO_Country__c = country.Id;

        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist2 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist2.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist2.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist2.License_required__c = true ;
        AMS_Acc_Checklist2.Registration_required__c = true ;
        AMS_Acc_Checklist2.Statement_of_International_Sales__c = true ;

        insert AMS_Acc_Checklist2;


        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req2 = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req2.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist2.Id ;
        ISSP_AMS_Accreditation_Acc_Req2.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req2.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req2.Type_Of_Change__c = 'bank account details;legal name;location;ownership or shareholding';
        ISSP_AMS_Accreditation_Acc_Req2.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req2.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req2.Name = 'TestReq2';
        insert ISSP_AMS_Accreditation_Acc_Req2;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Travel Agent';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = null;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.HO_Account__c = parent.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' , 'false');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' , 'true');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            ctrl.securityCheck();
            ctrl.getIsEmptySumbittedCases();
            String iatanCodeL = ctrl.iatanAccount;
            String accreditationTypeL = ctrl.accredidationType;
            String loginURL = ctrl.Portal_Login_URL;

            ctrl.amsOfficeType = 'HO';
            ctrl.sector = 'Travel Agent';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            ctrl.brAccountId = parent.Id;
            ctrl.getContactAccount();

            ctrl.getBranchAccounts();
            ctrl.agencyCodesConcerned = new List<SelectOption>();
            ctrl.newForm.Is_change_location__c = true;
            ctrl.newForm.Is_change_legal_name__c = true;
            ctrl.newForm.Is_change_ownership_or_shareholding__c = true;
            ctrl.newForm.Branch_Office_Street_name_number__c   = 'test street';
            ctrl.newForm.Branch_Office_City__c  = 'test city';
            ctrl.newForm.Branch_Office_Email__c  = 'test_email@gmail.com';
            ctrl.Save();
            ctrl.createAgencyContact();

            ctrl.cancelAgentUpdate();
            ctrl.cancelFormUpdate();
            ctrl.editAgencyContact();
            ctrl.updateAgencyDetails();
            ctrl.updateNoCAgencyLocation();
            ctrl.goToStep3Section1();
            ctrl.goToStep3Section2();
            ctrl.goToStep3Section3();
            ctrl.goToStep3Section4();
            ctrl.goToStep1();
            ctrl.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl.Save();
            ctrl.goToStep3();
            ctrl.goToStep1();
            ctrl.newForm.Scope_of_Change__c = 'HO - Selected Branches';
            ctrl.agencyCodesConcerned = ctrl.getBranchAccounts();
            ctrl.Save();
            ctrl.goToStep3();
            ctrl.goToStep1();
            ctrl.newForm.Last_Scope_Of_change__c = 'HO Only';
            ctrl.newForm.Scope_of_Change__c = 'Selected Branches Only';
            ctrl.agencyCodesConcerned = ctrl.getBranchAccounts();
            ctrl.Save();
            ctrl.goToStep2();
            ctrl.goToStep1();
            ctrl.agencyCodesConcerned = new List<SelectOption>();
            ctrl.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl.newForm.Notify_Change_Accreditation_Type__c = true;
            ctrl.newForm.ANG_Accreditation_Model_to_Change__c = 'Cash';
            ctrl.Save();
            ctrl.contactType = 'Trained Staff';
            ctrl.newContact = new AMS_Accreditation_Contact__c();
            ctrl.newContact.Training_dangerous_goods_completed__c = 'Yes';
            ctrl.createAgencyContact();
            ctrl.contactType = 'Person';
            ctrl.newContact = new AMS_Accreditation_Contact__c();
            ctrl.newContact.First_name__c = 'testef';
            ctrl.newContact.Last_name__c = 'testel';
            ctrl.newContact.PhoneNational__c = '+65464644';
            ctrl.newContact.Email__c = 'email@mail.com';
            ctrl.newContact.Financial_Assessment_Contact__c = true;
            ctrl.createAgencyContact();
            ctrl.Save();
            ctrl.goToStep3();
            ctrl.goToStep4();
            ctrl.goToStep5();
            ctrl.saveAMSFormAndGoForward();
            ctrl.saveAMSFormAndGoBack();
            ctrl.saveAMSFormAndLeave();
            ctrl.setPageLegalStatusAfterChangeLabels();

            ctrl.legalStatusAfterChange = 'association';
            ctrl.setPageLegalStatusAfterChangeLabels();

            ctrl.legalStatusAfterChange = 'joint venture';
            ctrl.setPageLegalStatusAfterChangeLabels();



            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.sectorValue = 'Travel_Agent';
            ctrl.fetchCountryRequirements();
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();
            ctrl.validateDangerousGoods(5);
        }

    }



    @isTest static void ISSP_AMS_Accreditation_Test_20() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Id rtIdOff = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Facility__c', 'Office');

        Id rtIdWar = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Facility__c', 'Warehouse');

        Id rtIdTS = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.CGO_Region_Selection__c = 'Africa';
            newForm.CGO_Region_Consignment_Selection__c = 'Africa';
            newForm.CGO_Region_Tons_Selection__c = 'Africa';
            newForm.CGO_Region_AirFreight_Selection__c = 'Africa';
            newForm.CGO_Region_Percentage_Selection__c = 'Africa';

            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            newContact.Training_dangerous_goods_completed__c = 'Yes';
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            AMS_Facility__c facility = new AMS_Facility__c();
            facility.Is_the_warehouse_sub_contracted__c = 'Yes';
            facility.Is_the_office_warehouse_leased__c = 'Yes';
            facility.RecordTypeId = rtIdOff;
            facility.AMS_Online_Accreditation__c = newForm.Id;
            facility.Are_Consignments_made_ready__c = 'Yes';
            insert facility;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Trained Staff';
            ctrl.trainedStaffId = newContact.Id;
            ctrl.editContactId = newContact.Id;
            ctrl.editTrainedStaff();
            List<AMS_Accreditation_Contact__c> trainedStaffList = ctrl.trainedStaffList;
            ctrl.cancelTrainedStaff();
            ctrl.trainedStaffContact.First_name__c = 'test first';
            ctrl.trainedStaffContact.Last_name__c = 'test last';
            ctrl.upsertTrainedStaff();
            ctrl.contactType = 'Company';
            ctrl.facilitiesId = facility.Id;
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.redirectToFacilitiesPage();
            ctrl.saveFacilities();
            ctrl.cancelFacilities();
            ctrl.editContactId = newContact.Id;
            ctrl.deleteTrainedStaff();
            ctrl.cancelAccountUpdate();
            ctrl.redirectToPDF();
            ctrl.facilitiesId = null;
            ctrl.redirectToFacilitiesPage();

            ctrl.contactType = 'Trained Staff';
            ctrl.trainedStaffContact.Training_dangerous_goods_completed__c = 'Yes';
            ctrl.trainedStaffContact.Valid_until__c = null;

            ctrl.includedPageName = 'ISSP_AMS_Cargo_Form';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.amsOfficeType = 'HO';
            testCase.Reason1__c = 'New HO';
            ctrl.contactType = ' ';
            ctrl.legalstatus = 'sole proprietorship';

            ctrl.createAgencyContact();

            facility.RecordTypeId = rtIdWar;
            update facility;
            ctrl.facilityRecordTypeName = 'Warehouse';
            ctrl.saveFacilities();
            ctrl.facilitiesId = facility.Id;
            ctrl.deleteFacility();
            ctrl.accountUpdatedToggleOff();
            ctrl.goToStep3Section8();
            ctrl.fetchCountryRequirements();
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            AMS_Acc_Checklist.Operation__c = 'Cargo Agent';
            Update AMS_Acc_Checklist;
            ctrl.fetchCountryRequirements();
            ctrl.validateCharactersInPersonWindow();
            ctrl.amsOfficeType = 'Branch';
            ctrl.validateCharactersInForm();
            ctrl.CheckCountryReqments();

            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.redirectToPDF();

            ctrl.newCase.Reason1__c = AMS_UTILS.CASE_REASON_ASSOCIATE_ENTITY_STANDARD;
            ctrl.redirectToPDF();

            ctrl.sectorValue = 'idk';
            ctrl.newform.Agent_Type__c = 'idk';
            ctrl.newCase.Reason1__c = 'idk';
            ctrl.redirectToPDF();
        }

    }

    @isTest static void ISSP_AMS_Accreditation_Test_17s() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.Registration_number__c = '123';
            newContact.Financial_interest__c = 100;
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';

            ctrl.amsOfficeType = 'HO';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;

            ctrl.newContact.Agencies_prev_worked_for__c = '';

            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();

            ctrl.newContact.Agencies_prev_worked_for__c = '';
            ctrl.legalstatus = 'sole proprietorship';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.newContact.Financial_interest__c = 0;
            ctrl.newContact.Agencies_prev_worked_for__c = null;
            ctrl.newContact.Prev_Job1_Position__c = null;
            ctrl.newContact.Prev_Job1_From__c = null;
            ctrl.newContact.Prev_Job1_Address__c = null;
            ctrl.newContact.Prev_Job1_employer__c = null;
            ctrl.newContact.Agencies_prev_worked_for__c = '2';
            ctrl.newContact.Prev_Job2_Position__c = null;
            ctrl.newContact.Prev_Job2_From__c = null;
            ctrl.newContact.Prev_Job2_Address__c = null;
            ctrl.newContact.Prev_Job2_employer__c = null;
            ctrl.createAgencyContact();
            ctrl.newContact.Agencies_prev_worked_for__c = '1';
            ctrl.createAgencyContact();
            ctrl.newContact.Registration_number__c = '1234';
            ctrl.createAgencyContact();
            ctrl.deleteAgencyContact();

        }
    }




    @isTest static void ISSP_AMS_Accreditation_Test_5s() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';

            ctrl.amsOfficeType = 'HO';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;


            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();
            ctrl.sector = 'Travel Agent';
            ctrl.applyLanguage = 'fr';
            ctrl.fetchCountryRequirements();

            ctrl.includedPageName = 'ISSP_AMS_Pax_Form';
            ctrl.newContact.Agencies_prev_worked_for__c = '';
            ctrl.legalstatus = 'sole proprietorship';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.newContact.Financial_interest__c = 0;
            ctrl.newContact.Agencies_prev_worked_for__c = null;
            ctrl.newContact.Prev_Job1_Position__c = null;
            ctrl.newContact.Prev_Job1_From__c = null;
            ctrl.newContact.Prev_Job1_Address__c = null;
            ctrl.newContact.Prev_Job1_employer__c = null;
            ctrl.newContact.Agencies_prev_worked_for__c = '2';
            ctrl.newContact.Prev_Job2_Position__c = null;
            ctrl.newContact.Prev_Job2_From__c = null;
            ctrl.newContact.Prev_Job2_Address__c = null;
            ctrl.newContact.Prev_Job2_employer__c = null;
            ctrl.createAgencyContact();
            ctrl.newContact.Agencies_prev_worked_for__c = '1';
            ctrl.createAgencyContact();

            ctrl.newInternationalSales.Sales_Amount__c = 1;
            ctrl.newInternationalSales.AMS_Online_Accreditation__c = null;
            ctrl.newInternationalSales.CurrencyIsoCode = '';
            ctrl.createInternationalSales();

            ctrl.newForm.ISSP_AMS_where_incorporated__c = 'testÎ©x';
            ctrl.newForm.ISSP_AMS_Principal_business_Org__c = 'testÎ©x';
            ctrl.hqAccount.BillingState = 'testÎ©x';
            ctrl.newContact.Job_title__c = 'testÎ©x';
            ctrl.newContact.AddressStreet__c = 'testÎ©x';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = 'testÎ©x';
            ctrl.newContact.AddressCity__c = 'testÎ©x';
            ctrl.newContact.First_name__c = 'testÎ©x';
            ctrl.newContact.Last_name__c = 'testÎ©x';
            ctrl.hqAccount.BillingStreet = 'testÎ©x';
            ctrl.hqAccount.BillingCity = 'testÎ©x';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c = 'testÎ©x';
            ctrl.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = 'testÎ©x';
            ctrl.validateCharactersInForm();

            ctrl.goToStep3Section1();
            ctrl.goToStep3Section2();
            ctrl.goToStep3Section3();
            ctrl.goToStep3Section4();
            ctrl.goToStep3Section5();
            ctrl.goToStep3Section6();
            ctrl.goToStep3Section7();

            ctrl.amsOfficeType = 'test';
            ctrl.newForm.ISSP_AMS_Previous_default__c = 'test';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = 'test';
            ctrl.newForm.ISSP_AMS_Legal_Status__c = null;
            ctrl.newCase.Reason1__c = 'Old HO';
            ctrl.amsIsGSA = 'NO';
            ctrl.isDupeSAAMCase = false;
            ctrl.isNewCase = true;
            ctrl.save();
            ctrl.isDupeSAAMCase = true;
            ctrl.save();

            ctrl.highLightPageForErrors();
            ctrl.saveAMSFormAndGoToStep5();
            ctrl.newCase.CaseArea__c = 'test';
            ctrl.newCase.Reason1__c = 'test';
            ctrl.sector = 'Travel Agent';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            //ctrl.newForm.SAAM_Case__c = null;
            ctrl.sectorValue = 'Travel_Agent';
            ctrl.newCase.Reason1__c = 'New BR / IP';
            ctrl.saveAMSForm();
            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.saveAMSForm();
            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.saveAMSForm();

            ctrl.contactType = 'House';
            ctrl.newContact.Agencies_prev_worked_for__c = '';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.newContact.Financial_interest__c = 0;
            ctrl.createAgencyContact();
            ctrl.newContact.Agencies_prev_worked_for__c = null;
            ctrl.newContact.Financial_interest__c = 1;
            ctrl.createAgencyContact();
            ctrl.newContact.Agency_owner__c = false;
            ctrl.newContact.Agency_role__c = false;
            ctrl.newContact.Agencies_prev_worked_for__c = '2';
            ctrl.createAgencyContact();
            ctrl.newContact.Prev_Job2_From__c = null;
            ctrl.newContact.Prev_Job2_Address__c = null;
            ctrl.newContact.Prev_Job2_employer__c = null;
            ctrl.newContact.Prev_Job2_Position__c = null;
            ctrl.createAgencyContact();
            ctrl.newContact.Prev_Job1_Position__c = 'test';
            ctrl.newContact.Prev_Job1_From__c = Date.today();
            ctrl.newContact.Prev_Job1_Address__c = 'test';
            ctrl.newContact.Prev_Job1_employer__c = 'test';
            ctrl.createAgencyContact();



            ctrl.saveAMSFormAndGoToStep1();
            List<AMS_Accreditation_Contact__c> accList = ctrl.List_AgencyContacts;
            List<AMS_Accreditation_Contact__c> acc2List = ctrl.List_AgencyCompanies;
            List<ISSP_AMS_Statement_International_Sales__c> asmList = ctrl.List_InternationalSales;
            List<AMS_Accreditation_Contact__c> acc3List = ctrl.List_Ownership_Summary;
            Double testDouble = ctrl.Ownership_Total;
            Decimal testDec = ctrl.InternationalSales_Total;

            ctrl.isEUcountry = true;
            ctrl.vatNumber = 'test';
            ctrl.validateVATNumber();
            Boolean testBool = ctrl.openHQCaseExists;
            String testStr = ctrl.pageLanguage;

            ctrl.newCase.Region__c = 'Africa & Middle East';
            ctrl.getRegionalQueue();

            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'es');

            ctrl.newCase.BSPCountry__c = 'Spain';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.hqAccount.Website = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCountry = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingPostalCode = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCity = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingStreet = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.TradeName__c = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.Name = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.newContact.Name = 'Î£汉字';
            ctrl.validateCharactersInCompanyWindow();
            ctrl.newContact.Registration_number__c = 'Î£汉字';
            ctrl.validateCharactersInCompanyWindow();

            ctrl.goToDownloadPDF();
        }
    }

    @isTest static void ISSP_AMS_Accreditation_Test_6() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '1');
            ApexPages.currentPage().getParameters().put('sectorValue' , 'Travel_Agent');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();

            ctrl.goToStep1();

            ctrl.goToStep2();

            ctrl.goToStep3();


            ctrl.draftHQCaseExists = true;
            ctrl.stepNumber = '';
            ctrl.txtHelpMinPaidCapital = '';
            ctrl.txtHelpRegisteredCapital = '';
            ctrl.txtHelpPaidUpCapital = '';
            ctrl.txtHelpTaxNumber = '';
            ctrl.txtHelpAuthorisedSig = '';
            ctrl.txtHelpFinContact = '';
            ctrl.txtHelpPortalAdmin = '';
            ctrl.txtHelpGrossSales = '';
            ctrl.isEUcountry = true;
            ctrl.vatNumber = '123';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.save();
            ctrl.sectorValue = 'Travel_Agent';
            ctrl.newForm.Agent_Type__c = 'IATA Passenger Sales Agent';
            ctrl.amsOfficeType = 'HO';
            ctrl.sector = 'Travel Agent';
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.amsOfficeType = 'Branch';
            ctrl.highLightPageForErrors();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_7() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'GB',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.Sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '10090909';
        parent.Type = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;

        insert parent;

        Account branch = ISSP_ObjectFactory.createNewAccount();
        branch.BillingCity = 'test';
        branch.Name = 'test';
        branch.Sector__c = 'Cargo Agent';
        branch.Location_Type__c = 'BR';
        branch.RecordTypeId = rtIdBr;
        branch.IATACode__c = '10090908';
        branch.Type = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;

        insert branch;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'GB';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '1');
            ApexPages.currentPage().getParameters().put('sectorValue' , 'Travel_Agent');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();

            ctrl.sectorValue = 'Travel_Agent';
            ctrl.con.Account.Sector__c = 'Travel Agent';
            ctrl.isHOAccredited  = true;
            ctrl.getOfficeTypes();

            ApexPages.currentPage().getParameters().put('sectorValue' , 'Cargo_Agent');

            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.con.Account.Sector__c = 'Cargo Agent';
            ctrl.isHOAccredited  = false;
            ctrl.isocountry.EACP_Country__c = true;
            ctrl.getOfficeTypes();

            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.con.Account.Sector__c = 'Cargo Agent';
            ctrl.isHOAccredited  = false;
            ctrl.isocountry.EACP_Country__c = false;
            ctrl.isCASSImport = true;
            ctrl.isoCountry.Disable_non_IATA_Cargo_Agents__c = false;
            ctrl.getOfficeTypes();

            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.con.Account.Sector__c = 'Cargo Agent';
            ctrl.isHOAccredited  = false;
            ctrl.isocountry.EACP_Country__c = false;
            ctrl.isCASSImport = true;
            ctrl.isoCountry.Disable_non_IATA_Cargo_Agents__c = false;
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = 'IATA Cargo Agent';
            ctrl.isHOAccredited  = true;
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = 'CASS Associates';
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = 'Courier';
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = 'Import Agent';
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = AMS_Utils.CATEGORY_CASSASSOCIATE;
            ctrl.isocountry.EACP_Country__c = true;
            ctrl.getOfficeTypes();

            ctrl.isHOAccredited = true;
            ctrl.con.Account.Sector__c = AMS_Utils.SECTOR_CARGO;
            ctrl.con.Account.Category__c = 'IATA Cargo Agent';
            ctrl.getOfficeTypes();

            ctrl.isocountry.EACP_Country__c = false;
            ctrl.communityName = 'CNS';
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = AMS_Utils.CATEGORY_CASSASSOCIATE;
            ctrl.isocountry.EACP_Country__c = true;
            ctrl.getOfficeTypes();

            ctrl.con.Account.Category__c = AMS_Utils.CATEGORY_IMPORT_AGENT;
            ctrl.getOfficeTypes();

            ctrl.isHOAccredited = false;
            ctrl.getOfficeTypes();

            ctrl.iatacode = '100';

            ctrl.goToStep1();

            ctrl.goToStep2();

            ctrl.goToStep3();

            ctrl.goToStep4();

            ctrl.goToStep5();

            ctrl.iatacode = '100';
            ctrl.fetchAgentDetails(); 

            ctrl.prevAgentHistory = '1';
            ctrl.fetchAgentDetails();

            ctrl.iatacode = '10090908';
            ctrl.agentsector = AMS_Utils.SECTOR_CARGO;
            ctrl.amsOfficeType = 'Branch';
            ctrl.newCase.Reason1__c = 'idk';
            ctrl.isAddCompanyModal = true;
            ctrl.accountType = 'IATA Cargo Agent';
            ctrl.fetchAgentDetails();

            ctrl.accountType = 'CASS Associates';
            ctrl.fetchAgentDetails();

            ctrl.agentsector = AMS_Utils.SECTOR_PASSENGER;
            ctrl.fetchAgentDetails();

            ctrl.iatacode = '10090909';
            ctrl.agentsector = 'Both';
            ctrl.fetchAgentDetails();

            ctrl.agentsector = 'idk';
            ctrl.accountType = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
            ctrl.fetchAgentDetails();

            ctrl.draftHQCaseExists = true;
            ctrl.stepNumber = '';
            ctrl.txtHelpMinPaidCapital = '';
            ctrl.txtHelpRegisteredCapital = '';
            ctrl.txtHelpPaidUpCapital = '';
            ctrl.txtHelpTaxNumber = '';
            ctrl.txtHelpAuthorisedSig = '';
            ctrl.txtHelpFinContact = '';
            ctrl.txtHelpPortalAdmin = '';
            ctrl.txtHelpGrossSales = '';
            ctrl.isEUcountry = true;
            ctrl.vatNumber = '123';
            ctrl.amsLocationType = 'New HO - IATA Cargo Agent';
            ctrl.save();
            ctrl.applyLanguage = 'es';
            ctrl.fetchCountryRequirements();

        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_8() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'CN',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist1 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist1.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist1.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist1.License_required__c = true ;
        AMS_Acc_Checklist1.Registration_required__c = true ;
        AMS_Acc_Checklist1.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist1;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist2 = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist2.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist2.Operation__c = 'Cargo Agent';
        AMS_Acc_Checklist2.License_required__c = true ;
        AMS_Acc_Checklist2.Registration_required__c = true ;
        AMS_Acc_Checklist2.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist2;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist1.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;


        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'CN';
            testCase.Applicable_to_Which_Version_s__c = '5';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('sectorValue' , 'Cargo_Agent');

            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();

            ctrl.newCase = testCase ;

            // applyLanguage
            ctrl.countryISOCodeList = new List<SelectOption>();

            List<SelectOption> so = new List<SelectOption>();
            List<String> langs = new List<String> {'es', 'fr', 'else'};
            for (String l : langs) {
                ctrl.applyLanguage = l;
                so = ctrl.countryISOCodeList;
                so = ctrl.countryNameList;
            }

            // getOfficeTypes
            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.getOfficeTypes();

            // save
            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA = 'YES';
            ctrl.sectorValue = 'Travel_Agent';

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA = 'NO';
            ctrl.sectorValue = 'else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '5';

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA = 'NO';
            ctrl.sectorValue = 'else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '4';

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA = 'NO';
            ctrl.sectorValue = 'else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '3';

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA = 'NO';
            ctrl.sectorValue = 'else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '2';


            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'pt_BR');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ko');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ar');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'zh_CN');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'in');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ja');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'th');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'vi');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'de');

            ctrl.newCase.BSPCountry__c = 'Canada';
            ctrl.newCase.Region__c = 'Europe';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.Region__c = 'Americas';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.BSPCountry__c = 'Brazil';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.BSPCountry__c = 'test';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.Region__c = 'China';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.Region__c = 'Africa';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.Region__c = 'test2';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.amsOfficeType = 'HO';
            ctrl.draftHQCaseExists = false;
            ctrl.amsIsGSA = 'NO';
            ctrl.sectorValue = 'Travel_Agent';
            ctrl.isDupeSAAMCase = true;
            ctrl.amsLocationType = 'New HO - IATA Cargo Agent';
            ctrl.save();
            ctrl.amsLocationType = 'New BR Abroad - IATA Passenger Sales Agent';
            ctrl.save();
            ctrl.CheckCountryReqments();
            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.newForm.Agent_Type__c = 'IATA Cargo Agent';
            ctrl.amsOfficeType = 'HO';
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            List<ISSP_AMS_Accreditation.AccountChanges> accChanges_List = new List<ISSP_AMS_Accreditation.AccountChanges>();
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('Phone', '0534534534', '0243242523'));

        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_9() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Name = con.Name;
            newContact.Salutation__c = con.Salutation;
            newContact.First_name__c = con.FirstName;
            newContact.Last_name__c = con.LastName;
            newContact.Phone__c = con.Phone;
            newContact.Email__c = con.Email;
            newContact.Job_title__c = con.Title;
            newContact.Authorised_signatory__c = true;
            newContact.Phone__c = '1123123';
            newContact.Email__c = 'test@test.com';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP');
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id;
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ApexPages.currentPage().getParameters().put('step' , '5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';

            ctrl.amsOfficeType = 'HO';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;


            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();

            ctrl.newContact.Agencies_prev_worked_for__c = '';
            ctrl.legalstatus = 'sole proprietorship';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.newContact.Financial_interest__c = 0;
            ctrl.newContact.Agencies_prev_worked_for__c = null;
            ctrl.newContact.Prev_Job1_Position__c = null;
            ctrl.newContact.Prev_Job1_From__c = null;
            ctrl.newContact.Prev_Job1_Address__c = null;
            ctrl.newContact.Prev_Job1_employer__c = null;
            ctrl.newContact.Agencies_prev_worked_for__c = '2';
            ctrl.newContact.Prev_Job2_Position__c = null;
            ctrl.newContact.Prev_Job2_From__c = null;
            ctrl.newContact.Prev_Job2_Address__c = null;
            ctrl.newContact.Prev_Job2_employer__c = null;
            ctrl.createAgencyContact();
            ctrl.newContact.Agencies_prev_worked_for__c = '1';
            ctrl.createAgencyContact();

            ctrl.newInternationalSales.Sales_Amount__c = 1;
            ctrl.newInternationalSales.AMS_Online_Accreditation__c = null;
            ctrl.newInternationalSales.CurrencyIsoCode = '';
            ctrl.createInternationalSales();

            ctrl.newForm.ISSP_AMS_where_incorporated__c = 'testÎ©x';
            ctrl.newForm.ISSP_AMS_Principal_business_Org__c = 'testÎ©x';
            ctrl.hqAccount.BillingState = 'testÎ©x';
            ctrl.newContact.Job_title__c = 'testÎ©x';
            ctrl.newContact.AddressStreet__c = 'testÎ©x';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = 'testÎ©x';
            ctrl.newContact.AddressCity__c = 'testÎ©x';
            ctrl.newContact.First_name__c = 'testÎ©x';
            ctrl.newContact.Last_name__c = 'testÎ©x';
            ctrl.hqAccount.BillingStreet = 'testÎ©x';
            ctrl.hqAccount.BillingCity = 'testÎ©x';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c = 'testÎ©x';
            ctrl.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = 'testÎ©x';
            ctrl.validateCharactersInForm();

            ctrl.goToStep3Section1();
            ctrl.goToStep3Section2();
            ctrl.goToStep3Section3();
            ctrl.goToStep3Section4();
            ctrl.goToStep3Section5();
            ctrl.goToStep3Section6();
            ctrl.goToStep3Section7();

            ctrl.amsOfficeType = 'test';
            ctrl.newForm.ISSP_AMS_Previous_default__c = 'test';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = 'test';
            ctrl.newForm.ISSP_AMS_Legal_Status__c = null;
            ctrl.newCase.Reason1__c = 'Old HO';
            ctrl.amsIsGSA = 'NO';
            ctrl.isDupeSAAMCase = false;
            ctrl.isNewCase = true;
            ctrl.save();

            ctrl.highLightPageForErrors();
            ctrl.saveAMSFormAndGoToStep5();
            ctrl.newCase.CaseArea__c = 'test';
            ctrl.newCase.Reason1__c = 'test';
            ctrl.sector = 'Travel Agent';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
            ctrl.goToFinalStep();

            ctrl.sectorValue = 'Travel_Agent';
            ctrl.newCase.Reason1__c = 'New BR / IP';
            ctrl.getCGORegionData();
            ctrl.newForm.CGO_Region_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_Consignment_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_Tons_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_AirFreight_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_Percentage_Selection__c = 'Africa';
            ctrl.getCGORegionData();
            ctrl.saveAMSForm();
            ctrl.sectorValue = 'Cargo_Agent';
            ctrl.saveAMSForm();
            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.saveAMSForm();

            ctrl.contactType = 'House';
            ctrl.newContact.Agencies_prev_worked_for__c = '';
            ctrl.newContact.Agency_owner__c = true;
            ctrl.newContact.Financial_interest__c = 0;
            ctrl.createAgencyContact();
            ctrl.newContact.Agencies_prev_worked_for__c = null;
            ctrl.newContact.Financial_interest__c = 1;
            ctrl.createAgencyContact();
            ctrl.newContact.Agency_owner__c = false;
            ctrl.newContact.Agency_role__c = false;
            ctrl.newContact.Agencies_prev_worked_for__c = '2';
            ctrl.createAgencyContact();
            ctrl.newContact.Prev_Job2_From__c = null;
            ctrl.newContact.Prev_Job2_Address__c = null;
            ctrl.newContact.Prev_Job2_employer__c = null;
            ctrl.newContact.Prev_Job2_Position__c = null;
            ctrl.createAgencyContact();
            ctrl.newContact.Prev_Job1_Position__c = 'test';
            ctrl.newContact.Prev_Job1_From__c = Date.today();
            ctrl.newContact.Prev_Job1_Address__c = 'test';
            ctrl.newContact.Prev_Job1_employer__c = 'test';
            ctrl.createAgencyContact();



            ctrl.saveAMSFormAndGoToStep1();
            List<AMS_Accreditation_Contact__c> accList = ctrl.List_AgencyContacts;
            List<AMS_Accreditation_Contact__c> acc2List = ctrl.List_AgencyCompanies;
            List<ISSP_AMS_Statement_International_Sales__c> asmList = ctrl.List_InternationalSales;
            List<AMS_Accreditation_Contact__c> acc3List = ctrl.List_Ownership_Summary;
            Double testDouble = ctrl.Ownership_Total;
            Decimal testDec = ctrl.InternationalSales_Total;

            ctrl.isEUcountry = true;
            ctrl.vatNumber = 'test';
            ctrl.validateVATNumber();
            Boolean testBool = ctrl.openHQCaseExists;
            String testStr = ctrl.pageLanguage;

            ctrl.newCase.Region__c = 'Africa & Middle East';
            ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Americas';
            ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'China & North Asia';
            ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Europe';
            ctrl.getRegionalQueue();

            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'es');

            ctrl.newCase.BSPCountry__c = 'Spain';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.BSPCountry__c = 'France';
            ctrl.sendConfirmationEmail(ctrl.newCase);

            ctrl.newCase.Reason1__c = 'FoP Management';
            ctrl.newCase.origin = 'Massive FOP Creation';
            ctrl.sendConfirmationEmail(ctrl.newCase);

            ctrl.isNoticeOfChange = true;
            ctrl.newCase.Reason1__c = 'idk';
            ctrl.newCase.ContactId = con.id;
            ctrl.sendConfirmationEmail(ctrl.newCase);

            ctrl.isNoticeOfChange = false;
            ctrl.newCase.BSPCountry__c = null;
            ctrl.sendConfirmationEmail(ctrl.newCase);

            ctrl.hqAccount.Website = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCountry = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingPostalCode = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCity = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingStreet = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.TradeName__c = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.Name = 'Î£';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.newContact.Name = 'Î£';
            ctrl.validateCharactersInCompanyWindow();
            ctrl.newContact.Registration_number__c = 'Î£';
            ctrl.validateCharactersInCompanyWindow();
        }
    }

    @isTest static void ISSP_AMS_Accreditation_Test_10() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '200';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;



            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_11() {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '200';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_12() {


        Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        Id rtAccreditContPersonOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        Id rtAccreditContCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        //NoC
        Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
        Id rtAccreditContCurrentOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
        Id rtAccreditContPreviousCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
        Id rtAccreditContCurrentCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');

        ISSP_AMS_Contextual_Help__c Contextual_Help1 = new ISSP_AMS_Contextual_Help__c(Name = 'CURRENCY', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help2 = new ISSP_AMS_Contextual_Help__c(Name = 'MIN_PAIDUP_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help3 = new ISSP_AMS_Contextual_Help__c(Name = 'REGISTERED_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help4 = new ISSP_AMS_Contextual_Help__c(Name = 'PAIDUP_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help5 = new ISSP_AMS_Contextual_Help__c(Name = 'TAX_NUMBER', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help6 = new ISSP_AMS_Contextual_Help__c(Name = 'AUTHORISED_SIG', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help7 = new ISSP_AMS_Contextual_Help__c(Name = 'FIN_CONTACT', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help8 = new ISSP_AMS_Contextual_Help__c(Name = 'PORTAL_ADMIN', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help9 = new ISSP_AMS_Contextual_Help__c(Name = 'GROSS_SALES', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');


        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                Enable_Minor_Changes_from_Portal__c = true,
                Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name = 'Test1 Person', User__c = newUser.Id, Lastname__c = 'person', Phone__c = '123123123');
        insert p1;

        AMS_Account_Role__c ar1 = new AMS_Account_Role__c(Account__c = parent.id,  Employee_Name__c = 'test1',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test1', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Owner_Account__c = child.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar2 = new AMS_Account_Role__c(Account__c = parent.id,  Employee_Name__c = 'test2',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test2', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Person__c = p1.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar3 = new AMS_Account_Role__c(Account__c = parent.id, Employee_Name__c = 'test3',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test3', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Contact__c = con.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar4 = new AMS_Account_Role__c(Account__c = parent.id, Employee_Name__c = 'test4',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test4', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Legacy_External_ID__c = '1234', Contact__c = con.id,
                RecordTypeId = rtAccRoleOwnership);

        insert new List<AMS_Account_Role__c>{ar1, ar2, ar3, ar4};

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            List<Case> caseList = new List<Case>();
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            caseList.add(testCase);

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = 'Cargo';
            testCase2.Customer_recovery__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            testCase2.Account_Concerned__c = parent.Id;
            testCase2.IFAP_Country_ISO__c = 'tq';
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;
            caseList.add(testCase2);

            insert caseList;

            List<AMS_Pax_Accreditation_Form__c> formList = new List<AMS_Pax_Accreditation_Form__c>();

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            formList.add(newForm);

            AMS_Pax_Accreditation_Form__c newForm2 = new AMS_Pax_Accreditation_Form__c();
            newForm2.IsGSA__c = 'No';
            newForm2.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm2.SAAM_Case__c = testCase2.Id;
            formList.add(newForm2);

            insert formList ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

            List<SelectOption> countryList = ctrl.countryList;
            Integer agencyCodesSize = ctrl.getAgencyCodesConcernedSize();

            AMS_Accreditation_Contact__c accrCont1 = ISSP_AMS_Accreditation.setAccreditationContact(ar1, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont2 = ISSP_AMS_Accreditation.setAccreditationContact(ar2, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont3 = ISSP_AMS_Accreditation.setAccreditationContact(ar3, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont4 = ISSP_AMS_Accreditation.setAccreditationContact(ar4, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);


            ctrl.setContextualHelp('en_US');

            Id idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Africa & Middle East';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Americas';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Asia & Pacific';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'China & North Asia';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Europe';
            idQueues = ctrl.getRegionalQueue();


            ctrl.setOwners('NoC');

            ctrl.save();
            ctrl.isScopeOfChangeChanged = true;
            ctrl.setOwners('Branch');

            newForm.Scope_of_Change__c = 'HO - All Branches';
            newform.Accept_terms_and_conditions__c = true;
            newForm2.Scope_of_Change__c = 'HO - All Branches';
            newform2.Accept_terms_and_conditions__c = true;

            ctrl.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl.newform.Accept_terms_and_conditions__c = true;
            ctrl.newform.Is_this_Head_Office_becoming_a_Branch__c = 'No';
            ctrl.newform.Will_such_change_affect_the_premises__c = 'No';
            ctrl.newform.Effective_Date_Of_Change__c = Date.newInstance(2016, 11, 11);
            ctrl.isNewHOforAccredAgent = true;
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            Pagereference pr1 = ctrl.goToFinalStep();

            ApexPages.currentPage().getParameters().put('caseId' , testCase2.Id );
            ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation();
            ctrl2.newCase = testCase2 ;

            ctrl2.isNoticeOfChange = true;
            ctrl2.isBankAccountChange = false;
            ctrl2.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl2.newform.Accept_terms_and_conditions__c = true;

            ctrl2.newform.Is_change_legal_name__c = true;
            ctrl2.newForm.Notify_Change_Legal_Details__c = true;
            ctrl2.newform.Is_change_location__c = true;
            ctrl2.newForm.Notify_Change_Location__c = true;
            ctrl2.newForm.Notify_Change_Ownership__c = true;
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            ctrl2.newForm.Is_this_Head_Office_becoming_a_Branch__c = 'Yes';
            ctrl2.newform.Will_such_change_affect_the_premises__c = 'Yes';
            ctrl2.newform.Will_such_change_affect_the_managers__c = 'Yes';
            ctrl2.newForm.Have_any_having_authorization_to_act__c = 'Yes';
            ctrl2.newForm.Will_the_change_of_ownership_cause__c = 'Yes';
            ctrl2.newForm.Will_such_change_affect_locations__c = 'No';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            ctrl2.newForm.Account_Name__c = 'test';
            ctrl2.newForm.ISSP_AMS_VAT_Number_Input__c = '21';
            ctrl2.newForm.Local_Legally_Registered_Name__c = 'test';
            ctrl2.newForm.Branch_Office_Street_name_number__c = 'test';
            ctrl2.newForm.Branch_Office_City__c = 'test';
            ctrl2.newForm.Branch_Office_Phone_National__c = '12345';
            ctrl2.newForm.Local_Physical_Address_Street__c = 'test';
            ctrl2.newForm.Local_Physical_Address_City__c = 'test';
            ctrl2.newForm.Local_Physical_Address_Province__c = 'test';
            ctrl2.newForm.Local_Postal_Address_City__c = 'test';
            ctrl2.newForm.Local_Postal_Address_Province__c = 'test';
            ctrl2.newForm.New_Head_Office_IATA_Code__c = '1000001';
            ctrl2.newForm.Please_provide_details_for_the_change__c = 'test';
            ctrl2.newForm.ISSP_AMS_Legal_Status__c = 'test';
            ctrl2.newForm.Provide_details_for_change_affect_staff__c = 'test';
            ctrl2.newForm.Give_details_for_authorization_to_act__c = 'test';
            ctrl2.newForm.Give_details_for_the_change_of_ownership__c = 'test';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            ctrl2.isBankAccountChange = true;
            ctrl2.newForm.Scope_of_Change__c = 'HO - Selected Branches';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            Pagereference pr2 = ctrl2.redirectToCasePage();

        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_13() {


        Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        Id rtAccreditContPersonOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        Id rtAccreditContCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        //NoC
        Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
        Id rtAccreditContCurrentOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
        Id rtAccreditContPreviousCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
        Id rtAccreditContCurrentCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');


        ISSP_AMS_Contextual_Help__c Contextual_Help1 = new ISSP_AMS_Contextual_Help__c(Name = 'CURRENCY', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help2 = new ISSP_AMS_Contextual_Help__c(Name = 'MIN_PAIDUP_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help3 = new ISSP_AMS_Contextual_Help__c(Name = 'REGISTERED_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help4 = new ISSP_AMS_Contextual_Help__c(Name = 'PAIDUP_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help5 = new ISSP_AMS_Contextual_Help__c(Name = 'TAX_NUMBER', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help6 = new ISSP_AMS_Contextual_Help__c(Name = 'AUTHORISED_SIG', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help7 = new ISSP_AMS_Contextual_Help__c(Name = 'FIN_CONTACT', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help8 = new ISSP_AMS_Contextual_Help__c(Name = 'PORTAL_ADMIN', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help9 = new ISSP_AMS_Contextual_Help__c(Name = 'GROSS_SALES', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');


        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                Enable_Minor_Changes_from_Portal__c = true,
                Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Cargo_Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name = 'Test1 Person', User__c = newUser.Id);
        insert p1;


        AMS_Account_Role__c ar1 = new AMS_Account_Role__c(Account__c = parent.id,  Employee_Name__c = 'test1',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test1', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Owner_Account__c = child.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar2 = new AMS_Account_Role__c(Account__c = parent.id,  Employee_Name__c = 'test2',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test2', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Person__c = p1.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar3 = new AMS_Account_Role__c(Account__c = parent.id, Employee_Name__c = 'test3',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test3', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Contact__c = con.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar4 = new AMS_Account_Role__c(Account__c = parent.id, Employee_Name__c = 'test4',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test4', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Legacy_External_ID__c = '1234',
                RecordTypeId = rtAccRoleOwnership);


        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'New HO';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';

            insert testCase;


            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Change_of_Bank_Account_Details');
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation( );
            ctrl.newCase = testCase ;

            try {
                ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation(new ISSP_AddAttachment() );
                ctrl2.newCase = testCase ;
            } catch (Exception e) {

            }

            try {
                newform = null;
                ISSP_AMS_Accreditation ctrl3 = new ISSP_AMS_Accreditation(new ISSP_AddAttachment() );
                ctrl3.newCase = testCase ;
            } catch (Exception e) {

            }


            ctrl.newForm.Agency_Codes_Concerned__c = 'a;b;c';
            List<SelectOption> lsoAgencyCodesConcerned = ctrl.getAgencyCodesConcerned();


            ctrl.updateNoCAgencyLegalDetails();

        }

        Test.stopTest();
    }

    // CB - test change of bank details w creation of child cases & oscars for them
    @isTest static void ISSP_AMS_Accreditation_Test_14() {


        Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        Id rtAccreditContPersonOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        Id rtAccreditContCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        //NoC
        Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
        Id rtAccreditContCurrentOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
        Id rtAccreditContPreviousCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
        Id rtAccreditContCurrentCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                Enable_Minor_Changes_from_Portal__c = true,
                Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name = 'Test1 Person', User__c = newUser.Id);
        insert p1;

        AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
        insert hierarchy;

        AMS_Agencies_relationhip__c rel1 = new AMS_Agencies_relationhip__c(Hierarchy__c = hierarchy.Id, Parent_Account__c = parent.Id, Child_Account__c = child.Id);
        insert rel1;

        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = false ;
        AMS_Acc_Checklist.Registration_required__c = false ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = false ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;


        System.runAs(newUser) {

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = 'Cargo';
            testCase2.Region__c = 'Europe';
            testCase2.Customer_recovery__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            testCase2.AccountId = parent.Id;
            testCase2.Account_Concerned__c = parent.Id;
            testCase2.IFAP_Country_ISO__c = 'tq';
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;

            insert testCase2;


            AMS_Pax_Accreditation_Form__c newForm2 = new AMS_Pax_Accreditation_Form__c();
            newForm2.IsGSA__c = 'No';
            newForm2.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm2.SAAM_Case__c = testCase2.Id;
            newForm2.Agency_Codes_Concerned__c = '2000000';
            newForm2.Scope_of_Change__c = 'HO - Selected Branches';
            insert newForm2 ;

            Test.startTest();

            ApexPages.currentPage().getParameters().put('caseId', testCase2.Id );
            ApexPages.currentPage().getParameters().put('isBankAccountChange' , 'true');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' , 'true');
            ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation();
            ctrl2.newCase = testCase2 ;

            ctrl2.isNoticeOfChange = true;
            ctrl2.isBankAccountChange = true;

            ctrl2.newForm.Scope_of_Change__c = 'HO - Selected Branches';
            ctrl2.newForm.Agency_Codes_Concerned__c = '2000000';
            ctrl2.newform.Accept_terms_and_conditions__c = true;
            ctrl2.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            Pagereference pr1 = ctrl2.goToFinalStep();

            Test.stopTest();



        }


        // Check that the child case was create & it has an OSCAR attached
        list<Case> childCases = [SELECT Id, ParentId, OSCAR__c FROM Case ORDER BY CreatedDate ASC];
        System.assertNotEquals(true, childCases.isEmpty());
        System.assertEquals(null, childCases[0].ParentId);

    }

    // CB - test notification to HO user when change of bank details submitted from BR
    @isTest static void ISSP_AMS_Accreditation_Test_15() {


        Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        Id rtAccreditContPersonOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        Id rtAccreditContCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        //NoC
        Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
        Id rtAccreditContCurrentOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
        Id rtAccreditContPreviousCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
        Id rtAccreditContCurrentCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                Enable_Minor_Changes_from_Portal__c = true,
                Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        Contact con_adm = ISSP_ObjectFactory.createNewContact();
        con_adm.AccountId= parent.Id;
        con_adm.Email = 'Test2@test22.com';
        con_adm.User_Portal_Status__c = 'Approved Admin';
        insert con_adm;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        System.runAs(newUser) {

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = 'Cargo';
            testCase2.Region__c = 'Europe';
            testCase2.Customer_recovery__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            testCase2.AccountId = child.Id;
            testCase2.Account_Concerned__c = child.Id;
            testCase2.IFAP_Country_ISO__c = 'tq';
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;

            insert testCase2;
			
            System.debug(Logginglevel.ERROR,'[ISSP_AMS_Accreditation_Test:Test15]Start: Number of Queries used in this apex code so far: ' + Limits.getQueries());
            Test.startTest();
            
	            AMS_Pax_Accreditation_Form__c newForm2 = new AMS_Pax_Accreditation_Form__c();
	            newForm2.IsGSA__c = 'No';
	            newForm2.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm2.SAAM_Case__c = testCase2.Id;
	            newForm2.Agency_Codes_Concerned__c = '2000000';
	            newForm2.Scope_of_Change__c = 'HO - Selected Branches';
	            insert newForm2 ;


	            ApexPages.currentPage().getParameters().put('caseId', testCase2.Id );
	            ApexPages.currentPage().getParameters().put('isBankAccountChange' , 'true');
	            ApexPages.currentPage().getParameters().put('isNoticeOfChange' , 'true');
	            ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation();
	                
	         System.debug(Logginglevel.ERROR,'[ISSP_AMS_Accreditation_Test:Test15]g1: Number of Queries used in this apex code so far: ' + Limits.getQueries());
	            
	            ctrl2.newCase = testCase2 ;
    
	            ctrl2.isNoticeOfChange = true;
	            ctrl2.isBankAccountChange = true;
	
	            ctrl2.newForm.Scope_of_Change__c = 'HO - Selected Branches';
	            ctrl2.newForm.Agency_Codes_Concerned__c = '2000000';
	            ctrl2.newform.Accept_terms_and_conditions__c = true;
	         System.debug(Logginglevel.ERROR,'[ISSP_AMS_Accreditation_Test:Test15]g2: Number of Queries used in this apex code so far: ' + Limits.getQueries());
	
	            ctrl2.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;
    
         	System.debug(Logginglevel.ERROR,'[ISSP_AMS_Accreditation_Test:Test15]g3: Number of Queries used in this apex code so far: ' + Limits.getQueries());

            	Pagereference pr1 = ctrl2.goToFinalStep();
			
            System.debug(Logginglevel.ERROR,'[ISSP_AMS_Accreditation_Test:Test15]Stop: Number of Queries used in this apex code so far: ' + Limits.getQueries());
            Test.stopTest();
        }

        // checkk there was a notification created for the contact on the HO
        list<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assertNotEquals(true, notifications.isEmpty());

    }

    @isTest static void ISSP_AMS_Accreditation_Test_16() {


        Id OSCAR_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Id rtAccRoleOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');

        Id rtAccreditContPersonOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        Id rtAccreditContCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        //NoC
        Id rtAccreditContPreviousOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Owner');
        Id rtAccreditContCurrentOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner');
        Id rtAccreditContPreviousCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Previous_Company_Owner');
        Id rtAccreditContCurrentCompanyOwner = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner');

        ISSP_AMS_Contextual_Help__c Contextual_Help1 = new ISSP_AMS_Contextual_Help__c(Name = 'CURRENCY', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help2 = new ISSP_AMS_Contextual_Help__c(Name = 'MIN_PAIDUP_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help3 = new ISSP_AMS_Contextual_Help__c(Name = 'REGISTERED_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help4 = new ISSP_AMS_Contextual_Help__c(Name = 'PAIDUP_CAPITAL', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help5 = new ISSP_AMS_Contextual_Help__c(Name = 'TAX_NUMBER', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help6 = new ISSP_AMS_Contextual_Help__c(Name = 'AUTHORISED_SIG', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help7 = new ISSP_AMS_Contextual_Help__c(Name = 'FIN_CONTACT', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help8 = new ISSP_AMS_Contextual_Help__c(Name = 'PORTAL_ADMIN', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');
        ISSP_AMS_Contextual_Help__c Contextual_Help9 = new ISSP_AMS_Contextual_Help__c(Name = 'GROSS_SALES', ISSP_AMS_HelpText_ar__c   = 'test', ISSP_AMS_HelpText_de__c = 'test', ISSP_AMS_HelpText_en_US__c  = 'test', ISSP_AMS_HelpText_es__c = 'test', ISSP_AMS_HelpText_fr__c = 'test', ISSP_AMS_HelpText_in__c = 'test', ISSP_AMS_HelpText_it__c = 'test', ISSP_AMS_HelpText_ja__c = 'test', ISSP_AMS_HelpText_ko__c = 'test', ISSP_AMS_HelpText_pt_BR__c  = 'test', ISSP_AMS_HelpText_th__c = 'test', ISSP_AMS_HelpText_vi__c = 'test', ISSP_AMS_HelpText_zh_CN__c  = 'test');


        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                Enable_Minor_Changes_from_Portal__c = true,
                Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id;
        parent.IATA_ISO_Shipping_Country__c = country.Id;

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.ParentId = parent.Id;
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name = 'Test1 Person', User__c = newUser.Id);
        insert p1;


        AMS_Account_Role__c ar1 = new AMS_Account_Role__c(Account__c = parent.id,  Employee_Name__c = 'test1',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test1', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Owner_Account__c = child.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar2 = new AMS_Account_Role__c(Account__c = parent.id,  Employee_Name__c = 'test2',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test2', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Person__c = p1.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar3 = new AMS_Account_Role__c(Account__c = parent.id, Employee_Name__c = 'test3',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test3', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Contact__c = con.id,
                RecordTypeId = rtAccRoleOwnership);

        AMS_Account_Role__c ar4 = new AMS_Account_Role__c(Account__c = parent.id, Employee_Name__c = 'test4',
                Employee_type__c = 'CL', Owner_Name__c = 'owner test4', Percentage__c = 100,
                Position__c = 'A', Valid__c = true, Title__c = 'owner',
                Legacy_External_ID__c = '1234',
                RecordTypeId = rtAccRoleOwnership);


        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Test.startTest();
        System.runAs(newUser) {
            List<Case> caseList = new List<Case>();
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = AMS_Utils.CASE_REASON_NEW_HO;
            testCase.RecordTypeId = OSCAR_RECORD_TYPE_ID;
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            caseList.add(testCase);
            //insert testCase;

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = AMS_Utils.CASE_REASON_BR_IP;
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;
            testCase2.Customer_recovery__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            testCase2.Account_Concerned__c = parent.Id;
            testCase2.IFAP_Country_ISO__c = 'tq';
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;
            caseList.add(testCase2);

            insert caseList;

            List<AMS_Pax_Accreditation_Form__c> formList = new List<AMS_Pax_Accreditation_Form__c>();

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            formList.add(newForm);

            AMS_Pax_Accreditation_Form__c newForm2 = new AMS_Pax_Accreditation_Form__c();
            newForm2.IsGSA__c = 'No';
            newForm2.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm2.SAAM_Case__c = testCase2.Id;
            formList.add(newForm2);

            insert formList ;

            ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

            AMS_Accreditation_Contact__c accrCont1 = ISSP_AMS_Accreditation.setAccreditationContact(ar1, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont2 = ISSP_AMS_Accreditation.setAccreditationContact(ar2, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont3 = ISSP_AMS_Accreditation.setAccreditationContact(ar3, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont4 = ISSP_AMS_Accreditation.setAccreditationContact(ar4, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);


            ctrl.setContextualHelp('en_US');

            Id idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Africa & Middle East';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Americas';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Asia & Pacific';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'China & North Asia';
            idQueues = ctrl.getRegionalQueue();
            ctrl.newCase.Region__c = 'Europe';
            idQueues = ctrl.getRegionalQueue();


            ctrl.setOwners('NoC');
            ctrl.setOwners('Branch');

            newForm.Scope_of_Change__c = 'HO - All Branches';
            newform.Accept_terms_and_conditions__c = true;
            newForm2.Scope_of_Change__c = 'HO - All Branches';
            newform2.Accept_terms_and_conditions__c = true;

            ctrl.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl.newform.Accept_terms_and_conditions__c = true;
            ctrl.newform.Is_this_Head_Office_becoming_a_Branch__c = 'No';
            ctrl.newform.Will_such_change_affect_the_premises__c = 'No';
            ctrl.newform.Effective_Date_Of_Change__c = Date.newInstance(2016, 11, 11);
            ctrl.isNewHOforAccredAgent = true;
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            Pagereference pr1 = ctrl.goToFinalStep();

            ApexPages.currentPage().getParameters().put('caseId' , testCase2.Id );
            ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation();
            ctrl2.newCase = testCase2 ;

            ctrl2.isNoticeOfChange = true;
            ctrl2.isBankAccountChange = false;
            ctrl2.newForm.Scope_of_Change__c = 'HO - All Branches';
            ctrl2.newform.Accept_terms_and_conditions__c = true;

            ctrl2.newform.Is_change_legal_name__c = true;
            ctrl2.newForm.Notify_Change_Legal_Details__c = true;
            ctrl2.newform.Is_change_location__c = true;
            ctrl2.newForm.Notify_Change_Location__c = true;
            ctrl2.newForm.Notify_Change_Ownership__c = true;
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            ctrl2.newForm.Is_this_Head_Office_becoming_a_Branch__c = 'Yes';
            ctrl2.newform.Will_such_change_affect_the_premises__c = 'Yes';
            ctrl2.newform.Will_such_change_affect_the_managers__c = 'Yes';
            ctrl2.newForm.Have_any_having_authorization_to_act__c = 'Yes';
            ctrl2.newForm.Will_the_change_of_ownership_cause__c = 'Yes';
            ctrl2.newForm.Will_such_change_affect_locations__c = 'No';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            ctrl2.newForm.Account_Name__c = 'test';
            ctrl2.newForm.ISSP_AMS_VAT_Number_Input__c = '21';
            ctrl2.newForm.Local_Legally_Registered_Name__c = 'test';
            ctrl2.newForm.Branch_Office_Street_name_number__c = 'test';
            ctrl2.newForm.Branch_Office_City__c = 'test';
            ctrl2.newForm.Branch_Office_Phone_National__c = '12345';
            ctrl2.newForm.Local_Physical_Address_Street__c = 'test';
            ctrl2.newForm.Local_Physical_Address_City__c = 'test';
            ctrl2.newForm.Local_Physical_Address_Province__c = 'test';
            ctrl2.newForm.Local_Postal_Address_City__c = 'test';
            ctrl2.newForm.Local_Postal_Address_Province__c = 'test';
            ctrl2.newForm.New_Head_Office_IATA_Code__c = '1000001';
            ctrl2.newForm.Please_provide_details_for_the_change__c = 'test';
            ctrl2.newForm.ISSP_AMS_Legal_Status__c = 'test';
            ctrl2.newForm.Provide_details_for_change_affect_staff__c = 'test';
            ctrl2.newForm.Give_details_for_authorization_to_act__c = 'test';
            ctrl2.newForm.Give_details_for_the_change_of_ownership__c = 'test';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            ctrl2.isBankAccountChange = true;
            ctrl2.newForm.Scope_of_Change__c = 'HO - Selected Branches';
            ctrl.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pr1 = ctrl2.goToFinalStep();

            Pagereference pr2 = ctrl2.redirectToCasePage();

        }

        Test.stopTest();
    }

    // aosantos, 2017-04-10, Increase Code Coverage
    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_01() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.noCLocationType = 'xpto';

            str = accr.noCLocationType;

            accr.txtHelpCurrency = 'xpto';

            str = accr.txtHelpCurrency;

            selectOptionList = new List<SelectOption>();

            accr.isGSAList = selectOptionList;
            accr.itemsYesNo = selectOptionList;

            selectOptionList = accr.isGSAList;
            selectOptionList = accr.itemsYesNo;

            accr.fileName = 'xpto';
            str = accr.fileName;

            accr.consignments = 'xpto';
            str = accr.consignments;

            accr.isleased = 'xpto';
            str = accr.isleased;

            accr.issubcontractor = 'xpto';
            str = accr.issubcontractor;

            accr.passedFormValidation = true;
            bol = accr.passedFormValidation;

            accr.fileBody = Blob.valueOf('xpto');
            blb = accr.fileBody;

            accr.hqAccount.Website = invalidISOsample;
            accr.hqAccount.BillingCountry = invalidISOsample;
            accr.hqAccount.BillingPostalCode = invalidISOsample;
            accr.hqAccount.BillingCity = invalidISOsample;
            accr.hqAccount.BillingStreet = invalidISOsample;
            accr.hqAccount.TradeName__c = invalidISOsample;
            accr.hqAccount.Name = invalidISOsample;

            accr.validateCharactersInAgencyWindow();

            accr.newContact.First_name__c = invalidISOsample;
            accr.newContact.Last_name__c = invalidISOsample;
            accr.newContact.Last_name__c = invalidISOsample;
            accr.newContact.AddressStreet__c = invalidISOsample;
            accr.newContact.AddressCity__c = invalidISOsample;
            accr.newContact.AddressPostcode__c = invalidISOsample;
            accr.newContact.Job_title__c = invalidISOsample;

            accr.newContact.Agencies_prev_worked_for__c = '2';
            accr.newContact.Prev_Job1_Employer__c = invalidISOsample;
            accr.newContact.Prev_Job1_Position__c = invalidISOsample;
            accr.newContact.Prev_Job1_Address__c = invalidISOsample;
            accr.newContact.Prev_Job2_Employer__c = invalidISOsample;
            accr.newContact.Prev_Job2_Position__c = invalidISOsample;
            accr.newContact.Prev_Job2_Address__c = invalidISOsample;

            accr.validateCharactersInPersonWindow();

            accr.isNoticeOfChange = false;
            accr.newForm.ISSP_AMS_where_incorporated__c = invalidISOsample;
            accr.newForm.ISSP_AMS_Principal_business_Org__c = invalidISOsample;
            accr.hqAccount.BillingState = invalidISOsample;
            accr.newContact.Job_title__c = invalidISOsample;
            accr.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = invalidISOsample;
            accr.newForm.ISSP_AMS_Prev_default_explanation__c = invalidISOsample;
            accr.newContact.AddressCity__c = invalidISOsample;
            accr.newContact.First_name__c = invalidISOsample;
            accr.newContact.Last_name__c = invalidISOsample;
            accr.hqAccount.BillingStreet = invalidISOsample;
            accr.hqAccount.BillingCity = invalidISOsample;
            accr.amsOfficeType = 'Branch';
            accr.newForm.Branch_Office_Street_name_number__c = invalidISOsample;
            accr.newForm.Branch_Office_City__c = invalidISOsample;
            accr.newForm.Branch_Office_Postal_code__c = invalidISOsample;
            accr.newForm.State_Province__c = invalidISOsample;
            accr.newForm.Branch_Office_Email__c = 'invalid@@email';
            accr.newCase.Reason1__c = 'New BR Abroad';
            accr.newForm.Account_name__c = invalidISOsample;
            accr.newForm.Trade_Name__c = invalidISOsample;
            accr.newForm.ISSP_AMS_Online_Agency_URL__c = 'xpto';
            accr.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = invalidISOsample;
            /*** AMSU-112 - Start ***/
            accr.newForm.ISSP_AMS_License_No__c = invalidISOsample;
            accr.newForm.ISSP_AMS_Trade_Reg_No__c = invalidISOsample;
            accr.newForm.ISSP_AMS_VAT_Number_Input__c = invalidISOsample;
            accr.newForm.ISSP_AMS_VAT_number__c = invalidISOsample;
            accr.newForm.Shipping_Street__c = invalidISOsample;
            accr.newForm.Shipping_City__c = invalidISOsample;
            accr.newForm.Shipping_Postal_Code__c = invalidISOsample;
            accr.newForm.Shipping_State__c = invalidISOsample;
            accr.newForm.Shipping_Country__c = invalidISOsample;
            /*** AMSU-112 - End ***/

            accr.validateCharactersInForm();

            accr.facilityRecordTypeName = 'Office';
            accr.facilityInContext = new AMS_Facility__c();
            accr.facilityInContext.Are_Consignments_made_ready__c = 'Yes';
            accr.facilityInContext.Any_functions_involved_in_preperations__c = null;
            accr.isocountry.EACP_Country__c = true;
            accr.newForm.ISSP_AMS_Number_of_Years_Traded__c = null;
            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = null;

            accr.saveFacilities();

            accr.facilityInContext.Is_the_office_warehouse_leased__c = 'Yes';
            accr.isocountry.EACP_Country__c = false;
            accr.facilityInContext.Name_of_lessor__c = null;
            accr.facilityInContext.Duration_of_lease__c = null;
            accr.facilityInContext.Date_lease_expires__c = null;
            accr.facilityInContext.Other_pertinent_details__c = null;

            accr.saveFacilities();

            accr.facilityRecordTypeName = 'Warehouse';
            accr.facilityInContext.Is_the_warehouse_sub_contracted__c = 'Yes';
            accr.facilityInContext.Name_of_sub_contractor__c = null;
            accr.facilityInContext.Date_agreement_expires__c = null;
            accr.facilityInContext.Duration_of_contract__c = null;

            accr.saveFacilities();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_02() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'A';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_03() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'C';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_04() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'E';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_05() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'L';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_06() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'O';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_07() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'P';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_08() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'R';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_09() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'S';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_10() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'T';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_11() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'Z';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            pageRef = accr.save();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_12() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'Z';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            accr.isNoticeOfChange = false;
            accr.amsOfficeType = 'to';
            accr.newCase.Reason1__c = 'Xpto';
            accr.isNewHOforAccredAgent = true;
            accr.sectorValue = 'Travel_AgentX';
            accr.newForm.Accept_terms_and_conditions__c = true;
            accr.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pageRef = accr.goToFinalStep();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_13() {
        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'Z';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.isNoticeOfChange = true;
            accr.isNewCase = true;
            accr.newCase.Reason1__c = 'New BR / IP';
            accr.hqAccount.Company_Type__c = companyType;

            accr.isNoticeOfChange = false;
            accr.amsOfficeType = 'Xpto';
            accr.newCase.Reason1__c = 'Xpto';
            accr.isNewHOforAccredAgent = true;
            accr.sectorValue = 'Cargo_Agent';
            accr.newForm.Accept_terms_and_conditions__c = true;
            accr.newform.Agent_Type__c = AMS_UTILS.NEWFORM_AGENTTYPE_NO_CASH;

            pageRef = accr.goToFinalStep();
        }

        Test.stopTest();
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_CC() {

        Account childAccount;
        User testUser;
        Contact testContact;
        ISSP_AMS_Accreditation accr;
        String str;
        Boolean bol;
        Blob blb;
        PageReference pageRef;
        String invalidISOsample = '∌';
        List<SelectOption> selectOptionList;
        String companyType = 'Z';

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );

        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        Test.startTest();

        insert country;
        insert country2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {

            ISSP_AMS_Accreditation cont = new ISSP_AMS_Accreditation();


            cont.dummy();

            cont.resetOwnership();

            cont.iatacode = '121321343';
            cont.iatanAccount = AMS_UTILS.IATAN_PASSENGER_AGENT;

            cont.fetchIATANDetails();

        }
    }


    @isTest
    static void testOptOut() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = false;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            testCase.Status = 'Draft';
            testCase.Origin = 'Portal';
            testCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
            testCase.Reason1__c = AMS_Utils.CASE_REASON_OPT_OUT;


            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }

    @isTest
    static void testOptOut2() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }
        
        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = false;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }

    @isTest
    static void testOptOut3() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = true;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }

    @isTest
    static void testOptOut4() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = true;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        con.User_Portal_Status__c = 'Administrator';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }

    @isTest
    static void testOptOut5() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = true;
        parent.Type = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        con.Financial_Assessment_Contact__c = true;
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }

    @isTest
    static void testOptOut6() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = true;
        parent.Type = AMS_Utils.CATEGORY_PASSENGER_SALES_AGENT;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        con.User_Portal_Status__c = 'Administrator';
        con.Financial_Assessment_Contact__c = true;
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser)
        {
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }

    @isTest
    static void testOptOut7() {
        IATA_ISO_Country__c country;
        IATA_ISO_Country__c country2;

        for (IATA_ISO_Country__c fetchedCountry: [SELECT Name, IATA_Contry_KR__c, CASS_Import__c, IATA_COUNTRY_EN__c, IATA_Country_FR__c, IATA_Country_ZH__c,
                                                        IATA_Country_IT__c, IATA_Country_JP__c, ISO_Code__c, IATA_Country_PT__c, IATA_Country_SP__c, Case_BSP_Country__c,
                                                        IATA_ISO_Country__c.CurrencyIsoCode
                                                  FROM IATA_ISO_Country__c]) {
            if (fetchedCountry.Name == 'testOptOut') country = fetchedCountry;
            else if (fetchedCountry.Name == 'testOptOut2') country2 = fetchedCountry;
        }

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = AMS_Utils.SECTOR_PASSENGER;
        parent.Location_Type__c = 'HO';
        parent.IATA_ISO_Country__c = country.Id;
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.ANG_FA_Opt_out__c = true;
        parent.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH;

        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        Test.startTest();
        System.runAs(newUser) {
            //AMS_OSCAR__c oscar = new AMS_OSCAR__c(Name = 'oscar', Account__c = parent.Id);
            //insert oscar;
            
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Customer_recovery__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tp';
            testCase.Status = 'Open - EDMC';
            testCase.Origin = 'Portal';
            testCase.RecordTypeId = AMS_Utils.RECTYPE_OSCARCOMM;
            testCase.Reason1__c = AMS_Utils.CASE_REASON_OPT_OUT;
            //testCase.OSCAR__c = oscar.Id;

            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            ctrl.pEfectiveDateStr = '2018-03-31';
            List<Case> lc = ctrl.getAMSDraftCases();
            ctrl.runOptInOut();
        }
        Test.stopTest();
    }


    private static Account icc_testAccount(IATA_ISO_Country__c country) {

        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';

        // aosantos 2017-04-10 17:06
        parent.Status__c = 'Terminated';

        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;

        return child;
    }

    private static Contact icc_testContact(Account child) {
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        return con;
    }

    private static User icc_testUser(Contact con) {
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;

        return newUser;
    }

    private static User icc_testUser2(Contact con, String language) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + String.valueof(datetime.now());
        String conId15 = con.Id;
        conId15 = conId15.substring(0, 15);
        User newUser = new User(alias = 'dsfsdfds',
                                email = con.email,
                                emailencodingkey = 'UTF-8',
                                firstname = con.firstName,
                                lastname = con.lastname,
                                languagelocalekey = language,
                                localesidkey = language,
                                contactId = con.Id,
                                FederationIdentifier = conId15,
                                timezonesidkey = 'Asia/Dubai',
                                Username = uniqueName + string.valueof(Integer.valueOf(math.rint(math.random() * 1000000))) + '@test' + orgId + '.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@')) + Datetime.now().formatLong().substring(10, 15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        con.OwnerId = newUser.Id;
        update con;

        return newUser;
    }

    private static ISSP_AMS_Accreditation icc_initialize(IATA_ISO_Country__c country, Account child) {
        AMS_Accreditation_Country_CheckList__c AMS_Acc_Checklist = new  AMS_Accreditation_Country_CheckList__c();
        AMS_Acc_Checklist.IATA_ISO_Country__c = country.id ;
        AMS_Acc_Checklist.Operation__c = 'Travel Agent';
        AMS_Acc_Checklist.License_required__c = true ;
        AMS_Acc_Checklist.Registration_required__c = true ;
        AMS_Acc_Checklist.Statement_of_International_Sales__c = true ;
        insert AMS_Acc_Checklist;

        AMS_Accreditation_Requirement__c ISSP_AMS_Accreditation_Acc_Req = new AMS_Accreditation_Requirement__c();
        ISSP_AMS_Accreditation_Acc_Req.AMS_Accreditation_Country_CheckList__c = AMS_Acc_Checklist.Id ;
        ISSP_AMS_Accreditation_Acc_Req.Language__c = 'English';
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO; Head Office;Branch';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        insert ISSP_AMS_Accreditation_Acc_Req;

        Case testCase = ISSP_ObjectFactory.createNewCase();
        testCase.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase.Reason1__c = 'Cargo';
        testCase.Customer_recovery__c = false;
        testCase.BounceEmailCounter__c = 0.0;
        testCase.Case_Language__c = 'English';
        testCase.Subject = 'Test 006';
        testCase.Reopened_case__c = 0.0;
        testCase.Account_Concerned__c = child.Id;
        testCase.IFAP_Country_ISO__c = 'tq';
        insert testCase;

        AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
        newForm.IsGSA__c = 'No';
        newForm.CurrencyIsoCode = country.CurrencyIsoCode;
        newForm.SAAM_Case__c = testCase.Id;
        insert newForm ;

        ApexPages.currentPage().getParameters().put('caseId' , testCase.Id );
        ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
        ctrl.newCase = testCase;
        return ctrl;
    }
}
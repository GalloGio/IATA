@isTest
private class ISSP_AMS_Accreditation_Test 
{
    @testSetup static void customSettingSetup() {
        insert new ISSP_CS__c(Name = 'ISSP AMS ALLOWED AGENCY URL',Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)([.])(([a-zA-Z]{3})|([a-zA-Z]{2}))');
        insert new ISSP_CS__c(Name = 'No Notification Email Contact Id',Value__c = null);
    }

    @isTest static void ISSP_AMS_Accreditation_Test_1() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;
                
            //newContact = new AMS_Accreditation_Contact__c();
            //newContact.Name = con.Name;
            //newContact.Salutation__c = con.Salutation;
            //newContact.First_name__c = con.FirstName;
            //newContact.Last_name__c = con.LastName;
            //newContact.Phone__c = con.Phone;
            //newContact.Email__c = con.Email;
            //newContact.Job_title__c = con.Title;
            //newContact.Authorised_signatory__c = true;

            //newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            //insert newContact;

            //ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            //AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            //insert AMS_SIS;
            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            ctrl.getnewlabels();
            //ctrl.newContact =  newContact ;
            //ctrl.newInternationalSales = AMS_SIS ;
        }
        Test.stopTest();
    }
     @isTest static void ISSP_AMS_Accreditation_Test_17() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = null;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        insert new ISSP_CS__c(Name = 'DefaultNewAccountOwnerId',Value__c = newUser.Id);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        System.debug('cs query '+ [select Name,value__c from ISSP_CS__c]);
        ISSP_Constant cons = new ISSP_Constant();
        Map<String,String> customSeting = ISSP_Constant.customSetingMap;
        System.debug('constant customSeting '+ customSeting);
        System.debug('constant cs query '+ ISSP_Constant.newAccountOwnerId);

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
        System.runAs(newUser)
        {
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
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
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

            /*    
            AMS_Accreditation_Contact__c newContact = new AMS_Accreditation_Contact__c();
            newContact.Registration_number__c = '123456';
            newContact.PhoneNational__c = '0534534534';
            newContact.MobileNational__c = '012410412';
            newContact.IATACode__c = '1234567';
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;
            */

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'4');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            ctrl.iatacode = '1234567';
            ctrl.companyModalNameOfEmployer = 'employee';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();
            ctrl.isNewCase = true;
            ctrl.save();
            
            ctrl.createBranchAccount();
            //ctrl.goToFinalStep();
        }
        Test.stopTest();
    }


     @isTest static void ISSP_AMS_Accreditation_Test_2() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
                
            //newContact = new AMS_Accreditation_Contact__c();
            //newContact.Name = con.Name;
            //newContact.Salutation__c = con.Salutation;
            //newContact.First_name__c = con.FirstName;
            //newContact.Last_name__c = con.LastName;
            //newContact.Phone__c = con.Phone;
            //newContact.Email__c = con.Email;
            //newContact.Job_title__c = con.Title;
            //newContact.Authorised_signatory__c = true;

            //newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            //insert newContact;

            //ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            //AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            //insert AMS_SIS;
            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'2');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            //ctrl.newContact =  newContact ;
            //ctrl.newInternationalSales = AMS_SIS ;

            
        }
        Test.stopTest();
    }


     @isTest static void ISSP_AMS_Accreditation_Test_3() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
                
            //newContact = new AMS_Accreditation_Contact__c();
            //newContact.Name = con.Name;
            //newContact.Salutation__c = con.Salutation;
            //newContact.First_name__c = con.FirstName;
            //newContact.Last_name__c = con.LastName;
            //newContact.Phone__c = con.Phone;
            //newContact.Email__c = con.Email;
            //newContact.Job_title__c = con.Title;
            //newContact.Authorised_signatory__c = true;

            //newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            //insert newContact;

            //ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            //AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            //insert AMS_SIS;
            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'3');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            Decimal InternationalCharges_Collected_Total = ctrl.InternationalCharges_Collected_Total;
            Decimal InternationalPrepaid_Collected_Total  = ctrl.InternationalPrepaid_Collected_Total;
            //ctrl.newContact =  newContact ;
            //ctrl.newInternationalSales = AMS_SIS ;

            
        }
        Test.stopTest();
    }


     @isTest static void ISSP_AMS_Accreditation_Test_4() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
                
            //newContact = new AMS_Accreditation_Contact__c();
            //newContact.Name = con.Name;
            //newContact.Salutation__c = con.Salutation;
            //newContact.First_name__c = con.FirstName;
            //newContact.Last_name__c = con.LastName;
            //newContact.Phone__c = con.Phone;
            //newContact.Email__c = con.Email;
            //newContact.Job_title__c = con.Title;
            //newContact.Authorised_signatory__c = true;

            //newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            //insert newContact;

            //ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            //AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            //insert AMS_SIS;
            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'4');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;
            //ctrl.newContact =  newContact ;
            //ctrl.newInternationalSales = AMS_SIS ;

            
        }
        Test.stopTest();
    }


     @isTest static void ISSP_AMS_Accreditation_Test_5() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Local_language_Agency_details_required__c = true );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', Local_language_Agency_details_required__c = true);
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingStreet = 'test';
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Cargo Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

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
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo Agent';
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
            newContact.Agency_owner__c = true;
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP'); 
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
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
            //ctrl.newform.Accept_terms_and_conditions__c = true;
            ctrl.highLightPageForErrors();
            ctrl.sector = 'Travel Agent';
            ctrl.goToFinalStep();
            ctrl.amsOfficeType = 'Branch';
            ctrl.newForm.Wholly_owned_by_this_Head_Office__c=null;
            ctrl.newForm.Wholly_managed_by_this_Head_Office__c=null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c=null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_when_incorporated__c=null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_where_incorporated__c=null;
            ctrl.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            ctrl.newForm.ISSP_AMS_Entity_with_listed_shares__c=null;
            ctrl.newForm.Branch_Office_Street_name_number__c=null;
            ctrl.newForm.Branch_Office_City__c=null;
            ctrl.newForm.Branch_Office_Phone__c=null;
            ctrl.newForm.ISSP_AMS_License_No__c=null;
            ctrl.newForm.ISSP_AMS_Date_license_granted__c=null;
            ctrl.newForm.ISSP_AMS_VAT_number__c=null;
            ctrl.newForm.ISSP_AMS_Previous_default__c=null;
            ctrl.newForm.ISSP_AMS_Previous_default__c='YES';
            ctrl.newForm.ISSP_AMS_Prev_default_explanation__c=null;
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c=null;
            ctrl.isocountry.ISO_Code__c='CN';
            ctrl.goToFinalStep();

            ctrl.sector = 'Cargo Agent';
            AMS_Acc_Checklist1.Operation__c = 'Cargo Agent';
            Update AMS_Acc_Checklist1;
            ctrl.goToFinalStep();

            ctrl.getIsEmpty();
            ctrl.getIsNotEmpty();
            ctrl.getPrevWorkedForItems();

            //ctrl.convertAMSContacts();
            ctrl.cancel();
            //ctrl.deleteAgencyContact();
            ctrl.setPageLegalStatusLabels();
            ctrl.legalStatus = 'association';
            ctrl.setPageLegalStatusLabels();
            ctrl.legalStatus = 'co-operative';
            ctrl.setPageLegalStatusLabels();
            ctrl.updateAmsCountry();
            
            
            
        }
            
    }
  
      
  
    @isTest static void ISSP_AMS_Accreditation_Test_NOC_1s() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'BR';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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

        Test.startTest();
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo Agent';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
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

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' ,'true');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' ,'true');
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
            ctrl.goToFinalStep();

            ctrl.newform.Accept_terms_and_conditions__c = true;

            ctrl.goToFinalStep();

        }
            
    }

    @isTest static void ISSP_AMS_Accreditation_Test_NOC_2s() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Local_language_Agency_details_required__c = true );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', Local_language_Agency_details_required__c = true);
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'BR';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Cargo Agent';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
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

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' ,'false');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' ,'true');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            ctrl.securityCheck();
            ctrl.getIsEmptySumbittedCases();
            String loginURL = ctrl.Portal_Login_URL;
            
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
            ctrl.goToFinalStep();
            ctrl.validateDangerousGoods(5);
   
        }
            
    }

    @isTest static void ISSP_AMS_Accreditation_Test_NOC_3s() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test',
                                    Local_language_Agency_details_required__c = true );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', Local_language_Agency_details_required__c = true);
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'BR';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'Travel Agent';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = false;
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

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
            ApexPages.currentPage().getParameters().put('isBankAccountChange' ,'false');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' ,'true');
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
            ctrl.goToStep5();
            ctrl.saveAMSFormAndGoForward();
            ctrl.saveAMSFormAndGoBack();
            ctrl.saveAMSFormAndLeave();
            ctrl.setPageLegalStatusAfterChangeLabels();
            ctrl.newForm.Validation_ERRORS__c = true;
            ctrl.highLightPageForErrors();
            ctrl.sectorValue= 'Travel_Agent';
            ctrl.fetchCountryRequirements();
            ctrl.goToFinalStep();
            ctrl.validateDangerousGoods(5);
   
        }
            
    }
    
    
    
    @isTest static void ISSP_AMS_Accreditation_Test_20() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 

        Id rtIdOff = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'AMS_Facility__c'
        AND DeveloperName = 'Office'][0].Id; 

        Id rtIdWar = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'AMS_Facility__c'
        AND DeveloperName = 'Warehouse'][0].Id; 

        Id rtIdTS = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'AMS_Accreditation_Contact__c'
        AND DeveloperName = 'Trained_Staff'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
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
            //ctrl.convertAMSContacts();
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
            Boolean isGSAReq = ctrl.getIsGSARequired();
            ctrl.fetchCountryRequirements();
            ctrl.goToFinalStep();

            AMS_Acc_Checklist.Operation__c = 'Cargo Agent';
            Update AMS_Acc_Checklist;
            ctrl.fetchCountryRequirements();
            ctrl.validateCharactersInPersonWindow();
            ctrl.amsOfficeType = 'Branch';
            ctrl.validateCharactersInForm();
            ctrl.CheckCountryReqments();

        }
            
    }

     @isTest static void ISSP_AMS_Accreditation_Test_17s()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            
            ctrl.amsOfficeType = 'HO';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            
            ctrl.newContact.Agencies_prev_worked_for__c ='';
                
            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agencies_prev_worked_for__c ='test';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();

            ctrl.newContact.Agencies_prev_worked_for__c= '';
            ctrl.legalstatus = 'sole proprietorship';
            ctrl.newContact.Agency_owner__c=true;
            ctrl.newContact.Financial_interest__c =0;
            ctrl.newContact.Agencies_prev_worked_for__c =null;
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
            ctrl.newContact.Agencies_prev_worked_for__c='1';
            ctrl.createAgencyContact();
            ctrl.newContact.Registration_number__c ='1234';
            ctrl.createAgencyContact();
            ctrl.deleteAgencyContact();

        }
    }
   
    


   @isTest static void ISSP_AMS_Accreditation_Test_5s()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP'); 
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            
            ctrl.amsOfficeType = 'HO';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            
                
            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agencies_prev_worked_for__c ='test';
            ctrl.newContact.Agency_owner__c =true;
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();
            ctrl.sector = 'Travel Agent';
            ctrl.applyLanguage = 'fr';
            ctrl.fetchCountryRequirements();
            
            ctrl.includedPageName = 'ISSP_AMS_Pax_Form';
            ctrl.newContact.Agencies_prev_worked_for__c= '';
            ctrl.legalstatus = 'sole proprietorship';
            ctrl.newContact.Agency_owner__c=true;
            ctrl.newContact.Financial_interest__c =0;
            ctrl.newContact.Agencies_prev_worked_for__c =null;
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
            ctrl.newContact.Agencies_prev_worked_for__c='1';
            ctrl.createAgencyContact();

            ctrl.newInternationalSales.Sales_Amount__c = 1;
            ctrl.newInternationalSales.AMS_Online_Accreditation__c = null;
            ctrl.newInternationalSales.CurrencyIsoCode = '';
            ctrl.createInternationalSales();

            ctrl.newForm.ISSP_AMS_where_incorporated__c='testÎ©x';
            ctrl.newForm.ISSP_AMS_Principal_business_Org__c='testÎ©x';
            ctrl.hqAccount.BillingState='testÎ©x';
            ctrl.newContact.Job_title__c ='testÎ©x';
            ctrl.newContact.AddressStreet__c='testÎ©x';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c='testÎ©x';
            ctrl.newContact.AddressCity__c='testÎ©x';
            ctrl.newContact.First_name__c='testÎ©x';
            ctrl.newContact.Last_name__c='testÎ©x';
            ctrl.hqAccount.BillingStreet='testÎ©x';
            ctrl.hqAccount.BillingCity='testÎ©x';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c='testÎ©x';
            ctrl.newForm.ISSP_AMS_Legal_Reg_Name_Address__c='testÎ©x';
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
            ctrl.goToFinalStep();

            //ctrl.newForm.SAAM_Case__c = null;
            ctrl.sectorValue='Travel_Agent';
            ctrl.newCase.Reason1__c = 'New BR / IP';
            ctrl.saveAMSForm();
            ctrl.sectorValue='Cargo_Agent';
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
            //ctrl.newCase.Region__c = 'Americas';
            //ctrl.getRegionalQueue();
            //ctrl.newCase.Region__c = 'China & North Asia';
            //ctrl.getRegionalQueue();
            //ctrl.newCase.Region__c = 'Europe';
            //ctrl.getRegionalQueue();

            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'es');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'pt_BR');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ko');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ar');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'zh_CN');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'in');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ja');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'th');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'vi');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'de');

            ctrl.newCase.BSPCountry__c = 'Spain';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'France';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'Canada';
            //ctrl.newCase.Region__c = 'Europe';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'Americas';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'Brazil';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'test';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'China';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'Africa';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'test2';
            //ctrl.sendConfirmationEmail(ctrl.newCase);

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
    
    @isTest static void ISSP_AMS_Accreditation_Test_6() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP'); 
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'1');
            ApexPages.currentPage().getParameters().put('sectorValue' ,'Travel_Agent');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            //ctrl.contactType = 'Company';
            

            

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
            //ctrl.validateVATNumber();
            //ctrl.getIATAMemberAirlines();
            //ctrl.getOfficeTypes();
            //ctrl.Save();
            //ctrl.createAgencyContact();
            //ctrl.createInternationalSales();
            //ctrl.cancelAgentUpdate();
            //ctrl.editSalesId = AMS_SIS.Id;
            //ctrl.editInternationalSales();
            //ctrl.cancelSalesUpdate();
            //ctrl.deleteInternationalSales();
            //ctrl.editAgencyContact();
            //ctrl.updateAgencyDetails();
            //ctrl.goToStep2();
            //ctrl.goToStep3();
            //ctrl.goToStep4();
            //ctrl.goToStep5();
            //ctrl.saveAMSFormAndGoForward();
            //ctrl.saveAMSFormAndGoBack();
            //ctrl.saveAMSFormAndLeave();
            //ctrl.goToFinalStep();
            //ctrl.getIsEmpty();
            //ctrl.getIsNotEmpty();
            //ctrl.getPrevWorkedForItems();
            //ctrl.convertAMSContacts();
            //ctrl.cancel();
            //ctrl.deleteAgencyContact();
            //ctrl.setPageLegalStatusLabels();
        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_7() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                        IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                        IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'GB',
                        IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'1');
            ApexPages.currentPage().getParameters().put('sectorValue' ,'Travel_Agent');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            //ctrl.contactType = 'Company';

            ctrl.sectorValue = 'Travel_Agent';
            ctrl.con.Account.Sector__c = 'Travel Agent';
            ctrl.isHOAccredited  = true;
            ctrl.getOfficeTypes();

            ApexPages.currentPage().getParameters().put('sectorValue' ,'Cargo_Agent');

            // getOfficeTypes
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
            
            ctrl.iatacode = '100';
            

            ctrl.goToStep1();

            ctrl.goToStep2();

            ctrl.goToStep3();

            ctrl.goToStep4();

            ctrl.goToStep5();

            ctrl.iatacode = '100';
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

    @isTest static void ISSP_AMS_Accreditation_Test_8()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'CN',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            //testCase.Continous_Feed_SAF__c = true;
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
            //insert AMS_SIS;
            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('sectorValue' ,'Cargo_Agent');
            
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            
            ctrl.newCase = testCase ;
            
            //RecordType rec = new RecordType(Name = ctrl.sector);
            //insert rec;
            
            //ctrl.newCase = testCase ;

            // applyLanguage
            ctrl.countryISOCodeList = new List<SelectOption>();

            List<SelectOption> so= new List<SelectOption>();
            List<String> langs = new List<String> {'es','fr','else'};
            for(String l : langs){
                ctrl.applyLanguage=l;
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
            ctrl.amsIsGSA ='YES';
            ctrl.sectorValue ='Travel_Agent';
            //ctrl.save();

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA ='NO';
            ctrl.sectorValue ='else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '5';
            //ctrl.save();

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA ='NO';
            ctrl.sectorValue ='else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '4';
            //ctrl.save();

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA ='NO';
            ctrl.sectorValue ='else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '3';
            //ctrl.save();

            ctrl.newCase.Reason1__c = 'New HO';
            ctrl.draftHQCaseExists = true;
            ctrl.isDupeSAAMCase = true;
            ctrl.amsIsGSA ='NO';
            ctrl.sectorValue ='else';
            ctrl.newCase.Applicable_to_Which_Version_s__c = '2';
            //ctrl.save();


            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'pt_BR');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ko');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ar');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'zh_CN');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'in');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ja');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'th');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'vi');
            ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'de');

            //ctrl.sendConfirmationEmail(ctrl.newCase);
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
            ctrl.amsIsGSA='NO';
            ctrl.sectorValue='Travel_Agent';
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
            //ctrl.draftHQCaseExists = false;
            //ctrl.amsIsGSA='NO';
            //ctrl.save();
            ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice WSInstance = ISSP_AMS_Accreditation.getWSInstance();
            List<ISSP_AMS_Accreditation.AccountChanges> accChanges_List = new List<ISSP_AMS_Accreditation.AccountChanges>();
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('Phone','0534534534','0243242523'));
            //ISSP_AMS_Accreditation.callToMinorChangesWS(WSInstance, parent.Id, accChanges_List);

        }
        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_9()
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            newContact.AMS_Pax_Accreditation_Form__c = newForm.Id;
            insert newContact;

            Portal_Applications__c app = new Portal_Applications__c(Name = 'IFAP'); 
            insert app;

            ISSP_AMS_Statement_International_Sales__c AMS_SIS = new ISSP_AMS_Statement_International_Sales__c();
            AMS_SIS.AMS_Online_Accreditation__c = newForm.Id; 
            AMS_SIS.IATA_Member_Airline__c = child.Id ;
            insert AMS_SIS;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ApexPages.currentPage().getParameters().put('step' ,'5');
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.contactType = 'Company';
            
            ctrl.amsOfficeType = 'HO';
            ctrl.iatacode = '100';
            ctrl.newCase = testCase ;
            ctrl.editContactId =  newContact.Id;
            
                
            ctrl.newContact.Agencies_prev_worked_for__c = 'test';
            ctrl.newContact.Agencies_prev_worked_for__c ='test';
            ctrl.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            ctrl.createAgencyContact();

            ctrl.newContact.Agencies_prev_worked_for__c= '';
            ctrl.legalstatus = 'sole proprietorship';
            ctrl.newContact.Agency_owner__c=true;
            ctrl.newContact.Financial_interest__c =0;
            ctrl.newContact.Agencies_prev_worked_for__c =null;
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
            ctrl.newContact.Agencies_prev_worked_for__c='1';
            ctrl.createAgencyContact();

            ctrl.newInternationalSales.Sales_Amount__c = 1;
            ctrl.newInternationalSales.AMS_Online_Accreditation__c = null;
            ctrl.newInternationalSales.CurrencyIsoCode = '';
            ctrl.createInternationalSales();

            ctrl.newForm.ISSP_AMS_where_incorporated__c='testÎ©x';
            ctrl.newForm.ISSP_AMS_Principal_business_Org__c='testÎ©x';
            ctrl.hqAccount.BillingState='testÎ©x';
            ctrl.newContact.Job_title__c ='testÎ©x';
            ctrl.newContact.AddressStreet__c='testÎ©x';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c='testÎ©x';
            ctrl.newContact.AddressCity__c='testÎ©x';
            ctrl.newContact.First_name__c='testÎ©x';
            ctrl.newContact.Last_name__c='testÎ©x';
            ctrl.hqAccount.BillingStreet='testÎ©x';
            ctrl.hqAccount.BillingCity='testÎ©x';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c='testÎ©x';
            ctrl.newForm.ISSP_AMS_Legal_Reg_Name_Address__c='testÎ©x';
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
            ctrl.goToFinalStep();

            //ctrl.newForm.SAAM_Case__c = null;
            ctrl.sectorValue='Travel_Agent';
            ctrl.newCase.Reason1__c = 'New BR / IP';
            ctrl.getCGORegionData();
            ctrl.newForm.CGO_Region_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_Consignment_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_Tons_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_AirFreight_Selection__c = 'Africa';
            ctrl.newForm.CGO_Region_Percentage_Selection__c = 'Africa';
            ctrl.getCGORegionData();
            ctrl.saveAMSForm();
            ctrl.sectorValue='Cargo_Agent';
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
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'pt_BR');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ko');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ar');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'zh_CN');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'in');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'ja');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'th');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'vi');
            //ctrl.getAmsAllLangCountryLabel(new IATA_ISO_Country__c(), 'de');

            ctrl.newCase.BSPCountry__c = 'Spain';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            ctrl.newCase.BSPCountry__c = 'France';
            ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'Canada';
            //ctrl.newCase.Region__c = 'Europe';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'Americas';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'Brazil';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.BSPCountry__c = 'test';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'China';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'Africa';
            //ctrl.sendConfirmationEmail(ctrl.newCase);
            //ctrl.newCase.Region__c = 'test2';
            //ctrl.sendConfirmationEmail(ctrl.newCase);

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

    @isTest static void ISSP_AMS_Accreditation_Test_10() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id; 

        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '200';
        child.Location_Type__c = 'BR';
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_11() 
    {
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        parent.IATA_ISO_Country__c = country.Id; 

        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '200';
        child.Location_Type__c = 'BR';
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
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
        System.runAs(newUser)
        {
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
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = child.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

        }

        Test.stopTest();
    }

    @isTest static void ISSP_AMS_Accreditation_Test_12() 
    {

        
        Id OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

        Id rtAccRoleOwnership = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();

        Id rtAccreditContPersonOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
        Id rtAccreditContCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        //NoC
        Id rtAccreditContPreviousOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Owner').getRecordTypeId();
        Id rtAccreditContCurrentOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Owner').getRecordTypeId();
        Id rtAccreditContPreviousCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Company Owner').getRecordTypeId();
        Id rtAccreditContCurrentCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Company Owner').getRecordTypeId();


        ISSP_AMS_Contextual_Help__c Contextual_Help1 = new ISSP_AMS_Contextual_Help__c(Name='CURRENCY',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help2 = new ISSP_AMS_Contextual_Help__c(Name='MIN_PAIDUP_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help3 = new ISSP_AMS_Contextual_Help__c(Name='REGISTERED_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help4 = new ISSP_AMS_Contextual_Help__c(Name='PAIDUP_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help5 = new ISSP_AMS_Contextual_Help__c(Name='TAX_NUMBER',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help6 = new ISSP_AMS_Contextual_Help__c(Name='AUTHORISED_SIG',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help7 = new ISSP_AMS_Contextual_Help__c(Name='FIN_CONTACT',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help8 = new ISSP_AMS_Contextual_Help__c(Name='PORTAL_ADMIN',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help9 = new ISSP_AMS_Contextual_Help__c(Name='GROSS_SALES',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');


        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id; 

        insert parent;
        System.debug('parent Id: ' + parent.Id);

       

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name='Test1 Person', User__c=newUser.Id);
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
        System.runAs(newUser)
        {
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
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            insert testCase;

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = 'Cargo';
            testCase2.Customer_recovery__c = false;
            //testCase2.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            //testCase2.Continous_Feed_SAF__c = true;
            testCase2.Account_Concerned__c = parent.Id;
            testCase2.IFAP_Country_ISO__c = 'tq';
            testCase2.RecordTypeId = OSCAR_RECORD_TYPE_ID;
            
            insert testCase2;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            insert newForm ;

            AMS_Pax_Accreditation_Form__c newForm2 = new AMS_Pax_Accreditation_Form__c();
            newForm2.IsGSA__c = 'No';
            newForm2.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm2.SAAM_Case__c = testCase2.Id;
            insert newForm2 ;

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
            ctrl.newCase = testCase ;

            //AMS_Accreditation_Contact__c setAccreditationContact(AMS_Account_Role__c accRole, Id newFormId, Id rtRecordTypePerson, Id rtRecordTypeCompany)

            AMS_Accreditation_Contact__c accrCont1 = ctrl.setAccreditationContact(ar1, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont2 = ctrl.setAccreditationContact(ar2, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont3 = ctrl.setAccreditationContact(ar3, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);
            AMS_Accreditation_Contact__c accrCont4 = ctrl.setAccreditationContact(ar4, newForm.id, rtAccreditContCurrentOwner, rtAccreditContCurrentCompanyOwner);


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

            Pagereference pr1 = ctrl.goToFinalStep();

            ApexPages.currentPage().getParameters().put('caseId' ,testCase2.Id );
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

            pr1 = ctrl2.goToFinalStep();

            ctrl2.newForm.Is_this_Head_Office_becoming_a_Branch__c = 'Yes';
            ctrl2.newform.Will_such_change_affect_the_premises__c = 'Yes';
            ctrl2.newform.Will_such_change_affect_the_managers__c = 'Yes';
            ctrl2.newForm.Have_any_having_authorization_to_act__c = 'Yes';
            ctrl2.newForm.Will_the_change_of_ownership_cause__c = 'Yes';
            ctrl2.newForm.Will_such_change_affect_locations__c = 'No';

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

            pr1 = ctrl2.goToFinalStep();

            ctrl2.isBankAccountChange = true;
            ctrl2.newForm.Scope_of_Change__c = 'HO - Selected Branches';

            pr1 = ctrl2.goToFinalStep();

            //ctrl2.sectorValue = 'Travel_Agent';
            //ctrl2.amsOfficeType = 'HO';

            //newCase.Reason1__c=='New HO'


            //pr1 = ctrl2.goToFinalStep();

            Pagereference pr2 = ctrl2.redirectToCasePage();

        }

        Test.stopTest();
    }

        @isTest static void ISSP_AMS_Accreditation_Test_13() 
    {

        
        Id OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

        Id rtAccRoleOwnership = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();

        Id rtAccreditContPersonOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
        Id rtAccreditContCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        //NoC
        Id rtAccreditContPreviousOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Owner').getRecordTypeId();
        Id rtAccreditContCurrentOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Owner').getRecordTypeId();
        Id rtAccreditContPreviousCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Company Owner').getRecordTypeId();
        Id rtAccreditContCurrentCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Company Owner').getRecordTypeId();


        ISSP_AMS_Contextual_Help__c Contextual_Help1 = new ISSP_AMS_Contextual_Help__c(Name='CURRENCY',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help2 = new ISSP_AMS_Contextual_Help__c(Name='MIN_PAIDUP_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help3 = new ISSP_AMS_Contextual_Help__c(Name='REGISTERED_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help4 = new ISSP_AMS_Contextual_Help__c(Name='PAIDUP_CAPITAL',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help5 = new ISSP_AMS_Contextual_Help__c(Name='TAX_NUMBER',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help6 = new ISSP_AMS_Contextual_Help__c(Name='AUTHORISED_SIG',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help7 = new ISSP_AMS_Contextual_Help__c(Name='FIN_CONTACT',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help8 = new ISSP_AMS_Contextual_Help__c(Name='PORTAL_ADMIN',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');
        ISSP_AMS_Contextual_Help__c Contextual_Help9 = new ISSP_AMS_Contextual_Help__c(Name='GROSS_SALES',ISSP_AMS_HelpText_ar__c   ='test',ISSP_AMS_HelpText_de__c ='test',ISSP_AMS_HelpText_en_US__c  ='test',ISSP_AMS_HelpText_es__c ='test',ISSP_AMS_HelpText_fr__c ='test',ISSP_AMS_HelpText_in__c ='test',ISSP_AMS_HelpText_it__c ='test',ISSP_AMS_HelpText_ja__c ='test',ISSP_AMS_HelpText_ko__c ='test',ISSP_AMS_HelpText_pt_BR__c  ='test',ISSP_AMS_HelpText_th__c ='test',ISSP_AMS_HelpText_vi__c ='test',ISSP_AMS_HelpText_zh_CN__c  ='test');


        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Cargo_Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id; 

        insert parent;
        System.debug('parent Id: ' + parent.Id);

       

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name='Test1 Person', User__c=newUser.Id);
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
        System.runAs(newUser)
        {
            //Case testCase = (Case)ISSP_ObjectFactory.createSObject('Case',false,1);
            Case testCase = ISSP_ObjectFactory.createNewCase();
            testCase.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase.Reason1__c = 'New HO';
            testCase.Customer_recovery__c = false;
            //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            //testCase.Continous_Feed_SAF__c = true;
            testCase.Account_Concerned__c = parent.Id;
            testCase.IFAP_Country_ISO__c = 'tq';
            
            insert testCase;

           
            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
            newForm.IsGSA__c = 'No';
            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
            newForm.SAAM_Case__c = testCase.Id;
            newForm.RecordTypeId = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.RecordTypeInfosByName.get('Change of Bank Account Details').RecordTypeId;
            insert newForm ;

           System.debug('ISSP_AMS_Accreditation_Test_13 - newForm.RecordTypeId: ' + newForm.RecordTypeId);

            ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
            ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation( );
            ctrl.newCase = testCase ;

            try{
            ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation(new ISSP_AddAttachment() );
            ctrl2.newCase = testCase ;
            }catch(Exception e){

            }

            try{
            newform = null;
            ISSP_AMS_Accreditation ctrl3 = new ISSP_AMS_Accreditation(new ISSP_AddAttachment() );
            ctrl3.newCase = testCase ;
            }catch(Exception e){
                
            }


            ctrl.newForm.Agency_Codes_Concerned__c = 'a;b;c';
            List<SelectOption> lsoAgencyCodesConcerned = ctrl.getAgencyCodesConcerned();

            
            ctrl.updateNoCAgencyLegalDetails();
            

            
        }

        Test.stopTest();
    }

    // CB - test change of bank details w creation of child cases & oscars for them
    @isTest static void ISSP_AMS_Accreditation_Test_14() 
    {

        
        Id OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();

        Id rtAccRoleOwnership = Schema.SObjectType.AMS_Account_Role__c.getRecordTypeInfosByName().get('Ownership').getRecordTypeId();

        Id rtAccreditContPersonOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Person').getRecordTypeId();
        Id rtAccreditContCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Company').getRecordTypeId();
        //NoC
        Id rtAccreditContPreviousOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Owner').getRecordTypeId();
        Id rtAccreditContCurrentOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Owner').getRecordTypeId();
        Id rtAccreditContPreviousCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Previous Company Owner').getRecordTypeId();
        Id rtAccreditContCurrentCompanyOwner = Schema.SObjectType.AMS_Accreditation_Contact__c.getRecordTypeInfosByName().get('Current Company Owner').getRecordTypeId();

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' ,
                                    Enable_Minor_Changes_from_Portal__c = true,
                                    Local_language_Agency_details_required__c = true);
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;

        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '1000000';
        parent.IATA_ISO_Country__c = country.Id; 

        insert parent;
        System.debug('parent Id: ' + parent.Id);

       

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        child.IATACode__c = '2000000';
        child.Location_Type__c = 'BR';
        insert child;
        System.debug('child Id: ' + child.Id);

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        AMS_Person__c p1 = new AMS_Person__c(Name='Test1 Person', User__c=newUser.Id);
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

        
        System.runAs(newUser)
        {

            Case testCase2 = ISSP_ObjectFactory.createNewCase();
            testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
            testCase2.Reason1__c = 'Cargo';
            testCase2.Region__c = 'Europe';
            testCase2.Customer_recovery__c = false;
            //testCase2.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase2.BounceEmailCounter__c = 0.0;
            testCase2.Case_Language__c = 'English';
            testCase2.Subject = 'Test 007';
            testCase2.Reopened_case__c = 0.0;
            //testCase2.Continous_Feed_SAF__c = true;
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
            ApexPages.currentPage().getParameters().put('isBankAccountChange' ,'true');
            ApexPages.currentPage().getParameters().put('isNoticeOfChange' ,'true');
            ISSP_AMS_Accreditation ctrl2 = new ISSP_AMS_Accreditation();
            ctrl2.newCase = testCase2 ;

            ctrl2.isNoticeOfChange = true;
            ctrl2.isBankAccountChange = true;

            ctrl2.newForm.Scope_of_Change__c = 'HO - Selected Branches';
            ctrl2.newForm.Agency_Codes_Concerned__c = '2000000';
            ctrl2.newform.Accept_terms_and_conditions__c = true;

            Pagereference pr1 = ctrl2.goToFinalStep();

            Test.stopTest();



        }

       
        // Check that the child case was create & it has an OSCAR attached
        list<Case> childCases = [SELECT Id, ParentId, OSCAR__c FROM Case ORDER BY CreatedDate ASC];
        System.assertNotEquals(true, childCases.isEmpty());
        System.assertEquals(null, childCases[0].ParentId);
       // System.assertEquals(childCases[0].Id, childCases[1].ParentId);
      //  System.assertNotEquals(null, childCases[1].OSCAR__c);

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

            pageRef = accr.goToFinalStep();
        }

        Test.stopTest();        
    }

    
/*
    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_14() {
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

            accr.contactType = 'Trained Staff';
            accr.trainedStaffContact = new AMS_Accreditation_Contact__c();
            accr.isocountry.EACP_Country__c = false;
            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = 'No';
            accr.trainedStaffContact.Training_dangerous_goods_completed__c = null;
            
            accr.createAgencyContact();

            accr.isocountry.EACP_Country__c = true;
            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = 'No';
            accr.trainedStaffContact.Training_dangerous_goods_completed__c = 'Yes';
            accr.trainedStaffContact.Valid_until__c = null;
            
            accr.createAgencyContact();

            accr.trainedStaffContact.Valid_until__c = System.today();

            accr.createAgencyContact();

            accr.trainedStaffContact.Agencies_prev_worked_for__c = '1';
            accr.newContact.Agencies_prev_worked_for__c = '1';

            accr.createAgencyContact();

            accr.trainedStaffContact.Agencies_prev_worked_for__c = '';
            accr.newContact.Agencies_prev_worked_for__c = '';

            accr.createAgencyContact();

            accr.legalstatus = 'sole proprietorship';
            accr.newContact.Agency_owner__c = true;
            accr.amsOfficeType = 'HO';

            accr.createAgencyContact();

            accr.includedPageName = 'ISSP_AMS_Cargo_Form';
            accr.newContact.Time_devoted_to_Agency_business__c = null;
            accr.newContact.AddressCity__c = null;
            accr.newContact.AddressCountry__c = null;
            accr.newContact.AddressStreet__c = null;
            accr.newContact.Agency_owner__c = true;
            accr.amsOfficeType = 'HO';
            accr.newCase.Reason1__c = 'New HO';
            accr.contactType = 'Person';
            
            accr.createAgencyContact();

            accr.includedPageName = 'ISSP_AMS_Cargo_Form';
            accr.newContact.Last_name__c = invalidISOsample;
            accr.newContact.AddressStreet__c = invalidISOsample;
            accr.newContact.AddressCity__c = invalidISOsample;
            accr.newContact.AddressPostcode__c = invalidISOsample;
            accr.newContact.Job_title__c = invalidISOsample;
            accr.newContact.Prev_Job1_Employer__c = invalidISOsample;
            accr.newContact.Prev_Job1_Position__c = invalidISOsample;
            accr.newContact.Prev_Job1_Address__c = invalidISOsample;
            accr.newContact.Prev_Job2_Employer__c = invalidISOsample;
            accr.newContact.Prev_Job2_Position__c = invalidISOsample;
            accr.newContact.Prev_Job2_Address__c = invalidISOsample;
            accr.createAgencyContact();

            accr.newContact.Last_name__c = 'xpto';
            accr.newContact.AddressStreet__c = 'xpto';
            accr.newContact.AddressCity__c = 'xpto';
            accr.newContact.AddressPostcode__c = 'xpto';
            accr.newContact.Job_title__c = 'xpto';
            accr.newContact.Prev_Job1_Employer__c = 'xpto';
            accr.newContact.Prev_Job1_Position__c = 'xpto';
            accr.newContact.Prev_Job1_Address__c = 'xpto';
            accr.newContact.Prev_Job2_Employer__c = 'xpto';
            accr.newContact.Prev_Job2_Position__c = 'xpto';
            accr.newContact.Prev_Job2_Address__c = 'xpto';

            accr.contactType = 'Current Owner';
            accr.newContact.Agency_owner__c = false;
            accr.newContact.Agency_role__c = false;
            
            accr.createAgencyContact();

            accr.contactType = 'Current Owner';
            accr.newContact.Agency_owner__c = true;
            accr.amsOfficeType = 'HO';
            accr.newContact.Financial_interest__c = -1;
            
            accr.createAgencyContact();

            accr.contactType = 'Company';
            accr.companyModalNameOfEmployer = '';
            accr.iatacode = 'X';

            accr.createAgencyContact();

            accr.newContact.Name = invalidISOsample;

            accr.createAgencyContact();

            accr.iatacode = null;
            accr.newContact.Registration_number__c = 'xpto';
            accr.companyModalNameOfEmployer = 'xpto';
            accr.newContact.Name = 'xpto';
            accr.newContact.Financial_interest__c = 1;

            accr.createAgencyContact();

            accr.iatacode = null;
            accr.newContact.Name = invalidISOsample;
            accr.newContact.Registration_number__c = invalidISOsample;
            accr.companyModalNameOfEmployer = 'xpto';
            accr.newContact.Name = 'xpto';
            accr.newContact.Financial_interest__c = 1;

            accr.createAgencyContact();

            accr.contactType = 'Person';

            accr.newContact.First_name__c = invalidISOsample;

            accr.createAgencyContact();

            accr.newContact.Registration_number__c = 'xpto';
            accr.newContact.Name = 'xpto';
            accr.newContact.Financial_interest__c = 1;

            //accr.createAgencyContact();

            //pageRef = accr.securityCheck();
        }

        Test.stopTest();        
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_15() {
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

            accr.contactType = 'Trained Staff';
            accr.trainedStaffContact = new AMS_Accreditation_Contact__c();
            accr.isocountry.EACP_Country__c = false;
            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = 'No';
            accr.trainedStaffContact.Training_dangerous_goods_completed__c = null;

            accr.isocountry.EACP_Country__c = true;
            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = 'No';
            accr.trainedStaffContact.Training_dangerous_goods_completed__c = 'Yes';
            accr.trainedStaffContact.Valid_until__c = null;

            accr.trainedStaffContact.Valid_until__c = System.today();

            accr.trainedStaffContact.Agencies_prev_worked_for__c = '1';
            accr.newContact.Agencies_prev_worked_for__c = '1';

            accr.trainedStaffContact.Agencies_prev_worked_for__c = '';
            accr.newContact.Agencies_prev_worked_for__c = '';

            accr.legalstatus = 'sole proprietorship';
            accr.newContact.Agency_owner__c = true;
            accr.amsOfficeType = 'HO';

            accr.includedPageName = 'ISSP_AMS_Cargo_Form';
            accr.newContact.Time_devoted_to_Agency_business__c = null;
            accr.newContact.Agency_owner__c = true;
            accr.amsOfficeType = 'HO';
            accr.newCase.Reason1__c = 'New HO';
            accr.contactType = 'Person';

            accr.newContact.Last_name__c = 'xpto';
            accr.newContact.AddressStreet__c = 'xpto';
            accr.newContact.AddressCity__c = 'xpto';
            accr.newContact.AddressPostcode__c = 'xpto';
            accr.newContact.Job_title__c = 'xpto';
            accr.newContact.Prev_Job1_Employer__c = 'xpto';
            accr.newContact.Prev_Job1_Position__c = 'xpto';
            accr.newContact.Prev_Job1_Address__c = 'xpto';
            accr.newContact.Prev_Job2_Employer__c = 'xpto';
            accr.newContact.Prev_Job2_Position__c = 'xpto';
            accr.newContact.Prev_Job2_Address__c = 'xpto';

            accr.contactType = 'Current Owner';
            accr.newContact.Agency_owner__c = false;
            accr.newContact.Agency_role__c = false;
            
            accr.createAgencyContact();

            accr.contactType = 'Current Owner';
            accr.newContact.Agency_owner__c = true;
            accr.amsOfficeType = 'HO';
            accr.newContact.Financial_interest__c = -1;
            
            accr.createAgencyContact();

            accr.contactType = 'Company';
            accr.companyModalNameOfEmployer = '';
            accr.iatacode = 'X';

            accr.createAgencyContact();

            accr.newContact.Name = invalidISOsample;

            accr.createAgencyContact();

            accr.contactType = 'Company';
            accr.companyModalNameOfEmployer = 'xpto';
            accr.iatacode = null;

            accr.createAgencyContact();

            accr.newContact.Name = invalidISOsample;

            accr.createAgencyContact();

            accr.iatacode = null;
            accr.newContact.Registration_number__c = null;

            accr.createAgencyContact();

            accr.iatacode = null;
            accr.newContact.Registration_number__c = 'xpto';
            accr.companyModalNameOfEmployer = 'xpto';
            accr.newContact.Name = 'xpto';
            accr.newContact.Financial_interest__c = 1;

            accr.createAgencyContact();

            accr.iatacode = null;
            accr.newContact.Registration_number__c = invalidISOsample;
            accr.companyModalNameOfEmployer = 'xpto';
            accr.newContact.Name = 'xpto';
            accr.newContact.Financial_interest__c = 1;

            accr.createAgencyContact();

            accr.contactType = 'Person';

            accr.newContact.First_name__c = invalidISOsample;

            accr.createAgencyContact();

            accr.newContact.Registration_number__c = 'xpto';
            accr.newContact.Name = 'xpto';
            accr.newContact.Financial_interest__c = 1;

            accr.createAgencyContact();

            pageRef = accr.securityCheck();
        }

        Test.stopTest();        
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_16() {
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

            accr.newForm.Scope_of_Change__c = 'Xpto';
            accr.newForm.Is_change_location__c = false;
            accr.newForm.Is_change_legal_name__c = false;
            accr.newForm.Is_change_ownership_or_shareholding__c = true;
            pageRef = accr.save();

            accr.newForm.Scope_of_Change__c = 'Xpto';
            accr.newForm.Is_change_location__c = false;
            accr.newForm.Is_change_legal_name__c = true;
            accr.newForm.Is_change_ownership_or_shareholding__c = false;
            pageRef = accr.save();

            accr.newForm.Scope_of_Change__c = 'Xpto';
            accr.newForm.Is_change_location__c = true;
            accr.newForm.Is_change_legal_name__c = false;
            accr.newForm.Is_change_ownership_or_shareholding__c = false;
            pageRef = accr.save();
        }

        Test.stopTest();        
    }
    
    */

    private static Account icc_testAccount(IATA_ISO_Country__c country) {


        Id rtIdBr = [ SELECT Id FROM RecordType 
        WHERE SobjectType = 'Account'
        AND DeveloperName = 'IATA_Agency'][0].Id; 


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
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);

        return child;
    }

    private static Contact icc_testContact(Account child) {
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;

        return con;
    }

    private static User icc_testUser(Contact con) {
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;

        return newUser;
    }

    private static User icc_testUser2(Contact con, String language) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + String.valueof(datetime.now());
        String conId15 = con.Id;
        conId15 = conId15.substring(0,15);
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
                                 Username = uniqueName+ string.valueof(Integer.valueOf(math.rint(math.random()*1000000))) + '@test' + orgId + '.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        con.OwnerId = newUser.Id;
        update con;

        return newUser;
    }

    /*
    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_17() {
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

            // First Test.
            accr.newForm.Validation_ERRORS__c = true;

            // Force validateCharactersInForm() evaluate to true
            accr.isNoticeOfChange = false;
            accr.sectorValue = 'Travel_Agent_X';
            accr.amsOfficeType = 'HO';
            accr.newForm.ISSP_AMS_where_incorporated__c = invalidISOsample;
            accr.amsOfficeType = 'Xpto';
            accr.newCase.Reason1__c = 'Xpto';
            accr.newForm.Notify_Change_Location__c = false;
            accr.newForm.Notify_Change_Legal_Details__c = false;
            accr.newForm.ISSP_AMS_Online_Agency_URL__c = null;
            accr.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = null;

            accr.highLightPageForErrors();

            // Second Test.
            accr.newForm.Validation_ERRORS__c = true;

            // Force validateCharactersInForm() evaluate to true
            accr.isNoticeOfChange = true;
            accr.isBankAccountChange = false;
            accr.amsOfficeType = 'Branch';
            accr.newForm.Branch_Office_Street_name_number__c = invalidISOsample;            

            accr.newForm.Wholly_owned_by_this_Head_Office__c = null;
            accr.newForm.Wholly_managed_by_this_Head_Office__c = null;
            accr.newForm.ISSP_AMS_VAT_Number_Input__c = null;

            accr.CountryCheckList.Registration_required__c = true;
            accr.newForm.ISSP_AMS_Trade_Reg_No__c = null;
            accr.newForm.ISSP_AMS_Date_Registration_granted__c = null;
            accr.CountryCheckList.License_required__c = true;
            accr.newForm.ISSP_AMS_License_No__c = null;
            accr.newForm.ISSP_AMS_Date_License_granted__c = null;
            accr.newForm.ISSP_AMS_Previous_default__c = null;

            accr.highLightPageForErrors();

            accr.amsOfficeType = 'HO';
            accr.newCase.Reason1__c = 'New HO';

            accr.highLightPageForErrors();

            accr.newForm.ISSP_AMS_Previous_default__c = 'YES';
            accr.newForm.ISSP_AMS_Prev_default_explanation__c = null;
            accr.newForm.ISSP_AMS_Premises_located_at_airport__c = null;
            accr.newForm.ISSP_AM_Means_Identified_Travel_Agency__c = null;
            accr.newForm.ISSP_AMS_Gross_Amnt_First_year__c = null;
            accr.newForm.ISSP_AMS_Gross_Amnt_Second_year__c = null;

            accr.highLightPageForErrors();

    
            accr.sectorValue = 'Cargo_Agent_X';
            accr.newForm.Agent_Type__c = 'IATA Cargo Agent';
            accr.amsOfficeType = 'HO';
            accr.newForm.ISSP_AMS_Legal_Status__c = null;
            accr.isTerminatedAgent = true;
            accr.newForm.Account_Name__c = null;
            accr.newForm.ISSP_AMS_Date_legal_establishment__c = null;
            accr.newForm.Is_there_any_relationship__c = 'Yes';
            accr.isocountry.EACP_Country__c = false;
            accr.newForm.Give_full_details__c = null;
            accr.newForm.ISSP_AMS_Is_Applicant_Parent__c = null;

            accr.highLightPageForErrors();

            accr.isocountry.EACP_Country__c = true;
            accr.newForm.ISSP_AMS_Number_of_Years_Traded__c = null;
            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = null;
            accr.newForm.ISSP_AMS_Business_Activities__c = null;

            accr.highLightPageForErrors();

            accr.newForm.ISSP_AMS_Is_Applicant_Parent__c = 'Yes';
            accr.isocountry.EACP_Country__c = false;
            accr.newForm.ISSP_AMS_State_Names_Addresses__c = null;
            accr.CountryCheckList.License_required__c = true;
            accr.newForm.ISSP_AMS_Type_of_License__c = null;
            accr.newForm.ISSP_AMS_Date_License_granted__c = null;

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            accr.newForm.ISSP_AMS_Date_of_incorporation__c = null;
            accr.newForm.ISSP_AMS_Nominee_Trustee__c = null;
                        accr.newForm.ISSP_AMS_For_whom_Nominee__c = null;

            accr.highLightPageForErrors();

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Association';
            accr.newForm.ISSP_AMS_Date_of_Association__c = null;

            accr.newForm.Does_your_firm_intend_to_request__c = null;

            accr.highLightPageForErrors();


            accr.newForm.Does_your_firm_intend_to_request__c = 'Yes';
            accr.newForm.List_the_airport_s_to_be_authorized__c = null;

            accr.newForm.Has_your_firm_ever_held_a_Cargo_Agency__c = null;

            accr.highLightPageForErrors();


            accr.newForm.Has_your_firm_ever_held_a_Cargo_Agency__c = 'Yes';
            accr.newForm.List_the_airport_s_to_be_authorized__c = null;
            accr.newForm.IATA_Agents_Numeric_Code__c = null;
            accr.newForm.Date_issued__c = null;
            accr.newForm.Name_under_which_it_was_issued__c = null;
            accr.newForm.Reason_for_cancellation__c = null;
            accr.newForm.Has_your_form_ever_held_CASS_Assoc_etc__c = null;

            accr.highLightPageForErrors();

            accr.newForm.Has_your_form_ever_held_CASS_Assoc_etc__c = 'Yes';
            accr.newForm.CASS_Assoc_Code__c = null;
            accr.newForm.CASS_Date_issued__c = null;
            accr.newForm.CASS_Name_under_which_it_was_issued__c = null;
            accr.newForm.CASS_Reason_for_cancellation__c = null;
            accr.newForm.Is_your_firm_an_approved_IATA_Passenger__c = null;

            accr.highLightPageForErrors();


            accr.newForm.Is_your_firm_an_approved_IATA_Passenger__c = 'Yes';
            accr.newForm.Agents_Numeric_Code_of_your_Head_Office__c = null;
            accr.newForm.Does_the_air_transportation_which_your__c = null;

            accr.highLightPageForErrors();


            accr.newForm.Does_the_air_transportation_which_your__c = 'Yes';
            accr.newForm.State_the_percentage_of_your_gross__c = null;
            accr.newForm.Does_your_firm_sell_air_cargo__c = null;

            accr.highLightPageForErrors();

            accr.newForm.Does_your_firm_sell_air_cargo__c = 'Yes';
            accr.newForm.What_percentage_of_your_sales__c = null;
            accr.newForm.Is_your_firm_a_General_Sales_Agent_GSA__c = 'Yes';
            accr.newForm.List_carriers__c = null;
            accr.newForm.Been_found_guilty_of_infringements__c = null;
            accr.newForm.Been_involved_in_a_bankruptcy__c = null;

            accr.highLightPageForErrors();

            accr.newForm.Been_involved_in_a_bankruptcy__c = null;
            accr.newForm.If_yes_are_you_fully_and_legally__c = null;
            accr.newForm.Been_a_sole_proprietor__c = null;
            accr.newForm.Been_director_or_had_a_financial__c = null;

            //accr.highLightPageForErrors();
        }

        Test.stopTest();        
    }


    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_18() {
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

            accr.newForm.Validation_ERRORS__c = true;

            // Force validateCharactersInForm() evaluate to true
            accr.isBankAccountChange = false;

            accr.isNoticeOfChange = false;
            accr.sectorValue = 'Travel_Agent_X';
            accr.amsOfficeType = 'HO';

            accr.newForm.ISSP_AMS_where_incorporated__c = null;
            accr.newCase.Reason1__c = 'New HO';
            accr.newForm.Notify_Change_Location__c = false;
            accr.newForm.Notify_Change_Legal_Details__c = false;
            accr.newForm.ISSP_AMS_Online_Agency_Application__c = 'Yes';
            accr.newForm.ISSP_AMS_Online_Agency_URL__c = null;
            accr.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = null;
            accr.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = 'Yes';

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            accr.newForm.ISSP_AMS_Entity_with_listed_shares__c = null;

            accr.highLightPageForErrors();

            accr.newForm.ISSP_AMS_Legal_Status__c = null;
            accr.highLightPageForErrors();

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';
            accr.highLightPageForErrors();


            accr.newCase.Reason1__c = 'New BR Abroad';
            accr.newForm.Account_Name__c = null;
            accr.newForm.ISSP_AMS_Online_Agency_Application__c = null;
            accr.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = null;

            accr.highLightPageForErrors();

            accr.newCase.Reason1__c = 'New HO';
            accr.newForm.ISSP_AMS_Entity_with_listed_shares__c = 'No';
            accr.newForm.Account_Name__c = 'Xpto';
            accr.newForm.ISSP_AMS_Legal_Status__c = 'Sole Proprietorship';

            //accr.highLightPageForErrors();
        }

        Test.stopTest();        
    }

    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_19() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newForm.Validation_ERRORS__c = true;

            // Force validateCharactersInForm() evaluate to true
            accr.isBankAccountChange = false;

            accr.isNoticeOfChange = false;
            accr.sectorValue = 'Travel_Agent_X';
            accr.amsOfficeType = 'HO';

            accr.newForm.ISSP_AMS_where_incorporated__c = null;
            accr.newForm.Notify_Change_Location__c = false;
            accr.newForm.Notify_Change_Legal_Details__c = false;
            accr.newForm.ISSP_AMS_Online_Agency_Application__c = 'Yes';
            accr.newForm.ISSP_AMS_Online_Agency_URL__c = null;
            accr.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = null;
            accr.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = 'Yes';

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';

            accr.newForm.Account_Name__c = null;
            accr.newForm.ISSP_AMS_Online_Agency_Application__c = null;
            accr.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = null;

            accr.newCase.Reason1__c = 'New HO';
            accr.newForm.ISSP_AMS_Entity_with_listed_shares__c = 'No';
            accr.newForm.Account_Name__c = 'Xpto';
            accr.newForm.ISSP_AMS_Legal_Status__c = 'Sole Proprietorship';

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Xpto';

            accr.highLightPageForErrors();

            accr.sector = 'Cargo Agent X';
            accr.amsOfficeType = 'Branch';
            accr.isNoticeOfChange = false;

            accr.newForm.Is_your_firm_handling_Dangerous_Goods__c = 'No';

            accr.newForm.Wholly_owned_by_this_Head_Office__c = null;
            accr.newForm.Wholly_managed_by_this_Head_Office__c = null;
            accr.newForm.ISSP_AMS_Previous_default__c = 'YES';
            accr.newForm.ISSP_AMS_Prev_default_explanation__c = null;

            accr.highLightPageForErrors();

            accr.amsOfficeType = 'HO';

            accr.highLightPageForErrors();

            accr.isocountry.Local_language_Agency_details_required__c = true;

            accr.highLightPageForErrors();


            accr.isocountry.Local_language_Agency_details_required__c = false;
            accr.sectorValue = 'Cargo_Agent_X';
            accr.newForm.Agent_Type__c = 'IATA Cargo Agent';
            accr.newForm.ISSP_AMS_Legal_Status__c = null;
            accr.isTerminatedAgent = true;
            accr.newForm.Account_Name__c = null;
            accr.newForm.ISSP_AMS_Date_legal_establishment__c = null;
            accr.newForm.Is_there_any_relationship__c = 'Yes';
            accr.newForm.Give_full_details__c = null;
            accr.newForm.ISSP_AMS_Is_Applicant_Parent__c = null;
            
            accr.highLightPageForErrors();

        }

        Test.stopTest();        
    }


    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_20() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newForm.Validation_ERRORS__c = true;

            // Force validateCharactersInForm() evaluate to true
            accr.isBankAccountChange = false;

            accr.isNoticeOfChange = false;
            accr.amsLocationType = null;
            accr.sectorValue = 'Travel_Agent_X';
            accr.amsOfficeType = 'HO';

            accr.newForm.ISSP_AMS_where_incorporated__c = null;
            accr.newForm.Notify_Change_Location__c = false;
            accr.newForm.Notify_Change_Legal_Details__c = false;
            accr.newForm.ISSP_AMS_Online_Agency_Application__c = 'Yes';
            accr.newForm.ISSP_AMS_Online_Agency_URL__c = null;
            accr.newForm.ISSP_AMS_Legal_Reg_Name_Address__c = null;
            accr.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = 'Yes';

            accr.newForm.ISSP_AMS_Legal_Status__c = 'Corporation';

            accr.newForm.Account_Name__c = null;
            accr.newForm.ISSP_AMS_Online_Agency_Application__c = null;
            accr.newForm.ISSP_AMS_IATA_Registered_Cargo_Agent__c = null;

            accr.newCase.Reason1__c = 'New HO';
            accr.newForm.ISSP_AMS_Entity_with_listed_shares__c = 'No';
            accr.newForm.Account_Name__c = 'Xpto';

            accr.saveAMSForm();

            accr.amsLocationType = 'Sales - Agent';
            accr.saveAMSForm();

            accr.amsLocationType = null;
            accr.sectorValue = 'Xpto';
            accr.saveAMSForm();

            accr.sectorValue = 'Travel_Agent_X';
            accr.newCase.Reason1__c = 'New BR / IP';

            accr.saveAMSForm();

            accr.sectorValue = 'Travel_Agent_X';
            accr.newCase.Reason1__c = 'New BR Abroad';

            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-IATA Cargo Agent';
            accr.newCase.Reason1__c = 'New HO';
            //accr.newForm.Agent_Type__c = 'IATA Cargo Agent';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-EACP Intermediary';
            accr.newCase.Reason1__c = 'New HO';
            //accr.newForm.Agent_Type__c = 'EACP Intermediary';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-EACP Intermediary';
            accr.newCase.Reason1__c = 'New BR / IP';
            //accr.newForm.Agent_Type__c = 'EACP Intermediary';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-IATA Cargo Agent';
            accr.newCase.Reason1__c = 'New BR / IP';
            //accr.newForm.Agent_Type__c = 'IATA Cargo Agent';
            accr.saveAMSForm();
            
            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-CASS Associate';
            accr.newCase.Reason1__c = 'New HO';
            //accr.newForm.Agent_Type__c = 'CASS Associate';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-CASS Associate';
            accr.newCase.Reason1__c = 'New BR / IP';
            //accr.newForm.Agent_Type__c = 'CASS Associate';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-Courier';
            accr.newCase.Reason1__c = 'New HO';
            //accr.newForm.Agent_Type__c = 'Courier';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-Courier';
            accr.newCase.Reason1__c = 'New BR / IP';
            //accr.newForm.Agent_Type__c = 'Courier';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-Import Agent';
            accr.newCase.Reason1__c = 'New HO';
            //accr.newForm.Agent_Type__c = 'Import Agent';
            accr.saveAMSForm();

            accr.sectorValue = 'Cargo_Agent_X';
            accr.amsLocationType = 'Cargo-Import Agent';
            accr.newCase.Reason1__c = 'New BR / IP';
            //accr.newForm.Agent_Type__c = 'Import Agent';
            accr.saveAMSForm();
        }

        Test.stopTest();        
    }


    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_21() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.con.Account.Sector__c = 'Invalid Sector';

            pageRef = accr.securityCheck();

            accr.con.Account.Sector__c = 'Travel Agent';

            accr.newCase.Status = 'Draft';
            accr.isNoticeOfChange = true;

            pageRef = accr.securityCheck();

            ApexPages.currentPage().getParameters().put('retURL', 'http://www.google.com');

            pageRef = accr.securityCheck();

            accr.isNoticeOfChange = false;
            accr.isEligableForChange = true;
            accr.isFinalStep = true;
            accr.newCase.Status = 'Invalid Status';

            pageRef = accr.securityCheck();
        }

        Test.stopTest();        
    }



    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_22() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newForm.Accept_terms_and_conditions__c = true;
            accr.isNoticeOfChange = true;
            accr.isBankAccountChange = false;
            accr.newCase.RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;
            accr.isocountry.Enable_Minor_Changes_from_Portal__c = true;

            accr.newForm.Is_this_Head_Office_becoming_a_Branch__c = 'No';
            accr.newForm.Is_this_Branch_becoming_a_Head_Office__c = 'No';
            accr.newForm.Will_such_change_affect_the_premises__c = 'No';
            accr.newForm.Effective_Date_Of_Change__c = System.today();
            accr.newForm.Will_such_change_affect_the_managers__c = 'No';
            accr.newForm.Have_any_having_authorization_to_act__c = 'No';
            accr.newForm.Will_the_change_of_ownership_cause__c = 'No';
            accr.newform.Confirm_Legal_Details_are_correct__c = true;
            accr.newform.Confirm_Location_Details_are_correct__c = true;
            accr.newform.Confirm_Ownership_Details_are_correct__c = true;
            accr.newForm.Branch_Office_Phone__c = '12345678';
            accr.newForm.Branch_Office_Phone_National__c = '12345678';
            accr.newForm.Branch_Office_Fax__c = '12345678';
            accr.newForm.Branch_Office_Fax_National__c = '12345678';
            accr.newForm.Branch_Office_Email__c = 'test@gmail.com';
            accr.isocountry.Prevent_Portal_Trade_Name_Change__c = false;
            accr.newForm.Trade_Name__c = 'Xpto';

            pageRef = accr.goToFinalStep();
        }

        Test.stopTest();        
    }




    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_23() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            ISSP_Ams_Login_Credentials__c credentials = new ISSP_Ams_Login_Credentials__c(
                Name = 'AmsDev1',
                User_Name__c = 'dummy',
                Password__c = 'dummy'
            );

            insert credentials;

            ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice ws = ISSP_AMS_Accreditation.getWSInstance();


            accr.isNoticeOfChange = true;
            accr.newCase.ContactId = accr.con.id;

            accr.sendConfirmationEmail(accr.newCase);

            accr.isNoticeOfChange = false;
            accr.newCase.BSPCountry__c = 'Xpto';
            accr.newCase.Region__c = 'ABCD';
            accr.sendConfirmationEmail(accr.newCase);
        }

        Test.stopTest();        
    }


    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_24() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newCase.ContactId = accr.con.id;

            accr.isNoticeOfChange = false;
            accr.newCase.BSPCountry__c = 'Xpto';
            accr.newCase.Region__c = 'ABCD';

            accr.amsLocationType = 'New HO - EACP Intermediary';
            pageRef = accr.save();

            accr.amsLocationType = 'New BR / IP - EACP Intermediary';
            pageRef = accr.save();

            accr.amsLocationType = 'New HO - IATA Cargo Agent';
            pageRef = accr.save();

            accr.amsLocationType = 'New BR / IP - IATA Cargo Agent';
            pageRef = accr.save();
        }

        Test.stopTest();        
    }



    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_25() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newCase.ContactId = accr.con.id;

            accr.isNoticeOfChange = false;
            accr.newCase.BSPCountry__c = 'Xpto';
            accr.newCase.Region__c = 'ABCD';

            accr.amsLocationType = 'New HO - CASS Associate';
            pageRef = accr.save();

            accr.amsLocationType = 'New BR / IP - CASS Associate';
            pageRef = accr.save();

            accr.amsLocationType = 'New HO - Import Agent';
            pageRef = accr.save();

            accr.amsLocationType = 'New BR / IP - Import Agent';
            pageRef = accr.save();
        }

        Test.stopTest();        
    }




    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_26() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newCase.ContactId = accr.con.id;

            accr.isNoticeOfChange = false;
            accr.newCase.BSPCountry__c = 'Xpto';
            accr.newCase.Region__c = 'ABCD';

            accr.amsLocationType = 'New HO - Courier';
            pageRef = accr.save();

            accr.amsLocationType = 'New BR / IP - Courier';
            pageRef = accr.save();

            accr.amsLocationType = 'New HO - IATA Passenger Sales Agent';
            pageRef = accr.save();
        }

        Test.stopTest();        
    }


    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_27() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);

            accr.newCase.ContactId = accr.con.id;

            accr.isNoticeOfChange = false;
            accr.newCase.BSPCountry__c = 'Xpto';
            accr.newCase.Region__c = 'ABCD';

            accr.amsLocationType = 'New BR Abroad - IATA Passenger Sales Agent';
            pageRef = accr.save();

            accr.amsLocationType = 'New XPTO';
            pageRef = accr.save();
        }

        Test.stopTest();        
    }





    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_28() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            String lang = 'en_US';
            List<ISSP_AMS_Contextual_Help__c> contextualHelpList = new List<ISSP_AMS_Contextual_Help__c> {
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'CURRENCY',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'MIN_PAIDUP_CAPITAL',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'REGISTERED_CAPITAL',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'PAIDUP_CAPITAL',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'TAX_NUMBER',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'AUTHORISED_SIG',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'FIN_CONTACT',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'PORTAL_ADMIN',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                ),
                new ISSP_AMS_Contextual_Help__c(
                    Name = 'GROSS_SALES',
                    ISSP_AMS_HelpText_en_US__c = 'XPTO'
                )
            };

            insert contextualHelpList;

            accr = icc_initialize(country, childAccount);

            accr.setContextualHelp(lang);

            lang = 'fr';

            accr.displayLanguage = lang;

            accr.setContextualHelp(lang);

            str = accr.getAmsAllLangCountryLabel(country, 'en_US');
            str = accr.getAmsAllLangCountryLabel(country, 'es');
            str = accr.getAmsAllLangCountryLabel(country, 'fr');
            str = accr.getAmsAllLangCountryLabel(country, 'it');
            str = accr.getAmsAllLangCountryLabel(country, 'pt_BR');
            str = accr.getAmsAllLangCountryLabel(country, 'ko');
            str = accr.getAmsAllLangCountryLabel(country, 'zh_CN');
            str = accr.getAmsAllLangCountryLabel(country, 'ja');
            str = accr.getAmsAllLangCountryLabel(country, 'xpto');
        }

        Test.stopTest();        
    }






    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_29() {
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


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;

        Test.startTest();

        insert country;
        insert country2;

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        childAccount = icc_testAccount(country);
        testContact = icc_testContact(childAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, childAccount);
            
            accr.agentsector = 'Cargo Agent';
            accr.iatacode = 'X';
            accr.fetchAgentDetails();
            
            accr.agentsector = 'Travel Agent';
            accr.iatacode = 'X';
            accr.fetchAgentDetails();
            
            accr.agentsector = 'Cargo Agent';
            accr.amsOfficeType = 'Branch';
            accr.iatacode = 'XXXXXXXX';
            accr.fetchAgentDetails();
            
            accr.agentsector = 'Both';
            accr.amsOfficeType = 'Branch';
            accr.iatacode = 'XXXXXXXX';
            accr.fetchAgentDetails();
            
            accr.agentsector = 'Xpto';
            accr.amsOfficeType = 'Branch';
            accr.accountType = 'IATA Passenger Sales Agent';
            accr.iatacode = 'XXXXXXXX';
            accr.fetchAgentDetails();

            accr.iatacode = null;
            accr.fetchAgentDetails(); // doesn't count as Agency Lookup because of iatacode being null

            accr.agentsector = 'Xpto';
            accr.amsOfficeType = 'Branch';
            accr.accountType = 'Xpto';
            accr.iatacode = 'XXXXXXXX';
            accr.fetchAgentDetails();

            accr.fetchAgentDetails();

            accr.prevAgentHistory = '1';
            accr.isAddCompanyModal = true;
            accr.fetchAgentDetails();
            
            accr.agentsector = 'Both';
            accr.iatacode = 'XXXXXXXX';

            Account agentAccount0 = new Account(
                Name = 'Xpto',
                BillingStreet = 'Xpto',
                BillingCity = 'Xpto',
                BillingState = 'Xpto',
                BillingPostalCode = 'Xpto',
                BillingCountry = 'Xpto',
                IATACode__c = accr.iatacode,
                Sector__c = 'Travel Agent',
                RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Agency').RecordTypeId
            );

            insert agentAccount0;

            accr.fetchAgentDetails();



            accr.prevAgentHistory = '1';
            accr.isAddCompanyModal = true;
            accr.fetchAgentDetails();

            accr.accountType = 'IATA Cargo Agent';
            accr.agentsector = 'Cargo Agent';
            accr.amsOfficeType = 'Branch';
            accr.iatacode = 'XXXXXXXX';

            Account agentAccount1 = new Account(
                Name = 'Xpto',
                BillingStreet = 'Xpto',
                BillingCity = 'Xpto',
                BillingState = 'Xpto',
                BillingPostalCode = 'Xpto',
                BillingCountry = 'Xpto',
                IATACode__c = accr.iatacode,
                Sector__c = accr.agentsector,
                Location_Type__c = 'BR',
                RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Agency').RecordTypeId
            );

            insert agentAccount1;

            accr.fetchAgentDetails();

            accr.prevAgentHistory = '1';
            accr.isAddCompanyModal = true;
            accr.fetchAgentDetails();

            accr.accountType = 'CASS Associates';
            accr.agentsector = 'Cargo Agent';
            accr.amsOfficeType = 'Branch';
            accr.iatacode = 'XXXXXXXX';

            Account agentAccount2 = new Account(
                Name = 'Xpto',
                BillingStreet = 'Xpto',
                BillingCity = 'Xpto',
                BillingState = 'Xpto',
                BillingPostalCode = 'Xpto',
                BillingCountry = 'Xpto',
                IATACode__c = accr.iatacode,
                Sector__c = accr.agentsector,
                Location_Type__c = 'BR',
                RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Agency').RecordTypeId
            );

            insert agentAccount2;

            accr.fetchAgentDetails();


            accr.prevAgentHistory = '1';
            accr.isAddCompanyModal = true;
            accr.fetchAgentDetails();

            accr.agentsector = 'Xpto';
            accr.iatacode = 'XXXXXXXX';

            Account agentAccount3 = new Account(
                Name = 'Xpto',
                BillingStreet = 'Xpto',
                BillingCity = 'Xpto',
                BillingState = 'Xpto',
                BillingPostalCode = 'Xpto',
                BillingCountry = 'Xpto',
                IATACode__c = accr.iatacode,
                Sector__c = accr.agentsector,
                RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Agency').RecordTypeId
            );

            insert agentAccount3;

            accr.fetchAgentDetails();


            accr.prevAgentHistory = '2';

            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails();
            accr.fetchAgentDetails(); // 19
            accr.fetchAgentDetails(); // 20
            accr.fetchAgentDetails(); // 21
        }

        Test.stopTest();        
    }







    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_30() {
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
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', EU_Country__c = true);
        
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;


        insert country;
        insert country2;

          Id rtIdBr = [ SELECT Id FROM RecordType 
            WHERE SobjectType = 'Account'
            AND DeveloperName = 'IATA_Agency'][0].Id; 

            Account topAccount = ISSP_ObjectFactory.createNewAccount();

            topAccount.BillingCity = 'test';
            topAccount.Name = 'test';
            topAccount.sector__c = 'Travel Agent';
            topAccount.Location_Type__c = 'HO';
            topAccount.RecordTypeId = rtIdBr ;
            topAccount.IATACode__c = '100';
            topAccount.Status__c = 'Terminated';
            topAccount.IATA_ISO_Country__c = country.Id;

            insert topAccount;

        Test.startTest();

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        testContact = icc_testContact(topAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, topAccount);
            
            accr.legalStatusAfterChange = 'association';
            accr.setPageLegalStatusAfterChangeLabels();

            accr.legalStatusAfterChange = 'co-operative';
            accr.setPageLegalStatusAfterChangeLabels();

            accr.vatNumber = invalidISOsample;
            accr.validateVATNumber();

            List<Case> insertCaseList = new List<Case> {
                new Case(
                    IFAP_Country_ISO__c = 'tq',
                    CaseArea__c = 'Accreditation Process',
                    Status = 'New',
                    AccountId = topAccount.Id,
                    Reason1__c = 'New HO',
                    RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('SAAM').RecordTypeId
                ),
                new Case(
                    IFAP_Country_ISO__c = 'tq',
                    CaseArea__c = 'Accreditation Process',
                    Status = 'Draft',
                    AccountId = topAccount.Id,
                    Reason1__c = 'New HO',
                    RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('SAAM').RecordTypeId
                )
            };

            insert insertCaseList;

            bol = accr.openHQCaseExists;
            bol = accr.draftHQCaseExists;

            accr.newCase = insertCaseList[0];
            accr.newCase.Case_Language__c = '';
            
            str = accr.pageLanguage;

            accr.newCase = null;

            str = accr.pageLanguage;

            accr.sector = 'Travel Agent';
            accr.con.Account.Category__c = 'Non-IATA Travel Agent';

            accr.checkEligibilityForAChange();
        }

        Test.stopTest();        
    }







    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_31() {
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
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', EU_Country__c = true, Branches_abroad_not_allowed__c = true);
        
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');


        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;


        insert country;
        insert country2;

          Id rtIdBr = [ SELECT Id FROM RecordType 
            WHERE SobjectType = 'Account'
            AND DeveloperName = 'IATA_Agency'][0].Id; 

            Account topAccount = ISSP_ObjectFactory.createNewAccount();

            topAccount.BillingCity = 'test';
            topAccount.Name = 'test';
            topAccount.sector__c = 'Travel Agent';
            topAccount.Location_Type__c = 'HO';
            topAccount.RecordTypeId = rtIdBr ;
            topAccount.IATACode__c = '100';
            topAccount.Status__c = 'Terminated';
            topAccount.IATA_ISO_Country__c = country.Id;

            insert topAccount;

        Test.startTest();

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        testContact = icc_testContact(topAccount);
        testUser = icc_testUser(testContact);

        System.runAs(testUser) {
            accr = icc_initialize(country, topAccount);

            accr.getCountriesMap();

            // --

            List<AMS_Facility__c> facilityList = new List<AMS_Facility__c> {
                new AMS_Facility__c (
                    AMS_Online_Accreditation__c = accr.newForm.Id,
                    Is_the_office_warehouse_leased__c = 'Yes',
                    RecordTypeId = Schema.SObjectType.AMS_Facility__c.RecordTypeInfosByName.get('Office').RecordTypeId
                ),
                new AMS_Facility__c (
                    AMS_Online_Accreditation__c = accr.newForm.Id,
                    Is_the_office_warehouse_leased__c = 'Yes',
                    Is_the_warehouse_sub_contracted__c = 'Yes',
                    RecordTypeId = Schema.SObjectType.AMS_Facility__c.RecordTypeInfosByName.get('Warehouse').RecordTypeId
                )
            };

            insert facilityList;

            accr.sectorValue = 'Cargo_Agent_X';
            accr.isNoticeOfChange = false;
            accr.applyLanguage = 'fr';

            accr.goToFinalStep();
        }

        Test.stopTest();        
    }







    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_32() {
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
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', EU_Country__c = true, Branches_abroad_not_allowed__c = true);
        
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');

        IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(name = 'testCN', ISO_Code__c = 'CN', Case_BSP_Country__c = 'testCN', CASS_Import__c = 'Yes');

        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;


        insert country;
        insert country2;
        insert country3;

          Id rtIdBr = [ SELECT Id FROM RecordType 
            WHERE SobjectType = 'Account'
            AND DeveloperName = 'IATA_Agency'][0].Id; 

            Account topAccount = ISSP_ObjectFactory.createNewAccount();

            topAccount.BillingCity = 'test';
            topAccount.Name = 'test';
            topAccount.sector__c = 'Travel Agent';
            topAccount.Location_Type__c = 'HO';
            topAccount.RecordTypeId = rtIdBr ;
            topAccount.IATACode__c = '100';
            topAccount.Status__c = 'Terminated';
            topAccount.IATA_ISO_Country__c = country.Id;
            topAccount.Company_Type__c = 'A';

            insert topAccount;

            childAccount = ISSP_ObjectFactory.createNewAccount();

            childAccount.BillingCity = 'test';
            childAccount.Name = 'test';
            childAccount.sector__c = 'Travel Agent';
            childAccount.Location_Type__c = 'HO';
            childAccount.RecordTypeId = rtIdBr ;
            childAccount.IATACode__c = '100';
            childAccount.Status__c = 'Terminated';
            childAccount.IATA_ISO_Country__c = country.Id;
            childAccount.Company_Type__c = 'A';
            childAccount.Top_Parent__c = topAccount.Id;

            insert childAccount;

            Account newAccount = ISSP_ObjectFactory.createNewAccount();

            newAccount.BillingCity = 'test';
            newAccount.Name = 'test';
            newAccount.sector__c = 'Travel Agent';
            newAccount.Location_Type__c = 'HO';
            newAccount.RecordTypeId = rtIdBr ;
            newAccount.IATACode__c = '100';
            newAccount.Status__c = 'Approved';
            newAccount.IATA_ISO_Country__c = country.Id;
            newAccount.Company_Type__c = 'A';
            newAccount.Top_Parent__c = topAccount.Id;

            insert newAccount;

        Test.startTest();

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        testContact = icc_testContact(childAccount);

        testUser = icc_testUser2(testContact, 'de');

        

            Case newCase = new Case(
                IFAP_Country_ISO__c = 'tq',
                CaseArea__c = 'Accreditation Process',
                Status = 'New',
                AccountId = topAccount.Id,
                Reason1__c = 'New HO',
                RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('SAAM').RecordTypeId
            );

            insert newCase;

            AMS_Pax_Accreditation_Form__c form = new AMS_Pax_Accreditation_Form__c(
                SAAM_Case__c = newCase.Id,
                ISSP_AMS_Legal_Status__c = 'Xpto'
            );

            insert form;
            
          System.runAs(testUser) {
            ApexPages.currentPage().getParameters().put('caseId', newCase.Id);
  
          
            accr = icc_initialize(country, childAccount);

            accr.sector = 'Xpto';

            bol = accr.getIsGSARequired();

            accr.con.Account.Top_Parent__c = accr.con.Account.Id;
            accr.newForm.Operation_Type__c = 'Xpto';
            accr.newForm.RecordTypeId = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.RecordTypeInfosByName.get('Change of Bank Account Details').RecordTypeId;
            accr.newCase.Reason1__c = 'Xpto';

            ISSP_AddAttachment att = new ISSP_AddAttachment();
            att.tmpCase = accr.newCase;
            
            ISSP_AMS_Accreditation accr2 = new ISSP_AMS_Accreditation(att);

            List<SelectOption> branchAccounts = accr.getBranchAccounts();
            
            accr.sectorValue = 'Travel_Agent_X';
            accr.isHOAccredited = true;
            accr.con.Account.Category__c = 'IATA Passenger Sales Agent';

            List<SelectOption> officeTypes = accr.getOfficeTypes();

            ApexPages.currentPage().getParameters().put('retURL', 'xpto');

            accr.cancel();

            accr.amsLocationType = null;
            accr.isNoticeOfChange = false;

            accr.save();

            accr.amsLocationType = 'Xpto';
            accr.newCase.Status = 'Open - EDMC';
            accr.con.Account.Category__c = 'IATA Cargo Agent';
            accr.isNoticeOfChange = false;

            accr.save();
        }

        Test.stopTest();        
    }








    @isTest
    static void ISSP_AMS_Accreditation_Test_ICC_33() {
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
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test', EU_Country__c = true, Branches_abroad_not_allowed__c = true);
        
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');

        IATA_ISO_Country__c country3 = new IATA_ISO_Country__c(name = 'testCN', ISO_Code__c = 'CN', Case_BSP_Country__c = 'testCN', CASS_Import__c = 'Yes');

        AMS_Accreditation_Country_CheckList__c countryCheckList;

        AMS_Accreditation_Country_CheckList__c countryCheckList2;


        insert country;
        insert country2;
        insert country3;

          Id rtIdBr = [ SELECT Id FROM RecordType 
            WHERE SobjectType = 'Account'
            AND DeveloperName = 'IATA_Agency'][0].Id; 

            Account topAccount = ISSP_ObjectFactory.createNewAccount();

            topAccount.BillingCity = 'test';
            topAccount.Name = 'test';
            topAccount.sector__c = 'Travel Agent';
            topAccount.Location_Type__c = 'HO';
            topAccount.RecordTypeId = rtIdBr ;
            topAccount.IATACode__c = '100';
            topAccount.Status__c = 'Terminated';
            topAccount.IATA_ISO_Country__c = country.Id;
            topAccount.Company_Type__c = 'A';

            insert topAccount;

            childAccount = ISSP_ObjectFactory.createNewAccount();

            childAccount.BillingCity = 'test';
            childAccount.Name = 'test';
            childAccount.sector__c = 'Travel Agent';
            childAccount.Location_Type__c = 'HO';
            childAccount.RecordTypeId = rtIdBr ;
            childAccount.IATACode__c = '100';
            childAccount.Status__c = 'Terminated';
            childAccount.IATA_ISO_Country__c = country.Id;
            childAccount.Company_Type__c = 'A';
            childAccount.Top_Parent__c = topAccount.Id;

            insert childAccount;

            Account newAccount = ISSP_ObjectFactory.createNewAccount();

            newAccount.BillingCity = 'test';
            newAccount.Name = 'test';
            newAccount.sector__c = 'Travel Agent';
            newAccount.Location_Type__c = 'HO';
            newAccount.RecordTypeId = rtIdBr ;
            newAccount.IATACode__c = '100';
            newAccount.Status__c = 'Approved';
            newAccount.IATA_ISO_Country__c = country.Id;
            newAccount.Company_Type__c = 'A';
            newAccount.Top_Parent__c = topAccount.Id;

            insert newAccount;

        Test.startTest();

        countryCheckList = new AMS_Accreditation_Country_CheckList__c(
            License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country.Id,
            Operation__c = 'Cargo Agent X'
        );

        countryCheckList2 = new AMS_Accreditation_Country_CheckList__c(
           License_required__c = true,
            Registration_required__c = true,
            Statement_of_International_Sales__c = true,
            Statement_of_International_Sales_Branch__c = true,
            IATA_ISO_Country__c = country2.Id,
            Operation__c = 'Cargo Agent X'
        );

        insert countryCheckList;
        insert countryCheckList2;

        testContact = icc_testContact(childAccount);

        testUser = icc_testUser2(testContact, 'de');

        

            Case newCase = new Case(
                IFAP_Country_ISO__c = 'tq',
                CaseArea__c = 'Accreditation Process',
                Status = 'New',
                AccountId = topAccount.Id,
                Reason1__c = 'New HO',
                RecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('SAAM').RecordTypeId
            );

            insert newCase;

            AMS_Pax_Accreditation_Form__c form = new AMS_Pax_Accreditation_Form__c(
                SAAM_Case__c = newCase.Id,
                ISSP_AMS_Legal_Status__c = 'Xpto'
            );

            insert form;
          System.runAs(testUser) {
            ApexPages.currentPage().getParameters().put('caseId', newCase.Id);
  
          
            accr = icc_initialize(country, childAccount);

            accr.amsLocationType = 'Xpto';
            accr.newCase.Status = 'Open - EDMC';
            accr.con.Account.Category__c = 'IATA Passenger Sales Agent';
            accr.isNoticeOfChange = false;

            accr.newCase.IFAP_Country_ISO__c = 'CN';
            accr.sectorValue = 'Travel_Agent_X';
            accr.newCase.Reason1__c = 'New HO';
            
            accr.save();

            accr.amsLocationType = 'Xpto';
            accr.newCase.Status = 'Open - EDMC';
            accr.con.Account.Category__c = 'Domestic Agent';
            accr.isNoticeOfChange = false;

            accr.newCase.IFAP_Country_ISO__c = 'CN';
            accr.sectorValue = 'Travel_Agent_X';
            accr.newCase.Reason1__c = 'XXX';
            
            accr.save();

            accr.amsLocationType = 'Xpto';
            accr.newCase.Status = 'Open - EDMC';
            accr.con.Account.Category__c = 'Xpto';
            accr.isNoticeOfChange = false;

            accr.newCase.IFAP_Country_ISO__c = 'CN';
            accr.sectorValue = 'Travel_Agent_X';
            accr.newCase.Reason1__c = 'XXX';
            
            accr.save();
        }

        Test.stopTest();        
    }

        */



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
            
        ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );
        ISSP_AMS_Accreditation ctrl = new ISSP_AMS_Accreditation();
        ctrl.newCase = testCase;
        ctrl.isTestCompliant();
        return ctrl;
    }
    
}
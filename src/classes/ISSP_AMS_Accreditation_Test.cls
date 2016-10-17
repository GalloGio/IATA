@isTest
private class ISSP_AMS_Accreditation_Test 
{
    @testSetup static void customSettingSetup() {
        insert new ISSP_CS__c(Name = 'ISSP AMS ALLOWED AGENCY URL',Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)([.])(([a-zA-Z]{3})|([a-zA-Z]{2}))');
    }

    @isTest static void ISSP_AMS_Accreditation_Test_1() 
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = true;
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = true;
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
        parent.sector__c = 'airline';
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
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'BR';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'BR';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'BR';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
            ctrl.convertAMSContacts();
            ctrl.editContactId = newContact.Id;
            ctrl.deleteTrainedStaff();
            ctrl.cancelAccountUpdate();
            ctrl.redirectToPDF();
            ctrl.facilitiesId = null;
            ctrl.redirectToFacilitiesPage();

            ctrl.contactType = 'Trained Staff';
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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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

            ctrl.newForm.ISSP_AMS_where_incorporated__c='testΩx';
            ctrl.newForm.ISSP_AMS_Principal_business_Org__c='testΩx';
            ctrl.hqAccount.BillingState='testΩx';
            ctrl.newContact.Job_title__c ='testΩx';
            ctrl.newContact.AddressStreet__c='testΩx';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c='testΩx';
            ctrl.newContact.AddressCity__c='testΩx';
            ctrl.newContact.First_name__c='testΩx';
            ctrl.newContact.Last_name__c='testΩx';
            ctrl.hqAccount.BillingStreet='testΩx';
            ctrl.hqAccount.BillingCity='testΩx';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c='testΩx';
            ctrl.newForm.ISSP_AMS_Legal_Reg_Name_Address__c='testΩx';
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

            ctrl.hqAccount.Website = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCountry = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingPostalCode = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCity = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingStreet = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.TradeName__c = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.Name = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.newContact.Name = 'Σ';
            ctrl.validateCharactersInCompanyWindow();
            ctrl.newContact.Registration_number__c = 'Σ';
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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
		parent.sector__c = 'airline';
		parent.Location_Type__c = 'HO';
		parent.RecordTypeId = rtIdBr ;
		parent.IATACode__c = '100';
		 
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
		child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = true;
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
            ISSP_AMS_Accreditation.callToMinorChangesWS(WSInstance, parent.Id, accChanges_List);

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
        parent.sector__c = 'airline';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
         
        insert parent;
        System.debug('parent Id: ' + parent.Id);

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'airline';
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
            testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
            testCase.BounceEmailCounter__c = 0.0;
            testCase.Case_Language__c = 'English';
            testCase.Subject = 'Test 006';
            testCase.Reopened_case__c = 0.0;
            testCase.Continous_Feed_SAF__c = false;
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

            ctrl.newForm.ISSP_AMS_where_incorporated__c='testΩx';
            ctrl.newForm.ISSP_AMS_Principal_business_Org__c='testΩx';
            ctrl.hqAccount.BillingState='testΩx';
            ctrl.newContact.Job_title__c ='testΩx';
            ctrl.newContact.AddressStreet__c='testΩx';
            ctrl.newForm.ISSP_AM_Means_Identified_Travel_Agency__c='testΩx';
            ctrl.newContact.AddressCity__c='testΩx';
            ctrl.newContact.First_name__c='testΩx';
            ctrl.newContact.Last_name__c='testΩx';
            ctrl.hqAccount.BillingStreet='testΩx';
            ctrl.hqAccount.BillingCity='testΩx';
            ctrl.newForm.ISSP_AMS_Online_Agency_URL__c='testΩx';
            ctrl.newForm.ISSP_AMS_Legal_Reg_Name_Address__c='testΩx';
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

            ctrl.hqAccount.Website = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCountry = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingPostalCode = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingCity = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.BillingStreet = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.TradeName__c = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.hqAccount.Name = 'Σ';
            ctrl.validateCharactersInAgencyWindow();
            ctrl.newContact.Name = 'Σ';
            ctrl.validateCharactersInCompanyWindow();
            ctrl.newContact.Registration_number__c = 'Σ';
            ctrl.validateCharactersInCompanyWindow();
        }
    }

}
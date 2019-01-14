@isTest
private class ISSP_ANG_VoluntaryRelinquishment_Test {

	@isTest static void testI(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'testa';
	        parent.sector__c = 'Travel Agent';
	        parent.Location_Type__c = 'BR';
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
	        child.IATACode__c = '101';   
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);        
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

		Test.startTest();
		System.runAs(newUser){

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'English';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0; 
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';
	            testCase.Account_Concerned__c = child.Id;
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
	            newForm.Scope_of_Change__c = 'HO - All Branches';
	            newForm.Accept_terms_and_conditions__c = true;
	            newForm.Effective_Date_Of_Change__c = System.today() -1;
            insert newForm ;

			ISSP_ANG_VoluntaryRelinquishment vr = new ISSP_ANG_VoluntaryRelinquishment();

			ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );			
			
			vr.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			vr.agencyCodesConcerned = vr.getAgencyCodesConcerned();
			vr.getRelatedAccount();			
			vr.save();
			newForm.Effective_Date_Of_Change__c = System.today();
			vr.save();
			vr.submitForm();
		}
	}

	@isTest static void testII(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'test';
	        parent.sector__c = 'Travel Agent';
	        parent.Location_Type__c = 'BR';
	        parent.RecordTypeId = rtIdBr ;
	        parent.IATACode__c = '100';
	       	parent.IATA_ISO_Country__c = country.Id;
	       	parent.ANG_Accreditation_Model__c = 'Cash';
	       	parent.Location_Type__c = 'HO';
        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);        
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        //update parent;

		Test.startTest();
		System.runAs(newUser){		

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'English';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0; 
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';	            
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
	            newForm.Scope_of_Change__c = 'HO Only';
	            newForm.Accept_terms_and_conditions__c = true;
	            newForm.Effective_Date_Of_Change__c = System.today() -1;
	            newForm.Agency_Codes_Concerned__c = '100';
            insert newForm ;

            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_VoluntaryRelinquishment')); 
			System.currentPageReference().getParameters().put('caseId', testCase.Id);
			System.currentPageReference().getParameters().put('step', '1');

			ISSP_ANG_VoluntaryRelinquishment vr = new ISSP_ANG_VoluntaryRelinquishment();
			vr.getRelatedAccount();			
			vr.save();
			newForm.Effective_Date_Of_Change__c = System.today();
			vr.save();				
			vr.submitForm();	
		}
	}

	@isTest static void testIII(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		
        Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'test';
	        parent.sector__c = 'Travel Agent';
	        parent.Location_Type__c = 'BR';
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
	        child.IATACode__c = '101';   
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);        
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

		Test.startTest();
		System.runAs(newUser){

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'English';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0; 
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';
	            testCase.Account_Concerned__c = child.Id;
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
	            newForm.Scope_of_Change__c = 'Selected Branches Only';
	            
	            newForm.Effective_Date_Of_Change__c = System.today() -1;
	            newForm.Agency_Codes_Concerned__c = '101';
            insert newForm ;

			ISSP_ANG_VoluntaryRelinquishment vr = new ISSP_ANG_VoluntaryRelinquishment();

			Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_VoluntaryRelinquishment')); 
			System.currentPageReference().getParameters().put('caseId', testCase.Id); 			
			System.currentPageReference().getParameters().put('step', '1');			
			
			vr.fetchCase(testCase.Id);
			vr.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			vr.agencyCodesConcerned = vr.getAgencyCodesConcerned();
			vr.getRelatedAccount();			
			newForm.Effective_Date_Of_Change__c = System.today()-1;
			vr.save();
			newForm.Effective_Date_Of_Change__c = System.today();
			vr.cancel();
			vr.save();
			newForm.Accept_terms_and_conditions__c = true;
			vr.save();
			
			vr.goToStep2();
			vr.submitForm();
		}
	}

	@isTest static void testIV() {
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'test';
	        parent.sector__c = 'Travel Agent';
	        parent.Location_Type__c = 'BR';
	        parent.RecordTypeId = rtIdBr ;
	        parent.IATACode__c = '100';
	       	parent.IATA_ISO_Country__c = country.Id;
	       	parent.ANG_Accreditation_Model__c = 'Cash';
	       	parent.Location_Type__c = 'HO';
        insert parent;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);        
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        //update parent;

		Test.startTest();
		System.runAs(newUser){		

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'English';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0; 
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';	            
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
	            newForm.Scope_of_Change__c = 'HO - All Branches';
	            newForm.Accept_terms_and_conditions__c = true;
	            newForm.Effective_Date_Of_Change__c = System.today() -1;
	            newForm.Agency_Codes_Concerned__c = '100';
            insert newForm ;

            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_VoluntaryRelinquishment')); 
			System.currentPageReference().getParameters().put('caseId', testCase.Id);
			System.currentPageReference().getParameters().put('step', '1');

			ISSP_ANG_VoluntaryRelinquishment vr = new ISSP_ANG_VoluntaryRelinquishment();
			vr.getRelatedAccount();			
			vr.save();
			newForm.Effective_Date_Of_Change__c = System.today();
			vr.save();				
			vr.submitForm();	
			vr.securityCheck();
		}
	}

	@isTest static void testV() {
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'test';
	        parent.sector__c = 'Travel Agent';
	        parent.Location_Type__c = 'BR';
	        parent.RecordTypeId = rtIdBr ;
	        parent.IATACode__c = '100';
	       	parent.IATA_ISO_Country__c = country.Id;
	       	parent.ANG_Accreditation_Model__c = 'Cash';
	       	parent.Location_Type__c = 'HO';
        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
	        child.BillingCity = 'test2';
	        child.Name = 'test2';
	        child.Site = 'headSite';
	        child.sector__c = 'Travel Agent';
	        child.Top_Parent__c = parent.Id;
	        child.IATA_ISO_Country__c = country.Id;
	        child.RecordTypeId = rtIdBr ;
	        child.IATACode__c = '101';   
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= parent.Id;
        con.Email = 'Test@test11.com';
        con.Authorized_Signatory__c = true;
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);        
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        //update parent;

		Test.startTest();
		System.runAs(newUser){		

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'English';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0; 
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';	            
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
	            newForm.Scope_of_Change__c = 'Selected Branches Only';
	            newForm.Accept_terms_and_conditions__c = true;
	            newForm.Effective_Date_Of_Change__c = System.today();
	            newForm.Agency_Codes_Concerned__c = '100';
            insert newForm ;

            Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_VoluntaryRelinquishment')); 
			System.currentPageReference().getParameters().put('caseId', testCase.Id);
			System.currentPageReference().getParameters().put('step', '1');

			ISSP_ANG_VoluntaryRelinquishment vr = new ISSP_ANG_VoluntaryRelinquishment();

			vr.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			
			vr.getRelatedAccount();			
			vr.save();
			newForm.Effective_Date_Of_Change__c = System.today();
			vr.save();
			vr.agencyCodesConcerned = new List<SelectOption>();
			vr.save();
			vr.submitForm();	
		}
	}

	@isTest static void test_securityCheck(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

		Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account parent = ISSP_ObjectFactory.createNewAccount();
	        parent.BillingCity = 'test';
	        parent.Name = 'test';
	        parent.sector__c = 'Travel Agent';
	        parent.Location_Type__c = 'BR';
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
	        child.IATACode__c = '101';   
        insert child;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);        
        con.OwnerId = newUser.Id;
        update con;

        parent.OwnerId = newUser.Id;
        update parent;

		Test.startTest();
		System.runAs(newUser){

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'English';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0; 
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Open';
	            testCase.Region__c = 'Africa & Middle East';
	            testCase.Account_Concerned__c = child.Id;
            insert testCase;

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
	            newForm.Scope_of_Change__c = 'Selected Branches Only';
	            
	            newForm.Effective_Date_Of_Change__c = System.today() -1;
	            newForm.Agency_Codes_Concerned__c = '101';
            insert newForm ;

			ISSP_ANG_VoluntaryRelinquishment vr = new ISSP_ANG_VoluntaryRelinquishment();

			Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_VoluntaryRelinquishment')); 
			System.currentPageReference().getParameters().put('caseId', testCase.Id); 			
			System.currentPageReference().getParameters().put('step', '1');			
			
			vr.fetchCase(testCase.Id);

			vr.securityCheck();
		}
	}		
	
}
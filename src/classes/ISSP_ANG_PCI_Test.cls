@isTest
private class ISSP_ANG_PCI_Test {

	
	@isTest static void CreateData_I(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

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
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        ISSP_AMS_Accreditation_Acc_Req.File_Identifier2__c = 'PCI_COMPLIANCE';
        ISSP_AMS_Accreditation_Acc_Req.File_to_Upload__c = 'Mandatory';
        insert ISSP_AMS_Accreditation_Acc_Req;

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
	            testCase.Account_Concerned__c = null;
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
            insert newForm ;

			ISSP_ANG_PCI pci = new ISSP_ANG_PCI();

			ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );			
			
			pci.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			pci.agencyCodesConcerned = pci.getAgencyCodesConcerned();
			pci.getRelatedAccount();			
			pci.save();
			pci.fetchCase(testCase.Id);			
			pci.goToStep1();
			pci.goToStep2();
			pci.cancel();
			pci.goToStep3();
			pci.submitForm();
			pci.securityCheck();
		}
	}

	@isTest static void CreateData_II(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

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
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        ISSP_AMS_Accreditation_Acc_Req.File_Identifier2__c = 'PCI_COMPLIANCE';        
        insert ISSP_AMS_Accreditation_Acc_Req;

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
	            testCase.Account_Concerned__c = null;
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
            insert newForm ;

			ISSP_ANG_PCI pci = new ISSP_ANG_PCI();

			ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );			
			
			pci.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			pci.agencyCodesConcerned = pci.getAgencyCodesConcerned();
			pci.CheckCountryReqments();			
			pci.save();
			pci.fetchCase(testCase.Id);			
			pci.goToStep1();
			pci.goToStep2();
			pci.cancel();
			pci.goToStep3();
			pci.submitForm();
			pci.securityCheck();
			String agencyCodesConcernedStr = pci.agencyCodesConcernedStr;
		}
	}

	@isTest static void CreateData_III(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

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
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        ISSP_AMS_Accreditation_Acc_Req.File_Identifier2__c = 'PCI_COMPLIANCE';        
        insert ISSP_AMS_Accreditation_Acc_Req;

		Test.startTest();
		System.runAs(newUser){

			Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_PCI')); 

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'Spanish';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0;            
	            testCase.Account_Concerned__c = null;
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';
	            testCase.Account_Concerned__c = child.Id;
            insert testCase;

            System.currentPageReference().getParameters().put('caseId', testCase.Id);
            System.currentPageReference().getParameters().put('step', '2');

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
            insert newForm ;

			ISSP_ANG_PCI pci = new ISSP_ANG_PCI();

			ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );			
			
			pci.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			pci.securityCheck();
		}
	}

	//rui lavos
	@isTest static void CreateData_IV(){
		//Create countries
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test',
                                    IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                    IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                    IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2');
        insert country2;
		
		//Create Accounts
		id AgencyRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Agency') ;
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'];

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
		
		Account child = ISSP_ObjectFactory.createNewAccount();
	        child.BillingCity = 'test2';
	        child.Name = 'test2';
	        child.Site = 'headSite';
	        child.sector__c = 'Travel Agent';
	        child.Top_Parent__c = null; //aqui
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
        ISSP_AMS_Accreditation_Acc_Req.Location_type__c = 'HO';
        ISSP_AMS_Accreditation_Acc_Req.Requirement_text__c = 'cdd';
        ISSP_AMS_Accreditation_Acc_Req.Sort_Order__c = 1;
        ISSP_AMS_Accreditation_Acc_Req.Name = 'TestReq1';
        ISSP_AMS_Accreditation_Acc_Req.File_Identifier2__c = 'PCI_COMPLIANCE';        
        insert ISSP_AMS_Accreditation_Acc_Req;

		Test.startTest();
		System.runAs(newUser){

			Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_PCI')); 
			System.currentPageReference().getParameters().put('step', '3');

			Case testCase = ISSP_ObjectFactory.createNewCase();
	            testCase.BSPCountry__c = 'South Africa';
	            testCase.Reason1__c = 'Travel Agent';
	            testCase.Customer_recovery__c = false;            
	            testCase.BounceEmailCounter__c = 0.0;
	            testCase.Case_Language__c = 'French';
	            testCase.Subject = 'Test 006';
	            testCase.Reopened_case__c = 0.0;            
	            testCase.Account_Concerned__c = null;
	            testCase.IFAP_Country_ISO__c = 'tq';
	            testCase.Status = 'Action Needed';
	            testCase.Region__c = 'Africa & Middle East';
	            testCase.Account_Concerned__c = child.Id;
            insert testCase;

            System.currentPageReference().getParameters().put('caseId', testCase.Id);

            AMS_Pax_Accreditation_Form__c newForm = new AMS_Pax_Accreditation_Form__c();
	            newForm.IsGSA__c = 'No';
	            newForm.CurrencyIsoCode = country.CurrencyIsoCode;
	            newForm.SAAM_Case__c = testCase.Id;
	            newForm.HO_Account__c = parent.Id;
	            newForm.Agency_Codes_Concerned__c = parent.IATACode__c;
            insert newForm ;

			ISSP_ANG_PCI pci = new ISSP_ANG_PCI();

			

			//ApexPages.currentPage().getParameters().put('caseId' ,testCase.Id );			
			
			pci.newForm.Agency_Codes_Concerned__c = child.IATACode__c;
			pci.securityCheck();
		}
	}
	//rui lavos
}
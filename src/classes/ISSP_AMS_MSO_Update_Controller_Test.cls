@isTest
private class ISSP_AMS_MSO_Update_Controller_Test {
	
	@isTest static void test_correction() {

        Id conRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Contact'}).get('Contact').get('Standard_Contact');//[SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        Id accRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('IATA_Airline');//[SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Airline' AND SobjectType = 'Account'].Id;
        Id agcRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('IATA_Agency');// [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Agency' AND SobjectType = 'Account'].Id;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'FR', Case_BSP_Country__c='Test');       
        insert isoc;

        IATA_ISO_State__c isos = new IATA_ISO_State__c(Name='Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c='FR');
        insert isos;

        Account acc = new Account (
			RecordTypeId = accRtId,
			Name = 'Airline HQ', 
			IATACode__c = '012',
            Airline_designator__c = 'HQ',
			IATA_ISO_Country__c = isoc.Id
			);
        insert acc;

        Contact con = new Contact (
			AccountId = acc.id,
			RecordTypeId = conRtId, 
			LastName = 'portalUser',
			FirstName = 'first',
			Email = 'someuser@iata.org',
			User_Portal_Status__c = 'Approved User'
			);
        insert con;

        Account mso = new Account (
    		RecordTypeId = agcRtId,
			Name = 'Airline HQ', 
			IATA_ISO_Country__c = isoc.Id,
			Iso_State__c = isos.Id,
			Sector__c = 'Travel Agent',
            Category__c = 'MSO Member Sales Office',
            Location_Class__c = 'M',
            Location_Type__c = 'HO',
            Reason_for_creation__c = 'New Agent',
            Status__c = 'Approved',
            BillingCity = 'initialCity',
            BillingStreet = 'asvs'
			);
        insert mso;


        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];
         
        User newUser = new User(
			profileId = p.id,
			username = 'someuser@iata.org',
			email = 'someuser@iata.org',
			emailencodingkey = 'UTF-8',
			localesidkey = 'en_US',
			languagelocalekey = 'en_US',
			timezonesidkey = 'America/Los_Angeles',
			alias='nuser',
			lastname='lastname',
			contactId = con.id
			);
        insert newUser;
		
		
        System.runAs(newUser){
        	

      		Test.setCurrentPage(Page.ISSP_AMS_MSO_Update);
      		System.currentPageReference().getParameters().put('msoId', mso.Id);
			System.currentPageReference().getParameters().put('action', ISSP_AMS_MSO_Update_Controller.ACTION_CORRECTION);

            ISSP_AMS_MSO_Update_Controller ctrl = new ISSP_AMS_MSO_Update_Controller();

            system.assertEquals('/ISSP_AMS_MSO', ctrl.cancel().getUrl());
            system.assertEquals('/ISSP_Homepage', ctrl.securityCheck().getUrl()); 
            
            ctrl.accreditationForm.Branch_Office_Street_name_number__c = 'streetname';
            ctrl.accreditationForm.Branch_Office_City__c = 'cityname';
            ctrl.accreditationForm.Branch_Office_Postal_code__c = '12345';

            // failing because no country & state selected, invalid email
            ctrl.countrySelected = null;
            ctrl.billingState = null;
            ctrl.accreditationForm.Branch_Office_Email__c = 'abc';
            system.assertEquals(null, ctrl.save());

            System.assertNotEquals(null, ctrl.goBackToForm());


            Test.startTest();    

	            ctrl.countrySelected = isoc.Id;
	            ctrl.billingState = isos.Id;
	            ctrl.accreditationForm.Branch_Office_Email__c = 'abc@abc.com';
	            ctrl.save();
	            ctrl.save();
                        	
            	ctrl.submitAndApproveCase(); 

            	ISSP_AMS_MSO_Update_Controller.closeOscar(ctrl.oscar.Id, ctrl.OscarCase.Id, con.id, ISSP_AMS_MSO_Update_Controller.ACTION_CORRECTION);

			Test.stopTest();
        }


		list<Account> updatedMSO = [SELECT Id, Location_Class__c, Name, RecordType.DeveloperName, IATACode__c, BillingCity FROM Account WHERE Id = :mso.Id];
		//system.assertEquals('cityname', updatedMSO[0].BillingCity);
		
	}
	
	@isTest static void test_termination() {
		
        Id conRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Contact'}).get('Contact').get('Standard_Contact');//[SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        Id accRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('IATA_Airline');//[SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Airline' AND SobjectType = 'Account'].Id;
        Id agcRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('IATA_Agency');// [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Agency' AND SobjectType = 'Account'].Id;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'FR', Case_BSP_Country__c='Test');       
        insert isoc;

        IATA_ISO_State__c isos = new IATA_ISO_State__c(Name='Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c='FR');
        insert isos;

        Account acc = new Account (
			RecordTypeId = accRtId,
			Name = 'Airline HQ', 
			IATACode__c = '012',
            Airline_designator__c = 'HQ',
			IATA_ISO_Country__c = isoc.Id
			);
        insert acc;

        Contact con = new Contact (
			AccountId = acc.id,
			RecordTypeId = conRtId, 
			LastName = 'portalUser',
			FirstName = 'first',
			Email = 'someuser@iata.org',
			User_Portal_Status__c = 'Approved User'
			);
        insert con;

        Account mso = new Account (
    		RecordTypeId = agcRtId,
			Name = 'Airline HQ', 
			IATA_ISO_Country__c = isoc.Id,
			Iso_State__c = isos.Id,
			Sector__c = 'Travel Agent',
            Category__c = 'MSO Member Sales Office',
            Location_Class__c = 'M',
            Location_Type__c = 'HO',
            Reason_for_creation__c = 'New Agent',
            Status__c = 'Approved'
			);
        insert mso;


        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];
         
        User newUser = new User(
			profileId = p.id,
			username = 'someuser@iata.org',
			email = 'someuser@iata.org',
			emailencodingkey = 'UTF-8',
			localesidkey = 'en_US',
			languagelocalekey = 'en_US',
			timezonesidkey = 'America/Los_Angeles',
			alias='nuser',
			lastname='lastname',
			contactId = con.id
			);
        insert newUser;
		
		ISSP_AMS_MSO_Update_Controller ctrl;
        System.runAs(newUser){
            Test.setCurrentPage(Page.ISSP_AMS_MSO_Update);
            System.currentPageReference().getParameters().put('msoId', mso.Id);
            System.currentPageReference().getParameters().put('action', ISSP_AMS_MSO_Update_Controller.ACTION_TERMINATION);
            ctrl = new ISSP_AMS_MSO_Update_Controller();
        }

        Test.startTest(); 
        ctrl.terminate();
        Test.stopTest();

		list<Account> updatedMSO = [SELECT Id, Status__c FROM Account WHERE Id = :mso.Id];
		system.assertEquals('Terminated', updatedMSO[0].Status__c);
	}

	@isTest static void test_increase_coverage() {

        Id conRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Contact'}).get('Contact').get('Standard_Contact');//[SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        Id accRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('IATA_Airline');//[SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Airline' AND SobjectType = 'Account'].Id;
        Id agcRtId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Account'}).get('Account').get('IATA_Agency');// [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Agency' AND SobjectType = 'Account'].Id;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'FR', Case_BSP_Country__c='Test');       
        insert isoc;

        IATA_ISO_State__c isos = new IATA_ISO_State__c(Name='Test_state', IATA_ISO_Country__c = isoc.Id, ISO_Code__c='FR');
        insert isos;

        Account acc = new Account (
			RecordTypeId = accRtId,
			Name = 'Airline HQ', 
			IATACode__c = '012',
            Airline_designator__c = 'HQ',
			IATA_ISO_Country__c = isoc.Id
			);
        insert acc;

        Contact con = new Contact (
			AccountId = acc.id,
			RecordTypeId = conRtId, 
			LastName = 'portalUser',
			FirstName = 'first',
			Email = 'someuser@iata.org',
			User_Portal_Status__c = 'Approved User'
			);
        insert con;

        Account mso = new Account (
    		RecordTypeId = agcRtId,
			Name = 'Airline HQ', 
			IATA_ISO_Country__c = isoc.Id,
			Iso_State__c = isos.Id,
			Sector__c = 'Travel Agent',
            Category__c = 'MSO Member Sales Office',
            Location_Class__c = 'M',
            Location_Type__c = 'HO',
            Reason_for_creation__c = 'New Agent',
            Status__c = 'Approved'
			);
        insert mso;


        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];
         
        User newUser = new User(
			profileId = p.id,
			username = 'someuser@iata.org',
			email = 'someuser@iata.org',
			emailencodingkey = 'UTF-8',
			localesidkey = 'en_US',
			languagelocalekey = 'en_US',
			timezonesidkey = 'America/Los_Angeles',
			alias='nuser',
			lastname='lastname',
			contactId = con.id
			);
        insert newUser;
		
		
        System.runAs(newUser){
        	

      		Test.setCurrentPage(Page.ISSP_AMS_MSO_Update);
      		System.currentPageReference().getParameters().put('msoId', mso.Id);

            ISSP_AMS_MSO_Update_Controller ctrl = new ISSP_AMS_MSO_Update_Controller(); // no msoId, should show error

            System.currentPageReference().getParameters().put('action', ISSP_AMS_MSO_Update_Controller.ACTION_CORRECTION);
            ctrl = new ISSP_AMS_MSO_Update_Controller();

            system.assertEquals(null, ctrl.communityName);
            system.assertEquals('', ctrl.commParam); 
            system.assertEquals('', ctrl.commParamFirst);             
            
            ctrl.accreditationForm.Branch_Office_Street_name_number__c = 'streetname';
            ctrl.accreditationForm.Branch_Office_City__c = 'cityname';
            ctrl.accreditationForm.Branch_Office_Postal_code__c = '12345';

            ctrl.countrySelected = isoc.Id;
            ctrl.billingState = isos.Id;
            ctrl.accreditationForm.Branch_Office_Email__c = 'abc@abc.com';

            Test.startTest();  
	            PageReference step2 = ctrl.save();
	            Id caseId = step2.getParameters().get('caseId');

	            Test.setCurrentPage(Page.ISSP_AMS_MSO_Update);
	      		System.currentPageReference().getParameters().put('msoId', mso.Id);
	      		System.currentPageReference().getParameters().put('action', ISSP_AMS_MSO_Update_Controller.ACTION_CORRECTION);
	      		System.currentPageReference().getParameters().put('step', 'form');
	      		System.currentPageReference().getParameters().put('caseId', caseId);
	            
	            ctrl = new ISSP_AMS_MSO_Update_Controller(); // the case, oscar etc exist now          	
            	ctrl.cancelRequest(); 

            	Test.setCurrentPage(Page.ISSP_AMS_MSO_Update);
	      		System.currentPageReference().getParameters().put('msoId', mso.Id);
	      		System.currentPageReference().getParameters().put('action', ISSP_AMS_MSO_Update_Controller.ACTION_CORRECTION);
	      		System.currentPageReference().getParameters().put('step', 'view');
	      		System.currentPageReference().getParameters().put('caseId', caseId);
            
            	ctrl = new ISSP_AMS_MSO_Update_Controller(); // the case, oscar etc exist now          	
            
            	ctrl.goToEdit(); 
                ctrl.goToView(); 
                ctrl.goToTermination(); 

			Test.stopTest();
        }

	}
	
}
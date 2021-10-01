@isTest
private class ISSP_SISMembershipApplicationForm_CTest {

	private static void loadCredentials() {
		TestDataFactory_AWSKeys.createAllEntries();
		insert new Case_Reason_Service__c (
			Name ='SIS Client',
			Service__c =ISSP_SISMembershipApplication_Ctrl.APP_NAME,
			Provider_Required__c = false);
	}

	private static User createPortalUser() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name='Spain',ISO_Code__c='SP');
		insert country;
		Account account = new Account(
			Name = 'test Account',
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','IATA_Agency'),
			Sector__c = 'Airline',
			Category__c = 'CASS Associate',
			BillingCountry = country.Name,
			Give_SIS_Membership__c = 'ISPA'
		);
		insert account;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId= account.Id;
		con.Email = 'Test' + String.valueOf(Math.random()) + '@test11.com';
		con.User_Portal_Status__c='Administrator';
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalUser(con);
		con.OwnerId = newUser.Id;
		update con;

		Portal_Applications__c SISapp = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		SISapp.Name = ISSP_SISMembershipApplication_Ctrl.APP_NAME;
    	insert SISapp;

		Portal_Application_Right__c right = new Portal_Application_Right__c(
			Contact__c = con.Id,
			Right__c = 'Access Granted',
			Portal_Application__c = SISapp.Id
		);
		PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
		insert right;
		return newUser;
	}

	static testMethod void test_Controller() {
		loadCredentials();
		User portalUser = createPortalUser();

		System.runas(portalUser) {
			ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
			ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
			PageReference pageref = wrapper.ApplyNow();

			Test.startTest();
			Test.setCurrentPageReference(pageref);
			System.currentPageReference().getParameters().put('step', '1');
			ISSP_SISMembershipApplicationForm_Ctrl formcontroller = new ISSP_SISMembershipApplicationForm_Ctrl();
			formcontroller.getListCountryOptions();
			formcontroller.saveFormAndGoForward();
			formcontroller.saveFormAndGoBack();
			formcontroller.saveFormAndGoBack();
			formcontroller.saveFormAndLeave();
			formcontroller.getisISPA();
			formcontroller.getisISUA();
			formcontroller.getisTOU();
			formcontroller.getSteps();
			Test.stopTest();
		}
	}

	 static testMethod void test_saveDraft() {
		 loadCredentials();
		User portalUser = createPortalUser();

		System.runas(portalUser) {
			ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
			ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
			PageReference pageref = wrapper.ApplyNow();
			Test.setCurrentPageReference(pageref);
			ISSP_SISMembershipApplicationForm_Ctrl formcontroller = new ISSP_SISMembershipApplicationForm_Ctrl();

			Test.startTest();
			formcontroller.currentStep=2;
			formcontroller.newForm.Is_AA_Member__c = 'No';
			formcontroller.newForm.Do_you_have_an_iiNET_account__c = 'No';
			formcontroller.newForm.Is_your_company_joining_the_Clearing_Hou__c = 'No';
			formcontroller.newForm.Is_company_subject_to_EU_laws__c = 'No';
			formcontroller.newForm.Company_Country__c = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1].Id;
			System.assert(formcontroller.saveFormAndLeave()!=null);

			formcontroller.currentStep=3;
			formcontroller.newForm.Accept_terms_and_conditions__c = true;
			System.assert(formcontroller.saveFormAndLeave()!=null);

			formcontroller.currentStep=2;
			formcontroller.newForm = null;
			System.assert(formcontroller.saveFormAndLeave()==null);

			Test.stopTest();
		}
	}

	 static testMethod void test_submitForm() {
		loadCredentials();
		User portalUser = createPortalUser();

		System.runas(portalUser) {
			ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
			ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
			PageReference pageref = wrapper.ApplyNow();
			Test.setCurrentPageReference(pageref);
			ISSP_SISMembershipApplicationForm_Ctrl formcontroller = new ISSP_SISMembershipApplicationForm_Ctrl();

			Case cse = formcontroller.newCase;
			insert new list<AmazonFile__c>{
				 new AmazonFile__c(Full_Name_Unique__c = '1', File_Identifier__c = 'COI',Case__c = cse.Id),
				 new AmazonFile__c(Full_Name_Unique__c = '2', File_Identifier__c = 'Shareholders_List',Case__c = cse.Id),
				 new AmazonFile__c(Full_Name_Unique__c = '3', File_Identifier__c = 'BankMandate',Case__c = cse.Id),
				 new AmazonFile__c(Full_Name_Unique__c = '4', File_Identifier__c = 'SISMembershipForm',Case__c = cse.Id)
			};

			Test.startTest();
			formcontroller.currentStep=0;
			System.assert(formcontroller.submitForm()==null);

			formcontroller.currentStep=1;
			System.assert(formcontroller.submitForm()!=null);

			formcontroller.currentStep=2;
			formcontroller.newForm.Is_your_company_joining_the_Clearing_Hou__c = 'No';
			System.assert(formcontroller.submitForm()!=null);

			formcontroller.currentStep=3;
			System.assert(formcontroller.submitForm()!=null);

			Test.stopTest();
		}
	}

}

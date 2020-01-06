/**
  * Description: This class contains unit tests for the Update Contact webpage (IECUpdateContact.page)
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
  */
@IsTest (SeeAllData=true)
private class vfIECUpdateContactTest {
	static testMethod void updateContact_test() {

		PageReference pgRef = Page.IECUpdateContact;
		Test.setCurrentPage(pgRef);

		vfIECUpdateContact pgCont = new vfIECUpdateContact();

		// Test 001: Accessing page as guest user
		pgCont.pageLoad();

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		// get the Contact associated to the User (to get the Account Id)
		Contact oContact = [select AccountId from Contact where id = :usr.ContactId limit 1];

		// create Domain associated to the Account
		Account_Domain__c domain = new Account_Domain__c();
		domain.Name = 'accepteddomain.org';
		domain.Account__c = oContact.AccountId;
		insert domain;

		System.runAs(usr) {

			Test.startTest();

			//Instantiate Controller
			IECPageController baseCont = new IECPageController();
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			pgCont = new vfIECUpdateContact();

			// Test #5 - test contact email change with unregistered domain
			// Temporary disabled
			/*
			try {
				pgCont.pageLoad();

				// change email to unkown domain
				pgCont.oContact.Email = 'new@email.com';
				pgCont.updateContact();

				system.assertNotEquals(pgCont.sOldEmail, pgCont.oContact.Email, 'The sOldEmail should be different from the new set email');
				system.assertEquals(true, pgCont.bEmailChanged, 'The flag bEmailChanged should be set to true');
				system.assertEquals(true, pgCont.bShowEmailDomainMessage, 'The flag bShowEmailDomainMessage should be set to true');

				// confirm email with wrong email
				pgCont.sConfirmEmail = 'some@email.com';
				pgCont.updateContact();

				// confirm email with good email
				pgCont.oContact.Email = 'new@email.com';
				pgCont.sConfirmEmail = 'new@email.com';
				pgCont.updateContact();

				// re-query the contact
				oContact = [select User_IECPortal_Status__c from Contact where id = :usr.ContactId limit 1];

				system.assertEquals(IECConstants.PENDING_APPROVAL_STATUS, oContact.User_IECPortal_Status__c, 'The portal status of the customer should be updated to ' + IECConstants.PENDING_APPROVAL_STATUS);
			}
			catch (Exception ex) {
				system.assert(false, 'Contact email change with unregistered domain should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
			}
			*/
			//END TEMPORARY DISABLE


			// Test #6 - test contact email change with registered domain
			// TEMPORARY DISABLE
			/*
			try {
				// change email to new domain
				pgCont.pageLoad();
				pgCont.oContact.Email = 'qwerty@accepteddomain.org';
				pgCont.updateContact();

				// confirm email
				pgCont.sConfirmEmail = 'qwerty@accepteddomain.org';
				pgCont.updateContact();

			}
			catch (Exception ex) {
				system.assert(false, 'Contact email change with registered domain should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
			}
			*/
			//END TEMPORARY DISABLED

			Test.stopTest();
		}
	}

	static testMethod void updateContact_test2() {

		PageReference pgRef = Page.IECUpdateContact;
		Test.setCurrentPage(pgRef);

		vfIECUpdateContact pgCont = new vfIECUpdateContact();

		// Test 001: Accessing page as guest user
		pgCont.pageLoad();

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		// get the Contact associated to the User (to get the Account Id)
		Contact oContact = [select AccountId from Contact where id = :usr.ContactId limit 1];

		// create Domain associated to the Account
		Account_Domain__c domain = new Account_Domain__c();
		domain.Name = 'accepteddomain.org';
		domain.Account__c = oContact.AccountId;
		insert domain;

		System.runAs(usr) {

			Test.startTest();

			//Instantiate Controller
			IECPageController baseCont = new IECPageController();
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			pgCont = new vfIECUpdateContact();

			// Test #1 - page load
			try {
				pgCont.pageLoad();

				system.assert(pgCont.oContact != null, 'The Contact should be loaded on pageLoad');
				system.assert(String.isNotBlank(pgCont.sOldEmail), 'The sOldEmail should not be empty on page load');
				system.assert(String.isNotBlank(pgCont.sAccountName), 'The Account name should be retreived');
/*              system.assert(pgCont.getCountries().size() > 0, 'The Countries should be loaded on pageLoad');
				system.assert(pgCont.getCanadaProvinces().size() > 0, 'The Canada provinces should be loaded on pageLoad');
				system.assert(pgCont.getUSAStates().size() > 0, 'The USA states should be loaded on pageLoad');
*/
				pgCont.backToContactInfo();
			}
			catch (Exception ex) {
				system.assert(false, 'PageLoad should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
			}

			// Test #2 - page load / contact update with incomplete Billing Address existing
			try {
				/* Commented by Samy (2016-03-02): Billing Address updates is not required as per scope of this page
				IECAddress__c oBillingAddress = new IECAddress__c();
				oBillingAddress.Address_Type__c = IECConstants.IECAddress_AddressType_Billing;
				oBillingAddress.Contact__c = usr.ContactId;
				insert oBillingAddress;*/
			   /*  salvatore
				pgCont.pageLoad();
				pgCont.updateContact();

				pgCont.iRegistrationStep = pgCont.constCHANGEEMAIL;
				pgCont.updateContact();

				pgCont.oContact.Email = 'abc@abc.com';
				pgCont.iRegistrationStep = pgCont.constCONTACTINFO;
				pgCont.bPasswordReset = true;
				pgCont.updateContact();

				pgCont.oContact.Phone = null;
				pgCont.updateContact();
				pgCont.oContact.Title = null;
				pgCont.updateContact();
				pgCont.oContact.FirstName = null;
				pgCont.updateContact();
*/
			}
			catch (Exception ex) {
				system.assert(false, 'PageLoad with existing Billing Address should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
			}

			// Test #3 - contact update with complete Billing Address info
			try {
				//Commented by Samy (2016-03-02): Billing Address updates is not required as per scope of this page
				/*pgCont.oBilling.State__c = 'CA';
				pgCont.oBilling.ZipCode__c = '12345';*/
				pgCont.oContact.Title = 'Title';
				pgCont.oContact.Email = 'testIECGuest@test.iata.org';

				pgCont.updateContact();
				system.assert(true, 'Contact upgrade should not throw an error');

			}
			catch (Exception ex) {
				system.assert(false, 'PageLoad with existing Billing Address should not throw an error: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
			}

			Test.stopTest();
		}
	}
}

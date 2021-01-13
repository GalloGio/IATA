/**
 * This class contains unit tests for class IECCustomer
 */
@isTest(SeeAllData=true)
private class IECCustomer_tst {

		static testMethod void testIATAMemberCustomer() {
		 	User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		 	Contact oContact = IECUserManager.getContactById(usr.ContactId);
		 	system.assert(oContact != null, 'Contact associated to the created user should not be null');
		 	IECCustomer oCurrentCustomer;

			System.runAs(usr) {

		 		Test.startTest();

			 	oCurrentCustomer = IECCustomer.getCurrentIECCustomer();

			 	system.assert(oCurrentCustomer != null, 'Object representing the logged in use should not be null');
			}

		insert IECTestUtil.CreateSampleSAPAccount(oCurrentCustomer.RelatedAccount.Id);

			System.runAs(usr) {

			 	// test retreival of client type
			 	//system.assertEquals(IECConstants.Account_ClientType_MemberAirline, oCurrentCustomer.ClientType, 'Client Type should be IATA Member Airline');

			 	// test payment methods
			 	system.assert(oCurrentCustomer.PaymentMethods != null && !oCurrentCustomer.PaymentMethods.isEmpty(), 'Should have payment methods');

			 	// test credit cards
			 	system.assert(oCurrentCustomer.CreditCards != null && !oCurrentCustomer.CreditCards.isEmpty(), 'Should have credit cards');

			 	// add credit card
			 	oCurrentCustomer.addTestCreditCard(IECTestUtil.createSampleZuoraPaymentMethod('789sdfa788df789fd', 'A00000089', 2018, 6));

			 	// test invoices & payments
			 	List<Zuora__ZInvoice__c> lstInvoices = oCurrentCustomer.Invoices;
			 	List<Zuora__Payment__c> lstPayment = oCurrentCustomer.Payments;

			 	IECUtil.PaymentMethodType ePM = oCurrentCustomer.DefaultPaymentMethodType;

			 	oCurrentCustomer.refreshZuoraAccount();
			 	oCurrentCustomer.refreshZuoraPaymentMethods();
			 	oCurrentCustomer.refreshRelatedContact();
			 	//system.assertEquals(true, oCurrentCustomer.canPayByICH(), 'Customer should be able to pay by ICH because Account is Member Airline');

			 	Test.stopTest();
			}
		}

		static testMethod void testThirdPartyCustomer() {

		 	final String IATA_CODE = '9876543';

		 	// create Headquarter Airline account
		 	Account oHeadquarterAirlineAccount = IECTestUtil.createSampleAccount(IECConstants.Account_ClientType_MemberAirline);
		 	oHeadquarterAirlineAccount.IATACode__c = IATA_CODE;
		 	insert oHeadquarterAirlineAccount;

		 	// create Standard Account
		 	Account oStandardAccount = IECTestUtil.createSampleAccount(IECConstants.Account_ClientType_ThirdParty);
		 	oStandardAccount.IATACode__c = IATA_CODE;
		 	oStandardAccount.Industry = IECConstants.Account_Industry_Airline;
		 	oStandardAccount.Reason_for_creation__c = 'Created by customer';
		 	insert oStandardAccount;

		 	Contact oContact = IECTestUtil.createSampleContact(oStandardAccount);
		 	oContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
		 	insert oContact;

		 	User oUser = IECTestUtil.createSampleUser(oContact);
		 	String userId = Site.createPortalUser(oUser, oStandardAccount.Id, 'testpassword');
		 	IECUserManager.login(oUser.Username, 'testpassword', null);

			System.runAs(oUser) {

		 		Test.startTest();

			 	try {

				 	IECCustomer oCurrentCustomer = IECCustomer.getCurrentIECCustomer();

				 	system.assert(oCurrentCustomer != null, 'Object representing the logged in use should not be null');

				 	// test retreival of client type
				 	//system.assertEquals(IECConstants.Account_ClientType_MemberAirline, oCurrentCustomer.ClientType, 'Client Type should be IATA Member because account has same IATA code as a HQ airline');
			 	}
			 	catch (Exception ex) {
			 		system.assert(false, 'testClientType should not throw any exception');
			 	}

			 	Test.stopTest();
			}
		}
}

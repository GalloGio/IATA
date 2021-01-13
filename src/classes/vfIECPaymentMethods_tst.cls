/**
  * Description: This class contains unit tests for the (Payment Methods) webpage
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */
@IsTest(SeeAllData=true)
private class vfIECPaymentMethods_tst {
	static testMethod void TestPaymentMethods() {
		System.debug('Unit Test: Start: TestPaymentMethods');

		PageReference pgRef = Page.IECPaymentMethods;
		Test.setCurrentPage(pgRef);

		vfIECPaymentMethods pgCont;
		IECPageController baseCont;

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			//Instantiate Controller
			baseCont = new IECPageController();
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			//Instantiate Controller
			pgCont = new vfIECPaymentMethods();
			pgCont.pageLoad();

			// Test 001: Make sure payment methods loaded successfully
			system.assert(pgCont.hasCreditCards);
			system.assert(pgCont.DefaultPaymentMethodsItems.size() > 1);
			system.assert(!String.isEmpty(pgCont.customerDefaultPaymentMethodId));

			// Test 002: Update default payment type
			// Set it to a credit card
			pgCont.customerDefaultPaymentType = 'Credit Card';
		}
			// Run outside the usr scope to avoid the "INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY, insufficient access rights on cross-reference id: []" exception
			pgCont.updateDefaultPaymentMethod();

		System.runAs(usr) {
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Confirm_DefaultPaymentUpdate));

			// Test 003: Modify existing card
			pgCont.creditCardToEdit = '222';
			pgCont.saveCard();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), 'has been successfully updated'));

			// Test 004: Delete existing card
			pgCont.creditCardToDelete = '111';
			pgCont.deleteCard();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), 'has been successfully deleted'));

			// Test 005: Add new card
			pgCont.newCreditCardPaymentId = '444';
			baseCont.loggedCustomer.addTestCreditCard(IECTestUtil.createSampleZuoraPaymentMethod('444', '99999', 2999, 12));
			pgCont.addCard();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Confirm_AddNewCard));
		}

		System.debug('Unit Test: Finish: TestPaymentMethods');
	}
	static testMethod void TestPaymentMethods_Errors() {
		System.debug('Unit Test: Start: TestPaymentMethods_Errors');

		PageReference pgRef = Page.IECPaymentMethods;
		Test.setCurrentPage(pgRef);

		//Instantiate Controller
		vfIECPaymentMethods pgCont = new vfIECPaymentMethods();

		// Test 001: Accessing page as guest user
		pgCont.pageLoad();

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			//Instantiate Controller
			IECPageController baseCont = new IECPageController();
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			// Load page again to load properly this time
			pgCont = new vfIECPaymentMethods();
			pgCont.pageLoad();

			// Test 002: Update default payment type
			// Set it to none
			pgCont.customerDefaultPaymentType = '';
			pgCont.updateDefaultPaymentMethod();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_DefaultPaymentEmpty));

			/* Commented by Samy (2016-03-04) Replaced with new code to save the default payment type instead of method on the SF Account level
			// Test 003: Update default payment method
			// Set it to a credit card that has an expired date
			pgCont.customerDefaultPaymentMethodId = '111';
			pgCont.updateDefaultPaymentMethod();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_DefaultPaymentExpired));
			*/

			// Test 004: Delete existing card
			pgCont.creditCardToDelete = pgCont.customerDefaultPaymentMethodId;
			pgCont.deleteCard();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_DeleteDefaultPayment));

			// Test 005: Add new card
			pgCont.addCard();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_HostedPaymentIdMissing));

			pgCont.newCreditCardPaymentId = '444';
			pgCont.addCard();
			system.assert(IECTestUtil.PageContainsMessage(ApexPages.getMessages(), Label.IEC_Error_AddNewCardFailed));

			// Test 006: Callback failure
			pgCont.displayCallBackfailure();
		}
		System.debug('Unit Test: Finish: TestPaymentMethods_Errors');
	}

	static testMethod void TestPaymentMethods_Misc() {
		System.debug('Unit Test: Start: TestPaymentMethods_Misc');

		PageReference pgRef = Page.IECPaymentMethods;
		Test.setCurrentPage(pgRef);

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		System.runAs(usr) {
			//Instantiate Controller
			IECPageController baseCont = new IECPageController();
			baseCont.loggedCustomer = IECCustomer.getCurrentIECCustomer();

			//Instantiate Controller
			vfIECPaymentMethods pgCont = new vfIECPaymentMethods();
			pgCont.pageLoad();

			// Add coverage for the misc functions & variabes
			String s = pgCont.getExtraParamString();
			List<SelectOption> lstOptions = pgCont.MonthsSelectOptionItems;
			lstOptions = pgCont.YearsSelectOptionItems;
			lstOptions = pgCont.getCountriesItems();

			pgCont.addButton();
			pgCont.editButton();
			pgCont.cancelButton();
		}

		System.debug('Unit Test: Finish: TestPaymentMethods_Misc');
	}
}

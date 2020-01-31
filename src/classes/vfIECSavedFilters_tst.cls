/**
 * This class contains unit tests for validating the behavior of class vfIECSavedFilters
 */
@isTest
private class vfIECSavedFilters_tst {

	private static Account oAccount;
	private static Account oAgencyAccount;
	private static Zuora__CustomerAccount__c oBillingAccount;
	private static Contact oContact;
	private static IECCustomer currentCustomer;

	private static void initCustomer(){

		currentCustomer = IECCustomer.getCurrentIECCustomer();
		oAccount = currentCustomer.RelatedAccount;
		oContact = currentCustomer.RelatedContact;
		oBillingAccount = currentCustomer.RelatedBillingAccount;
	}

	@isTest(SeeAllData=true)
	static void testController() {
		try {

			User u = IECTestUtil.createSampleGuestUserAndLogin();
			System.runAs(u) {

				// setup data
				initCustomer();

				vfIECSavedFilters controller = new vfIECSavedFilters();
				controller.loggedCustomer = currentCustomer;
				controller.loadFilters();

				// Test #1 - no filters
				List<IEC_Application_Filter__c> lstFilters = controller.lstSavedFilters;
				//system.assert(lstFilters == null || lstFilters.isEmpty(), 'There should be no filters for current customer');

				// Test #2 - load some filters
				IEC_Application_Filter__c oFilter1 = IECTestUtil.CreateSampleApplicationFilter(oContact);
				insert oFilter1;

				controller.loadFilters();
				lstFilters = controller.lstSavedFilters;
				system.assert(lstFilters.size() == 1, 'There should be 1 filters for current customer');
				//system.assert(lstFilters != null && lstFilters.size() == 1, 'There should be 1 filters for current customer');

				controller.iFilterIndex = 0;
				controller.runFilter();
				controller.editFilter();
				controller.deleteFilter();
			}
		}
		catch (Exception ex) {
			system.assert(false, 'Test testController should not throw an exception: ' + ex.getMessage() + '\r\n' + ex.getStacktraceString());
		}
	}
}

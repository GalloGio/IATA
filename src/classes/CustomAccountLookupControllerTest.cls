@isTest
public class CustomAccountLookupControllerTest
{
	@testSetup
	public static void setup()
	{
		IATA_ISO_Country__c pt = ANG_TestDataHelper.insertBspAndIsoCountry(ANG_TestDataHelper.COUNTRY_INFORMATION.get('PT'));
		Account ac1 = ANG_TestDataHelper.insertStandardAccount('SC Account 1 HE PT', (Id) null, AMS_Utils.HE, pt, '10000000');
		Account ac2 = ANG_TestDataHelper.insertStandardAccount('SC Account 2 HE PT', (Id) null, AMS_Utils.HE, pt, '10000001');
		Account ac3 = ANG_TestDataHelper.insertStandardAccount('SC Account 3 HE PT', (Id) null, AMS_Utils.HE, pt, '10000002');
		Account ac4 = ANG_TestDataHelper.insertStandardAccount('SC Account 4 HE PT', (Id) null, AMS_Utils.HE, pt, '10000003');
	}

	@isTest
	public static void testController()
	{
		List<Account> accounts = [SELECT Id FROM Account WHERE Name IN ('SC Account 1 HE PT', 'SC Account 2 HE PT')];
		String ids = accounts.get(0).Id + ',' + accounts.get(1).Id;

		PageReference pageRef = Page.CustomAccountLookup;
		pageRef.getParameters().put('lksrch', '10000001');
		pageRef.getParameters().put('staticFilter', ids);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		CustomAccountLookupController controller = new CustomAccountLookupController();
		controller.search();

		System.assertEquals(1, controller.results.size());
		System.assertEquals(null, controller.getFormTag());
		System.assertEquals(null, controller.getTextBox());
		
		Account a = new Account(Name = 'SC Account 5 HE PT');
		controller.account = a;
		controller.saveAccount();
		Test.stopTest();

		System.assertNotEquals(null, a.Id);
	}
}
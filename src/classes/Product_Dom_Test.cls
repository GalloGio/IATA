/**

	Project: eCommerce Enhancements
	   File: Product_Dom_Test.cls
	Subject: Test Class for Product_Dom Class.
	History: 2017-06-26, asantos, Initial Release.

*/
@isTest
private class Product_Dom_Test {
	private static User user;
	private static Account account;
	private static Contact contact;

	private static void setup() {
		user = IECTestUtil.createSampleGuestUserAndLogin();

		TestDataGenerator.generateApexSetting();
		account = TestDataGenerator.generateAccounts(1, true)[0];
		contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];
		contact.Account = account;

		Apex_Setting__c setting = new Apex_Setting__c (Name = 'Execute Trigger Product', Number_1__c = 1);
		
		insert setting;
	}

	@isTest (SeeAllData=true)
	static void testProductDom() {
		Test.startTest();

		setup();

		System.runAs(user) {
			List<Product2> productList = TestDataGenerator.generateProducts(5, true);

			for (Product2 product : productList) {
				product.Accepted_Payment_Methods__c = 'Credit Card';
			}

			update productList;

			update productList;

			Apex_Setting__c setting = new Apex_Setting__c(Name='Sandbox Reference Data Sync', Number_1__c = 1);

			insert setting;

			update productList;
		}

		Test.stopTest();
	}
}
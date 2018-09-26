/**

	Project: eCommerce Enhancements
	   File: Pricebook_Sel_Test.cls
	Subject: Test Class for Pricebook_Sel Class.
	History: 2017-06-26, asantos, Initial Release.

*/
@isTest
private class Pricebook_Sel_Test {
	private static User user;
	private static Account account;
	private static Contact contact;
	private static Map<Id,Id> productZProductMap = new Map<Id,Id>();
	private static Map<Id,zqu__ProductRatePlanCharge__c> chargeMap = new Map<Id,zqu__ProductRatePlanCharge__c>();

	private static void setup() {
		user = IECTestUtil.createSampleGuestUserAndLogin();

		TestDataGenerator.generateApexSetting();
		account = TestDataGenerator.generateAccounts(1, true)[0];
		contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];
		contact.Account = account;

		for (
			Product2 product : [
				SELECT
					Id,
					ZProduct__c
				FROM
					Product2
				WHERE
					ZProduct__c != null
			]
		) {
			productZProductMap.put(product.ZProduct__c, product.Id);

			System.debug('ZProductId: ' + product.ZProduct__c + ', ProductId: ' + product.Id);
		}

		for (
			zqu__ProductRatePlanCharge__c charge : [
				SELECT
					Id,
					zqu__ListPrice__c,
					zqu__ProductRatePlan__r.zqu__ZProduct__c
				FROM
					zqu__ProductRatePlanCharge__c
				WHERE
					zqu__Deleted__c = false
					AND
					zqu__ListPrice__c != NULL
			]
		) {
			Id zProductId = charge.zqu__ProductRatePlan__r.zqu__ZProduct__c;
			Id productId = productZProductMap.get(zProductId);

			if (productId != null) {
				System.debug('ProductId: ' + productId + ', ChargeId: ' + charge.Id + ', ZProductId: ' + zProductId);

				chargeMap.put(productId, charge);
			}
		}
	}

	@isTest (SeeAllData=true)
	static void testPricebookSel() {
		Test.startTest();

		setup();

		System.runAs(user) {
			Pricebook_Sel pricebookSel = new Pricebook_Sel();
			
			List<Schema.SObjectField> sobjectFieldList = pricebookSel.getSObjectFieldList();
			Schema.SObjectType sobjectType = pricebookSel.getSObjectType();
			Pricebook2 pricebook2 = pricebookSel.getStandardPricebook();
			String corporateCurrencyCode = pricebookSel.getCorporateCurrencyCode();
			List<PricebookEntry> pricebookEntryList = pricebookSel.generatePriceBokkEntries(
				chargeMap,
				pricebook2,
				true
			);

			pricebookEntryList = pricebookSel.generatePriceBokkEntries(
				chargeMap,
				pricebook2,
				false
			);
		}

		Test.stopTest();
	}
}
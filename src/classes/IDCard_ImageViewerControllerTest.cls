@isTest
private class IDCard_ImageViewerControllerTest {


	@isTest static void test_IDCard_ImageViewerController() {
		TestDataFactory_AWSKeys.createAllEntries();

		ID_Card__c idCard = CreateValidIDCardTest();

		ApexPages.StandardController stdController = new ApexPages.StandardController(idCard);
		IDCard_ImageViewerController controller = new IDCard_ImageViewerController(stdController);

		system.assertNotEquals(null, controller.authorizationLink);
	}


	private static ID_Card__c CreateValidIDCardTest()
	{
		ID_Card__c aIdCard = new ID_Card__c();
		aIdCard.FirstName__c = 'Test';
		aIdCard.LastName__c = 'Contact 1';
		aIdCard.Agency_Name__c = 'Test IDCard';
		aIdCard.Agency_IATA_Code__c = '12345678';
		aIdCard.Name_on_ID_Card__c = 'Test IDCard';
		aIdCard.Nature_of_ID_Card__c = 'Nenew';
		aIdCard.Card_Status__c = 'Sent ID Card';
		aIdCard.Type_of_ID_Card__c = 'Passenger';
		aIdCard.Photo_Flag__c = 'Digital';
		aIdCard.Photo__c = '54668.jpg';
		aIdCard.Card_Variation_Code__c ='2';
		aIdCard.Card_Code__c = 'TACB';
		aIdCard.CIN__c = 'TACB';
		aIdCard.MustSyncWithAIMS__c = true;
		aIdCard.Hours_per_week__c = '35h or more';
		aIdCard.Start_Date_Agency_Month__c = 'DECEMBER';
		aIdCard.Start_Date_Agency_Year__c = '2000';
		aIdCard.Start_Date_Industry__c = '2000';
		aIdCard.Valid_To_Date__c = Date.newInstance(2099, 06, 23);
		aIdCard.VER_Number__c = '5036048956';
		aIdCard.Date_of_Birth__c = Date.newInstance(1985, 06, 23);
		insert aIdCard;

		return aIdCard;
	}
}

@IsTest
private class vfIATAPassengersList_Test {


	@IsTest static void testPageTitle_ListTitle(){

		String productCode = 'ASL';

		// test encrypt encode
        String sEncryptedEncodedValue1 = IECUtil.EncryptEncodeParameter(productCode);

		Test.setCurrentPageReference(new PageReference('/apex/IATAPassengersList'));
		System.currentPageReference().getParameters().put('ProductCode', sEncryptedEncodedValue1);
		
		//Data Preparation
		GDP_Airlines_Statistic__c newAirlineStatistic = new GDP_Airlines_Statistic__c();
		newAirlineStatistic.Class__c = 'ASL';
        newAirlineStatistic.Key__c = 'ASLTEST';
        newAirlineStatistic.Last_Update__c = system.now().addDays(-1);
        newAirlineStatistic.AO__c = 0;
        newAirlineStatistic.BR__c = 0;
        newAirlineStatistic.AW__c = 0;

        insert newAirlineStatistic;

        Test.startTest();

		vfIATAPassengersList controller = new vfIATAPassengersList();
		String pageTitle = controller.PageTitle;
		String listTitle = controller.ListTitle;

		Test.stopTest();

		//Check the page title && listTitle
		System.assertEquals('MSO & GSA List', pageTitle);
		System.assertEquals('IATA Airline Sales Worldwide Statistics', listTitle);

	}

	
}
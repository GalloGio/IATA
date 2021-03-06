@isTest
private class IDCardApplicationImageViewerCtrlTest {

	@isTest static void test_method_one() {
		TestDataFactory_AWSKeys.createAllEntries();

		ID_Card_Application__c app = CreateAIdCardApplication();

		ApexPages.StandardController stdController = new ApexPages.StandardController(app);
		ApexPages.currentPage().getParameters().put('id', app.Id);
		IDCardApplicationImageViewerController controller = new IDCardApplicationImageViewerController(stdController);

		system.assertNotEquals(null, controller.authorizationLink);

	}


	private static ID_Card_Application__c CreateAIdCardApplication()
	{
		ID_Card_Application__c aApplication = new ID_Card_Application__c();
		aApplication.Title__c = 'Mr';
		aApplication.First_Name__c = 'Test';
		aApplication.Last_Name__c = 'Contact 1';
		aApplication.Approving_Manager_s_Email__c = 'manager@admin.ad';
		aApplication.Approving_Manager_s_Name__c = 'Manager';
		aApplication.Date_of_Birth__c = Date.newInstance(1980,12,12);
		aApplication.Displayed_Name__c = 'Test Contact 1';
		aApplication.Type_of_application__c = 'Renew';
		aApplication.Gender__c = 'M';
		aApplication.Solicitation_Flag__c = true;
		aApplication.IATA_Code__c = '1234567';
		aApplication.Photo__c = '54668.jpg';
		aApplication.Start_Date_Agency_Year__c = '2000';
		aApplication.Start_Date_Agency_Month__c = 'January';
		aApplication.Start_Date_Industry__c = '1998';
		aApplication.Duties_in_Current_Agency__c = 'Sales';
		aApplication.Position_in_Current_Agency__c = 'Director';
		aApplication.Hours_worked__c = '35 h or more';
		aApplication.Email_admin__c = 'dummyemail@mlail.com';
		insert aApplication;

		return aApplication;
	}

}

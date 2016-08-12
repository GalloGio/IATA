@isTest
private class AMP_BMAExtensionTest
{
	@isTest
	static void testBMAListing()
	{
		// TODO: run this as a test User
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(

			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);

		System.runAs(testUser) {

			Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Airline Headquarters'].Id;
			Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId);
			insert a;

			Id objectiveRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Objective__c' AND DeveloperName = 'Account'].Id;

			Objective__c o = new Objective__c();
			o.Account__c = a.Id;
			o.RecordTypeId = objectiveRecordTypeId;
			o.Name = 'testObjective';
			insert o;

			ApexPages.currentPage().getParameters().put('id',a.id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(a);
			AMP_BoardMonitoredActivitiesExtension bmaExtension  = new AMP_BoardMonitoredActivitiesExtension(stdController);

			bmaExtension.IdConcerned = o.Id;

			bmaExtension.AddNewBMA();
			bmaExtension.EditLine();
			bmaExtension.CancelEdit();
			bmaExtension.SaveLine();

			list<Objective__c> lsBMAS = bmaExtension.getBMAs();
			System.assertEquals(2,lsBMAS.size(),'There should be 2 BMAs');

			bmaExtension.IdConcerned = o.Id;
			bmaExtension.DeleteLine();
			// System.assertEquals(1,lsBMAS.size(),'There should be 1 BMA');

		}
	}
}
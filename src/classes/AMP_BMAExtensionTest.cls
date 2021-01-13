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

			Id accountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
			Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId, Sector__c='Airline', Category__c='Passenger and Cargo');
			insert a;

			Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Division');

			Objective__c o = new Objective__c();
			o.Account__c = a.Id;
			o.RecordTypeId = objectiveRecordTypeId;
			o.Name = 'testObjective';
			o.AM_Related_to_Sector__c = 'Airline';
			o.AM_Related_to_Categories__c = 'Passenger and Cargo';
			insert o;
			System.debug(o);

			ApexPages.currentPage().getParameters().put('id',a.id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(a);
			AMP_BoardMonitoredActivitiesExtension bmaExtension  = new AMP_BoardMonitoredActivitiesExtension(stdController);

			bmaExtension.IdConcerned = o.Id;

			bmaExtension.AddNewBMA();
			bmaExtension.EditLine();
			bmaExtension.CancelEdit();
			bmaExtension.SaveLine();

			bmaExtension.IdConcerned = o.Id;
			bmaExtension.EditCommentLine();
			bmaExtension.selectedComment.Status__c = 'On track';
			bmaExtension.SaveCommentLine();

			// for @AuraEnabled
			AMP_BoardMonitoredActivitiesExtension.getBMAs(a.Id);
			AMP_BoardMonitoredActivitiesExtension.getDivisionBMAs(a.Id);
			AMP_BoardMonitoredActivitiesExtension.upsertBMA(o);
			AMP_BoardMonitoredActivitiesExtension.upsertComment(bmaExtension.selectedComment);


			list<Objective__c> lsBMAS = bmaExtension.getBMAs();
			System.assertEquals(1,lsBMAS.size(),'There should be 1 BMAs');

			bmaExtension.IdConcerned = o.Id;
			bmaExtension.DeleteLine();
			// System.assertEquals(1,lsBMAS.size(),'There should be 1 BMA');

		}
	}
}
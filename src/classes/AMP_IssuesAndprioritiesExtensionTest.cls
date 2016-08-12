@isTest
private class AMP_IssuesAndprioritiesExtensionTest
{
	@isTest
	static void testIssuesAndPrioritiesListing()
	{
		// TODO: run this as a test User
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(
			// Username = 'test.username@test.com',
			// Email = 'test.username@test.com',
			// ProfileId = testProfile.Id

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

			Id objectiveRecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Account Issues and Priorities'].Id;

			Objective__c o = new Objective__c();
			o.Account__c = a.Id;
			o.RecordTypeId = objectiveRecordTypeId;
			o.Name = 'testObjective';
			o.Status__c = 'Not Started';
			o.AM_Level_of_importance__c = 'Medium';
			insert o;

			ApexPages.currentPage().getParameters().put('id',a.id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(a);
			AMP_IssuesAndPrioritiesExtension issuesAndPrioritiesExtension  = new AMP_IssuesAndPrioritiesExtension(stdController);

			List<Objective__c> lsIssuesAndPriorities =  issuesAndPrioritiesExtension.getIssuesAndPriorities();
			String s = issuesAndPrioritiesExtension.getRecordName();
			s = issuesAndPrioritiesExtension.getRecordId();
			s = issuesAndPrioritiesExtension.getJSONIssuesAndPriorities();
			// for coverage go through the void functions
			issuesAndPrioritiesExtension.sortByName();
			issuesAndPrioritiesExtension.sortByDescription();
			issuesAndPrioritiesExtension.sortByDetails();
			issuesAndPrioritiesExtension.sortByLocal();
			issuesAndPrioritiesExtension.sortByRegional();
			issuesAndPrioritiesExtension.sortByGlobal();
			issuesAndPrioritiesExtension.sortByPublic();
			issuesAndPrioritiesExtension.sortByCanIATASupport();
			issuesAndPrioritiesExtension.sortByIssueWithIATA();
			issuesAndPrioritiesExtension.sortByStatus();
			issuesAndPrioritiesExtension.sortByLevelOfImportance();

			issuesAndPrioritiesExtension.newLine();
			issuesAndPrioritiesExtension.EditLine();
			issuesAndPrioritiesExtension.SaveLine();
			issuesAndPrioritiesExtension.CancelEdit();
			issuesAndPrioritiesExtension.IdConcerned = o.Id;
			issuesAndPrioritiesExtension.DeleteLine();

			PageReference pr = issuesAndPrioritiesExtension.saveList();
			System.assertEquals(1,lsIssuesAndPriorities.size());
			try {
				o.Id = 'fakeId';
				issuesAndPrioritiesExtension.saveList();
			} catch(Exception e) {
				return;
			}
			System.assert(false, 'There should be and Exception thrown');
		}
	}
}
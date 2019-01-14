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

			Account a = new Account(name='testAccount', 
									RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline')
									);
			insert a;

			Id objectiveRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Account_Issues_and_Priorities');

			Objective__c o = new Objective__c();
			o.Account__c = a.Id;
			o.RecordTypeId = objectiveRecordTypeId;
			o.Name = 'testObjective';
			o.Status__c = 'Open';
			o.AM_Level_of_importance__c = 'Medium';
			insert o;

			Objective__c o2 = new Objective__c();
			o2.Account__c = a.Id;
			o2.RecordTypeId = objectiveRecordTypeId;
			o2.Name = 'testObjective';
			o2.Status__c = 'Open';
			o2.AM_Level_of_importance__c = 'Medium';
			insert o2;

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
			issuesAndPrioritiesExtension.sortBySource();
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
			issuesAndPrioritiesExtension.SaveList();
			issuesAndPrioritiesExtension.filterIssuesAndPriorities();
			issuesAndPrioritiesExtension.CancelEdit();
			issuesAndPrioritiesExtension.IdConcerned = o.Id;
			issuesAndPrioritiesExtension.DeleteLine();

			// for @AuraEnabled
			AMP_IssuesAndPrioritiesExtension.getIssuesAndPriorities(a.Id, null);
			AMP_IssuesAndPrioritiesExtension.upsertIssue(o2);
			AMP_IssuesAndPrioritiesExtension.deleteIssue(o2);

			PageReference pr = issuesAndPrioritiesExtension.saveList();
			System.assertEquals(2,lsIssuesAndPriorities.size(), 'There should be 2 issues');
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
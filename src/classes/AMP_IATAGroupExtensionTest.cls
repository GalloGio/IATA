@isTest
private class AMP_IATAGroupExtensionTest
{
	@isTest
	static void testIATAGroupExtension()
	{
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

			RecordType regDivRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'LocalGovernance__c' AND DeveloperName  = 'Reg_Div_Groups'];
			LocalGovernance__c lg = new LocalGovernance__c();
			lg.RecordTypeId = regDivRecordType.Id;
			// insert lg;

			// ApexPages.currentPage().getParameters().put('id',lg.id);
			ApexPages.StandardController stdController = new ApexPages.StandardController(lg);
			AMP_IATAGroupExtension iataGroupExtension  = new AMP_IATAGroupExtension(stdController);
			lg.Division__c = 'CS';
			// lg.Region__c = 'N/A';
			iataGroupExtension.mySave();
			// lg.Open_to_non_IATA_Airlines_and_Others__c = 'Yes';
			lg.Restricted_of_Participants__c = 'Yes';
			iataGroupExtension.mySave();
			// lg.Division__c = null;
			// lg.Region__c = null;
			
			// set the lookup to self to get an error
			lg.Reporting_to__c = lg.Id;
			iataGroupExtension.mySave();
		}

	}
}
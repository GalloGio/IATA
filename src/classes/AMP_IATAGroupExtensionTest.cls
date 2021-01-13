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
			
			Id accountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
			Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId);
			insert a;

			Id regDivRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Reg_Div_Groups');
			LocalGovernance__c lg = new LocalGovernance__c();
			lg.RecordTypeId = regDivRecordTypeId;
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


			// create a child group
			LocalGovernance__c lgChild = new LocalGovernance__c();
			lgChild.RecordTypeId = regDivRecordTypeId;
			lgChild.Reporting_to__c = lg.Id;
			lgChild.Active__c = true;
			insert lgChild;

			lg.Active__c = false;
			try {
				update lg;
			} catch(Exception e) {
				System.debug(e);
				System.assertEquals(true, e.getMessage().contains('cannot'), 'Deactivating a parent with active children should not be allowed');
			}
			// set the lookup to self to get an error
			lg.Reporting_to__c = lg.Id;
			iataGroupExtension.mySave();
		}

	}

	@isTest
	static void testLocalGroups()
	{
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		User testUser = New User(
			Alias = 'standt', Email='standarduser@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);

		insert testUser;

		PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
		PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = testUser.Id);
		insert psa;

		System.runAs(testUser) {
			Id accountRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
			Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId);
			insert a;

			IATA_ISO_Country__c testCountry = new IATA_ISO_Country__c(name='test', ISO_Code__c = 'te');
			insert testCountry;

			Id regDivRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Local_Groups');
			LocalGovernance__c lg = new LocalGovernance__c();
			lg.RecordTypeId = regDivRecordType;
			lg.Country__c = testCountry.Id;
			insert lg;

			LocalGovernance_Meeting__c testMeeting = new LocalGovernance_Meeting__c();
			testMeeting.Local_Governance__c = lg.Id;
			insert testMeeting;

			// create a child group
			LocalGovernance__c lgChild = new LocalGovernance__c();
			lgChild.RecordTypeId = regDivRecordType;
			lgChild.Reporting_to__c = lg.Id;
			lgChild.Active__c = true;
			insert lgChild;

			lg.Active__c = false;
			try {
				update lg;
			} catch(Exception e) {
				System.assertEquals(true, e.getMessage().contains('cannot'), 'Deactivating a parent with active children should not be allowed');
			}
			try {
				delete lg;
			} catch(Exception e) {
				System.assertEquals(true, e.getMessage().contains('cannot'), 'Deleting a parent with children should not be allowed');
			}
			try {
				delete testMeeting;
			} catch(Exception e) {
				System.assertEquals(true, e.getMessage().contains('cannot'), 'Deleting a meeting on an inactive group should not be allowed');
			}
		}

	}
}
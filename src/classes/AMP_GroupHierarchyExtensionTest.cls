@isTest
public with sharing class AMP_GroupHierarchyExtensionTest  {

	@isTest
	static void testGroupHierarchy() {
		// CREATE TEST DATA
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
			Id GroupRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Reg_Div_Groups');

			LocalGovernance__c testGroup = new LocalGovernance__c();
			testGroup.recordTypeId = GroupRecordTypeId;
			testGroup.Name = 'testGroup1';
			testGroup.Region__c = 'testGroup';
			testGroup.Division__c = 'N/A';
			insert testGroup;

			LocalGovernance__c testGroup2 = new LocalGovernance__c();
			testGroup2.recordTypeId = GroupRecordTypeId;
			testGroup2.Name = 'testGroup2';
			testGroup2.Region__c = 'testGroup2';
			testGroup2.Division__c = 'N/A';
			testGroup2.AM_Under__c = testGroup.Id;
			testGroup2.Reporting_to__c = testGroup.Id;
			insert testGroup2;


			ApexPages.StandardController std = new ApexPages.StandardController(testGroup2);
			AMP_GroupHierarchyExtension ghExtension = new AMP_GroupHierarchyExtension(std);
			String JSONHierarchy = ghExtension.JSONHierarchy;
			System.assertEquals(true, JSONHierarchy.contains('testGroup1'), 'testGroup1 should be in the hierarchy');
		}
	}

}
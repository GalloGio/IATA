@isTest
private class AMP_Groups_ParticipationControllerTest {

  @isTest static void test_controller() {
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

			// Create a new ISO Country
			IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
			insert country_qr;

			// Create an Airline HQ account
			Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
			Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
			RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
			insert acct_hq;
			Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Airline Headquarters'].Id;
			Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId);
			insert a;

			Contact testContact = new Contact();
			testContact.FirstName = 'testFirstname';
			testContact.LastName = 'testLastname';
			testContact.Email = 'testLastname@test.ts';
			testContact.Title = 'test Title';
			testContact.AccountId = acct_hq.Id;
      testContact.Function__c = 'testFunction';
      testContact.Membership_Function__c = 'testFunction';
			insert testContact;

			// List<AMPCoreGroups__c> lsCoreGroups = AMPCoreGroups__c.getAll().Values();
			AMPCoreGroups__c testCoreGroup = new AMPCoreGroups__c();
			testCoreGroup.Name = 'testGroup';
			testCoreGroup.Order__c = 0;
			insert testCoreGroup;

			AMPCoreGroups__c testCoreGroup2 = new AMPCoreGroups__c();
			testCoreGroup2.Name = 'testGroup2';
			testCoreGroup2.Order__c = 1;
			insert testCoreGroup2;

			LocalGovernance__c testGroup = new LocalGovernance__c();
			testGroup.Name = 'testGroup';
			testGroup.Region__c = 'testGroup';
			testGroup.Division__c = 'N/A';
			insert testGroup;

			LocalGovernance__c testGroup2 = new LocalGovernance__c();
			testGroup2.Name = 'testGroup2';
			testGroup2.Region__c = 'testGroup2';
			testGroup2.Division__c = 'N/A';
			testGroup2.AM_Under__c = testGroup.Id;
      testGroup2.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType='LocalGovernance__c' AND DeveloperName = 'Reg_Div_Groups'].Id;
			insert testGroup2;

			Participant__c testParticipant = new Participant__c();
			testParticipant.Contact__c = testContact.Id;
			testParticipant.Participant_Type__c = '1. Chair';
			testParticipant.Local_Governance__c = testGroup2.Id;
			testParticipant.Head_Quartier__c = acct_hq.Id;
			insert testParticipant;


        // instantiate the groups participation page controller
        ApexPages.StandardController std = new ApexPages.StandardController(acct_hq);
        AMP_Groups_ParticipationController controller = new AMP_Groups_ParticipationController(std);

        system.assertNotEquals(true, controller.lstParticipants.isEmpty());
  }
  }

}
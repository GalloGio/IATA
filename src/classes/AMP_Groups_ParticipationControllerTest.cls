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

		insert testUser;

		PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Reg_Div_Group_Owners'];
		PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = testUser.Id);
		insert psa;

		System.runAs(testUser) {

			// Create a new ISO Country
			IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
			insert country_qr;

			// Create an Airline HQ account
			Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

			Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', Sector__c = AMS_Utils.SECTOR_AIRLINE,
										Category__c = AMS_Utils.CATEGORY_PASSENGER_ONLY, RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');

			Account a = new Account(name='testAccount', RecordTypeId=AirlineHQ_RT_Id, Sector__c = AMS_Utils.SECTOR_AIRLINE, Category__c = AMS_Utils.CATEGORY_PASSENGER_ONLY);

			insert new List<Account>{ acct_hq, a};

			Contact testContact = new Contact();
			testContact.FirstName = 'testFirstname';
			testContact.LastName = 'testLastname';
			testContact.Email = 'testLastname@test.ts';
			testContact.Title = 'test Title';
			testContact.AccountId = acct_hq.Id;
			testContact.Function__c = 'Aeropolitical';
			testContact.Membership_Function__c = 'Aeropolitical';
			insert testContact;

			// List<AMPCoreGroups__c> lsCoreGroups = AMPCoreGroups__c.getAll().Values();
			AMPCoreGroups__c testCoreGroup = new AMPCoreGroups__c();
			testCoreGroup.Name = 'testGroup';
			testCoreGroup.Order__c = 0;

			AMPCoreGroups__c testCoreGroup2 = new AMPCoreGroups__c();
			testCoreGroup2.Name = 'testGroup2';
			testCoreGroup2.Order__c = 1;

			// a third group to show 'not at this time'
			AMPCoreGroups__c testCoreGroup3 = new AMPCoreGroups__c();
			testCoreGroup3.Name = 'testGroup3';
			testCoreGroup3.Order__c = 2;

			insert new List<AMPCoreGroups__c>{testCoreGroup, testCoreGroup2, testCoreGroup3};

			ID localGovernanceRecId = RecordTypeSingleton.getInstance().getRecordTypeId('LocalGovernance__c', 'Reg_Div_Groups');

			LocalGovernance__c testGroup = new LocalGovernance__c();
			testGroup.Name = 'testGroup';
			testGroup.Region__c = 'testGroup';
			testGroup.Division__c = 'N/A';
			testGroup.RecordTypeId = localGovernanceRecId;
			insert testGroup;

			LocalGovernance__c testGroup2 = new LocalGovernance__c();
			testGroup2.Name = 'testGroup2';
			testGroup2.Region__c = 'testGroup2';
			testGroup2.Division__c = 'N/A';
			testGroup2.AM_Under__c = testGroup.Id;
			testGroup2.RecordTypeId = localGovernanceRecId;
			insert testGroup2;

			LocalGovernance__c testGroup3 = new LocalGovernance__c();
			testGroup3.Name = 'testGroup3';
			testGroup3.Region__c = 'testGroup3';
			testGroup3.Division__c = 'N/A';
			testGroup3.AM_Under__c = testGroup.Id;
			testGroup3.RecordTypeId = localGovernanceRecId;
			insert testGroup3;

			Participant__c testParticipant = new Participant__c();
			testParticipant.Contact__c = testContact.Id;
			testParticipant.Participant_Type__c = '1. Chair';
			testParticipant.Local_Governance__c = testGroup.Id;
			testParticipant.Head_Quartier__c = acct_hq.Id;

			Participant__c testParticipant2 = new Participant__c();
			testParticipant2.Contact__c = testContact.Id;
			testParticipant2.Participant_Type__c = '1. Chair';
			testParticipant2.Local_Governance__c = testGroup2.Id;
			testParticipant2.Head_Quartier__c = acct_hq.Id;

			insert new List<Participant__c>{testParticipant, testParticipant2};

			// instantiate the groups participation page controller
			ApexPages.StandardController std = new ApexPages.StandardController(acct_hq);
			AMP_Groups_ParticipationController controller = new AMP_Groups_ParticipationController(std);
			String reportId = AMP_Groups_ParticipationController.getReportId();
			system.assertNotEquals(true, controller.lstParticipants.isEmpty());

  		}
  	}

}

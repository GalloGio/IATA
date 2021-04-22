// *************************************
// Vanja Djurdjevic | vanja.djurdjevic@b-i.com
// 20/11/2018
// Note: since the custom metadata entries are matched using queue id, this test
// will most likely pass when the queue Id's are intentical across orgs.
// This is like this because:
// 1) Id field can't be instantiated (predefined) when creating queue
// 2) custom metadata records creation from apex test is cumbersome (possible, but not easy)
//
// Solution: when storing information about a queue in custom metadata, refer to a queue by
// unique API name not the id. Then in test a queue with identical name is created.
// *************************************
@isTest
public class AutoAssignmentAgentToQueueTest {
	
	@TestSetup
	private static void setup() {
		Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'GCS - Staff - AI'];
		User testUser = New User(
			Alias = 'standt', Email='AutoAssignmentAgentToQueueTest@testorg.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = testProfile.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='AutoAssignmentAgentToQueueTest@test.com',
			License_Cost_Center__c = 'ISF005CH01'
		);
		insert testUser;

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','Cases_Global');
		Case currentCase= new Case(Subject='test 1', OwnerId=UserInfo.getUserId(),Status='Open', recordTypeId = recordTypeId, CaseArea__c = 'ICH');

		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule = true;
		currentCase.setOptions(dmo);
		insert currentCase;
	}

	@isTest static void agentToQueueTest() {
		user testUser = [SELECT id FROM user WHERE UserName='AutoAssignmentAgentToQueueTest@test.com'];

		case theCase = [SELECT Id, OwnerId, Owner.Type FROM case limit 1];

		system.assert(string.ValueOf(theCase.OwnerId).startsWith('00G'));
		
		System.runAs(testUser){
			Test.startTest();

			theCase.OwnerId = testUser.Id;
			update theCase;

			system.assertEquals(testUser.Id, theCase.OwnerId);

			AutoAssignmentAgentToQueue.TestType = 'reassign';
			
			Id batchJobId = Database.executeBatch(new AutoAssignmentAgentToQueue(), 5);
			Test.stopTest();

			case reQuery = [SELECT Id, OwnerId, Owner.Type FROM case limit 1];

			system.assert(string.ValueOf(reQuery.OwnerId).startsWith('00G'));
		}
	}

	@isTest static void keepAssigned() {
		user testUser = [SELECT id FROM user WHERE UserName='AutoAssignmentAgentToQueueTest@test.com'];

		case theCase = [SELECT Id, OwnerId, Owner.Type FROM case limit 1];

		system.assert(string.ValueOf(theCase.OwnerId).startsWith('00G'));
		
		System.runAs(testUser){
			Test.startTest();

			theCase.OwnerId = testUser.Id;
			update theCase;

			system.assertEquals(testUser.Id, theCase.OwnerId);

			AutoAssignmentAgentToQueue.TestType = 'keepAssigned';
			
			Id batchJobId = Database.executeBatch(new AutoAssignmentAgentToQueue(), 5);
			Test.stopTest();

			case reQuery = [SELECT Id, OwnerId, Owner.Type FROM case limit 1];

			system.assert(string.ValueOf(reQuery.OwnerId).startsWith('005'));
		}
	}
}

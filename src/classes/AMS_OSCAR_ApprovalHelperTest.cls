@isTest
private class AMS_OSCAR_ApprovalHelperTest {



	static testMethod void AMS_OSCAR_ApprovalHelper() {
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
		AMS_Oscar__c oscar = [SELECT Id FROM AMS_Oscar__c LIMIT 1];
		Id userId = UserInfo.getUserId();

		Test.startTest();

		try {
			AMS_OSCAR_ApprovalHelper.submit(null, oscar.Id, userId, 'Submission comment');
		} catch(Exception e) {
			System.assert(e.getMessage().contains('No applicable approval process was found'), e.getMessage());
			AMS_OSCAR_ApprovalHelper.submit('AMS_OSCAR_Management_Approval', oscar.Id, UserInfo.getUserId(), 'Submission comment');
		}
		Id approvalId = [SELECT Id FROM ProcessInstanceWorkItem LIMIT 1].Id;

		List<Id> workingItemIds = AMS_OSCAR_ApprovalHelper.getAllApprovals(new List<Id>{oscar.Id});
		System.assertEquals(workingItemIds[0], approvalId);

		AMS_OSCAR_ApprovalHelper.processForObject('Approve', oscar.Id, new List<Id>{userId}, 'Approval testing');

		try {
			AMS_OSCAR_ApprovalHelper.approveAll(new List<Id>{approvalId}, new List<Id>{userId}, 'Failed process');
		}catch(Exception e){
			Map<Id, ProcessInstanceStep> approvalSteps = AMS_OSCAR_ApprovalHelper.getLastApprovalSteps(new Set<Id>{Oscar.Id});
			System.assertNotEquals('Failed Process', approvalSteps.get(oscar.Id).Comments);
		}



		Test.stopTest();
	}

}

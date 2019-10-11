@isTest
private class InterviewsControllerTest {
	
	@isTest static void testGetPausedId() {
		
		String pausedId;

		Test.startTest();
		pausedId = InterviewsController.getPausedId();
		Test.stopTest();

		System.assertEquals(null, pausedId); //not possible to add flowinterview for testing
	}
	
	@isTest static void testGetInterviews() {
		
		List<FlowInterview> listFlows = new List<FlowInterview>();

		Test.startTest();
		listFlows = InterviewsController.getInterviews();
		Test.stopTest();

		System.assertEquals(0, listFlows.size()); //not possible to add flowinterview for testing
	}

	@isTest static void testDeleteInterview() {
		
		FlowInterview flowInt;

		Test.startTest();
		flowInt = InterviewsController.deleteInterview(null);
		Test.stopTest();

		System.assertEquals(null, flowInt); //not possible to add flowinterview for testing
	}
	
}
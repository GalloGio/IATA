@isTest
public class DeleteIncompletedObjectivesSchedulerTest {

	/** TEST METHODS **/
	public static testMethod void testlaunchProcess() {

		Objective__c activeObj = ObjectiveHandlerTest.getDivisionObjective();
		insert activeObj;

		Objective__c inactiveObj = ObjectiveHandlerTest.getDivisionObjective();
		inactiveObj.Division__c = '';
		insert inactiveObj;

		activeObj = [Select is_Incomplete__c from Objective__c where Id = :activeObj.Id];
		System.assert(!activeObj.is_Incomplete__c);

		inactiveObj = [Select is_Incomplete__c from Objective__c where Id = :inactiveObj.Id];
		System.assert(inactiveObj.is_Incomplete__c);


		Test.startTest();
		String cronExp = '0 0 0 15 3 ? 2022';
		String jobId = System.schedule('schedule_test_DeleteIncompletedObjectivesScheduler',
				cronExp,
				new DeleteIncompletedObjectivesScheduler());
		Test.stopTest();

		System.assert( [Select count() from Objective__c where Id = :activeObj.Id] == 1 );
		System.assert( [Select count() from Objective__c where Id = :inactiveObj.Id] == 0 );

	}

}

@IsTest
public class GADM_ActorMembershipScheduler_TEST {

	@IsTest
	private static void scheduleTest() {

		Test.startTest();

		GADM_ActorMembershipScheduler scheduler = new GADM_ActorMembershipScheduler();
		scheduler.execute(null);

		Test.stopTest();

	}

}

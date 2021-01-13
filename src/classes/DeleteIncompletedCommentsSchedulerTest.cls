@isTest
public class DeleteIncompletedCommentsSchedulerTest {

  /** TEST METHODS **/
  public static testMethod void testlaunchProcess() {

	Comment__c activeCom = new Comment__c(Division__c = 'Eastern Africa', Divisional_News__c = true);
	insert activeCom;

	Comment__c inactiveCom = new Comment__c();
	insert inactiveCom;

	activeCom = [Select Is_incomplete__c from Comment__c where Id = :activeCom.Id];
	System.assert(!activeCom.Is_incomplete__c);

	inactiveCom = [Select Is_incomplete__c from Comment__c where Id = :inactiveCom.Id];
	System.assert(inactiveCom.Is_incomplete__c);

	Test.startTest();
	String cronExp = '0 0 0 15 3 ? 2022';
	String jobId = System.schedule('schedule_test_DeleteIncompletedObjectivesScheduler',
		cronExp,
		new DeleteIncompletedCommentsScheduler());
	Test.stopTest();

	System.assert( [Select count() from Comment__c where Id = :activeCom.Id] == 1 );
	System.assert( [Select count() from Comment__c where Id = :inactiveCom.Id] == 0 );

  }

}

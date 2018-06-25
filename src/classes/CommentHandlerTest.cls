@isTest
public class CommentHandlerTest {
	
	/** TEST METHODS **/
	@isTest
	public static void testsetObjectiveInfo() {
		Objective__c objective = ObjectiveHandlerTest.getDivisionObjective();
		insert objective;
		
		Comment__c comment = new Comment__c(Parent_Objective__c = objective.Id);
		insert comment;
		
		Test.startTest();
		CommentHandler.setObjectiveInfo(comment);
		Test.stopTest();

		System.assert(comment.Region__c == objective.Region__c);
	}

}
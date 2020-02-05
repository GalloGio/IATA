@isTest
public class NewCommentControllerTest {


	/** TEST METHODS **/
	public static  void testControllerWithoutObjective() {
		Comment__c comment = new Comment__c();
		comment.Divisional_News__c = false;
		comment.Country_News__c = true;
		comment.Area__c = 'Eastern Africa';
		insert comment;

		Test.startTest();
		ApexPages.standardController stdController = new ApexPages.standardController(comment);
		NewCommentController controller = new NewCommentController(stdController);
		controller.redirect();
		Test.stopTest();
	}

	public static testMethod void testControllerWithObjective() {
		Comment__c comment = new Comment__c();
		insert comment;

		Objective__c objective = ObjectiveHandlerTest.getDivisionObjective();
		insert objective;

		Pagereference pageref = Page.NewComment;
		pageref.getParameters().put('parent',objective.Id);
		Test.setCurrentPage(pageref);

		Test.startTest();
		ApexPages.standardController stdController = new ApexPages.standardController(comment);
		NewCommentController controller = new NewCommentController(stdController);
		controller.redirect();
		Test.stopTest();
	}

}

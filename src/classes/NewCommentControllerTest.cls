@isTest
public class NewCommentControllerTest {
	
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
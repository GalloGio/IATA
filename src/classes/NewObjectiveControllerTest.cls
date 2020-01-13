@isTest
public class NewObjectiveControllerTest {


	/** TEST METHODS **/

	public static testMethod void testController() {

		Objective__c objective = ObjectiveHandlerTest.getDivisionObjective();
		insert objective;

		Pagereference pageref = Page.NewObjective;
		pageref.getParameters().put('parent',objective.Id);
		pageref.getParameters().put('recordtype','Region');
		Test.setCurrentPage(pageref);

		Test.startTest();
		ApexPages.standardController stdController = new ApexPages.standardController(objective);
		NewObjectiveController controller = new NewObjectiveController(stdController);
		controller.redirect();
		Test.stopTest();
	}

}

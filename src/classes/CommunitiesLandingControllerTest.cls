/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesLandingControllerTest {
	@IsTest public static void testCommunitiesLandingController() {
		// Instantiate a new controller with all parameters in the page
		CommunitiesLandingController controller = new CommunitiesLandingController();
		controller.forwardToStartPage();
	  }
	
	 @IsTest public static void testCommunitiesLandingControllerGDPR() {
		// Instantiate a new controller with all parameters in the page
		Test.setCurrentPageReference(new PageReference('Page.CommunitiesLanding')); 
		System.currentPageReference().getParameters().put('serviceName', Label.TECH_GDPR_Community_Name);
		CommunitiesLandingController controller = new CommunitiesLandingController();
		controller.forwardToStartPage();
	  }

	@IsTest public static void testCommunitiesLandingControllerISSP() {
		// Instantiate a new controller with all parameters in the page
		Test.setCurrentPageReference(new PageReference('Page.CommunitiesLanding')); 
		System.currentPageReference().getParameters().put('serviceName', 'ISSP');
		System.currentPageReference().getParameters().put('startUrl', 'ISSP');
		CommunitiesLandingController controller = new CommunitiesLandingController();
		controller.forwardToStartPage();

		System.currentPageReference().getParameters().put('startUrl', 'ISSP');
		controller.forwardToStartPage();

		PageReference pRef = controller.forwardToStartPage();
		string startUrl = ApexPages.currentPage().getParameters().get('startUrl');
		pRef.getParameters().get('startUrl');
	
		System.assertEquals(startUrl, 'ISSP');

	}

}
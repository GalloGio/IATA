@IsTest
public class PowerBI_Dashboard_TEST {
	@IsTest
		private static void getPageParams() {
			 Test.startTest();
			 PageReference pageRef = Page.PowerBI_Dashboard;
			 Test.setCurrentPage(pageRef);
			 ApexPages.currentPage().getParameters().put('tokenType', 'tokenType');
				ApexPages.currentPage().getParameters().put('embedUrl', 'embedUrl');
				ApexPages.currentPage().getParameters().put('accessToken', 'accessToken');
				ApexPages.currentPage().getParameters().put('objectId', 'objectId');

				PowerBI_Dashboard_CTRL pageController = new PowerBI_Dashboard_CTRL();


			 System.assertEquals(pageController.tokenType, 'tokenType');
			 System.assertEquals(pageController.embedUrl, 'embedUrl');
			 System.assertEquals(pageController.accessToken, 'accessToken');
			 System.assertEquals(pageController.objectId, 'objectId');
			 System.assertEquals(pageController.redirect(), null);
			 Test.stopTest();
		}
}

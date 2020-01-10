@isTest
public class ISSP_NewCase_RedirectControllerTest {

		public static testMethod void ISSP_NewCase_RedirectControllerTest () {
				 // Create dummy data for test purposes.
						Case myCase= new Case();
						System.debug('******************Inserting the Portal_Application_Right__c record...');

					 PageReference pageRef = Page.ISSP_NewCase_Redirection;
					 Test.setCurrentPage(pageRef);


					 ApexPages.StandardController sc = new ApexPages.StandardController(myCase);

					 ISSP_NewCase_RedirectController controller = new  ISSP_NewCase_RedirectController(sc);

					 System.assertEquals('/500/e',controller.PartnerUserAccountId());

					 //System.assertEquals(MyCase.Subject, null, '');

					 //  Case myCase = new MyController();

		 //   myCase.save();

		}
}

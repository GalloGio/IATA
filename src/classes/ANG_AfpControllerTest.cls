@isTest
public class ANG_AfpControllerTest {
	public static testMethod void test1() {
		ANG_AfpController ctl = new ANG_AfpController();
		ANG_ISSP_AfpWrapper wrapper = ctl.wrapper;
		//check if new portal, will fail for missin CS
		system.assertNotEquals(ctl.isNewPortal,true);

		ctl.isNewPortal=null; // clear lazy variable
		
		ISSP_CS__c cs = new ISSP_CS__c();
		cs.name='CS Portal Redirect';
		cs.Value__c='test';
		insert cs;


		//check if new portal, will pass after inserting missin CS
		system.assertEquals(ctl.isNewPortal,true);

		system.assertEquals(ctl.portalRedirectToIEP!=null,true);
	}
}
@isTest
public class PortalBreadcrumbCtrlTest {

	@isTest
	public static void testController_getBreadcrumbsTest() {
		Test.StartTest();

		PortalBreadcrumbCtrl.getBreadcrumbs('support');

		Test.StopTest();
	}

}

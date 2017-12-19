/**
 * Created by Paulo Bastos on 30/10/2017.
 */
@IsTest(SeeAllData = false)
private class LVA_ConsoleToolkitControllerTest {

		@testSetup static void customSettingSetup() {
			LVA_ConsoleToolkitController.initConfigs();
		}

		@IsTest
		static void test01() {
			LVA_ConsoleToolkitController test=new LVA_ConsoleToolkitController();

			System.assertNotEquals(null, LVA_ConsoleToolkitController.lvaChatConsoleAlertMode);
			System.assertNotEquals(null, LVA_ConsoleToolkitController.isChatSupervisor);
			System.assertNotEquals(null, LVA_ConsoleToolkitController.myUserId);
			System.assertNotEquals(null, LVA_ConsoleToolkitController.isAccumulative);
			System.assertNotEquals(null, LVA_ConsoleToolkitController.myUserId);
		}
}
/**
 * Created by bkaya01 on 14/08/2019.
 */

@IsTest
public class PortalForgotPasswordControllerTest {

	@isTest
	public static void unitTest(){
		PortalForgotPasswordController.configInfo result = PortalForgotPasswordController.getInitialConfig();
		PortalPasswordHandler.resultWrapper passResult   = PortalForgotPasswordController.handleResetPassword('test');
	}

}

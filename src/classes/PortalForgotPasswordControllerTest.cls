/**
 * Created by bkaya01 on 14/08/2019.
 */

@IsTest
public class PortalForgotPasswordControllerTest {

	@isTest
	public static void unitTest(){
		PortalForgotPasswordController.configInfo result = PortalForgotPasswordController.getInitialConfig();
		PortalPasswordHandler.resultWrapper passResult   = PortalForgotPasswordController.handleResetPassword('test', new Map<String,String>{'d'=>'d'});
		Boolean passResult2   = PortalForgotPasswordController.handleResetPassword2('test', new Map<String,String>{'d'=>'d'});
	}

}
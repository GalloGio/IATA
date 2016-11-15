@isTest
private class IEC_LoginControllerTest {
	
	@isTest static void test_onLoadAction() {
		//Set current page to login page
		Test.startTest();
		PageReference pageRef = Page.IEC_Login;
		Test.setCurrentPage(pageRef);

		pageRef.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter('http://www.iata.org'));
    	pageRef.getParameters().put(IECConstants.PARAM_RESETPASSWORD, IECUtil.EncryptEncodeParameter('true'));
    	pageRef.getParameters().put('doLogin', 'yes');

    	User usr = IECTestUtil.createSampleGuestUserAndLogin();

    	system.runAs(usr){

    		IEC_LoginController loginController = new IEC_LoginController();
	    	loginController.onLoadAction();

	    	system.setPassword(usr.Id,'P@$$w0rD');
	    	//cover Login
	        loginController.username = '';
	        loginController.login();
	        loginController.username = usr.Username;//'test@iata.org.test';
	        loginController.password = '';
	        loginController.login();
	        loginController.password = 'P@$$w0rD';
	        loginController.login();

	        //Cover register
	        loginController.register();

	        //Cover reset password
	        try{
	        	loginController.resetPasswordEmail = '';
	        	loginController.resetPassword();
        	}catch(Exception ex){
        		System.assert(ex.getMessage().contains('Your password could not be reseted.'), ex.getMessage());
        	}
	        
	        try{
	        	loginController.resetPasswordEmail = usr.Username;//'test@iata.org.test';
	        	loginController.resetPassword();
	        }catch(Exception ex){
	        	System.assert(ex.getMessage().contains('Your password could not be reseted.'), ex.getMessage());
	        }
	        
	        Test.stopTest();

    	}

    	
	}
	
	
	
}
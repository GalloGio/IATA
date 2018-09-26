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

    		IEC_LoginController loginController = new IEC_LoginController();
	    	//cover onLoadAction
	    	loginController.onLoadAction();
			pageRef.getParameters().remove('doLogin');
			pageRef.getParameters().put('resetPasswordEmail', usr.Email);
			loginController.onLoadAction();

	    	//cover Login
	    	system.setPassword(usr.Id,'P@$$w0rD');
	        loginController.username = '';
	        loginController.login();
	        loginController.username = usr.Username;//'test@iata.org.test';
	        loginController.password = '';
	        loginController.login();
	        loginController.password = 'P@$$w0rD';
	        loginController.login();

	        //Cover register
	        loginController.register();
        
        	//Cover redirect to iecWebDownload after login
        	pageRef.getParameters().put(IECConstants.PARAM_RETURN_URL, 'iecWebDownload');
        	loginController.login();
        
        	//Cover redirect to IEC_ViewQuotes after login
        	pageRef.getParameters().put(IECConstants.PARAM_RETURN_URL, 'IEC_ViewQuotes');
        	loginController.login();

	        //Cover reset password
	        try{
	        	loginController.resetPasswordEmail = '';
	        	loginController.resetPassword();
        	}catch(Exception ex){
        		System.assert(ex.getMessage().contains('The Username field is required'), ex.getMessage());
        	}
	        try{
	        	loginController.resetPasswordEmail = 'not_exist@z1z1z3.com';
	        	loginController.resetPassword();
        	}catch(Exception ex){
        		System.assert(ex.getMessage().contains('No eligible user found'), ex.getMessage());
        	}
	        try{
	        	loginController.resetPasswordEmail = UserInfo.getUserEmail();
	        	loginController.resetPassword();
        	}catch(Exception ex){
        		System.assert(ex.getMessage().contains('Your password could not be reseted'), ex.getMessage());
        	}
	        try{
	        	loginController.resetPasswordEmail = usr.Username;
	        	loginController.resetPassword();
	        }catch(Exception ex){
	        	System.assert(ex.getMessage().contains('Your password could not be reseted.'), ex.getMessage());
	        }
	        try{
	        	loginController.resetPasswordEmail = usr.Email;
	        	loginController.resetPassword();
	        }catch(Exception ex){
	        	System.assert(false, ex.getMessage());
	        }
	        
        Test.stopTest();
	}
	
	
	
}
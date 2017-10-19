@isTest
private class vfIECLoginComponent_tst {
    static testMethod void myUnitTest() {
    	Test.startTest();
    	
    	//Set current page to login page
    	PageReference pgRef = Page.IECLogin;
    	Test.setCurrentPage(pgRef);
    	
    	VfIECLoginComponent pgCont = new VfIECLoginComponent();

    	pgRef.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter('http://www.iata.org'));
    	pgRef.getParameters().put(IECConstants.PARAM_RESETPASSWORD, IECUtil.EncryptEncodeParameter('true'));
    	
        pgCont = new VfIECLoginComponent();
        
        //001: Login
        pgCont.sPrefillUsername = '';
        pgCont.login();
        pgCont.sPrefillUsername = 'test@iata.org.test';
        pgCont.password = '';
        pgCont.login();
        pgCont.password = 'P@$$w0rD';
        pgCont.login();
        
        //002: Register
        pgCont.register();
    
        //003: Forgot Password
        pgCont.forgotPassword();
        
        //004: Forgot Password Redirect
        pgCont.forgotPasswordRedirect();
        
        //006: Reset Password
        pgCont.resetPasswordEmail = '';
        pgCont.resetPassword();
        pgCont.resetPasswordEmail = 'test@iata.org.test';
        pgCont.resetPassword();
        
        //Misc
        Boolean bTest = pgCont.isUserLoggedIn;
        pgCont.closePopup();
        pgCont.showPopup();
    	Test.stopTest();
    }

    @isTest static void testLogin(){
        //setup test data
        VfIECLoginComponent page = new VfIECLoginComponent();
    
        //if username == null
        try{
            page.username = null;
            page.password = 'password';
            page.login();
        } catch(IECApplicationException e){
            System.assert(true);
        }

        //if username invalid email format
        try{
            page.username = 'a';
            page.password = 'password';
            page.login();
        } catch(IECApplicationException e){
            System.assert(true);
        }

        //if password = null
        try{
            page.password = null;
            page.username = 'a@b.com';
            page.login();
        } catch(IECApplicationException e){
            System.assert(true);
        }

        //if sPrefillUsername != null
        page.username = 'a@b.com';
        page.password = 'password';
        page.sPrefillUsername = 'a@b.com';
        page.login();
        
        System.assertEquals('a@b.com', page.username);
        System.assertEquals('', page.sPrefillUsername);

        //if all ok
        page.username = 'a@b.com';
        page.password = 'password';
        page.sPrefillUsername = 'a@b.com';
        System.assertEquals(null, page.login());
    }

    @isTest static void testResetPassword(){
        VfIECLoginComponent loginPage = new VfIECLoginComponent();

        //test if username = null
        loginPage.resetPasswordEmail = null;
        try{
            loginPage.resetPassword();
        } catch(IECApplicationException e){
            System.assert(true);
        }

        //test if username is of invalid email format
        loginPage.resetPasswordEmail = 'a';
        try{
            loginPage.resetPassword();
        } catch(IECApplicationException e){
            System.assert(true);
        }

        //test if username is of invalid email format
        loginPage.resetPasswordEmail = 'a.com';
        try{
            loginPage.resetPassword();
        } catch(IECApplicationException e){
            System.assert(true);
        }

        //test if username is in valid email format
        loginPage.resetPasswordEmail = 'a@b.com';
        System.assertEquals(null, loginPage.resetPassword());
        Test.setCurrentPage(loginPage);
        System.assertEquals(false, ApexPages.hasMessages());
    }
}
@isTest
public class ISSP_ForgotPasswordControllerTest {

    public static testMethod void testISSP_ForgotPasswordControllerTest() {
    	ISSP_ForgotPasswordController controller = new ISSP_ForgotPasswordController();
    	controller.username = 'test@test.test';
    	controller.forgotPassword();
    	ApexPages.currentPage().getParameters().put('Accept-Language','es');
        String lang = controller.lang;
        ApexPages.currentPage().getParameters().put('lang','es');
        lang = controller.lang;
        controller.isLogined();
    }
    
}
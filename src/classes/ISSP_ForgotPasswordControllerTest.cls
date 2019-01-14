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

    //force language to English for CNS Community
   public static testMethod void testISSP_ForgotPasswordControllerTest_CNSCommunity_setLanguage() {
               
        Test.startTest();
        	ISSP_ForgotPasswordController controller = new ISSP_ForgotPasswordController();
      		PageReference pageref = Page.ISSP_ForgotPassword;
            ApexPages.currentPage().getParameters().put('CommunityName','CNS');            
        	String lang = controller.lang;
            controller.username = 'test@testclass.testclass';
            controller.forgotPassword();             
            controller.isLogined();
            System.assertEquals('en_US', lang);
        Test.stopTest();
    }

    //Set language with cookies and CNS Community
    public static testMethod void testISSP_ForgotPasswordControllerTest_ISSComm_Cookies(){
         Test.startTest();
             ISSP_ForgotPasswordController controller = new ISSP_ForgotPasswordController();
             Test.setCurrentPage(new PageReference('ISSP_ForgotPassword'));
            
             List<Cookie> cookies = new List<Cookie>();
             cookies.add(new Cookie('lang','fr',null,-1,false));
             ApexPages.currentPage().setCookies(cookies);
             ApexPages.currentPage().getParameters().put('CommunityName','CNS');     
    		 controller = new ISSP_ForgotPasswordController();
            
            String lang = controller.lang;
            System.assertEquals('en_US', lang);
        Test.stopTest();
    }

    public static testMethod void testISSP_ForgotPasswordControllerTest_ISSCommExistingUser(){
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
        contact.Portal_User_Frozen__c = true;
        contact.email='issp_forgotPassword_test_class@testclass.testclass';
        insert contact;
        User newUser = new User(alias = 'dsfsdfds',
                                email = 'issp_forgotPassword_test_class@testclass.testclass',
                                emailencodingkey = 'UTF-8',
                                firstname = contact.firstName,
                                lastname = contact.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = contact.Id,
                                timezonesidkey = 'Asia/Dubai',
                                username = 'issp_forgotPassword_test_class.testclass.testclass@partner.iata.org',
                                PortalRole = 'Manager',
                                CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = profileId,
                                IsActive = true,
                                Portal_User_Frozen_Checkbox__c=true);
        insert newUser;

        Test.startTest();
            ISSP_ForgotPasswordController controller = new ISSP_ForgotPasswordController();
            controller.username = 'issp_forgotPassword_test_class@testclass.testclass';
            try{controller.forgotPassword(); }catch(Exception e){System.debug('error ' +e);}           
        Test.stopTest();

    }


   
}
@isTest
public class ISSP_ForgotPasswordControllerTest {
    public static testMethod void testISSP_ForgotPasswordControllerTest_ISSCommExistingUser(){
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC' LIMIT 1].Id;
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

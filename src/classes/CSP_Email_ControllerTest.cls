@isTest
public with sharing class CSP_Email_ControllerTest {

    @isTest
    static void unitTest(){
        CSP_Email_Controller controller = new CSP_Email_Controller();
        controller.getHeaderUrl();
        controller.getFirstName();
        controller.getFooterUrl();
        controller.getCommunityUrl();
        controller.getExistingContactName();
        controller.getExistingContactEmail();
        controller.getExistingContactAccount();
        controller.getExistingContactUsername();
    }
    
}
/**
 * Test the classes IFAP_ForgotPasswordController, IFAP_SiteLoginController and IFAP_SiteRegistrationController
 */
@isTest
private class IFAP_SitesTest {

    public static testMethod void testForgotPasswordController() {
        
        // Instantiate a new controller with all parameters in the page
        IFAP_ForgotPasswordController controller = new IFAP_ForgotPasswordController();
        
        // unexisting user
        controller.username = 'test@salesforce.com';        
        controller.forgotPassword(); 
        
        // existing user
        controller.username = 'amcgraw@azurgroup.ca';       
        controller.forgotPassword(); 
        
        controller.getLangItems();
        controller.getSelectedLanguage();
    }
    
    public static testMethod void testLoginController() {
        
        // Instantiate a new controller with all parameters in the page
        IFAP_SiteLoginController controller = new IFAP_SiteLoginController();
        
        controller.getLangItems();
        controller.getSelectedLanguage();
        
        controller.username = 'test@salesforce.com';
        controller.password = 'asdfasdf';       
        controller.login(); 
        
        controller.username = 'test@salesforce.com';
        controller.password = null;         
        controller.login(); 
        
        controller.username = null;
        controller.password = 'asdfasdf';       
        controller.login(); 
        
        controller.username = null;
        controller.password = null;         
        controller.login(); 
        
        controller.username = 'alexandre@iata.org.ifapnew';
        controller.password = 'welcome';        
        controller.login(); 
        
        controller.username = 'mcgrawa@iata.org';
        controller.password = 'welcome';        
        controller.login(); 
        
        Boolean bolean = controller.getHasLoggingError();
       	controller.setSelectedLanguage('Fr');
        
        PageReference controllerPage = Page.IFAP_Login;
        Cookie languageCookies = new Cookie('IFAP_PORTAL_LANG','en_US',null,-1,false);          
        controllerPage.setCookies(new Cookie[]{languageCookies});  
        Test.setCurrentPage (controllerPage);		
        
        IFAP_SiteLoginController controller2 = new IFAP_SiteLoginController();
    }
    
    public static testMethod void testRegistrationController() {
        
        Id StandardContactRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        // Instantiate a new controller with all parameters in the page
        IFAP_SiteRegistrationController controller = new IFAP_SiteRegistrationController();
        
        List<selectOption> listLang = controller.lstLanguages;
        controller.getLangItems();
        controller.getSelectedLanguage();
        
        // create test account
        Account account1 = new Account();
        account1.Name = 'Test account';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';
        account1.Type = 'IATA Cargo Agent';
        insert account1;
        
        // test #1: unexisting contact
        controller.email = 'testqwerty@salesforce.com';         
        controller.registerUser();

        // test #2: existing contact not flagged as Financial Assessment Contact
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'Contact';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = false;
        contact1.RecordTypeId = StandardContactRecordTypeId;
        insert contact1;
        controller.email = contact1.Email;      
        controller.registerUser();
       	
		
        // test #3: existing contact flagged as Financial Assessment Contact that has no user
        contact1.Financial_Assessment_Contact__c = true;
        update contact1;
        controller.registerUser();        
		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            // test #3: existing contact flagged as Financial Assessment Contact that has a user but emails do not match
            List<User> users = [Select u.Email From User u where u.ContactId = :contact1.Id];
            if (users != null && users.size() > 0) {
                users[0].Email = 'qwerty@asdf.org';
                update users[0];
                controller.email = users[0].Email;      
                controller.registerUser();
            }
            // test #4: existing user
            List<User> users2 = [Select u.Email From User u where u.IsActive = true limit 1];   // select random user
            if (users2 != null && users2.size() > 0) {
                controller.email = users2[0].Email;         
                controller.registerUser();
            }
        }     
        
    }
    
    public static testMethod void testChangeLanguageTab() {
        
        clsIFAP_Change_Language_Tab objPage = new clsIFAP_Change_Language_Tab();
        
        objPage.getSelectedLanguage();
        objPage.getLangItems();
        objPage.ChangeLanguage();
        objPage.setSelectedLanguage('ko');
        objPage.ChangeLanguage();
    }
    
    public static testMethod void testCustomEmailTemplateLookupController() {
        
        CustomEmailTemplateLookupController objController = new CustomEmailTemplateLookupController();
        
        objController.getFormTag();
        objController.getTextBox();
        
        objController.search();
    }
    
    public static testMethod void testLanguageExtensionController() {
        
        clsLanguageExtension obj = new clsLanguageExtension(null);
        
        obj.getLocale();
    }
}
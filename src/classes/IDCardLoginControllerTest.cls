@isTest
public class IDCardLoginControllerTest{

    private static IDCardTestData testData;
    
    private static IDCardLoginController idCardLoginController;
    private static PageReference controllerPage;
    private static PageReference nextPage;
    private static List<Contact> relatedContact;
    
    public static void TestIDCardLoginController() {
        
        testData = new IDCardTestData();
        
        List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();
         
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[1]);        
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[3]);
        
        insert idCardAppToInsert;
        
        Id contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[1]);        
        Id contactId3 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);
        
        relatedContact = [SELECT Id, LastName, FirstName, VER_Number__c, IATA_Code__c, Account.RecordType.Name, Account.Status__c, Date_of_Birth__c, Account.BillingCountry FROM Contact WHERE Id IN (:contactId1, :contactId3)];  
        
        List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();
         
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[1], relatedContact[0]));               
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], relatedContact[1]));        
        insert idCardToInsert;        
        System.debug('-------------------------- Contacts = ' + relatedContact[0].VER_Number__c + ' ' + relatedContact[0].Account.RecordType.Name + ' ' +  relatedContact[0].Account.Status__c +                    
                     '\n-------------------------- Contacts = ' + relatedContact[1].VER_Number__c + ' ' + relatedContact[1].Account.RecordType.Name + ' ' +  relatedContact[1].Account.Status__c);
        system.debug('Billing Country: ' + relatedContact[0].Account.BillingCountry + 'IATA_Code__c: ' + relatedContact[0].IATA_Code__c + 'FirstName: ' + relatedContact[0].FirstName);             
        system.debug('Billing Country: ' + relatedContact[1].Account.BillingCountry + 'IATA_Code__c: ' + relatedContact[1].IATA_Code__c + 'FirstName: ' + relatedContact[1].FirstName);  
        
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCardLogin;
        Test.setCurrentPage(controllerPage_NoCookies);
        IDCardLoginController idCardLogingController_NoCookies = new IDCardLoginController();
              
        // TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
        controllerPage = Page.IDCardLogin;
        controllerPage.setCookies(new Cookie[]{languageCookies});        
      Test.setCurrentPage (controllerPage);       
        idCardLoginController = new IDCardLoginController();        
      idCardLoginController.getLangItems();
    } 
   
    public static TestMethod void TestVerify(){
        TestIDCardLoginController();
        
        idCardLoginController.IATACodeLocation = '';
        
        // IATACode and VER are null
        nextPage = idCardLoginController.verify();        
        
       
        // VER is null
        idCardLoginController.IATACodeLocation = relatedContact[1].IATA_Code__c;
        nextPage = idCardLoginController.verify();
        
         // IATACode and VER are not null
        idCardLoginController.VERNumber = relatedContact[1].VER_Number__c + '';
        nextPage = idCardLoginController.verify();
        
        // VER not found
        idCardLoginController.VERNumber = '784512369';
        nextPage = idCardLoginController.verify();
        
        // VER and IATA Code no numeric
        idCardLoginController.IATACodeLocation = 'abcdefgh';       
        idCardLoginController.VERNumber = 'abcdefgh';
        nextPage = idCardLoginController.verify();     
       
        
    }
    
    public static TestMethod void TestVerifyAlternative(){
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        TestIDCardLoginController();
        
        idCardLoginController.FNAME = '';
        idCardLoginController.LNAME = '';
        idCardLoginController.IATACodeLocation2 = '';
        idCardLoginController.DOB = '';   
        // IATACode, Firstname, Lastname and Date of birth are null 
        nextPage = idCardLoginController.verifyAlternative();             
                
        controllerPage.getParameters().put('recaptcha_challenge_field','challengeTest');
        controllerPage.getParameters().put('recaptcha_response_field', 'responseTest');
    idCardLoginController.reset();
        string t = idCardLoginController.publicKey;   
        idCardLoginController.setSelectedLanguage('en_US');
        t = idCardLoginController.getSelectedLanguage();  
        idCardLoginController.FNAME = '';
        idCardLoginController.LNAME = '';
        idCardLoginController.IATACodeLocation2 = '';
        idCardLoginController.DOB = '';       
        nextPage = idCardLoginController.verifyAlternative();
         
        // Invalid Account
        Test.startTest();
        Date dateTemp = testData.IDCards_IDCardApplications[0].Date_of_Birth__c;        
        idCardLoginController.IATACodeLocation2 = testData.IDCards_IDCardApplications[0].IATA_Code__c;     
         idCardLoginController.FNAME = testData.IDCards_IDCardApplications[0].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[0].Last_Name__c; 
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();        
        nextPage = idCardLoginController.verifyAlternative();      
        
        // Multiple Agent
        dateTemp = relatedContact[1].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = relatedContact[1].IATA_Code__c;
        idCardLoginController.FNAME = relatedContact[1].FirstName;
        idCardLoginController.LNAME = relatedContact[1].LastName;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();         
        nextPage = idCardLoginController.verifyAlternative(); 
        
         // New ID Application
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCards_IDCardApplications[2].IATA_Code__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[2].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[2].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();        
        nextPage = idCardLoginController.verifyAlternative();   
        
        
      // New ID Application for limited keyAccount
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCard_keyAccounts[1].IATACode__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[2].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[2].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();        
        nextPage = idCardLoginController.verifyAlternative();       
        
        //unlimited key acocunt
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;
        idCardLoginController.IATACodeLocation2 = testData.IDCard_keyAccounts[0].IATACode__c;
        idCardLoginController.FNAME = testData.IDCards_IDCardApplications[2].First_Name__c;
        idCardLoginController.LNAME = testData.IDCards_IDCardApplications[2].Last_Name__c;
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year();        
        nextPage = idCardLoginController.verifyAlternative();       
        
        // Wrong Date of Birth format
        idCardLoginController.DOB = dateTemp.month() + '/' + dateTemp.day() + '/' + dateTemp.year() + '2';        
        nextPage = idCardLoginController.verifyAlternative();
        Test.stopTest();
    }
}
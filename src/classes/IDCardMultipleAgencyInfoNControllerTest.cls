@isTest

public class IDCardMultipleAgencyInfoNControllerTest{
    private static IDCardTestData testData;
    
    private static IDCardMultipleAgencyInfoNController iDCardMultipleAgencyInfoNController;
    private static PageReference controllerPage;
    private static PageReference nextPage;   
    
    public static void InitIDCardMultipleAgencyInfoNControllerTest() {
        
        testData = new IDCardTestData();
        
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_Portal;         
        Test.setCurrentPage(controllerPage_NoCookies);
        IDCardMultipleAgencyInfoNController iDCardMultipleAgencyInfoNController_NoCookies = new iDCardMultipleAgencyInfoNController();
              
        // TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
        controllerPage = Page.IDCard_Portal;        
        controllerPage.setCookies(new Cookie[]{languageCookies});  
        
        // Set valid account parameters for the page.  
        Datetime dateTemp = testData.IDCards_IDCardApplications[0].Date_of_Birth__c; 
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));    
        controllerPage.getParameters().put('myaction', IDCardUtil.APPLICATIONTYPE_REPLACEMENT);
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[1].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[1].First_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[1].Last_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(dateTemp.format('yyyy-MM-dd')));
        Test.setCurrentPage (controllerPage);       
        iDCardMultipleAgencyInfoNController = new IDCardMultipleAgencyInfoNController();
        // Next page
        nextPage = iDCardMultipleAgencyInfoNController.next(); 
        
        // Set valid account parameters for the page.  
        dateTemp = testData.IDCards_IDCardApplications[0].Date_of_Birth__c; 
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));       
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[1].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[1].First_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[1].Last_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(dateTemp.format('yyyy-MM-dd')));
        Test.setCurrentPage (controllerPage);       
        iDCardMultipleAgencyInfoNController = new IDCardMultipleAgencyInfoNController();
        // Next page
        nextPage = iDCardMultipleAgencyInfoNController.next();
        
        // Set valid account parameters for the page.  
        dateTemp = testData.IDCards_IDCardApplications[0].Date_of_Birth__c; 
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));       
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[4].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[4].First_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[4].Last_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(dateTemp.format('yyyy-MM-dd')));
        controllerPage.getParameters().put('selected', '003R000000m7o96');
        controllerPage.getParameters().put('myaction', IDCardUtil.APPLICATIONTYPE_REPLACEMENT);
        Test.setCurrentPage (controllerPage);       
        iDCardMultipleAgencyInfoNController = new IDCardMultipleAgencyInfoNController();
        // Next page
        nextPage = iDCardMultipleAgencyInfoNController.next(); 
        
        //Test LangItems, HasError and getErrMsg
        iDCardMultipleAgencyInfoNController.getLangItems();        
        String testString = iDCardMultipleAgencyInfoNController.getErrMsg();
        testString = iDCardMultipleAgencyInfoNController.NewApp;
        Integer testInteger = iDCardMultipleAgencyInfoNController.nbrContactsFound;
        List<SelectOption> tempSelectOption = iDCardMultipleAgencyInfoNController.getItems();
        iDCardMultipleAgencyInfoNController.showPopup();
        iDCardMultipleAgencyInfoNController.closePopup();
    } 
    
     public static TestMethod void TestNext(){
        InitIDCardMultipleAgencyInfoNControllerTest();
        
        // Test selectedLanguage()           
        iDCardMultipleAgencyInfoNController.setSelectedLanguage('en_US');
        string t = iDCardMultipleAgencyInfoNController.getSelectedLanguage();  
         
        // Next page
        nextPage = iDCardMultipleAgencyInfoNController.next(); 
         
        //Next with a selected contact        
         controllerPage.getParameters().put('selected', '003R000000m7o96');
        controllerPage.getParameters().put('myaction', IDCardUtil.APPLICATIONTYPE_NEW);
        nextPage = iDCardMultipleAgencyInfoNController.next();        
         
         
         
         //test  public class cContact 
       ID_Card__c c = new ID_Card__c();
         iDCardMultipleAgencyInfoNController.cContact ccont = new iDCardMultipleAgencyInfoNController.cContact(c); 
         boolean v = ccont.valid;
         ID_Card__c cc = ccont.con;
         string s = ccont.selected;
         //Account a = ccont.acc;
         
         c.Name_on_ID_Card__c = 'TestSubject';
         c.Agency_IATA_Code__c = '123';
         
         insert c;
         
         ID AgencyRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
         Account theAccount = new Account(name ='testAgency',
                                      IATACode__c = '123',
                                      Status__c = 'Approved',
                                      Is_AIMS_Account__c = true,
                                      Type = 'Domestic Agent',
                                      recordtypeID = AgencyRT);
                                    
         insert theAccount;
         
         Contact contact = new Contact(Email='test@email.com', FirstName='test', LastName='test', AccountId = theAccount.Id);
         
         insert contact;
         
         c.Related_Contact__c = contact.Id;
         
         iDCardMultipleAgencyInfoNController.cContact ccont2 = new iDCardMultipleAgencyInfoNController.cContact(c);
         
         theAccount.ShippingCity = 'Lisbon';
         update theAccount;
         
         iDCardMultipleAgencyInfoNController.cContact ccont3 = new iDCardMultipleAgencyInfoNController.cContact(c);
     
     }
    
}
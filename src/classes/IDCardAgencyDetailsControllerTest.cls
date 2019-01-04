/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
public class IDCardAgencyDetailsControllerTest{
    
    private static IDCardTestData testData;
    
    private static IDCardAgencyDetailsController iDCardAgencyDetailsController;
    private static PageReference controllerPage;
    private static PageReference nextPage;   
    
    public static void InitIDCardAgencyDetailsControllerTest() {
        
        testData = new IDCardTestData();
        
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_Agency_Details;
        Test.setCurrentPage(controllerPage_NoCookies);
        IDCardAgencyDetailsController iDCardAgencyDetailsController_NoCookies = new IDCardAgencyDetailsController();
              
        // TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
        controllerPage = Page.IDCard_Agency_Details;        
        controllerPage.setCookies(new Cookie[]{languageCookies});  
        // Set Inactive account parameters for the page.  
        Datetime dateTemp = testData.IDCards_IDCardApplications[0].Date_of_Birth__c; 
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));       
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[0].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[0].First_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[0].Last_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(dateTemp.format('yyyy-MM-dd')));
        Test.setCurrentPage (controllerPage);       
        iDCardAgencyDetailsController = new IDCardAgencyDetailsController();        
        
        // Set valid account parameters for the page.  
        controllerPage = Page.IDCard_Agency_Details;        
        controllerPage.setCookies(new Cookie[]{languageCookies});
        dateTemp = testData.IDCards_IDCardApplications[2].Date_of_Birth__c;         
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));
        controllerPage.getParameters().put(IDCardUtil.PARAM_FNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].First_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_LNAME, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Last_Name__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_DOB, IDCardUtil.EncryptEncodeParameter(dateTemp.format('yyyy-MM-dd')));                   
        Test.setCurrentPage (controllerPage);       
        iDCardAgencyDetailsController = new IDCardAgencyDetailsController();  
        
        //Test LangItems, HasError and getErrMsg
        iDCardAgencyDetailsController.getLangItems();
        iDCardAgencyDetailsController.getHasError();
        iDCardAgencyDetailsController.getErrMsg();
    }
    
    public static TestMethod void TestNext(){
        InitIDCardAgencyDetailsControllerTest();
        
        // Test selectedLanguage()           
        iDCardAgencyDetailsController.setSelectedLanguage('en_US');
        string t = iDCardAgencyDetailsController.getSelectedLanguage(); 

         Account acc = new Account(Name ='testAccount',
            IATACode__c = testData.IDCards_IDCardApplications[0].IATA_Code__c,
            ID_Card_KeyAccount_features__c = 'Prohibit Applicant to Apply',
            RecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
            Status__c = 'Listed',
            IDCard_Key_Account__c = true);
        insert acc;

        iDCardAgencyDetailsController.theAccount = acc;
         
        // Next page
        nextPage = iDCardAgencyDetailsController.next();      
    }
    
    public static TestMethod void TestPrevious(){
        InitIDCardAgencyDetailsControllerTest();      
         
        // Login page
        nextPage = iDCardAgencyDetailsController.previous();      
    }
    
    public static TestMethod void TestPopUp(){
        InitIDCardAgencyDetailsControllerTest();      
        
        Account acc = new Account(Name ='testAccount',
            IATACode__c = testData.IDCards_IDCardApplications[0].IATA_Code__c,
            ID_Card_KeyAccount_features__c = 'Prohibit Applicant to Apply',
            RecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
            Status__c = 'Listed');
        insert acc;
        Contact con = new Contact(FirstName = 'test',
            LastName = 'test',
            Email = 'ISSP_test@test.test',
            AccountId = acc.Id,
            VER_Number_2__c = '546');
        insert con;
        Managed_agency__c ma = new Managed_agency__c(Account__c = acc.Id,
            Contact__c = con.Id,
            Delegate__c = false);
        insert ma;

        iDCardAgencyDetailsController.theAccount = acc;
        iDCardAgencyDetailsController.showPopup();
        iDCardAgencyDetailsController.closePopup();
        nextPage = iDCardAgencyDetailsController.next();     
    }
    
    public static TestMethod void TestAccountAddress(){
         InitIDCardAgencyDetailsControllerTest();      
         
        iDCardAgencyDetailsController.showPopup();
        
         Account acc = new Account(name ='testAccount');
         iDCardAgencyDetailsController.ShippingAddress sAddr = new iDCardAgencyDetailsController.ShippingAddress(acc);
         
         acc.ShippingCity = 'Lisbon';
         sAddr = new iDCardAgencyDetailsController.ShippingAddress(acc);
    }

    public static TestMethod void TestKeyAccount(){
        InitIDCardAgencyDetailsControllerTest();

        Boolean keyAccount = iDCardAgencyDetailsController.isKeyAccount_override('159', '546');

        Test.startTest();
        Account acc = new Account(Name ='testAccount', IATACode__c = '159');
        insert acc;
        Contact con = new Contact(FirstName = 'test', LastName = 'test', Email = 'ISSP_test@test.test', AccountId = acc.Id, VER_Number_2__c = '546');
        insert con;
        Test.stopTest();

        keyAccount = iDCardAgencyDetailsController.isKeyAccount_override('159', '546');
    }

    public static TestMethod void TestRefresh(){
        InitIDCardAgencyDetailsControllerTest();      
        
        nextPage = iDCardAgencyDetailsController.refresh();      
    }

}
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
public class IDCard_CheckoutConfirmationTest{
    
    private static IDCardTestData testData;
    
  	private static IDCard_CheckoutConfirmation iDCard_CheckoutConfirmation;
    private static PageReference controllerPage;
    private static PageReference nextPage;   
    
    public static void InitIDCard_CheckoutConfirmationTest() {
     	
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');

        testData = new IDCardTestData();
        testData.IDCards_IDCardApplications[2].IDCard_Prefered_Language__c = 'fr';
        testData.IDCards_IDCardApplications[2].IDCard_Expedite_Delivery_Fee__c = 135;
        testData.IDCards_IDCardApplications[2].RecordTypeId = recordTypeId;

        testData.IDCards_IDCardApplications[3].RecordTypeId = recordTypeId;

        testData.IDCards_IDCardApplications[5].RecordTypeId = recordTypeId;

        testData.IDCards_IDCardApplications[6].RecordTypeId = recordTypeId;

        Test.startTest();
        insert testData.IDCards_IDCardApplications[2];
        insert testData.IDCards_IDCardApplications[3];
        insert testData.IDCards_IDCardApplications[5];
        insert testData.IDCards_IDCardApplications[6];
        Test.stopTest();
        
        ID_Card_Application__c testData_IDCardApplication1 = [Select Name from ID_Card_Application__c where Id =: testData.IDCards_IDCardApplications[2].Id];
        
        string t;
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_CheckoutConfirmation;
        Test.setCurrentPage(controllerPage_NoCookies);
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();
              
        // TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);

        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put(IDCardUtil.ISFOC, IDCardUtil.EncryptEncodeParameter('13.31'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '100');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');

        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();

        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put(IDCardUtil.ISFOC, IDCardUtil.EncryptEncodeParameter('13.31'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '101');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
     
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('true'));
        controllerPage.getParameters().put(IDCardUtil.ISFOC, IDCardUtil.EncryptEncodeParameter('0.00.'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '100');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '101');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '102');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '200');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '201');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '203');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '211');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();
        
        controllerPage = Page.IDCard_CheckoutConfirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});      
        controllerPage.getParameters().put('req_reference_number', testData_IDCardApplication1.Name);
        controllerPage.getParameters().put(IDCardUtil.ISPAYMENTBYCHEQUE, IDCardUtil.EncryptEncodeParameter('false'));
        controllerPage.getParameters().put('auth_amount','358');
        controllerPage.getParameters().put('req_currency', 'CAD');
        controllerPage.getParameters().put('decision', 'accept');
        controllerPage.getParameters().put('reason_Code', '400');
        controllerPage.getParameters().put('card_accountNumber', '');
        controllerPage.getParameters().put('transaction_id', '');
        controllerPage.getParameters().put('auth_time', '2012-09-07T102740Z');
        
        Test.setCurrentPage (controllerPage);       
        iDCard_CheckoutConfirmation = new IDCard_CheckoutConfirmation();    
        nextPage = iDCard_CheckoutConfirmation.interpretDecision();
        iDCard_CheckoutConfirmation.refreshCaseNumber();
        nextPage = iDCard_CheckoutConfirmation.terminate();

                       
        
        //Test LangItems, HasError and getErrMsg
    	iDCard_CheckoutConfirmation.getLangItems();
        iDCard_CheckoutConfirmation.setSelectedLanguage('en_US');
        t = iDCard_CheckoutConfirmation.getSelectedLanguage();      
       
        
    }
    
    public static TestMethod void TestProcess(){
        InitIDCard_CheckoutConfirmationTest();    
    }    
}
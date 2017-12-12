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
public class IDCard_ReplacementNewAgencyInfoCntrTest{

    private static IDCardTestData testData;
    
  	private static IDCard_ReplacementNewAgencyInfoCntlr iDCard_ReplacementNewAgencyInfoCntlr;
    private static PageReference controllerPage;
    private static PageReference nextPage;   
    
    public static void InitIDCard_ReplacementNewAgencyInfoCntlrTest() {
        
        testData = new IDCardTestData();
       	String applicationId = '';
        
        insert testData.IDCards_IDCardApplications[3];
        List<RecordType> rtid = [select id from RecordType where developername= 'IATA_Agency' limit 1];
        Account account1 = new Account();
        account1.Name = 'Test account 1';
        account1.IATACode__c = '3791852';
        account1.Type = 'IATA Cargo Agent';
        account1.BillingCity = 'Lisboa';
        account1.BillingCountry = 'Portugal';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';
        account1.Location_Class__c = 'C';
        account1.Purge_Flag__c = false;
        account1.RecordType = rtid[0];
        insert account1;

        Contact cont = new Contact();
            cont.FirstName = 'testFirst';
            cont.LastName = 'testLast';
            cont.Title = 'not-CEO';
            cont.Email = 'cont@testAccount.com';
            cont.AccountId = account1.Id;
            cont.VER_Number_2__c = '1111111';
            // cont.Function__c = 'testFunction';
            insert cont;
        
        
        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_Replacement_Confirmation;
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter('NoId'));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Type_of_application__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));       
        Test.setCurrentPage(controllerPage_NoCookies);
        iDCard_ReplacementNewAgencyInfoCntlr = new IDCard_ReplacementNewAgencyInfoCntlr();
       
              
       	// TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
        controllerPage = Page.IDCard_Replacement_Confirmation;        
        controllerPage.setCookies(new Cookie[]{languageCookies});  
        
         // Set Page parameters with wrong IATA Code and call Replace and Renew function                 
        controllerPage.setCookies(new Cookie[]{languageCookies});   
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Type_of_application__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter('3791852'));
        controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));        
    	Test.setCurrentPage (controllerPage);  
        // Testing with a new IATA Code
        iDCard_ReplacementNewAgencyInfoCntlr = new IDCard_ReplacementNewAgencyInfoCntlr();
        iDCard_ReplacementNewAgencyInfoCntlr.NewAgencyCode = '4242424';
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Verify();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Confirm();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.back();
        iDCard_ReplacementNewAgencyInfoCntlr.showPopup();
        iDCard_ReplacementNewAgencyInfoCntlr.closePopup();
        iDCard_ReplacementNewAgencyInfoCntlr.refresh();
        
        // Set Page parameters and call Replace and Renew function                 
        controllerPage.setCookies(new Cookie[]{languageCookies});   
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
        controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Type_of_application__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));        
    	Test.setCurrentPage (controllerPage);  
        // Testing with a new IATA Code
        iDCard_ReplacementNewAgencyInfoCntlr = new IDCard_ReplacementNewAgencyInfoCntlr();
        iDCard_ReplacementNewAgencyInfoCntlr.NewAgencyCode = '4242424';
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Verify();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Confirm();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.back();
        // Testing with the same IATA Code
        iDCard_ReplacementNewAgencyInfoCntlr.NewAgencyCode = testData.IDCards_IDCardApplications[3].IATA_Code__c;
       	nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Verify();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Confirm();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.back();
        // Testing with a blank IATA Code
        iDCard_ReplacementNewAgencyInfoCntlr.NewAgencyCode = '';
       	nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Verify();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Confirm();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.back();
        // Testing with a wrong IATA Code
        iDCard_ReplacementNewAgencyInfoCntlr.NewAgencyCode = '3791852';
       	nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Verify();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.Confirm();
        nextPage = iDCard_ReplacementNewAgencyInfoCntlr.back();
        //Test LangItems, HasError and getErrMsg
    	iDCard_ReplacementNewAgencyInfoCntlr.getLangItems();
       
    } 
    
     public static TestMethod void TestReplaceRenew(){
        InitIDCard_ReplacementNewAgencyInfoCntlrTest();
        
        // Test selectedLanguage()           
        IDCard_ReplacementNewAgencyInfoCntlr.setSelectedLanguage('en_US');
        string t = iDCard_ReplacementNewAgencyInfoCntlr.getSelectedLanguage();     
     
     }
  

}
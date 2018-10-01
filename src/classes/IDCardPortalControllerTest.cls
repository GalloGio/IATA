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
public class IDCardPortalControllerTest {


    private static IDCardTestData testData;

    private static IDCardPortalController iDCardPortalController;
    private static PageReference controllerPage;
    private static PageReference nextPage;

    /*public static void InitIDCardPortalControllerTest() {

        testData = new IDCardTestData();

        List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();
        ID_Card_Application__c idCardApplicationClone = testData.IDCards_IDCardApplications[1].clone();
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[1]);
        idCardAppToInsert.add(idCardApplicationClone);
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[3]);

        insert idCardAppToInsert;

        Id contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[1]);
        Id contactId2 = IDCardUtil.CreateContactWhenNewCardIsApproved(idCardApplicationClone);
        Id contactId3 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);

        List<Contact> relatedContact = [SELECT Id, LastName, FirstName, VER_Number__c FROM Contact WHERE Id IN (:contactId1, :contactId2, :contactId3)];


        List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();

        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[1], relatedContact[0]));
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(idCardApplicationClone, relatedContact[1]));
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], relatedContact[2]));
        insert idCardToInsert;

        // Test page without cookies
        PageReference controllerPage_NoCookies = Page.IDCard_Portal;
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));
        Test.setCurrentPage(controllerPage_NoCookies);
        IDCardPortalController iDCardPortalController_NoCookies = new IDCardPortalController();
        iDCardPortalController_NoCookies.next();

        // TestPage with cookies
        Cookie languageCookies = new Cookie('idcard_portal_lang', 'en_US', null, -1, false);
        controllerPage = Page.IDCard_Portal;
        controllerPage.setCookies(new Cookie[] {languageCookies});

        // Set valid account parameters for the page.
        controllerPage = Page.IDCard_Portal;
        controllerPage.setCookies(new Cookie[] {languageCookies});
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
        Test.setCurrentPage (controllerPage);
        iDCardPortalController = new IDCardPortalController();
        nextPage = iDCardPortalController.next();

        // Select a Type of Application to pass
        controllerPage = Page.IDCard_Portal;
        controllerPage.setCookies(new Cookie[] {languageCookies});
        controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
        controllerPage.getParameters().put('myaction', IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));
        Test.setCurrentPage (controllerPage);
        iDCardPortalController = new IDCardPortalController();
        nextPage = iDCardPortalController.next();

        //Test LangItems, HasError and getErrMsg
        iDCardPortalController.getLangItems();
        Boolean testBoolean = iDCardPortalController.hasError;
        String testString = iDCardPortalController.errMsg;

        iDCardPortalController.admContact();
        iDCardPortalController.admPendingApps();
        iDCardPortalController.admPayments();

    }*/

    public static TestMethod void TestNext() {
        testData = new IDCardTestData();

        Test.startTest();
        
        List<ID_Card_Application__c> idCardAppToInsert = new List<ID_Card_Application__c>();
        ID_Card_Application__c idCardApplicationClone = testData.IDCards_IDCardApplications[1].clone();
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[1]);
        idCardAppToInsert.add(idCardApplicationClone);
        idCardAppToInsert.add(testData.IDCards_IDCardApplications[3]);

        insert idCardAppToInsert;

        Contact contactId1 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[1]);
        Contact contactId2 = IDCardUtil.CreateContactWhenNewCardIsApproved(idCardApplicationClone);
        Contact contactId3 = IDCardUtil.CreateContactWhenNewCardIsApproved(testData.IDCards_IDCardApplications[3]);

        List<Contact> relatedContact = new List<Contact>();
        relatedContact.add(contactId1);
        relatedContact.add(contactId2);
        relatedContact.add(contactId3);
        system.debug('Related Contact: ' + relatedContact);
        List<ID_Card__c> idCardToInsert = new List<ID_Card__c>();

        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[1], relatedContact[0]));
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(idCardApplicationClone, relatedContact[1]));
        idCardToInsert.add(IDCardUtil.CreateIDCardObjectFromApplication(testData.IDCards_IDCardApplications[3], relatedContact[2]));
        idCardToInsert[2].Card_Status__c = IDCardUtil.CARDSTATUS_VALID;
        insert idCardToInsert;

        // Test page without cookies
        system.debug('***TESTE***');
        PageReference controllerPage_NoCookies = Page.IDCard_Portal;
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
        system.debug('ver numbere: ' + testData.IDCards_IDCardApplications[3].VER_Number__c);
        controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
        Test.setCurrentPage(controllerPage_NoCookies);



        IDCardPortalController iDCardPortalController_NoCookies = new IDCardPortalController();
        //controllerPage_NoCookies.getParameters().put('myaction', IDCardUtil.APPLICATIONTYPE_REPLACEMENT);
        nextPage = iDCardPortalController_NoCookies.next();

        controllerPage_NoCookies.getParameters().put('myaction', IDCardUtil.APPLICATIONTYPE_REPLACEMENT);
        nextPage = iDCardPortalController_NoCookies.next();


        //Test.setCurrentPage(nextPage);

        // Next page
        try {
            iDCardPortalController_NoCookies.admContact();
        } catch (Exception e) {
        }

        try {
            iDCardPortalController_NoCookies.admPendingApps();
        } catch (Exception e) {
        }
        try {
            iDCardPortalController_NoCookies.admPayments();
        } catch (Exception e) {
        }

        Test.stopTest();
    }
}
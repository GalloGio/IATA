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
public class IDCard_Replacement_Conf_ControllerTest{


	private static IDCardTestData testData;

  	private static IDCard_Replacement_Conf_Controller iDCard_Replacement_Conf_Controller;
	private static PageReference controllerPage;
	private static PageReference nextPage;

	public static void InitIDCard_Replacement_Conf_ControllerTest() {

		testData = new IDCardTestData();
	   	String applicationId = '';

		insert testData.IDCards_IDCardApplications[3];


		// Test page without cookies
		PageReference controllerPage_NoCookies = Page.IDCard_Replacement_Confirmation;
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter('NoId'));
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Type_of_application__c));
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));
		Test.setCurrentPage(controllerPage_NoCookies);
		IDCard_Replacement_Conf_Controller iDCard_Replacement_Conf_Controller_NoCookies = new IDCard_Replacement_Conf_Controller();


	   	// TestPage with cookies
		Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
		controllerPage = Page.IDCard_Replacement_Confirmation;
		controllerPage.setCookies(new Cookie[]{languageCookies});

		// Set Page parameters and call Replace and Renew function
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Type_of_application__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
		Test.setCurrentPage (controllerPage);
		iDCard_Replacement_Conf_Controller = new IDCard_Replacement_Conf_Controller();
		nextPage = iDCard_Replacement_Conf_Controller.Replace();
		nextPage = iDCard_Replacement_Conf_Controller.Renew();
		nextPage = iDCard_Replacement_Conf_Controller.back();

		//Test LangItems, HasError and getErrMsg
		iDCard_Replacement_Conf_Controller.getLangItems();
		Boolean testBoolean = iDCard_Replacement_Conf_Controller.getHasError();
		String testString = iDCard_Replacement_Conf_Controller.getErrMsg();
	}

	 public static TestMethod void TestReplaceRenew(){
		InitIDCard_Replacement_Conf_ControllerTest();

		// Test selectedLanguage()
		iDCard_Replacement_Conf_Controller.setSelectedLanguage('en_US');
		string t = iDCard_Replacement_Conf_Controller.getSelectedLanguage();

	 }


}

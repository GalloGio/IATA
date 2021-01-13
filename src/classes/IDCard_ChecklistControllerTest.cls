@isTest
public class IDCard_ChecklistControllerTest{

	private static IDCardTestData testData;

	private static IDCard_ChecklistController iDCard_ChecklistController;
	private static PageReference controllerPage;
	private static PageReference nextPage;

	public static void InitIDCard_ChecklistControllerTest() {

		testData = new IDCardTestData();
		String applicationId = '';

		insert testData.IDCards_IDCardApplications[3];


		// Test page without cookies
		PageReference controllerPage_NoCookies = Page.IDCard_Checklist;
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter('NoId'));
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].IATA_Code__c));
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Type_of_application__c));
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter('1111111'));
		Test.setCurrentPage(controllerPage_NoCookies);
		iDCard_ChecklistController = new IDCard_ChecklistController();


		// TestPage with cookies
		Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
		controllerPage = Page.IDCard_Checklist;
		controllerPage.setCookies(new Cookie[]{languageCookies});


		// Set Page parameters and call Next function
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_NEW));
		controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
		Test.setCurrentPage (controllerPage);
		// Testing New Application 
		iDCard_ChecklistController = new IDCard_ChecklistController();
		nextPage = iDCard_ChecklistController.next();
		// Testing New Application 

		// Set Page parameters and call Next function
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));
		controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
		Test.setCurrentPage (controllerPage);
		// Testing Replacement 
		iDCard_ChecklistController = new IDCard_ChecklistController();
		nextPage = iDCard_ChecklistController.next();
		nextPage = iDCard_ChecklistController.back();
		// Testing Replacement 

		//Test LangItems, HasError and getErrMsg
		iDCard_ChecklistController.getLangItems();

	}

	 public static TestMethod void TestLanguage(){
		InitIDCard_ChecklistControllerTest();

		// Test selectedLanguage()
		iDCard_ChecklistController.setSelectedLanguage('en_US');
		string t = iDCard_ChecklistController.getSelectedLanguage();

	 }


}

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
		// Testing New Application with a Picture Checkbox not checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = false;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();
		// Testing New Application with all checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();



		// Set Page parameters and call Next function
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REPLACEMENT));
		controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
		Test.setCurrentPage (controllerPage);
		// Testing Replacement with a Proof of Employment not checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = false;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();
		// Testing Replacement with with all checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();
		nextPage = iDCard_ChecklistController.back();
		// Set Page parameters and call Next function
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_RENEWAL));
		controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
		Test.setCurrentPage (controllerPage);
		// Testing Renewal with a Proof of Name not checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = false;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();
		nextPage = iDCard_ChecklistController.back();
		// Testing Renewal with with all checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();
		nextPage = iDCard_ChecklistController.back();

		// Set Page parameters and call Next function
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPLICATIONTYPE, IDCardUtil.EncryptEncodeParameter(IDCardUtil.APPLICATIONTYPE_REISSUE));
		controllerPage.getParameters().put(IDCardUtil.PARAM_IATACODE, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].IATA_Code__c));
		controllerPage.getParameters().put(IDCardUtil.PARAM_VER, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].VER_Number__c));
		Test.setCurrentPage (controllerPage);
		// Testing Reissue with Credit Card Information not checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = false;
		nextPage = iDCard_ChecklistController.next();
		nextPage = iDCard_ChecklistController.back();
		// Testing Reissue with with all checked
		iDCard_ChecklistController = new IDCard_ChecklistController();
		iDCard_ChecklistController.isPictureOptionChecked  = true;
		iDCard_ChecklistController.isProofEmploymentOptionChecked  = true;
		iDCard_ChecklistController.isProofNameOptionChecked  = true;
		iDCard_ChecklistController.isCreditCardOptionChecked  = true;
		nextPage = iDCard_ChecklistController.next();
		nextPage = iDCard_ChecklistController.back();
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

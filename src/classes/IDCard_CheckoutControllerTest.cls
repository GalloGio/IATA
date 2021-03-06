@isTest
public class IDCard_CheckoutControllerTest{

	public static TestMethod void InitIDCard_CheckoutControllerTest() {

		IDCardTestData testData = new IDCardTestData();
		insert testData.IDCards_IDCardApplications[2];
		insert testData.IDCards_IDCardApplications[3];
		insert testData.IDCards_IDCardApplications[5];
		insert testData.IDCards_IDCardApplications[6];
		string t;
		// Test page without cookies
		PageReference controllerPage_NoCookies = Page.IDCard_Checkout;
		Test.setCurrentPage(controllerPage_NoCookies);
		IDCard_CheckoutController iDCard_CheckoutController_NoCookies = new IDCard_CheckoutController();

		// TestPage with cookies
		Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
		PageReference controllerPage = Page.IDCard_Checkout;
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[2].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_ERRMSG, IDCardUtil.EncryptEncodeParameter('Error'));
		Test.setCurrentPage (controllerPage);
		IDCard_CheckoutController iDCard_CheckoutController = new IDCard_CheckoutController();
		PageReference nextPage = iDCard_CheckoutController.buyNow();
		nextPage = iDCard_CheckoutController.payByCheque();
		nextPage = iDCard_CheckoutController.back();
		t = iDCard_CheckoutController.confirmationString;

		controllerPage = Page.IDCard_Checkout;
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[3].Id));
		Test.setCurrentPage (controllerPage);
		iDCard_CheckoutController = new IDCard_CheckoutController();
		nextPage = iDCard_CheckoutController.buyNow();
		nextPage = iDCard_CheckoutController.payByCheque();
		nextPage = iDCard_CheckoutController.back();
		t = iDCard_CheckoutController.confirmationString;

		controllerPage = Page.IDCard_Checkout;
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[5].Id));
		Test.setCurrentPage (controllerPage);
		iDCard_CheckoutController = new IDCard_CheckoutController();
		 nextPage = iDCard_CheckoutController.buyNow();
		nextPage = iDCard_CheckoutController.payByCheque();
		nextPage = iDCard_CheckoutController.back();
		t = iDCard_CheckoutController.confirmationString;

		controllerPage = Page.IDCard_Checkout;
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[6].Id));
		Test.setCurrentPage (controllerPage);
		iDCard_CheckoutController = new IDCard_CheckoutController();
		nextPage = iDCard_CheckoutController.buyNow();
		nextPage = iDCard_CheckoutController.payByCheque();
		nextPage = iDCard_CheckoutController.back();
		t = iDCard_CheckoutController.confirmationString;

		//Test LangItems, HasError and getErrMsg
		iDCard_CheckoutController.getLangItems();
		iDCard_CheckoutController.setSelectedLanguage('en_US');
		t = iDCard_CheckoutController.getSelectedLanguage();
		t = iDCard_CheckoutController.confirmationString;

		Boolean b = iDCard_CheckoutController.IsExpediteDeliveryAddedtoIDCardPrice;

		//iDCard_CheckoutController.IsExpediteDeliveryAddedtoIDCardPrice = true;
		iDCard_CheckoutController.CanPayByCheque = true;
		nextPage = iDCard_CheckoutController.payByCheque();
		t = iDCard_CheckoutController.confirmationString;

	}

	public static TestMethod void InitIDCard_SingleCheckoutControllerTest() {

		IDCardTestData testData = new IDCardTestData();
		insert testData.IDCards_IDCardApplications[7];
		string t;
		// Test page without cookies
		PageReference controllerPage_NoCookies = Page.IDCard_CheckoutSingleApplication;
		controllerPage_NoCookies.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[7].Id));
		Test.setCurrentPage(controllerPage_NoCookies);
		IDCard_CheckoutSingleApplication ctrl = new IDCard_CheckoutSingleApplication();

		// TestPage with cookies
		Cookie languageCookies = new Cookie('idcard_portal_lang','en_US',null,-1,false);
		PageReference controllerPage = Page.IDCard_Checkout;
		controllerPage.setCookies(new Cookie[]{languageCookies});
		controllerPage.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(testData.IDCards_IDCardApplications[7].Id));
		controllerPage.getParameters().put(IDCardUtil.PARAM_ERRMSG, IDCardUtil.EncryptEncodeParameter('Error'));
		Test.setCurrentPage (controllerPage);
		ctrl = new IDCard_CheckoutSingleApplication();
		ctrl.updateRecord();
	}
}

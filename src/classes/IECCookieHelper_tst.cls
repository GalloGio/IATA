/**
  * Description: This class tests the IEC Cookie helper class
  * Author: Alexandre McGraw
  * Version: 1.0
  * History:
  */
@isTest
private class IECCookieHelper_tst {

	static testMethod void testCookieStoring() {

		// Test #1 - shopping cart guid cookie

		String sGUID = IECUtil.NewGuid();

		IECCookieHelper.storeCartGuid(sGUID);
		String sTemp = IECCookieHelper.getCartGuid();

		system.assertEquals(IECCookieHelper.COOKIE_GUID_TEST, sTemp);

		IECCookieHelper.deleteShoppingCartCookie();

		//String sDeletedCookieValue = IECCookieHelper.getCartGuid();
		//system.assert(sDeletedCookieValue == null || sDeletedCookieValue=='');


		// Test #2 - quote rate plan info id cookie

		String sQrpiid = 'a3111000000Cb6y';

		IECCookieHelper.storeQuoteRatePlanInfo(sQrpiid);
		sTemp = IECCookieHelper.getQuoteRatePlanInfo();

		system.assertEquals(IECCookieHelper.COOKIE_QUOTE_RATEPLANID_TEST, sTemp);

		IECCookieHelper.deleteQuoteCookie();


		// Test #3 - quote comments cookie

		String sComments = 'some comments';

		IECCookieHelper.storeQuoteComments(sComments);
		sTemp = IECCookieHelper.getQuoteComments();

		system.assertEquals(IECCookieHelper.COOKIE_QUOTE_COMMENTS_TEST, sTemp);

		IECCookieHelper.deleteQuoteCommentsCookie();
	}
}

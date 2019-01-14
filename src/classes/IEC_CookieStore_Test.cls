/**

	Project: eCommerce Enhancements
	   File: IEC_CookieStore_Test.cls
	Subject: Test Class for IEC Cookie Store Management Class.
	History: 2017-06-20, asantos, Initial Release.

*/
@isTest
private class IEC_CookieStore_Test {
	private static User user;

	private static void setup() {
		user = IECTestUtil.createSampleGuestUserAndLogin();
	}

	@isTest
	static void testCookieStore1() {
		IEC_ConfirmOrderController controller;
		IEC_CookieStore cookieStore;
		String sampleContentSmall = 'Hello Dear Sirs, this is a sample test. Many thanks.';
		String sampleContentSmall2 = 'Hello Sir; What\'s my name? Thanks';
		String sampleContentBig = '';

		String readContent;

		setup();

		for (Integer i = 1000; i < 4000; i++) {
			sampleContentBig += String.valueOf(i);
		}

		Test.startTest();
		
		System.runAs(user) {
			Test.setCurrentPage(Page.IEC_ConfirmOrder);

			controller = new IEC_ConfirmOrderController();

			cookieStore = new IEC_CookieStore('CookieStoreTest', null, 86400, false);

			cookieStore.storeContent(sampleContentSmall);

			readContent = cookieStore.retrieveContent();

			System.assert(readContent.equals(sampleContentSmall), 'Content is not the same: expecting \'' + sampleContentSmall + '\', got \'' + readContent + '\'');

			cookieStore.storeContent(sampleContentSmall2);

			readContent = cookieStore.retrieveContent();

			System.assert(readContent.equals(sampleContentSmall2), 'Content is not the same: expecting \'' + sampleContentSmall2 + '\', got \'' + readContent + '\'');

			cookieStore.storeContent(sampleContentBig);

			readContent = cookieStore.retrieveContent();

			System.assert(readContent.equals(sampleContentBig), 'Content is not the same: expecting \'' + sampleContentBig + '\', got \'' + readContent + '\'');

			cookieStore.storeContent(sampleContentSmall);
			
			readContent = cookieStore.retrieveContent();

			System.assert(readContent.equals(sampleContentSmall), 'Content is not the same: expecting \'' + sampleContentSmall + '\', got \'' + readContent + '\'');

			cookieStore.clearContent();

			readContent = cookieStore.retrieveContent();

			System.assert(readContent.equals(''), 'Content is not the same: expecting \'' + '' + '\', got \'' + readContent + '\'');
		}

		Test.stopTest();
	}
}
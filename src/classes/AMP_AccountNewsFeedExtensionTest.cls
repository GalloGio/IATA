@isTest
private class AMP_AccountNewsFeedExtensionTest {

	@isTest
	static void testAccountNewsFeed() {

			Test.setMock(HttpCalloutMock.class, new AMP_MockHttpResponseGenerator());
			// HttpResponse res = AMP_AccountNewsFeedExtension.getInfoFromExternalService('test');
			List<AMP_AccountNewsFeedExtension.rssPost> lsPosts = new List<AMP_AccountNewsFeedExtension.rssPost>();
			lsPosts = AMP_AccountNewsFeedExtension.getNewsFeed('test');
			AMP_AccountNewsFeedExtension.getAccountName('0018E00000Gfake');

	}

}

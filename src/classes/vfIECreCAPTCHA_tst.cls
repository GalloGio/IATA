@isTest
private class vfIECreCAPTCHA_tst {

	static testMethod void myUnitTest() {
		vfIECreCAPTCHA cap = new vfIECreCAPTCHA();
		String sTest = cap.siteKey;
		sTest = cap.challenge;
		sTest = cap.response;
		Boolean bTest = cap.verified;
		cap.verify();
		vfIECreCAPTCHA.YourHttpCalloutMockImpl callout = new vfIECreCAPTCHA.YourHttpCalloutMockImpl();
		callout.respond(null);
	}
}

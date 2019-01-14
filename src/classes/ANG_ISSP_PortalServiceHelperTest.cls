@isTest
private class ANG_ISSP_PortalServiceHelperTest {
	
	@isTest 
	static void isIepPortalServiveTest() {
		System.assert(ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay (EDENRED)'));
		System.assert(ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay (MSTS)'));
		System.assert(ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay (WEX)'));
		System.assert(!ANG_ISSP_PortalServiceHelper.isIepPortalService('IATA EasyPay'));
	}		
}
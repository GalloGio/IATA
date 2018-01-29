@isTest
public class RTSMonthlyDigestEmailComponentTest {
	static testmethod void testMonthlyDigestEmailComponent() {
		RTSMonthlyDigestEmailComponentController mdController = new RTSMonthlyDigestEmailComponentController();
		System.assertEquals(0, mdController.getRedRiskAlerts().size());
	}
}
/**
 * Partially test some of the IEC_Zuora_Sel class since it is all callout
 * Testing will involve invoking the callout lines and failing
 */
@isTest
private class IEC_Zuora_Sel_Test {

	@isTest(SeeAllData=true)
	static void test_Zuora_Sel() {
		String zId =  TestDataGenerator.generateZuoraFakeId();
		try {
			IEC_Zuora_Sel.getRatePlanChargeFromRatePlan(new Set<String> {zId});
		} catch (Exception e) {}
		try {
			IEC_Zuora_Sel.getRatePlanFromSubscription(zId);
		} catch (Exception e) {}
		try {
			IEC_Zuora_Sel.getAccountsByZId(new Set<String> {zId});
		} catch (Exception e) {}
		try {
			IEC_Zuora_Sel.getSubscriptionsByZId(new Set<String> {zId});
		} catch (Exception e) {}
	}

	@isTest
	static void test_Exceptions() {
		String zId =  TestDataGenerator.generateZuoraFakeId();
		try {
			IEC_Zuora_Sel.getRatePlanChargeFromRatePlan(new Set<String> {zId});
		} catch (Exception e) {}
		try {
			IEC_Zuora_Sel.getRatePlanFromSubscription(zId);
		} catch (Exception e) {}
		try {
			IEC_Zuora_Sel.getAccountsByZId(new Set<String> {zId});
		} catch (Exception e) {}
		try {
			IEC_Zuora_Sel.getSubscriptionsByZId(new Set<String> {zId});
		} catch (Exception e) {}
	}
}

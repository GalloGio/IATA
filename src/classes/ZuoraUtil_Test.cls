@isTest
private class ZuoraUtil_Test {

	@isTest (seeAllData=true)
	static void test_PaymentMethod() {
		// Implement test code
		ZuoraUtil.getDefaultPaymentMethod();
		ZuoraUtil.getPaymentMethodsFromZuora('4028e6992e836e4a012e914e1ddf5a2a');
	}


	/****************************************************************************************************
		Created by Thai 2016-04-14
			Cover method "isRESTCalledFromZuora"
	****************************************************************************************************/
	@isTest(SeeAllData=false)
	static void testIsRESTCalledFromZuora() {
		List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
		listCS.add(new Apex_Setting__c(Name='Zuora Outbound IP Address1', Text_1__c=',64.79.155.192,'));
		listCS.add(new Apex_Setting__c(Name='Zuora Outbound IP Address2', Text_1__c=',207.218.90.81,'));
		insert listCS;

		system.assert(false == ZuoraUtil.isRESTCalledFromZuora(null, null), 'Exception should return false');
		system.assert(false == ZuoraUtil.isRESTCalledFromZuora('108.60.148.186', new Map<String, String>()), 'Should be false because of no match');
		system.assert(true == ZuoraUtil.isRESTCalledFromZuora('64.79.155.192', new Map<String, String>()), 'Should be matched on remote address');
		system.assert(true == ZuoraUtil.isRESTCalledFromZuora('108.60.148.186', new Map<String, String>{'X-Salesforce-SIP' => '207.218.90.81'}), 'Should be matched on parameter');
	} //*** end of "testIsRESTCalledFromZuora"

}

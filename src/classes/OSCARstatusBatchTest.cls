@isTest
private class OSCARstatusBatchTest {
	
	@testSetup
	private static void initialize() {
		List<AMS_OSCAR__c> oscarList = new List<AMS_OSCAR__c>();
		AMS_OSCAR__c osc = new AMS_OSCAR__c(Name ='Voluntary_Relinquishment',
		 Change_effective_as_of__c = System.today()+1);
		AMS_OSCAR__c osc1 = new AMS_OSCAR__c(Name ='Voluntary_Relinquishment1',
		 Change_effective_as_of__c = System.today());
		AMS_OSCAR__c osc2 = new AMS_OSCAR__c(Name ='Voluntary_Relinquishment',
		 Termination_Date__c = System.today()+1);
		AMS_OSCAR__c osc3 = new AMS_OSCAR__c(Name ='Voluntary_Relinquishment',
		 Termination_Date__c = System.today());

		

	}


	@isTest static void test_method_one() {
		// Implement test code
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}
	
}
@isTest
private class ANG_OSCARNewGenTest {
       
	@isTest static void testNewHEStandardManagerApproval() {
		
		AMS_OSCAR_TestDataFactory.createNewGenTestData(AMS_Utils.NEWHESTANDARD);

		AMS_OSCAR__c oscar = [SELECT Id, RPM_Approval__c, Oscar_Communication_Case_Id__c, STEP12__c FROM AMS_OSCAR__c limit 1];

		oscar.STEP12__c = AMS_Utils.PASSED;
		oscar.Validation_Status__c = AMS_Utils.PASSED;
		oscar.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;

		update oscar;

		//confirm that email sent is on the case
		List<EmailMessage> approvalEmail = [SELECT Id, ParentId FROM EmailMessage WHERE ParentId =: oscar.Oscar_Communication_Case_Id__c];

		System.assertEquals(approvalEmail.size(), 1);

		ID FormOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
		List<Agency_Authorization__c> formsofpayment = [SELECT Id, ANG_FormOfPayment_ID__c FROM Agency_Authorization__c WHERE RecordTypeId =: FormOfPaymentRT];

		String check = '';
		for(Agency_Authorization__c fp: formsofpayment)
			check += fp.ANG_FormOfPayment_ID__c;

		System.assert(check.contains('CC'));
		System.assert(check.contains('CA'));
		System.assert(check.contains('EP'));

		//check that agency authorizations are created on the account
		System.assertEquals(formsofpayment.size(), 3);

	}
	
}
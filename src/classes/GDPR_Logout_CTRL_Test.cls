@isTest
public with sharing class GDPR_Logout_CTRL_Test {
	
	@isTest
	static void killTokenTest() {
		String token = 'test';

		Boolean k = GDPR_Logout_CTRL.killToken('fakeId');

        Individual indiv = new Individual(FirstName = 'fred', LastName = 'dev', Email__c = 'fred.dev@test.com', Token__c = token, Timestamp__c = String.valueOf(System.now().getTime()));
        INSERT indiv;

		Boolean killT = GDPR_Logout_CTRL.killToken(indiv.Id);
	}
}
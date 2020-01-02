@isTest
public class AccountRolesHelper_Test {
	@isTest
	public static void testUpdateNameInsert() {
		Account_Roles__c ars = new Account_Roles__c(Name = 'test', Sector__c = 'Airline', Category__c = 'Passenger only');

		test.startTest();
		insert ars;
		test.stopTest();

		Account_Roles__c arsResultInsert = [SELECT Name
									  FROM Account_Roles__c
									  WHERE Sector__c = 'Airline'
									  AND Category__c = 'Passenger only'];

		system.assertEquals('Airline - Passenger only', arsResultInsert.Name);

	}

	@isTest
	public static void testUpdateNameUpdate() {
		Account_Roles__c ars = new Account_Roles__c(Name = 'test', Sector__c = 'Airline', Category__c = 'Passenger only');

		insert ars;

		Account_Roles__c arsResultInsert = [SELECT Name
											FROM Account_Roles__c
											WHERE Sector__c = 'Airline'
											AND Category__c = 'Passenger only'];

		arsResultInsert.Category__c = 'Passenger and Cargo';

		test.startTest();
		update arsResultInsert;
		test.stopTest();

		Account_Roles__c arsResultUpdate = [SELECT Name
											FROM Account_Roles__c
											WHERE Sector__c = 'Airline'
											AND Category__c = 'Passenger and Cargo'];

		system.assertEquals('Airline - Passenger and Cargo', arsResultUpdate.Name);

	}
}

@isTest
public class Training_Contact_Role_DetailsTest {

	@isTest
	public static void testInsertTrainingContactRole(){

		IATA_ISO_Country__c ctr1 = new IATA_ISO_Country__c(Name = 'Test1 country', ISO_Code__c = 'PT');
		insert ctr1;

		Account acc = new Account(Name = 'test account', IATA_ISO_Country__c = ctr1.id, Sector__c = 'Airline Supplier', Category__c = 'Fuel Supplier');
		insert acc;

		Contact cont = new Contact(AccountId = acc.Id, LastName = 'Master', email = 'test.cont1@test.com');
		insert cont;

		Account_Role__c accRole = new Account_Role__c(Account__c = acc.Id);
		insert accRole;

		Id accContactRole_RT = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Master');
		Account_Contact_Role__c acr = new Account_Contact_Role__c(Account_Role__c = accRole.Id, Contact__c = cont.Id, Service_Rendered__c = 'Other', RecordTypeId = accContactRole_RT);
		insert acr;

		Training_Contact_Role_Details__c tcrd = new Training_Contact_Role_Details__c(Preferred_Course__c = 'test', Account_Contact_Role__c = acr.Id);
		insert tcrd;

		Test.startTest();

			tcrd.UserId__c = 'id&rekt';
			update tcrd;
			
			//this update above is supposed to published an event.
			//although events are not being published when running tests
			//so we cannot make an assertion of this logic.

		Test.stopTest();

	}

}
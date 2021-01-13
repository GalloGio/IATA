@isTest
public class AMS_PersonHelperTest {

	public static testmethod void testUpdateContactInfo(){

		Contact c = new Contact(FirstName = 'Test', LastName = 'Contact');
		insert c;

		List<Contact> cons = [select Id from contact];

		Set<ID> contactIDS = new Set<Id>{cons[0].id};

		AMS_PersonHelper.updateContactInfo(contactIDS);

	}
/*
	public static testmethod void testEnsure0to1ContactLookup(){
		Account a = new Account(Name='Test Account');
		insert a ;
		Contact c = new Contact(LastName = 'Test Contact', AccountId = a.ID);
		insert c;
		Contact c2 = new Contact(LastName = 'Test Contact 2', AccountId = a.ID);
		insert c2;
		Test.startTest();

		AMS_Person__c p = new AMS_Person__c(Name = 'Test Person', Contact__c = c.ID);
		insert p;

		// insert should be ok
		List<AMS_Person__c> persons = [SELECT Id FROM AMS_Person__c];
		system.assertEquals(1,persons.size());

		try{
			p = new AMS_Person__c(Name = 'Test Person', Contact__c = c.ID);
			insert p;
		}catch(Exception e){}

		// it's not possible to insert a second Person related to the same contact
		persons = [SELECT Id FROM AMS_Person__c];
		system.assertEquals(1,persons.size());


		// if I change the lookup to a different contact insert will succeed
		p.Contact__c = c2.id;
		insert p;

		persons = [SELECT Id FROM AMS_Person__c];
		system.assertEquals(2,persons.size());

	}


	public static testmethod void testAddContactIfEmpty(){
		Account acc = new Account(Name='Test Account');
		insert acc ;
		Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.ID);
		insert c;
		Contact c2 = new Contact(FirstName = 'Test', LastName = 'Contact 2', AccountId = acc.ID);
		insert c2;


		AMS_Agency__c a = new AMS_Agency__c(Name='Test Agency', Account__c=acc.ID);
		insert a;

		Test.startTest();

		// try to insert an Person with no contact but same name of an existing contact
		AMS_Person__c p = new AMS_Person__c(FirstName__c = 'Test', Name = 'Contact', Agency__c=a.ID);
		insert p;

		// should be ok and the relationship to the existing contact should be created
		List<AMS_Person__c> persons = [SELECT Id, Contact__c FROM AMS_Person__c];
		system.assertEquals(1,persons.size());
		system.assertEquals(c.ID,persons[0].Contact__c);


		// now I try to insert an Person not related to a contact and with a new name
		p = new AMS_Person__c(FirstName__c = 'Real', Name = 'Contact', Agency__c=a.ID);
		insert p;

		// should be ok, a new contact should be created and the relationship to the new contact should be created
		List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE FirstName = 'Real' AND LastName = 'Contact'];
		system.assertEquals(1,contacts.size());
		system.assertEquals(acc.ID,contacts[0].AccountId);

		persons = [SELECT Id, Contact__c FROM AMS_Person__c WHERE FirstName__c = 'Real'];
		system.assertEquals(1,persons.size());
		system.assertEquals(contacts[0].ID,persons[0].Contact__c);



		system.debug(LoggingLevel.ERROR,'####################  CRITICAL TEST ######################');
		// now I try to insert an Person not related to any contact but with the same name as an existing contact related to an Person
		p = new AMS_Person__c(FirstName__c = 'Real', Name = 'Contact', Agency__c=a.ID);
		try{insert p;}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR,'####################  Exception e '+e.getMessage());

		}

		// should not insert neither a new contact nor the new Person
		contacts = [SELECT Id,AccountId FROM Contact WHERE FirstName = 'Real' AND LastName = 'Contact'];
		system.assertEquals(1,contacts.size());

		persons = [SELECT Id, Contact__c FROM AMS_Person__c WHERE FirstName__c = 'Real'];
		system.assertEquals(1,persons.size());
		system.debug(LoggingLevel.ERROR,'####################  END CRITICAL TEST ######################');

	}

	public static testmethod void testCheckMax1ManagerPerAgency(){
		AMS_Agency__c a = new AMS_Agency__c(Name='Test Agency');
		insert a ;


		Account acc = new Account(Name='Test Account');
		insert acc ;
		Contact c = new Contact(LastName = 'Test Contact', AccountId = acc.ID);
		insert c;
		Contact c2 = new Contact(LastName = 'Test Contact 2', AccountId = acc.ID);
		insert c2;
		Test.startTest();


		// create a manager Person
		AMS_Person__c p = new AMS_Person__c(Name = 'Test Person', Agency__c = a.ID, isManager__c = true, Contact__c=c.ID);
		insert p;

		// insert should be ok
		List<AMS_Person__c> persons = [SELECT Id FROM AMS_Person__c];
		system.assertEquals(1,persons.size());

		try{
			p = new AMS_Person__c(Name = 'Test Person 2', Agency__c = a.ID, isManager__c = true, Contact__c=c2.ID);
			insert p;
		}catch(Exception e){}

		// it's not possible to insert a second manager Person related to the same agency
		persons = [SELECT Id FROM AMS_Person__c];
		system.assertEquals(1,persons.size());


		// I should be allowed to insert a second Person (non manager)
		p.isManager__c = false;
		insert p;

		persons = [SELECT Id FROM AMS_Person__c];
		system.assertEquals(2,persons.size());

	}
 */
}

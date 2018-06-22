@isTest
private class AMS_PersonCasesControllerTest {
	
	@testSetup static void setup(){
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account acc1 = new Account(Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        insert acc1;

        Contact c1 = new Contact(AccountId = acc1.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = false);
        Contact c2 = new Contact(AccountId = acc1.id, Firstname = 'teste2', Lastname='test2',Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = false);
        Contact c3 = new Contact(AccountId = acc1.id, Firstname = 'teste3', Lastname='test3',Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = false, User_Portal_Status__c = 'Approved Admin');
        Contact c4 = new Contact(AccountId = acc1.id, Firstname = 'teste4', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = true);
        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts.add(c1);
        listOfContacts.add(c2);
        listOfContacts.add(c3);
        listOfContacts.add(c4);
        insert listOfContacts;

        AMS_Person__c p1 = new AMS_Person__c(Name='test1', Contact__c = c1.id);
        AMS_Person__c p2 = new AMS_Person__c(Name='test2', Contact__c = c2.id);
        AMS_Person__c p3 = new AMS_Person__c(Name='test3', Contact__c = c3.id);
        List<AMS_Person__c> listOfPersons = new List<AMS_Person__c>();
        listOfPersons.add(p1);
        listOfPersons.add(p2);
        listOfPersons.add(p3);
        insert listOfPersons;

        AMS_Account_Role__c e1 = new AMS_Account_Role__c(Account__c = acc1.id, Person__c = p1.id, Contact__c = c1.id);
        AMS_Account_Role__c e2 = new AMS_Account_Role__c(Account__c = acc1.id, Person__c = p2.id, Contact__c = c2.id);
        AMS_Account_Role__c e3 = new AMS_Account_Role__c(Account__c = acc1.id, Person__c = p3.id, Contact__c = c3.id);
        List<AMS_Account_Role__c> listOfEmployees = new List<AMS_Account_Role__c>();
        listOfEmployees.add(e1);
        listOfEmployees.add(e2);
        listOfEmployees.add(e3);
        insert listOfEmployees;
    }
	
	@isTest static void test_PersonCasesController() {
        PageReference pageRef = Page.AMS_PersonCases;
        Test.setCurrentPageReference(pageRef);

        AMS_Person__c p = [select id, Contact__c from AMS_Person__c where name = 'test1'];

        ApexPages.CurrentPage().getparameters().put('pid', p.id);
        ApexPages.StandardController sc = new ApexPages.standardController(p);

        Test.startTest();
        AMS_PersonCasesController ecc = new AMS_PersonCasesController(sc);
        ecc.getCases();

        Account acc1 = [select id from Account];
        List<Contact> contacts = [select id from Contact];
        for(Contact c:contacts){
        	Case ca = new Case(AccountId = acc1.id, ContactId = c.id);
        	insert ca;
    	}
    	ecc.cases = null;
        ecc.getCases();
        Test.stopTest();
    } 
	
}
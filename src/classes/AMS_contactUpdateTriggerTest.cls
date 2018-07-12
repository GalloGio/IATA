@isTest
private class AMS_contactUpdateTriggerTest {
    
    @testSetup static void setup(){
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account acc = new Account(type = 'IATA Passenger Sales Agent', Location_Class__c = 'R', IATA_ISO_Country__c = isoc.id,Name='Test Agency', IATAcode__c = '1234567', Short_Name__c = 'Test Agency', AIMS_ID__c = '12345678', Is_AIMS_Account__c = true,Location_Type__c = 'HO');
        insert acc;

        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test1@test.com',
                                    Financial_Assessment_Contact__c = false);
        Contact c2 = new Contact(AccountId = acc.id, Firstname = 'teste2', Lastname='test2',Phone = '911111111', MobilePhone = '911111111', Email = 'test2@test.com',
                                    Financial_Assessment_Contact__c = true);
        Contact c3 = new Contact(AccountId = acc.id, Firstname = 'teste3', Lastname='test3',Phone = '911111111', MobilePhone = '911111111', Email = 'test3@test.com',
                                    Financial_Assessment_Contact__c = false, User_Portal_Status__c = 'Approved Admin');

        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts.add(c1);
        listOfContacts.add(c2);
        listOfContacts.add(c3);
        insert listOfContacts;

        AMS_Person__c p1 = new AMS_Person__c(Name='test1', legacy_system__c = 'WEBSTAR', Contact__c = c1.Id);
        AMS_Person__c p2 = new AMS_Person__c(Name='test2', legacy_system__c = 'WEBSTAR', Contact__c = c2.Id);
        AMS_Person__c p3 = new AMS_Person__c(Name='test3', legacy_system__c = 'WEBSTAR', Contact__c = c3.Id);

        List<AMS_Person__c> listOfPersons = new List<AMS_Person__c>();
        listOfPersons.add(p1);
        listOfPersons.add(p2);
        listOfPersons.add(p3);
        insert listOfPersons;

        c1.Person__c = p1.Id;
        c2.Person__c = p2.Id;
        c3.Person__c = p3.Id;

        update listOfContacts;

        //AMS_Employee__c e1 = new AMS_Employee__c(Agency__c = a.id, Person__c = p1.id, Contact__c = c1.id, legacy_system__c = 'WEBSTAR');
        //AMS_Employee__c e2 = new AMS_Employee__c(Agency__c = a.id, Person__c = p2.id, Contact__c = c2.id, legacy_system__c = 'WEBSTAR');
        //AMS_Employee__c e3 = new AMS_Employee__c(Agency__c = a.id, Person__c = p3.id, Contact__c = c3.id, legacy_system__c = 'WEBSTAR');

        AMS_Account_Role__c e1 = new AMS_Account_Role__c(Account__c = acc.id, Person__c = p1.id, Contact__c = c1.id, legacy_system__c = 'WEBSTAR');
        AMS_Account_Role__c e2 = new AMS_Account_Role__c(Account__c = acc.id, Person__c = p2.id, Contact__c = c2.id, legacy_system__c = 'WEBSTAR');
        AMS_Account_Role__c e3 = new AMS_Account_Role__c(Account__c = acc.id, Person__c = p3.id, Contact__c = c3.id, legacy_system__c = 'WEBSTAR');

        List<AMS_Account_Role__c> listOfEmployees = new List<AMS_Account_Role__c>();
        listOfEmployees.add(e1);
        listOfEmployees.add(e2);
        listOfEmployees.add(e3);
        insert listOfEmployees;
    }
    
    @isTest static void test_contactUpdateTrigger() {
        Test.startTest();
        
        List<AMS_Person__c> listofPersons = [select id, Email__c, Phone__c, DOB__c, Mobile__c, Fax__c from AMS_Person__c];
        
        integer y = 0;
        for(AMS_Person__c p:listOfPersons){
             p.Email__c = 'test2' + y +'@gmail.com';
            p.Phone__c = '123';
            p.Mobile__c = '123';
            p.Fax__c = '123';
            y++;
        }
        
        update listofPersons;
        
        List<Contact> allContacts = [select id,Phone,email,MobilePhone,Fax from Contact WHERE Id IN (SELECT Contact__c FROM AMS_Account_Role__c)];
        
        integer z = 0;
        for(Contact c:allContacts){
            system.assertEquals('test2' + z +'@gmail.com', c.email);
            system.assertEquals('123', c.Phone);
            system.assertEquals('123', c.MobilePhone);
            system.assertEquals('123', c.Fax);
            z++;
        }
        
        Test.stopTest();
    }
}
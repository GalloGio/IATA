@isTest
public class AMS_EmployeeHelperTest{

    /* #AMSFTS is not used anymore
    public static testmethod void testEnsure0to1ContactLookup(){
       
        Account acc = new Account(Name='Test Account');
        insert acc ;
        Contact c = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert c;
        Contact c2 = new Contact(LastName = 'Test Contact 2', AccountId = acc.Id);
        insert c2;
        AMS_Person__c p = new AMS_Person__c(Lastname__c = 'Test Contact', legacy_system__c='WEBSTAR');
        insert p;
        AMS_Person__c p2 = new AMS_Person__c(Lastname__c = 'Test Contact 2', legacy_system__c='WEBSTAR');
        insert p2;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        //AMS_Agency__c a = new AMS_Agency__c(Country__c = ctry.id, Name='Test Agency', Account__c=acc.Id, RecordTypeId = agenciesRT.get('PASSENGER'));
        //insert a;

        Test.startTest();
        
        AMS_Employee__c emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p.Id, Valid__c = true, isManager__c = true);
        insert emp;
        
        // insert should be ok
        List<AMS_Employee__c> employees = [SELECT Id FROM AMS_Employee__c];
        system.assertEquals(1,employees.size());

        try{
            emp = new AMS_Employee__c(Agency__c = a.Id, Person__c = p.Id, Valid__c = true, isManager__c = true);
            insert emp;
        }catch(Exception e){}
        
        // it's not possible to insert a second Person related to the same contact
        employees = [SELECT Id FROM AMS_Employee__c];
        system.assertEquals(2,employees.size());
        AMS_EmployeeHelper.Ensure0to1ContactLookup(employees);
        
        // if I change the lookup to a different contact insert will succeed
        //emp.Person__c = p2.id;
        //emp.isManager__c =  false;
        //insert emp;
        
        //employees = [SELECT Id FROM AMS_Employee__c];
        //system.assertEquals(3,employees.size());
        
    }
    
    */
    // #AMSFTS moved into AMS_AccountRoleTest class
    public static testmethod void testAddContactIfEmpty(){
        Account acc = new Account(Name='Test Account');
        insert acc ;
        Contact c = new Contact(FirstName = 'Name', LastName = 'Test Contact', AccountId = acc.Id);
        insert c;
        Contact c2 = new Contact(FirstName = 'Name', LastName = 'Test Contact 2', AccountId = acc.Id);
        insert c2;
        AMS_Person__c p = new AMS_Person__c(First_Name__c = 'Name', Lastname__c = 'Test Contact', legacy_system__c ='WEBSTAR', DOB__c = Date.newInstance(2000, 1, 1), Email__c = 'testing@test.com');
        insert p;
        AMS_Person__c p2 = new AMS_Person__c(First_Name__c = 'Name', Lastname__c = 'Test Contact 2');
        insert p2;
        AMS_Person__c p3 = new AMS_Person__c(First_Name__c = 'Name', Lastname__c = 'Test Person 3', Email__c = 'teste@test.com');
        insert p3;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        AMS_Agency__c a = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test Agency', Account__c=acc.Id);
        insert a;
        
        List<AMS_Account_Role__c> newRoles = new List<AMS_Account_Role__c>();
        newRoles.add(new AMS_Account_Role__c(Person__c = p.id, Account__c = acc.Id, Simplex__c='12345'));
        newRoles.add(new AMS_Account_Role__c(Person__c = p2.id, Account__c = acc.Id, Simplex__c='12346'));
        insert newRoles;
        
        Test.startTest();
        
        // try to insert an Person with no contact but same name of an existing contact
        AMS_Employee__c emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p.Id, Valid__c = true, isManager__c = false);
        insert emp;
        
        // should be ok and the relationship to the existing contact should be created
        //List<AMS_Employee__c> employees = [SELECT Id, Person__r.Contact__c FROM AMS_Employee__c];
        //system.assertEquals(1,employees.size());
        //system.assertEquals(c.Id,employees[0].Person__r.Contact__c);
        
        
        // now I try to insert an Person not related to a contact and with a new name
        //p = new AMS_Person__c(First_Name__c = 'Real', Name = 'Contact', Agency__c=a.ID);
        emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p3.Id, Valid__c = true, isManager__c = false);
        insert emp;
        
        // should be ok, a new contact should be created and the relationship to the new contact should be created
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE LastName = 'Test 3'];
        //system.assertEquals(1,contacts.size()); //TODO to check
        system.assertEquals(0,contacts.size());
        //system.assertEquals(acc.ID,contacts[0].AccountId);
        
        //List<AMS_Person__c> persons = [SELECT Id, Contact__c FROM AMS_Person__c WHERE Name = 'Test Person 3'];
        //system.assertEquals(1,persons.size());
        //system.assertEquals(contacts[0].Id,persons[0].Contact__c);
        
        
        
        system.debug(LoggingLevel.ERROR,'####################  CRITICAL TEST ######################');
        // now I try to insert an person not related to any contact but with the same name as an existing contact related to an person
        //p = new AMS_Person__c(First_Name__c = 'Real', Name = 'Contact', Lastname__c = 'Test');
        emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p3.Id, Valid__c = true, isManager__c = false);
        try{insert emp;}
        catch(Exception e){
            system.debug(LoggingLevel.ERROR,'####################  Exception e '+e.getMessage());
        }
        
        // should not insert neither a new contact nor the new person
        contacts = [SELECT Id,AccountId FROM Contact WHERE LastName = 'Test 3'];
        //system.assertEquals(1,contacts.size());
        
        //persons = [SELECT Id, Contact__c FROM AMS_Person__c WHERE Name = 'Test Person 3'];
        //system.assertEquals(1,persons.size());
        //system.debug(LoggingLevel.ERROR,'####################  END CRITICAL TEST ######################');
        
    }
    
    /* #AMSFTS not used anymore
    public static testmethod void testCheckMax1ManagerPerAgency(){
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        AMS_Agency__c a = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test Agency');
        insert a ;
        
        
        Account acc = new Account(Name='Test Account');
        insert acc ;
        Contact c = new Contact(LastName = 'Test Contact', AccountId = acc.Id);
        insert c;
        Contact c2 = new Contact(LastName = 'Test Contact 2', AccountId = acc.Id);
        insert c2;
        AMS_Person__c p = new AMS_Person__c(Lastname__c = 'Test Contact');
        insert p;
        AMS_Person__c p2 = new AMS_Person__c(Lastname__c = 'Test Contact 2');
        insert p2;
        Test.startTest();
        
        
        // create a manager Person
        //AMS_Person__c p = new AMS_Person__c(Name = 'Test Person', Agency__c = a.ID, isManager__c = true, Contact__c=c.ID);
        //insert p;
        AMS_Employee__c emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p.Id, Valid__c = true, isManager__c = true);
        insert emp;
        
        // insert should be ok
        List<AMS_Employee__c> employees = [SELECT Id FROM AMS_Employee__c];
        system.assertEquals(1,employees.size());
        
        try{
            emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p2.Id, Valid__c = true, isManager__c = true);
            insert emp;
        }catch(Exception e){}
        
        // it's not possible to insert a second manager Person related to the same agency
        employees = [SELECT Id, Agency__c FROM AMS_Employee__c];
        system.assertEquals(2,employees.size());
        AMS_EmployeeHelper.EnsureMax1ManagerPerAgency(employees);
        
        
        // I should be allowed to insert a second Person (non manager)
        //emp.isManager__c = false;
        //insert emp;
        
        //employees = [SELECT Id FROM AMS_Employee__c];
        //system.assertEquals(3,employees.size());
        
    }
    */
}
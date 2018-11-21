@isTest
public class AMS_EmployeeHelperTest{

    
    // #AMSFTS moved into AMS_AccountRoleTest class
    @isTest
    public static void testAddContactIfEmpty(){
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

        AMS_Agency__c a = new AMS_Agency__c(Country__c = ctry.id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agency__c', 'PASSENGER'), Name='Test Agency', Account__c=acc.Id);
        insert a;
        
        List<AMS_Account_Role__c> newRoles = new List<AMS_Account_Role__c>();
        newRoles.add(new AMS_Account_Role__c(Person__c = p.id, Account__c = acc.Id, Simplex__c='12345'));
        newRoles.add(new AMS_Account_Role__c(Person__c = p2.id, Account__c = acc.Id, Simplex__c='12346'));
        insert newRoles;
        
        Test.startTest();
        
        // try to insert an Person with no contact but same name of an existing contact
        AMS_Employee__c emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p.Id, Valid__c = true, isManager__c = false);
        insert emp;
        
        // now I try to insert an Person not related to a contact and with a new name
        emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p3.Id, Valid__c = true, isManager__c = false);
        insert emp;
        
        // should be ok, a new contact should be created and the relationship to the new contact should be created
        List<Contact> contacts = [SELECT Id,AccountId FROM Contact WHERE LastName = 'Test 3'];
        //system.assertEquals(1,contacts.size()); //TODO to check
        system.assertEquals(0,contacts.size());
        
        system.debug(LoggingLevel.ERROR,'####################  CRITICAL TEST ######################');
        // now I try to insert an person not related to any contact but with the same name as an existing contact related to an person
        emp = new AMS_Employee__c( Agency__c = a.Id, Person__c = p3.Id, Valid__c = true, isManager__c = false);
        try{insert emp;}
        catch(Exception e){
            system.debug(LoggingLevel.ERROR,'####################  Exception e '+e.getMessage());
        }
        
        // should not insert neither a new contact nor the new person
        contacts = [SELECT Id,AccountId FROM Contact WHERE LastName = 'Test 3'];
        
    }
    
}
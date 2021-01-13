/*
 * Test class covering the RelatedContactHandler trigger and the RelatedContactUtil class.
 */

@isTest
private class RelatedContactTest {
	@testSetup static void setup(){
		// Create accounts
		list<Account> lsAccount = new list<Account>();
        Id StandardAccount_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        lsAccount.add(new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', RecordTypeId = StandardAccount_RT_Id));
        lsAccount.add(new Account(Name = 'Qatar Airways France', Airline_designator__c = 'QR', RecordTypeId = StandardAccount_RT_Id));
        lsAccount.add(new Account(Name = 'Qatar Airways UK', Airline_designator__c = 'QR', RecordTypeId = StandardAccount_RT_Id));
        
        insert lsAccount;
	}
	
    static testMethod void myUnitTest() {
        // Create a contact linked to the first account
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        
        Account a1;
        Account a2;
        Account a3;
        
        list<Account> lsAccnt = [select id, name, Airline_designator__c from Account];
        system.assert(lsAccnt.size()==3);
        
        a1 = lsAccnt.get(0);
        a2 = lsAccnt.get(1);
        a3 = lsAccnt.get(2);
        
        test.startTest();
        
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a1.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        c = [SELECT Id, Related_to_Accounts__c FROM Contact WHERE Id = :c.Id];
        system.assertEquals(null, c.Related_to_Accounts__c);
        
        // link contact to 2nd account
        Related_Contact__c rc1 = new Related_Contact__c(Account__c = a2.Id, Contact__c = c.Id, Status__c = 'Active');
        insert rc1;
        
        // check that the trigger updated the Related_to_Accounts__c field on the contact
        c = [SELECT Id, Related_to_Accounts__c FROM Contact WHERE Id = :c.Id];
        system.assertEquals(String.valueOf(a2.Id), c.Related_to_Accounts__c);
        
        // link contact to 3rd account
        Related_Contact__c rc2 = new Related_Contact__c(Account__c = a3.Id, Contact__c = c.Id, Status__c = 'Active');
        insert rc2;
        
        // check that the trigger updated the Related_to_Accounts__c field on the contact
        c = [SELECT Id, Related_to_Accounts__c FROM Contact WHERE Id = :c.Id];
        system.assertEquals(String.valueOf(a2.Id) + ',' + String.valueOf(a3.Id), c.Related_to_Accounts__c);
        
        // update one of the related contact records
        rc2.Status__c = 'Inactive';
        update rc2;
        
        // check that the trigger updated the Related_to_Accounts__c field on the contact
        c = [SELECT Id, Related_to_Accounts__c FROM Contact WHERE Id = :c.Id];
        system.assertEquals(String.valueOf(a2.Id), c.Related_to_Accounts__c);
        
        // delete the other related contact record
        delete rc1;
        
        // check that the trigger updated the Related_to_Accounts__c field on the contact
        c = [SELECT Id, Related_to_Accounts__c FROM Contact WHERE Id = :c.Id];
        system.assertEquals(null, c.Related_to_Accounts__c);
        test.stopTest();
    }

}
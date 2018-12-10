/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the trgICCS_ASP_CaseClosed triggers on the Case object. 
 *
 */

@isTest
private class trgICCS_ASP_CaseClosed_Test {
    static testMethod void test() {
    	// Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create an Airline HQ account & a contact for it
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        test.startTest();
        
        // Create a Case for the Account
        
        Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
        Case cs = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true);  
        insert cs;
        
        // close the case
        cs.Process_Approved__c = Date.today();
        cs.status = 'Closed';
        update cs;
        
        // check that the Process Approved date was copied to the Authorized Signatories field on the related Account
        a = [SELECT Id, Document_Std_Instruction__c FROM Account WHERE Id = :a.Id];
        
        system.assertEquals(Date.today(), a.Document_Std_Instruction__c);
        
        test.stopTest();
    }
}
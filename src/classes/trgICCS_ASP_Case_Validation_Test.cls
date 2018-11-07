/*
 *  @author: Constantin BUZDUGA, blue-infinity
 *  @description: This is a test class for the trgICCS_ASP_Case_Validation trigger on the Case object. 
 *
 */

@isTest
private class trgICCS_ASP_Case_Validation_Test {
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
        
        // create an Airline Coding Application case on the account
        ID AirlineCodingRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');
        Case cs_coding1 = new Case(recordtypeID = AirlineCodingRTId, Status = 'Open', AccountId = a.id, Subject = 'cs1', Reason1__c='Designator Form');
        insert cs_coding1;
        
        test.startTest();
        
        // Create a Case for the Account
        Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
        Case cs = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true,Reason1__c='Designator Form');
        insert cs;
        
        List<Case> lstCases = [SELECT Id, Account.Ongoing_Request_for_Documents__c FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size());
        System.AssertEquals(true,lstCases[0].Account.Ongoing_Request_for_Documents__c);
        
        // try to open a new ASP case on the same account, check that it is not inserted
        try {
            Case cs2 = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true,Reason1__c='Designator Form');
            insert cs2;
        } catch(Exception e) {}
        
        lstCases = [SELECT Id FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size()); // Check that the case was not inserted
        
        
        cs.Status = 'Closed';
        update cs;
        
        lstCases = [SELECT Id, Account.Ongoing_Request_for_Documents__c FROM Case WHERE RecordTypeId = :RT_ICCS_ASP_Id];
        System.AssertEquals(1,lstCases.size());
        System.AssertEquals(false,lstCases[0].Account.Ongoing_Request_for_Documents__c);
        
        
        // try to open a new Airline Coding case on the same account, check that it is not inserted 
        Boolean isExceptionRaised = false;
        try {
	        Case cs_coding2 = new Case(recordtypeID = AirlineCodingRTId, Status = 'Open', AccountId = a.id, Subject = 'cs2',Reason1__c='Designator Form');
	        insert cs_coding2;
        } catch(Exception e) {
        	isExceptionRaised = true;
        }
        
        System.AssertEquals(true, isExceptionRaised);
        
        test.stopTest();
    }
}

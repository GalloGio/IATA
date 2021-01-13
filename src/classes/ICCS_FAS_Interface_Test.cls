/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This is a test class for the ICCS_FAS_Interface class.
 */
 
@isTest
private class ICCS_FAS_Interface_Test {
	testMethod static void WebserviceMethodsTest() {
        // Create an Airline HQ account & a contact for it
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id, 
						Communication_Interest__c = 'Cash Flow - Monthly Report');
        insert c;
        
	    ICCS_FAS_Interface.getContacts('');
	    ICCS_FAS_Interface.getContacts('Cash Flow - Monthly Report');
	}
}
/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This is a test class for the ICCS_FAS_Interface class.
 */
 
@isTest
private class ICCS_FAS_Interface_Test {
	testMethod static void WebserviceMethodsTest() {
        // Create an Airline HQ account & a contact for it
        //RecordType RT_AirlineHQ = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'IATA_Airline'];
        Id AirlineHQ_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Airline Headquarters').RecordTypeId ;
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        //RecordType RT_ContactStd = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Standard_Contact'];
        Id ContactStd_RT_Id = Schema.SObjectType.Contact.RecordTypeInfosByName.get('Standard').RecordTypeId ;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'test@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id, 
						Communication_Interest__c = 'Cash Flow - Monthly Report');
        insert c;
        
	    ICCS_FAS_Interface.getContacts('');
	    ICCS_FAS_Interface.getContacts('Cash Flow - Monthly Report');
	}
}
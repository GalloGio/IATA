/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class CustomQueueNotificationsTest {

    static testMethod void myUnitTest() {
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
        
        // Create a Case for the Account
        Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
        Case cs = new Case(RecordTypeId = RT_ICCS_ASP_Id, Subject = 'test', Origin = 'Email', CaseArea__c = 'FDS - Create Authorized Signatories Package', Status = 'Open',
                        ContactId = c.Id, AccountId = a.Id, Confirmation_Remarks__c = 'remarks', Eligibility_Documents_Checklist_approved__c = true);  
        insert cs;
        
        List<Case> lstCases = [SELECT Id FROM Case];
        System.AssertEquals(1,lstCases.size());
        
        // create the custom setting
        Queue_Notif_Emails__c qn = new Queue_Notif_Emails__c(Name = 'Due Diligence', Queue_Name__c = 'Due Diligence', Email_Adresses__c = 'buzdugac@iata.org');
        insert qn;
        
        // get the Due Diligence queue Id
        Group dd = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Due Diligence'];
        
        test.startTest();
        	
        	// try to change the owner Id to the Due Diligence queue, to trigger the notification email
        	cs.OwnerId = dd.Id;
        	update cs;
        	
        test.stoptest();
    }
}
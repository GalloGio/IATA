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
private class AuthorizedSignatoriesPackageTest {

    static testMethod void myUnitTest() {
        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR');
        insert country;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account a = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', RecordTypeId = AirlineHQ_RT_Id);
        insert a;
        
        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c = new Contact(FirstName = 'Test', LastName = 'Contact', email = 'AuthorizedSignatoriesPackageTest@test.com', AccountId = a.Id, RecordTypeId = ContactStd_RT_Id);
        insert c;
        
        Authorized_Signatories_Package__c asp = new Authorized_Signatories_Package__c(Account__c = a.Id);
        Authorized_Signatories_Package__c asp2 = new Authorized_Signatories_Package__c(Account__c = a.Id);
        
        
        test.startTest();
        	// no ASPs present at the beginning of the test
        	list<Authorized_Signatories_Package__c> asps = [SELECT Id FROM Authorized_Signatories_Package__c];
        	system.assertEquals(true, asps.isEmpty());
        	
        	// empty ASP Effective Date at the beginning of the test
        	a = [SELECT Id, ASP_Effective_Date__c FROM Account WHERE Id = :a.id];
        	system.assertEquals(null, a.ASP_Effective_Date__c);
        	
        	// insert first asp, should work fine
        	insert asp;
        	
        	// ASP should have been created
        	asps = [SELECT Id FROM Authorized_Signatories_Package__c];
        	system.assertEquals(false, asps.isEmpty());
        	
        	// create a new Authorized Signatory linked to the ASP
        	Authorized_Signatory__c auths = new Authorized_Signatory__c(Authorized_Signatories_Package__c = asp.Id, Contact__c = c.Id);
        	insert auths;
        	
        	///// add a non-image attachment
        	Attachment att = new Attachment(ParentId = auths.Id, Body = Blob.valueOf('asdasd'), Name = 'asd.txt', ContentType = 'plain/text');
        	insert att;
        	
        	// the ASP Effective date at account level should have been updated to today()
        	a = [SELECT Id, ASP_Effective_Date__c FROM Account WHERE Id = :a.id];
        	system.assertEquals(Date.today(), a.ASP_Effective_Date__c);
        	
        	// the last attachment id should have been updated, the image attachment not
        	auths = [SELECT Id, Image_Attachment_Id__c, Last_Attachment_Id__c FROM Authorized_Signatory__c WHERE Id = :auths.Id];
        	system.assertEquals(null, auths.Image_Attachment_Id__c);
        	system.assertEquals(att.Id, auths.Last_Attachment_Id__c);
        	
        	///// add an image attachment
        	Attachment att2 = new Attachment(ParentId = auths.Id, Body = Blob.valueOf('asdasd'), Name = 'asd.jpg', ContentType = 'image/jpeg');
        	insert att2;
        	
        	// the last attachment id should not have been updated, the image attachment yes
        	auths = [SELECT Id, Image_Attachment_Id__c, Last_Attachment_Id__c FROM Authorized_Signatory__c WHERE Id = :auths.Id];
        	system.assertEquals(att2.Id, auths.Image_Attachment_Id__c);
        	system.assertEquals(att.Id, auths.Last_Attachment_Id__c);
        	
        	// try to insert the second ASP linked to the same account, the validation should prevent this from happening
        	boolean exceptionRaised = false;
            try{
                insert asp2;
            } catch (Exception e){
                exceptionRaised = true;
            }
            system.assertEquals(true,exceptionRaised);

            delete asps;
            undelete asps;
        	
        
        test.stopTest();
    }
}
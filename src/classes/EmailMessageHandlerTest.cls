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
private class EmailMessageHandlerTest {

    static testMethod void test_SetTheNOISentDateOnParentCase() {
        // create a SIDRA case
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;
        
        // create an attachment to it
        Attachment att = new Attachment();
        att.ParentId = aCase.Id;
        att.Name = 'Notice of Irregularity';
        att.Body = Blob.valueOf('asd');
        insert att;
        
        test.startTest();
            // simulate the creation of an email message
            EmailMessage em = new EmailMessage();
            em.ParentId = aCase.Id;
            em.Incoming = false;
            em.FromAddress = 'test@example.com';
            em.ToAddress = 'test@example.com';
            em.Subject = 'Test email';
            em.TextBody = 'Hello';
            insert em;
            
            // assert that the case NOI Sent was set
            aCase = [SELECT Id, NOI_sent__c FROM Case WHERE Id = :aCase.Id];
            System.assertNotEquals(null, aCase.NOI_sent__c);
             
        test.stopTest();
    }
    
    /* 
    static testMethod void test_PreventEmailDeletion() {
        // create a SIDRA case
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;
        
        //create an email message attached to the case
        EmailMessage em = new EmailMessage();
        em.ParentId = aCase.Id;
        em.Incoming = false;
        em.FromAddress = 'test@example.com';
        em.ToAddress = 'test@example.com';
        em.Subject = 'Test email';
        em.TextBody = 'Hello';
        insert em;
        
        test.startTest();
            
        Boolean exceptionRaised = false;
        
        // test that the email deletion is prevented
        try {
            delete em;
        } catch (Exception e) {
            exceptionRaised = true;
        }
        
        system.assertEquals(true, exceptionRaised);
             
        test.stopTest();
    }*/
}
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
private class trgCheckSISCaseRecycleBinAfterInsertTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        RecordType StandardContactRecordType = [Select r.Id, r.Name from RecordType r where r.Name = 'Standard' and r.SobjectType = 'Contact' limit 1];
        
        ExcludedEmailFromAddress__c excludeEmail = new ExcludedEmailFromAddress__c();
        excludeEmail.ApplicationName__c = 'ANY';
        excludeEmail.Name = 'sis.servicedesk@accelyakale.com';
        insert excludeEmail;
        
        ExcludedCaseSubject__c excludeSubject = new ExcludedCaseSubject__c();
        excludeSubject.Application_Name__c = 'ANY';
        excludeSubject.Name = 'UNDELIVERABLE';
        insert excludeSubject;
        
        Case c = new Case();
        ID SIScaseRecordTypeID = TestClass_SetupVariables.SIScaseRecordTypeID;
        ID IATAAccountRecordTypeID = TestClass_SetupVariables.IATAAccountRecordTypeID;        
        c.Subject = 'FAILURE NOTICE';
        c.Origin = 'E-mail to Case - IS Help Desk';
        c.RecordTypeId = SIScaseRecordTypeID;
        c.SuppliedEmail = 'sishelp@iata.org';
        insert c;
        
        // create test account
        Account account1 = new Account();
        account1.Name = 'Kale Application Support';
        account1.BillingCity = 'Montreal';
        account1.BillingCountry = 'Canada';
        account1.BillingStreet = 'some street';
        account1.Location_Type__c = 'HO';
        account1.RecordTypeId = IATAAccountRecordTypeID;
        insert account1;
        
        Contact contact1 = new Contact();
        contact1.FirstName = 'Dummy';
        contact1.LastName = 'No-Reply';
        contact1.Type_of_Contact__c = 'IFAP Contact';
        contact1.AccountId = account1.Id;
        contact1.Email = 'some@email.org';
        contact1.Financial_Assessment_Contact__c = false;
        contact1.RecordTypeId = StandardContactRecordType.Id;
        insert contact1;
        
        /*Case c1 = new Case();        
        c1.CaseArea__c = 'SIS';
        c1.Status = 'Escalated';
        c1.Subject = 'FAILURE NOTICE';
        c1.Origin = 'E-mail to Case - IS Help Desk';
        c1.RecordTypeId = SIScaseRecordTypeID;
        c1.SuppliedEmail = 'sishelp@iata.org';
        c1.Assigned_To__c = account1.Name;
        insert c1;*/
        
        Case c2 = new Case();        
        c2.CaseArea__c = 'SIS';
        c2.Status = 'Escalated';
        c2.Subject = 'FAILURE NOTICE';
        c2.Origin = 'E-mail to Case - IS Help Desk';        
      //  c2.SuppliedEmail = 'No-Reply@email.com';
        c2.Assigned_To__c = account1.Name;
        c2.Description = 'Case Area: SIS';
        c2.Type = 'Feature Request';
        
        /*Case c3 = new Case();        
        c3.CaseArea__c = 'SIS';
        c3.Status = 'Escalated';
        c3.Subject = 'UNDELIVERABLE';
        c3.Origin = 'E-mail to Case - IS Help Desk';        
        c3.SuppliedEmail = 'sis.servicedesk@accelyakale.com';
        c3.Assigned_To__c = account1.Name;
        c3.Description = 'Case Area: SIS';
        c3.Type = 'Feature Request';*/
        
        //c2.RecordTypeId = null;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            insert c2;
            //insert c3;
        }
        
    }
}
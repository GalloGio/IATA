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
private class DIPdetailsTest {

    static testMethod void DIPDetailsControllerTest() {
        // CREATE TEST DATA
        
        // Create a new ISO Country
        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
        insert acct_hq;
        
        // FINISHED CREATING TEST DATA
        
        
        test.startTest();
        
        // create a DIP review case
        Id RT_DIP_Review_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DIP_Review_Process');
        Case cs = new Case(RecordTypeId = RT_DIP_Review_Id, Subject = 'test', Origin = 'Phone', CaseArea__c = 'Risk Management Process', Reason1__c = 'DIP Annual Review', 
        				Status = 'Open', AccountId = acct_hq.Id);  
        insert cs;
        
        // check that the corresponding DIP Details record has been created
        list<DIP_Details__c> lstDIPrecords = [SELECT Id FROM DIP_Details__c WHERE Case__c =: cs.Id];
        system.assertEquals(1,lstDIPrecords.size());
        
        
        // instantiate the DIP details page controller 
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        DIPdetailsController controller = new DIPdetailsController(std);
        
        controller.EditDIP();
        PageReference pref = controller.CancelEditDIP();
        pref = controller.SaveDIP();
        
        // simulate Add new reinsurer, edit and cancel edit buttons click
        controller.AddNewReinsurer();
        system.assertEquals(true, controller.isAddEditReinsurerMode);
        system.assertEquals(true, controller.isViewReinsurerMode);
        
        controller.onFocusReinsurer.Coverage_percentage__c = 10;
        controller.SaveReinsurer();
        
        list<Reinsurer__c> lstReinsurers = [SELECT Id, Coverage_percentage__c FROM Reinsurer__c WHERE DIP_Details__c = :lstDIPrecords[0].Id];
        system.assertNotEquals(0, lstReinsurers.size());
        system.assertEquals(10, lstReinsurers[0].Coverage_percentage__c);
        
        
        
        controller = new DIPdetailsController(std);
        
        controller.onFocusReinsurer = lstReinsurers[0];
        controller.ViewReinsurer();
        controller.EditReinsurer();
        pref = controller.CancelEditReinsurer();
        
        
        test.stopTest();
        
    }
    
    
    static testMethod void DIPDetailsUtilTest() {
        // CREATE TEST DATA
        
        // Create a new ISO Country
        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;
        
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'Non-IATA member');
        insert acct_hq;
        
        // create a DIP review case
        Id RT_DIP_Review_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DIP_Review_Process');
        Case cs = new Case(RecordTypeId = RT_DIP_Review_Id, Subject = 'test', Origin = 'Phone', CaseArea__c = 'Risk Management Process', Reason1__c = 'DIP Annual Review', 
        				Status = 'Open', AccountId = acct_hq.Id);  
        insert cs;
        
        
        // FINISHED CREATING TEST DATA
        
        
        test.startTest();
        DIP_Details__c dip = [SELECT Id FROM DIP_Details__c WHERE Case__c =: cs.Id LIMIT 1];
        
        // simulate the first approval
        dip.Approval_Status__c = 'Pending Legal Approval';
        update dip;
        
        // check that the GPO Approver Name field has been updated
        dip = [SELECT Id, GPO_Approver_Name__c, Legal_Approver_Name__c FROM DIP_Details__c WHERE Case__c =: cs.Id];
        system.assertEquals(UserInfo.getUserId(),dip.GPO_Approver_Name__c);
        system.assertEquals(null,dip.Legal_Approver_Name__c);
        
        
        // simulate the second approval
        dip.Approval_Status__c = 'Pending RM&I Approval';
        update dip;
        
        // check that the Legal Approver Name field has been updated
        dip = [SELECT Id, GPO_Approver_Name__c, Legal_Approver_Name__c FROM DIP_Details__c WHERE Case__c =: cs.Id];
        system.assertEquals(UserInfo.getUserId(),dip.Legal_Approver_Name__c);
        
        delete dip;
        undelete dip;

        test.stopTest();
        
    }
}
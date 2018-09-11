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
private class SIDRARepaymentInstalmentsControllerTest {

    static testMethod void test_Controller_ERROR() {
        Test.startTest();
        
        ApexPages.StandardController stdc = new ApexPages.StandardController(new Case());
        SIDRARepaymentInstalmentsController controller = new SIDRARepaymentInstalmentsController(stdc);
        
        // test that new payment instalments are correctly created
        controller.AddNewPaymentInstalment(); 
        
        controller.Edit(); 
        controller.Save();
        controller.DeleteRpi();
        
        Test.stopTest();
    }
    
    static testMethod void test_Controller_OK() {
        Case aCase = new Case();
        acase.Subject = 'Test Case Subject';
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'SIDRA');
        insert aCase;
        
        list<Case_Detail__c> rpi = [SELECT Id FROM Case_Detail__c WHERE Case__c = :aCase.Id];
        system.assertEquals(0, rpi.size());
        
        Test.startTest();
        
        ApexPages.StandardController stdc = new ApexPages.StandardController(aCase);
        SIDRARepaymentInstalmentsController controller = new SIDRARepaymentInstalmentsController(stdc);
        
        // test that new payment instalments are correctly created
        controller.AddNewPaymentInstalment();
        controller.save();
        
        rpi = [SELECT Id FROM Case_Detail__c WHERE Case__c = :aCase.Id];
        system.assertEquals(SIDRARepaymentInstalmentsController.REPAYMENT_INSTALMENTS_QUANTITY, rpi.size());
        
        controller.Edit(); 
        controller.Cancel();
        controller.Save();
        
        String label = controller.strAddNewLabel;
        
        Double totalAmount = controller.totalAmount;
        Double netBalance = controller.netBalance;
        
        Test.stopTest();
    }
    
    static testMethod void test_Controller_OK2() {
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;
        
        ApexPages.StandardController stdc = new ApexPages.StandardController(aCase);
        SIDRARepaymentInstalmentsController controller = new SIDRARepaymentInstalmentsController(stdc);
        
        // test that new payment instalments are correctly created
        controller.AddNewPaymentInstalment();
        controller.save();
        
        list<Case_Detail__c> rpi = [SELECT Id FROM Case_Detail__c WHERE Case__c = :aCase.Id];
        system.assertEquals(SIDRARepaymentInstalmentsController.REPAYMENT_INSTALMENTS_QUANTITY, rpi.size());
        
        Test.startTest();
        controller = new SIDRARepaymentInstalmentsController(stdc);
        controller.AddNewPaymentInstalment();
        controller.save();
        
        rpi = [SELECT Id FROM Case_Detail__c WHERE Case__c = :aCase.Id];
        system.assertEquals(SIDRARepaymentInstalmentsController.REPAYMENT_INSTALMENTS_QUANTITY+1, rpi.size());
        Test.stopTest();
    }
    
    static testMethod void test_Controller_OK3() {
        Case aCase = new Case();
        acase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'SIDRA');
        acase.Subject = 'Test Case Subject';
        insert aCase;
        
        ApexPages.StandardController stdc = new ApexPages.StandardController(aCase);
        SIDRARepaymentInstalmentsController controller = new SIDRARepaymentInstalmentsController(stdc);
        
        // test that new payment instalments are correctly created
        controller.AddNewPaymentInstalment();
        controller.save();
        
        list<Case_Detail__c> rpi = [SELECT Id FROM Case_Detail__c WHERE Case__c = :aCase.Id];
        system.assertEquals(SIDRARepaymentInstalmentsController.REPAYMENT_INSTALMENTS_QUANTITY, rpi.size());
        
        Test.startTest();
        controller = new SIDRARepaymentInstalmentsController(stdc);
        controller.rpiIndexToDelete = 0;
        controller.DeleteRpi();
        
        rpi = [SELECT Id FROM Case_Detail__c WHERE Case__c = :aCase.Id];
        system.assertEquals(SIDRARepaymentInstalmentsController.REPAYMENT_INSTALMENTS_QUANTITY-1, rpi.size());
        Test.stopTest();
    }

}
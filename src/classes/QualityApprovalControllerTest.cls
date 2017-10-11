@isTest
public class QualityApprovalControllerTest {
    
    private static Quality__c createQuality() {
        Case cse = new Case();
        insert cse;
        
        Quality__c quality = new Quality__c(
            Status__c = 'Under Investigation',
            Deadline_for_Approval__c = DateTime.now().addDays(1),
            Exception_Type__c='Permanent',
            Exception_Classification_Type__c='Key Control',
            Key_Control__c='KC01 - Settlement Model Rules',
            Related_Case_Number__c=cse.Id);
        return quality;
    }

    static testMethod void testController_InvalidQuality() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Under Investigation';
        quality.Deadline_for_Approval__c = DateTime.now();
        insert quality;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        Test.stopTest();
    }
    
    static testMethod void testController_ValidQuality1() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Under Investigation';
        quality.Deadline_for_Approval__c = DateTime.now().addDays(-1);
        insert quality;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        Test.stopTest();
    }
    
    static testMethod void testController_ValidQuality2() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Pending Approval';
        quality.Deadline_for_Approval__c = DateTime.now().addDays(-1);
        insert quality;
        
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        Test.stopTest();
    }
    
    static testMethod void testController_Step2() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Under Investigation';
        quality.Deadline_for_Approval__c = DateTime.now().addDays(1);
        insert quality;

        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        
        Test.startTest();
        controller.goToStep2();
        controller.mapUsers = null;
        controller.getListUser();
        Test.stopTest();
    }

    static testMethod void testController_Step3() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Under Investigation';
        quality.Deadline_for_Approval__c = DateTime.now().addDays(1);
        insert quality;

        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        controller.searchUsers();
        
        Test.startTest();
        controller.goToStep3();
        Test.stopTest();
    }
    
    static testMethod void testController_Step4_Exception() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Under Investigation';
        quality.Deadline_for_Approval__c = DateTime.now().addDays(1);
        insert quality;

        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        
        Test.startTest();
        controller.quality = null;
        controller.userId = null;
        controller.goToStep4();
        System.assertEquals(QualityApprovalController.DANGER,controller.messageResult.type);
        Test.stopTest();
    }
    
    static testMethod void testController_Step4_Ok() {
        Quality__c quality = createQuality();
        quality.Status__c = 'Under Investigation';
        quality.Deadline_for_Approval__c = DateTime.now().addDays(1);
        insert quality;

        ApexPages.StandardController stdController = new ApexPages.StandardController(quality);
        QualityApprovalController controller = new QualityApprovalController(stdController);
        controller.UserId = UserInfo.getUserId();
        
        Test.startTest();
        
        // send to approval must go fine
        controller.goToStep4();
        System.assertEquals(QualityApprovalController.SUCCESS,controller.messageResult.type);
        
        // 2nd try must fail because is already in an approval process
        controller.goToStep4();
        System.assertEquals(QualityApprovalController.DANGER,controller.messageResult.type);
        controller.goToStep1();
        
        Test.stopTest();
    }
}
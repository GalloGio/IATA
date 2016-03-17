@isTest
private class VFEmailTemplatePreviewControllerTest {

    static testMethod void testController() {
        VFEmailTemplatePreviewController controller = new VFEmailTemplatePreviewController();
        Contact c = [Select c.Id from Contact c limit 1];
        EmailTemplate__c template = [Select et.Id from EmailTemplate__c et limit 1];
        
        controller.contactId = c.Id;
        controller.emailTemplateId = template.Id;
        controller.subject = 'Some subject';
        controller.financialReviewType = 'Annual';
        controller.deadlineDate = '2013-10-01';
        controller.financialYear = '2013';
        
    }
}
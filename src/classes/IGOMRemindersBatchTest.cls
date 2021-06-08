@isTest
public inherited sharing class IGOMRemindersBatchTest {
	public static final String GAP_NAME = 'Compliance Review';
    
	@TestSetup
	static void makeData() {
        // Generate one array of related records
        List<sObject> stationObjects = IGOMTestFactory.generateIGOMUserFactory(2, IGOMConstants.ROLES.ADMIN, IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ).get(0);

        //Generate base document and compliance reviews
        List<Compliance_Review_Part__c> complianceReviewParts = IGOMTestFactory.createExampleComplianceReviewData();

        //Set Compliance review notification date to today
        Set<Id> complianceRevIds = new Set<Id>{complianceReviewParts.get(3).Compliance_Review__c, complianceReviewParts.get(5).Compliance_Review__c};
        List<Compliance_Review__c> revs = new List<Compliance_Review__c>();
        for(Compliance_Review__c rev : [SELECT Id FROM Compliance_Review__c WHERE Id IN :complianceRevIds]){
            rev.Notification_Date__c = Date.today();
            revs.add(rev);
        }
        update revs;

        //Generate some base notifications
        Id contactRoleDetailId = stationObjects.get(6).Id;
        List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = new List<IGOM_Contact_Role_Procedure_Compliance__c>();
		IGOM_Contact_Role_Procedure_Compliance__c noti11 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetailId, complianceReviewParts.get(3).Id);
		IGOM_Contact_Role_Procedure_Compliance__c noti12 = IGOMTestFactory.createIGOMContactRoleProcedureCompliance(contactRoleDetailId, complianceReviewParts.get(5).Id);
		notI11.Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.UNREAD;
		notI12.Notification_Status__c = IGOMConstants.NOTIFICATION.STATUS.UNREAD;
		notifications.addAll(new List<IGOM_Contact_Role_Procedure_Compliance__c>{ notI11, noti12 });
		insert notifications;
	}

    /**
     * @description Test the batch when there are 2 stations without a GAP related to the latest IGOM.
     */
    @isTest
    private static void testIGOMReminder_Bulk_Success(){
        Test.startTest();
        SchedulableContext sc = null;
        IGOMRemindersBatch reminderBatch = new IGOMRemindersBatch();
        reminderBatch.execute(sc);
        Test.stopTest();

        List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = [SELECT Id, IGOM_Contact_Role_Detail__c, Notification_Subject__c FROM IGOM_Contact_Role_Procedure_Compliance__c];
        System.assertEquals(2+3, notifications.size());
    }

    /**
     * @description Test the batch when there are 25 stations with a published GAP related to the latest IGOM and there are another 25 stations without one.
     */
    @isTest
    private static void testIGOMReminder_Mixed_Success(){
        List<Compliance_Review__c> gapAnalyses = new List<Compliance_Review__c>();
        Id igomDocumentId = [SELECT Id FROM Document__c LIMIT 1].Id;
        Integer i = 0;
        for (Account_Role__c accRole : [SELECT Id FROM Account_Role__c LIMIT 2]) {
            // Create a GAP analysis per station for the created IGOM document
            if (Math.mod(i, 2) == 0) {
                Compliance_Review__c gap = IGOMTestFactory.createComplianceReview(igomDocumentId, accRole.Id, ('Title gap ' + i));
                gap.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
                gapAnalyses.add(gap);
            }
            i++;
        }
        insert gapAnalyses;

        Test.startTest();
        SchedulableContext sc = null;
        IGOMRemindersBatch reminderBatch = new IGOMRemindersBatch();
        reminderBatch.execute(sc);
        Test.stopTest();

        List<IGOM_Contact_Role_Procedure_Compliance__c> notifications = [SELECT Id, IGOM_Contact_Role_Detail__c, Notification_Subject__c FROM IGOM_Contact_Role_Procedure_Compliance__c];
        System.assertEquals(4, notifications.size());
    }
}
trigger ComplianceReviewTrigger on Compliance_Review__c (before update, before delete, after insert, after update, after delete, after undelete) {
	ComplianceReviewHandler complianceReviewHandler = new ComplianceReviewHandler();
    if (Trigger.isAfter) {
        if(Trigger.isUpdate){
		    complianceReviewHandler.afterUpdate(Trigger.oldMap, Trigger.new);
		}
	} 
}
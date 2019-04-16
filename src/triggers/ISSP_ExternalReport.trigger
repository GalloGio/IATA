trigger ISSP_ExternalReport on ISSP_External_Report__c (before insert, after insert, after update) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
    	ISSP_ExternalReportHandler.afterInsert(Trigger.new);
    }
    else if (Trigger.isBefore && Trigger.isInsert) {
    	ISSP_ExternalReportHandler.beforeInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
    	ISSP_ExternalReportHandler.afterUpdate(Trigger.new);
    }    
}
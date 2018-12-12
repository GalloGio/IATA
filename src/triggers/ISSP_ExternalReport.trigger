trigger ISSP_ExternalReport on ISSP_External_Report__c (before insert, after insert) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
    	ISSP_ExternalReportHandler.afterInsert(Trigger.new);
    }
    else if (Trigger.isBefore && Trigger.isInsert) {
    	ISSP_ExternalReportHandler.beforeInsert(Trigger.new);
    }
    
}
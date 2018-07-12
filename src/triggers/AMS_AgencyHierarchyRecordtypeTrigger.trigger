/*
This trigger will force Hierarchy to the MAIN record type oif not specified
to test: create new Hierarchy without RT, the  select it and check RT
*/
trigger AMS_AgencyHierarchyRecordtypeTrigger on AMS_Agencies_Hierarchy__c (before insert) {
   Id rtMain = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agencies_Hierarchy__c', 'MAIN');
   for(AMS_Agencies_Hierarchy__c h:trigger.new)
        if(h.recordTypeId ==null)
            h.recordtypeId = rtMain;
}
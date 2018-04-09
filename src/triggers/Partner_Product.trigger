trigger Partner_Product on Partner_products__c (after delete, after insert, after undelete,
    after update, before delete, before insert, before update){
	if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Insert', 'PartnerProduct__e', 'Partner_products__c');
        }
        if (Trigger.isUpdate) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Update', 'PartnerProduct__e', 'Partner_products__c');
        }
        if (Trigger.isDelete) {
            PlatformEvents_Helper.publishEvents(Trigger.oldMap, 'Delete', 'PartnerProduct__e', 'Partner_products__c');
        }
        if (Trigger.isUndelete) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Undelete', 'PartnerProduct__e', 'Partner_products__c');
        }
    }
}
trigger Payment_Product_Country_Config on TIP_Pay_Prov_Prod_Country_Config__c (after delete, after insert, after undelete,
    after update, before delete, before insert, before update){
	if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Insert', 'Product_Country_Config__e', 'TIP_Pay_Prov_Prod_Country_Config__c');
        }
        if (Trigger.isUpdate) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Update', 'Product_Country_Config__e', 'TIP_Pay_Prov_Prod_Country_Config__c');
        }
        if (Trigger.isDelete) {
            PlatformEvents_Helper.publishEvents(Trigger.oldMap, 'Delete', 'Product_Country_Config__e', 'TIP_Pay_Prov_Prod_Country_Config__c');
        }
        if (Trigger.isUndelete) {
            PlatformEvents_Helper.publishEvents(Trigger.newMap, 'Undelete', 'Product_Country_Config__e', 'TIP_Pay_Prov_Prod_Country_Config__c');
        }
    }
}
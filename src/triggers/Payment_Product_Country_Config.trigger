trigger Payment_Product_Country_Config on TIP_Pay_Prov_Prod_Country_Config__c (after delete, after insert, after undelete,
    after update, before delete, before insert, before update){
	if (Trigger.isAfter) {
        //Publish the platform events
        PlatformEvents_Helper.publishEvents((trigger.isDelete?trigger.OldMap:Trigger.newMap), 'Product_Country_Config__e', 'TIP_Pay_Prov_Prod_Country_Config__c', trigger.isInsert, trigger.isUpdate, trigger.isDelete, trigger.isUndelete);
    }
}
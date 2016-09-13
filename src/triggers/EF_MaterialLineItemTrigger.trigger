trigger EF_MaterialLineItemTrigger on EF_Material_Line_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

    	EF_MaterialLineItemHandler.checkBillingAgreementContractItems(Trigger.new, Trigger.oldMap);
    	EF_MaterialLineItemHandler.emailIfMaterialChanges(Trigger.new, Trigger.oldMap);
	}
}
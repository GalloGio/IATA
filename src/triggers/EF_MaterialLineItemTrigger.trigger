trigger EF_MaterialLineItemTrigger on EF_Material_Line_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
	if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {

    	EF_MaterialLineItemHandler.checkBillingAgreementContractItems(Trigger.new, Trigger.oldMap);
    	EF_MaterialLineItemHandler.emailIfMaterialChanges(Trigger.new, Trigger.oldMap);
	}
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		EF_MaterialLineItemHandler.validateContractMaterialRemoval(Trigger.new, Trigger.oldMap, true);
	}
	if(Trigger.isBefore && Trigger.isDelete)
	{
		EF_MaterialLineItemHandler.validateContractMaterialRemoval(Trigger.new, Trigger.oldMap, false);
	}
}
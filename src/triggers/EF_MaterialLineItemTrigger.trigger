trigger EF_MaterialLineItemTrigger on EF_Material_Line_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert)
		{
			// EF_MaterialLineItemHandler.testSomething(Trigger.new);
			EF_MaterialLineItemHandler.handleWithApprovalInserts(Trigger.new);
		}
		if(Trigger.isUpdate)
		{
			EF_MaterialLineItemHandler.checkBillingAgreementContractItems(Trigger.new, Trigger.oldMap);
			EF_MaterialLineItemHandler.validateContractMaterialRemoval(Trigger.new, Trigger.oldMap, true);
			EF_MaterialLineItemHandler.handleWithApprovalUpdates(Trigger.newMap, Trigger.oldMap);
            EF_MaterialLineItemHandler.handleApprovedAndRejectedApprovals(Trigger.new, Trigger.oldMap);
		}
		if(Trigger.isDelete)
		{
			EF_MaterialLineItemHandler.validateContractMaterialRemoval(Trigger.new, Trigger.oldMap, false);
		}
	}
	else if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
	{
		EF_MaterialLineItemHandler.validateNoInactiveMaterialsFromContract(Trigger.newMap);

    	// EF_MaterialLineItemHandler.emailIfMaterialChanges(Trigger.new, Trigger.oldMap);
    	if(Trigger.isInsert)
    		EF_MaterialLineItemHandler.checkBillingAgreementContractItems(Trigger.new);
		if(EF_MaterialLineItemHandler.runOnce() && EF_ContractHandler.isUserCsSpecialist())
        {
			EF_MaterialLineItemHandler.startApprovalProcesses(Trigger.new);
        }
	}
}
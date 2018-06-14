trigger EF_MaterialLineItemTrigger on EF_Material_Line_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update)
{
	if(Trigger.isBefore)
	{
		List<EF_Material_Line_Item__c> toApproveList = new List<EF_Material_Line_Item__c>();
		if(!Trigger.isDelete)
			toApproveList = EF_MaterialLineItemHandler.identifyToApproveRecords(Trigger.new);
		
		if(Trigger.isInsert)
		{
			EF_MaterialLineItemHandler.handleWithApprovalInserts(toApproveList);
		}
		if(Trigger.isUpdate)
		{
			EF_MaterialLineItemHandler.checkBillingAgreementContractItems(Trigger.new, Trigger.oldMap);
			EF_MaterialLineItemHandler.validateContractMaterialRemoval(Trigger.new, Trigger.oldMap, true);
			EF_MaterialLineItemHandler.handleWithApprovalUpdates(Trigger.newMap, Trigger.oldMap);
            EF_MaterialLineItemHandler.handleApprovedAndRejectedApprovals(toApproveList, Trigger.oldMap);
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
    	if(Trigger.isInsert){
    		EF_MaterialLineItemHandler.checkBillingAgreementContractItems(Trigger.new);
    	}
    	else{
    		EF_MaterialLineItemHandler.checkIfBillingAgreementDeactivationRequired(Trigger.oldMap);
    	}
    		
		if(EF_MaterialLineItemHandler.runOnce() && EF_ContractHandler.isUserCsSpecialist())
        {
			EF_MaterialLineItemHandler.startApprovalProcesses(Trigger.new);
        }
	}
	else if (Trigger.isAfter && (Trigger.isDelete))
	{
		EF_MaterialLineItemHandler.checkIfBillingAgreementDeactivationRequired(Trigger.oldMap);
	}
}
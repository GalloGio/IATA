trigger EF_ContractTrigger on Contract (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete)
{
		Set<Id> efContractRecordTypes = new Set<Id>();
		Id efContractRtId = AMS_Utils.getId('Contract', 'EF_Client_Agreement');
		if(efContractRtId != null)
			efContractRecordTypes.add(efContractRtId);
		
		List<Contract> efContractList = new List<Contract>();
		Map<Id, Contract> efContractMap = new Map<Id, Contract>();
		if(Trigger.new != null)
		{
			for(Contract c : Trigger.new)
			{
				if(c.RecordTypeId == efContractRtId)
				{
					efContractList.add(c);
					if(c.Id != null)
						efContractMap.put(c.Id, c);
				}
			}
		}

		if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)) {

            if(Trigger.isInsert)
            {
                EF_ContractHandler.handleWithApprovalAccountInserts(efContractList);
            } else
            {
            	EF_ContractHandler.validateContractCurrencyRemoval(Trigger.new, Trigger.oldMap);
                EF_ContractHandler.handleWithApprovalAccountUpdates(efContractMap, Trigger.oldMap);
                EF_ContractHandler.handleApprovedAndRejectedApprovals(efContractList, Trigger.oldMap);
            }
            
        } else if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert))
        {
            if(EF_ContractHandler.runOnce() && EF_ContractHandler.isUserCsSpecialist())
            {
				EF_ContractHandler.startApprovalProcesses(efContractList);
            }
        }
}
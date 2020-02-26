trigger EF_LocationCurrencyTrigger on EF_Location_Currency__c (
	before insert,
	before update,
	before delete,
	after insert,
	after update,
	after delete,
	after undelete) {

				if(Trigger.isBefore){
						if(Trigger.isInsert){
								try{ EF_LocationCurrencyHandler.manageNewLocationCurrency(Trigger.new, 'insert');  }catch(Exception e){ System.debug('#### ' + e);}

								//send for approval if needed
					EF_LocationCurrencyHandler.handleWithApprovalInserts(Trigger.new);

						}else if(Trigger.isUpdate){
								//check that it can be updated
								EF_LocationCurrencyHandler.handleWithApprovalUpdates(Trigger.newMap, Trigger.oldMap);
							EF_LocationCurrencyHandler.handleApprovedAndRejectedApprovals(Trigger.new, Trigger.oldMap);

						}else if(Trigger.isDelete){
								//check that it can be deleted
								EF_LocationCurrencyHandler.validateLocationCurrencyRemoval(Trigger.newMap, Trigger.oldMap);
						}

				}else if(Trigger.isAfter){
						if(Trigger.isInsert){
								if(EF_LocationCurrencyHandler.runOnce() && EF_ContractHandler.isUserCsSpecialist())
						{
					EF_LocationCurrencyHandler.startApprovalProcesses(Trigger.new);
						}
						}else if(Trigger.isUpdate){
								if(EF_LocationCurrencyHandler.runOnce() && EF_ContractHandler.isUserCsSpecialist())
						{
					EF_LocationCurrencyHandler.startApprovalProcesses(Trigger.new);
						}
								EF_LocationCurrencyHandler.manageUpdateLocationCurrency();
						}

				}

}

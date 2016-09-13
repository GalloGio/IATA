public class EF_ContractHandler 
{
    private static boolean run = true;   
    
     // Submits E&F Contracts for approval processing if the helper field is set to TRUE
    public static void startApprovalProcesses(List<Contract> cList)
    {
        for(Contract c : cList)
        {
            if(c.EF_Require_Approval__c)
            {
                EF_BaContractApprovalHelper.submitForApproval(c.Id, UserInfo.getUserId(), '');
            }
        }
    }

    // Identifies and handles both Approved, Rejected and Recalled approvals 
    public static void handleApprovedAndRejectedApprovals(List<Contract> newValues, Map<Id, Contract> oldValues)
    {
    	// Find the Custom Setting values for "Approval Required" fields and...
        List<EF_Approve_Fields__c> fieldList = [select id, name, Contract_Fields__c from EF_Approve_Fields__c where Name = 'Contract'];
        List<String> fields = new List<String>();
        if(fieldList.size() > 0)
            fields = fieldList.get(0).Contract_Fields__c.split(',');
        else
            fields.add('Id');
        List<Contract> approvedList = EF_BaContractApprovalHelper.identifyApprovedContracts(newValues, oldValues);
        List<Contract> rejectedList = EF_BaContractApprovalHelper.identifyRejectedOrRecalledContracts(newValues, oldValues);
        if(approvedList.size() > 0)
        {
        	// If approval occurred, copies the approved values from temporary storage onto the record itself
            EF_BaContractApprovalHelper.copyValuesFromTempStorageOnContractApproval(approvedList, fields);
        }
        if(rejectedList.size() > 0)
        {
        	// Or if rejected or recalled, simply ignore the changes and get rid of the temp storage record
            EF_BaContractApprovalHelper.removeTempStorageRecordOnContractRejection(rejectedList);
        }
    }

    
    public static void handleWithApprovalAccountUpdates(Map<Id, Contract> newContracts, Map<Id, Contract> oldContracts)
    {
    	// Find if the User belongs to CS Specialist group, because that is the only group requiring special attention
    	if(isUserCsSpecialist())
    	{
	        // Create a list of EF Approval records that will be stored in the system to contain the UPDATED versions of Contract
	        List<EF_Approval__c> approvalStorageList = new List<EF_Approval__c>();
	        // Get the list of fields that require Approval from Custom Settings and place them in a List
	        List<EF_Approve_Fields__c> fieldList = [select id, name, Contract_Fields__c from EF_Approve_Fields__c where Name = 'Contract'];
	        List<String> fields = fieldList.get(0).Contract_Fields__c.split(',');

	        // If there are any Contracts that require approval, start the process to temporarily store them into another object
	        for(Contract c : newContracts.values())
	        {
	            if(EF_BaContractApprovalHelper.identifyContractChanges(c, oldContracts.get(c.Id), fields))
	            {
	                EF_Approval__c approval = EF_BaContractApprovalHelper.fillTemporaryApprovalStorage(new EF_Approval__c(), c, fields);
	                c.EF_Require_Approval__c = true;
	                approvalStorageList.add(approval);
	                EF_BaContractApprovalHelper.rollbackPreviousValues(c, oldContracts.get(c.Id), fields);
	            }
	        }

	        if(approvalStorageList.size() > 0)
	        {
	            insert approvalStorageList;
	        }
    	}
    }

    // If user is a CS Specialist, make the Contract inactive and require approval
    public static void handleWithApprovalAccountInserts(List<Contract> contractList)
    {
		if(isUserCsSpecialist())
		{
			for(Contract c : contractList)
	        {
	            c.EF_Require_Approval__c = true;
	            c.EF_Status__c = 'Inactive';
	        }
		}
    }

    // Used to identify is the running user belongs to Client Services Specialists role inside E&F
    public static boolean isUserCsSpecialist()
    {
    	Id userId = UserInfo.getUserId();
    	List<User> currentUsers = [select id, EF_User_Role__c from User where Id = :userId];
    	if(currentUsers.size() > 0)
    	{
    		User currentUser = currentUsers.get(0);
    		if(currentUser.EF_User_Role__c != null)
    		{
    			if(currentUser.EF_User_Role__c.equalsIgnoreCase('Client Services Specialists'))
    				return true;
			}
    	}
    	return false;
    }

    public static boolean runOnce()
    {
        if(run)
        {
            run = false;
            return true;
        }
        else
        {
            return run;
        }
    }
    
}
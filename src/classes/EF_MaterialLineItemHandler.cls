public class EF_MaterialLineItemHandler
{
    private static boolean run = true;

    public static List<EF_Material_Line_Item__c> identifyToApproveRecords(List<EF_Material_Line_Item__c> newValues)
    {
        List<EF_Material_Line_Item__c> toApproveList = new List<EF_Material_Line_Item__c>();
        Id baMaterialRtId = AMS_Utils.getId('EF_Material_Line_Item__c', 'Relationship_Line_Item');
        for(EF_Material_Line_Item__c mat : newValues)
        {
            if(mat.RecordTypeId == baMaterialRtId)
            {
                if(mat.Allow_Billing_Agreements__c != null)
                {
                    if(mat.Allow_Billing_Agreements__c.equalsIgnoreCase('Allowed with Approval'))
                    {
                        toApproveList.add(mat);
                    }
                }
            } else
            {
                toApproveList.add(mat);
            }
        }
        return toApproveList;
    }

    public static void validateNoInactiveMaterialsFromContract(Map<Id, EF_Material_Line_Item__c> newMap)
    {
        Map<Id, EF_Material_Line_Item__c> relevantMaterials  = new Map<Id, EF_Material_Line_Item__c>();
        for(EF_Material_Line_Item__c mat : newMap.values())
        {
            if(mat.EF_Relationship__c != null && mat.EF_Status__c == 'Active')
            {
                relevantMaterials.put(mat.Id, mat);
            }
        }

        if(relevantMaterials.size() > 0)
        {
            List<EF_Material_Line_Item__c> allMaterials = [select Id, EF_Material__c, EF_Relationship__r.Contract__c, EF_Status__c, Name from EF_Material_Line_Item__c where Id in :relevantMaterials.keySet()];
            Set<Id> contractIds = new Set<Id>();
            for(EF_Material_Line_Item__c mat : allMaterials)
            {
                contractIds.add(mat.EF_Relationship__r.Contract__c);
            }

            Map<Id, List<EF_Material_Line_Item__c>> contractIdMaterialsMap = new Map<Id, List<EF_Material_Line_Item__c>>();
            
            // Only select Inactive materials to reduce the amount of records to loop through later on
            List<EF_Material_Line_Item__c> contractMaterials = [select Id, EF_Material__c, EF_Status__c, Contract__c, Name from EF_Material_Line_Item__c where Contract__c in :contractIds and EF_Status__c = 'Inactive'];
            for(EF_Material_Line_Item__c contractMaterial : contractMaterials)
            {
                if(contractIdMaterialsMap.get(contractMaterial.Contract__c) != null)
                {
                    contractIdMaterialsMap.get(contractMaterial.Contract__c).add(contractMaterial);
                } else
                {
                    contractIdMaterialsMap.put(contractMaterial.Contract__c, new List<EF_Material_Line_Item__c>());
                    contractIdMaterialsMap.get(contractMaterial.Contract__c).add(contractMaterial);
                }
            }

            for(EF_Material_Line_Item__c mat : allMaterials)
            {
                if(contractIdMaterialsMap.get(mat.EF_Relationship__r.Contract__c) != null)
                {
                    // Loop through the INACTIVE Contract's Material Line Items and identify if the same EF_Material__c linking exists
                    // If it does, it means that the Contract's Material Line Item for that Material is Inactive => Throw an error
                    for(EF_Material_Line_Item__c contractMaterial : contractIdMaterialsMap.get(mat.EF_Relationship__r.Contract__c))
                    {
                        if(mat.EF_Material__c == contractMaterial.EF_Material__c)
                        {
                            newMap.get(mat.Id).addError('The selected Material is set to Inactive state on the Contract level. Please select an active one instead.');
                            return;
                        }
                    }
                }
            }
        }
    }

    public static void handleApprovedAndRejectedApprovals(List<EF_Material_Line_Item__c> newValues, Map<Id, EF_Material_Line_Item__c> oldValues)
    {
        List<String> fields = new List<String>{'EF_Status__c', 'EF_Material__c'};
        List<Contract> approvedList = EF_BaContractApprovalHelper.identifyApprovedRecords(newValues, oldValues);
        List<Contract> rejectedList = EF_BaContractApprovalHelper.identifyRejectedOrRecalledRecords(newValues, oldValues);
        if(approvedList.size() > 0)
        {
            EF_BaContractApprovalHelper.copyValuesFromTempStorageOnrecordApproval(approvedList, fields, 'EF_Material_Line_Item__c');
        }
        if(rejectedList.size() > 0)
        {
            EF_BaContractApprovalHelper.removeTempStorageRecordOnRecordRejection(rejectedList, 'EF_Material_Line_Item__c');
        }
    }

    public static void handleWithApprovalUpdates(Map<Id, EF_Material_Line_Item__c> newMaterials, Map<Id, EF_Material_Line_Item__c> oldMaterials)
    {
        if(EF_ContractHandler.isUserCsSpecialist())
        {
            List<EF_Approval__c> approvalStorageList = new List<EF_Approval__c>();
            List<String> fields = new List<String>{'EF_Status__c', 'EF_Material_Name__c'};
            List<String> editFields = new List<String>{'EF_Status__c', 'EF_Material__c'};
            User currentUser = [select Id, Email, EF_Contract_Approver_Email__c, EF_Billing_Agreement_Approver_Email__c from User where Id = :UserInfo.getUserId()];
            for(EF_Material_Line_Item__c mat : newMaterials.values())
            {
                if(EF_BaContractApprovalHelper.identifyRecordChanges(mat, oldMaterials.get(mat.Id), fields, false))
                {
                    EF_Approval__c approval = EF_BaContractApprovalHelper.fillTemporaryApprovalStorage(new EF_Approval__c(), (sObject) mat, editFields, 'EF_Material_Line_Item__c');
                    mat.Require_Approval__c = true;
                    setApproverEmail(mat, currentUser);
                    approvalStorageList.add(approval);
                    EF_BaContractApprovalHelper.rollbackPreviousValues(mat, oldMaterials.get(mat.Id), editFields);
                }
            }

            if(approvalStorageList.size() > 0)
            {
                insert approvalStorageList;
            }
        }
    }

    // If user is a CS Specialist, make the Contract inactive and require approval
    public static void handleWithApprovalInserts(List<EF_Material_Line_Item__c> materialList)
    {
        if(EF_ContractHandler.isUserCsSpecialist())
        {
            List<String> fields = new List<String>{'EF_Status__c', 'EF_Material_Name__c'};
            List<String> editFields = new List<String>{'EF_Status__c', 'EF_Material__c'};

            for(EF_Material_Line_Item__c mat : materialList)
            {
                mat.Require_Approval__c = true;
                mat.EF_Status__c = 'Inactive';
                EF_BaContractApprovalHelper.identifyRecordChanges(mat, null, fields, true);
            }
        }
    }

    public static void startApprovalProcesses(List<EF_Material_Line_Item__c> cList)
    {
        for(EF_Material_Line_Item__c c : cList)
        {
            if(c.Require_Approval__c)
            {
                EF_BaContractApprovalHelper.submitForApproval(c.Id, UserInfo.getUserId(), '');
            }
        }
    }
    
    public static void setApproverEmail(EF_Material_Line_Item__c mat, User currentUser)
    {
        if(mat.Contract__c != null)
        {
            mat.EF_Approver_Email__c = currentUser.EF_Contract_Approver_Email__c;
        }
        if(mat.EF_Relationship__c != null)
        {
            mat.EF_Approver_Email__c = currentUser.EF_Billing_Agreement_Approver_Email__c;
        }
        mat.EF_Submitter_Email__c = currentUser.Email;
    }

    public static void validateContractMaterialRemoval(List<EF_Material_Line_Item__c> newLines, Map<Id, EF_Material_Line_Item__c> materialLineItemOldMap, boolean isUpdate)
    {
        // Ignore new inserts and only activate code on Update or Deletion
        if(materialLineItemOldMap != null)
        {
            // Place the Contracts into a set to be queried for
            Set<Id> affectedContractIds = new Set<Id>();
            for(EF_Material_Line_Item__c mat : materialLineItemOldMap.values())
            {
                if(mat.Contract__c != null)
                    affectedContractIds.add(mat.Contract__c);
            }

            // Because the point is to prevent deletion of Contract's Material Line Items that exist on Billing Agreements as well, 
            // we can get a list of all Material Line Items related to Contract from which a Material is being deleted from
            List<EF_Material_Line_Item__c> materialsInBAs = [select id, name, EF_Material__c, EF_Relationship__c, EF_Relationship__r.Contract__c from EF_Material_Line_Item__c where EF_Relationship__r.Contract__c in :affectedContractIds];
            Set<Id> materialIds = new Set<Id>();
            // Create a map that contains all Contracts as keys and a list of Materials belonging to Billing Agreements in the value
            Map<Id, Set<Id>> contractMaterialsMap = new Map<Id, Set<Id>>();
            for(EF_Material_Line_Item__c materialLineItem : materialsInBAs)
            {
                if(contractMaterialsMap.containsKey(materialLineItem.EF_Relationship__r.Contract__c))
                {
                    contractMaterialsMap.get(materialLineItem.EF_Relationship__r.Contract__c).add(materialLineItem.EF_Material__c);
                }
                else
                {
                    materialIds.add(materialLineItem.EF_Material__c);
                    contractMaterialsMap.put(materialLineItem.EF_Relationship__r.Contract__c, materialIds);
                }
            }

            // Loop through the items and try to find the to-be-deleted Material from the map => If found, throw an error
            if(!isUpdate)
            {
                for(EF_Material_Line_Item__c mat : materialLineItemOldMap.values())
                {
                    if(mat.Contract__c != null && !contractMaterialsMap.isEmpty())
                    {
                        if(contractMaterialsMap.get(mat.Contract__c).contains(mat.EF_Material__c))
                        {
                            mat.addError('Deletion of Material Line Item was not possible due to the same Material being used in at least one Airline Billing Agreement related to the Contract record.');
                        }
                    }
                }
            }

            // Loop through the items and try to find the to-be-used Material from the map => If not found, throw an error
            if(isUpdate)
            {
                for(EF_Material_Line_Item__c mat : newLines)
                {
                    if(mat.Contract__c != null)
                    {
                        if(contractMaterialsMap.get(mat.Contract__c) != null)
                        {
                            if(!contractMaterialsMap.get(mat.Contract__c).contains(mat.EF_Material__c) && contractMaterialsMap.get(mat.Contract__c).contains(materialLineItemOldMap.get(mat.id).EF_Material__c))
                            {
                                mat.EF_Material__c.addError('Unable to change Material type due to the current material being used in at least one Airline Billing Agreement related to the Contract record.');
                            }
                        }
                    }
                }
            }
        }
    }

    /* Commented out due to approval processing doing this and additional actions for now....
    public static void emailIfMaterialChanges(List<EF_Material_Line_Item__c> materialLineItemList, Map<Id,EF_Material_Line_Item__c> materialLineItemOldMap)
    {
        List<EF_Material_Line_Item__c> toApproveList = new List<EF_Material_Line_Item__c>();
        List<EF_Material_Line_Item__c> toDisallowList = new List<EF_Material_Line_Item__c>();
        List<EF_Material_Line_Item__c> baMaterials = new List<EF_Material_Line_Item__c>();
        boolean isCsSpecialist = EF_ContractHandler.isUserCsSpecialist();
        Set<Id> relatedBaIdSet = new Set<Id>();
        Set<Id> relevantProductIds = new Set<Id>();
        Map<Id, Product2> relevantProducts;

        for(EF_Material_Line_Item__c mat : materialLineItemList)
        {
            if(mat.Id != null && materialLineItemOldMap != null)
            {
                if(materialLineItemOldMap.get(mat.id) != null)
                {
                    // Only tracking changes to Material field...
                    if(mat.EF_Material__c != materialLineItemOldMap.get(mat.id).EF_Material__c)
                    {
                        relevantProductIds.add(mat.EF_Material__c);
                        if(materialLineItemOldMap.get(mat.id).EF_Material__c != null)
                            relevantProductIds.add(materialLineItemOldMap.get(mat.id).EF_Material__c);

                        // For Contracts, only the ones edited by Customer Services Spealists should be put to approval processing
                        if(mat.Contract__c != null && isCsSpecialist)
                        {
                            toApproveList.add(mat);
                        }
                        else if(mat.EF_Relationship__c != null)
                        {
                            // Billing Agreements might require an approval based on related Contract__r.EF_Allow_Billing_Agreements__c value (Allowed with Approval)
                            baMaterials.add(mat);
                            relatedBaIdSet.add(mat.Id);
                        }
                    }
                }
            }

            if(mat.Id != null && materialLineItemOldMap == null)
            {
                // Send a notification on insert
                relevantProductIds.add(mat.EF_Material__c);

                // For Contracts, only the ones edited by Customer Services Spealists should be put to approval processing
                if(mat.Contract__c != null && isCsSpecialist)
                {
                    toApproveList.add(mat);
                }
                else if(mat.EF_Relationship__c != null)
                {
                    // Billing Agreements might require an approval based on related Contract__r.EF_Allow_Billing_Agreements__c value (Allowed with Approval)
                    baMaterials.add(mat);
                    relatedBaIdSet.add(mat.Id);
                }                
            }

        }

        if(toApproveList.size() == 0 && baMaterials.size() == 0)
        {
            return;
        }

        // Find all Contracts related to the Billing Agreements to include Allow with Approval records
        List<EF_Material_Line_Item__c> matList = [select EF_Material__r.Name, Name, Contract__c, EF_Relationship__r.Contract__r.EF_Allow_Billing_Agreements__c from EF_Material_Line_Item__c where id in :relatedBaIdSet];
        for(EF_Material_Line_Item__c mat : matList)
        {
            if(mat.EF_Relationship__r.Contract__r.EF_Allow_Billing_Agreements__c != null)
            {
                if(mat.EF_Relationship__r.Contract__r.EF_Allow_Billing_Agreements__c.equalsIgnoreCase('Allowed with Approval'))
                {
                    toApproveList.add(mat);
                }
                if(mat.EF_Relationship__r.Contract__r.EF_Allow_Billing_Agreements__c.equalsIgnoreCase('Not Allowed'))
                {
                    toDisallowList.add(mat);
                }
            }
        }

        // Notify the approvers for Contract and BA Material Line changes. A html-table listing will be provided if more than one line changes at time. 
        if(toApproveList.size() > 0)
        {
            relevantProducts = new Map<Id, Product2>([select id, name from Product2 where Id in :relevantProductIds]);
            notifyRelevantApprover(toApproveList, materialLineItemOldMap, relevantProducts);
        }

        // Throw an exception if the Contract has turned into "Don't allow Billing Agreements" despite at one point BA and Materials were added
        if(toDisallowList.size() > 0)
        {
            for(EF_Material_Line_Item__c disallowed : toDisallowList)
            {
                throw new EF_BaContractApprovalHelper.ApprovalException('The Billing Agreement record is not editable, because the related Contract is set to not to allow Billing Agreements');
            }
        }
    }

    // Constructs two email html-bodies to be sent to User's Contract and Billing Agreement approvers
    private static void notifyRelevantApprover(List<EF_Material_Line_Item__c> changeList, Map<Id,EF_Material_Line_Item__c> materialLineItemOldMap, Map<Id, Product2> relevantProducts)
    {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        User u = [select EF_Contract_Approver__r.email, EF_Billing_Agreement_Approver__r.email, FirstName, LastName from User where Id = :UserInfo.getUserId()];
        String emailBody = 'Dear team member, <br/><br/>the following Materials have been changed by '+u.FirstName+' '+u.LastName+':<br/><br/>';
        emailBody = emailBody + '<table width="600px" border="1"><tr border="1"><th border="1">Field</th><th border="1">Old value:</th><th border="1">New value:</th></tr>';
        
        String contractBody = emailBody;
        String baBody = emailBody;
        boolean sendContract = false;
        boolean sendBa = false;
        boolean isInsert = false;

        // Go through the list of all changed Material Line Items and create an table row per item based on if the material line is related to a Contract or a BA
        for(EF_Material_Line_Item__c line : changeList)
        {
            if(materialLineItemOldMap != null)
            {
                if(materialLineItemOldMap.get(line.Id) != null)
                    isInsert = false;
            }
            else
            {
                isInsert = true;
            }

            if(line.Contract__c != null)
            {
                sendContract = true;
                if(isInsert)
                {
                    contractBody = contractBody + constructEmailRow(line, null, relevantProducts.get(line.EF_Material__c), baseUrl);
                } else
                {
                    contractBody = contractBody + constructEmailRow(line, relevantProducts.get(materialLineItemOldMap.get(line.Id).EF_Material__c), relevantProducts.get(line.EF_Material__c), baseUrl);
                }
            }
            else if(line.EF_Material__c != null)
            {
                sendBa = true;
                if(isInsert)
                {
                    baBody = baBody + constructEmailRow(line, null, relevantProducts.get(line.EF_Material__c), baseUrl);
                }
                else
                {
                    baBody = baBody + constructEmailRow(line, relevantProducts.get(materialLineItemOldMap.get(line.Id).EF_Material__c), relevantProducts.get(line.EF_Material__c), baseUrl);
                }
                
            }
        }

        contractBody = contractBody + '</table>';
        baBody = baBody + '</table>';

        // Only send an email to Contract approver if there were changes to Contracts' Materials
        if(sendContract && u.EF_Contract_Approver__r.email != null)
        {
            Utility.sendEmail(new List<String>{u.EF_Contract_Approver__r.email}, 'E&F CRM: Changes to Material Line Items', contractBody, true, null);
        }

        // Only send an email to BA approver if there were changes to BA' Materials
        if(sendBa && u.EF_Billing_Agreement_Approver__r.email != null)
        {
            Utility.sendEmail(new List<String>{u.EF_Billing_Agreement_Approver__r.email}, 'E&F CRM: Changes to Material Line Items', baBody, true, null);
        }
    }

    // Can be used to add more items per line apart from Material Name. If so, add the fields also to query on line 42.
    private static String constructEmailRow(EF_Material_Line_Item__c line, Product2 oldValue, Product2 newValue, String baseUrl)
    {
        String htmlRow;
        if(oldValue != null)
            htmlRow = '<tr><td border="1"><a href="'+baseUrl+'/'+line.Id+'">'+line.Name+'</a></td><td border="1">'+oldValue.Name+'</td><td border="1">'+newValue.Name+'</td></tr>';
        else
            htmlRow = '<tr><td border="1"><a href="'+baseUrl+'/'+line.Id+'">'+line.Name+'</a></td><td border="1">--</td><td border="1">'+newValue.Name+'</td></tr>';
        return htmlRow;
    }
    */

    //
    // Check is the material Item that is in the BillingAgreement exists in the contract.
    //
    public static void checkBillingAgreementContractItems(List<EF_Material_Line_Item__c> materialLineItemList, Map<Id,EF_Material_Line_Item__c> materialLineItemOldMap) {
        
        List<EF_Material_Line_Item__c> workdata = new List<EF_Material_Line_Item__c>();
        Set<Id> baIdSet = new Set<Id>();
                    
        //
        // Get all the new material lines and Billing agreements
        //
        for (EF_Material_Line_Item__c mli : materialLineItemList) {
            
            if ((mli.EF_Relationship__c != null && materialLineItemOldMap == null) || 
                (materialLineItemOldMap != null && materialLineItemOldMap.containsKey(mli.Id) && mli.EF_Relationship__c != materialLineItemOldMap.get(mli.Id).EF_Relationship__c) ||
                (materialLineItemOldMap != null && materialLineItemOldMap.containsKey(mli.Id) && mli.EF_Material__c != materialLineItemOldMap.get(mli.Id).EF_Material__c && mli.EF_Relationship__c != null) 
               ) {
                   
                workdata.add(mli);
                baIdSet.add(mli.EF_Relationship__c);
            }
        }
                        
        if (workdata.size() > 0) {
            
            Map<Id, Id> mliToContractMap = new Map<Id, Id>();
            
            //
            // Get all the contracts associated with the material lines
            //
            for (EF_Material_Line_Item__c mli : [select Id, EF_Relationship__r.Contract__c from EF_Material_Line_Item__c where Id IN: workdata]) {
                
                mliToContractMap.put(mli.Id, mli.EF_Relationship__r.Contract__c);
            }           

            //
            // Get all the material lines associated with the contracts in the billings agreements
            // 
            Map<Id,Contract> contracts = new Map<Id,Contract>([select Id, (select Id, EF_Material__c from EF_Material_Line_Items__r) from Contract where Id IN: mliToContractMap.values()]);
            Contract cont;
            Boolean found;
            
            //
            // The materials on the new lines must exist on the Material lines associated with the contracts.
            //
            for (EF_Material_Line_Item__c mli : workdata) {
                
                cont = contracts.get(mliToContractMap.get(mli.Id));
                found = false;
                if(cont != null)
                {
                    if (cont.EF_Material_Line_Items__r != null) {
                        
                        for (EF_Material_Line_Item__c contractMLI : cont.EF_Material_Line_Items__r) {
                            
                            if (contractMLI.EF_Material__c == mli.EF_Material__c) {
                                
                                found = true;
                                break;
                            }
                        }
                    }
                }
                if (found == false) {
                    
                    mli.addError(Label.EF_Line_Item_Not_In_Contract_Error);
                }
            }
        }
    }

    public static void checkBillingAgreementContractItems(List<EF_Material_Line_Item__c> materialLineItemList)
    {
        
        List<EF_Material_Line_Item__c> workdata = new List<EF_Material_Line_Item__c>();
        Set<Id> baIdSet = new Set<Id>();

        for (EF_Material_Line_Item__c mli : materialLineItemList)
        {
            if (mli.EF_Relationship__c != null)
            {
                workdata.add(mli);
                baIdSet.add(mli.EF_Relationship__c);
            }
        }

        if (workdata.size() > 0)
        {
            Map<Id, Id> mliToContractMap = new Map<Id, Id>();
            for (EF_Material_Line_Item__c mli : [select Id, EF_Relationship__r.Contract__c from EF_Material_Line_Item__c where Id IN :workdata])
            {
                mliToContractMap.put(mli.Id, mli.EF_Relationship__r.Contract__c);
            }

            Map<Id,Contract> contracts = new Map<Id,Contract>([select Id, (select Id, EF_Material__c from EF_Material_Line_Items__r) from Contract where Id IN :mliToContractMap.values()]);
            Contract cont;
            Boolean found;
            
            for (EF_Material_Line_Item__c mli : workdata)
            {
                cont = contracts.get(mliToContractMap.get(mli.Id));
                found = false;
                if(cont != null)
                {
                    if (cont.EF_Material_Line_Items__r != null) {
                        
                        for (EF_Material_Line_Item__c contractMLI : cont.EF_Material_Line_Items__r) {
                            
                            if (contractMLI.EF_Material__c == mli.EF_Material__c)
                            {
                                found = true;
                                break;
                            }
                        }
                    }
                }
                if (found == false)
                {
                    mli.addError(Label.EF_Line_Item_Not_In_Contract_Error);
                }
            }
        }
    }
    
    public static void checkIfBillingAgreementDeactivationRequired(Map<Id,EF_Material_Line_Item__c> materialLineItemOldMap){
    	
    	// Retrieve the list of Billing Agreements to be checked
    	List<Id> involvedBAs = new List<Id>();
    	for(EF_Material_Line_Item__c mat : materialLineItemOldMap.values()){
    		if(mat.EF_Relationship__c != null){
    			involvedBAs.add(mat.EF_Relationship__c);
    		}
    	}
    	
		// Retrieve the list of Billing Agreement for which there is at least one active Material Line Item
    	AggregateResult[] activableBAs = [Select EF_Relationship__c FROM EF_Material_Line_Item__c WHERE EF_Relationship__c IN :involvedBAs AND EF_Status__c = 'Active' GROUP BY EF_Relationship__c];

		// For each involved Billing Agreement, check if it still has a Material Line Item
		List<Id> withoutItemBAs = new List<Id>();
		for(Id involvedBa : involvedBAs){
			Boolean baHasItem = false;

			for(AggregateResult activableBA : activableBAs){
				if(activableBA.get('EF_Relationship__c') == involvedBa){
					baHasItem = true;
					break;
				}
			}
			
			if(!baHasItem){
				withoutItemBAs.add(involvedBa);
			}
		}

		// Retrieve and update the billing agreements that need to be updated
		List<EF_Billing_Agreement__c> billingAgreementsToUpdate = [SELECT Status__c FROM EF_Billing_Agreement__c WHERE Id IN :withoutItemBAs];
		for(EF_Billing_Agreement__c ba : billingAgreementsToUpdate){
			ba.EF_Status__c = 'Inactive';
		}
		update billingAgreementsToUpdate;
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
public with sharing class EF_BaContractApprovalHelper
{

	// Used for Contract approval rejection process 
	public static void removeTempStorageRecordOnContractRejection(List<Contract> rejectedList)
	{
		Set<Id> rejectedIds = new Set<Id>();
		for(Contract rejectedRecord : rejectedList)
		{
			rejectedIds.add(rejectedRecord.Id);
		}
		String query = 'select id, Contract__c from EF_Approval__c where Contract__c in :rejectedIds';

		List<EF_Approval__c> storageList = Database.query(query);
	    if(storageList.size() > 0)
		    delete storageList;
	}

	// Used for E&F Billing Agreement approval rejection process
	public static void removeTempStorageRecordOnBaRejection(List<EF_Billing_Agreement__c> rejectedList)
	{
		Set<Id> rejectedIds = new Set<Id>();
		for(EF_Billing_Agreement__c rejectedRecord : rejectedList)
		{
			rejectedIds.add(rejectedRecord.Id);
		}
		String query = 'select id, EF_Billing_Agreement__c from EF_Approval__c where EF_Billing_Agreement__c in :rejectedIds';

		List<EF_Approval__c> storageList = Database.query(query);
	    if(storageList.size() > 0)
		    delete storageList;
	}

	// Copies approved, future values of a Contract onto the Contract record from Temp Storage and then deleted the temp record
	public static void copyValuesFromTempStorageOnContractApproval(List<Contract> approvedList, List<String> fieldList)
	{
		Set<Id> approvedIds = new Set<Id>();
		for(Contract approvedRecord : approvedList)
		{
			approvedIds.add(approvedRecord.Id);
			approvedRecord.EF_Status__c = 'Active';
		}
		String query = 'select id, Contract__c, ';
		for(String f : fieldList)
		{
			query = query + f + ', ';
		}
		query = query.substring(0, query.length()-2);
		query = query + ' from EF_Approval__c where Contract__c in :approvedIds order by createddate desc';
		List<EF_Approval__c> storageList = Database.query(query);
		if(storageList.size() > 0)
		{
			Map<Id, EF_Approval__c> storageMap = new Map<Id, EF_Approval__c>();
			for(EF_Approval__c storageRecord : storageList)
			{
				if(storageMap.get(storageRecord.Contract__c) == null)
				{
					storageMap.put(storageRecord.Contract__c, storageRecord);
				}
			}

			Map<String, Schema.SobjectField> fields = Contract.getSObjectType().getDescribe().fields.getMap();
			for(Contract recordToUpdate : approvedList)
			{
		        for(String field : fieldList)
		        {
		            SObjectField f = fields.get(field);
		            recordToUpdate.put(field, storageMap.get(recordToUpdate.Id).get(field));
		        }
		        recordToUpdate.EF_Manager_Approval__c = 'Not Started';
		    }

		    delete storageList;
		}
	}

	// Copies approved, future values of a Billing Agreement onto the Billing Agreement record from Temp Storage and then deleted the temp record
	public static void copyValuesFromTempStorageOnBaApproval(List<EF_Billing_Agreement__c> approvedList, List<String> fieldList)
	{
		Set<Id> approvedIds = new Set<Id>();
		for(EF_Billing_Agreement__c approvedRecord : approvedList)
		{
			approvedIds.add(approvedRecord.Id);
			approvedRecord.Status__c = 'Active';
		}
		String query = 'select id, EF_Billing_Agreement__c, ';
		for(String f : fieldList)
		{
			query = query + f + ', ';
		}
		query = query.substring(0, query.length()-2);
		query = query + ' from EF_Approval__c where EF_Billing_Agreement__c in :approvedIds order by createddate desc';
		System.debug('***************** query: '+query);
		List<EF_Approval__c> storageList = Database.query(query);
		if(storageList.size() > 0)
		{
			Map<Id, EF_Approval__c> storageMap = new Map<Id, EF_Approval__c>();
			for(EF_Approval__c storageRecord : storageList)
			{
				if(storageMap.get(storageRecord.EF_Billing_Agreement__c) == null)
				{
					storageMap.put(storageRecord.EF_Billing_Agreement__c, storageRecord);
				}
			}

			Map<String, Schema.SobjectField> fields = EF_Billing_Agreement__c.getSObjectType().getDescribe().fields.getMap();
			for(EF_Billing_Agreement__c recordToUpdate : approvedList)
			{
		        for(String field : fieldList)
		        {
		            SObjectField f = fields.get(field);
		            recordToUpdate.put(field, storageMap.get(recordToUpdate.Id).get(field));
		        }
		        recordToUpdate.Manager_Approval__c = 'Not Started';
		    }

		    delete storageList;
		}
	}

	// Utilizes helper field (EF_Manager_Approval__c) that gets updated through the approval final actions to identify records that got approved
	public static List<Contract> identifyApprovedContracts(List<Contract> newValues, Map<Id, Contract> oldValues)
	{
		List<Contract> approvedList = new List<Contract>();
		for(Contract newValue : newValues)
		{
			if(newValue.EF_Manager_Approval__c != null)
			{
				if(newValue.EF_Manager_Approval__c.equalsIgnoreCase('Approved') && oldValues.get(newValue.Id).EF_Manager_Approval__c.equalsIgnoreCase('In Progress'))
				{
					approvedList.add(newValue);
				}
			}
		}
		return approvedList;
	}

	// Utilizes helper field (EF_Manager_Approval__c) that gets updated through the approval final actions to identify records that got rejected or were recalled
	public static List<Contract> identifyRejectedOrRecalledContracts(List<Contract> newValues, Map<Id, Contract> oldValues)
	{
		List<Contract> rejectedList = new List<Contract>();
		for(Contract newValue : newValues)
		{
			if(newValue.EF_Manager_Approval__c != null)
			{
				if((newValue.EF_Manager_Approval__c.equalsIgnoreCase('Rejected') || newValue.EF_Manager_Approval__c.equalsIgnoreCase('Recalled')) && oldValues.get(newValue.Id).EF_Manager_Approval__c.equalsIgnoreCase('In Progress'))
				{
					rejectedList.add(newValue);
				}
			}
		}
		return rejectedList;
	}

	public static List<EF_Billing_Agreement__c> identifyApprovedBillingAgreements(List<EF_Billing_Agreement__c> newValues, Map<Id, EF_Billing_Agreement__c> oldValues)
	{
		List<EF_Billing_Agreement__c> approvedList = new List<EF_Billing_Agreement__c>();
		for(EF_Billing_Agreement__c newValue : newValues)
		{
			if(newValue.Manager_Approval__c != null)
			{
				if(newValue.Manager_Approval__c.equalsIgnoreCase('Approved') && oldValues.get(newValue.Id).Manager_Approval__c.equalsIgnoreCase('In Progress'))
				{
					approvedList.add(newValue);
				}
			}
		}
		return approvedList;
	}

	public static List<EF_Billing_Agreement__c> identifyRejectedOrRecalledBillingAgreements(List<EF_Billing_Agreement__c> newValues, Map<Id, EF_Billing_Agreement__c> oldValues)
	{
		List<EF_Billing_Agreement__c> rejectedList = new List<EF_Billing_Agreement__c>();
		for(EF_Billing_Agreement__c newValue : newValues)
		{
			if(newValue.Manager_Approval__c != null)
			{
				if((newValue.Manager_Approval__c.equalsIgnoreCase('Rejected') || newValue.Manager_Approval__c.equalsIgnoreCase('Recalled')) && oldValues.get(newValue.Id).Manager_Approval__c.equalsIgnoreCase('In Progress'))
				{
					rejectedList.add(newValue);
				}
			}
		}
		return rejectedList;
	}

	// This method identifies if any of the "key elements" of a Billing Agreement record has changed. If even one has, proceed with Approval processing.
	// The htmlTable is set to be a rich-text helper field that can be placed in emails to approvers to list them what key elements changed their values.
    public static boolean identifyContractChanges(Contract newValues, Contract oldValues, List<String> fieldList, boolean isInsert)
    {
    	String htmlTable = '<table width="600px" border="1"><tr border="1"><th border="1">Field</th><th border="1">Old value:</th><th border="1">New value:</th></tr>';
    	boolean hasChanged = false;
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        if(isInsert)
        {
	        for(String field : fieldList)
	        {
	            SObjectField f = fields.get(field);
            	htmlTable = htmlTable + '<tr><td border="1">'+field+'</td><td border="1">--</td><td border="1">'+newValues.get(field)+'</td></tr>';
                hasChanged = true;
	        }
	    }
        else
        {
	        for(String field : fieldList)
	        {
	            SObjectField f = fields.get(field);
	            if(newValues.get(field) != oldValues.get(field))
	            {
	            	htmlTable = htmlTable + '<tr><td border="1">'+field+'</td><td border="1">'+oldValues.get(field)+'</td><td border="1">'+newValues.get(field)+'</td></tr>';
	                hasChanged = true;
	            }
	        }
	    }

        htmlTable = htmlTable + '</table>';
        if(hasChanged)
        {
        	newValues.EF_Requested_Changes__c = htmlTable;
        }
        return hasChanged;
    }

	// This method identifies if any of the "key elements" of a Billing Agreement record has changed. If even one has, proceed with Approval processing.
    // The htmlTable is set to be a rich-text helper field that can be placed in emails to approvers to list them what key elements changed their values.
    public static boolean identifyBillingAgreementChanges(EF_Billing_Agreement__c newValues, EF_Billing_Agreement__c oldValues, List<String> fieldList, boolean isInsert)
    {
    	String htmlTable = '<table width="600px" border="1"><tr border="1"><th border="1">Field</th><th border="1">Old value:</th><th border="1">New value:</th></tr>';
    	boolean hasChanged = false;
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        if(isInsert)
        {
        	for(String field : fieldList)
	        {
	            SObjectField f = fields.get(field);
            	htmlTable = htmlTable + '<tr><td border="1">'+field+'</td><td border="1">--</td><td border="1">'+newValues.get(field)+'</td></tr>';
                hasChanged = true;
	        }
        }
        else
        {
	        for(String field : fieldList)
	        {
	            SObjectField f = fields.get(field);
	            if(newValues.get(field) != oldValues.get(field))
	            {
	            	htmlTable = htmlTable + '<tr><td border="1">'+field+'</td><td border="1">'+oldValues.get(field)+'</td><td border="1">'+newValues.get(field)+'</td></tr>';
	                hasChanged = true;
	            }
	        }
	    }

        htmlTable = htmlTable + '</table>';
        if(hasChanged)
        {
        	newValues.Requested_Changes__c = htmlTable;
        }
        return hasChanged;
    }

    // After storing to-be-approved values into temp storage record, this method is run to get the fields set to their original values on the record that is not yet approved
    public static void rollbackPreviousValues(Contract newValues, Contract oldValues, List<String> fieldList)
    {
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            newValues.put(field, oldValues.get(field));
        }
    }

    public static void rollbackPreviousValues(EF_Billing_Agreement__c newValues, EF_Billing_Agreement__c oldValues, List<String> fieldList)
    {
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            newValues.put(field, oldValues.get(field));
        }
    }

    // Loop over for any changes to key elements and put any changes into a temp storage record along with the parent Contract ID
    public static EF_Approval__c fillTemporaryApprovalStorage(EF_Approval__c approvalStorageRecord, Contract newValues, List<String> fieldList)
    {
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            approvalStorageRecord.put(field, newValues.get(field));
        }
        approvalStorageRecord.put('Contract__c', newValues.Id);
        return approvalStorageRecord;
    }

    // Loop over for any changes to key elements and put any changes into a temp storage record along with the parent Billing Agreement ID
    public static EF_Approval__c fillTemporaryApprovalStorage(EF_Approval__c approvalStorageRecord, EF_Billing_Agreement__c newValues, List<String> fieldList)
    {
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            approvalStorageRecord.put(field, newValues.get(field));
        }
        approvalStorageRecord.put('EF_Billing_Agreement__c', newValues.Id);
        return approvalStorageRecord;
    }

    // Submit a record to approval
	public static List<Id> submitForApproval(Id recordId, Id userId, String processNameOrId)
	{
		List<ProcessInstance> isInApproval = [Select Id From ProcessInstance WHERE TargetObjectId = :recordId AND Status = 'Pending'];

		if(isInApproval.size() == 0)
		{
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(recordId);
			req.setSubmitterId(userId); 
			
			// Utilize a certain approval process and ignore any others that might match the entry criteria
			if(String.isNotBlank(processNameOrId))
			{
				req.setProcessDefinitionNameOrId(processNameOrId);
				req.setSkipEntryCriteria(true); 	
			}
			
			Approval.ProcessResult result = Approval.process(req);
			if(!result.isSuccess())
			{
				String msg = '';
				for(Database.Error err : result.getErrors())
				{
					msg += '\n'+err.getMessage();
				}
				msg = msg.substring(2);
				throw new ApprovalException(msg);
			}

			return result.getNewWorkitemIds();
		} else
		{
			return null;
		}
	}

    public class ApprovalException extends Exception {}
}
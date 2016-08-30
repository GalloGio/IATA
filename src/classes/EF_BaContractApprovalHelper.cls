public with sharing class EF_BaContractApprovalHelper
{

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

	public static void copyValuesFromTempStorageOnBaApproval(List<EF_Billing_Agreement__c> approvedList, List<String> fieldList)
	{
		Set<Id> approvedIds = new Set<Id>();
		for(EF_Billing_Agreement__c approvedRecord : approvedList)
		{
			approvedIds.add(approvedRecord.Id);
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

	public static List<EF_Billing_Agreement__c> identifyApprovedBillingAgreements(List<EF_Billing_Agreement__c> newValues, Map<Id, EF_Billing_Agreement__c> oldValues)
	{
		List<EF_Billing_Agreement__c> approvedList = new List<EF_Billing_Agreement__c>();
		for(EF_Billing_Agreement__c newValue : newValues)
		{
			if(newValue.Manager_Approval__c.equalsIgnoreCase('Approved') && oldValues.get(newValue.Id).Manager_Approval__c.equalsIgnoreCase('In Progress'))
			{
				approvedList.add(newValue);
			}
		}
		return approvedList;
	}

	public static List<EF_Billing_Agreement__c> identifyRejectedOrRecalledBillingAgreements(List<EF_Billing_Agreement__c> newValues, Map<Id, EF_Billing_Agreement__c> oldValues)
	{
		List<EF_Billing_Agreement__c> rejectedList = new List<EF_Billing_Agreement__c>();
		for(EF_Billing_Agreement__c newValue : newValues)
		{
			if((newValue.Manager_Approval__c.equalsIgnoreCase('Rejected') || newValue.Manager_Approval__c.equalsIgnoreCase('Recalled')) && oldValues.get(newValue.Id).Manager_Approval__c.equalsIgnoreCase('In Progress'))
			{
				rejectedList.add(newValue);
			}
		}
		return rejectedList;
	}

	// this method identifies if any of the "key elements" of a Billing Agreement record has changed. If even one has, proceed with Approval processing.
    public static boolean identifyBillingAgreementChanges(EF_Billing_Agreement__c newValues, EF_Billing_Agreement__c oldValues, List<String> fieldList)
    {
    	String htmlTable = '<table width="600px" border="1"><tr border="1"><th border="1">Field</th><th border="1">Old value:</th><th border="1">New value:</th></tr>';
    	boolean hasChanged = false;
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            if(newValues.get(field) != oldValues.get(field))
            {
            	htmlTable = htmlTable + '<tr><td border="1">'+field+'</td><td border="1">'+oldValues.get(field)+'</td><td border="1">'+newValues.get(field)+'</td></tr>';
                hasChanged = true;
            }
        }

        htmlTable = htmlTable + '</table>';
        if(hasChanged)
        {
        	System.debug('************ hasChanged: '+hasChanged + ' - ' + htmlTable);
        	newValues.Requested_Changes__c = htmlTable;
        } else
        {
        	System.debug('************ hasChanged: '+hasChanged + ' - ' + htmlTable);
        	//newValues.Requested_Changes__c = '';
        }
        return hasChanged;
    }

    public static void rollbackPreviousValues(EF_Billing_Agreement__c newValues, EF_Billing_Agreement__c oldValues, List<String> fieldList)
    {
        System.debug('*********** payment NEW: '+newValues.Payment_Method__c);
        System.debug('*********** payment OLD: '+oldValues.Payment_Method__c);
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            newValues.put(field, oldValues.get(field));
        }

        System.debug('*************** new value rolled back: '+newValues.Payment_Method__c);
    }

    public static EF_Approval__c fillTemporaryApprovalStorage(EF_Approval__c approvalStorageRecord, EF_Billing_Agreement__c newValues, List<String> fieldList)
    {
        Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
        
        for(String field : fieldList)
        {
            SObjectField f = fields.get(field);
            approvalStorageRecord.put(field, newValues.get(field));
        }
        approvalStorageRecord.put('EF_Billing_Agreement__c', newValues.Id);
        System.debug('********************** apr: '+approvalStorageRecord);
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
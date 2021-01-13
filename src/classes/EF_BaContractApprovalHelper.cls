public with sharing class EF_BaContractApprovalHelper
{

	public static void removeTempStorageRecordOnRecordRejection(List<sObject> rejectedList, String objectName)
	{
		Set<Id> rejectedIds = new Set<Id>();
		for(sObject rejectedRecord : rejectedList)
		{
			rejectedIds.add(rejectedRecord.Id);
		}
		String query = 'select id, Contract__c from EF_Approval__c where '+objectName+' in :rejectedIds';

		List<EF_Approval__c> storageList = Database.query(query);
		if(storageList.size() > 0)
		{
			for(sObject recordToUpdate : rejectedList)
			{
				recordToUpdate.put('Manager_Approval__c', 'Not Started');
				recordToUpdate.put('Requested_Changes__c', '');
			}

			delete storageList;
		}
	}

	public static void copyValuesFromTempStorageOnRecordApproval(List<sObject> approvedList, List<String> fieldList, String objectName)
	{
		Set<Id> approvedIds = new Set<Id>();
		for(sObject approvedRecord : approvedList)
		{
			approvedIds.add((Id) approvedRecord.get('Id'));
			approvedRecord.put('EF_Status__c', 'Active');
		}

		String query = 'select id, EF_Billing_Agreement__c, Contract__c, EF_Material_Line_Item__c, EF_Location_Currency__c, ';
		for(String f : fieldList)
		{
			query = query + f + ', ';
		}
		query = query.substring(0, query.length()-2);
		query = query + ' from EF_Approval__c where ' + objectName + ' in :approvedIds order by createddate desc';
		System.debug('***************** query: '+query);
		List<EF_Approval__c> storageList = Database.query(query);
		if(storageList.size() > 0)
		{
			Map<Id, EF_Approval__c> storageMap = new Map<Id, EF_Approval__c>();
			for(EF_Approval__c storageRecord : storageList)
			{
				if(storageMap.get((Id) storageRecord.get(objectName)) == null)
				{
					storageMap.put((Id) storageRecord.get(objectName), storageRecord);
				}
			}


			Map<String, Schema.SobjectField> fields = approvedList.get(0).getSObjectType().getDescribe().fields.getMap();
			for(sObject recordToUpdate : approvedList)
			{
				for(String field : fieldList)
				{
					recordToUpdate.put(field, storageMap.get(recordToUpdate.Id).get(field));
				}
				recordToUpdate.put('Manager_Approval__c', 'Not Started');
				recordToUpdate.put('Requested_Changes__c', '');
			}

			delete storageList;
		}
	}


	// Utilizes helper field (EF_Manager_Approval__c) that gets updated through the approval final actions to identify records that got approved
	public static List<sObject> identifyApprovedRecords(List<sObject> newValues, Map<Id, sObject> oldValues)
	{
		List<sObject> approvedList = new List<sObject>();
		for(sObject newValue : newValues)
		{
			if((String) newValue.get('Manager_Approval__c') != null)
			{
				String newApproval = (String) newValue.get('Manager_Approval__c');
				Id newId = (Id) newValue.get('Id');
				String oldApproval = (String) oldValues.get(newId).get('Manager_Approval__c');

				if(newApproval.equalsIgnoreCase('Approved') && oldApproval.equalsIgnoreCase('In Progress'))
				{
					approvedList.add(newValue);
				}
			}
		}
		return approvedList;
	}

	// Utilizes helper field (EF_Manager_Approval__c) that gets updated through the approval final actions to identify records that got rejected or were recalled
	public static List<sObject> identifyRejectedOrRecalledRecords(List<sObject> newValues, Map<Id, sObject> oldValues)
	{
		List<sObject> rejectedList = new List<sObject>();
		for(sObject newValue : newValues)
		{
			if((String) newValue.get('Manager_Approval__c') != null)
			{
				String newApproval = (String) newValue.get('Manager_Approval__c');
				Id newId = (Id) newValue.get('Id');
				String oldApproval = (String) oldValues.get(newId).get('Manager_Approval__c');

				if((newApproval.equalsIgnoreCase('Rejected') || newApproval.equalsIgnoreCase('Recalled')) && oldApproval.equalsIgnoreCase('In Progress'))
				{
					rejectedList.add(newValue);
				}
			}
		}
		return rejectedList;
	}

	public static boolean identifyRecordChanges(sObject newValues, sObject oldValues, List<String> fieldList, boolean isInsert)
	{
		String htmlTable = '<table width="600px" border="1"><tr border="1"><th border="1">Field</th><th border="1">Existing value:</th><th border="1">Requested value:</th></tr>';
		boolean hasChanged = false;
		Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
		if(isInsert)
		{
			for(String field : fieldList)
			{
				htmlTable = htmlTable + '<tr><td border="1">'+field+'</td><td border="1">--</td><td border="1">'+newValues.get(field)+'</td></tr>';
				hasChanged = true;
			}
		}
		else
		{
			for(String field : fieldList)
			{
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
			newValues.put('Requested_Changes__c', htmlTable);
		}
		return hasChanged;
	}

	// Loop over for any changes to key elements and put any changes into a temp storage record along with the parent Contract ID
	public static EF_Approval__c fillTemporaryApprovalStorage(EF_Approval__c approvalStorageRecord, sObject newValues, List<String> fieldList, String fieldToUse)
	{
		Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();

		for(String field : fieldList)
		{
			approvalStorageRecord.put(field, newValues.get(field));
		}
		approvalStorageRecord.put(fieldToUse, newValues.Id);
		return approvalStorageRecord;
	}

	public static void rollbackPreviousValues(sObject newValues, sObject oldValues, List<String> fieldList)
	{
		Map<String, Schema.SobjectField> fields = newValues.getSObjectType().getDescribe().fields.getMap();
		for(String field : fieldList)
		{
			newValues.put(field, oldValues.get(field));
		}
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
			try
			{
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
				} catch(Exception e)
				{
					System.debug('************ approval error: '+e);
					return null;
				}
		} else
		{
			return null;
		}
	}

	public class ApprovalException extends Exception {}
}

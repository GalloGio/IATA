public class IEC_EventRelease_Dom
{
	private List<IEC_Event_Release__c> newList = new List<IEC_Event_Release__c>();
	private List<IEC_Event_Release__c> oldList = new List<IEC_Event_Release__c>();
	private Map<Id, IEC_Event_Release__c> newMap = new Map<Id, IEC_Event_Release__c>();
	private Map<Id, IEC_Event_Release__c> oldMap = new Map<Id, IEC_Event_Release__c>();

	public static void triggerHandler()
	{
		IEC_EventRelease_Dom exe = new IEC_EventRelease_Dom();

		if (trigger.isBefore)
		{
			if (trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();
			else if (trigger.isDelete) exe.onBeforeDelete();
		}
		else if (trigger.isAfter)
		{
			if (trigger.isInsert) exe.onAfterInsert();
			else if (trigger.isUpdate) exe.onAfterUpdate();
		}
	}

	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable)
	{
		if (newDataAvailable)
		{
			newList = (List<IEC_Event_Release__c>) trigger.new;
			newMap = (Map<Id, IEC_Event_Release__c>) trigger.newMap;
		}

		if (oldDataAvailable)
		{
			oldList = (List<IEC_Event_Release__c>) trigger.old;
			oldMap = (Map<Id, IEC_Event_Release__c>) trigger.oldMap;
		}
	}

	private void onBeforeDelete()
	{
		getData(false, true);

		IEC_EventRelease_Svc.preventDeletion(oldList);
	}

	private void onBeforeInsert()
	{
		getData(true, false);

		IEC_EventRelease_Svc.validateProducts(newList);
	}

	private void onBeforeUpdate()
	{
		getData(true, true);

		Set<Id> setEventToSkip = IEC_EventRelease_Svc.skipChangedRecord(oldList, newList);
		if (setEventToSkip.size() != newList.size())
			IEC_EventRelease_Svc.validateProducts(newList, setEventToSkip);
		//List<IEC_Event_Release__c> lstChangedRecord = IEC_EventRelease_Svc.keepCoreChangedRecord(oldList, newList);
		//if (lstChangedRecord.size() > 0)
			//IEC_EventRelease_Svc.validateProducts(lstChangedRecord);
	}

	private void onAfterInsert()
	{
		getData(true, false);

		//Create order for renewal
		IEC_EventRelease_Svc.generateAutoRenewals(newList, null);
	}

	private void onAfterUpdate()
	{
		getData(true, true);

		//generate AutoRenewals Orders
		Set<Id> setEventToSkip = IEC_EventRelease_Svc.skipChangedRecord(oldList, newList);

		if (setEventToSkip.size() != newList.size()){
			IEC_EventRelease_Svc.generateAutoRenewals(newList, oldMap, setEventToSkip);
		}
		//List<IEC_Event_Release__c> lstChangedRecord = IEC_EventRelease_Svc.keepCoreChangedRecord(oldList, newList);
		//if (lstChangedRecord.size() > 0)
			//IEC_EventRelease_Svc.generateAutoRenewals(lstChangedRecord, oldMap);
	}
}

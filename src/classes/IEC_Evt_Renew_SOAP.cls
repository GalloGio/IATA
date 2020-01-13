// Test coverage is done in the IEC_Evt_Renew_ProcessPmt_Batch_Test
global class IEC_Evt_Renew_SOAP {
	// Used by the button "Release" on the IEC_Event_Release__c page layout to process payments
	webservice static void Event_Release(Id idEventRelease)
	{
		//*** update status
		update (new IEC_Event_Release__c(Id=idEventRelease, Processing_Status__c='Payment is processing...'));

		//*** launch process
		Database.ExecuteBatch(new IEC_Evt_Renew_ProcessPmt_Batch(idEventRelease),Utility.getIntegerSetting('IEC evt renewal processPmt batch size'));
	}

	webservice static void eventRegenerateRelease(Id eventReleaseId){

		//Validate that Product number is not null
		map<Id,IEC_Event_Release__c> eventReleaseMap = new IEC_EventRelease_Sel().getEventReleaseById(new set<Id>{eventReleaseId});
		IEC_Event_Release__c eventRelease = eventReleaseMap.values()[0];
		if(eventRelease.Product_Number__c != null && !eventRelease.Released__c){
			eventRelease.Sales_Amout__c = null;
			eventRelease.Sales_Quantity__c = null;
			eventRelease.Nb_Customer__c = null;
			update eventRelease;
			Database.executeBatch(new IEC_ReleaseLogCleanup_Batch(eventReleaseMap.values(), 'ClearAutoRenewals'));
		}

	}


	/****************************************************************************************************
		Created by Thai 2016-04-19
			Reprocess errors in release
	****************************************************************************************************/
	webservice static void reprocessError(Id idEventRelease)
	{
		Set<Id> setSubscriptionId = new Set<Id>();
		Set<Id> setOrderId = new Set<Id>();

		//*** update status
		update (new IEC_Event_Release__c(Id=idEventRelease, Processing_Status__c='Reprocessing errors...'));

		//*** build sets of subscriptions and/or orders to reprocess
		for (IEC_Event_Release_Log__c log : [select Order__c, Subscription__c from IEC_Event_Release_Log__c where IEC_Event_Release__c = :idEventRelease])
		{
			if (log.Order__c == null) {
				if (log.Subscription__c != null){ setSubscriptionId.add(log.Subscription__c); }
			}
			else
				setOrderId.add(log.Order__c);
		}
		if (setSubscriptionId.size() == 0 && setOrderId.size() == 0)
		{
			update (new IEC_Event_Release__c(Id=idEventRelease, Processing_Status__c=null)); return;
		}

		//*** remove subscriptions and/or orders already had order processed
		for (Order o : [select Id, IEC_Event_Subscription__c, Status
						from Order
						where IEC_Event_Release__c = :idEventRelease and (Id in :setOrderId or IEC_Event_Subscription__c in :setSubscriptionId)])
		{
			setSubscriptionId.remove(o.IEC_Event_Subscription__c);
			if (o.Status != 'New') { setOrderId.remove(o.Id); }
		}

		//*** reprocess
		if (setSubscriptionId.size() > 0)
		{
			Map<Id, IEC_Event_Release__c> mapId_EventRelease = new IEC_EventRelease_Sel().getEventReleaseById(new set<Id>{idEventRelease});
			Database.executeBatch(new IEC_Event_Renewal_CreateOrders_Batch(mapId_EventRelease.get(idEventRelease), '\'' + String.join(new List<Id>(setSubscriptionId), '\',\'') + '\''), Utility.getIntegerSetting('IEC Event renewal batch size'));
		}
		else if (setOrderId.size() > 0)
			Database.executeBatch(new IEC_Evt_Renew_GetSAPFreightTax_Batch(idEventRelease, true), 1);
		else
			update (new IEC_Event_Release__c(Id=idEventRelease, Processing_Status__c=null));
	} //*** end of "reprocessError"


}

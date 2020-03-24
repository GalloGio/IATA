/*
	Batch to get orderItem Freight and Tax from SAP
*/
global class IEC_Evt_Renew_GetSAPFreightTax_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	private Id eventReleaseId;
		private Boolean isReprocessingJob;

	global IEC_Evt_Renew_GetSAPFreightTax_Batch(Id evtReleaseId, Boolean isReprocessingJob) {
		eventReleaseId = evtReleaseId;
		this.isReprocessingJob = isReprocessingJob;
	}

	//Update the Event Release status when the tax and shipping calculation start
	public void setProcessingStatus(Set<Id> releaseIds)
		{
				List<IEC_Event_Release__c> releasesToUpdate = [SELECT Id, Processing_Status__c FROM IEC_Event_Release__c WHERE Id IN:releaseIds];
				for(IEC_Event_Release__c release : releasesToUpdate)
						release.Processing_Status__c = 'Auto Renew Shipping and tax is processing ....';

				update releasesToUpdate;
		}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		setProcessingStatus(new Set<Id>{eventReleaseId});
		String queryLimit = '';
		if(Test.isRunningTest())
			queryLimit = ' Limit 1';

		return Database.getQueryLocator(
			' SELECT Id, BillToContactId FROM Order' +
			' WHERE IEC_Event_Release__c = \'' + eventReleaseId + '\' and Status = \'New\' ' + queryLimit
		);
	}

	 	global void execute(Database.BatchableContext BC, List<Order> scope) {

	 		if(!scope.isEmpty()){
	 			//List of error to log
	 			List<IEC_Event_Release_Log__c> lstErrors = new List<IEC_Event_Release_Log__c>();

	 			for(Order o : scope){
	 				//Set the order Items tax and shipping
	 				String response = Order_Svc.getSAP_Freight_Tax(o.Id);
	 				try {
	 					//Get the orderItem with tax and shipping if no error
								List<OrderItem> lstOrderItem = (List<OrderItem>) JSON.deserializeStrict(response, List<OrderItem>.class);
						} catch (Exception e) {
							//Log Error if the tax and shipping calculation failed
							lstErrors.add(
												IEC_EventReleaseLog_Svc.logError(
														'Error for calculation tax and shipping ', JSON.serialize(response), o.Id, eventReleaseId, 'Calculate S&T', o.BillToContactId, false
												)
										);
						}
		 		}

		 		//Log error
		 		if(!lstErrors.isEmpty())
		 			insert lstErrors;

	 		}

	}

	global void finish(Database.BatchableContext BC) {
		if (!isReprocessingJob)
		{
			//Get the last update of tax and shipping before update the release status
					IEC_Event_Release__c releaseToUpdate = [select id, Processing_Status__c from IEC_Event_Release__c where id = :eventReleaseId ];
			releaseToUpdate.Processing_Status__c = '';
			update releaseToUpdate;

						//*** send notification to creator
						releaseToUpdate = [select Name, CreatedBy.Email, CreatedBy.FirstName from IEC_Event_Release__c where Id = :eventReleaseId limit 1];
						if(releaseToUpdate.CreatedBy.Email != null && !releaseToUpdate.CreatedBy.Email.endsWithIgnoreCase('.inactive')){
							Utility.sendEmail(new List<String> {releaseToUpdate.CreatedBy.Email}
														, 'Process for event release "' + releaseToUpdate.Name + '" is complete'
														, 'Dear ' + releaseToUpdate.CreatedBy.FirstName + '<br/><br/>'
															+ 'The process launched for event release "' + releaseToUpdate.Name + '" was complete.  For more detail, click on this link '
															+ '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + eventReleaseId + '">' + releaseToUpdate.Name + '</a>.<br/><br/>'
															+ 'Best regards,<br/>'
															+ 'eCommerce Support Team<br/>'
														, true, null);
						}
		}
		else
			//*** when reprocessing, perform payment to complete the cycle
			Database.ExecuteBatch(new IEC_Evt_Renew_ProcessPmt_Batch(eventReleaseId));
	}

}

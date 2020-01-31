/****************************************************************************************************
		Created by Kevin Ky 2016-08-19
				Batch to get orderItem Freight and Tax from SAP
****************************************************************************************************/
global class IEC_CampaignMembers_SAPFreightTax_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	String campaigId;
		String campaignNumber;

	global IEC_CampaignMembers_SAPFreightTax_Batch(String campaignId, String cNumber) {
		campaigId = campaignId;
				campaignNumber = cNumber;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'SELECT Id, BillToContactId, Campaign__c FROM Order where Campaign__c =\'' + campaigId + '\' and Type = \'Renewal Notification\' ';
		return Database.getQueryLocator(query);
	}

	 	global void execute(Database.BatchableContext BC, List<Order> scope) {

		List<IEC_Renewal_notice_log__c> lstErrorLog = new List<IEC_Renewal_notice_log__c>();

		if(!scope.isEmpty()){
			List<Order> failureOrders = new List<Order>();
			for(Order o : scope){
	 				//Set the order Items tax and shipping
	 				String response = Order_Svc.getSAP_Freight_Tax(o.Id);

	 				try {
	 					//Get the orderItem with tax and shipping if no error
								List<OrderItem> lstOrderItem = (List<OrderItem>) JSON.deserializeStrict(response, List<OrderItem>.class);
						} catch (Exception e) {
							//Log Error if the tax and shipping calculation failed
							lstErrorLog.add(
												IEC_RenewalNotice_Svc.logError('Error for calculation tax and shipping', JSON.serialize(response), o.Id, o.Campaign__c, o.BillToContactId, false)
										);

										o.Type = 'Renewal Notice failure';
										failureOrders.add(o);
						}
		 		}

		 		//Log renewal notice errors
		 		if(lstErrorLog.size() > 0) insert lstErrorLog;

		 		//Update orders
		 		if(!failureOrders.isEmpty()) update failureOrders;
		}

	}

	global void finish(Database.BatchableContext BC) {

		try{
						//Update the Campaign Renewal notice generated field
						Campaign campaign = Campaign_Sel.getCampaignById(campaigId);
						campaign.Renewal_notice_generated__c = Datetime.now();
						update campaign;

						//Send notification to the loggin user
						String templateId = Utility.getTextSetting('loginUser campaign notice notification');

						list<EmailTemplate> templates = Utility.getEmailTemplatebyTemplateId((Id) templateId);
						if(templates != null && templates.size() > 0){
								//Send notification to login user
								CampaignMember_Svc.sendBatchFinishNotification(new List<String> {UserInfo.getUserEmail()}, campaignNumber, UserInfo.getName(), templates[0]);
						}

				}catch(Exception ex){
						System.debug('Batch error ' + ex.getMessage());
				}

	}

}

/****************************************************************************************************
	Created by Kevin Ky 2015-09-23

****************************************************************************************************/
public without sharing class Order_Dom {

	/****************************************************************************************************
			Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
		//*** instantiate the domain class to prevent too many static methods
		Order_Dom exe = new Order_Dom();

		//*** call handler method corresponding to trigger event
		if (trigger.isBefore) {
				 /*if (trigger.isInsert) exe.onBeforeInsert();
			else if (trigger.isUpdate) exe.onBeforeUpdate();*/
			if(trigger.isUpdate) exe.onBeforeUpdate();
			else if (trigger.isDelete) exe.onBeforeDelete();
		} else if (trigger.isAfter) {
			if (trigger.isInsert) exe.onAfterInsert();
			else if (trigger.isUpdate) exe.onAfterUpdate();
			else if (trigger.isDelete) exe.onAfterDelete();
		}
	} //*** end of "triggerHandler"


	/****************************************************************************************************
			Data variables
	****************************************************************************************************/
	private List<Order> newList = new List<Order>();
	private List<Order> oldList = new List<Order>();
	private Map<Id, Order> newMap = new Map<Id, Order>();
	private Map<Id, Order> oldMap = new Map<Id, Order>();

	/****************************************************************************************************
			Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
			newList = (List<Order>) trigger.new;
			newMap = (Map<Id, Order>) trigger.newMap;
		}
		if (oldDataAvailable) {
			oldList = (List<Order>) trigger.old;
			oldMap = (Map<Id, Order>) trigger.oldMap;
		}
	} //*** end of "getData"

	/****************************************************************************************************
			Method for event
	****************************************************************************************************/
	private void onBeforeUpdate() {

		//This is a custom setting for order max upload
		//Avoid the order triggers to fire when mass upload Orders
		if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;

		getData(true, true);
		//Prevent modification to some fields at some Status
		Order_Svc.preventModification(newMap,oldMap);

		// Ecommerce Enhancements R2
		Order_Svc.setOrderAcceptedPaymentMethods(newList, oldMap);
	}

	private void onBeforeDelete() {

		//This is a custom setting for order max upload
		//Avoid the order triggers to fire when mass upload Orders
		if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;

		getData(false, true);
		//Prevent Order deletion at some Status
		Order_Svc.preventDeletion(oldList);
	}

	private void onAfterInsert() {
		// getData(true, true);
	}

	private void onAfterUpdate() {
		List<ICG_Notification__c> notifications = new List<ICG_Notification__c>();
		//This is a custom setting for order max upload
		//Avoid the order triggers to fire when mass upload Orders
		if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;

		getData(true, true);

		//*** set order items to paid if order is paid
		Order_Svc.setOrderItemToPaid(newList, oldList);

		//Email notification when the Order is sold
		Order_Svc.sendEmailWhenOrderIsSold(newMap, oldMap);

		//Email notification when the Order is Payment Error
		Order_Svc.sendEmailWhenPaymentDeclined(newMap, oldMap);

		//-- Call SAP SalesOrder Interface if status become Ready for SAP or PAID
		Order_Sel orderSelector = new Order_Sel();
		Set<Id> orderIds = orderSelector.findOrders4SAP(newList, oldList);
		if(orderIds.size() > 0)
		{
			System.enqueueJob(new SapSalesOrContractOrders_Queueable(orderIds));
			//System.enqueueJob(new IEC_ContractOrdersQueueable(orderIds));  //*** failed with error "Too many async calls created" from batch
		}

		// Activate product access for paid orders
		new IECProductAccess_Svc().ActivateProductAccessForPaidOrders(newList, oldMap);

		//Update IEC Event Subscription for Event renewal
		Order_Svc.updateEventSubcriptions(newList, oldMap);

		//Update iec sap invoice status (Zuora Ready) when order is Payment Confirmed INC295559
		Order_Svc.sapInvoiceStatusUpdate(newMap, oldMap);

		// GxA Remote Validation Integration
		CW_GxA_Amazon_S3__c cfgGxaS3 = CW_GxA_Amazon_S3__c.getOrgDefaults();
		String startProcessStatus = cfgGxaS3.Order_Status_To_Start_Process__c != null ? cfgGxaS3.Order_Status_To_Start_Process__c : 'RV_Complete';
		String readyForUserFulfillmentStatus = cfgGxaS3.Order_Status_Pending_Fulfillment__c != null ? cfgGxaS3.Order_Status_Pending_Fulfillment__c : 'RV_Created';
		String rvSubmittedStatus = cfgGxaS3.Order_Status_Submitted__c != null ? cfgGxaS3.Order_Status_Submitted__c : 'RV_WIP';
		String needsCorrectionStatus = cfgGxaS3.Order_Status_Needs_Correction__c != null ? cfgGxaS3.Order_Status_Needs_Correction__c : 'RV_NeedsCorrection';
		if (String.isNotBlank(cfgGxaS3.Order_Status_To_Start_Process__c)) {
			List<Id> gxaOrderIds = new List<Id>();
			List<Id> pendingToFulfillOrderIds = new List<Id>();
			List<Id> submittedOrderIds = new List<Id>();
			List<Id> needsCorrectionOrderIds = new List<Id>();
			for (Order currentOrder : newMap.values()) {
				if(String.isNotBlank(currentOrder.Remote_Validation_Status__c) && (oldMap == null || oldMap.get(currentOrder.Id).Remote_Validation_Status__c != currentOrder.Remote_Validation_Status__c)){
					if (currentOrder.Remote_Validation_Status__c == startProcessStatus) {
						gxaOrderIds.add(currentOrder.Id);
					}
					else if (currentOrder.Remote_Validation_Status__c == readyForUserFulfillmentStatus) {
						pendingToFulfillOrderIds.add(currentOrder.Id);
					}
					else if (currentOrder.Remote_Validation_Status__c == rvSubmittedStatus) {
						submittedOrderIds.add(currentOrder.Id);
					}
					else if (currentOrder.Remote_Validation_Status__c == needsCorrectionStatus) {
						needsCorrectionOrderIds.add(currentOrder.Id);
					}
				}
			}
			if (gxaOrderIds.size() > 0) {
				System.enqueueJob(new CW_GxA_Integration_Queueable(gxaOrderIds));
				List<OrderItem> orderItems = [Select Id, Product2.Name, Station__r.Name, Station__r.RecordType.Name, Station__r.Formatted_Address__c, CreatedById, CreatedBy.Email, CreatedBy.ContactId from OrderItem where Product2.Smart_Facility_Remote_Validation__c = true and OrderId IN :gxaOrderIds];
				for(OrderItem orditem : orderItems){
					//Insert System Notification
					if(ordItem.CreatedBy.ContactId != null && ordItem.Station__r != null){
						String subject = orditem.Product2.Name + ' results for ' + ordItem.Station__r.Name + ', ' + ordItem.Station__r.RecordType.Name + ' ready';
						String body = orditem.Product2.Name + ' results for ' + ordItem.Station__r.Name + ', ' + ordItem.Station__r.RecordType.Name + ', ' + ordItem.Station__r.Formatted_Address__c + ' ready';
						notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String>{orditem.CreatedBy.ContactId}, ordItem.Station__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
					}
					
					//Send email to who purchased
					CW_Utilities.sendEmailTemplate('Results_to_User_appro_by_IATA',orditem.Id, orditem.CreatedById, new List<String>{orditem.createdBy.Email});
				}
			}
			List<String> whoEmailIata = new List<String>();
			for(User u : CW_Utilities.getIATAStakeHoldersUsersList()) {
				if(u.email != null){
					whoEmailIata.add(u.email);
				}
			}
			if (pendingToFulfillOrderIds.size() > 0) {
				List<OrderItem> orderItems = [Select Id, Product2.Name, Station__r.Name, Station__r.RecordType.Name, Station__r.Formatted_Address__c, CreatedById, CreatedBy.Email from OrderItem where Product2.Smart_Facility_Remote_Validation__c = true and OrderId IN : pendingToFulfillOrderIds];
				for(OrderItem orditem : orderItems){
					//Insert System Notification
					if(ordItem.CreatedBy.ContactId != null && ordItem.Station__r != null){
						String subject = orditem.Product2.Name + ' for ' + ordItem.Station__r.Name+ ' now ready to be completed';
						String body = orditem.Product2.Name + ' for ' + ordItem.Station__r.Name + ', ' + ordItem.Station__r.Formatted_Address__c  + ' now ready to be completed';
						notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String>{orditem.CreatedBy.ContactId}, ordItem.Station__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
					}

					//Send email to who purchased
					CW_Utilities.sendEmailTemplate('Completion_to_User_link_ready',orditem.Id, orditem.CreatedById, new List<String>{orditem.createdBy.Email});
					//Send email to IATA
					CW_Utilities.sendEmailTemplate('Completion_to_IATA_link_ready',orditem.Id, orditem.CreatedById, whoEmailIata);
				}
			}
			if (submittedOrderIds.size() > 0) {
				List<OrderItem> orderItems = [Select Id, Station__r.Name, Station__r.RecordType.Name, Station__r.Formatted_Address__c, CreatedById, CreatedBy.Email from OrderItem where Product2.Smart_Facility_Remote_Validation__c = true and OrderId IN :submittedOrderIds];
				for(OrderItem orditem : orderItems){
					//Send email to who purchased
					CW_Utilities.sendEmailTemplate('Completion_to_User_questionnaire_sub',orditem.Id, orditem.CreatedById, new List<String>{orditem.createdBy.Email});
					//Send email to IATA
					CW_Utilities.sendEmailTemplate('Completion_to_IATA_when_is_subm',orditem.Id, orditem.CreatedById, whoEmailIata);
				}
			}
			if (needsCorrectionOrderIds.size() > 0) {
				List<OrderItem> orderItems = [Select Id, Product2.Name, Station__r.Name, Station__r.RecordType.Name, Station__r.Formatted_Address__c, CreatedById, CreatedBy.Email from OrderItem where Product2.Smart_Facility_Remote_Validation__c = true and OrderId IN :needsCorrectionOrderIds];
				for(OrderItem orditem : orderItems){
					//Insert System Notification
					if(ordItem.CreatedBy.ContactId != null && ordItem.Station__r != null){
						String subject = orditem.Product2.Name + ' results for ' + ordItem.Station__r.Name + ', ' + ordItem.Station__r.RecordType.Name + ' ready';
						String body = orditem.Product2.Name + ' results for ' + ordItem.Station__r.Name + ', ' + ordItem.Station__r.RecordType.Name + ', ' + ordItem.Station__r.Formatted_Address__c + ' ready';
						notifications.addAll(CW_NotificationsController.setNotificationCustom(subject, body, 'Requested', new List<String>{orditem.CreatedBy.ContactId}, ordItem.Station__r, CW_NotificationsController.RT_NOTIFICATION_PRIVATE_AREA, false));
					}
					//Send email to who purchased
					CW_Utilities.sendEmailTemplate('Results_to_User_rejec_by_IATA',orditem.Id, orditem.CreatedById, new List<String>{orditem.createdBy.Email});
				}
			}
		}

		if(notifications.size() > 0){
			Database.insert(notifications);
		}
	}

	private void onAfterDelete() {
		//getData(true, true);
	}

	/*private Set<Id> findOrders4SAP()
	{
		Set<Id> orderIds = new Set<Id>();
		for(Integer x=0; x < newList.size(); x++)
		{
			Order newOrd = newList[x];
			Order oldOrd = oldList[x];

			if((newOrd.Status != oldOrd.Status) && (newOrd.Status == IECConstants.ORDER_STATUS_READY_FOR_SAP || newOrd.Status == IECConstants.ORDER_STATUS_PAID))
			{
				orderIds.add(newOrd.Id);
			}
		}

		return orderIds;
	}*/

}
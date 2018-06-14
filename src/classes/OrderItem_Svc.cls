/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
****************************************************************************************************/
public without sharing class OrderItem_Svc {
	
	/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
    	Prevent Order deletion with some status
	****************************************************************************************************/
	public static void preventDeletion(List<OrderItem> oldOrderList){
		
		set<Id> OrderIds = new set<Id>();
		map<Id,String> orderId_Status = new map<Id,String>();
		//Get the corresponding Order ids
		for(OrderItem oi : oldOrderList){
			OrderIds.add(oi.OrderId);
		}
		
		//Get the corresponding Order status by order id
		if(OrderIds.size() > 0){
			orderId_Status = Order_Sel.getOrderStatusById(OrderIds);
		}

		//Get the list of status to prevent the deletion
		List<String> statusList = Order_Svc.getStatusToPreventDeletion();
		Set<String> statusSet = new Set<String>(statusList);

		for(OrderItem oi : oldOrderList){
			String orderStatus = orderId_Status.get(oi.OrderId);
			if(orderStatus != null){
				//Show the error message
				if(!statusSet.contains(orderStatus)) oi.AddError(String.format(Label.Order_prevent_deletion_message,new String[]{'Order item',orderStatus}));
			}
		}
		
	}
	
	/****************************************************************************************************
    Created by Kevin Ky 2015-09-30
    	Prevent some Order fields modification at some Status
	****************************************************************************************************/
	public static void preventModification(Map<Id, OrderItem> newMap,Map<Id, OrderItem> oldMap){
        if (System.isFuture() || System.isBatch() || System.isScheduled())
            return;
		
		set<String> FieldsToForbidModification = new set<String>();
        
        Set<String> orderItemFieldsAllowModification = new set<String>();
        List<String> lstFields = Utility.getSeqTextSetting('OrderItem fields allow modification',',').split(',');
        for(String str : lstFields){
            orderItemFieldsAllowModification.add(str.toLowerCase());
        }

        map<String,String> orderFields = Utility.getOrderItemLabelByApiName();
        for(String field:orderFields.keySet()){
            if(!orderItemFieldsAllowModification.contains(field)){
                FieldsToForbidModification.add(field);
            }
        }

		//Get the Order Status
		set<Id> orderIds = new set<Id>();
		for(OrderItem oi : newMap.values()){
			orderIds.add(oi.OrderId);
		}
		
		map<Id,String> orderId_Status = new map<Id,String>();
		//Get the corresponding Order status by order id
		if(OrderIds.size() > 0){
			orderId_Status = Order_Sel.getOrderStatusById(OrderIds);
		}
		
		//Get the list of Status that some modification are not allows
		set<String>	orderStatus = new set<String>(Order_Svc.getStatusToPreventModification());

		Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
		
		for(OrderItem oi : newMap.values()){
			//Get the order status
			List<String> userProfiles = Order_Svc.getUserProfileAllowOrderModification();
            set<String> profiles = new set<String>(userProfiles);

			String status = orderId_Status.get(oi.OrderId);
			if(!profiles.contains(profileName)){
				if(!orderStatus.contains(status)){
					//allows some field to be modified
                    for(String field : FieldsToForbidModification){
                        if(newMap.get(oi.Id).get(field) != oldMap.get(oi.Id).get(field) ){
                            oi.AddError(' ' + Label.Order_prevent_modification_message);
                            break;
                        }
                    }
				}
			}

			
		}
		
	}

	//Send notification when OrderItems was been shipped
	public static void orderItemShippedNotification(Map<String, OrderItem> mapMaterial_OrderItem){

        map<String, OrderItem> trackingNumber_OrderItem = new map<String, OrderItem>();

        for(OrderItem oi : mapMaterial_OrderItem.values()){
            if(!trackingNumber_OrderItem.containsKey(oi.Carrier_Tracking_Number__c)){
                trackingNumber_OrderItem.put(oi.Carrier_Tracking_Number__c, oi);
            }
        }

        if(trackingNumber_OrderItem.size() > 0){
            List<Mail_DTO> lstMails = new List<Mail_DTO>();
	    	for(OrderItem oi : trackingNumber_OrderItem.values()){
	    		Mail_DTO mail = new Mail_DTO();
	    		mail.targetObjectId = oi.Order.BillToContactId;
	    		mail.whatId = oi.Id;
                mail.orgWideEmailAddressId = Utility.getTextSetting('Ecom OrgWideEmailAddressId for notif');
	    		mail.templateId = Utility.getTextSetting('Product shipped template Id');
	    		mail.recipients = new List<String>();
	    		//mail.recipients.add(oi.Order.ShipToContact_Email__c);
	    		mail.recipients.add(oi.Order.ShipToContact_Email__c);
	    		if(oi.Order.ShipToContact_Email__c != null)
	    			lstMails.add(mail);
	    	}

	    	try{
	    		if(lstMails.size() > 0)
					Utility.sendBulkEmails(lstMails);
			}catch(Exception ex){
				system.debug('Error sendToCustomerShippedNotification() ' + ex.getMessage());
			}
        }

    }

    //Insert orderItems or log error if insertion failed
    public static set<Id> insertOrderItems(List<OrderItem> itemsToInsert){

    	set<Id> orderItemIds = new set<Id>();
        List<IEC_Error_Log__c> lstErrors = new List<IEC_Error_Log__c>();

        //Insert orderItems
        if(itemsToInsert.size() > 0){

            List<Database.SaveResult> srList = Database.insert(itemsToInsert, false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    orderItemIds.add(sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                   
                        lstErrors.add(IECErrorLogger.createErrorLog('Order_Svc/createSapSalesOrders', JSON.serialize(err), err.getMessage(), String.valueOf(err.getStatusCode())));
                    }
                }
            }
        }

        //Log errors
        if(lstErrors.size() > 0) IECErrorLogger.logErrors(lstErrors);

        return orderItemIds;
    }


    /****************************************************************************************************
        Created by CGI, Thai 2016-05-06
            Set order to paid if all order items are paid
    ****************************************************************************************************/
    public static void setOrderToPaid(List<OrderItem> newList, List<OrderItem> oldList)
    {
        Set<Id> setOrderIdToSetPaid = new Set<Id>();
        List<Order> lstOrder = new List<Order>();
        Integer i1;

        //*** prepare to get order to set paid flag
        for (i1 = 0; i1 < newList.size(); i1++)
            if ((oldList == null || oldList[i1].IEC_Is_Paid__c) == false && newList[i1].IEC_Is_Paid__c == true)
                setOrderIdToSetPaid.add(newList[i1].OrderId);
        
        if (setOrderIdToSetPaid.size() > 0)
        {
            //*** remove order already paid or having item not paid
            for (AggregateResult ag : [select OrderId
                                       from OrderItem
                                       where OrderId in :setOrderIdToSetPaid
                                         and (IEC_Is_Paid__c = false or Order.Is_Paid__c = true)
                                       group by OrderId])
                setOrderIdToSetPaid.remove(String.valueOf(ag.get('OrderId')));

            //*** set paid flag to remaining orders
            if (setOrderIdToSetPaid.size() > 0)
            {
                for (Id idOrder : setOrderIdToSetPaid)
                    lstOrder.add(new Order(Id=idOrder, Is_Paid__c=true, IEC_Payment_Date__c=Date.today()));
                update lstOrder;
            }
        }
    } //*** end of "setOrderToPaid"

    /** Ecommerce Enhancements R2 **/
    public static void setOrderItemAcceptedPaymentMethods(List<OrderItem> newList, Map<Id,OrderItem> oldMap) {
        Set<String> idSet = new Set<String>();

        if (newList != null) {
            for (OrderItem orderItem : newList) {
                OrderItem oldOrderItem = (oldMap != null ? oldMap.get(orderItem.Id) : null);
                String oldPricebookEntryId = (oldOrderItem != null ? oldOrderItem.PricebookEntryId : null);
                String newPricebookEntryId = orderItem.PricebookEntryId;
                
                if (oldPricebookEntryId == null) {
                    oldPricebookEntryId = '';
                }

                if (newPricebookEntryId == null) {
                    newPricebookEntryId = '';
                }

                System.debug('OrderItemId: ' + orderItem.Id + ', old PricebookEntryId: ' + oldPricebookEntryId + ', new PricebookEntryId: ' + newPricebookEntryId);

                if (orderItem.Accepted_Payment_Methods__c == null || newPricebookEntryId.equals(oldPricebookEntryId) == false) {
                    System.debug('    Adding OrderItemId: ' + orderItem.Id + ' for setting in future method');
                    idSet.add(orderItem.Id);
                }
            }
        }

        if (idSet.isEmpty() == false) {
            if (System.isBatch()) {
                batchSetOrderItemAcceptedPaymentMethods(idSet);
            } else if (! System.isFuture()) {
                futureSetOrderItemAcceptedPaymentMethods(idSet);
            }
        }
    }

    @future
    public static void futureSetOrderItemAcceptedPaymentMethods(Set<String> idSet) {
        List<OrderItem> orderItemList = [SELECT Id, OrderId, PricebookEntry.Product2.Accepted_Payment_Methods__c FROM OrderItem WHERE Id IN :idSet];
        Set<Id> orderIdSet = new Set<Id>();
        List<Order> orderUpdateList = new List<Order>();

        for (OrderItem orderItem : orderItemList) {
            String acceptedPaymentMethods = orderItem.PricebookEntry.Product2.Accepted_Payment_Methods__c;

            orderItem.Accepted_Payment_Methods__c = acceptedPaymentMethods;

            orderIdSet.add(orderItem.OrderId);
        }

        update orderItemList;

        for (Id orderId : orderIdSet) {
            orderUpdateList.add(new Order(Id = orderId));
        }

        update orderUpdateList;
    }

    public static void batchSetOrderItemAcceptedPaymentMethods(Set<String> idSet) {
        List<OrderItem> orderItemList = [SELECT Id, OrderId, PricebookEntry.Product2.Accepted_Payment_Methods__c FROM OrderItem WHERE Id IN :idSet];
        Set<Id> orderIdSet = new Set<Id>();
        List<Order> orderUpdateList = new List<Order>();

        for (OrderItem orderItem : orderItemList) {
            orderIdSet.add(orderItem.OrderId);
        }

        for (Id orderId : orderIdSet) {
            orderUpdateList.add(new Order(Id = orderId));
        }

        update orderUpdateList;
    }

}
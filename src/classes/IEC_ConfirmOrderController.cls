public class IEC_ConfirmOrderController extends IEC_PageController 
{
	public Order sfOrder{get;set;}
	public Order_DTO vfOrder{get;set;}
	public IEC_CreditCard_DTO card{get;set;} 

	
	public String successMessage{get;set;}
	public Map<String,String> discountLabels{get;set;}
	public Boolean isOrderConfirmed{get;set;}

	public String orderPaymentType{get;set;}
  	public String orderCreditCardId{get;set;}

	public Boolean stopProcess { get; set; }

	// if orderId passed by parameter to page
	public String pageParameterOrderId { get; set; }

	//Used for google analytics
    public String productWrapper {
        get {
            Map<String,Object> ecommObj = new Map<String,Object>();
            Map<String,Object> checkoutObj = new Map<String,Object>();
            Map<String,Object> actionObj = new Map<String,Object>();
            Map<String,Object> prodObj = new Map<String,Object>();
            
            String couponCodes = '';
            if(vfOrder.orderItems != null && !vfOrder.orderItems.isEmpty()){
                List<String> lstProductNames = new List<String>();
                for(OrderItem_DTO orderItemAux : vfOrder.orderItems){
                    lstProductNames.add(orderItemAux.couponCode);
                }
                couponCodes = String.join( lstProductNames,' - ');
            }

            ecommObj.put('purchase', checkoutObj);
            
            checkoutObj.put('products', new List<Object> {prodObj});

            checkoutObj.put('actionField', actionObj);
            actionObj.put('id',vfOrder.orderId);
            actionObj.put('affiliation','IATA Publications');
            actionObj.put('revenue', vfOrder.orderTotalAmount );
            actionObj.put('tax', vfOrder.taxes);
            actionObj.put('shipping', vfOrder.totalFreightCharge);
            actionObj.put('coupon', couponCodes);


            List<OrderItem_DTO> lstOrderItemsAux = storeCart.getOrderItems();
            if(lstOrderItemsAux != null && !lstOrderItemsAux.isEmpty()){
                List<Object> lstOrderItems = new List<Object>();
                for(OrderItem_DTO orderItemDtoAux : lstOrderItemsAux){
                    Map<String,Object> orderItemsObjMap = new Map<String,Object>();

                    orderItemsObjMap.put('id', orderItemDtoAux.productNumber);
                    orderItemsObjMap.put('name', orderItemDtoAux.productName);
                    orderItemsObjMap.put('category', orderItemDtoAux.productCategory);
                    orderItemsObjMap.put('price', orderItemDtoAux.unitPrice == null ? 0.00 : orderItemDtoAux.unitPrice);
                    orderItemsObjMap.put('brand', orderItemDtoAux.productBrand);
                    orderItemsObjMap.put('quantity', orderItemDtoAux.quantity);
                    orderItemsObjMap.put('dimension1', orderItemDtoAux.productEdition);
                    orderItemsObjMap.put('dimension2', orderItemDtoAux.productLanguage);
                    orderItemsObjMap.put('dimension3', orderItemDtoAux.productInventoryStatus);
                    orderItemsObjMap.put('dimension4', orderItemDtoAux.productAvailabilityDate);
                    orderItemsObjMap.put('dimension5', orderItemDtoAux.productMedia);
                    orderItemsObjMap.put('dimension6', orderItemDtoAux.productEffectiveTo);

                    lstOrderItems.add(orderItemsObjMap);
                }
            
                checkoutObj.put('products', lstOrderItems);
            }

            return JSON.serialize(ecommObj);
        }
        set;
    }


	public IEC_ConfirmOrderController() 
	{
		discountLabels = Utility.buildMapFromString(Label.Labels_IECDiscountType, '\n', ':');
	}

	/* Fallback method for support existing test classes */
	public void initorder() {
		initorder(null, null);
	}

	/*
		Ecommerce Enhancements R1

		Introduced a orderId Query String parameter where we can visualize the order passed by parameter.

	*/
	public void initorder(Order order, Order_DTO orderDto)
	{
		if (order == null || orderDto == null) {
			sfOrder = IECOrder_Svc.getPenddingOrder(true);
			vfOrder = new Order_DTO(sfOrder);
		} else {
			sfOrder = order;
			vfOrder = orderDto;

			String transactionNub = '';
			if (sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer) {
				successMessage = Label.Order_wire_transfer_confirmation_message;
			} else if (sfOrder.Payment_Type__c == IECConstants.ORDER_STATUS_CHECK) {
				successMessage = Label.Order_Check_confirmation_message;
			} else if (sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_ICH) {
				successMessage = Label.Order_ICH_confirmation_message;
			} else if (sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard) {
				//If the transaction was successfully created
				if(sfOrder.Zuora_GatewayResponse__c == null && sfOrder.Payment_Transaction_Number__c != null) {
					successMessage = Label.Order_Credit_Card_confirmation_message;
					transactionNub = Label.IEC_CREDIT_CARD_TRANSACTION_NUMBER + ' ' + sfOrder.Payment_Transaction_Number__c + '.<br />';
				} else {
					addErrorMessage(Label.Order_transaction_failed_message, Label.IEC_ZUORA_GATEWAY_RESPONSE + ' ' + sfOrder.Zuora_GatewayResponse__c);
					isOrderConfirmed = true;
					return;
				}
				successMessage = Label.Order_Credit_Card_confirmation_message;
			}

			successMessage = String.format(successMessage, new String[] { sfOrder.OrderNumber,transactionNub });

			String subscriptionInfos = '';
			Map<Id, List<OrderItem>> orderId_items = new OrderItem_Sel().getOrderItems(new Set<Id>{sfOrder.Id});
			List<OrderItem> orderItems = orderId_items.get(sfOrder.Id);
			for(OrderItem oi : orderItems)
			{
				if(oi.Zuora_Subscription_Number__c != null && oi.IEC_Subscribe_to_Zuora__c) subscriptionInfos += '<br />Subscription Number : ' + oi.Zuora_Subscription_Number__c;
			}

			if (subscriptionInfos != '') {
				successMessage += '<br />' + subscriptionInfos;
			}


			isOrderConfirmed = true;

			checkOrderPayments(successMessage, sfOrder.Id);

			/*
			addConfirmMessage(successMessage);

			isOrderConfirmed = true;

			checkOrderPayments(sfOrder.Id);
			*/
		}
	}

	private String getOrderIdParameter() {
		String paramOrderId = ApexPages.currentPage().getParameters().get('orderId');

		if (paramOrderId != null) {
			if (paramOrderId.trim().length() == 0) {
				paramOrderId = null;
			}
		}

		return paramOrderId;
	}

	private Order getOrderById(Id orderId) {
		Order order = Order_Sel.getOrderForVF(orderId);

		return order;
	}

	/**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		Order order;
		Order_DTO orderDto;

		if(loggedCustomer == null)
		{
			//-- redfirect to login 
			PageReference pgRef = new PageReference('/IEC_Login?returl=/IEC_ConfirmOrder');
				pgRef.setRedirect(true);
        	return pgRef;
		}

		pageParameterOrderId = getOrderIdParameter();

		if (pageParameterOrderId != null) {
			order = getOrderById(pageParameterOrderId);
			orderDto = new Order_DTO(order);
		}

		if (orderDto == null) {
			if(cartContent.isEmpty())
		    {
		        addErrorMessage(Label.Warning_Empty_Cart);
		        return null;
		    }
		}

		initorder(order, orderDto);

		orderPaymentType = sfOrder.Payment_Type__c;
		orderCreditCardId = sfOrder.Zuora_Credit_Card_Id__c;

		//Order_Svc.getSAP_Freight_Tax(sfOrder.Id);

		//If payment type = card get selected card info
		for(IEC_CreditCard_DTO c : loggedCustomer.creditCards)
		{
			if(c.zId == sfOrder.Zuora_Credit_Card_Id__c)
			{
				card = c;
				break;
			}
		}

		//*** check if all SAP partners are valid
		stopProcess = false;
		if (String.isBlank(sfOrder.SoldToAccount_Partner_Number__c) || String.isBlank(sfOrder.BillToContact_Partner_Number__c) || String.isBlank(sfOrder.ShipToContact_Partner_Number__c))
		{
			stopProcess = true;
			addErrorMessage(Label.IEC_SAP_Customer_Issue);
			return null;
		}

		if (isOrderConfirmed == false) {
			//*** check if has a payment method -> check again in method "submitOrder"
			if (String.isBlank(sfOrder.Payment_Type__c) || (sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard && card == null))
			{
				stopProcess = true;
				addErrorMessage(Label.IEC_Error_PleaseSelectPaymentMethod);
				return null;
			}
		}

		if (order == null || orderDto == null) {
			isOrderConfirmed = false;
		}

		return null;		
	}

	/**************************************************************************************************************
     *  submitOrder: method called to process the order                                                           *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference submitOrder()
	{
		try
		{
			Map<Id,Zuora.zApi.SubscribeResult> subscribeSub;
			Zuora.zObject pm = new Zuora.zObject('PaymentMethod');
			Map<Id,String> orderId_paymentType;

			//Set the zuora credit card id in the Order
			if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard)
			{
				//-- Validate Credit Card selected 
				if(String.isBlank(sfOrder.Zuora_Credit_Card_Id__c))
				{
					addErrorMessage(Label.IEC_Error_PleaseSelectPaymentMethod);
					return null;
				}

				//Add the new payment method
				orderId_paymentType = new Map<Id,String>();
				orderId_paymentType.put(vfOrder.orderId,IECConstants.PaymentThresholdType_CreditCard);

				pm.setValue('Id',sfOrder.Zuora_Credit_Card_Id__c);  

				//Set the a zuora payment method object
				IECZuoraHelper.PaymentMethod pay = new IECZuoraHelper.PaymentMethod(pm);
				Map<Id,IECZuoraHelper.PaymentMethod> orderPy = new Map<Id,IECZuoraHelper.PaymentMethod>();
				orderPy.put(vfOrder.orderId,pay);

				//Verified if the Order already have Subscription and Invoices
				Map<Id,Order> orderMap = new Map<Id,Order>();
				orderMap.put(sfOrder.Id,sfOrder);
				Map<Id, List<OrderItem>> orderId_itemsToPaid = new OrderItem_Sel().getOrderItems(new Set<Id>{sfOrder.Id});
				List<OrderItem> orderItems = orderId_itemsToPaid.get(sfOrder.Id);

				//Set Invoices to paid
				Set<String> zInvoicesIds = new set<String>();
				if(orderItems != null && orderItems.size() > 0)
				{
					for(OrderItem oi : orderItems)
					{
						if(oi.Zuora_SubscriptionId__c != null && oi.Zuora_InvoiceId__c != null) zInvoicesIds.add(oi.Zuora_InvoiceId__c);
						else break;						
					}
				}

				//Call Zuora to Create Subscriptions for credit card payment method
				if(!Test.isRunningTest())
					subscribeSub = Order_Svc.subscribe(new set<Id>{vfOrder.orderId}, orderPy,orderId_paymentType);//orderId_paymentType
				else if (card != null)   //*** generate test data
					subscribeSub = new Map<Id,Zuora.zApi.SubscribeResult>{vfOrder.orderId => null};
				if (subscribeSub == null || subscribeSub.size() == 0) {
					addErrorMessage(Label.Order_transaction_failed_message, 'Could not subscribe.');
					return null;
				}
				
				Map<String, ZuoraUtil.zAccountPaymentMethod> iecOrderId_paymentMethod = new Map<String,ZuoraUtil.zAccountPaymentMethod>();
				ZuoraUtil.zAccountPaymentMethod zAccPaymentMethod = new ZuoraUtil.zAccountPaymentMethod();
				zAccPaymentMethod.zPaymentMethodName = sfOrder.Payment_Type__c;
				zAccPaymentMethod.zPaymentMethod = sfOrder.Zuora_Credit_Card_Id__c;
				iecOrderId_paymentMethod.put(sfOrder.Id,zAccPaymentMethod);

				try{
					Map<Id,String> orderItemsResponse;
					if(!Test.isRunningTest())
						orderItemsResponse = Order_Svc.parseSubscribeResult2UpdateItems(subscribeSub,iecOrderId_paymentMethod);
					else   //*** generate test data
						orderItemsResponse = new Map<Id,String>{vfOrder.orderId => (card.name != 'TEST FAILED' ? 'Success' : 'Failed')};
					for(Id ordItem : orderItemsResponse.keySet())
						if (orderItemsResponse.get(ordItem) != 'Success') {
							addErrorMessage(Label.Order_transaction_failed_message, 'Insuccess on OrderItem: ' + ordItem + ' [' + orderItemsResponse.get(ordItem) + ']');
							return null;
						}
				}catch(Exception ex){
					addErrorMessage(Label.Order_transaction_failed_message, ex);
					return null;
				}
				

			}else{
				
				if(sfOrder.Payment_Type__c == null || sfOrder.Payment_Type__c == '')
				{
					addErrorMessage(Label.IEC_Error_PleaseSelectPaymentMethod);
					return null;
				}

				orderId_paymentType = new map<Id,String>();
				orderId_paymentType.put(sfOrder.Id,sfOrder.Payment_Type__c);
				//Call Zuora to Create Subscriptions for orther payment method
				String orderItemsRes = Order_Svc.orderSubscription(new set<Id>{vfOrder.orderId}, null,orderId_paymentType);
				
				if(orderItemsRes != null)
				{
					// Ecommerce Enhancements R2, flag the order as failed in case of error.
					Order updateOrder = new Order(Id = vfOrder.orderId, Status = 'Transaction Failed');

					try {
						update updateOrder;
					} catch (Exception e) {
						// TODO: remove the following addErrorMessage
						addErrorMessage('Error updating the order status: ' + e.getMessage());
					}
					
					addErrorMessage(Label.Order_transaction_failed_message);
					addErrorMessage(orderItemsRes);
					return null;
				}
			}



			//Get the updated Order after the zuora subscription was created
			Order updatedOrder = Order_Sel.getOrderForVF(String.valueOf(sfOrder.Id));

			//Display the success message base on the payment type
			String transactionNub = '';
			if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer) successMessage = Label.Order_wire_transfer_confirmation_message; 
			else if(sfOrder.Payment_Type__c == IECConstants.ORDER_STATUS_CHECK) successMessage = Label.Order_Check_confirmation_message;
			else if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_ICH) successMessage = Label.Order_ICH_confirmation_message;
			else if(sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard){
				//If the transaction was successfully created
				if(updatedOrder.Zuora_GatewayResponse__c == null && updatedOrder.Payment_Transaction_Number__c != null){
					successMessage = Label.Order_Credit_Card_confirmation_message;
					transactionNub = Label.IEC_CREDIT_CARD_TRANSACTION_NUMBER + ' ' + updatedOrder.Payment_Transaction_Number__c + '.<br />';
				} else {
					addErrorMessage(Label.Order_transaction_failed_message, Label.IEC_ZUORA_GATEWAY_RESPONSE + ' ' + updatedOrder.Zuora_GatewayResponse__c);
					return null;
				}
				successMessage = Label.Order_Credit_Card_confirmation_message;
			}

			//List of Event subscription to insert
			List<IEC_Event_Subscription__c> eventSubscriptionToInsert = new List<IEC_Event_Subscription__c>();

			String subscriptionInfos = '';
			Map<Id, List<OrderItem>> orderId_items = new OrderItem_Sel().getOrderItems(new Set<Id>{updatedOrder.Id});
			List<OrderItem> orderItems = orderId_items.get(updatedOrder.Id);
			for(OrderItem oi : orderItems)
			{
				if(oi.Zuora_Subscription_Number__c != null && oi.IEC_Subscribe_to_Zuora__c) subscriptionInfos += '<br />Subscription Number : ' + oi.Zuora_Subscription_Number__c;
				
				//Create a new event subscription object
				if(oi.Auto_Renew__c && !oi.IEC_Subscribe_to_Zuora__c) eventSubscriptionToInsert.add(new IEC_Event_Subscription__c(Product__c=oi.Product__c, Quantity__c=oi.Quantity, Start_Date__c=Date.today(), Subscriber__c=updatedOrder.BillToContactId));				
			}
			/*//log event auto-renew
			if(eventSubscriptionToInsert.size() > 0)
				insert eventSubscriptionToInsert;*/

			map<Id,Id> prodId_eveSubId = new map<Id,Id>();
            //log event auto-renew
            if(eventSubscriptionToInsert.size() > 0){
                Database.SaveResult[] srList = Database.insert(eventSubscriptionToInsert, false);
                set<Id> newEveSubIds = new set<Id>();
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) 
                    if (sr.isSuccess()) newEveSubIds.add(sr.getId()); 
                
                List<IEC_Event_Subscription__c> newEveSubs = new IEC_EventSubscription_Sel().getEventSubscriptionById(newEveSubIds).values();
                for(IEC_Event_Subscription__c es : newEveSubs) prodId_eveSubId.put(es.Product__c,es.Id);
            }

            //Set the Order item event subscription 
            for(OrderItem oi : orderItems){
                Id eveSubId = prodId_eveSubId.get(oi.Product__c);
                oi.IEC_Event_Subscription__c = eveSubId;
            }
            
            update orderItems;
			
			//successMessage += subscriptionInfos;
			successMessage = String.format(successMessage, new String[]{updatedOrder.OrderNumber,transactionNub});

			if(subscriptionInfos != '') successMessage += '<br />' + subscriptionInfos;

			if(sfOrder.Payment_Type__c != IECConstants.PaymentThresholdType_CreditCard)
				updatedOrder.Payment_Type__c = sfOrder.Payment_Type__c;
			
			/** 
					Ecommerce Enhancements R1.

					If Credit Card payment type then transition the Order to status Pending Payment.
					Upon on sucessful payment processing the Zuora__Payment__c object trigger will
                    update the order status to Paid and run similar code as bellow.


			*/

			if (updatedOrder.Payment_Type__c != IECConstants.PaymentThresholdType_CreditCard) {
				//Set the sfOrder status
				updatedOrder.Status = Order_Svc.getOrderStatusByPaymentType(sfOrder.Payment_Type__c);

				//Set the is paid flag base on the payment type
				updatedOrder.Is_Paid__c = Order_Svc.isOrderPaidByPaymentType(sfOrder.Payment_Type__c);
				
				updatedOrder.Type = 'Order';
				updatedOrder.EffectiveDate = Date.today();

				update updatedOrder;

				//-- If Order come from Campaign Update campaign Member Status 
				updateCampaignMembers(updatedOrder.Id);

				Order_Svc.saveCouponUsed(updatedOrder.Id, updatedOrder.ShipToContactId);

				//addConfirmMessage(successMessage);

				isOrderConfirmed=true;

				//*** send information to Pardot
				sendFormHandlerToPardot(sfOrder.Id);
			}

			if (sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard) {
				updatedOrder.Status = 'Pending Payment';
				
				updatedOrder.Type = 'Order';
				updatedOrder.EffectiveDate = Date.today();
				updatedOrder.Is_Paid__c = false;

				update updatedOrder;

				isOrderConfirmed=true;

				checkOrderPayments(successMessage, sfOrder.Id);
			}
		}
		catch(Exception ex){
			//log Subscription exception
			IEC_Error_Log__c errorLog = IECErrorLogger.createErrorLog('IECConfirmOrder_Ctrl/processPayment','',ex.getMessage(),ex.getStackTraceString());
			IECErrorLogger.logErrors(new list<IEC_Error_Log__c>{errorLog});

			addErrorMessage(Label.Order_transaction_failed_message);
			addErrorMessage(ex.getStackTraceString());
			isOrderConfirmed=false;
			return null;
		}
		
		if (newShoppingCart == false) {
			//Clear the customer cookies
			IECOrder_Svc.deleteAllCookies();
		} else {
			storeCart.submitEvent();
		}

		//susana alves INC332088
		Order orderToDelete = storeCart.getCartOrderContent();
		system.debug('submitOrder -> orderToDelete :: ' + orderToDelete);
		Boolean canDeleteOrder = !([SELECT count() FROM OrderItem WHERE OrderId = :orderToDelete.Id] > 0);
		system.debug('submitOrder -> canDeleteOrder? : ' + canDeleteOrder);
		
		if(canDeleteOrder){
			// the order don't have related products, so can be deleted
			system.debug('submitOrder -> empty order on the cart to be deleted : ' + storeCart.getCartOrderContent());
			IECOrder_Svc.deleteOrder(storeCart.getCartOrderContent());
		}
		return null;
	} 

	/*

		checkOrderPayments - check if last payment associated with Order is with success / failure and set messaging accordingly.


	*/
	private void checkOrderPayments(String messageHistory, Id orderId) {
		Order order = [SELECT Id, Status, Payment_Type__c, Payment_Gateway_Response__c FROM Order WHERE Id = :orderId LIMIT 1];
		
		if (order.Payment_Type__c == 'Credit Card') {
			if (order.Status == 'Pending Payment') {
				addWarningMessage(messageHistory + '<br />' + Label.IEC_CREDIT_CARD_PENDING_PAYMENT);
			} else if (order.Status == 'Payment Failure') {
				addErrorMessage(messageHistory + '<br />' + Label.IEC_CREDIT_CARD_PAYMENT_ERROR + ' ' + order.Payment_Gateway_Response__c + '.');				
			} else {
				List<Zuora__Payment__c> orderPaymentList = [SELECT Id, Zuora__Status__c, Zuora__PaymentMethod__c, Zuora__GatewayResponse__c FROM Zuora__Payment__c WHERE Order__c = :orderId ORDER BY LastModifiedDate DESC];
				Zuora__Payment__c lastPayment;

				if (orderPaymentList.size() > 0) {
					lastPayment = orderPaymentList.get(0);
				}

				if (lastPayment != null) {
					if (lastPayment.Zuora__PaymentMethod__c != null && lastPayment.Zuora__PaymentMethod__c.startsWith(IECConstants.ZUORA_PAYMENT_METHOD_PREFIX_CREDIT_CARD)) {
						if (lastPayment.Zuora__Status__c == 'Error') {
							addErrorMessage(messageHistory + '<br />' + Label.IEC_CREDIT_CARD_PAYMENT_ERROR + ' ' + lastPayment.Zuora__GatewayResponse__c + '.');
						} else if (lastPayment.Zuora__Status__c == 'Processed') {
							addConfirmMessage(messageHistory + '<br />' + Label.IEC_CREDIT_CARD_PAYMENT_SUCCESSFUL);
						}
					}					
				} else {
					addWarningMessage(messageHistory + '<br />' + Label.IEC_CREDIT_CARD_PENDING_PAYMENT);
				}
			}
		} else {
			addConfirmMessage(messageHistory);
		}
	}

	/************************************************************************************************************************
     *  updateCampaignMembers: method called when the order is generated from a campaign to update campaigneMember status 	*
     *  Author: David Daboué                                                                                      			*  
     ***********************************************************************************************************************/
	@future
    public static void updateCampaignMembers(String updatedOrderId)
    {
        try
        {
            Order updatedOrder = [SELECT Id, Campaign__c, BillToContactId FROM Order WHERE Id = :updatedOrderId LIMIT 1];   

            if(updatedOrder.Campaign__c != null)
            {
                List<CampaignMember> cm = [SELECT Id, Status FROM CampaignMember WHERE CampaignId = :updatedOrder.Campaign__c AND ContactId = :updatedOrder.BillToContactId];
                if(cm.size() > 0)
                {
                    cm[0].Status = 'Responded';
                    update cm[0];
                }
            }
        }
        catch(Exception ex){System.debug('EXCPTION:: '+ex.getMessage());}
    }

	/****************************************************************************************************
	    Created by CGI, Thai 2017-01-25
	        Send information to Pardot
	****************************************************************************************************/
	@future (callout=true) public static void sendFormHandlerToPardot(Id idOrder)
	{
		String URL = Utility.getTextSetting('Pardot Campaign');
		if (URL != '')
			try
			{
				//*** get data
				Order oOrder = [select OrderNumber, BillToContact_Email__c, BillToContact.Email
				                     , Discount_Amount__c, Total_Freight_Charge__c, Total_handling_charges__c, Taxes__c, SubTotal_Amount__c, Total_Amount__c
				                     , (select SAP_Product_Number__c, Quantity, UnitPrice, Discount__c, SubTotal__c, Freight_Charge__c, Handling_charges__c, Tax__c, Total__c
				                        from OrderItems)
				                from Order where Id = :idOrder limit 1][0];

				//*** build URL with all data to send
				URL += '?order=' + EncodingUtil.urlEncode(oOrder.OrderNumber, 'UTF-8')
				     + '&email=' + EncodingUtil.urlEncode(oOrder.BillToContact_Email__c == null ? (oOrder.BillToContact.Email == null ? '' : oOrder.BillToContact.Email) : oOrder.BillToContact_Email__c, 'UTF-8')
				     + '&total_discount=' + EncodingUtil.urlEncode(String.valueOf(oOrder.Discount_Amount__c == null ? 0.00 : oOrder.Discount_Amount__c), 'UTF-8')
				     + '&total_shipping=' + EncodingUtil.urlEncode(String.valueOf(oOrder.Total_Freight_Charge__c == null ? 0.00 : oOrder.Total_Freight_Charge__c), 'UTF-8')
				     + '&total_tax=' + EncodingUtil.urlEncode(String.valueOf(oOrder.Taxes__c == null ? 0.00 : oOrder.Taxes__c), 'UTF-8')
				     + '&total_amount=' + EncodingUtil.urlEncode(String.valueOf(oOrder.Total_Amount__c == null ? 0.00 : oOrder.Total_Amount__c), 'UTF-8');
				for (Integer i1 = 0; i1 < oOrder.OrderItems.size(); i1++)
					URL += '&product' + (i1 + 1) + '=' + EncodingUtil.urlEncode(oOrder.OrderItems[i1].SAP_Product_Number__c, 'UTF-8')
					     + '&quantity' + (i1 + 1) + '=' + EncodingUtil.urlEncode(String.valueOf(oOrder.OrderItems[i1].Quantity), 'UTF-8');

				System.debug('URL: ' + URL);

				//*** send to Pardot
				HttpRequest httpReq = new HttpRequest();
				httpReq.setMethod('POST');
				httpReq.setEndpoint(URL);
				Http httpTarget = new Http();
				HttpResponse httpResp = httpTarget.send(httpReq);
			}
			catch (Exception e)
			{
				IECErrorLogger.logApexException('IEC_ConfirmOrderController.sendFormHandlerToPardot', URL, e.getMessage(), e.getStackTraceString());
			}
	} //*** end of "sendFormHandlerToPardot"

}
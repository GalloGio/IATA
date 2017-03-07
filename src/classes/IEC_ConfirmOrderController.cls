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

	public IEC_ConfirmOrderController() 
	{
		discountLabels = Utility.buildMapFromString(Label.Labels_IECDiscountType, '\n', ':');
	}

	public void initorder()
	{
		sfOrder = IECOrder_Svc.getPenddingOrder(true);
		vfOrder = new Order_DTO(sfOrder);
	}

	/**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		if(loggedCustomer == null)
		{
			//-- redfirect to login 
			PageReference pgRef = new PageReference('/IEC_Login?returl=/IEC_ConfirmOrder');
				pgRef.setRedirect(true);
        	return pgRef;
		}

		if(cartContent.isEmpty())
	    {
	        addErrorMessage(Label.Warning_Empty_Cart);
	        return null;
	    }

		initorder();

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

		//*** check if has a payment method -> check again in method "submitOrder"
		if (String.isBlank(sfOrder.Payment_Type__c) || (sfOrder.Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard && card == null))
		{
			stopProcess = true;
			addErrorMessage(Label.IEC_Error_PleaseSelectPaymentMethod);
			return null;
		}

		isOrderConfirmed = false;
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
					addErrorMessage(Label.Order_transaction_failed_message);
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
							addErrorMessage(Label.Order_transaction_failed_message);
							return null;
						}
				}catch(Exception ex){
					addErrorMessage(Label.Order_transaction_failed_message);
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
					transactionNub = 'Your Transaction number is : ' + updatedOrder.Payment_Transaction_Number__c + '<br />';
				} else {
					addErrorMessage(Label.Order_transaction_failed_message);
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

			addConfirmMessage(successMessage);
			isOrderConfirmed=true;
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
		
		//Clear the customer cookies
		IECOrder_Svc.deleteAllCookies();
		
		return null;
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

}
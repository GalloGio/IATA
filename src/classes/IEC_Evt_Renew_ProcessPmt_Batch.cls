/**
 * A Sync batch that submit Event Renewal as subscriptions to Zuora to collect payments.
 * - Only Credit Card Payments are processed in Zuora
 * - ICH Payments are marked as paid and records will be sent later to SAP
 **/

global class IEC_Evt_Renew_ProcessPmt_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	private Set<Id> setOrderIdToUpdate;
	private Id idEventRelease;
	
	// Constructor
	//	param: EventReleaseId: ID of the Event Release
	global IEC_Evt_Renew_ProcessPmt_Batch(Id EventReleaseId) {
		idEventRelease = EventReleaseId;
		setOrderIdToUpdate = new Set<Id>();
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('Kyle Porter debug start time: ' + DateTime.now());
		String queryLimit = '';
        if(Test.isRunningTest())
            queryLimit = ' And Tax__c != null Limit 5';

		return Database.getQueryLocator(
			' SELECT Id, Tax__c, OrderId, Product__c, Order.IEC_Event_Subscription__c' +
			'	, Order.BillToContactId, Order.BillToAccount__r.Default_Payment_Type__c, Order.BillTo_Account_Contact_ID__c' +
			' FROM OrderItem' +
			' WHERE Order.IEC_Event_Release__c = \'' + idEventRelease + '\'' +
			'	AND Order.Status = \'New\' ' + queryLimit
		);
	}

	global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
		System.debug('Kyle Porter Debug execute time: ' + DateTime.now());
		integer iZuoraAPIObjectLimit = Utility.getIntegerSetting('Zuora API Object Limit');
		
		// Build a list of Account/Contact ID to retrieve the related Billing Account with it
		Set<String> setAccountContactId = new Set<String>();

		//*** Id of orders or subscriptions to filter log for deletion
		Set<Id> setOrderOrSubscriptionId = new Set<Id>();

		//*** list of subscription to update product to the latest version
		List<IEC_Event_Subscription__c> lstSubscriptionToUpdate = new List<IEC_Event_Subscription__c>();
		
		// List of errors reported during the release payment
		List<IEC_Event_Release_Log__c> lstReleaseLog = new List<IEC_Event_Release_Log__c>();
		
		// List of Orders used to update the order with the status of payment
		List<Order> lstOrderToUpdate = new List<Order>();
		List<Map<Id, OrderItem>> lst_mapOrderPaidByCreditCard = new List<Map<Id, OrderItem>>();
		List<OrderItem> lstOrderItemToUpdate = new List<OrderItem>();
		
		try
		{
			
			if (!scope.isEmpty()) {
				
				/*////////////////////////////////////////////////////////////
				// First loop determines which order hasn't been calculated
				// Tax or shipping
				// And also retrieve related Billing Account for successful orders
				///////////////////////////////////////////////////////////*/
				
				for (OrderItem oi : scope) {
					// Skip order items that doesn't have tax calculation and will be reported as error
					if (oi.Tax__c != null)
					{
						setAccountContactId.add(oi.Order.BillTo_Account_Contact_ID__c);
					}
					else
					{
						lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('Tax and Shipping have not been calculated on the order.', null, oi.OrderId, idEventRelease, 'Payment', oi.Order.BillToContactId, false));
					}
				}
				
				// Retrieve ZAccounts related to the location records in 
				Map<String, Zuora__CustomerAccount__c> mapAccConId_ZAccount = CustomerAccount_Sel.getZAccountByAccountContactId(setAccountContactId);
				
				/*////////////////////////////////////////////////////////////
				// Second loop determines which order is paid by either
				// ICH or Credit Cards
				///////////////////////////////////////////////////////////*/
				
				// Create a multi-dimensional array to make a multiple callouts to zuora
				// to workaround zuora limit of updating maximum 50 records at one time
				integer  i = 0, j = 0;

				//List of payment methods and types
				List<Map<Id, IECZuoraHelper.PaymentMethod>> lst_mapOrderId_PaymentMethod = new List<Map<Id, IECZuoraHelper.PaymentMethod>>();
				List<Map<String, ZuoraUtil.zAccountPaymentMethod>> lst_mapOrderId_AccountPaymentMethod = new List<Map<String, ZuoraUtil.zAccountPaymentMethod>>();
				List<Map<Id, String>> lst_mapOrderId_PaymentType = new List<Map<Id, String>>();
				Map<Id, String> mapOrdersNotRenewed = new Map<Id, String>();
				Map<Id, String> mapOrderItemsNotRenewed = new Map<Id, String>();

				// Loop over orderitems to determine which orders will be submitted to zuora
				for (OrderItem oi : scope) {

					//list of Zuora default payment methods to validate
					List<Zuora.zObject> validateDefaultPaymentMethods = new List<Zuora.zObject>();
					String transactionStatus;
					Datetime transactionDateTime;

					// Skip order items that doesn't have tax calculation
					if (oi.Tax__c != null)
					{
						if (oi.Order.BillToAccount__r.Default_Payment_Type__c != null)
						{
							// If order is paid by ICH, then mark it as paid and set the status to be ready for SAP
							if (oi.Order.BillToAccount__r.Default_Payment_Type__c == 'ICH')
							{
								setOrderIdToUpdate.add(oi.OrderId);
								lstOrderToUpdate.add(new Order(
									Id = oi.OrderId
									, Status = Order_Svc.getOrderStatusByPaymentType('ICH')
									, Is_Paid__c = Order_Svc.isOrderPaidByPaymentType('ICH')
								));

								//*** prepare to delete error logs and to update product in subscription
								setOrderOrSubscriptionId.add(oi.OrderId);
								if (oi.Order.IEC_Event_Subscription__c != null)
								{
									setOrderOrSubscriptionId.add(oi.Order.IEC_Event_Subscription__c);
									lstSubscriptionToUpdate.add(new IEC_Event_Subscription__c(Id=oi.Order.IEC_Event_Subscription__c, Product__c=oi.Product__c));
								}
							}
							// If order is paid by credit card, then prep it to submit it to zuora
							else if (oi.Order.BillToAccount__r.Default_Payment_Type__c.contains('Credit'))
							{
								// Try to find the corresponding Zuora Billing Account first
								if (mapAccConId_ZAccount.containskey(oi.Order.BillTo_Account_Contact_ID__c))
								{
									Zuora__CustomerAccount__c oBillingAccount = mapAccConId_ZAccount.get(oi.Order.BillTo_Account_Contact_ID__c); 
									// Make sure the default payment on the billing account is set to Credit Card
									if (oBillingAccount.Zuora__Default_Payment_Method__c != null && oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__Type__c == 'CreditCard')
									{
										// If still first time in the sub-array, then instantiate a new array
										if (j == 0)
										{
											
											lst_mapOrderPaidByCreditCard.add(new Map<Id, OrderItem>());
											lst_mapOrderId_PaymentMethod.add(new Map<Id, IECZuoraHelper.PaymentMethod>());
											lst_mapOrderId_AccountPaymentMethod.add(new Map<String, ZuoraUtil.zAccountPaymentMethod>());
											lst_mapOrderId_PaymentType.add(new Map<Id, String>());
										}
										// Otherwise keep adding to the same array
										
										// Record the order id and order item that will be submitted to Zuora
										lst_mapOrderPaidByCreditCard[i].put(oi.OrderId, oi);
										
										// Define the payment method ID on the order
										Zuora.zObject zPaymentMethod = new Zuora.zObject('PaymentMethod');
										zPaymentMethod.setValue('Id', oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
										zPaymentMethod.setValue('NumConsecutiveFailures', 20);

										validateDefaultPaymentMethods.add(zPaymentMethod);
										// validate if credit card is valid or invalid
										// update NumConsecutiveFailures to 20 just to trigger the card validation - 
										List<Zuora.zApi.SaveResult> results = ZuoraUtil.zupdate(validateDefaultPaymentMethods);

										System.debug('susana results - ' + results);
										// verify the Last Transaction registered on Zuora
										// if is Error, the renewal order process ends here for that order
										List<Zuora.zObject> pm = ZuoraUtil.getPaymentMethodDetails(oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c); 
										System.debug('susana pm - ' + pm);
										System.debug('susana pm transactionStatus - ' + pm.get(0).getValue('LastTransactionStatus'));

										if(pm.size()>0)
										{
											transactionStatus = (String)pm.get(0).getValue('LastTransactionStatus');
							            	transactionDateTime = (Datetime)pm.get(0).getValue('LastTransactionDateTime');
										}

										// if the LastTransactionStatus is different from Approved, the credit card is invalid for payment
										// we will stop the process
										if(transactionStatus == 'Approved' && transactionStatus != null){

											// Record the order id and order item that will be submitted to Zuora
											lst_mapOrderPaidByCreditCard[i].put(oi.OrderId, oi);

											System.debug('susana zPaymentMethod - '+zPaymentMethod);
											lst_mapOrderId_PaymentMethod[i].put(oi.OrderId, new IECZuoraHelper.PaymentMethod(zPaymentMethod));
											System.debug('susana lst_mapOrderId_PaymentMethod - '+lst_mapOrderId_PaymentMethod);
											// Define the payment type on the order
											lst_mapOrderId_PaymentType[i].put(oi.OrderId, IECConstants.PaymentThresholdType_CreditCard);
											System.debug('susana lst_mapOrderId_PaymentType - '+lst_mapOrderId_PaymentType);
											ZuoraUtil.zAccountPaymentMethod zAccPmtMethod = new ZuoraUtil.zAccountPaymentMethod();
											zAccPmtMethod.zPaymentMethodName = 'Credit Card';
											zAccPmtMethod.zPaymentMethod = oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c;
											lst_mapOrderId_AccountPaymentMethod[i].put(oi.OrderId, zAccPmtMethod);
											System.debug('susana zAccPmtMethod - '+zAccPmtMethod);
											System.debug('susana lst_mapOrderId_AccountPaymentMethod - '+lst_mapOrderId_AccountPaymentMethod);
											
											j++;
											
											// Once the sub-array index reaches to the maximum number allowed per callout
											// then reset the level 2 index J and increment the Level 1 index I to force to create a new sub-array
											if (j == iZuoraAPIObjectLimit)
											{
												j = 0; i++;
											}
										}
										else
										{	
											mapOrdersNotRenewed.put(oi.OrderId, '' + transactionStatus + ' registered on ' + transactionDateTime + ' for payment method id ' + oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
											mapOrderItemsNotRenewed.put(oi.Id, '' + transactionStatus + ' registered on ' + transactionDateTime + ' for payment method id ' + oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c);
											System.debug('susana mapOrdersNotRenewed - ' + mapOrdersNotRenewed);
											lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('Zuora Billing Account\'s default payment method is not a valid credit card to proceed with the payment.', '' + transactionStatus + ' registered on ' + transactionDateTime + ' for payment method id ' + oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__External_Id__c, oi.OrderId, idEventRelease, 'Credit Card Validation', oi.Order.BillToContactId, false));
										}
									}
									else
									{
										lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('Zuora Billing Account\'s default payment method is not set to credit card while trying to pay with credit card.', null, oi.OrderId, idEventRelease, 'Payment', oi.Order.BillToContactId, false));
									}
								}
								else
								{
									lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('Zuora Billing Account was not found for order.', null, oi.OrderId, idEventRelease, 'Payment', oi.Order.BillToContactId, false));
								}
							}
							else
							{
								lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('Event release only supports payment types of ICH or Credit Card.', null, oi.OrderId, idEventRelease, 'Payment', oi.Order.BillToContactId, false));
							}
						}
						else
						{
							lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('No default payment type defined on the Bill-To Account.', null, oi.OrderId, idEventRelease, 'Payment', oi.Order.BillToContactId, false));
						}
					}
				}
				
				/*////////////////////////////////////////////////////////////
				// Subscribe to Zuora Orders paid by Credit Card
				///////////////////////////////////////////////////////////*/
				for (integer x = 0; x < lst_mapOrderPaidByCreditCard.size(); x++)
				{
					// First retrieve the maps necessary maps from the two dimensional arrays
					Map<Id, OrderItem> mapOrderPaidByCreditCard = lst_mapOrderPaidByCreditCard[x];
					Map<Id, IECZuoraHelper.PaymentMethod> mapOrderId_PaymentMethod = lst_mapOrderId_PaymentMethod[x];
					Map<String, ZuoraUtil.zAccountPaymentMethod> mapOrderId_AccountPaymentMethod = lst_mapOrderId_AccountPaymentMethod[x];
					Map<Id, String> mapOrderId_PaymentType = lst_mapOrderId_PaymentType[x];
					
					// Now submit subscription reuquest to zuora
					Map<Id, Zuora.zApi.SubscribeResult> mapZSubscribeResult = Order_Svc.subscribe(mapOrderPaidByCreditCard.keySet(), mapOrderId_PaymentMethod, mapOrderId_PaymentType);
					
					// Now process payments for Orders through Zuora
					Map<Id, String> orderItemsResponse = Order_Svc.parseSubscribeResult2UpdateItems(mapZSubscribeResult, mapOrderId_AccountPaymentMethod);
					
					// Loop on orderitem status to record errors
					for (OrderItem oi : scope) {
						// Only log erros for order items that was submitted to zuora
						if (orderItemsResponse.containsKey(oi.Id))
						{
							String result = orderItemsResponse.get(oi.Id);
							
							if (result == 'Success')
							{
								setOrderIdToUpdate.add(oi.OrderId);
								lstOrderToUpdate.add(new Order(
									Id = oi.OrderId
									, Status = Order_Svc.getOrderStatusByPaymentType('Credit Card')
									, Is_Paid__c = Order_Svc.isOrderPaidByPaymentType('Credit Card')
								));

								//*** prepare to delete error logs and to update product in subscription
								setOrderOrSubscriptionId.add(oi.OrderId);
								if (oi.Order.IEC_Event_Subscription__c != null)
								{
									setOrderOrSubscriptionId.add(oi.Order.IEC_Event_Subscription__c);
									lstSubscriptionToUpdate.add(new IEC_Event_Subscription__c(Id=oi.Order.IEC_Event_Subscription__c, Product__c=oi.Product__c));
								}
							}
							else
							{
								lstReleaseLog.add(IEC_EventReleaseLog_Svc.logError('Error while subscribing order item.', orderItemsResponse.get(oi.Id), oi.OrderId, idEventRelease, 'Payment', oi.Order.BillToContactId, false));
							}
						}
					}
				}
				
				for(Id oid : mapOrdersNotRenewed.keySet()){

					lstOrderToUpdate.add(new Order(
						Id = oid,
						Status = IECConstants.ORDER_STATUS_PAYMENT_FAILURE,
						Is_Paid__c = false,
						Payment_Gateway_Response__c = mapOrdersNotRenewed.get(oid)
					));

				}

				for(Id oiid : mapOrderItemsNotRenewed.keySet()){

					lstOrderItemToUpdate.add(new OrderItem(
						Id = oiid,
						IEC_Is_Paid__c = false
					));

				}

				
				/*////////////////////////////////////////////////////////////
				// Update Orders Status and Paid flag
				///////////////////////////////////////////////////////////*/
				update lstOrderToUpdate;
				update lstOrderItemToUpdate;

				//*** delete logs for proceeded orders and/or subscriptions
				if (setOrderOrSubscriptionId.size() > 0)
					delete [select Id from IEC_Event_Release_Log__c
					        where IEC_Event_Release__c = :idEventRelease
					          and (Order__c in :setOrderOrSubscriptionId or Subscription__c in :setOrderOrSubscriptionId)];
				
				//*** update product in subscription to the latest version or swapped product
				if (lstSubscriptionToUpdate.size() > 0)
					update lstSubscriptionToUpdate;
				
				/*////////////////////////////////////////////////////////////
				// Finally insert the logs if applicable
				///////////////////////////////////////////////////////////*/
				if (!lstReleaseLog.isEmpty())
				{
					insert lstReleaseLog;
				}
			}
   		}
   		catch (Exception e)
   		{
   			IECErrorLogger.logApexException('IEC_Evt_Renew_ProcessPmt_Batch.execute'
   				, 'Exception thrown while running the execute function:\nidEventRelease: ' + idEventRelease
   				  + '\nData:\n' + String.join(scope, '\n')
   				  + '\nOrder to update:\n' + String.join(lstOrderToUpdate, '\n')
   				  + '\nSubscription to update:\n' + String.join(lstSubscriptionToUpdate, '\n')
   				  + '\nSubscription/Order in log to delete:\n' + String.join(new List<Id>(setOrderOrSubscriptionId), '\n')
   				  + '\nNew error log:\n' + String.join(lstReleaseLog, '\n')
   				, e.getMessage()
   				, e.getStackTraceString()
   			);
   		}
	}
	
	global void finish(Database.BatchableContext BC)
	{
		System.debug('Kyle Porter Debug finish time: ' + DateTime.now());
		// When the process is done, set the Event Release to Released
		update (new IEC_Event_Release__c (Id = idEventRelease, Released__c = true, Processing_Status__c = null));		

        //*** send notification to creator
        IEC_Event_Release__c event = [select Name, CreatedBy.Email, CreatedBy.FirstName from IEC_Event_Release__c where Id = :idEventRelease limit 1];
        Utility.sendEmail(new List<String> {event.CreatedBy.Email}
                        , 'Process for event release "' + event.Name + '" is complete'
                        , 'Dear ' + event.CreatedBy.FirstName + '<br/><br/>'
                          + 'The process launched for event release "' + event.Name + '" was complete.  For more detail, click on this link '
                          + '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + idEventRelease + '">' + event.Name + '</a>.<br/><br/>'
                          + 'Best regards,<br/>'
                          + 'eCommerce Support Team<br/>'
                        , true, null);


	}

	
}
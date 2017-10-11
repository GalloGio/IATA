/**

	Project: eCommerce Enhancements
	   File: trgHndlrIECPayment.cls
	Subject: Trigger Handler for Zuora Payments.
	History: 2017-05-11, asantos, Initial Release.
			 2017-05-14, asantos, Workflow for received credit card payments.
			 2017-05-31, asantos, Included a field to bypass the trigger logic that
                                  should be used when performing data fixes in the
                                  Zuora__Payment__c object.
			 2017-06-19, asantos, Reworked the way zuora data is rollback.
			 2017-06-19, asantos, Only update order status to "Payment Failure" when current
								  order status is "Pending Payment" to prevent out of order
								  status changes due to payments.

       Info: Purpose of this handler is to:
              - populate the Order__c field on Zuora__Payment__c object to link the Payment with
                the corresponding Order.
			  - perform the credit card workflow payment reception from Zuora and update
                order status with success payment or failure payment.
			  - if payment fails, rollback Zuora subscription, invoice and payments.
              - when payment deletion is received (due to payment failure and payment rollback)
                log the payment details to IEC_Payment_Error__c.
			 

*/
public with sharing class trgHndlrIECPayment {
	static Set<Id> processedPaymentIdSet = new Set<Id>();
	static Set<Id> processedOrderIdSet = new Set<Id>();
	static Set<Id> updateIgnoredSet = new Set<Id>();
	static Set<Integer> insertIgnoredSet = new Set<Integer>();

	public static void OnBeforeInsertOrUpdate(
		List<Zuora__Payment__c> newRecords,
		Map<Id,Zuora__Payment__c> oldRecordsMap
	) {
		Integer seq;

		/* collect the records to be ignored */
		if (newRecords != null) {
			seq = -1;

			for (Zuora__Payment__c payment : newRecords) {
				seq++;

				if (payment.Bypass_Trigger_Logic__c == true) {
					if (payment.Id != null) {
						updateIgnoredSet.add(payment.Id);
					} else {
						insertIgnoredSet.add(seq);
					}
				}
			}
		}

		correlateCreditCardPaymentsWithOrders(newRecords, oldRecordsMap);

		/* reset the flag status for the records to be ignored */
		if (newRecords != null) {
			seq = -1;
			for (Zuora__Payment__c payment : newRecords) {
				seq++;

				if (payment.Id != null) {
					if (updateIgnoredSet.contains(payment.Id)) {
						payment.Bypass_Trigger_Logic__c = false;
					}
				} else {
					if (insertIgnoredSet.contains(seq)) {
						payment.Bypass_Trigger_Logic__c = false;
					}
				}
			}
		}
	}

	public static void OnAfterInsertOrUpdate(
		Map<Id,Zuora__Payment__c> newRecordsMap,
		Map<Id,Zuora__Payment__c> oldRecordsMap
	) {
		workflowCreditCardPayments(newRecordsMap, oldrecordsMap);
	}

	public static void OnAfterDelete(
		Map<Id,Zuora__Payment__c> oldRecordsMap
	) {
		createPaymentErrors(oldRecordsMap);
	}

	static Map<String,List<Zuora.zObject>> zuoraTestObjectData = new Map<String,List<Zuora.zObject>>();
	static Integer zuoraTestId = 1;

	/**
		Update the order status based on the outcome of the credit card payment.

		If credit card payment is in error, rollback the Zuora subscription, invoice and payment.


	*/
	public static void workflowCreditCardPayments(Map<Id,Zuora__Payment__c> newRecordsMap, Map<Id,Zuora__Payment__c> oldRecordsMap) {
		Set<Id> orderIdSet = new Set<Id>();
		Map<Id,Boolean> orderStatusMap = new Map<Id,Boolean>();
		Map<Id,String> gatewayResponseMap = new Map<Id,String>();
		Map<String,Boolean> paymentStatusSuccessMap = new Map<String,Boolean>{
			'Processed'		=> true,
			'Error'			=> false
		};
		List<Order> orderUpdateList = new List<Order>();

		for (Zuora__Payment__c payment : newRecordsMap.values()) {
			if (processedPaymentIdSet.contains(payment.Id) == false) {
				if (payment.Zuora__PaymentMethod__c.startsWithIgnoreCase('Credit Card')) {
					if (payment.Order__c != null) {
						Boolean paymentSuccess = false;

						if (paymentStatusSuccessMap.containsKey(payment.Zuora__Status__c)) {
							paymentSuccess = paymentStatusSuccessMap.get(payment.Zuora__Status__c);
						}

						gatewayResponseMap.put(payment.Order__c, payment.Zuora__GatewayResponse__c);

						orderStatusMap.put(payment.Order__c, paymentSuccess);

						orderIdSet.add(payment.Order__c);
					}
				}

				processedPaymentIdSet.add(payment.Id);
			}
		}

		for (Order order : [SELECT Id, Status, Is_Paid__c, Type, EffectiveDate, Payment_Type__c, ShipToContactId FROM Order WHERE Id IN :orderIdSet]) {
			Boolean success = orderStatusMap.get(order.Id);
			String orderStatus;
			Boolean orderIsPaid;
			String orderType;
			String gatewayResponse;
			Date effectiveDate = Date.today();
			String previousOrderStatus = order.Status;

			Order updateOrder;

			if (processedOrderIdSet.contains(order.Id) == false) {
				if (previousOrderStatus == null || previousOrderStatus != null && previousOrderStatus == 'Pending Payment') {
					if (success == true) {
						orderStatus = Order_Svc.getOrderStatusByPaymentType(order.Payment_Type__c);
						orderIsPaid = Order_Svc.isOrderPaidByPaymentType(order.Payment_Type__c);
						orderType = 'Order';
					} else {
						orderStatus = 'Payment Failure';
						orderIsPaid = false;
						orderType = order.Type;
					}

					gatewayResponse = gatewayResponseMap.get(order.Id);

					updateOrder = new Order(
						Id = order.Id,
						Status = orderStatus,
						Is_Paid__c = orderIsPaid,
						Type = orderType,
						EffectiveDate = effectiveDate,
						ShipToContactId = order.ShipToContactId,
						Payment_Gateway_Response__c = gatewayResponse
					);

					System.debug(updateOrder);

					orderUpdateList.add(updateOrder);
				} else {
					System.debug('Order ' + order.Id + ' ignored because order status is ' + previousOrderStatus);
				}

				processedOrderIdSet.add(order.Id);
			}
		}

		if (orderUpdateList.isEmpty() == false) {
			Set<Id> cancelOrderIdSet = new Set<Id>();

			update orderUpdateList;
			
			for (Order order : orderUpdateList) {
				Boolean orderStatus = orderStatusMap.get(order.Id);

				if (orderStatus != null && orderStatus) {
					// Payment with Success, proceed flow for Order
					updateCampaignMembers(order.Id);
					Order_Svc.saveCouponUsed(order.Id, order.ShipToContactId);
					sendFormHandlerToPardot(order.Id);
				} else {
					// Payment with Failure, Cancel the Subscription/Invoice
					cancelOrderIdSet.add(order.Id);
				}
			}

			if (cancelOrderIdSet.isEmpty() == false) {
				rollbackZuoraOrders(cancelOrderIdSet);
			}
		}
	}

	/**
		Correlate the Order with the Payment.

	*/
	public static void correlateCreditCardPaymentsWithOrders(List<Zuora__Payment__c> newRecords, Map<Id,Zuora__Payment__c> oldRecordsMap) {
		Set<String> transactionNumberSet = new Set<String>();
		Map<String,Id> orderIdMap = new Map<String,Id>();
		Integer seq;

		if (newRecords != null) {
			seq = -1;
			for (Zuora__Payment__c payment : newRecords) {
				seq++;

				/* check if to bypass trigger logic */
				if (payment.Id != null && updateIgnoredSet.contains(payment.Id)) {
					continue;
				} else if (payment.Id == null && insertIgnoredSet.contains(seq)) {
					continue;
				}
				
				if (payment.Zuora__PaymentMethod__c != null && payment.Zuora__PaymentMethod__c.startsWith('Credit Card')) {
					transactionNumberSet.add(payment.Zuora__ReferenceID__c);

					System.debug('Zuora Reference ID: ' + payment.Zuora__ReferenceID__c);
				}
			}
		}

		if (transactionNumberSet.isEmpty() == false) {
			for (Order order : [SELECT Id, Payment_Transaction_Number__c FROM Order WHERE Payment_Transaction_Number__c != NULL AND Payment_Transaction_Number__c IN : transactionNumberSet]) {
				orderIdMap.put(order.Payment_Transaction_Number__c, order.Id);

				System.debug('Zuora Reference ID: ' + order.Payment_Transaction_Number__c + ', Order ID: ' + order.Id);
			}
		}

		if (newRecords != null) {
			seq = -1;
			for (Zuora__Payment__c payment : newRecords) {
				seq++;

				/* check if to bypass trigger logic */
				if (payment.Id != null && updateIgnoredSet.contains(payment.Id)) {
					continue;
				} else if (payment.Id == null && insertIgnoredSet.contains(seq)) {
					continue;
				}

				System.debug('Payment Method: ' + payment.Zuora__PaymentMethod__c);

				if (payment.Zuora__PaymentMethod__c != null && payment.Zuora__PaymentMethod__c.startsWith('Credit Card')) {
					String transactionNumber = payment.Zuora__ReferenceID__c;

					if (transactionNumber != null) {
						Id orderId = orderIdMap.get(transactionNumber);

						if (orderId != null) {
							// connect Payment with respective Order
							payment.Order__c = orderId;

							System.debug('Assigning Order ID: ' + orderId + ' to Zuora Reference ID: ' + transactionNumber);
						}
					}
				}
			}
		}
	}

	/**

		Create Payment Errors records.

	*/
	public static void createPaymentErrors(Map<Id,Zuora__Payment__c> paymentErrorMap) {
		List<IEC_Payment_Error__c> paymentErrorList = new List<IEC_Payment_Error__c>();

		for (Zuora__Payment__c payment : paymentErrorMap.values()) {
			paymentErrorList.add(getPaymentError(payment));
		}

		if (paymentErrorList.isEmpty() == false) {
			upsert  paymentErrorList Unique_External_Id__c;
		}
	}

	static IEC_Payment_Error__c getPaymentError(Zuora__Payment__c zp) {
		IEC_Payment_Error__c ipe = new IEC_Payment_Error__c(
			Name = zp.Zuora__ReferenceId__c,
			Payment_ID__c = zp.Name,
			Account__c = zp.Zuora__Account__c,
			Accounting_Code__c = zp.Zuora__AccountingCode__c,
			Amount__c = zp.Zuora__Amount__c,
			Applied_Credit_Balance_Amount__c = zp.Zuora__AppliedCreditBalanceAmount__c,
			Applied_Invoice_Amount__c = zp.Zuora__AppliedInvoiceAmount__c,
			Auth_Transaction_ID__c = zp.Zuora__AuthTransactionId__c,
			Bank_Identification_Number__c = zp.Zuora__BankIdentificationNumber__c,
			Billing_Account__c = zp.Zuora__BillingAccount__c,
			Cancelled_On__c = zp.Zuora__CancelledOn__c,
			Comment__c = zp.Zuora__Comment__c,
			Created_By__c = zp.Zuora__CreatedById__c,
			Created_Date__c = zp.Zuora__CreatedDate__c,
			Effective_Date__c = zp.Zuora__EffectiveDate__c,
			Gateway_Order_ID__c = zp.Zuora__GatewayOrderId__c,
			Gateway_Response__c = zp.Zuora__GatewayResponse__c,
			Gateway_Response_Code__c = zp.Zuora__GatewayResponseCode__c,
			Gateway_State__c = zp.Zuora__GatewayStatus__c,
			Invoice_Number__c = zp.Zuora__InvoiceNumber__c,
			Market_For_Submission_On__c = zp.Zuora__MarkedForSubmissionOn__c,
			Order__c = zp.Order__c,
			Payment_Method__c = zp.Zuora__PaymentMethod__c,
			Payment_Number__c = zp.Zuora__PaymentNumber__c,
			Reference_ID__c = zp.Zuora__ReferenceId__c,
			Refund_Amount__c = zp.Zuora__RefundedAmount__c,
			Second_Payment_Reference_ID__c = zp.Zuora__SecondPaymentReferenceId__c,
			Settled_On__c = zp.Zuora__SettledOn__c,
			SIS_Invoice_Number__c = zp.SISInvoiceNumber__c,
			Soft_Descriptor__c = zp.Zuora__SoftDescriptor__c,
			Soft_Descriptor_Phone__c = zp.Zuora__SoftDescriptorPhone__c,
			Status__c = zp.Zuora__Status__c,
			Submitted_On__c = zp.Zuora__SubmittedOn__c,
			Transfered_to_Accounting__c = zp.Zuora__TransferedToAccounting__c,
			Type__c = zp.Zuora__Type__c,
			Unique_External_Id__c = zp.Zuora__EXT_ID__c,
			Updated_By__c = zp.Zuora__UpdatedById__c,
			Updated_Date__c = zp.Zuora__UpdatedDate__c
		);

		return ipe;
	}

	@future (callout=true)
	static void rollbackZuoraOrders(Set<Id> orderIdSet) {
		Map<Id,Order> orderMap = new Order_Sel().getOrderByStatus(orderIdSet);
		Map<Id,List<OrderItem>> orderItemListMap = new OrderItem_Sel().getOrderItems(orderIdSet);
		List<String> paymentIdList = new List<String>();
		List<String> subscriptionIdList = new List<String>();
		List<String> invoiceIdList = new List<String>();

		List<Zuora.zObject> paymentList;
		List<Zuora.zObject> invoiceList;
		List<Zuora.zObject> subscriptionList;

		List<IEC_Error_Log__c> errorLogList = new List<IEC_Error_Log__c>();

		for (Id orderId : orderItemListMap.keySet()) {
			Order order = orderMap.get(orderId);
			String zuoraTransactionId = order.Zuora_Transaction_Id__c;
			String zuoraSubscriptionId = order.IEC_Zuora_ST_SubscriptionId__c;
			String zuoraInvoiceId = order.IEC_Zuora_ST_InvoiceId__c;

			if (zuoraTransactionId != null) {
				paymentIdList.add(zuoraTransactionId);
			}

			if (zuoraSubscriptionId != null) {
				subscriptionIdList.add(zuoraSubscriptionId);
			}

			if (zuoraInvoiceId != null) {
				invoiceIdList.add(zuoraInvoiceId);
			}

			for (OrderItem orderItem : orderItemListMap.get(orderId)) {
				zuoraSubscriptionId = orderItem.Zuora_SubscriptionId__c;
				zuoraInvoiceId = orderItem.Zuora_InvoiceId__c;

				if (zuoraSubscriptionId != null) {
					subscriptionIdList.add(zuoraSubscriptionId);
				}

				if (zuoraInvoiceId != null) {
					invoiceIdList.add(zuoraInvoiceId);
				}
			}
		}

		if (paymentIdList.isEmpty() == false) {
			paymentList = zoqlQuery('Payment', new List<String> { 'Id', 'Status', 'AccountId' }, 'Id', paymentIdList);
		}

		if (subscriptionIdList.isEmpty() == false) {
			subscriptionList = zoqlQuery('Subscription', new List<String> { 'Id', 'Status' }, 'Id', subscriptionIdList);
		}

		if (invoiceIdList.isEmpty() == false) {
			invoiceList = zoqlQuery('Invoice', new List<String> { 'Id', 'Status' }, 'Id', invoiceIdList);
		}

		zuoraCancelPayments(paymentList, errorLogList);
		zuoraDraftInvoices(invoiceList, errorLogList);
		zuoraCancelInvoices(invoiceList, errorLogList);
		zuoraDeletePayments(paymentList, errorLogList);
		zuoraDeleteInvoices(invoiceList, errorLogList);
		zuoraDeleteSubscriptions(subscriptionList, errorLogList);

		// Log Errors (if any)
		if (errorLogList.isEmpty() == false) {
			IECErrorLogger.logErrors(errorLogList);
		}
	}

	@testVisible
	private static void zuoraCancelPayments(List<Zuora.zObject> paymentList, List<IEC_Error_Log__c> errorLogList) {
		if (paymentList != null && paymentList.isEmpty() == false) {
			for (Zuora.zObject payment : paymentList) {
				payment.setValue('Status', 'Canceled');
			}

			try {
				List<Zuora.zApi.SaveResult> saveResultList = ZuoraUtil.zupdate(paymentList);
			} catch (Exception e) {
				errorLogList.add(
					IECErrorLogger.createErrorLog('trgHndlrIECPayment/zuoraCancelPayments', JSON.serialize(paymentList), e.getMessage(), e.getStackTraceString())
				);
			}
		}
	}

	@testVisible
	private static void zuoraDeletePayments(List<Zuora.zObject> paymentList, List<IEC_Error_Log__c> errorLogList) {
		if (paymentList != null && paymentList.isEmpty() == false) {
			List<String> paymentIdList = new List<String>();

			for (Zuora.zObject payment : paymentList) {
				paymentIdList.add((String)payment.getValue('Id'));
			}

			try {
				List<Zuora.zApi.DeleteResult> deleteResultList = ZuoraUtil.zdelete('Payment', paymentIdList);
			} catch (Exception e) {
				errorLogList.add(
					IECErrorLogger.createErrorLog('trgHndlrIECPayment/zuoraDeletePayments', JSON.serialize(paymentIdList), e.getMessage(), e.getStackTraceString())
				);
			}
		}
	}

	@testVisible
	private static void zuoraDraftInvoices(List<Zuora.zObject> invoiceList, List<IEC_Error_Log__c> errorLogList) {
		if (invoiceList != null && invoiceList.isEmpty() == false) {
			List<String> invoiceIdList = new List<String>();

			for (Zuora.zObject invoice : invoiceList) {
				invoice.setValue('Status', 'Draft');
			}

			try {
				List<Zuora.zApi.SaveResult> saveResultList = ZuoraUtil.zupdate(invoiceList);
			} catch (Exception e) {
				errorLogList.add(
					IECErrorLogger.createErrorLog('trgHndlrIECPayment/zuoraDraftInvoices', JSON.serialize(invoiceList), e.getMessage(), e.getStackTraceString())
				);
			}
		}
	}

	@testVisible
	private static void zuoraCancelInvoices(List<Zuora.zObject> invoiceList, List<IEC_Error_Log__c> errorLogList) {
		if (invoiceList != null && invoiceList.isEmpty() == false) {
			List<String> invoiceIdList = new List<String>();

			for (Zuora.zObject invoice : invoiceList) {
				invoice.setValue('Status', 'Canceled');
			}

			try {
				List<Zuora.zApi.SaveResult> saveResultList = ZuoraUtil.zupdate(invoiceList);
			} catch (Exception e) {
				errorLogList.add(
					IECErrorLogger.createErrorLog('trgHndlrIECPayment/zuoraCancelInvoices', JSON.serialize(invoiceList), e.getMessage(), e.getStackTraceString())
				);
			}
		}
	}

	@testVisible
	private static void zuoraDeleteInvoices(List<Zuora.zObject> invoiceList, List<IEC_Error_Log__c> errorLogList) {
		if (invoiceList != null && invoiceList.isEmpty() == false) {
			List<String> invoiceIdList = new List<String>();

			for (Zuora.zObject invoice : invoiceList) {
				invoiceIdList.add((String)invoice.getValue('Id'));
			}

			try {
				List<Zuora.zApi.DeleteResult> deleteResultList = ZuoraUtil.zdelete('Invoice', invoiceIdList);
			} catch (Exception e) {
				errorLogList.add(
					IECErrorLogger.createErrorLog('trgHndlrIECPayment/zuoraDeleteInvoices', JSON.serialize(invoiceIdList), e.getMessage(), e.getStackTraceString())
				);
			}
		}
	}

	@testVisible
	private static void zuoraDeleteSubscriptions(List<Zuora.zObject> subscriptionList, List<IEC_Error_Log__c> errorLogList) {
		if (subscriptionList != null && subscriptionList.isEmpty() == false) {
			List<String> subscriptionIdList = new List<String>();

			for (Zuora.zObject subscription : subscriptionList) {
				subscriptionIdList.add((String)subscription.getValue('Id'));
			}

			try {
				List<Zuora.zApi.DeleteResult> deleteResultList = ZuoraUtil.zdelete('Subscription', subscriptionIdList);
			} catch (Exception e) {
				errorLogList.add(
					IECErrorLogger.createErrorLog('trgHndlrIECPayment/zuoraDeleteSubscription', JSON.serialize(subscriptionIdList), e.getMessage(), e.getStackTraceString())
				);
			}
		}
	}

	private static List<Zuora.zObject> zoqlQuery(String objectName, List<String> fieldList, String filterField, List<String> filterValueList) {
		List<Zuora.zObject> queryResultList;

		if (Test.isRunningTest()) {
			// If running Tests, simulate the answers from Zuora
			if (zuoraTestObjectData.containsKey(objectName)) {
				List<Zuora.zObject> zresultList = zuoraTestObjectData.get(objectName);

				return zresultList;
			}
		}

		try {
			String zoqlQueryString = zoqlQueryString(objectName, fieldList, filterField, filterValueList);

			System.debug('zoqlQueryString: ' + zoqlQueryString);

			queryResultList = IECZuoraHelper.queryApiCall(zoqlQueryString);
		} catch (Exception e) {
			System.debug('Error in zoqlQuery: ' + e.getStackTraceString());
		}

		return queryResultList;
	}
	
	@testVisible
	private static String zoqlQueryString(String objectName, List<String> fieldList, String filterField, List<String> filterValueList) {
		String zoql = 'SELECT ' + String.join(fieldList, ',') + ' FROM ' + objectName;

		if (filterField != null) {
			List<String> whereList = new List<String>();

			for (String filterValue : filterValueList) {
				whereList.add(filterField + ' = \'' + filterValue + '\'');
			}

			zoql += ' WHERE ' + String.join(whereList, ' OR ');
		}

		return zoql;
	}

	/****************************************************************************************************
	    Created by CGI, Thai 2017-01-25
	        Send information to Pardot
	****************************************************************************************************/
	@future (callout=true) static void sendFormHandlerToPardot(Id idOrder)
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

				//*** send to Pardot
				HttpRequest httpReq = new HttpRequest();
				httpReq.setMethod('POST');
				httpReq.setEndpoint(URL);
				Http httpTarget = new Http();
				HttpResponse httpResp = httpTarget.send(httpReq);
			}
			catch (Exception e)
			{
				IECErrorLogger.logApexException('trgHndlrIECPayment.sendFormHandlerToPardot', URL, e.getMessage(), e.getStackTraceString());
			}
	} //*** end of "sendFormHandlerToPardot"

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
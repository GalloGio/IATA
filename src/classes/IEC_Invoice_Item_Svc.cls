/*
 * Test Coverage is provided under the trgHndlrIECInvoice_tst class
 */
global without sharing class IEC_Invoice_Item_Svc {
	public class InvoiceItemException extends Exception {}


	//*** complex type to handle information for an order item
	class clsItemInfo
	{
		public Id idPriceBookEntry;
		public Boolean chargeShipping;
		public String ZInvoiceItemNumber, ZProductInfo;   //*** for error only
		public Decimal decUnitQuantity = 0, decUnitPrice = 0, decSetupQuantity = 0, decSetupPrice = 0, decDiscount = 0;
		public String ZInvoiceId, ZInvoiceNumber, ZSubscriptionId, ZSubscriptionNumber;
		public Date dtStart, dtEnd;
	}


	//*** create sales orders corresponding to Zuora invoices -> one sales order per subscription
	public static Map<String, String> CreateSalesOrder(set<Id> setInvoiceItemId)
	{
		Set<Id> setAccoutId = new Set<Id>();
		Set<Id> setContactId = new Set<Id>();
		Set<String> setProductNumber = new Set<String>();
		List<Invoice_Item__c> lstInvoiceItemRequireOrder = new List<Invoice_Item__c>(); 
		Boolean bRequireOrder = false;
		Map<Id, Map<String, Map<Id, clsItemInfo>>> mapInvZId_mapSubZId_mapZProdId_Data = new Map<Id, Map<String, Map<Id, clsItemInfo>>>();
		clsItemInfo ItemInfo;
		Map<String, Boolean> mapSubProdChargeZId_IsSetupFee = new Map<String, Boolean>();
		Map<String, String> mapSubProdChargeZId_ProdRatePlanZId = new Map<String, String>();
		Map<String, Product2> mapProdRatePlanZId_Product;
		Zuora__Subscription__c oSub;
		Map<String, Zuora__Payment__c> mapInvoice_Pmt = new Map<String, Zuora__Payment__c>();
		Map<String, String> mapZInvNum_Status = new Map<String, String>();
		String strMsg;
		
		//*** retrieve full information on the invoice items
		List<Invoice_Item__c> lstInvoiceItem = new IEC_Invoice_Item_Sel().getInvoiceItemsById(setInvoiceItemId);
		
		//*** retrieve associated subscription information
		Map<String, String> mapSubZId_ZInvNum  = new Map<String, String>();
		Map<String, String> mapSubName_ZInvNum  = new Map<String, String>();
		Map<String, Boolean> mapObjectId_IsUsed = new Map<String, Boolean>();
		for (Invoice_Item__c invItem : lstInvoiceItem)
		{
			//INC330514
			mapSubZId_ZInvNum.put(invItem.Subscription_Zuora_ID__c, invItem.Invoice__r.Name);
			//INC306838
			mapSubName_ZInvNum.put(invItem.Subscription_Number__c, invItem.Invoice__r.Name);
			mapObjectId_IsUsed.put(invItem.Invoice__r.Zuora__External_Id__c, false);
			mapZInvNum_Status.put(invItem.Invoice__r.Name, '');
		}
		//INC330514
		Map<String, Zuora__Subscription__c> mapSubZId_Subscription = new IEC_ZSubscription_Sel().getSubscriptionByZId(mapSubZId_ZInvNum.keySet());
		//INC306838
		Map<String, Zuora__Subscription__c> mapSubZName_Subscription = new IEC_ZSubscription_Sel().getSubscriptionByZName(mapSubName_ZInvNum.keySet());
		
		//*** quit on error of missing subscription
		if (mapSubZName_Subscription.isEmpty() || mapSubZName_Subscription.size() != mapSubName_ZInvNum.size())
		{
			for (String SubZId : mapSubZId_ZInvNum.keySet())
				if (!mapSubZName_Subscription.containsKey(SubZId))
				{
					//*** log error for invoice
					mapZInvNum_Status.put(mapSubZId_ZInvNum.get(SubZId), mapZInvNum_Status.get(mapSubZId_ZInvNum.get(SubZId)) + ', Error - Missing subscription "' + SubZId + '"');
					
					//*** remove all invoice items
					for (Integer i = lstInvoiceItem.size() - 1; i >= 0; i--)
						if (lstInvoiceItem[i].Invoice__r.Name == mapSubZId_ZInvNum.get(SubZId))
							lstInvoiceItem.remove(i);
				}
			if (lstInvoiceItem.size() == 0)
				return mapZInvNum_Status;
		}
		
		//*** get invoices already processed to skip processing again
		for (OrderItem oi : [select Zuora_InvoiceId__c from OrderItem where Zuora_InvoiceId__c in :mapObjectId_IsUsed.keySet()])
			mapObjectId_IsUsed.put(oi.Zuora_InvoiceId__c, true);
		
		//*** determine what charge is setup fee charge and corresponding rate plan
		List<String> lstExcludeCharge = new List<String>{Utility.getTextSetting('Zuora tax Charge id'), Utility.getTextSetting('Zuora shipping Charge id')};
		for (Zuora__SubscriptionProductCharge__c spc : [select Zuora__Zuora_Id__c, Zuora__Model__c, Zuora__Quantity__c, Zuora__Price__c
		                                                     , Product_Rate_Plan_Charge__r.Product_Number__c, Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c
		                                                     , Zuora__Subscription__r.Zuora__External_Id__c, Zuora__Product__c
		                                                from Zuora__SubscriptionProductCharge__c
		                                                where Zuora__Subscription__r.Zuora__External_Id__c in :mapSubZId_Subscription.keySet()
		                                                  and Product_Rate_Plan_Charge__r.zqu__ZuoraId__c not in :lstExcludeCharge
		                                                  and Product_Rate_Plan_Charge__r.zqu__Model__c not in ('Discount-Fixed Amount', 'Discount-Percentage')])
		{
			if (spc.Zuora__Model__c == IECConstants.ChargeModel_Zuora_FlatFeePricing)
			{
				mapSubProdChargeZId_IsSetupFee.put(spc.Zuora__Zuora_Id__c, true);
				//*** for case of no match on subscription product charge - subscription + ZProduct Id + quantity + price
				mapSubProdChargeZId_IsSetupFee.put(spc.Zuora__Subscription__r.Zuora__External_Id__c + ',' + spc.Zuora__Product__c
				                                 + ',' + spc.Zuora__Quantity__c + ',' + spc.Zuora__Price__c, true);
			}
			if (spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c != null)
			{
				mapSubProdChargeZId_ProdRatePlanZId.put(spc.Zuora__Zuora_Id__c, spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c);
				//*** for case of no match on subscription product charge - subscription + material number
				mapSubProdChargeZId_ProdRatePlanZId.put(spc.Zuora__Subscription__r.Zuora__External_Id__c + ',' + spc.Product_Rate_Plan_Charge__r.Product_Number__c
				                                      , spc.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c);
			}
		}
		
		//*** get eligible invoice items to create orders
		for (Invoice_Item__c invItem : lstInvoiceItem)
		{
			//INC306838
			//oSub = mapSubZId_Subscription.get(invItem.Subscription_Zuora_ID__c);
			oSub = mapSubZName_Subscription.get(invItem.Subscription_Number__c);
			
			// We only require an order if the OrderID is not specified on the subscription i.e. subscription created from Zuora
			// OR if the version number is greater than 1 which means there is an amendment on it
			//		which could be either (Renewal [Auto/Manual], Upgrade)
			// AND also make sure that the order is not created from a previous job based on invoice Id
			bRequireOrder = (String.isBlank(oSub.OrderId__c) || oSub.Zuora__Version__c > 1) && !mapObjectId_IsUsed.get(invItem.Invoice__r.Zuora__External_Id__c);
			
			if (bRequireOrder)
			{
				//*** exclude shipping & tax since they are not attached to any product and charge of 0 dollar
				if ('Shipping'.equalsIgnoreCase(invItem.New_Product__r.Name) || 'Tax'.equalsIgnoreCase(invItem.New_Product__r.Name) || invItem.Charge_Amount__c == 0)
					continue;
				
				//*** create working item for invoice if necessary
				if (!mapInvZId_mapSubZId_mapZProdId_Data.containsKey(invItem.Invoice__c))
				{
					mapInvZId_mapSubZId_mapZProdId_Data.put(invItem.Invoice__c, new Map<String, Map<Id, clsItemInfo>>());
					mapInvoice_Pmt.put(invItem.Invoice__r.Name, null);
				}
				
				//*** create working item for subscription under an invoice if necessary
				if (!mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).containsKey(invItem.Subscription_Zuora_ID__c))
					mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).put(invItem.Subscription_Zuora_ID__c, new Map<Id, clsItemInfo>());
				
				//*** create working item for product under a subscription if necessary
				if (!mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).get(invItem.Subscription_Zuora_ID__c).containsKey(invItem.New_Product__c))
				{
					ItemInfo = new clsItemInfo();
					ItemInfo.ZInvoiceId = invItem.Invoice__r.Zuora__External_Id__c;
					ItemInfo.ZInvoiceNumber = invItem.Invoice__r.Name;
					ItemInfo.ZSubscriptionId = invItem.Subscription_Zuora_ID__c;
					ItemInfo.ZSubscriptionNumber = invItem.Subscription_Number__c;
					ItemInfo.ZInvoiceItemNumber = invItem.Name;
					ItemInfo.ZProductInfo = invItem.New_Product__r.Name + ' (' + invItem.New_Product__r.SAP_Material_Number__c + ')';
					mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).get(invItem.Subscription_Zuora_ID__c).put(invItem.New_Product__c, ItemInfo);
				}
				else
					ItemInfo = mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).get(invItem.Subscription_Zuora_ID__c).get(invItem.New_Product__c);
				
				if (invItem.Charge_Amount__c > 0)
				{
					//*** not discount -> prepare to create order and order item
					lstInvoiceItemRequireOrder.add(invItem);
					setAccoutId.add(invItem.Invoice__r.Zuora__Account__c);
					setContactId.add(invItem.Invoice__r.Zuora__BillingAccount__r.Contact__c);
					setProductNumber.add(invItem.New_Product__r.SAP_Material_Number__c);
					if (mapSubProdChargeZId_IsSetupFee.get(invItem.Subscription_Product_Charge_Zuora_ID__c) == true ||
						mapSubProdChargeZId_IsSetupFee.get(invItem.Subscription_Zuora_ID__c + ',' + invItem.New_Product__c + ',' + invItem.Quantity__c + ',' + invItem.Unit_Price__c) == true)
					{
						ItemInfo.decSetupQuantity = invItem.Quantity__c;
						ItemInfo.decSetupPrice = invItem.Charge_Amount__c / invItem.Quantity__c;   //*** do not use Unit_Price__c because Charge_Amount__c may different than Unit_Price__c * Quantity__c
						ItemInfo.dtStart = invItem.Service_Start_Date__c;
						ItemInfo.dtEnd = invItem.Service_End_Date__c;
					}
					else
					{
						ItemInfo.decUnitQuantity = invItem.Quantity__c;
						ItemInfo.decUnitPrice = invItem.Charge_Amount__c / invItem.Quantity__c;   //*** do not use Unit_Price__c because Charge_Amount__c may different than Unit_Price__c * Quantity__c
						ItemInfo.dtStart = invItem.Service_Start_Date__c;
						ItemInfo.dtEnd = invItem.Service_End_Date__c;
					}
				}
				else
					//*** discount -> summarize
					ItemInfo.decDiscount += invItem.Charge_Amount__c;
			}
		}

		//*** quit if no need to create order
		if (lstInvoiceItemRequireOrder.size() == 0)
			return mapZInvNum_Status;
		
		//*** get hierarchy product information based on rate plan
		mapProdRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(new Set<String>(mapSubProdChargeZId_ProdRatePlanZId.values()));

		//*** get product information based on material number of ZProduct (i.e. for both regular & hierarchy product)
		Map<String, Product2> mapProdNum_Product = Product_Sel.getProductsByCode(setProductNumber);

		//*** get price book entries -> assuming all products have price book entries
		Set<Id> setProductId = new Set<Id>();
		for (Product2 p : mapProdNum_Product.values())
			setProductId.add(p.Id);
		for (Product2 p : mapProdRatePlanZId_Product.values())
			setProductId.add(p.Id);
		Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
		Map<Id, PricebookEntry> mapProdId_PBE = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, setProductId);
		
		//*** set price book entries to items
		for (Invoice_Item__c invItem : lstInvoiceItemRequireOrder)
		{
			ItemInfo = mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.New_Invoice__c).get(invItem.Subscription_Zuora_ID__c).get(invItem.New_Product__c);
			
			//*** get price book entry from hierarchy product based on subscription product charge
			String strSearchKey = invItem.Subscription_Product_Charge_Zuora_ID__c;
			if (ItemInfo.idPriceBookEntry == null &&
			    mapSubProdChargeZId_ProdRatePlanZId.containsKey(strSearchKey) &&
			    mapProdRatePlanZId_Product.containsKey(mapSubProdChargeZId_ProdRatePlanZId.get(strSearchKey)) &&
			    mapProdId_PBE.containsKey(mapProdRatePlanZId_Product.get(mapSubProdChargeZId_ProdRatePlanZId.get(strSearchKey)).Id))
				ItemInfo.idPriceBookEntry = mapProdId_PBE.get(mapProdRatePlanZId_Product.get(mapSubProdChargeZId_ProdRatePlanZId.get(strSearchKey)).Id).Id;
			
			//*** get price book entry from hierarchy product based on subscription and material
			strSearchKey = invItem.Subscription_Zuora_ID__c + ',' + invItem.New_Product__r.SAP_Material_Number__c;
			if (ItemInfo.idPriceBookEntry == null &&
			    mapSubProdChargeZId_ProdRatePlanZId.containsKey(strSearchKey) &&
			    mapProdRatePlanZId_Product.containsKey(mapSubProdChargeZId_ProdRatePlanZId.get(strSearchKey)) &&
			    mapProdId_PBE.containsKey(mapProdRatePlanZId_Product.get(mapSubProdChargeZId_ProdRatePlanZId.get(strSearchKey)).Id))
				ItemInfo.idPriceBookEntry = mapProdId_PBE.get(mapProdRatePlanZId_Product.get(mapSubProdChargeZId_ProdRatePlanZId.get(strSearchKey)).Id).Id;
			
			//*** get price book entry from material number -> regular product
			if (ItemInfo.idPriceBookEntry == null &&
			    mapProdNum_Product.containsKey(invItem.New_Product__r.SAP_Material_Number__c) &&
			    mapProdId_PBE.containsKey(mapProdNum_Product.get(invItem.New_Product__r.SAP_Material_Number__c).Id))
				ItemInfo.idPriceBookEntry = mapProdId_PBE.get(mapProdNum_Product.get(invItem.New_Product__r.SAP_Material_Number__c).Id).Id;
			
			if (ItemInfo.idPriceBookEntry != null)
				ItemInfo.chargeShipping = mapProdNum_Product.get(invItem.New_Product__r.SAP_Material_Number__c).Charge_Shipping__c;
		}

		//*** check all lines have price book entry and special treatment for discount
		for (Id InvZId : mapInvZId_mapSubZId_mapZProdId_Data.keySet())
			for (String SubZId : mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).keySet())
			{
				Decimal decDiscount = 0;
				for (Id ZProdId : mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).get(SubZId).keySet())
				{
					ItemInfo = mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).get(SubZId).get(ZProdId);
					if (ItemInfo.idPriceBookEntry == null)
						if (ItemInfo.decUnitPrice == 0 && ItemInfo.decSetupPrice == 0)
						{
							decDiscount += ItemInfo.decDiscount;
							mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).get(SubZId).remove(ZProdId);   //*** remove product since just discount
						}
						else
						{
							mapZInvNum_Status.put(ItemInfo.ZInvoiceNumber, mapZInvNum_Status.get(ItemInfo.ZInvoiceNumber) + ', Error - Invoice Item "' + ItemInfo.ZInvoiceItemNumber
							                                             + '", ZProduct "' + ItemInfo.ZProductInfo + ')" does not have product entry or standard price book entry');
							decDiscount = 1;   //*** indicate to raise error
							break;
						}
				}
				if (decDiscount < 0)
					//*** apply discount to the first applicable product since don't know discount for which product
					for (Id ZProdId : mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).get(SubZId).keySet())
					{
						ItemInfo = mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).get(SubZId).get(ZProdId);
						if (Math.abs(decDiscount + ItemInfo.decDiscount) < ItemInfo.decUnitQuantity * ItemInfo.decUnitPrice + ItemInfo.decSetupQuantity * ItemInfo.decSetupPrice)
						{
							ItemInfo.decDiscount += decDiscount;
							break;
						}
					}
				else if (decDiscount > 0)
					//*** remove subscription because error
					mapInvZId_mapSubZId_mapZProdId_Data.get(InvZId).remove(SubZId);
			}

		//*** get related ZPayments
		for (Zuora__Payment__c ZPmt : [select Zuora__InvoiceNumber__c , Zuora__ReferenceId__c, Zuora__External_Id__c, Zuora__EffectiveDate__c, Zuora__PaymentMethod__c
		                               from Zuora__Payment__c
		                               where Zuora__InvoiceNumber__c in :mapInvoice_Pmt.keySet()])
			mapInvoice_Pmt.put(ZPmt.Zuora__InvoiceNumber__c, ZPmt);

		//*** get accounts and contacts information
		Map<Id, Zuora__CustomerAccount__c> mapContactID_BillingAccount = CustomerAccount_Sel.getZuoraCustmerAccount(setContactId);
		Map<Id, Account> mapAccount = new Account_Sel().getAccountById(setAccoutId);
		Map<Id, Contact> mapContact = Contact_Sel.getContactById(setContactId);
		Location_Svc.initializeDefaultLocations(new List<Id>(setContactId));

		//*** build order and order items: 1 order per subscription
		List<Order> lstOrder = new List<Order>(), lstOrderStatus = new List<Order>();
		List<OrderItem> lstOrderItem = new List<OrderItem>();
		List<Integer> lstOrderIndex = new List<Integer>();
		Set<String> setZInvNumProcessed = new Set<String>();
		mapObjectId_IsUsed.clear();
		for (Invoice_Item__c invItem : lstInvoiceItemRequireOrder)
			if (mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).containsKey(invItem.Subscription_Zuora_ID__c) &&
				!mapObjectId_IsUsed.containsKey(invItem.Invoice__c + invItem.Subscription_Zuora_ID__c))
			{
				setZInvNumProcessed.add(invItem.Invoice__r.Name);
				mapObjectId_IsUsed.put(invItem.Invoice__c + invItem.Subscription_Zuora_ID__c, true);
				
				//*** get the payment method for order
				//INC306838
				//oSub = mapSubZId_Subscription.get(invItem.Subscription_Zuora_ID__c);
				oSub = mapSubZName_Subscription.get(invItem.Subscription_Number__c);
				
				Zuora__CustomerAccount__c oBillingAccount = mapContactID_BillingAccount.get(invItem.Invoice__r.Zuora__BillingAccount__r.Contact__c);
				String sPaymentMethod = null;
				Zuora__Payment__c ZPmt = mapInvoice_Pmt.get(invItem.Invoice__r.Name);
				if (ZPmt != null)
				{
					if (ZPmt.Zuora__PaymentMethod__c.startsWithIgnoreCase('Credit'))
						sPaymentMethod = IECConstants.PaymentThresholdType_CreditCard;
					else
						sPaymentMethod = IECConstants.parsePaymentMethodTypeToTypeWithSpaces(ZPmt.Zuora__PaymentMethod__c.replace(' ', ''));
				}
				else
				{
					if(oBillingAccount != null && oBillingAccount.Zuora__Default_Payment_Method__c != null && oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__Type__c != null)
						sPaymentMethod = IECConstants.parsePaymentMethodTypeToTypeWithSpaces(oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__Type__c.replace(' ', ''));
					if(sPaymentMethod == null && oBillingAccount != null && oBillingAccount.Zuora__DefaultPaymentMethod__c != null)
						sPaymentMethod = IECConstants.parsePaymentMethodTypeToTypeWithSpaces(oBillingAccount.Zuora__DefaultPaymentMethod__c.replace(' ', ''));
				}
				
				//*** create order
				Account oAccount = mapAccount.get(invItem.Invoice__r.Zuora__Account__c);
				Contact oContact = mapContact.get(invItem.Invoice__r.Zuora__BillingAccount__r.Contact__c);
				Order oOrder = new Order_Sel().initializeOrder(oAccount, oContact, UserInfo.getUserId(), false);
				lstOrder.add(oOrder);
				lstOrderStatus.add(new Order(Status=Order_Svc.getOrderStatusByPaymentType(sPaymentMethod), Is_Paid__c=Order_Svc.isOrderPaidByPaymentType(sPaymentMethod)));
				oOrder.Type = 'Order';
				oOrder.EffectiveDate = invItem.Invoice__r.Zuora__InvoiceDate__c;
				oOrder.Payment_Type__c = sPaymentMethod;
				oOrder.IEC_Payment_Date__c = (oOrder.Is_Paid__c) ? ((ZPmt != null && ZPmt.Zuora__EffectiveDate__c != null) ? ZPmt.Zuora__EffectiveDate__c.date() : invItem.Invoice__r.Zuora__InvoiceDate__c) : null;
				oOrder.Payment_Transaction_Number__c = (ZPmt != null) ? ZPmt.Zuora__ReferenceId__c : null;
				oOrder.Zuora_Transaction_Id__c = (ZPmt != null) ? ZPmt.Zuora__External_Id__c : null;
				
				//*** create order items
				for (String ZProdId : mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).get(invItem.Subscription_Zuora_ID__c).keySet())
				{
					ItemInfo = mapInvZId_mapSubZId_mapZProdId_Data.get(invItem.Invoice__c).get(invItem.Subscription_Zuora_ID__c).get(ZProdId);
					OrderItem oOrderItem = new OrderItem (
					    PriceBookEntryId = ItemInfo.idPriceBookEntry
					    , Quantity = (ItemInfo.decUnitQuantity != 0 ? ItemInfo.decUnitQuantity : ItemInfo.decSetupQuantity)
					    , UnitPrice = (ItemInfo.decUnitQuantity != 0 ? ItemInfo.decUnitPrice : ItemInfo.decSetupPrice)
					    , Discount__c = (ItemInfo.decDiscount != 0 ? Math.abs(ItemInfo.decDiscount) : null)
					    , Setup_Fee__c = (ItemInfo.decSetupPrice != 0 ? (ItemInfo.decUnitQuantity != 0 ? ItemInfo.decSetupPrice : null) : null)
					    , Charge_Shipping__c = ItemInfo.chargeShipping
					    , Zuora_InvoiceId__c = ItemInfo.ZInvoiceId
					    , Zuora_InvoiceNumber__c = ItemInfo.ZInvoiceNumber
					    , Zuora_SubscriptionId__c = ItemInfo.ZSubscriptionId
					    , Zuora_Subscription_Number__c = ItemInfo.ZSubscriptionNumber
					    , IEC_Contract_Start_Date__c = ItemInfo.dtStart
					    , IEC_Contract_End_Date__c = ItemInfo.dtEnd
					    //, IEC_Is_Paid__c = oOrder.Is_Paid__c
					);
					lstOrderItem.add(oOrderItem);
					lstOrderIndex.add(lstOrder.size() - 1);   //*** to assign to order later
				}
			}

		//*** create orders
		if (lstOrder.size() > 0)
		{
			Savepoint sp = Database.setSavepoint();
			Map<Id, String> mapOrderId_ZInvNum = new Map<Id, String>();
			Set<Id> setOrderIdOK = new Set<Id>();
			try
			{
				insert lstOrder;
				
				//*** set order items to orders
				for (Integer i2 = 0; i2 < lstOrderItem.size(); i2++)
				{
					lstOrderItem[i2].OrderId = lstOrder[lstOrderIndex[i2]].Id;
					mapOrderId_ZInvNum.put(lstOrderItem[i2].OrderId, lstOrderItem[i2].Zuora_InvoiceNumber__c);
				}
				insert lstOrderItem;
				
				//*** change status
				for (Integer i2 = lstOrderStatus.size() - 1; i2 >= 0; i2--)
					if (lstOrderStatus[i2].Status == null || lstOrderStatus[i2].Status == 'New')
						lstOrderStatus.remove(i2);
					else
					{
						lstOrderStatus[i2].Id = lstOrder[i2].Id;
						setOrderIdOK.add(lstOrder[i2].Id);
					}
				update lstOrderStatus;
				
				//*** update processing status
				Map<Id, Order> mapOrderId_Order = new Map<Id, Order>([select Id, OrderNumber from Order where Id in :mapOrderId_ZInvNum.keySet()]);
				for (Id OrderId : mapOrderId_ZInvNum.keySet())
					mapZInvNum_Status.put(mapOrderId_ZInvNum.get(OrderId), mapZInvNum_Status.get(mapOrderId_ZInvNum.get(OrderId))
					                                                     + ', ' + (setOrderIdOK.contains(OrderId) ? '' : 'Error - ')
					                                                     + 'Order ' + mapOrderId_Order.get(OrderId).OrderNumber + ' (' + String.valueOf(OrderId).left(15) + ')'
					                                                     + (setOrderIdOK.contains(OrderId) ? ' sent' : ' created with missing payment method'));
			}
			catch (Exception ex)
			{
				for (String s : setZInvNumProcessed)
					mapZInvNum_Status.put(s, mapZInvNum_Status.get(s) + ', Error - Failed to create order: ' + ex.getMessage() + ', ' + ex.getStackTraceString());
				Database.rollback(sp);
			}
		}
		
		//*** log errors if applicable
		for (String s : mapZInvNum_Status.keySet())
			if (mapZInvNum_Status.get(s) != '')
				mapZInvNum_Status.put(s, mapZInvNum_Status.get(s).substring(2));
		return mapZInvNum_Status;
	}
	
}
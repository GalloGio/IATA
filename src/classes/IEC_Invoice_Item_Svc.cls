/*
 * Test Coverage is provided under the trgHndlrIECInvoice_tst class
 */
public without sharing class IEC_Invoice_Item_Svc {
    public class InvoiceItemException extends Exception {}

	public static void CreateSalesOrder(set<Id> setInvoiceItemId)
	{
		// Retrieve full information on the invoice item
		List<Invoice_Item__c> lstInvoiceItem = new IEC_Invoice_Item_Sel().getInvoiceItemsById(setInvoiceItemId);
		
		Set<String> setSubscriptionZId = new Set<String>();
		
		// First loop determines related subscription
		for (Invoice_Item__c invItem : lstInvoiceItem)
		{
			setSubscriptionZId.add(invItem.Subscription_Zuora_ID__c);
		}
		
		/*****************************
		* Query related subscriptions
		*****************************/
		Map<String, Zuora__Subscription__c> mapSubscription = new IEC_ZSubscription_Sel().getSubscriptionByZId(setSubscriptionZId);
		Map<String, OrderItem> mapSubZId_OrderItem = new OrderItem_Sel().getOrderItemBySubscriptionZId(setSubscriptionZId);
		
		if (mapSubscription.isEmpty()) throw new InvoiceItemException('No Subscriptions were found related to the invoice');
		
		Set<Id> setAccoutId = new Set<Id>();
		Set<Id> setContactId = new Set<Id>();
		Set<Id> setInvoiceId = new Set<Id>();
		Set<String> setProductNumber = new Set<String>();
		List<Invoice_Item__c> lstInvoiceItemRequireOrder = new List<Invoice_Item__c>(); 
		setSubscriptionZId.clear();
		Boolean bRequireOrder = false;
		
		/************************************************************************************************
		* Query related Billing Account/Account/Contact for only subscriptions that doesn't have OrderId
		*************************************************************************************************/
		for (Invoice_Item__c invItem : lstInvoiceItem)
		{
			Zuora__Subscription__c oSub = mapSubscription.get(invItem.Subscription_Zuora_ID__c);
			
			// We only require an order if the OrderID is not specified on the subscription
			// OR if the version number is greater than 1 which means there is an amendment on it
			//		which could be either (Renewal [Auto/Manual], Upgrade)
			// AND also make sure that the order is not created from a previous job from split invoice items on two different batches
			bRequireOrder = (String.isBlank(oSub.OrderId__c) || oSub.Zuora__Version__c > 1) && !mapSubZId_OrderItem.containsKey(oSub.Zuora__External_Id__c);
			
			if (bRequireOrder)
			{
				lstInvoiceItemRequireOrder.add(invItem);
				setAccoutId.add(invItem.Invoice__r.Zuora__Account__c);
				setContactId.add(invItem.Invoice__r.Zuora__BillingAccount__r.Contact__c);
				setSubscriptionZId.add(oSub.Zuora__External_Id__c);
				setProductNumber.add(invItem.Product__r.SAPProductMaterialNo__c);
				setInvoiceId.add(invItem.Invoice__c);
			}
		}
		
		/***********************
		* Get related ZPayments
		***********************/
		Map<Id, Zuora__Payment__c> mapInvId_Pmt = new Map<Id, Zuora__Payment__c>();
		for (Zuora__Payment__c ZPmt :
			[SELECT Zuora__Invoice__c , Zuora__ReferenceId__c, Zuora__External_Id__c
            FROM Zuora__Payment__c
            WHERE Zuora__Invoice__c IN :setInvoiceId]) {
			
			mapInvId_Pmt.put(ZPmt.Zuora__Invoice__c, ZPmt);
		}

		Map<Id, Zuora__CustomerAccount__c> mapContactID_BillingAccount = CustomerAccount_Sel.getZuoraCustmerAccount(setContactId);
		Map<Id, Account> mapAccount = new Account_Sel().getAccountById(setAccoutId);
		Map<Id, Contact> mapContact = Contact_Sel.getContactById(setContactId);
		
		/*******************************************************
		* This will query products that are mainly publications
		*******************************************************/
		Map<String, Product2> mapProdNum_Product = Product_Sel.getProductsByCode(setProductNumber);
		
		// Retrieve all Charges under the specified subscriptions (Excluding Tax/Shipping/Discount)
        Map<String, List<Zuora__SubscriptionProductCharge__c>> mapSubChrgProd = new IEC_ZSubscriptionProductCharge_Sel().getZSubscriptionProductChargeByProdRatePlanChargeZId(
                setSubscriptionZId
                , new Set<String> {Utility.getTextSetting('Zuora tax Charge id'), Utility.getTextSetting('Zuora shipping Charge id')}
                , false
                , 'Product_Rate_Plan_Charge__r.zqu__Model__c NOT IN (\'\'Discount-Fixed Amount\'\', \'\'Discount-Percentage\'\')');
        
        /*******************************************************
		* Get Product prices based on charges on Invoice Items
		*******************************************************/
		Map<String, Decimal> mapSubZId_ProductPrice = new Map<String, Decimal>();
		Map<String, Decimal> mapSubZId_ProductSetupFee = new Map<String, Decimal>();
        
        // Query the Subscription Product charges from the invoice to get actual prices (Prices on the invoice items are the real numbers, the one on the subscription charges are copy of what is on the product rate plan)
        List<Invoice_Item__c> lstInvoiceItem_ProdPrice = new IEC_Invoice_Item_Sel().getInvoiceItemsBySubZId(mapSubChrgProd.keySet());

        // Determine what charge is setup fee charge
		Set<String> setSetupFeeSubscriptionProductCharge = new Set<String>();
		for (Invoice_Item__c ii : lstInvoiceItem_ProdPrice)
			setSetupFeeSubscriptionProductCharge.add(ii.Subscription_Product_Charge_Zuora_ID__c);
		List<Zuora__SubscriptionProductCharge__c> lstSetupFeeSubscriptionProductCharge = [select Zuora__Zuora_Id__c
																						  from Zuora__SubscriptionProductCharge__c
																						  where Zuora__Zuora_Id__c in :setSetupFeeSubscriptionProductCharge
																						    and Zuora__Model__c = :IECConstants.ChargeModel_Zuora_FlatFeePricing];
		setSetupFeeSubscriptionProductCharge.clear();
		for (Zuora__SubscriptionProductCharge__c sf : lstSetupFeeSubscriptionProductCharge)
			setSetupFeeSubscriptionProductCharge.add(sf.Zuora__Zuora_Id__c);

		for (Invoice_Item__c oInvoiceItem : lstInvoiceItem_ProdPrice)
		{
			if (setSetupFeeSubscriptionProductCharge.contains(oInvoiceItem.Subscription_Product_Charge_Zuora_ID__c)) {
				// Save the setup fee for product on the side to use it on the order item later
				if (mapSubZId_ProductSetupFee.containsKey(oInvoiceItem.Subscription_Zuora_ID__c))
					mapSubZId_ProductSetupFee.put(oInvoiceItem.Subscription_Zuora_ID__c, oInvoiceItem.Charge_Amount__c + mapSubZId_ProductSetupFee.get(oInvoiceItem.Subscription_Zuora_ID__c));
				else
					mapSubZId_ProductSetupFee.put(oInvoiceItem.Subscription_Zuora_ID__c, oInvoiceItem.Charge_Amount__c);
			} else {
				// Save the product price on the side to use it on the order item later
				if (mapSubZId_ProductPrice.containsKey(oInvoiceItem.Subscription_Zuora_ID__c))
					mapSubZId_ProductPrice.put(oInvoiceItem.Subscription_Zuora_ID__c, oInvoiceItem.Charge_Amount__c + mapSubZId_ProductPrice.get(oInvoiceItem.Subscription_Zuora_ID__c));
				else
					mapSubZId_ProductPrice.put(oInvoiceItem.Subscription_Zuora_ID__c, oInvoiceItem.Charge_Amount__c);
			}
		}
		
		Set<String> setProductRatePlanZId = new Set<String>();
		Map<String, Decimal> mapSubZId_TaxPrice = new Map<String, Decimal>();
		Map<String, Decimal> mapSubZId_ShippingPrice = new Map<String, Decimal>();
		Map<String, Decimal> mapSubZId_ProductQty = new Map<String, Decimal>();
		
		/*******************************************************
		* Retrieve all GDP Products to the related charges
		*******************************************************/
		for (String sSubZId : mapSubChrgProd.keySet())
		{
			for (Zuora__SubscriptionProductCharge__c oSubChrg : mapSubChrgProd.get(sSubZId))
			{
				// Save the product quantity on the side to use it on the order item later -> get maximum
				if (!setSetupFeeSubscriptionProductCharge.contains(oSubChrg.Zuora__Zuora_Id__c))
					if (!mapSubZId_ProductQty.containsKey(oSubChrg.Zuora__Subscription__r.Zuora__External_Id__c) || mapSubZId_ProductQty.get(oSubChrg.Zuora__Subscription__r.Zuora__External_Id__c) < oSubChrg.Zuora__Quantity__c)
						mapSubZId_ProductQty.put(oSubChrg.Zuora__Subscription__r.Zuora__External_Id__c, oSubChrg.Zuora__Quantity__c);
				
				// Build array of ProductRatePlan Zuora Ids
				setProductRatePlanZId.add(oSubChrg.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c);
			}
		}
		
		Map<String, Product2> mapProductRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(setProductRatePlanZId);

		/*************************************************************************
		* Retrieve all Tax and Shipping Charges under the specified subscriptions
		*************************************************************************/
        Map<String, List<Zuora__SubscriptionProductCharge__c>> mapSubChrgTaxShip = new IEC_ZSubscriptionProductCharge_Sel().getZSubscriptionProductChargeByProdRatePlanChargeZId(
                setSubscriptionZId
                , new Set<String> {Utility.getTextSetting('Zuora tax Charge id'), Utility.getTextSetting('Zuora shipping Charge id')}
                , true
                , null);
                
		if (!mapSubChrgTaxShip.isEmpty())
		{
			// Determine Tax & Shipping per subscription
			for (Invoice_Item__c invItem : lstInvoiceItemRequireOrder)
			{
				for (Zuora__SubscriptionProductCharge__c oSubChrg : mapSubChrgTaxShip.get(invItem.Subscription_Zuora_ID__c))
				{
					if (oSubChrg.Product_Rate_Plan_Charge__r.zqu__ZuoraId__c == Utility.getTextSetting('Zuora tax Charge id'))
					{
						mapSubZId_TaxPrice.put(invItem.Subscription_Zuora_ID__c, oSubChrg.Zuora__Price__c);
					}
					else if (oSubChrg.Product_Rate_Plan_Charge__r.zqu__ZuoraId__c == Utility.getTextSetting('Zuora shipping Charge id'))
					{
						mapSubZId_ShippingPrice.put(invItem.Subscription_Zuora_ID__c, oSubChrg.Zuora__Price__c);
					}
				}
			}
		}

		Map<String, String> mapSubZId_PaymentMethod = new Map<String, String>();
		Map<String, Order> mapSubZId_Order = new Map<String, Order>();
		mapSubZId_OrderItem.clear();
		
		// Retrieve standard pricebook
        Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
        
        /*******************************************************
		* Retrieve the PriceBookEntry for the products in query
		*******************************************************/
        Set<Id> setProductId = new Set<Id>();
        
        for (Product2 oProduct : mapProdNum_Product.values())
        {
        	setProductId.add(oProduct.Id);
        }
        for (Product2 oProduct : mapProductRatePlanZId_Product.values())
        {
        	setProductId.add(oProduct.Id);
        }
        
        Map<Id, PricebookEntry> mapProdId_PBE = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, setProductId);
	
		/************************************
		* Build up the Order and Order Item
		************************************/
		for (Invoice_Item__c invItem : lstInvoiceItemRequireOrder)
		{
			Zuora__Subscription__c oSub = mapSubscription.get(invItem.Subscription_Zuora_ID__c);
			Zuora__CustomerAccount__c oBillingAccount = mapContactID_BillingAccount.get(invItem.Invoice__r.Zuora__BillingAccount__r.Contact__c);
			// Get the payment method
            String sPaymentMethod = '';
            if(oBillingAccount != null && oBillingAccount.Zuora__Default_Payment_Method__c != null && oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__Type__c != null)
                sPaymentMethod = IECConstants.parsePaymentMethodTypeToTypeWithSpaces(oBillingAccount.Zuora__Default_Payment_Method__r.Zuora__Type__c);
            if(sPaymentMethod == '' && oBillingAccount != null && oBillingAccount.Zuora__DefaultPaymentMethod__c != null)
                sPaymentMethod = IECConstants.parsePaymentMethodTypeToTypeWithSpaces(oBillingAccount.Zuora__DefaultPaymentMethod__c);
			
			// Create the Order record
			if (!mapSubZId_Order.containsKey(oSub.Zuora__External_Id__c))
			{
				Account oAccount = mapAccount.get(invItem.Invoice__r.Zuora__Account__c);
				Contact oContact = mapContact.get(invItem.Invoice__r.Zuora__BillingAccount__r.Contact__c);
				Zuora__Payment__c ZPmt = (mapInvId_Pmt.containsKey(invItem.Invoice__c)) ? mapInvId_Pmt.get(invItem.Invoice__c) : null;
				
				// Create an order once the subscription is confirmed through Zuora
	            Customer_DTO oCurrentCustomer = Customer_DTO.getLoggedCustomer();
	            Order oOrder = new Order_Sel().initializeOrder(oAccount, oContact, false);
	
	            // Update order fields
	            oOrder.Type = 'Order';
	            oOrder.Payment_Type__c = sPaymentMethod;
	            //oOrder.Status = Order_Svc.getOrderStatusByPaymentType(sPaymentMethod);
	            oOrder.Is_Paid__c = Order_Svc.isOrderPaidByPaymentType(sPaymentMethod);
	            oOrder.IEC_Payment_Date__c = (Order_Svc.isOrderPaidByPaymentType(sPaymentMethod)) ? Date.today() : null;
	            oOrder.Payment_Transaction_Number__c = (ZPmt != null) ? ZPmt.Zuora__ReferenceId__c : null;
	            oOrder.Zuora_Transaction_Id__c = (ZPmt != null) ? ZPmt.Zuora__External_Id__c : null;
	            
	            mapSubZId_Order.put(oSub.Zuora__External_Id__c, oOrder);
	            
	            // Store the payment method to use it to update order status later to trigger SAP Contract creation
	            mapSubZId_PaymentMethod.put(oSub.Zuora__External_Id__c, sPaymentMethod);
			}
			
			// Create the OrderItem record	            
			if (!mapSubZId_OrderItem.containsKey(oSub.Zuora__External_Id__c))
			{
	            Product2 oProduct;
	            // First try to get the product from the GDP list
	            if (mapSubChrgProd.containsKey(oSub.Zuora__External_Id__c))
	            {
	            	for (Zuora__SubscriptionProductCharge__c oSubChrg : mapSubChrgProd.get(oSub.Zuora__External_Id__c))
					{
			            if (mapProductRatePlanZId_Product.containsKey(oSubChrg.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c))
						{
							oProduct = mapProductRatePlanZId_Product.get(oSubChrg.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZuoraId__c);
							break;
						}
					}
	            }
	            
	            // If product not found in the GDP list then it must be a Publication product
	            if (oProduct == null && mapProdNum_Product.containsKey(invItem.Product__r.SAPProductMaterialNo__c))
	            {
	            	oProduct = mapProdNum_Product.get(invItem.Product__r.SAPProductMaterialNo__c);
	            }
	            
	            if (oProduct != null)
	            {
		            OrderItem oOrderItem = new OrderItem (
		                PriceBookEntryId = mapProdId_PBE.get(oProduct.Id).Id
		                , Quantity = (mapSubZId_ProductQty.containsKey(oSub.Zuora__External_Id__c)) ? mapSubZId_ProductQty.get(oSub.Zuora__External_Id__c) : 1
		                , UnitPrice = ((mapSubZId_ProductPrice.containsKey(oSub.Zuora__External_Id__c)) ? mapSubZId_ProductPrice.get(oSub.Zuora__External_Id__c) : 0)
		                , Setup_Fee__c = mapSubZId_ProductSetupFee.get(oSub.Zuora__External_Id__c)
		                , Charge_Shipping__c = oProduct.Charge_Shipping__c
		                , Tax__c = (mapSubZId_TaxPrice.containsKey(oSub.Zuora__External_Id__c)) ? mapSubZId_TaxPrice.get(oSub.Zuora__External_Id__c) : 0
		                , Freight_Charge__c = (mapSubZId_ShippingPrice.containsKey(oSub.Zuora__External_Id__c)) ? mapSubZId_ShippingPrice.get(oSub.Zuora__External_Id__c) : null
		                , Zuora_InvoiceId__c = invItem.Invoice__r.Zuora__External_Id__c
		                , Zuora_InvoiceNumber__c = invItem.Invoice__r.Name
		                , Zuora_SubscriptionId__c = oSub.Zuora__External_Id__c
		                , Zuora_Subscription_Number__c = oSub.Name
		                , IEC_Is_Paid__c = (sPaymentMethod == 'Credit Card' || sPaymentMethod == 'ICH')
		            );
		            oOrderItem.UnitPrice = 0.00 + (oOrderItem.UnitPrice / oOrderItem.Quantity);
		            
		            mapSubZId_OrderItem.put(oSub.Zuora__External_Id__c, oOrderItem);
	            }
			}
		}
		
		/*************************************
		* Finally insert Order and Order Item
		*************************************/
		if (!mapSubZId_Order.isEmpty())
		{
			insert mapSubZId_Order.values();
			
			// Now update the OrderItems.OrderId with the recently inserted orders
			for (String sSubZId : mapSubZId_OrderItem.keySet())
			{
				mapSubZId_OrderItem.get(sSubZId).OrderId = mapSubZId_Order.get(sSubZId).Id;
				mapSubZId_Order.get(sSubZId).Status = Order_Svc.getOrderStatusByPaymentType(mapSubZId_PaymentMethod.get(sSubZId));
			}
			
			if (!mapSubZId_OrderItem.isEmpty())
			{
				insert mapSubZId_OrderItem.values();
			}
			
			// Now update the status from NEW to PAID to trigger SAP Contract creation
			update mapSubZId_Order.values();
		}
	}
}
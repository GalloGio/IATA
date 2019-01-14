/**  
  * Description: Trigger Handler for the Invoice Item object
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
public with sharing class trgHndlrIECInvoiceItem {
	public static void OnAfterInsert(List<Invoice_Item__c> newRecords, Map<Id, Invoice_Item__c> newRecordsMap) {
		/* Commented: Samy: 2016-05-12: Replaced by creating Sales Order directly in Salesforce
		Set<String> setZInvoiceItemNumber = new Set<String>();
		List<Invoice_Item__c> lstNonZeroInvoiceItems = new List<Invoice_Item__c>();

		for (Invoice_Item__c invoiceItem : newRecords) {
			// Filter out invoice and invoice items with zero amount
			if (invoiceItem.Charge_Amount__c != 0) {
				setZInvoiceItemNumber.add(invoiceItem.Name);
				lstNonZeroInvoiceItems.add(invoiceItem);
			}
		}


		if (lstNonZeroInvoiceItems.size() > 0)
			CreateSAPInvoiceItems(setZInvoiceItemNumber, lstNonZeroInvoiceItems);
		*/
		//*** (Thai 2016-11-01) should do from a job because missing subscription
		//IEC_Invoice_Item_Svc.CreateSalesOrder(newRecordsMap.keySet());
	}
	
	/**
	 * Create SAP Invoice Item records for all new invoice items that has not been created before
	 * @ param setZInvoiceItemNumber Set of Zuora of Invoice Item Numbers
	 * @ param InvoiceItems Zuora Invoice Item Records
 	 **/
 	 /* Commented: Samy: 2016-05-12: Replaced by creating Sales Order directly in Salesforce
 	 private static void CreateSAPInvoiceItems(Set<String> setZInvoiceItemNumber, List<Invoice_Item__c> InvoiceItems) {
		Set<String> setSAPInvoiceItemNumber = new Set<String>();
		
		// Determine which Invoices has been already created in SAP Invoice object
		for (IEC_SAP_Invoice_Item__c SAPItem : [SELECT Name FROM IEC_SAP_Invoice_Item__c WHERE Name IN :setZInvoiceItemNumber]) {
			setSAPInvoiceItemNumber.add(SAPItem.name);
		}
		
		List<Invoice_Item__c> lstInvoicesToSAP = new List<Invoice_Item__c>();
		Set<String> setProductId = new Set<String>();
		Set<String> setSubscriptionNumber = new Set<String>();
		Set<String> setInvoiceId = new Set<String>();
		
		// Filter out Invoices that has been already created in SAP Invoice object
		for (Invoice_Item__c item : InvoiceItems) {
			if (!setSAPInvoiceItemNumber.contains(item.Name)) {
				lstInvoicesToSAP.add(item);
				setProductId.add(item.Product__c);
				setSubscriptionNumber.add(item.Subscription_Number__c);
				setInvoiceId.add(item.Invoice__c);
			}
		}
		
		// Get related objects that will help building the SAP Invoice Item record (i.e. Zuora Product, Subscription)
		
		// Related: Zuora Product
		Map<Id, zqu__ZProduct__c> mapZProduct = new Map<Id, zqu__ZProduct__c>(
			[SELECT Id, SAPProductMaterialNo__c
			FROM zqu__ZProduct__c
			WHERE Id IN :setProductId]);
			
		// Related: Product2
		
		// First get list of SAP Material numbers
		Set<String> setSAPMaterialNo = new Set<String>();
		for (zqu__ZProduct__c zProd : mapZProduct.values())
		{
			setSAPMaterialNo.add(zProd.SAPProductMaterialNo__c);
		}
		
		Map<String, Product2> mapSAPMaterialToProduct2 = new Map<String, Product2>();
		for (Product2 prod :
			[SELECT Id, SAP_Material_Number__c, Use_Contract_when_ordered__c
				, IEC_SAP_DocType__c, IEC_SAP_EmpResp__c, SAP_Contract_OrderReason__c, IEC_SAP_ProfitCenter__c
			FROM Product2
			WHERE SAP_Material_Number__c IN :setSAPMaterialNo]) {
			
			mapSAPMaterialToProduct2.put(prod.SAP_Material_Number__c, prod);
		}
		
		// Related: Subscription
		Map<String, Zuora__Subscription__c> mapZIdToSubscription = new Map<String, Zuora__Subscription__c>();
		for (Zuora__Subscription__c subscription :
			[SELECT PurchaseOrder__c, Name, Zuora__Version__c, OrderId__c
			FROM Zuora__Subscription__c
			WHERE Name IN :setSubscriptionNumber]) {
			
			mapZIdToSubscription.put(subscription.Name, subscription);
		}
		
		// Related: Zuora Invoice
		Map<Id, Zuora__ZInvoice__c> mapZInvoice = new Map<Id, Zuora__ZInvoice__c>(
			[SELECT Id, Name, Zuora__External_Id__c
			FROM Zuora__ZInvoice__c
			WHERE Id IN :setInvoiceId]);
			
		// From Zuora Invoice get the related SAP Invoices, and ZPayment (It is done at this level instead and not on the invoice, to wait for the payment object to get created from Zuora)
		Set<String> setInvoiceNum = new Set<String>();
		Set<String> setCountry = new Set<String>();
		
		for (Zuora__ZInvoice__c inv : mapZInvoice.values()) {
			setInvoiceNum.add(inv.Name);
		}
		
		// Related: SAP Invoices
		Map<String, IEC_SAP_Invoice__c> mapInvNumToSAPInv = new Map<String, IEC_SAP_Invoice__c>();
		for (IEC_SAP_Invoice__c SAPInv :
			[SELECT Name, Billing_Country__c
			FROM IEC_SAP_Invoice__c
			WHERE Name IN :setInvoiceNum]) {
			
			mapInvNumToSAPInv.put(SAPInv.Name, SAPInv);
			setCountry.add(SAPInv.Billing_Country__c);
		}
		
		// Related: ZPayments
		Map<Id, Zuora__Payment__c> mapInvIdToPmt = new Map<Id, Zuora__Payment__c>();
		for (Zuora__Payment__c ZPmt :
			[SELECT Payment_Method__c, Zuora__EffectiveDate__c, Zuora__Invoice__c ,Zuora__SecondPaymentReferenceId__c
            FROM Zuora__Payment__c
            WHERE Zuora__Invoice__c IN :setInvoiceId]) {
			
			mapInvIdToPmt.put(ZPmt.Zuora__Invoice__c, ZPmt);
		}
			
		// Related: ISO Country
		Map<String, IATA_ISO_Country__c> mapCountryToIATACountry = new Map<String, IATA_ISO_Country__c>();
		for (IATA_ISO_Country__c isoCountry :
			[SELECT Name, ISO_Code__c
			FROM IATA_ISO_Country__c
			WHERE Name IN :setCountry]) {
			
			mapCountryToIATACountry.put(isoCountry.Name, isoCountry);
		}
		
		List<IEC_SAP_Invoice_Item__c> lstNewSAPInvoiceItem = new List<IEC_SAP_Invoice_Item__c>();
		Map<String, IEC_SAP_Invoice__c> mapSAPInvoice = new Map<String, IEC_SAP_Invoice__c>();
		
		String sDocType, sEmpResp, sOrderReason;
		
		// Create the SAP Invoice Item records
		for (Invoice_Item__c item : lstInvoicesToSAP) {
			Zuora__ZInvoice__c ZInv = (mapZInvoice.containsKey(item.Invoice__c)) ? mapZInvoice.get(item.Invoice__c) : null;
			Zuora__Subscription__c subscription = (mapZIdToSubscription.containsKey(item.Subscription_Number__c)) ? mapZIdToSubscription.get(item.Subscription_Number__c) : null;
			Zuora__Payment__c ZPmt = (ZInv != null && mapInvIdToPmt.containsKey(ZInv.Id)) ? mapInvIdToPmt.get(ZInv.Id) : null;

			IATA_ISO_Country__c country = null;

			IEC_SAP_Invoice_Item__c SAPItem = new IEC_SAP_Invoice_Item__c();
			
			sDocType = sEmpResp = sOrderReason = null;
			
			if (mapZProduct.containsKey(item.Product__c))
			{
				SAPItem.Material__c = mapZProduct.get(item.Product__c).SAPProductMaterialNo__c;
			
				if (mapSAPMaterialToProduct2.containsKey(SAPItem.Material__c))
				{
					Product2 prod = mapSAPMaterialToProduct2.get(SAPItem.Material__c);
					SAPItem.Use_Contract__c = prod.Use_Contract_when_ordered__c;
					SAPItem.Product__c = prod.Id;
					SAPItem.Profit_Center__c = prod.IEC_SAP_ProfitCenter__c;
					
					// Retrieve Product information that will be used later to update the SAP Invoice
					sDocType = prod.IEC_SAP_DocType__c;
					sEmpResp = prod.IEC_SAP_EmpResp__c;
					sOrderReason = prod.SAP_Contract_OrderReason__c;
				}
			}
			
			if (ZInv != null) {
				if (mapInvNumToSAPInv.containsKey(ZInv.Name)) {
					IEC_SAP_Invoice__c SAPInv = mapInvNumToSAPInv.get(ZInv.Name);
				
					if (mapCountryToIATACountry.containsKey(SAPInv.Billing_Country__c)) {
						country = mapCountryToIATACountry.get(SAPInv.Billing_Country__c);
						/* Commented by Samy (2016-03-30) Replaced by profit center from the product instead of the country object
						SAPItem.Profit_Center__c = country.Profit_Center__c;
						* /
					}
				}
			}

			if (subscription != null) {
				if (ZInv != null && !mapSAPInvoice.containsKey(ZInv.Name)) {
					// If ZPayment object is available correct Payment Method & Payment Date fields on parent SAP Invoice (Done on this level to give room for Zuora to create the Payment object before checking if exists)
					if (ZPmt != null) {
						if (ZPmt.Payment_Method__c.contains('Credit Card')) {
                            
                            String cardType = 'Visa';
                            if(ZPmt.Payment_Method__c.contains('Master'))
                                cardType = 'MasterCard';
                            if(ZPmt.Payment_Method__c.contains('Express') || ZPmt.Payment_Method__c.contains('Amex'))
                                cardType = 'American Express';
                                                            
							mapSAPInvoice.put(ZInv.Name
								, new IEC_SAP_Invoice__c (
									Zuora_Invoice_Number__c = ZInv.Name
									, Customer_PO__c = subscription.PurchaseOrder__c
									// Only pass date if payment method is Credit Card
									, Payment_Date__c = ZPmt.Zuora__EffectiveDate__c.date()
									, Pay_Method__c = 'Credit Card'
									, Billing_Country_ISO_Code__c = (country == null) ? null : country.ISO_Code__c                                    
									//set new fields: card type and reference number
									, Credit_Card_Type__c = cardType
									, Payment_Reference_ID__c = ZPmt.Zuora__SecondPaymentReferenceId__c
									, Subscription_Order_Id__c = subscription.OrderId__c
									// Use previously assigned values to update the SAP fields on the Invoice
									, Employee_Responsible__c = sEmpResp
									, Order_Reason__c = sOrderReason
									, Doc_Type__c = sDocType
								)
							);
						}
						else {
							mapSAPInvoice.put(ZInv.Name
								, new IEC_SAP_Invoice__c (
									Zuora_Invoice_Number__c = ZInv.Name
									, Customer_PO__c = subscription.PurchaseOrder__c
									, Pay_Method__c = ZPmt.Payment_Method__c
									, Billing_Country_ISO_Code__c = (country == null) ? null : country.ISO_Code__c
									, Subscription_Order_Id__c = subscription.OrderId__c
									// Use previously assigned values to update the SAP fields on the Invoice
									, Employee_Responsible__c = sEmpResp
									, Order_Reason__c = sOrderReason
									, Doc_Type__c = sDocType
								)
							);
						}
					}
					else {
						mapSAPInvoice.put(ZInv.Name
							, new IEC_SAP_Invoice__c (
								Zuora_Invoice_Number__c = ZInv.Name
								, Customer_PO__c = subscription.PurchaseOrder__c
								, Billing_Country_ISO_Code__c = (country == null) ? null : country.ISO_Code__c
								, Subscription_Order_Id__c = subscription.OrderId__c
								// Use previously assigned values to update the SAP fields on the Invoice
								, Employee_Responsible__c = sEmpResp
								, Order_Reason__c = sOrderReason
								, Doc_Type__c = sDocType
							)
						);
					}
				}
			}

			SAPItem.Date_From__c = item.Service_Start_Date__c;
			SAPItem.Date_To__c = item.Service_End_Date__c;
			SAPItem.IEC_SAP_Invoice__r = new IEC_SAP_Invoice__c (Zuora_Invoice_Number__c = item.Invoice_Number__c);
			SAPItem.Quantity__c = item.Quantity__c;
			SAPItem.Unit_Price__c = item.Unit_Price__c;
			SAPItem.Charge_Amount__c = item.Charge_Amount__c;
			SAPItem.Status__c = IECConstants.IECSAPInvoice_Status_New;
			SAPItem.Status_Date__c = DateTime.now();
			SAPItem.Name = item.Name;			
			
			lstNewSAPInvoiceItem.add(SAPItem);			
		}
		
		// Insert new SAP Invoice Items
		if (!lstNewSAPInvoiceItem.isEmpty()) {
			insert lstNewSAPInvoiceItem;
		}
		
		// Update fields on parent SAP Invoice object
		if (!mapSAPInvoice.isEmpty()) {
			upsert mapSAPInvoice.values() Zuora_Invoice_Number__c;
		}
	}
	*/
}
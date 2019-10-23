/**  
  * Description: Trigger Handler for the Zuora Invoice object
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
public with sharing class trgHndlrIECInvoice {
	public static void OnAfterInsert(List<Zuora__ZInvoice__c> newRecords, Map<Id, Zuora__ZInvoice__c> newRecordsMap) {
		String sInvoiceZIds = '';
		Map<String, String> mapInvoiceZIdToNumber = new Map<String, String>(); 
		Set<String> setNonZeroInvoiceNumber = new Set<String>();
		Set<String> setNonZeroInvoiceId = new Set<String>();
		List<Zuora__ZInvoice__c> lstNonZeroInvoices = new List<Zuora__ZInvoice__c>();

		for (Zuora__ZInvoice__c invoice : newRecords) {
			//*** reset variables to download items for one invoice at a time
			//sInvoiceZIds = '';
			//mapInvoiceZIdToNumber.clear();
			//setNonZeroInvoiceId.clear();
			
			sInvoiceZIds += ((sInvoiceZIds == '') ? '\'' : ' OR InvoiceId = \'') + invoice.Zuora__Zuora_Id__c + '\'';
			mapInvoiceZIdToNumber.put(invoice.Zuora__Zuora_Id__c, invoice.Name);
			
			// Filter out invoice and invoice items with zero amount
			if (invoice.Zuora__TotalAmount__c > 0) {
				setNonZeroInvoiceNumber.add(invoice.Name);
				setNonZeroInvoiceId.add(invoice.Zuora__External_Id__c);
				lstNonZeroInvoices.add(invoice);
				//DownloadRelatedInvoiceItems(sInvoiceZIds, mapInvoiceZIdToNumber, setNonZeroInvoiceId);
			}
		}

		if (lstNonZeroInvoices.size() > 0)
			CreateSAPInvoices(setNonZeroInvoiceNumber, lstNonZeroInvoices);

		DownloadRelatedInvoiceItems(sInvoiceZIds, mapInvoiceZIdToNumber, setNonZeroInvoiceId);
	}
	
	/**
	 * Create SAP Invoice records for all new invoices that has not been created before
	 * @ param setNonZeroInvoiceNumber Set of Zuora of Invoice Numbers
	 * @ param ZInvoices Zuora Invoice Records
 	 **/
 	 private static void CreateSAPInvoices(Set<String> setNonZeroInvoiceNumber, List<Zuora__ZInvoice__c> ZInvoices) {
		Set<String> setSAPInvoiceNumber = new Set<String>();
		
		// Determine which Invoices has been already created in SAP Invoice object
		for (IEC_SAP_Invoice__c SAPInv : [SELECT Zuora_Invoice_Number__c FROM IEC_SAP_Invoice__c WHERE Zuora_Invoice_Number__c IN :setNonZeroInvoiceNumber]) {
			setSAPInvoiceNumber.add(SAPInv.Zuora_Invoice_Number__c);
		}
		
		List<Zuora__ZInvoice__c> lstInvoicesToSAP = new List<Zuora__ZInvoice__c>();
		//Set<Id> setBillingAccountId = new Set<Id>();
		//Set<String> setInvoiceZId = new Set<String>();
		
		// Filter out Invoices that has been already created in SAP Invoice object
		for (Zuora__ZInvoice__c ZInv : ZInvoices) {
			if (!setSAPInvoiceNumber.contains(ZInv.Name)) {
				lstInvoicesToSAP.add(ZInv);
		//		setBillingAccountId.add(ZInv.Zuora__BillingAccount__c);
		//		setInvoiceZId.add(ZInv.Zuora__External_Id__c);
			}
		}
		
		// Get related objects that will help building the SAP Invoice record (i.e. Billing Account, Subscription History)
		
		// Related: Billing Account
		//Map<Id, Zuora__CustomerAccount__c> mapBillingAccount = new Map<Id, Zuora__CustomerAccount__c>(
		//	[SELECT Id, Contact__r.Name, Zuora__External_Id__c, Zuora__DefaultPaymentMethod__c, SAPBillTo__c
		//		, Zuora__BillToCity__c, Zuora__BillToCountry__c, Zuora__BillToAddress1__c, Zuora__BillToState__c, Zuora__BillToPostalCode__c
		//		, Tax1ID__c
		//		, Contact__r.BillTo_Location__r.Street__c, Contact__r.BillTo_Location__r.City__c
		//		, Contact__r.BillTo_Location__r.ZipCode__c, Contact__r.BillTo_Location__r.ISO_State_Code__c
		//		, Contact__r.BillTo_Location__r.ISO_Country_Code__c, Contact__r.BillTo_Location__r.Country__c
		//		, Contact__r.BillTo_Location__r.SAP_Id__c
		//	FROM Zuora__CustomerAccount__c
		//	WHERE Id IN :setBillingAccountId]);
			
		// Related: Subscription History
		//Map<String, IEC_Subscription_History__c> mapInvZIdToSubHist = new Map<String, IEC_Subscription_History__c>();
		//for (IEC_Subscription_History__c subHist :
		//	[SELECT Invoice_Zuora_ID__c, Billing_City__c, Billing_Country__c, Billing_State__c, Billing_Street__c, Billing_Zip__c
		//		, VAT_Number__c, Selected_Payment_Method__c
		//	FROM IEC_Subscription_History__c
		//	WHERE Invoice_Zuora_ID__c IN :setInvoiceZId]) {
			
		//	mapInvZIdToSubHist.put(subHist.Invoice_Zuora_ID__c, subHist);
		//}
		
		// Create the SAP Invoice records
		List<IEC_SAP_Invoice__c> lstNewSAPInvoice = new List<IEC_SAP_Invoice__c>();

		for (Zuora__ZInvoice__c ZInv : lstInvoicesToSAP) {
			IEC_SAP_Invoice__c SAPInv = new IEC_SAP_Invoice__c();
			
			// Prep Data for processing
			//Zuora__CustomerAccount__c ZAcc = (mapBillingAccount.containsKey(ZInv.Zuora__BillingAccount__c)) ? mapBillingAccount.get(ZInv.Zuora__BillingAccount__c) : null;
			//IEC_Subscription_History__c SubHist = (mapInvZIdToSubHist.containsKey(ZInv.Zuora__External_Id__c)) ? mapInvZIdToSubHist.get(ZInv.Zuora__External_Id__c) : null;
			
			//if (ZAcc != null) {
			//	SAPInv.Billing_Name__c = ZAcc.Contact__r.Name;
			//	SAPInv.Zuora_Billing_Account_ID__c = ZAcc.Zuora__External_Id__c;
			//	SAPInv.Bill_To__c = String.isBlank(ZAcc.Contact__r.BillTo_Location__r.SAP_Id__c) ? null : ZAcc.Contact__r.BillTo_Location__r.SAP_Id__c;
			//}

			// Try to determine Payment Method, First using the Payment object if available (will be done on the invoice item level to give room for Zuora to create Payment record first)
			// If not, then try to load it up from the Subscription History
			//if (SubHist != null) {
			//	SAPInv.Pay_Method__c = SubHist.Selected_Payment_Method__c;
			//}
			// If still not, then try to load it up from the Billing Account
			//else if (ZAcc != null) {
			//	// Also replace the values to match the other previous two approaches
			//	SAPInv.Pay_Method__c = ZAcc.Zuora__DefaultPaymentMethod__c.replace('Other', 'ICH').replace('CreditCard', 'Credit Card');
			//}
				
			// Try to get the billing details from the Billing Account
			//if (ZAcc != null) {
			//	SAPInv.Billing_City__c = ZAcc.Contact__r.BillTo_Location__r.City__c;
			//	SAPInv.Billing_Country__c = ZAcc.Contact__r.BillTo_Location__r.ISO_Country_Code__c;
			//	SAPInv.Billing_State__c = ZAcc.Contact__r.BillTo_Location__r.ISO_State_Code__c;
			//	SAPInv.Billing_Street__c = ZAcc.Contact__r.BillTo_Location__r.Street__c;
			//	SAPInv.Billing_Zip__c = ZAcc.Contact__r.BillTo_Location__r.ZipCode__c;

			//	IECVATUtil.VATConfiguration vatConfig = IECVATUtil.GetVATConfiguration(ZAcc.Contact__r.BillTo_Location__r.Country__c);

			//	// Only provide VAT Number for VAT Countries that require validation for their VAT Number
			//	if (vatConfig != null && vatConfig.VATValidationRequired)
			//		SAPInv.VAT_Number__c = ZAcc.Tax1ID__c;
			//}

			SAPInv.PO_Date__c = DateTime.now().date();
			SAPInv.Status__c = IECConstants.IECSAPInvoice_Status_New;
			SAPInv.Status_Date__c = DateTime.now();
			SAPInv.Total_Amount__c = ZInv.Zuora__TotalAmount__c;
			SAPInv.Zuora_Invoice_Number__c = ZInv.Name;
			SAPInv.Zuora_Invoice_ID__c = ZInv.Zuora__External_Id__c;
			SAPInv.Name = ZInv.Name;
			SAPInv.Account__c = ZInv.Zuora__Account__c;
			SAPInv.Billing_Account__c = ZInv.Zuora__BillingAccount__c;
			
			// if currently running a test method, flag the SAP Invoice
			if (Test.isRunningTest())
				SAPInv.Text_Print__c = IECSAPManager_tst.TEST_FLAG_SUCCESS;
			
			lstNewSAPInvoice.add(SAPInv);
		}
		
		if (!lstNewSAPInvoice.isEmpty()) {
			insert lstNewSAPInvoice;
		}
	}


	/**
	 * Retrieves a list of Invoice Item corresponding to the passed invoice ids
	 * @ param sInvoiceZIds a concatenated list of Invoice Zuora Ids ready to be used in a ZOQL query
 	 **/
	@future (callout=true)
	private static void DownloadRelatedInvoiceItems(String sInvoiceZIds, Map<String, String> mapInvoiceZIdToNumber, Set<String> setNonZeroInvoiceId) {
		if (String.isNotEmpty(sInvoiceZIds)) {
			// Retrieve related Invoice Items from Zuora
			List<Zuora.zObject> lstZInvoiceItems = new List<Zuora.zObject>();
			if (Test.isRunningTest()) {
				if (IECTestUtil.InvoiceTestOrigin == 'trgHndlrIECInvoice_tst')
					lstZInvoiceItems = trgHndlrIECInvoice_tst.getSampleInvoiceItems();
				else if (IECTestUtil.InvoiceTestOrigin == 'vfIECHistInactiveSubscriptions_tst')
					lstZInvoiceItems = vfIECHistInactiveSubscriptions_tst.getSampleInvoiceItems();
				else if (IECTestUtil.InvoiceTestOrigin == 'vfIECHistActiveSubscriptions_tst')
					lstZInvoiceItems = vfIECHistActiveSubscriptions_tst.getSampleInvoiceItems();
				else if (IECTestUtil.InvoiceTestOrigin == 'IECSAPManager_tst')
					lstZInvoiceItems = IECSAPManager_tst.getSampleInvoiceItems();
			}
			else {
				lstZInvoiceItems = IECZuoraHelper.queryApiCall(
					'select Id, ChargeAmount, ChargeDate, ChargeName, InvoiceId, ProductId, Quantity, SubscriptionId' +
					'		, RatePlanChargeId, TaxAmount, UnitPrice, SubscriptionNumber' +
					'		, ServiceStartDate, ServiceEndDate' +
					'	from InvoiceItem ' +
					'	where InvoiceId = ' + sInvoiceZIds + '');
			}
			
			List<Invoice_Item__c> lstInvoiceItemsToInsert = new List<Invoice_Item__c>();
			Map<String, IEC_SAP_Invoice__c> mapInvoiceItemCounter = new Map<String, IEC_SAP_Invoice__c>();
			
			// Loop over the result and replicate them in SFDC
			for (Zuora.zObject zInvoiceItem : lstZInvoiceItems) {
				String sInvoiceId = (String)zInvoiceItem.getValue('InvoiceId');
				lstInvoiceItemsToInsert.add(new Invoice_Item__c(
					Zuora_ID__c = (String)zInvoiceItem.getValue('Id')
					, Charge_Amount__c = (Decimal)zInvoiceItem.getValue('ChargeAmount')
					, Charge_Date__c = (DateTime)zInvoiceItem.getValue('ChargeDate')
					, Charge_Name__c = (String)zInvoiceItem.getValue('ChargeName')
					, Invoice__r = new Zuora__ZInvoice__c (Zuora__External_Id__c = sInvoiceId)
					, New_Product__r = new Product2 (zqu__ZuoraId__c = (String)zInvoiceItem.getValue('ProductId'))
					, Subscription_Number__c = (String)zInvoiceItem.getValue('SubscriptionNumber')
					//, Subscription__r = new Zuora__Subscription__c (Zuora__External_Id__c = (String)zInvoiceItem.getValue('SubscriptionId'))
					//, Subscription_Product_Charge__r = new Zuora__SubscriptionProductCharge__c (Zuora__External_Id__c = (String)zInvoiceItem.getValue('RatePlanChargeId'))
					, Subscription_Zuora_ID__c = (String)zInvoiceItem.getValue('SubscriptionId')
					, Subscription_Product_Charge_Zuora_ID__c = (String)zInvoiceItem.getValue('RatePlanChargeId')
					, Quantity__c = (Decimal)zInvoiceItem.getValue('Quantity')
					, Service_Start_Date__c = ((DateTime)zInvoiceItem.getValue('ServiceStartDate')).date()
					, Service_End_Date__c = ((DateTime)zInvoiceItem.getValue('ServiceEndDate')).date()
					, Tax_Amount__c = (Decimal)zInvoiceItem.getValue('TaxAmount')
					, Unit_Price__c = (Decimal)zInvoiceItem.getValue('UnitPrice')
				));

				// Avoid updating item count for invoices with total amount = zero
				if (setNonZeroInvoiceId.contains(sInvoiceId)) {
					if (mapInvoiceItemCounter.containsKey(sInvoiceId)) {
						mapInvoiceItemCounter.get(sInvoiceId).Number_of_Zuora_Items__c += 1;
					}
					else {
						mapInvoiceItemCounter.put(sInvoiceId
							, new IEC_SAP_Invoice__c (
								Zuora_Invoice_Number__c = mapInvoiceZIdToNumber.get(sInvoiceId)
								, Name = mapInvoiceZIdToNumber.get(sInvoiceId)   //*** (Thai) add to fix test class
								, Number_of_Zuora_Items__c = 1
							)
						);
					}
				}
			}

			
			if (!lstInvoiceItemsToInsert.isEmpty()){
				try{
					upsert lstInvoiceItemsToInsert Zuora_ID__c;
				}catch(Exception ex){
					IECErrorLogger.logApexException('trgHndlrIECInvoice/DownloadRelatedInvoiceItems'
					                              , 'Cannot upsert Invoice Items\n' + String.join(lstInvoiceItemsToInsert, '\n')
					                              , ex.getMessage(), ex.getStackTraceString(), false);
				}
			}

			if (!mapInvoiceItemCounter.isEmpty()){
				try{
					upsert mapInvoiceItemCounter.values() Zuora_Invoice_Number__c;
				}catch(Exception ex){
					IECErrorLogger.logApexException('trgHndlrIECInvoice/DownloadRelatedInvoiceItems'
					                              , 'Cannot upsert counters for SAP Invoice\n' + String.join(mapInvoiceItemCounter.values(), '\n')
					                              , ex.getMessage(), ex.getStackTraceString(), false);
				}
			}
				
		}
	}
}
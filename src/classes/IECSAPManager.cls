/**
 * Class that encapsulate all methods related to SAP WebServices,
 * validating the data to be sent to SAP, sending of invoice items to SAP, 
 * flaging them as paid, send the payments to Zuora, etc.
 * 
 */
public with sharing class IECSAPManager {

	/**
	 * NOTE: called by scheduled process.
	 * Takes all SAP Invoices and SAP Invoice Items that are New and validates them against a set of business rules.
	 * Then send to SAP all the valid ones
	 * If errors are found, the status will be updated to 'Validation Error' 
	 * and the field Error_Message__c will be populated with the specific error (both for the Invoices and Invoice Items).
	 */
	public static void sendInvoicesToSAP(List<IEC_SAP_Invoice__c> lstSAPInvoicesToValidate) {

		// List of valid SAP Invoices to send to SAP
		List<IEC_SAP_Invoice__c> lstSAPInvoicesToSend = new List<IEC_SAP_Invoice__c>();
		List<String> lstSAPInvoicesNumberToSend = new List<String>();
		
		// List of SAP Invoice to update the status
		List<IEC_SAP_Invoice__c> lstSAPInvoiceToUpdate = new List<IEC_SAP_Invoice__c>();
		
		// List of SAP Invoice Items to update the status
		List<IEC_SAP_Invoice_Item__c> lstSAPInvoiceItemsToUpdate = new List<IEC_SAP_Invoice_Item__c>();
	
		// list of response objects
		List<iataComXiSalesforceOtcWid5600Sales3.Response_element> lstResponse = null;
	
		// List to compile all error message received regarding a submitted invoice
		List<String> lstErrorMessage = new List<String>();
		
		// List to compile all warning message received regarding a submitted invoice
		List<String> lstWarningMessage = new List<String>();
	
		try {
			
			if (lstSAPInvoicesToValidate == null || lstSAPInvoicesToValidate.isEmpty())
				return;

			///////////////////////////////
			// TEST - bypass validation
			//lstSAPInvoicesToSend = lstSAPInvoicesToValidate;
			
			
			//////////////////////////
			// Validate SAP Invoices
			
			for (IEC_SAP_Invoice__c oSAPInvoiceToValidate : lstSAPInvoicesToValidate) {
				
				// validate SAP Invoice and its SAP Invoice Items
				IEC_SAP_Invoice__c oValidatedSAPInvoice = validateInvoiceAndChildItems(oSAPInvoiceToValidate);

				// if no validation errors, add to the list of SAP Invoices to Send
				if (oValidatedSAPInvoice.Status__c != IECConstants.IECSAPInvoice_Status_ValidationError && String.isBlank(oValidatedSAPInvoice.Error_Message__c)) {
					lstSAPInvoicesToSend.add(oValidatedSAPInvoice);
					lstSAPInvoicesNumberToSend.add(oValidatedSAPInvoice.Name);
				}
				// else, add to the list of SAP Invoice to update (status have been updated to Validation Error and contains appropriate error message)
				else {
					lstSAPInvoiceToUpdate.add(oValidatedSAPInvoice);
					
					// add related SAP Invoice Items to the list to update
					for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oValidatedSAPInvoice.IEC_SAP_Invoice_Items__r)
						lstSAPInvoiceItemsToUpdate.add(oSAPInvoiceItem);
				}
			}
			
			//////////////////////////////////
			// if there are invoices to send
			
			if (!lstSAPInvoicesToSend.isEmpty()) {

				///////////////////////////////////////////
				// Build list of contract element to send
				
				List<iataComXiSalesforceOtcWid5600Sales3.Contract_element> lstContractElement = new List<iataComXiSalesforceOtcWid5600Sales3.Contract_element>();
				
				for (IEC_SAP_Invoice__c oSAPInvoiceToSend : lstSAPInvoicesToSend) {

					iataComXiSalesforceOtcWid5600Sales3.Contract_element oContractElement = new iataComXiSalesforceOtcWid5600Sales3.Contract_element();
					oContractElement.Header = IECSAPHelper.createHeaderForInvoiceSending(oSAPInvoiceToSend);
					oContractElement.Item = IECSAPHelper.createItemElementsForInvoiceSending(oSAPInvoiceToSend);
					oContractElement.Address = IECSAPHelper.createAddressElementForInvoiceSending(oSAPInvoiceToSend);
					
					lstContractElement.add(oContractElement);
				}

				/////////////////////////////
				// Send SAP Invoices to SAP
				
				// instantiate the web service proxy
				iataComXiSalesforceOtcWid5600Sales3.HTTPS_Port ws = new iataComXiSalesforceOtcWid5600Sales3.HTTPS_Port();
				
				// set the credentials
				Blob headerValue = Blob.valueOf(IEC_SAP_Settings__c.getOrgDefaults().Web_Service_Username__c + ':' + IECUtil.DecryptParameter(IEC_SAP_Settings__c.getOrgDefaults().Web_Service_Password__c));
				String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);

				if (ws.inputHttpHeaders_x == null)
					ws.inputHttpHeaders_x = new Map<String,String>();
				ws.inputHttpHeaders_x.put('Authorization', authorizationHeader);
				
				// set the timeout to maximum value (60 seconds)
				ws.timeout_x = 60000;
				
				// if not in test class
				if(!Test.isRunningTest()) {
					
					try {
						
						// calculate execution time of seb service call
						Datetime dtBefore = Datetime.now();
						
						// Call SAP web service
						lstResponse = ws.SI_SalesForce_SalesContract_OB(lstContractElement);
						
						long lElapsedMiliseconds = DateTime.Now().getTime() - dtBefore.getTime();

						// log execution time
						string sMessage = 'Callout elapsed: ' + lElapsedMiliseconds + 'ms \r\nNumber of SAP Invoices sent: ' + lstContractElement.size();
						string sExtraInfo = 'SAP Invoices sent: ' + String.join(lstSAPInvoicesNumberToSend, ',');
						IECErrorLogger.logInfo(null, 'SAP Web Service callout log', sMessage, sExtraInfo, 'IECSAPManager.sendInvoicesToSAP()');
					}
					catch (Exception ex) {
						system.debug('IECSAPManager.sendInvoicesToSAP() - SAP Web Service callout error: ' + ex.getMessage());
						IECErrorLogger.logError(null, 'SAP Web Service callout error', ex.getMessage(), null, 'IECSAPManager.sendInvoicesToSAP()', ex.getStacktraceString());
						
						// if calloutexception or timeout, flag all invoices with Error Message and status SAP Error
						for (IEC_SAP_Invoice__c oSAPInvoiceToSend : lstSAPInvoicesToSend) {
							oSAPInvoiceToSend.Error_Message__c = 'SAP Web Service callout error: ' + ex.getMessage();
						}
						
						update lstSAPInvoicesToSend;
						
						// make sure to update the invoices that are in 'Validation Error' status
						update lstSAPInvoiceToUpdate;
						
						return;
					}
				}
				// if in test class
				else {
					
					// return fake data for test class
					lstResponse = new List<iataComXiSalesforceOtcWid5600Sales3.Response_element>();
					
					for (IEC_SAP_Invoice__c oSAPInvoiceToSend : lstSAPInvoicesToSend) {
						iataComXiSalesforceOtcWid5600Sales3.Return_element response = new iataComXiSalesforceOtcWid5600Sales3.Return_element();
						
						// default behavior or simulating success
						if (oSAPInvoiceToSend.Text_Print__c == '' || oSAPInvoiceToSend.Text_Print__c == IECSAPManager_tst.TEST_FLAG_SUCCESS) {
							
							response.Type_x = IECSAPHelper.RESPONSE_TYPE_SUCCESS;
							response.Message = IECSAPHelper.RESPONSE_MESSAGE_CONTRACT_PREFIX + IECSAPManager_tst.INVOICE_SUCCESS_CONTRACT_NO + IECSAPHelper.RESPONSE_MESSAGE_CONTRACT_SUFFIX;
						}
						// simulating error
						else {
							response.Type_x = IECSAPHelper.RESPONSE_TYPE_ERROR;
							response.Message = IECSAPManager_tst.INVOICE_ERROR_MSG;
						}
						
						iataComXiSalesforceOtcWid5600Sales3.Response_element oResponseElement = new iataComXiSalesforceOtcWid5600Sales3.Response_element();
						
						// add warning response for code coverage
						iataComXiSalesforceOtcWid5600Sales3.Return_element warningResponse = new iataComXiSalesforceOtcWid5600Sales3.Return_element();
						warningResponse.Type_x = IECSAPHelper.RESPONSE_TYPE_WARNING;
						warningResponse.Message = IECSAPManager_tst.INVOICE_WARNING_MSG;
						
						// add Bill To number on success
						if (oSAPInvoiceToSend.Text_Print__c == '' || oSAPInvoiceToSend.Text_Print__c == IECSAPManager_tst.TEST_FLAG_SUCCESS) {
							iataComXiSalesforceOtcWid5600Sales3.Return_element billToResponse = new iataComXiSalesforceOtcWid5600Sales3.Return_element();
							billToResponse.Type_x = IECSAPHelper.RESPONSE_TYPE_SUCCESS;
							billToResponse.Message = IECSAPHelper.RESPONSE_MESSAGE_BILLTO_PREFIX + IECSAPManager_tst.INVOICE_SUCCESS_BILLTO_NO + IECSAPHelper.RESPONSE_MESSAGE_BILLTO_SUFFIX;
							
							oResponseElement.Return_x = new List<iataComXiSalesforceOtcWid5600Sales3.Return_element>{ response, warningResponse, billToResponse };
						}
						else {
							oResponseElement.Return_x = new List<iataComXiSalesforceOtcWid5600Sales3.Return_element>{ response, warningResponse };
						}
						
						lstResponse.add(oResponseElement);
					}
				}
				
				
				///////////////////////
				// Parse SAP response
				
				// parse response element (one per invoice sent)
				Integer i = 0;
				for (iataComXiSalesforceOtcWid5600Sales3.Response_element response : lstResponse) {
				
					// get the related SAP Invoice related to the response we receive (index should match)
					IEC_SAP_Invoice__c oCurrentSAPInvoice = lstSAPInvoicesToSend.get(i);
				
					// parse return element - will be 1 success or one/multiple error(s)
					for (iataComXiSalesforceOtcWid5600Sales3.Return_element itemResponse : response.Return_x) {
						
						// DEBUG
						system.debug('ALEX - itemResponse.Type_x: ' + itemResponse.Type_x);
						system.debug('ALEX - itemResponse.Message: ' + itemResponse.Message);
						system.debug('ALEX - itemResponse.Parameter: ' + itemResponse.Parameter);
						system.debug('ALEX - itemResponse.MsgId: ' + itemResponse.MsgId);
						
						// check if success or info(should only receive one success)
						if (itemResponse.Type_x == IECSAPHelper.RESPONSE_TYPE_SUCCESS 
							|| itemResponse.Type_x == IECSAPHelper.RESPONSE_TYPE_INFO) {

							if (String.isBlank(itemResponse.Message)) {
								lstErrorMessage.add('Field Message is missing');
							}
							else {

								// look for the message containing the Contract Number then store SAP contract number
								if (itemResponse.Message.startsWithIgnoreCase(IECSAPHelper.RESPONSE_MESSAGE_CONTRACT_PREFIX) && itemResponse.Message.endsWithIgnoreCase(IECSAPHelper.RESPONSE_MESSAGE_CONTRACT_SUFFIX)) {
								
									// extract Contract Number
									String[] arrSplit = itemResponse.Message.split(' ');
									oCurrentSAPInvoice.SAP_Contract_Number__c = arrSplit[2];
								}
								
								// look for the message containing the BillTo Number then store SAP Bill To number
								if (itemResponse.Message.startsWithIgnoreCase(IECSAPHelper.RESPONSE_MESSAGE_BILLTO_PREFIX) && itemResponse.Message.endsWithIgnoreCase(IECSAPHelper.RESPONSE_MESSAGE_BILLTO_SUFFIX)) {
								
									String sBillToMessage = itemResponse.Message.replace(':', ' ');
									
									// extract Bill To Number
									String[] arrSplit = sBillToMessage.split(' ');
									oCurrentSAPInvoice.SAP_Bill_To_Number__c = arrSplit[2];
								}
							}
						}
						// Warning
						else if (itemResponse.Type_x == IECSAPHelper.RESPONSE_TYPE_WARNING) {
							if (String.isNotBlank(itemResponse.Message))
								lstWarningMessage.add(itemResponse.Message.length() > 255 ? itemResponse.Message.substring(0, 255) : itemResponse.Message);
						}
						// Error or Abort
						else {
							// build list of error messages
							lstErrorMessage.add(itemResponse.Message);
						}
					}
					
					// if warning were found (regardless of errors or success)
					if (!lstWarningMessage.isEmpty()) {
						// concatenate error messages
						oCurrentSAPInvoice.Warning_Message__c = String.join(lstWarningMessage, '\r\n');
					}
					
					// if there was no errors
					if (lstErrorMessage.isEmpty()) {
						
						// update status of the SAP Invoice to 'Sent to SAP'
						oCurrentSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_SentToSAP;
						oCurrentSAPInvoice.Status_Date__c = Datetime.now();
						lstSAPInvoiceToUpdate.add(oCurrentSAPInvoice);
						
						// update status of the SAP Invoice Items to 'Sent to SAP'
						for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oCurrentSAPInvoice.IEC_SAP_Invoice_Items__r) {
							oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_SentToSAP;
							oSAPInvoiceItem.Status_Date__c = Datetime.now();
							lstSAPInvoiceItemsToUpdate.add(oSAPInvoiceItem);
						}
					}
					// one or more errors
					else {
						
						// concatenate error messages
						oCurrentSAPInvoice.Error_Message__c = String.join(lstErrorMessage, '\r\n');
						
						// update status of the SAP Invoice to 'SAP Error'
						oCurrentSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_SAPError;
						oCurrentSAPInvoice.Status_Date__c = Datetime.now();
						lstSAPInvoiceToUpdate.add(oCurrentSAPInvoice);
						
					}
				
					i++;
					lstErrorMessage.clear();
					lstWarningMessage.clear();
				}
			}
			
			system.debug('ALEX - should update ' + lstSAPInvoiceToUpdate.size() + ' invoices');
			
			// update SAP Invoices
			update lstSAPInvoiceToUpdate;
			
			// update SAP Invoice Items
			update lstSAPInvoiceItemsToUpdate;
			
			return;
		}
		catch (Exception ex) {
			system.debug('ALEX - Exception in IECSAPManager.sendInvoicesToSAP(): ' + ex.getMessage() + '. ' + ex.getStacktraceString());
			IECErrorLogger.logError(null, 'Global exception', ex.getMessage(), null, 'IECSAPManager.sendInvoicesToSAP()', ex.getStacktraceString());
		}
	}
	
	/**
	 * Returns the list of SAP Invoices having the New status and Ready to sent to SAP
	 */
	public static List<IEC_SAP_Invoice__c> getNewSAPInvoices() {
		
		if (!Test.isRunningTest()) {
			return [SELECT Billing_City__c, Billing_Country__c, Billing_Name__c, Billing_State__c, Billing_Street__c, Bill_To__c
					, Billing_Zip__c, Contract_Start__c, Contract_End__c, Contract_Number__c, CurrencyIsoCode, Customer_PO__c, Dist_Chan__c
					, Division__c, Doc_Currency__c, Doc_Type__c, Employee_Responsible__c, Error_Message__c, Order_Reason__c
					, PO_Date__c, Pay_Method__c, Pay_Terms__c, Payment_Date__c, Id, SAP_Bill_To_Number__c, Ready_for_SAP__c
					, SAP_Contract_Number__c, SAP_Invoice_Clearance_Date__c, SAP_Invoice_Number__c, Sales_Office__c, Payment_Method_Code__c
					, Sales_Org__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c, Shipping_State__c, Total_Positive_Quantity__c
					, Shipping_Street__c, Shipping_Zip__c, Status__c, Status_Date__c, Text_Print__c, VAT_number__c, Total_Quantity__c
					, Name, Zuora_Invoice_Number__c, Billing_Country_ISO_Code__c, Warning_Message__c, Zuora_Billing_Account_ID__c,
					(SELECT Date_From__c,Date_To__c,Error_Message__c,IEC_SAP_Invoice__c,Material__c,Material_Description__c, Charge_Amount__c
						,Profit_Center__c,Quantity__c,Status__c,Status_Date__c,Unit_Price__c,Unit_Price_Currency__c, Name, Adjusted_Charge_Amount__c 
					 FROM IEC_SAP_Invoice_Items__r)
					FROM IEC_SAP_Invoice__c
					WHERE Status__c = :IECConstants.IECSAPInvoice_Status_New
						AND Ready_for_SAP__c = true
					ORDER by CreatedDate];
		}
		// if in test, will filter the SAP Invoice having the test flags (put in the Text Print field)
		else {
			
			return [SELECT Billing_City__c, Billing_Country__c, Billing_Name__c, Billing_State__c, Billing_Street__c, Bill_To__c
					, Billing_Zip__c, Contract_Start__c, Contract_End__c, Contract_Number__c, CurrencyIsoCode, Customer_PO__c, Dist_Chan__c
					, Division__c, Doc_Currency__c, Doc_Type__c, Employee_Responsible__c, Error_Message__c, Order_Reason__c
					, PO_Date__c, Pay_Method__c, Pay_Terms__c, Payment_Date__c, Id, SAP_Bill_To_Number__c, Ready_for_SAP__c
					, SAP_Contract_Number__c, SAP_Invoice_Clearance_Date__c, SAP_Invoice_Number__c, Sales_Office__c, Payment_Method_Code__c
					, Sales_Org__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c, Shipping_State__c, Total_Positive_Quantity__c
					, Shipping_Street__c, Shipping_Zip__c, Status__c, Status_Date__c, Text_Print__c, VAT_number__c, Total_Quantity__c
					, Name, Zuora_Invoice_Number__c, Billing_Country_ISO_Code__c, Warning_Message__c, Zuora_Billing_Account_ID__c,
					(SELECT Date_From__c,Date_To__c,Error_Message__c,IEC_SAP_Invoice__c,Material__c,Material_Description__c, Charge_Amount__c
						,Profit_Center__c,Quantity__c,Status__c,Status_Date__c,Unit_Price__c,Unit_Price_Currency__c, Name, Adjusted_Charge_Amount__c 
					 FROM IEC_SAP_Invoice_Items__r)
					FROM IEC_SAP_Invoice__c
					WHERE Status__c = :IECConstants.IECSAPInvoice_Status_New
						AND Ready_for_SAP__c = true
						AND (Text_Print__c = :IECSAPManager_tst.TEST_FLAG_SUCCESS or Text_Print__c = :IECSAPManager_tst.TEST_FLAG_ERROR)
					ORDER by CreatedDate];
		}
	}
	
	/**
	 * Validates a single SAP Invoice and its Invoice Items
	 * If invalid, the invoice status will be changed to 'Validation Error'
	 */
	public static IEC_SAP_Invoice__c validateInvoiceAndChildItems(IEC_SAP_Invoice__c oSAPInvoice) {
		
		// concatenate error messages together
		List<String> lstErrorString = new List<String>();
		
		///////////////////////////
		// SAP INVOICE VALIDATION
		
		// validate that all mandatory fields are filled before sending
		if (String.isBlank(oSAPInvoice.Doc_Type__c)) lstErrorString.add('The field Doc Type is missing');
		if (String.isBlank(oSAPInvoice.Sales_Org__c)) lstErrorString.add('The field Sales Org is missing');
		if (String.isBlank(oSAPInvoice.Dist_Chan__c)) lstErrorString.add('The field Distribution Channel is missing');
		if (String.isBlank(oSAPInvoice.Division__c)) lstErrorString.add('The field Division is missing');
		if (String.isBlank(oSAPInvoice.Sales_Office__c)) lstErrorString.add('The field Sales Office is missing');
		if (String.isBlank(oSAPInvoice.Employee_Responsible__c)) lstErrorString.add('The field Employee Responsible is missing');
		if (String.isBlank(oSAPInvoice.Zuora_Invoice_Number__c)) lstErrorString.add('The field Zuora Invoice Number is missing');
		if (String.isBlank(oSAPInvoice.Name)) lstErrorString.add('The field Name is missing');
		if (String.isBlank(oSAPInvoice.Order_Reason__c)) lstErrorString.add('The field Order Reason is missing');
		if (oSAPInvoice.Contract_Start__c == null) lstErrorString.add('The field Contract Start is missing');
		if (oSAPInvoice.Contract_End__c == null) lstErrorString.add('The field Contract End is missing');
		if (String.isBlank(oSAPInvoice.Pay_Method__c)) lstErrorString.add('The field Payment Method is missing');
		if (String.isBlank(oSAPInvoice.Pay_Terms__c)) lstErrorString.add('The field Payment Terms is missing');
		if (String.isBlank(oSAPInvoice.Billing_Country__c)) lstErrorString.add('The field Billing Country is missing');
		if (String.isBlank(oSAPInvoice.Billing_Name__c)) lstErrorString.add('The field Billing Name is missing');
		if (oSAPInvoice.Payment_Method_Code__c == IECSAPHelper.SAP_PAYMENT_METHOD_CODE_ICH && String.isBlank(oSAPInvoice.Bill_To__c)) lstErrorString.add('The field Bill To number is mandatory for customer paying with ICH');

		// check if country requires VAT number
		IECVATUtil.VATConfiguration vatConfig = IECVATUtil.GetVATConfiguration(oSAPInvoice.Billing_Country__c);
		if (vatConfig != null && vatConfig.TaxIDMandatory && String.isBlank(oSAPInvoice.VAT_Number__c))
			lstErrorString.add('The field VAT is missing for Billing Country ' + oSAPInvoice.Billing_Country__c);

		// set the field Error Message if some validation errors were not found
		if (!lstErrorString.isEmpty())
			oSAPInvoice.Error_Message__c = String.join(lstErrorString, '\r\n');
		// otherwise, clear the field
		else
			oSAPInvoice.Error_Message__c = null;
		
		// if the invoice is not valid, change status to Validation Error
		// otherwise, status New will be kept
		if (String.isNotBlank(oSAPInvoice.Error_Message__c)) {
			oSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_ValidationError;
			oSAPInvoice.Status_Date__c = Datetime.now();
		}
		else {
			
			// keeps track of the earlist DateFrom found in all Invoice Items
			Date dInvoiceItemEarliestDateFrom = null;
		
			// keeps track of the latest DateTo found in all Invoice Items
			Date dInvoiceItemLatestDateTo = null;
		
			////////////////////////////////
			// SAP INVOICE ITEM VALIDATION
			
			Integer iNbrInvoiceItemError = 0;
			
			for (IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice.IEC_SAP_Invoice_Items__r) {
				
				try {

					// check min/max DateFrom and DateTo
					if (dInvoiceItemEarliestDateFrom == null || oSAPInvoiceItem.Date_From__c < dInvoiceItemEarliestDateFrom)
						dInvoiceItemEarliestDateFrom = oSAPInvoiceItem.Date_From__c;
					if (dInvoiceItemLatestDateTo == null || oSAPInvoiceItem.Date_To__c > dInvoiceItemLatestDateTo)
						dInvoiceItemLatestDateTo = oSAPInvoiceItem.Date_To__c;

					// concatenate error messages together
					List<String> lstItemsErrorString = new List<String>();
					
					// validate that all mandatory fields are filled before sending
					if (String.isBlank(oSAPInvoiceItem.Material__c)) lstItemsErrorString.add('The field Material is missing');
					if (String.isBlank(oSAPInvoiceItem.Profit_Center__c)) lstItemsErrorString.add('The field Profit Center is missing');
					if (oSAPInvoiceItem.Quantity__c == null) lstItemsErrorString.add('The field Quantity is missing');
					if (oSAPInvoiceItem.Unit_Price__c == null) lstItemsErrorString.add('The field Unit Price is missing');
					if (oSAPInvoiceItem.Unit_Price_Currency__c == null) lstItemsErrorString.add('The field Unit Price Currency is missing');
					if (oSAPInvoiceItem.Date_From__c == null) lstItemsErrorString.add('The field Date From is missing');
					if (oSAPInvoiceItem.Date_To__c == null) lstItemsErrorString.add('The field Date To is missing');
					if (oSAPInvoiceItem.Name == null) lstItemsErrorString.add('The field Name is missing');

					// set the field Error Message if some validation errors were not found
					if (!lstItemsErrorString.isEmpty()) {
						oSAPInvoiceItem.Error_Message__c = String.join(lstItemsErrorString, '\r\n');
						iNbrInvoiceItemError++;
					}
					// otherwise, clear the field
					else
						oSAPInvoiceItem.Error_Message__c = null;
					
					// if the invoice item is not valid, change status to Validation Error
					// otherwise, status New will be kept
					if (String.isNotBlank(oSAPInvoiceItem.Error_Message__c)) {
						oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_ValidationError;
						oSAPInvoiceItem.Status_Date__c = Datetime.now();
					}
				}
				catch (Exception ex) {
					oSAPInvoiceItem.Error_Message__c += '\r\nCould not validate/update SAP Invoice Item id ' + oSAPInvoiceItem.Id + ' for the following reason: ' + ex.getMessage();
					oSAPInvoiceItem.Status__c = IECConstants.IECSAPInvoiceItem_Status_ValidationError;
					oSAPInvoiceItem.Status_Date__c = Datetime.now();
				}
			}
			
			// if one of the invoice items is not valid, flag the whole invoice as invalid
			if (iNbrInvoiceItemError > 0)
				oSAPInvoice.Error_Message__c = 'Invoice has one or more invalid Invoice Item';

			// BUSINESS RULE: Contract Start Date should match the earliest DateFrom of the invoice items
			if (oSAPInvoice.Contract_Start__c <> dInvoiceItemEarliestDateFrom)
				oSAPInvoice.Error_Message__c = 'Contract Start Date should match the earliest DateFrom of the invoice items (' + dInvoiceItemEarliestDateFrom + ')';
				
			// BUSINESS RULE: Contract End Date should match the latest DateTo of the invoice items
			if (oSAPInvoice.Contract_End__c <> dInvoiceItemLatestDateTo)
				oSAPInvoice.Error_Message__c = 'Contract End Date should match the latest DateTo of the invoice items (' + dInvoiceItemLatestDateTo + ')';
				
			if (String.isNotBlank(oSAPInvoice.Error_Message__c)) {
				oSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_ValidationError;
				oSAPInvoice.Status_Date__c = Datetime.now();
			}
		}
		
		return oSAPInvoice;
	}

	/**
	 * Updates our SAP Invoices with information received from SAP (Invoice Clearance date and SAP Invoice Number)
	 * Each invoice is processed seperatly (can fail or succeed independantly)
	 * NOTE: called by SAP via the IECSAPWebService.
	 */
	public static IECSAPWebService.PaymentConfirmationResponse[] updateInvoicesFromSAPPayment(IECSAPWebService.PaymentConfirmationRequest[] arrInvoicePayments) {

		if (arrInvoicePayments == null || arrInvoicePayments.isEmpty())
			return null;

		// the list of responses to send to SAP (index match the list of payment confirmation)
		List<IECSAPWebService.PaymentConfirmationResponse> lstPaymentResponse = new List<IECSAPWebService.PaymentConfirmationResponse>();
		
		// Map containing the queried SAP Invoice to update for payment confirmation (instead of doing 1 query per loop)
		Map<String, IEC_SAP_Invoice__c> mapSAPInvoices = new Map<String, IEC_SAP_Invoice__c>();
		
		// the list of SAP Invoices to update
		List<IEC_SAP_Invoice__c> lstInvoicesToUpdate = new List<IEC_SAP_Invoice__c>();
		
		//////////////////////////////////////////////
		// for each payment confirmation received:
		// - create a response object (index match the request list)
		// - build set of the ZuoraInvoiceNumber that SAP is sending payment confirmation for
		
		Set<String> setZuoraInvoiceNumber = new Set<String>();
		for (IECSAPWebService.PaymentConfirmationRequest payment : arrInvoicePayments) {
			
			// create the response object
			IECSAPWebService.PaymentConfirmationResponse paymentResponse = new IECSAPWebService.PaymentConfirmationResponse();
			
			// validate that a Zuora Invoice Number has been provided
			if (String.isBlank(payment.ZuoraInvoiceNumber)) {
				paymentResponse.Success = false;
				paymentResponse.Error = 'Missing field ZuoraInvoiceNumber';
			}
			// assign the invoice number we are currently handling
			else {
				paymentResponse.InvoiceNumber = payment.ZuoraInvoiceNumber.trim();
				// add the Zuora Invoice Number to the set
				setZuoraInvoiceNumber.add(payment.ZuoraInvoiceNumber);
			}
				
			lstPaymentResponse.add(paymentResponse);
		}
		
		// get all SAP Invoices matching the received Zuora Invoice Number and build map (instead of doing 1 query per loop)
		for (IEC_SAP_Invoice__c oSAPInv : [SELECT Name, Status__c, SAP_Invoice_Clearance_Date__c, Zuora_Invoice_Number__c, SAP_Invoice_Number__c, Payment_Method_Code__c FROM IEC_SAP_Invoice__c WHERE Name IN :setZuoraInvoiceNumber]) {
			mapSAPInvoices.put(oSAPInv.Name, oSAPInv);
		}
		
		// for each payment confirmation received
		Integer i = 0;
		for (IECSAPWebService.PaymentConfirmationRequest payment : arrInvoicePayments) {

			// get the current response object (index match the payment confirmation array)
			IECSAPWebService.PaymentConfirmationResponse paymentResponse = lstPaymentResponse.get(i);

			try {

				// validate that an Invoice Clearance Date has been provided
				if (payment.InvoiceClearanceDate == null) {
					paymentResponse.Success = false;
					paymentResponse.Error = 'Missing field InvoiceClearanceDate';
					continue;
				}
				
				// get SAP Invoice object from the Map
				IEC_SAP_Invoice__c oSAPInvoice = mapSAPInvoices.containsKey(payment.ZuoraInvoiceNumber) ? mapSAPInvoices.get(payment.ZuoraInvoiceNumber) : null;
				
				// if not found
				if (oSAPInvoice == null) {
					paymentResponse.Success = false;
					paymentResponse.Error = 'Invoice not found';
					IECErrorLogger.logError(null, null, 'SAP sent an invalid Zuora Invoice Number: ' + payment.ZuoraInvoiceNumber + ' (SAP Invoice Number: ' + payment.SAPInvoiceNumber + ')', null, 'IECSAPManager.updateInvoicesFromSAPPayment()', null);
					continue;
				}

				// if it's the first time we receive the payment (duplicates handling below)
				if (oSAPInvoice.Status__c == IECConstants.IECSAPInvoice_Status_SentToSAP && oSAPInvoice.SAP_Invoice_Clearance_Date__c == null) {
				
					// update the fields with the info received
					oSAPInvoice.SAP_Invoice_Clearance_Date__c = payment.InvoiceClearanceDate;
					oSAPInvoice.SAP_Invoice_Number__c = payment.SAPInvoiceNumber;
					
					// if payment method was ICH or Bank Transfer (not Credit Card)
					if (oSAPInvoice.Payment_Method_Code__c != IECSAPHelper.SAP_PAYMENT_METHOD_CODE_CREDITCARD) {
						
						// flag invoice to create payment in Zuora
						oSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_ZuoraReady;
						oSAPInvoice.Status_Date__c = Datetime.now();
						
						// if payment is ICH or Bank Transfer, payment date is the SAP Clearance Date
						oSAPInvoice.Payment_Date__c = oSAPInvoice.SAP_Invoice_Clearance_Date__c;
					}
					else {
						//  flag the SAP Invoice as paid
						oSAPInvoice.Status__c = IECConstants.IECSAPInvoice_Status_SAPPaymentConfirmationReceived;
						oSAPInvoice.Status_Date__c = Datetime.now();
					}
				}
				// we received a duplicate
				else {
					
					// if the data received is different
					if (!isPaymentRequestAndSAPInvoiceEquals(payment, oSAPInvoice)) {
						
						// return error to SAP saying that this payment is a duplicate
						paymentResponse.Success = false;
						paymentResponse.Error = 'Invoice Payment already received';
						
						// track the error in the SAP Invoice object
						List<String> lstErrorMsgs = new List<String>();
						lstErrorMsgs.add('Invoice Payment already received, but data is different:');

						if (oSAPInvoice.SAP_Invoice_Clearance_Date__c != null && !payment.InvoiceClearanceDate.isSameDay(oSAPInvoice.SAP_Invoice_Clearance_Date__c))
							lstErrorMsgs.add('Request.InvoiceClearanceDate: ' + payment.InvoiceClearanceDate + ' vs SAPInvoice.SAP_Invoice_Clearance_Date__c: ' + oSAPInvoice.SAP_Invoice_Clearance_Date__c);
						if (oSAPInvoice.Zuora_Invoice_Number__c != null && payment.ZuoraInvoiceNumber != oSAPInvoice.Zuora_Invoice_Number__c)
							lstErrorMsgs.add('Request.ZuoraInvoiceNumber: ' + payment.ZuoraInvoiceNumber + ' vs SAPInvoice.Zuora_Invoice_Number__c: ' + oSAPInvoice.Zuora_Invoice_Number__c);
						if (oSAPInvoice.SAP_Invoice_Number__c != null && payment.SAPInvoiceNumber != oSAPInvoice.SAP_Invoice_Number__c)
							lstErrorMsgs.add('Request.SAPInvoiceNumber: ' + payment.SAPInvoiceNumber + ' vs SAPInvoice.SAP_Invoice_Number__c: ' + oSAPInvoice.SAP_Invoice_Number__c);
						oSAPInvoice.Error_Message__c = String.join(lstErrorMsgs, '\r\n');
						
						continue;
					}
					else {
						// if we received the same data more than once, do nothing
						// (success will be returned to SAP)
					}
				}
				
				lstInvoicesToUpdate.add(oSAPInvoice);
			}
			catch(Exception ex) {
				paymentResponse.Success = false;
				paymentResponse.Error = ex.getMessage();
				system.debug('IECSAPManager.updateInvoicesFromSAPPayment()' + ' - Exception: ' + ex.getMessage() + ' Stack: ' + ex.getStacktraceString());
				IECErrorLogger.logError(null, 'Global exception', ex.getMessage(), null, 'IECSAPManager.updateInvoicesFromSAPPayment()', ex.getStacktraceString());
			}
			i++;
		}
		
		// update the SAP Invoice
		List<Database.SaveResult> updateResults = Database.update(lstInvoicesToUpdate, false);
		Integer saveIndex = 0;
		for (Database.SaveResult res : updateResults) {
			
			// get the current response object associated to the updated SAP Invoice (index match the index of lstInvoicesToUpdate provided to the Database.update method)
			IECSAPWebService.PaymentConfirmationResponse paymentResponse = lstPaymentResponse.get(saveIndex);
			
			if (res.isSuccess()) {
				paymentResponse.Success = true;
			}
			else {
				paymentResponse.Success = false;
				List<String> lstError = new List<String>();
				for(Database.Error err : res.getErrors()) 
					lstError.add(err.getStatusCode() + ': ' + err.getMessage());
				paymentResponse.Error = String.join(lstError, '\r\n');
			}
			saveIndex++;
		}

		return lstPaymentResponse;
	}
	
	/**
	 * Returns the an SAP Invoice (and its SAP Invoice Items) by its Invoice Number
	 */
	public static IEC_SAP_Invoice__c getSAPInvoiceByInvoiceNumber(String sInvoiceNumber) {
		
		List<IEC_SAP_Invoice__c> lstSAPInvoices =
			[SELECT Billing_City__c, Billing_Country__c, Billing_Name__c, Billing_State__c, Billing_Street__c, Bill_To__c
				, Billing_Zip__c, Contract_Start__c, Contract_End__c, Contract_Number__c, CurrencyIsoCode, Customer_PO__c, Dist_Chan__c
				, Division__c, Doc_Currency__c, Doc_Type__c, Employee_Responsible__c, Error_Message__c, Order_Reason__c
				, PO_Date__c, Pay_Method__c, Pay_Terms__c, Payment_Date__c, Id, SAP_Bill_To_Number__c, Total_Quantity__c
				, SAP_Contract_Number__c, SAP_Invoice_Clearance_Date__c, SAP_Invoice_Number__c, Sales_Office__c
				, Sales_Org__c, Shipping_City__c, Shipping_Contact__c, Shipping_Country__c, Shipping_State__c, Total_Positive_Quantity__c
				, Shipping_Street__c, Shipping_Zip__c, Status__c, Status_Date__c, Text_Print__c, VAT_number__c, Payment_Method_Code__c
				, Name, Zuora_Invoice_Number__c, Ready_for_SAP__c, Number_of_SAP_Items__c, Number_of_Error_SAP_Items__c
				, Number_of_Zuora_Items__c, Billing_Country_ISO_Code__c,Warning_Message__c, Zuora_Billing_Account_ID__c
				, Account__r.Sales_Office__c, Account__r.Payment_Term__c, Number_of_Use_Contract__c
				, (SELECT Date_From__c,Date_To__c,Error_Message__c,IEC_SAP_Invoice__c,Material__c,Material_Description__c, Charge_Amount__c
					, Profit_Center__c,Quantity__c,Status__c,Status_Date__c,Unit_Price__c,Unit_Price_Currency__c, Name, Adjusted_Charge_Amount__c
					, Product__r.IEC_SAP_DocType__c, Product__r.Product_Manager_lookup__r.EmployeeNumber, Product__r.SAP_Contract_OrderReason__c
					, Product__c, Use_Contract__c 
				 FROM IEC_SAP_Invoice_Items__r)
				FROM IEC_SAP_Invoice__c
				WHERE Name = :sInvoiceNumber];
				
		if (lstSAPInvoices == null || lstSAPInvoices.isEmpty())
			return null;
		else
			return lstSAPInvoices.get(0);
	}
	
	/**
	 * Compares the data received from the web service (PaymentConfirmationRequest) and a SAP Invoice.
	 * This method is used to check when receiving duplicate payments from SAP.
	 */
	private static Boolean isPaymentRequestAndSAPInvoiceEquals(IECSAPWebService.PaymentConfirmationRequest oRequest, IEC_SAP_Invoice__c oSAPInvoice) {

		return (oRequest.InvoiceClearanceDate == oSAPInvoice.SAP_Invoice_Clearance_Date__c
				&& oRequest.ZuoraInvoiceNumber == oSAPInvoice.Zuora_Invoice_Number__c
				&& oRequest.SAPInvoiceNumber == oSAPInvoice.SAP_Invoice_Number__c);
	}
}
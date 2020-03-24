/**
 * Provides helper methods to helper call SAP web service
 */
public with sharing class IECSAPHelper {

	private final static String EMPTY = '';

	// Message type: S Success, E Error, W Warning, I Info, A Abort
	public final static String RESPONSE_TYPE_SUCCESS = 'S';
	public final static String RESPONSE_TYPE_ERROR = 'E';
	public final static String RESPONSE_TYPE_WARNING = 'W';
	public final static String RESPONSE_TYPE_INFO = 'I';
	public final static String RESPONSE_TYPE_ABORT = 'A';

	public final static String RESPONSE_MESSAGE_CONTRACT_PREFIX = 'IATA Contract ';
	public final static String RESPONSE_MESSAGE_CONTRACT_SUFFIX = ' has been saved';
	public final static String RESPONSE_MESSAGE_BILLTO_PREFIX = 'Bill To:';
	public final static String RESPONSE_MESSAGE_BILLTO_SUFFIX = ' exists in system';

	// Payment method codes
	public final static String SAP_PAYMENT_METHOD_CODE_CREDITCARD = '1';
	public final static String SAP_PAYMENT_METHOD_CODE_ICH = 'I';
	public final static String SAP_PAYMENT_METHOD_CODE_BANKTRANSFER = 'T';

	/**
	 * Creates the header object required for the invoice creation SAP web service based on the Invoice, SAP Account, IsOneTimeCustomer flag, etc
	 */
	public static iataComXiSalesforceOtcWid5600Sales3.Header_element createHeaderForInvoiceSending(IEC_SAP_Invoice__c oSAPInvoice) {

		iataComXiSalesforceOtcWid5600Sales3.Header_element oHeader = new iataComXiSalesforceOtcWid5600Sales3.Header_element();

		/* Commented as part of ECOM-495: DEV- Modify contract interface for sales area
		oHeader.SalesOrg = oSAPInvoice.Sales_Org__c;
		oHeader.DistChan = oSAPInvoice.Dist_Chan__c;
		oHeader.Division = oSAPInvoice.Division__c;
		*/
		oHeader.SalesOffice = oSAPInvoice.Account__r.Sales_Office__c;
		oHeader.ContractNumber = EMPTY;
		oHeader.BillTo = oSAPInvoice.Bill_To__c;
		oHeader.ContactPerson = EMPTY;
		oHeader.ZuoraInv = oSAPInvoice.Zuora_Invoice_Number__c;
		oHeader.PODate = oSAPInvoice.PO_Date__c;
		oHeader.Name = oSAPInvoice.Billing_Name__c; // based on feedback from Tamer, it is the Contact's name
		// SAP integration test
		//oHeader.Name = EMPTY;
		oHeader.CustomerPO = oSAPInvoice.Customer_PO__c;
		oHeader.ContractStart = oSAPInvoice.Contract_Start__c;
		oHeader.ContractEnd = oSAPInvoice.Contract_End__c;
		oHeader.DocCurr = oSAPInvoice.Doc_Currency__c;
		oHeader.PayMethod = oSAPInvoice.Payment_Method_Code__c;
		oHeader.PayTerms = oSAPInvoice.Account__r.Payment_Term__c;
		oHeader.TextPrint = oSAPInvoice.Text_Print__c;

		if (!oSAPInvoice.IEC_SAP_Invoice_Items__r.isEmpty())
		{
			// Assumption is there will always be one invoice item under the any single invoice
			IEC_SAP_Invoice_Item__c oSAPInvoiceItem = oSAPInvoice.IEC_SAP_Invoice_Items__r[0];

			oHeader.DocType = oSAPInvoiceItem.Product__r.IEC_SAP_DocType__c;
			oHeader.EmpResp = oSAPInvoiceItem.Product__r.Product_Manager_lookup__r.EmployeeNumber;
			oHeader.OrderReason = oSAPInvoiceItem.Product__r.SAP_Contract_OrderReason__c;
		}
		else
		{
			oHeader.DocType = EMPTY;
			oHeader.EmpResp = EMPTY;
			oHeader.OrderReason = EMPTY;
		}

		return oHeader;
	}

	/**
	 * Creates the items element required for the invoice creation SAP web service
	 */
	public static iataComXiSalesforceOtcWid5600Sales3.Item_element[] createItemElementsForInvoiceSending(IEC_SAP_Invoice__c oSAPInvoice) {

		List<iataComXiSalesforceOtcWid5600Sales3.Item_element> lstItemElements = new List<iataComXiSalesforceOtcWid5600Sales3.Item_element>();

		// first check if the invoice is for an upgrade
		// (upgrades have a negative amount on an invoice item, and SAP just wants the adjusted charged amount)
		Boolean bInvoiceIsForUpgrade = (oSAPInvoice.Total_Positive_Quantity__c != oSAPInvoice.Total_Quantity__c);

		for(IEC_SAP_Invoice_Item__c oSAPInvoiceItem : oSAPInvoice.IEC_SAP_Invoice_Items__r) {

			// if the invoice is for an Upgrade, ignore negative Invoice items
			if (bInvoiceIsForUpgrade && oSAPInvoiceItem.Charge_Amount__c < 0)
				continue;

			iataComXiSalesforceOtcWid5600Sales3.Item_element item = new iataComXiSalesforceOtcWid5600Sales3.Item_element();

			item.Material = oSAPInvoiceItem.Material__c;
			item.MatDesc = oSAPInvoiceItem.Material_Description__c;
			item.PrftCtr = oSAPInvoiceItem.Profit_Center__c;
			item.Quantity = String.valueOf(oSAPInvoiceItem.Quantity__c);
			item.UnitPrice = String.valueOf(oSAPInvoiceItem.Adjusted_Charge_Amount__c); // send the Adjusted Charge Amount and not the Unit Price (hack for upgrades)
			item.UnitPriceCurr = oSAPInvoiceItem.Unit_Price_Currency__c;
			item.DateFrom = oSAPInvoiceItem.Date_From__c;
			item.DateTo = oSAPInvoiceItem.Date_To__c;

			lstItemElements.add(item);
		}

		return lstItemElements;
	}

	/**
	 * Creates the Address element required for the invoice creation SAP web service
	 */
	public static iataComXiSalesforceOtcWid5600Sales3.Address_element createAddressElementForInvoiceSending(IEC_SAP_Invoice__c oSAPInvoice) {

		iataComXiSalesforceOtcWid5600Sales3.Address_element oAddress = new iataComXiSalesforceOtcWid5600Sales3.Address_element();

		// Billing Address
		oAddress.BillingAddress = oSAPInvoice.Billing_Street__c;
		oAddress.BillingCity = oSAPInvoice.Billing_City__c;
		oAddress.BillingCountry = oSAPInvoice.Billing_Country_ISO_Code__c; //oSAPInvoice.Billing_Country__c;
		oAddress.BillingPostalCode = oSAPInvoice.Billing_Zip__c;
		// convert state name to state code (if needed)
		String sStateCode = null;
		if (String.isNotBlank(oSAPInvoice.Billing_State__c) && oSAPInvoice.Billing_State__c.length() == 2)
			sStateCode = oSAPInvoice.Billing_State__c.toUpperCase();
		else
			sStateCode = IECUtil.getStateCodeByNameAndCountryCode(oSAPInvoice.Billing_State__c, oSAPInvoice.Billing_Country_ISO_Code__c);
		oAddress.BillingState = String.isBlank(sStateCode) ? EMPTY : sStateCode;
		oAddress.VATRegId = oSAPInvoice.VAT_Number__c;

		// Shipping Address
		/* AS PER RELEASE 1: leave shipping fields empty
		oAddress.ShippingContactName = oSAPInvoice.Shipping_Contact__c;
		oAddress.ShippingAddress = oSAPInvoice.Shipping_Street__c;
		oAddress.ShippingCity = oSAPInvoice.Shipping_City__c;
		oAddress.ShippingCountry = oSAPInvoice.Shipping_Country__c;
		oAddress.ShippingPostalCode = oSAPInvoice.Shipping_Zip__c;
		// convert state name to state code (if needed)
		sStateCode = null;
		if (String.isNotBlank(oSAPInvoice.Shipping_State__c) && oSAPInvoice.Shipping_State__c.length() == 2)
			sStateCode = oSAPInvoice.Shipping_State__c.toUpperCase();
		else
			sStateCode = IECUtil.getStateCodeByNameAndCountryCode(oSAPInvoice.Shipping_State__c, oSAPInvoice.??????_Country_ISO_Code__c);

		oAddress.ShippingState = String.isBlank(sStateCode) ? null : sStateCode;
		*/
		oAddress.ShippingContactName = EMPTY;
		oAddress.ShippingAddress = EMPTY;
		oAddress.ShippingCity = EMPTY;
		oAddress.ShippingCountry = EMPTY;
		oAddress.ShippingPostalCode = EMPTY;
		oAddress.ShippingState = EMPTY;

		return oAddress;
	}
}

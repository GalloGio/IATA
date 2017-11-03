/**
 * Page controller for the Payments page
 */
public with sharing class vfIECHistPayments extends IECPageController {

	//public List<Zuora__Payment__c> lstPaymentsToDisplay { get; private set; }
	public List<PaymentWrapper> lstPaymentsToDisplay { get; private set; }

	public List<Zuora__PaymentInvoice__c> lstPaymentInvoicesToDisplay { get; private set; }
	public Integer iNbrRowsDisplayed { get; private set; }
	public String sSelectedInvoiceID { get; set; }
	public String sSelectedPaymentID { get; set; }
	//public Zuora__Payment__c oSelectedPayment { get; private set; }
	public PaymentWrapper oSelectedPayment { get; private set; }
	public String sSortDirection { get; set; }
	public String sSortByColumn { get; set; }
	public DateTime legacyInvoiceDate {get;set;}

	public class PaymentWrapper implements Comparable {
		private Zuora__Payment__c payment;
		private IEC_Payment_Error__C paymentError;

		public Id id {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Id;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Id;
				} else {
					return null;
				}
			}
		}

		public String type { get; set; }

		public String paymentID {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Name;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Payment_ID__c;
				} else {
					return null;
				}
			}
		}

		public Datetime effectiveDate {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__EffectiveDate__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Effective_Date__c;
				} else {
					return null;
				}
			}
		}

		public Datetime createdDate {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__CreatedDate__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Created_Date__c;
				} else {
					return null;
				}
			}
		}

		public Decimal amount {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__Amount__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Amount__c;
				} else {
					return null;
				}
			}
		}

		public String status {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__Status__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Status__c;
				} else {
					return null;
				}
			}
		}

		public String paymentMethod {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__PaymentMethod__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Payment_Method__c;
				} else {
					return null;
				}
			}
		}

		public String referenceID {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__ReferenceId__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Reference_ID__c;
				} else {
					return null;
				}
			}
		}

		public List<Zuora__PaymentInvoice__c> invoiceList {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Zuora__PaymentInvoices__r;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return new List<Zuora__PaymentInvoice__c>();
				} else {
					return null;
				}
			}
		}

		public String orderId {
			get {
				if (type != null && type == 'Zuora__Payment__c' && payment != null) {
					return payment.Order__c;
				} else if (type != null && type == 'IEC_Payment_Error__c' && paymentError != null) {
					return paymentError.Order__c;
				} else {
					return null;
				}
			}
		}

		public PaymentWrapper(Zuora__Payment__c zp) {
			payment = null;
			paymentError = null;

			if (zp != null) {
				payment = zp;

				type = 'Zuora__Payment__c';
			}
		}

		public PaymentWrapper(IEC_Payment_Error__c pe) {
			payment = null;
			paymentError = null;

			if (pe != null) {
				paymentError = pe;

				type = 'IEC_Payment_Error__c';
			}
		}

		public Integer compareTo(Object compareTo) {
			PaymentWrapper compareToPayment = (PaymentWrapper)compareTo;

			Integer result = 0;

			if (this.createdDate < compareToPayment.createdDate) {
				result = -1;
			} else if (this.createdDate > compareToPayment.createdDate) {
				result = 1;
			}

			return result;
		}
	}

	public List<PaymentWrapper> getLoggedUserPayments() {
		List<PaymentWrapper> resultList = new List<PaymentWrapper>();

		System.debug('Logged Customer Related Billing Account Id: ' + loggedCustomer.RelatedBillingAccount.Id);

		List<Zuora__Payment__c> processedPayments = loggedCustomer.Payments;
		List<IEC_Payment_Error__c> errorPayments = [
			SELECT
				Id,
				Name,
				Payment_ID__c,
				Effective_Date__c,
				Amount__c,
				Status__c,
				Payment_Method__c,
				Reference_ID__c,
				Order__c,
				Created_Date__c
			FROM
				IEC_Payment_Error__c
			WHERE
				Billing_Account__c = :loggedCustomer.RelatedBillingAccount.Id
			ORDER BY
				Created_Date__c
		];

		System.debug('Processed Payments: ' + processedPayments.size() + ', Error Payments: ' + errorPayments.size());

		for (Zuora__Payment__c p : processedPayments) {
			resultList.add(new PaymentWrapper(p));
		}

		for (IEC_Payment_Error__c p : errorPayments) {
			resultList.add(new PaymentWrapper(p));
		}

		resultList.sort();
		
		return resultList;
	}

	/**
	 * Constructor
	 */
	public vfIECHistPayments() {

		Date dt = Date.valueOf(Utility.getTextSetting('Legacy Invoice Cutoff Date'));
		if(dt != null)
			legacyInvoiceDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
			
		try {

			// check if a Payment ID was passed as a parameter
			String sParamPaymentID = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PAYMENT_ID);
			if (sParamPaymentID!=null && !String.isEmpty(sParamPaymentID))
				sSelectedPaymentID = IECUtil.DecodeDecryptParameter(sParamPaymentID);
			else
				sSelectedPaymentID = null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
		}
	}
	
	/**
	 * Action called after the page has been loaded
	 */
	public Pagereference pageLoad() {
		try {
			
			// first check if the user is logged in
			if (IECUserManager.isUserLoggedIn() == false) {
				//Pagereference prLogin = Page.IECLogin;
				//prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				//prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				Pagereference prLogin = Page.IEC_Login;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();
				
				//lstPaymentsToDisplay = loggedCustomer.Payments;
				lstPaymentsToDisplay = getLoggedUserPayments();
				
				iNbrRowsDisplayed = (lstPaymentsToDisplay != null) ? lstPaymentsToDisplay.size() : 0;
				/*
				
				if (lstPaymentsToDisplay != null && lstPaymentsToDisplay.size() > 5)
					iNbrRowsDisplayed = 5;
				else
					iNbrRowsDisplayed = (lstPaymentsToDisplay != null) ? lstPaymentsToDisplay.size() : 0;
				*/
					
				// preselect payment if one was specified in the parameters
				if (iNbrRowsDisplayed > 0 && sSelectedPaymentID != '' && sSelectedPaymentID != null)
					selectPayment();
					
				return null;
			}
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}
	
	/**
	 * Action when a user clicks on Show All
	 */
	public Pagereference showAll() {
		iNbrRowsDisplayed = (lstPaymentsToDisplay != null) ? lstPaymentsToDisplay.size() : 0;
		return null;
	}
	
	/**
	 * Action when a user clicks on a Payment
	 */
	public Pagereference selectPayment() {
		try {
			if(String.isBlank(sSelectedPaymentID))
				return null;

			// search for Payment in list
			//for(Zuora__Payment__c payment : lstPaymentsToDisplay) {
			for (PaymentWrapper payment : lstPaymentsToDisplay) {
				//if (payment.Id == sSelectedPaymentID) {
				if (payment.id == sSelectedPaymentID) {
					oSelectedPayment = payment;
					break;
				}
			}
			
			// if a Payment was found
			if (oSelectedPayment != null) {
				// get the related payment invoice
				if (oSelectedPayment.type != 'IEC_Payment_Error__c') {
					lstPaymentInvoicesToDisplay = IECSubscriptionManager.getPaymentInvoicesByPaymentID(oSelectedPayment.Id);
				} else {
					lstPaymentInvoicesToDisplay = new List<Zuora__PaymentInvoice__c>();
				}
			}

			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}
	
	/**
	 * Action when a user clicks on an invoice; redirects to the Invoice page with a preselected invoice
	 */
	public Pagereference selectInvoice() {
		try {
			if(String.isBlank(sSelectedInvoiceID))
				return null;

			Pagereference prInvoice = Page.IECHistInvoices;
			prInvoice.getParameters().put(IECConstants.PARAM_INVOICE_ID, IECUtil.EncryptEncodeParameter(sSelectedInvoiceID));
			prInvoice.setRedirect(true);
			return prInvoice;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}
	
	/**
	 * Action when a user sort by a column
	 */
	public Pagereference sortPayments() {
		try {
			if (String.isBlank(sSortDirection) || String.isBlank(sSortByColumn))
				return null;
			
			//lstPaymentsToDisplay = IECSubscriptionManager.getSortedPaymentsByBillingAccount((String)loggedCustomer.RelatedBillingAccount.Id, sSortByColumn, sSortDirection);
			lstPaymentsToDisplay = getLoggedUserPayments();
			
			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}
}
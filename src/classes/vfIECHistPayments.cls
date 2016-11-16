/**
 * Page controller for the Payments page
 */
public with sharing class vfIECHistPayments extends IECPageController {

	public List<Zuora__Payment__c> lstPaymentsToDisplay { get; private set; }
	public List<Zuora__PaymentInvoice__c> lstPaymentInvoicesToDisplay { get; private set; }
	public Integer iNbrRowsDisplayed { get; private set; }
	public String sSelectedInvoiceID { get; set; }
	public String sSelectedPaymentID { get; set; }
	public Zuora__Payment__c oSelectedPayment { get; private set; }
	public String sSortDirection { get; set; }
	public String sSortByColumn { get; set; }
	public DateTime legacyInvoiceDate {get;set;}

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
				
				lstPaymentsToDisplay = loggedCustomer.Payments;
				
				
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
			for(Zuora__Payment__c payment : lstPaymentsToDisplay) {
				if (payment.Id == sSelectedPaymentID) {
					oSelectedPayment = payment;
					break;
				}
			}
			
			// if a Payment was found
			if (oSelectedPayment != null) {
				// get the related payment invoice
				lstPaymentInvoicesToDisplay = IECSubscriptionManager.getPaymentInvoicesByPaymentID(oSelectedPayment.Id);
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
			
			lstPaymentsToDisplay = IECSubscriptionManager.getSortedPaymentsByBillingAccount((String)loggedCustomer.RelatedBillingAccount.Id, sSortByColumn, sSortDirection);
			
			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}
}
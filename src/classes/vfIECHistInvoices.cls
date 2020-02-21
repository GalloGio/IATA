/**
 * Page controller for the Invoices page
 */
public with sharing class vfIECHistInvoices extends IECPageController {

	public List<Zuora__ZInvoice__c> lstInvoicesToDisplay { get; private set; }
	public List<Zuora__PaymentInvoice__c> lstPaymentInvoicesToDisplay { get; private set; }
	public Integer iNbrRowsDisplayed { get; private set; }
	public String sSelectedInvoiceID { get; set; }
	public String sSelectedPaymentID { get; set; }
	public Zuora__ZInvoice__c oSelectedInvoice { get; private set; }
	public String sSortDirection { get; set; }
	public String sSortByColumn { get; set; }

	/**
	 * Constructor
	 */
	public vfIECHistInvoices() {
		try {

			// check if an Invoice ID was passed as a parameter
			String sParamInvoiceID = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_INVOICE_ID);
			if (String.isNotBlank(sParamInvoiceID))
				sSelectedInvoiceID = IECUtil.DecodeDecryptParameter(sParamInvoiceID);
			else
				sSelectedInvoiceID = null;
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
				Pagereference prLogin = Page.IECLogin;
				prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
				prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
				prLogin.setRedirect(true);
				return prLogin;
			}
			else {
				// Validate Logged in user profile and ensure profile is complete
				validUserProfile();

				// get the invoices (but not the ICH ones)(NEW CHANGE: INCLUDE ICH 2014-07-11)
				lstInvoicesToDisplay = (loggedCustomer.RelatedBillingAccount != null)
					? IECSubscriptionManager.getInvoicesByBillingAccount(loggedCustomer.RelatedBillingAccount.Id, true)
					: null;

				iNbrRowsDisplayed = (lstInvoicesToDisplay != null) ? lstInvoicesToDisplay.size() : 0;
				/*
				if (lstInvoicesToDisplay.size() > 5)
					iNbrRowsDisplayed = 5;
				else
					iNbrRowsDisplayed = lstInvoicesToDisplay.size();
				*/

				// preselect invoice if one was specified in the parameters
				if (iNbrRowsDisplayed > 0 && sSelectedInvoiceID != '' && sSelectedInvoiceID != null)
					selectInvoice();

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
		iNbrRowsDisplayed = lstInvoicesToDisplay.size();
		return null;
	}

	/**
	 * Action when a user clicks on an invoice
	 */
	public Pagereference selectInvoice() {
		try {
			if(String.isBlank(sSelectedInvoiceID))
				return null;

			// search for invoice in list
			for(Zuora__ZInvoice__c invoice : lstInvoicesToDisplay) {
				if (invoice.Id == sSelectedInvoiceID) {
					oSelectedInvoice = invoice;
					break;
				}
			}

			// if an invoice was found
			if (oSelectedInvoice != null) {
				// get the related payment invoice
				lstPaymentInvoicesToDisplay = IECSubscriptionManager.getPaymentInvoicesByInvoiceID(oSelectedInvoice.Id);
			}

			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}

	/**
	 * Action when a user clicks on a payment; redirects to the Payments page with a preselected payment
	 */
	public Pagereference selectPayment() {
		try {
			if(String.isBlank(sSelectedPaymentID))
				return null;

			Pagereference prPayment = Page.IECHistPayments;
			prPayment.getParameters().put(IECConstants.PARAM_PAYMENT_ID, IECUtil.EncryptEncodeParameter(sSelectedPaymentID));
			prPayment.setRedirect(true);
			return prPayment;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}

	/**
	 * Action when a user sort by a column
	 */
	public Pagereference sortInvoices() {
		try {
			if (sSortDirection == '' || sSortByColumn == '')
				return null;

			lstInvoicesToDisplay = IECSubscriptionManager.getSortedInvoicesByBillingAccount((String)loggedCustomer.RelatedBillingAccount.Id, true, sSortByColumn, sSortDirection);

			return null;
		}
		catch(Exception ex) {
			addErrorMessage(ex.getMessage());
			return null;
		}
	}
}

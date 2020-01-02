/******************************************************************************************************************
 *  IEC_MyInvoicesController: IEC_MyInvoices page Controller                                                      *
 *  Author: David Daboué - CGI                                                                                    *
 ******************************************************************************************************************/
public with sharing class IEC_MyInvoicesController extends IEC_PageController
{
	public List<Zuora__ZInvoice__c> invoices { get; set; }

	public IEC_MyInvoicesController() {}

	/**************************************************************************************************************
		 *  onLoadAction: method calls when page loaded                                                               *
		 *  Author: David Daboué                                                                                      *
		 **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		if(loggedCustomer == null)
		{
			//-- redfirect to login
			PageReference pgRef = new PageReference('/IEC_Login?returl=/IEC_MyInvoices');
				pgRef.setRedirect(true);
					return pgRef;
		}

		if(loggedCustomer.zBillingAccount != null)
			invoices = IECSubscriptionManager.getInvoicesByBillingAccount(loggedCustomer.zBillingAccount.Id, true);

		return null;
	}
}

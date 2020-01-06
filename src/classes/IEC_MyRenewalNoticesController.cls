/******************************************************************************************************************
 *  IEC_MyRenewalNoticesController: IEC_MyRenewalNotices page Controller                                          *
 *  Author: David Daboué - CGI                                                                                    *
 ******************************************************************************************************************/
public with sharing class IEC_MyRenewalNoticesController extends IEC_PageController
{
	public List<Order> getRenewalNotices(){
		return Order_Sel.getCustomerRenewalNotices(loggedCustomer.sfUser.ContactId);
	}

	/**************************************************************************************************************
		 *  IEC_MyRenewalNoticesController: Class Constructor                                                         *
		 *  Author: David Daboué                                                                                      *
		 **************************************************************************************************************/
	public IEC_MyRenewalNoticesController()
	{
	}

	/**************************************************************************************************************
		 *  onLoadAction: method calls when page loaded                                                               *
		 *  Author: David Daboué                                                                                      *
		 **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		if(loggedCustomer == null)
		{
			PageReference ret = new PageReference('/IEC_Login?returl=/IEC_MyRenewalNotices');
			ret.setRedirect(true);
					return ret;
		}

		return null;
	}

}

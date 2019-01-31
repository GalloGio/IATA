public class IEC_MyOrdersController   extends IEC_PageController
{
	public IEC_MyOrdersController() {}

	public List<Order> myOrders{get;set;}

	public PageReference onLoadAction()
	{
		if(loggedCustomer == null)
		{
			PageReference ret = new PageReference('/IEC_Login?returl=/IEC_OrderHistory');
			ret.setRedirect(true);
	        return ret;
		}

		//-- Load My Orders 
		Order_Sel oSelector =new Order_Sel();
		myOrders = oSelector.getMyOrdersForOrderHistory(loggedCustomer.sfContact.Id);

		return null;
	}
}
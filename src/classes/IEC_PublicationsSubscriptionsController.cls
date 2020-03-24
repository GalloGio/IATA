public without sharing class IEC_PublicationsSubscriptionsController extends IEC_PageController /*IECPageController*/ {

	public Contact oContact { get; private set; }
	public List<OrderItem> orderItems{get;set;}
	public List<item> lstOrderItem {get;set;}

	public class item{
		public OrderItem ordItem{get;set;}
		public Integer subscriptionDaysLeft{get;set;}
		public item(OrderItem oi, Integer nbSubDays){
			this.ordItem = oi;
			this.subscriptionDaysLeft = nbSubDays;
		}
	}

	public PageReference pageLoad(){

		// first check if the user is logged in
		if (IECUserManager.isUserLoggedIn() == false) {
			Pagereference prLogin = Page.IEC_Login;
			prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, ApexPages.currentPage().getUrl());
			prLogin.setRedirect(true);
			return prLogin;
		}else {
			oContact = loggedCustomer.sfContact;

			//Ensure there is a customer registered
			IECCustomer currentCustomer = IECCustomer.getCurrentIECCustomer();
			if (currentCustomer == null) return null;

			//get the Customer Event Subscriptions
			map<Id,Id> eveSubId_prodId = new map<Id,Id>();
			List<IEC_Event_Subscription__c> eventSubscriptions = new IEC_EventSubscription_Sel().getEventSubscriptionBySubscriber(oContact.Id);

			orderItems = new List<OrderItem>();
			lstOrderItem = new List<item>();

			//Get the customer Event Subscriptions and the number of days left
			if(eventSubscriptions != null && !eventSubscriptions.isEmpty()){
				for(IEC_Event_Subscription__c eveSub : eventSubscriptions){
					orderItems.addAll(eveSub.Order_Products__r);

					for(OrderItem oi : eveSub.Order_Products__r){
						if(oi.Effective_End_Date__c == null) continue;
						Integer daysLeft = Date.today().daysBetween(oi.Effective_End_Date__c);
						if (daysLeft < 0) daysLeft = 0;
						lstOrderItem.add(new item(oi,daysLeft));
					}
				}
			}

		}

		return null;
	}

}

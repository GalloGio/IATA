@isTest
public class IEC_PublicationsSubscriptionsCtrl_Test {
	@isTest (SeeAllData = true)
	static void IEC_PublicationsSubscriptionsCtrl_Test() {
		
		//Custom settings
		TestDataGenerator.generateApexSetting();
		TestDataGenerator.generateISOCountryState();

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		if(usr.Id == null)insert usr;

		IEC_PublicationsSubscriptionsController pubSub = new IEC_PublicationsSubscriptionsController();
		pubSub.pageLoad();

		System.runAs(usr){
			//Create location for the customer
			Location_Svc.initializeDefaultLocations(new List<Id>{usr.ContactId});

			//Products
			List<Product2> products = TestDataGenerator.generateProducts(1, true);

			//Orders & OrderItems
			List<Account> accounts = TestDataGenerator.generateAccounts(1,true);
			List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,1,true);
			List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, usr.ContactId,true); 
			List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, products, true);
			
			//create event subscription
			IEC_Event_Subscription__c eveSubscription = new IEC_Event_Subscription__c(
				Product__c = orderItems[0].Product__c,
				Subscriber__c = orders[0].BillToContactId,
				Start_Date__c = Date.today(),
				Quantity__c = orderItems[0].Quantity
			);
			insert eveSubscription;

			orderItems[0].IEC_Event_Subscription__c = eveSubscription.Id;
			update orderItems;

			PageReference pageRef = Page.IEC_PublicationsSubscriptions;
			Test.setCurrentPage(pageRef);

			//cover IEC_PublicationsSubscriptionsController
			IEC_PublicationsSubscriptionsController pubSubs = new IEC_PublicationsSubscriptionsController();
			pubSubs.pageLoad();

			//Cover the _EventSubscription selector
			IEC_EventSubscription_Sel eveSubSel = new IEC_EventSubscription_Sel();
			eveSubSel.getEventSubscriptionById(new set<Id>{eveSubscription.Id});
		}
		

	}
}
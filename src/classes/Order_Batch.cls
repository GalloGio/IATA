global class Order_Batch implements Database.Batchable<Order> , Database.AllowsCallouts
{
	// List of orders to be processed with this batch
	List<Order> ordersToProcess;

	// Type of action required under this batch
	String action;

	global Order_Batch(String a, List<Order> lst)
	{
		action = a;
		ordersToProcess = lst;
	}

	// Return list of orders to be used in this batch
	global List<Order> start(Database.BatchableContext BC)
	{
		return ordersToProcess;
	}

	 	global void execute(Database.BatchableContext BC, List<Order> scope)
	 	{
	 		// If the specified action is either clean up quotes or renewal notifications, then delete these old orders
		if(action == 'CleanUpQuotes' || action == 'CleanUpRenewalNotifications')
		{
			delete scope;
		}
		// Create the SAP Sales order using the provided list of orders
		else if(action == 'CreateSalesOrders')
		{
			Map<Id, Order> orderById = new Map<Id, Order>(scope);
			Order_Svc.createSapSalesOrders(orderById.keySet());
		}
	}

	global void finish(Database.BatchableContext BC) { }
}

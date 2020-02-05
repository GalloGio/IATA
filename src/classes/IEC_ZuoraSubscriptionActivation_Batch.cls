//Update all the pending Activation subscription in Zuora
global class IEC_ZuoraSubscriptionActivation_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	private List<OrderItem> lstOrderItem;

	//Get the list of order item with pending activation subscription
	global IEC_ZuoraSubscriptionActivation_Batch(List<OrderItem> orderItems) {
		lstOrderItem = orderItems;
	}

	global List<OrderItem> start(Database.BatchableContext BC) {
		return lstOrderItem;
	}

	 	global void execute(Database.BatchableContext BC, List<OrderItem> scope) {
	 		//Process the Order item with subscription
		Order_Svc.updateZsubscriptions(scope);
	}

	global void finish(Database.BatchableContext BC) {

	}

}

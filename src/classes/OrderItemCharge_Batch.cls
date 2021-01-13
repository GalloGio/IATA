/****************************************************************************************************
		Created by CGI - Kevin 12/17/2015
			Clean up all the OrderITemCharge with no OrderItem related
****************************************************************************************************/
global class OrderItemCharge_Batch implements Database.Batchable<sObject> {

	List<Order_Item_Charge__c> orderItemCharges;
	String action;

	global OrderItemCharge_Batch(String a, List<Order_Item_Charge__c> oic) {
		orderItemCharges = oic;
		action = a;
	}

	global List<Order_Item_Charge__c> start(Database.BatchableContext BC) {
		return orderItemCharges;
	}

	 	global void execute(Database.BatchableContext BC, List<Order_Item_Charge__c> scope) {
		if(action == 'CleanUpOrderItemCharges'){
			delete scope;
		}
	}

	global void finish(Database.BatchableContext BC) {

	}

}

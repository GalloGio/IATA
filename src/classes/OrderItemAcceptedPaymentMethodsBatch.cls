/**

	   File: OrderItemAcceptedPaymentMethodsBatch.cls
	Purpose: Replicate the updated Product Accepted Payment Methods to "open" Order Items.
	 Author: blue-infinity sa.
	History: 2017-06-19, aosantos, Initial Release.


*/
global class OrderItemAcceptedPaymentMethodsBatch implements Database.Batchable<sObject> {
	global final Map<Id, String> acceptedPaymentMethodsMap;
	global final Set<Id> productIdSet;

	global OrderItemAcceptedPaymentMethodsBatch(Set<Id> productIdSet) {
		acceptedPaymentMethodsMap = new Map<Id, String>();
		this.productIdSet = productIdSet;

		for (Product2 product : [SELECT Id, Accepted_Payment_Methods__c FROM Product2 WHERE Id IN :productIdSet]) {
			acceptedPaymentMethodsMap.put(product.Id, product.Accepted_Payment_Methods__c);
		}
	}

	/**
		Start

	*/
	global Database.QueryLocator start(Database.BatchableContext bc) {
		String query = 'SELECT Id, Status, PricebookEntry.Product2Id, Accepted_Payment_Method__c FROM OrderItem WHERE Order.Status =\'New\' AND Accepted_Payment_Method__c = NULL';

		return Database.getQueryLocator(
			[
				SELECT
					Id,
					OrderId,
					Order.Status,
					PricebookEntry.Product2Id,
					Accepted_Payment_Methods__c
				FROM
					OrderItem
				WHERE
					PricebookEntry.Product2Id IN :productIdSet
					AND
					Order.Status = 'New'
			]
		);
	}

	/**
		Execute

	*/
	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		if (scope != null) {
			List<OrderItem> orderItemList = (List<OrderItem>)scope;

			System.debug('Processing ' + orderItemList.size() + ' order items');

			for (OrderItem orderItem : orderItemList) {
				Id productId = orderItem.PricebookEntry.Product2Id;
				String acceptedPaymentMethods = acceptedPaymentMethodsMap.get(productId);

				orderItem.Accepted_Payment_Methods__c = acceptedPaymentMethods;
			}

			System.debug('updating order items');

			update orderItemList;
		}
	}

	/**
		Finish

	*/
	global void finish(Database.BatchableContext bc) {
	}
}
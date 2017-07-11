/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
    
****************************************************************************************************/
public without sharing class OrderItem_Dom {
	
	/****************************************************************************************************
	        Call trigger method corresponding to trigger event
	****************************************************************************************************/
	public static void triggerHandler() {
	    //*** instantiate the domain class to prevent too many static methods
	    OrderItem_Dom exe = new OrderItem_Dom();
	    
	    //*** call handler method corresponding to trigger event
	    if (trigger.isBefore) {
	             /*if (trigger.isInsert) exe.onBeforeInsert();
	        else if (trigger.isUpdate) exe.onBeforeUpdate();*/
	        if (trigger.isUpdate) exe.onBeforeUpdate();
	        else if (trigger.isDelete) exe.onBeforeDelete();
	    } else if (trigger.isAfter) {
	             if (trigger.isInsert) exe.onAfterInsert();
	        else if (trigger.isUpdate) exe.onAfterUpdate();
	        //else if (trigger.isDelete) exe.onAfterDelete();
	    }
	} //*** end of "triggerHandler"
	
	
	/****************************************************************************************************
	        Data variables
	****************************************************************************************************/
	private List<OrderItem> newList = new List<OrderItem>();
	private List<OrderItem> oldList = new List<OrderItem>();
	private Map<Id, OrderItem> newMap = new Map<Id, OrderItem>();
	private Map<Id, OrderItem> oldMap = new Map<Id, OrderItem>();
	
	/****************************************************************************************************
	        Set trigger data to data variables
	****************************************************************************************************/
	private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
		if (newDataAvailable) {
	        newList = (List<OrderItem>) trigger.new;
	        newMap = (Map<Id, OrderItem>) trigger.newMap;
		}
	    if (oldDataAvailable) {
	        oldList = (List<OrderItem>) trigger.old;
	        oldMap = (Map<Id, OrderItem>) trigger.oldMap;
	    }
	} //*** end of "getData"
	
	/****************************************************************************************************
	        Method for event
	****************************************************************************************************/
	private void onBeforeUpdate() {
		
		//This is a custom setting for order max upload
    	//Avoid the orderItem triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
	    getData(true, true);
	    //Prevent modification to some fields at some Status
	    OrderItem_Svc.preventModification(newMap,oldMap);
	}
	
	private void onBeforeDelete() {
		
		//This is a custom setting for order max upload
    	//Avoid the orderItem triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
	    getData(false, true);
	    //Prevent Order item deletion at some Status
	    OrderItem_Svc.preventDeletion(oldList);
	}

    private void onAfterUpdate() {
		if (System.isFuture() == true) {
			return;
		}

    	//This is a custom setting for order max upload
    	//Avoid the orderItem triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
    	
        getData(true, true);

        //*** set order to paid if all order items are paid
        OrderItem_Svc.setOrderToPaid(newList, oldList);
        
	    //Update Product Access based on Paid Flag of the OrderItem
	    new IECProductAccess_Svc().ActivateProductAccessForPaidOrderItems(newList, oldMap);

		// Ecommerce Enhancements R2
		OrderItem_Svc.setOrderItemAcceptedPaymentMethods(newList, null);
    }

    private void onAfterInsert() {
		if (System.isFuture() == true) {
			return;
		}
    	
    	//This is a custom setting for order max upload
    	//Avoid the orderItem triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
    	
        getData(true, false);

        //*** set order to paid if all order items are paid
        OrderItem_Svc.setOrderToPaid(newList, null);
        
	    //Update Product Access based on Paid Flag of the OrderItem
	    new IECProductAccess_Svc().ActivateProductAccessForPaidOrderItems(newList, null);

		// Ecommerce Enhancements R2
		OrderItem_Svc.setOrderItemAcceptedPaymentMethods(newList, null);
    }
}
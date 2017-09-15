/****************************************************************************************************
    Created by Kevin Ky 2015-09-23
    
****************************************************************************************************/
public without sharing class Order_Dom {
    
    /****************************************************************************************************
            Call trigger method corresponding to trigger event
    ****************************************************************************************************/
    public static void triggerHandler() {
        //*** instantiate the domain class to prevent too many static methods
        Order_Dom exe = new Order_Dom();
        
        //*** call handler method corresponding to trigger event
        if (trigger.isBefore) {
                 /*if (trigger.isInsert) exe.onBeforeInsert();
            else if (trigger.isUpdate) exe.onBeforeUpdate();*/
            if(trigger.isUpdate) exe.onBeforeUpdate();
            else if (trigger.isDelete) exe.onBeforeDelete();
        } else if (trigger.isAfter) {
            if (trigger.isInsert) exe.onAfterInsert();
            else if (trigger.isUpdate) exe.onAfterUpdate();
            else if (trigger.isDelete) exe.onAfterDelete();
        }
    } //*** end of "triggerHandler"
    
    
    /****************************************************************************************************
            Data variables
    ****************************************************************************************************/
    private List<Order> newList = new List<Order>();
    private List<Order> oldList = new List<Order>();
    private Map<Id, Order> newMap = new Map<Id, Order>();
    private Map<Id, Order> oldMap = new Map<Id, Order>();
    
    /****************************************************************************************************
            Set trigger data to data variables
    ****************************************************************************************************/
    private void getData(Boolean newDataAvailable, Boolean oldDataAvailable) {
        if (newDataAvailable) {
            newList = (List<Order>) trigger.new;
            newMap = (Map<Id, Order>) trigger.newMap;
        }
        if (oldDataAvailable) {
            oldList = (List<Order>) trigger.old;
            oldMap = (Map<Id, Order>) trigger.oldMap;
        }
    } //*** end of "getData"
    
    /****************************************************************************************************
            Method for event
    ****************************************************************************************************/
    private void onBeforeUpdate() {
    	
    	//This is a custom setting for order max upload
    	//Avoid the order triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
        getData(true, true);
        //Prevent modification to some fields at some Status
        Order_Svc.preventModification(newMap,oldMap);

        // Ecommerce Enhancements R2 
        Order_Svc.setOrderAcceptedPaymentMethods(newList, oldMap);
    }

    private void onBeforeDelete() {
    	
    	//This is a custom setting for order max upload
    	//Avoid the order triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
        getData(false, true);
        //Prevent Order deletion at some Status
        Order_Svc.preventDeletion(oldList);
    }

    private void onAfterInsert() {
        //getData(true, true);
    }

    private void onAfterUpdate() {
    	
    	//This is a custom setting for order max upload
    	//Avoid the order triggers to fire when mass upload Orders
    	if (Utility.getNumericSetting('Execute Order Trigger for mass upload') != 1) return;
    	
        getData(true, true);

        //*** set order items to paid if order is paid
        Order_Svc.setOrderItemToPaid(newList, oldList);

        //Email notification when the Order is sold
        Order_Svc.sendEmailWhenOrderIsSold(newMap, oldMap);

        //Email notification when the Order is Payment Error
        Order_Svc.sendEmailWhenPaymentDeclined(newMap, oldMap);
        
        //-- Call SAP SalesOrder Interface if status become Ready for SAP or PAID
        Order_Sel orderSelector = new Order_Sel(); 
        Set<Id> orderIds = orderSelector.findOrders4SAP(newList, oldList);
        if(orderIds.size() > 0)
        {
            System.enqueueJob(new SapSalesOrContractOrders_Queueable(orderIds));
            //System.enqueueJob(new IEC_ContractOrdersQueueable(orderIds));  //*** failed with error "Too many async calls created" from batch
        }
        
        // Activate product access for paid orders
        new IECProductAccess_Svc().ActivateProductAccessForPaidOrders(newList, oldMap);

        //Update IEC Event Subscription for Event renewal
        Order_Svc.updateEventSubcriptions(newList, oldMap);

        //Update iec sap invoice status (Zuora Ready) when order is Payment Confirmed INC295559
        Order_Svc.sapInvoiceStatusUpdate(newMap, oldMap);
    }

    private void onAfterDelete() {
        //getData(true, true);
    }

    /*private Set<Id> findOrders4SAP()
    {
        Set<Id> orderIds = new Set<Id>();
        for(Integer x=0; x < newList.size(); x++)
        {
            Order newOrd = newList[x];
            Order oldOrd = oldList[x]; 

            if((newOrd.Status != oldOrd.Status) && (newOrd.Status == IECConstants.ORDER_STATUS_READY_FOR_SAP || newOrd.Status == IECConstants.ORDER_STATUS_PAID))
            {
                orderIds.add(newOrd.Id);
            }
        }

        return orderIds;
    }*/

}
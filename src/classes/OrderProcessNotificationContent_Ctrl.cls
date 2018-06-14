public class OrderProcessNotificationContent_Ctrl {

    // Component attributes
    public Id idOrder                   {get;set;}

    // Display variables
    public String sContactName          {get;set;}
    public String sAccountName          {get;set;}
    public String sEmail                {get;set;}
    public String sOrderNumber          {get;set;}
    public String paymentTypeMsg        {get;set;}
    public Order ord{get;set;}
    public Boolean hasSetupFee          {get;set;}

    public List<OrderItem> getOrderItems(){
        // Order ID is required
        if (idOrder == null) return null;
        
        // First get the Order Header
        List<Order> lstOrder = Order_Sel.getOrdersById(new Set<Id> { idOrder });
        
        if (!lstOrder.isEmpty()) {
            ord = lstOrder[0];
            sContactName = lstOrder[0].BillToContact_Name__c;
            sAccountName = lstOrder[0].BillToAccount_Name__c;
            sEmail = lstOrder[0].BillToContact_Email__c;
            sOrderNumber = lstOrder[0].OrderNumber;

            //set the payment method message
            paymentTypeMsg = '';
            //Bank transfert message
            if(lstOrder[0].Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer){ paymentTypeMsg = 'Once we receive your wire transfer,'; }
            //Check message
            if(lstOrder[0].Payment_Type__c == IECConstants.ORDER_STATUS_CHECK){ paymentTypeMsg = 'Once we receive your check payment,'; }
        }
        
        // Now query the order items, either based on the OrderId, or on the OrderItemId if available.
        List<OrderItem> lstOrderItem = new List<OrderItem>();

        Map<Id, List<OrderItem>> mapOrderId_OrderItem = new OrderItem_Sel().getOrderItems(new Set<Id> { idOrder });
            
        if (mapOrderId_OrderItem.containsKey(idOrder)) {
            lstOrderItem.addAll(mapOrderId_OrderItem.get(idOrder));
        }

        //verified if the orderItems contain a setup fee
        hasSetupFee = false;
        for (OrderItem oi : lstOrderItem){
            if (oi.Setup_Fee__c != null && oi.Setup_Fee__c > 0){
                hasSetupFee = true;
                break;
            }
        }
        
        return lstOrderItem;
    }

}
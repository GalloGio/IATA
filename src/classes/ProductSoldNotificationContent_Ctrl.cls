public class ProductSoldNotificationContent_Ctrl {
    // Component attributes
    public Id idOrder                   {get;set;}
    public Id idOrderItem               {get;set;}

    // Display variables
    public String sContactName          {get;set;}
    public String sAccountName          {get;set;}
    public String sEmail                {get;set;}
    public String sOrderNumber          {get;set;}
    public String paymentTypeMsg        {get;set;}
    public Boolean containsWebDownload  {get;set;}
    public Boolean hasSetupFee          {get;set;}
    public Decimal discountedAmount     {get;set;}
    public Decimal totalAmount          {get;set;}
    public Order ord                    {get;set;}

    public String sBaseUrl {
        get {
            return IEC_Settings__c.getOrgDefaults().IEC_User_Portal_URL__c;
            }
    }


    public List<OrderItem> getOrderItems(){
        // Order ID is required
        if (idOrder == null) return null;
        
        // First get the Order Header
        List<Order> lstOrder = Order_Sel.getOrdersById(new Set<Id> { idOrder });
        
        if (!lstOrder.isEmpty()) {
            sContactName = lstOrder[0].BillToContact_Name__c;
            sAccountName = lstOrder[0].BillToAccount_Name__c;
            sEmail = lstOrder[0].BillToContact_Email__c;
            sOrderNumber = lstOrder[0].OrderNumber;
            discountedAmount = lstOrder[0].Discount_Amount__c;
            totalAmount = lstOrder[0].Total_Amount__c;
            ord = lstOrder[0];

            //set the payment method message
            if(lstOrder[0].Payment_Type__c == IECConstants.PaymentThresholdType_CreditCard){
                //Credit card message
                paymentTypeMsg = Label.Credit_card_payment_msg;
            }else if(lstOrder[0].Payment_Type__c == IECConstants.PaymentThresholdType_ICH){
                //ICH message
                paymentTypeMsg = Label.ICH_payment_processed_msg;
            }
            else if(lstOrder[0].Payment_Type__c == IECConstants.PaymentThresholdType_BankTransfer){
                //Bank transfert message
                paymentTypeMsg = Label.wire_transfer_payment_msg;
            }else if(lstOrder[0].Payment_Type__c == IECConstants.ORDER_STATUS_CHECK){
                //Check message
                paymentTypeMsg = Label.Check_payment_msg;
            }else{
                paymentTypeMsg = '';
            }
        }
        
        // Now query the order items, either based on the OrderId, or on the OrderItemId if available.
        List<OrderItem> lstOrderItem = new List<OrderItem>();

        if (idOrderItem == null) {
            Map<Id, List<OrderItem>> mapOrderId_OrderItem = new OrderItem_Sel().getOrderItems(new Set<Id> { idOrder });
            
            if (mapOrderId_OrderItem.containsKey(idOrder)) {
                lstOrderItem.addAll(mapOrderId_OrderItem.get(idOrder));
            }
        }
        else {
            Map<Id, OrderItem> mapOrderItemById = new OrderItem_Sel().getOrderItemsById(new set<Id> {idOrderItem});
            
            if (mapOrderItemById.containsKey(idOrderItem)) {
                lstOrderItem.add(mapOrderItemById.get(idOrderItem));
            }
        }

        //verified if the orderItems contain a downloadable item
        containsWebDownload = false;
        for(OrderItem oi : lstOrderItem){
            if(oi.Is_Web_Download__c){
                containsWebDownload = true;
                break;
            }
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
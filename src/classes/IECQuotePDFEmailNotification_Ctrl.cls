public class IECQuotePDFEmailNotification_Ctrl
{    
    public Id orderId{ get; set; }
     
    public Order_DTO vfQuote {
        get {
            Order_DTO o = new Order_DTO(); 
            Order_Sel oSelector = new Order_Sel(); 
            List<Order> orderList;
            Order order = new Order();
            Order sfQuote = new Order();
            Order_DTO vfQuote = new Order_DTO();
            
            if (orderId == null) {
                return null;
            }
            
            orderList = Order_Sel.getOrdersById(new Set<Id> { orderId });
            
            if (orderList != null && orderList.isEmpty() == false)
                order = orderList[0];
                
            if (order != null) {
                Id idContact = order.BillToContactId;
                String quoteNumber = order.OrderNumber;
                    
                sfQuote = oSelector.getCustomerQuoteDetails(idContact, quoteNumber);
                if(sfQuote != null)
                    vfQuote = new Order_DTO(sfQuote);
            }
            
           return vfQuote;    
       }
   }  
}
//Product sold manager email notification
public without sharing class ProductSoldManagerNotification_Ctrl {
	// Component attributes
	public Id idOrder						{get;set;}
	public Id idOrderItem					{get;set;}

	public String sOrderNumber				{get;set;}
	public String productName				{get;set;}
	public Integer qty 						{get;set;}

	//Get the order object
	public Order getOrder(){
		Order order = new Order();

		if(idOrder != null){
			List<Order> orders = Order_Sel.getOrdersById(new set<Id>{idOrder});
			if(orders != null){
				order = orders[0];
			}
		}

		return order;
	}

	//get the OrderItem object
	public OrderItem getOrderItem(){
		qty = 0;
		OrderItem orderItem = new OrderItem();
		List<OrderItem> lstOrderItem = new OrderItem_Sel().getOrdItemsById(new set<Id>{idOrderItem});

		if(lstOrderItem != null && lstOrderItem.size() > 0){
			orderItem = lstOrderItem[0];
			qty = Integer.valueOf(orderItem.Quantity);
		}

		return orderItem;
	}

}

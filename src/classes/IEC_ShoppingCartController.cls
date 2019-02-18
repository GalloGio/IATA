/******************************************************************************************************************
 *  IEC_ShoppingCartController: IEC_ShoppingCart page Controller                                                  *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
public without sharing class IEC_ShoppingCartController extends IEC_PageController
{
	//Page parameters
    public Map<String, String> pageParams;

    //Page Labels 
    public Map<String, String> labels { get; set; }

	//VF Order to display 
	public Order_DTO vfOrder{get;set;}
	private String orderId;
	public Boolean isCartEmpty{get{
		return 	vfOrder.orderItems == null || vfOrder.orderItems.size() == 0; 
	}set;}

	public Boolean bAreProductsCompliant { get; set; }


	public String cartProducts {get;set;}


	/**************************************************************************************************************
     *  IEC_ShoppingCartController: Class Constructor                                                             *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public IEC_ShoppingCartController() 
	{
		//Fetch Page params 
		pageParams = ApexPages.currentPage().getParameters();

		//Labels
		labels = Utility.buildMapFromString(Label.Labels_IECViewCart, '\n', ':');
	}

	/**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
	{
		Order_Sel oSelector = new Order_Sel();
		OrderItem_Sel oiSelector = new OrderItem_Sel();

		//*** check/initialize default locations -> error will be checked in the checkout flow
		if (loggedCustomer != null && (loggedCustomer.sfContact.BillTo_Location__c == null || loggedCustomer.sfContact.ShipTo_Location__c == null))
			Location_Svc.initializeDefaultLocations(new List<Id>{loggedCustomer.sfContact.Id});

		if(pageParams.containsKey('order')){			
			String orderNumber = pageParams.get('order');			
			//orderId = pageParams.get('order');

			//-- Customer come from Auto-Renewal link 
			if(loggedCustomer == null){
				return this.redirectToPage('/IEC_Login?returl=/IEC_ShoppingCart?order=' + orderNumber);
			} 

			//--Validate customer has access to the order
			//-- Change pendding Order to renewal 
			List<Order> lstOrders = (List<Order>) new Order_Sel().selectSObjectByField('OrderNumber',new Set<String>{orderNumber});			
			if(lstOrders.size() > 0){
				orderId = lstOrders[0].Id;
                Order_Svc.getSAP_Freight_Tax(orderId);  //*** re-calculate shipping and tax
	        	if(lstOrders[0].Type != 'Cart')
	        		IECOrder_Svc.changePenddingOrder(lstOrders[0]);
	        	
				//-- Replace cookie content with renewal items 
				if (newShoppingCart == false) {
					List<OrderItem> orderItems = oiSelector.getOrderItems(orderId);
					refreshCookieContent(orderItems, true);
				} else {
					// new shopping cart by default when logged in serializes in order items as soon as items are added.

					buildOrderItemFromCookie();
				}

			}
		}
		else if(loggedCustomer != null)
		{
			//-- Find pending order/orderItems Of the customer
			if (newShoppingCart == false) {
				Order pendingOrder = IECOrder_Svc.getPenddingOrder(true); // oSelector.getPenddingOrder(loggedCustomer.sfUser.Id);
				List<OrderItem> pendingOrderItems = oiSelector.getOrderItems(pendingOrder.Id);
				refreshCookieContent(pendingOrderItems, false);//@todo: revalidate
				orderId = pendingOrder.Id;
			} else {
				// new shopping cart by default when logged in serializes in order items as soon as items are added.
				Order pendingOrder = storeCart.getCartOrder();
				orderId = pendingOrder.Id;

				buildOrderItemFromCookie();
			}

			//-- Calculate tax/shipping
			
			Order_Svc.getSAP_Freight_Tax(orderId);  //*** re-calculate shipping and tax
		}

		//Verified if the cart already have a time-based subscription or sibling In Cart
		if(pageParams.containsKey('msg')){
			String errorType = pageParams.get('msg');
			addErrorMessage((errorType == 'siblingInCart') ? Label.Itemalready_in_cart : Label.Only_one_subscription_can_be_purchased);
		}

		//-- Build Cart Items to display
		buildOrderItemFromCookie();

		//-- Customer was forced to login when click on proceed to checkout button
		//1-->ADDED TO: 
		if(pageParams.get('action') == 'checkout'){
		 return startCheckout();
		}

		//-- Validate country compliance 
		validateCountryCompliance();
		if (! bAreProductsCompliant){
			return null;
		} 
		//addErrorMessage(labels.get('msgErrorCartNotCompliant'));
		
		//-- Customer was forced to login when click on proceed to checkout button
		//1--> REMOVED FROM: if(pageParams.get('action') == 'checkout') return startCheckout();	
		

		//-- Existing product added again  ?
		String prdAlreadyExist = ApexPages.currentPage().getParameters().get('productNumber');
		for (OrderItem_DTO oi : vfOrder.orderItems)
		    if(prdAlreadyExist != null && oi.productCode == prdAlreadyExist) addConfirmMessage(String.format(Label.Item_already_in_your_cart, new List<String>{oi.productName}));

		return null;
	}

	/**************************************************************************************************************
     *  removeProduct: method calls customer clicks on "Remove" product Icon                                      *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference removeProduct()
	{	
		String productCode = ApexPages.currentPage().getParameters().get('productCode');

		try{
			if (newShoppingCart == false) {
				//-- Remove product from Cookie 
				IECOrder_Svc.deleteProductToCookie(productCode);

				//-- If user logged-in remove product in pendding cart 
		        if(loggedCustomer != null)
				{
					List<OrderItem> orderItems2delete = new List<OrderItem>();

					//-- Update OrderItem in Database
					Order pendingOrder =  IECOrder_Svc.getPenddingOrder(true);

					//-- Find OrderItems of pendingOrder with ProductOCde in items.keySet()
					Map<Id, List<OrderItem>> mapOrderItems =  new OrderItem_Sel().getOrderItems(new Set<Id>{pendingOrder.Id});
					if(mapOrderItems != null && mapOrderItems.size() > 0)
					{
						List<OrderItem> items = mapOrderItems.get(pendingOrder.Id);
						for(OrderItem item : items)
							if(productCode == item.Product_Number__c)
								orderItems2delete.add(item);
					}

					if(orderItems2delete.size() > 0) delete orderItems2delete;
				}	
			
				//-- Build Cart Items to display
				buildOrderItemFromCookie();
			} else {
				storeCart.deleteItem(productCode);
				//susana alves INC332088
				//verify if the order don't have related order items
				Order orderToDelete = storeCart.getCartOrderContent(); 
				if(orderToDelete != null){
					system.debug('orderToDelete : ' + orderToDelete);
					Boolean canDeleteOrder = !([SELECT count() FROM OrderItem WHERE OrderId = :orderToDelete.Id] > 0);
					system.debug('canDeleteOrder? : ' + canDeleteOrder);
					if(canDeleteOrder){
						// the order don't have related products, so can be deleted
						system.debug('empty order on the cart to be deleted : ' + storeCart.getCartOrderContent());
						IECOrder_Svc.deleteOrder(storeCart.getCartOrderContent());
					}
				}
				buildOrderItemFromCookie();
			}

			validateCountryCompliance();
			if (! bAreProductsCompliant){
				return null;
			} 

			addConfirmMessage('Product ' + productCode + ' has been successfully removed.');
			return null;

		}
		catch(Exception ex){addErrorMessage(ex.getMessage()); return null;}			
	}

	/**************************************************************************************************************
     *  updateProductQuantity: method calls when customer clicks on "update" link in his cart 	  				  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference updateProductQuantity()
	{
		String productCode = ApexPages.currentPage().getParameters().get('productCode');
		String quantity = ApexPages.currentPage().getParameters().get('quantity');

		try
		{
			if (newShoppingCart == false) {
				if(Decimal.valueOf(quantity) > 0) IECOrder_Svc.modifiedProductToCookie(productCode, Decimal.valueOf(quantity));
				else IECOrder_Svc.deleteProductToCookie(productCode);

				buildOrderItemFromCookie();

				if(loggedCustomer != null) updateOrderItems();
			} else {
				storeCart.updateItem(productCode, Decimal.valueOf(quantity), null);
				
				buildOrderItemFromCookie();

				if(loggedCustomer != null) updateOrderItems();
			}

			validateCountryCompliance();
			if (! bAreProductsCompliant){
				return null;
			} 

			addConfirmMessage('Quantity has been successfully updated.');

			return null;
		}	
		catch(Exception ex){addErrorMessage(ex.getMessage()); return null;}

	}

	/**************************************************************************************************************
     *  continueShopping: method calls when customer clicks on "Continue Shopping" button             			  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference continueShopping()
	{
		if (! bAreProductsCompliant) 
		{
			addErrorMessage(labels.get('msgErrorCartNotCompliant'));
			return null;
		}

		PageReference catalogPage =  new PageReference('/IEC_ProductList');
        	catalogPage.setRedirect(true);
        return catalogPage;
	}

    public void updateOrderItems()
    {

    	Map<String, Decimal> itemsInCookie = Order_Svc.getItemsInCookie();

    	List<OrderItem> orderItems2update = new List<OrderItem>();
		//-- Update OrderItem in Database
		Order pendingOrder =  IECOrder_Svc.getPenddingOrder(orderId);
		//-- Find OrderItems of pendingOrder with ProductOCde in items.keySet()
		Map<Id, List<OrderItem>> mapOrderItems =  new OrderItem_Sel().getOrderItems(new Set<Id>{pendingOrder.Id});


		if(mapOrderItems != null && mapOrderItems.size() > 0)
		{
			List<OrderItem> items = mapOrderItems.get(pendingOrder.Id);
			for(OrderItem item : items)
			{
				if(itemsInCookie.keySet().contains(item.Product_Number__c)){	
					item.Quantity = (item.IEC_Static_Cart_Quantity__c != null && item.IEC_Static_Cart_Quantity__c > 0) ? item.IEC_Static_Cart_Quantity__c :	itemsInCookie.get(item.Product_Number__c);					
					orderItems2update.add(item);
				}
			}				
		}


		if(orderItems2update.size() > 0) update orderItems2update;
    }

    /**************************************************************************************************************
     *  upsertOrderItemsFromVfOrder: method called to insert item in the vfOrder, needed when the user adds items *
     *                               to cart before login                                                         *
     *  Author: Ângela Lázaro                                                                                     *  
     **************************************************************************************************************/
    public void insertOrderItemsFromVfOrder(){

		List<OrderItem> orderItems2upsert = new List<OrderItem>();

		Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();

		for (OrderItem_DTO oi : vfOrder.orderItems){
			Map<Id, PricebookEntry> pricebookEntryByProductId = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, oi.ProductId);

           	orderItems2upsert.add(new OrderItem(OrderId = orderId, Freight_Charge__c=oi.shippingAmount, Handling_charges__c=oi.handlingCharges,
           						 Tax__c=oi.taxAmount, UnitPrice = oi.UnitPrice, PricebookEntryId = pricebookEntryByProductId.get(oi.ProductId).Id, Quantity = oi.Quantity));
        }

        if(orderItems2upsert.size() > 0){
        	insert orderItems2upsert;
        }


	}

    /**************************************************************************************************************
     *  startCheckout: method calls when customer clicks on "Proceed to checkout" button                          *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference startCheckout()
	{
		//-- Validate Customer is logged-in 
		if(loggedCustomer == null)
		{
			//-- redirect to login 
			PageReference pgRef = new PageReference('/IEC_Login?returl=/IEC_ShoppingCart?action=checkout');
				pgRef.setRedirect(true);
        	return pgRef;
		}


		//-- Validate all product in cart are compliant 
		validateCountryCompliance();
		if(!bAreProductsCompliant)
		{
			//addErrorMessage(labels.get('msgErrorCartNotCompliant'));
			return null;
		}

		if (newShoppingCart == false) {
			//-- Update Database with cookie info
			updateOrderItems();

			//-- Insert items with vfOrder items, in case there is any
			insertOrderItemsFromVfOrder();
		}

		//-- Get Tax & Shipping 
		Order_Svc.getSAP_Freight_Tax(orderId);

		if (newShoppingCart == false) {
			IECOrder_Svc.createOrderFromCookie();
		}

		PageReference ref = new PageReference('/IEC_CustomerInformation');

		ref.setRedirect(true);

	    return ref;
	}

	/**************************************************************************************************************
     *  validateCountryCompliance: method to validate if all the products in the cart are country compliant       *
     *  Author: David Daboué  - Samy Saied                                                                        *  
     **************************************************************************************************************/
	public void validateCountryCompliance()
	{
		List<Id> productIds = new List<Id>();
		for(OrderItem_DTO oi : vfOrder.orderItems)
			productIds.add(oi.productId);


		Set<String> countryCodes = new Set<String>();
	    	
		if(loggedCustomer != null)
		{
			if (!String.isBlank(loggedCustomer.sfContact.BillTo_Location__r.ISO_Country_Code__c)) countryCodes.add(loggedCustomer.sfContact.BillTo_Location__r.ISO_Country_Code__c);
			if (!String.isBlank(loggedCustomer.sfContact.ShipTo_Location__r.ISO_Country_Code__c)) countryCodes.add(loggedCustomer.sfContact.ShipTo_Location__r.ISO_Country_Code__c);
		}

		Map<Id, Boolean> mapProduct2Id_Compliance = Product_Svc.IsProductAndCountryCompliant(productIds, countryCodes);

		bAreProductsCompliant = true;
        
        if (!mapProduct2Id_Compliance.isEmpty()) 
        {
        	for (Id idProduct : mapProduct2Id_Compliance.keySet()) 
        	{
        		for (OrderItem_DTO oi : vfOrder.orderItems) 
        		{
        			if (idProduct == oi.productId) {
		        		// If product is compliant, then move to the next one
		        		if (mapProduct2Id_Compliance.get(idProduct)) {
		        			oi.IsCompliant = true;
		        		}
	        			else {
	        				oi.IsCompliant = false;
	        				bAreProductsCompliant = false;
	        				addErrorMessage(String.format(labels.get('msgErrorProductNotCompliant'), new String[]{oi.productName, oi.productCode}));
	        			}
						break;
        			}
        		}
        	}
		}
	}

	/**************************************************************************************************************
     *  refreshCookieContent: method calls to refresh the cookie containing the cart data with database data 	  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public void refreshCookieContent(List<OrderItem> orderItems, Boolean overideCookieContent)
	{
		String cookie_Sync = IECOrder_Svc.readCookie('Cookie_Sync');
		if(overideCookieContent)
		{
			//-- Replace cookie content with OrderItems
			IECOrder_Svc.deleteAllCookies();

			for(OrderItem oi : orderItems) 
				IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
			
		}
		else if(cookie_Sync != 'true')
		{
			//-- Add OrderItems to Cookie if not synched yet 
			Map<String, Decimal> cookieContent =  IECOrder_Svc.getItemsInCookie();

			for(OrderItem oi : orderItems)
			{
				//-- Product already in cookie 
				if(cookieContent.containsKey(oi.Product_Number__c)) IECOrder_Svc.modifiedProductToCookie(oi.Product_Number__c, cookieContent.get(oi.Product_Number__c));
				
				//-- New product 
				else IECOrder_Svc.addProductToCookie(oi.Product_Number__c, oi.Quantity, true);
			}
				
			
			//-- Create Cookie_Sync entry
			Cookie c = new Cookie('Cookie_Sync','true', null, Utility.getIntegerSetting('IEC Order Cookie maxAge'), false);
			ApexPages.currentPage().setCookies(new Cookie[]{c});
		}		
	}

	/**************************************************************************************************************
     *  buildOrderItemFromCookie: method to build OrderItem_DTO data from cookie content 						  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public void buildOrderItemFromCookie()
	{
		if(vfOrder == null) vfOrder = new Order_DTO();

		if (newShoppingCart == false) {
			vfOrder.orderItems = IECOrder_Svc.getOrderItemsInCookie();
		} else {
			vfOrder.orderItems = storeCart.getOrderItems();
		}


		cartProducts = '';
		if(vfOrder.orderItems != null && !vfOrder.orderItems.isEmpty()){
			List<String> lstProductNames = new List<String>();
			for(OrderItem_DTO orderItemAux : vfOrder.orderItems){
				lstProductNames.add(orderItemAux.productName);
			}
			cartProducts = String.join( lstProductNames,' - ');
		}

		cartProducts = JSON.serialize(cartProducts);
	}


}
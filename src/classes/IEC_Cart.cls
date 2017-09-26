/**

		Project: eCommerce Enhancements
	       File: IEC_Cart.cls
	Description: Cart Management for Online Store.
	     Author: blue-infinity sa
	    History: aosantos, 2017-06-20, Initial Release.

	Detailed description:

		The cart is organized internally as a Map of Cart Items, indexed by the
	Product Number (Product2.SAP_Material_Number__c).

		When the addItem() is invoked, if the product with Product Number is already present
	then the quantity of the existing Cart Item will be incremented by the quantity of the
	item being added. If the Product Number is not yet present, then the item is added
	to the cart with the specified quantity.

		The deleteItem() will delete the Cart Item indexed by the Product Number.

		The updateItem() will update the Cart Item indexed by Product Number to the specified
	values.

		When logging in the eCommerce application, the loginUserEvent() must be called so
	that the cart is validated with the type of customer logged in and only the product the
	customer has access are retained in the cart. At this point in time the cart will be
	managed and stored in the order items linked with the most recent order that is of the
	user and with type "Cart". Before logging in the Cart is mantained by means of a set of
	cookie entries managed by the IEC_CookieStore class.

		When an order is checked out and confirmed for payment the method submitEvent()
	from the cart will be called, effectively destroying the existing in-memory cart and
	corresponding cookies if any available.

	In this implementation the content stored in the cookie store has the following format:
			<productNumber>;<quantity>;<coupon>#<productNumber>;<quantity>;<coupon>...

    Sample usage:

		IEC_Cart cartInstance = IEC_Cart.getInstance();

		cartInstance.storeCart(); 		// store cart in database if user is logged in, else store in cookies.

		cartInstance.retrieveCart();	// retrieve cart from database if user is logged in, else retrieve from cookies.

		cartInstance.loginUserEvent();	// transition a user from not logged in to logged in appending the database cart to the current cart.
		
		cartInstance.submitEvent();		// when user submits order, event that is called, clearing the cart items and cookies.

		List<IEC_Cart.CartItem> cartItems = cartInstance.getCartContent();	// get current cart content.
		
		cartInstance.addItem(productNumber, quantity, coupon);				// add a new cart item to current cart.

		cartInstance.updateItem(productNumber, quantity, coupon);			// update the cart item with a new quantity + coupon.
		
		cartInstance.deleteItem(productNumber);								// remove the cart item.
		
*/
public without sharing virtual class IEC_Cart {
	private static IEC_Cart cartInstance;

	@testVisible
	private IEC_CookieStore cookieStore;

	@testVisible
	private Customer_DTO loggedCustomer;

	private static Map<Id,String> productNumberMap;
	private static Map<String,String> productNameMap;
	private static Map<Id,String> productRatePlanInformationProductNumberMap;
	private static Map<Id,Id> productRatePlanInformationSwapMap;
	private static Map<String,Set<String>> productAccessMap;
	private static Map<String,Product2> productMap;
	private static Map<String,EComProduct_DTO> ecomProductByProductNumberMap;
	private static Map<Id,PricebookEntry> pricebookEntryMap;
	private static Pricebook2 standardPricebook;
	private static Order pendingOrder;

	// Static Initializer
	static {
		staticInitializer();
	}

	/**
		Initialize Static Map with Product Name.

	*/
	private static void staticInitializer() {
		Pricebook_Sel pricebookSelector = new Pricebook_Sel();

		productNumberMap = new Map<Id,String>();
		productNameMap = new Map<String,String>();
		productRatePlanInformationProductNumberMap = new Map<Id,String>();
		productRatePlanInformationSwapMap = new Map<Id,Id>();
		productAccessMap = new Map<String,Set<String>>();
		ecomProductByProductNumberMap = new Map<String,EComProduct_DTO>();
		productMap = new Map<String,Product2>();
		pricebookEntryMap = new Map<Id,PricebookEntry>();

		standardPricebook = pricebookSelector.getStandardPriceBook();

		for (EComProduct_DTO ecomProduct : Product_Sel.getEComProduct(null, false, null, null, false)) {
			ecomProductByProductNumberMap.put(ecomProduct.ProductNumber, ecomProduct);
		}

		for (PricebookEntry pricebookEntry : [SELECT Id, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Pricebook2Id = :standardPricebook.Id]) {
			pricebookEntryMap.put(pricebookEntry.Product2Id, pricebookEntry);
		}

		for (
			Product2 product : [
				SELECT
					Id,
					Name,
					Restricted_Customer_Type__c,
					IEC_Product_Rate_Plan_Information__c,
					SAP_Material_Number__c
				FROM
					Product2
				WHERE
					SAP_Material_Number__c != NULL
			]
		) {
			Set<String> customerTypeSet = new Set<String>();

			productMap.put(product.SAP_Material_Number__c, product);
			productNumberMap.put(product.Id, product.SAP_Material_Number__c);
			productNameMap.put(product.SAP_Material_Number__c, product.Name);
			productRatePlanInformationProductNumberMap.put(product.IEC_Product_Rate_Plan_Information__c, product.SAP_Material_Number__c);

			if (
				product.Restricted_Customer_Type__c == null
				||
				product.Restricted_Customer_Type__c != null && product.Restricted_Customer_Type__c == ''
			) {
				customerTypeSet.add(null);
			} else {
				String[] customerTypes = product.Restricted_Customer_Type__c.split(';');

				for (String customerType : customerTypes) {
					customerTypeSet.add(customerType);
				}
			}

			productAccessMap.put(product.SAP_Material_Number__c, customerTypeSet);
		}

		for (
			Swap_Configuration__c swap : [
				SELECT
					Id,
					Name,
					Relationship_Type__c,
					Source_Product_Rate_Plan_Information__c,
					Target_Product_Rate_Plan_Information__c
				FROM
					Swap_Configuration__c
				WHERE
					Relationship_Type__c = 'Swap'
			]
		) {
			productRatePlanInformationSwapMap.put(swap.Source_Product_Rate_Plan_Information__c, swap.Target_Product_Rate_Plan_Information__c);
		}
	}

	/**
		Representation of a Cart Item.

	*/
	public class CartItem {
		public Id       id              { get; set; }

		public String	productNumber 	{ get; set; }

		public String 	productName 	{
			get {
				return IEC_Cart.getProductName(productNumber);
			}
		}

		public Decimal	quantity 		{ get; set; }

		public String	coupon 			{ get; set; }

		public CartItem(Id id, String productNumber, Decimal quantity, String coupon) {
			this.id = id;
			this.productNumber = productNumber;
			this.quantity = quantity;
			this.coupon = coupon;
		}
	}

	public class CartException extends Exception { }
	
	/** The map of Cart Items indexed by Product Number. */
	@testVisible
	private Map<String, CartItem> cartItemMap;

	private Order cartOrder;
	private List<OrderItem> cartOrderItems;

	//susana alves INC332088
	public Order getCartOrderContent(){
		return cartOrder;
	}

	protected IEC_Cart() {
		cartItemMap = new Map<String,CartItem>();

		cookieStore = new IEC_CookieStore(
			'IEC_CartStore',
			null,
			Utility.getIntegerSetting('IEC Order Cookie maxAge'),
			false
		);

		loggedCustomer = Customer_DTO.getLoggedCustomer();
	}

	/**
		Get the Instance of the Cart.

	*/
	public static IEC_Cart getInstance() {
		if (cartInstance == null) {
			cartInstance = new IEC_Cart();

			cartInstance.retrieveCart();
		}

		return cartInstance;
	}

	/**
		Get the Serialization String for a Cart Item.

	*/
	@testVisible
	private static String serializeCartItem(CartItem cartItem) {
		return serializeString(cartItem.productNumber) + ';' + serializeDecimal(cartItem.quantity) + ';' + serializeString(cartItem.coupon);
	}

	@testVisible
	private static String serializeString(String str) {
		String result = null;

		if (str != null && str != '') {
			result = str;
		}

		return result;
	}

	@testVisible
	private static String serializeDecimal(Decimal dec) {
		String result = null;

		if (dec != null) {
			result = String.valueOf(dec);
		}

		return result;
	}

	/**
		Get the Cart Item from a previously Serialized Instance.

	*/
	@testVisible
	private static CartItem deserializeCartItem(String serializedString) {
		CartItem cartItem;

		String[] fields;

		if (serializedString != null && serializedString.length() != 0) {
			fields = serializedString.split(';');

			if (fields.size() == 3) {
				String productNumber = fields[0];
				String quantity = fields[1];
				String coupon = fields[2];

				if (productNumber == 'null' || productNumber == '') {
					productNumber = null;
				}

				if (quantity == 'null' || quantity == '') {
					quantity = null;
				}

				if (coupon == 'null' || coupon == '') {
					coupon = null;
				}

				cartItem = new CartItem(
					null,
					productNumber,
					quantity != null ? Decimal.valueOf(quantity) : null,
					coupon
				);
			} else {
				//throw new CartException('Error deserializing CartItem \'' + serializedString + '\'');
			}
		} else {
			cartItem = new CartItem(null, null, null, null);
		}

		return cartItem;
	}

	/**
		Serialize the Cart to Cookies.

	*/
	@testVisible
	private void serializeCartInCookies() {
		String content;
		List<String> contentItemList = new List<String>();

		System.debug('serializeCartInCookies start');

		for (CartItem cartItem : cartItemMap.values()) {
			contentItemList.add(serializeCartItem(cartItem));
		}

		content = String.join(contentItemList, '#');

		cookieStore.storeContent(content);

		System.debug('serializeCartInCookies end');
	}

	/**
		Switch to a new Pending Order.

	*/
	public void reloadOrder() {
		system.debug('aqui reloadOrder...');
		clearCartInCookies();
		retrieveCart();
	}

	/**
		Clear the entire Cart from Memory and Cookies.

	*/
	public void clearCart() {
		clearCartInCookies();
		cartItemMap.clear();
	}

	/**
		Clear the Cart stored in Cookies.

	*/
	@testVisible
	private void clearCartInCookies() {
		System.debug('clearCartInCookies start');

		cookieStore.clearContent();

		System.debug('clearCartInCookies end');
	}

	/**
		Deserialize the Cart from Cookies.

	*/
	@testVisible
	private void deserializeCartFromCookies() {
		String content = cookieStore.retrieveContent();

		System.debug('deserializeCartFromCookies start');

		System.debug('Cart Cookie Content: ' + content);

		cartItemMap.clear();

		if (content != null && content.length() != 0) {
			String[] items = content.split('#');

			if (items != null && items.isEmpty() == false) {
				for (String item : items) {
					CartItem cartItem = deserializeCartItem(item);

					System.debug('Cart Content Item ' + item + ', cartItem: ' + cartItem);

					if (cartItem != null) {
						cartItemMap.put(cartItem.productNumber, cartItem);
						
						System.debug('put the cartItem in the cartItemMap');
					}
				}
			}
		}

		System.debug('deserializeCartFromCookies end');
	}

	/**
		Store the Cart into Database if user is logged in.

	*/
	public void storeCart() {
		System.debug('storeCart start');

		if (isUserLoggedIn()) {
			System.debug('user is logged in, storing in database');

			// Store in Database
			cartOrder = getCartOrder();
			///////ADDED angielaz
			//cartOrderItems = getCartOrderItems();

			//INC339486
			//productSwap();
			//doProductSwap(cartOrderItems);
			//filterInacessibleProducts();

			saveOrderAndCartItemsToDatabase(cartOrder, getCartContent());
		} else {
			System.debug('user is not logged in, storing in cookies');

			// Store in Cookies
			serializeCartInCookies();
		}

		System.debug('storeCart end');
	}

	/**
		Reload the Cart from Database if user is logged in, if not,
        use the cookies stored on the browser.


	*/
	public void retrieveCart() {
		System.debug('retrieveCart start ' + isUserLoggedIn());

		if (isUserLoggedIn()) {
			// Master is Database
			System.debug('aqui cartItemMap retrieveCart() ' + cartItemMap);
			// clear current image in-memory
			cartItemMap.clear();

			cartOrder = getCartOrder();
			cartOrderItems = getCartOrderItems();
			System.debug('aqui cartOrder ' + cartOrder);
				System.debug('aqui cartOrderItems ' + cartOrderItems);

			for (OrderItem orderItem : cartOrderItems) {
				String productNumber;
				Decimal quantity;
				String coupon;
				CartItem cartItem;

				productNumber = orderItem.PricebookEntry.Product2.SAP_Material_Number__c;
				quantity = orderItem.Quantity;
				coupon = orderItem.Coupon__c;

				if (cartItemMap.containsKey(productNumber) == false) {
					cartItem = new CartItem(orderItem.Id, productNumber, quantity, coupon);

					cartItemMap.put(cartItem.productNumber, cartItem);
				} else {
					cartItem = cartItemMap.get(productNumber);

					cartItem.quantity += quantity;

					if (coupon != null && cartItem.coupon == null) {
						cartItem.coupon = coupon;
					}

					// If Item is multiple, remove the Id so that those multiple items are combined in a single item.
					cartItem.id = null;
				}
			}
			//INC339486
			//productSwap();
			//doProductSwap(cartOrderItems);
			//filterInacessibleProducts();
		} else {
			// Master is Cookies
			deserializeCartFromCookies();
		}

		System.debug('retrieveCart end');
	}

	/**
		When user is logged in, call this method to perform the needed logic to
		merge the database cart with the cookies. No changes are made in database,
        the new image of the cart is stored in cookies.

	*/
	public void loginUserEvent() {
		System.debug('loginUserEvent start');
		
		loggedCustomer = Customer_DTO.getLoggedCustomer();

		if (isUserLoggedIn()) {
			cartOrder = getCartOrder();
			cartOrderItems = getCartOrderItems();

			// Perform merge taking in consideration the cookies present
			for (OrderItem orderItem : cartOrderItems) {
				String productNumber = orderItem.PricebookEntry.Product2.SAP_Material_Number__c;
				Decimal quantity = orderItem.Quantity;
				String coupon = orderItem.Coupon__c;
				CartItem cartItem;

				if (cartItemMap.containsKey(productNumber)) {
					// Update
					cartItem = cartItemMap.get(productNumber);

					System.debug('OrderItem with ProductNumber ' + productNumber + ' already exists with Quantity ' + cartItem.quantity + ', adding Quantity ' + quantity);

					cartItem.quantity += quantity;
					
					if (cartItem.coupon == null) {
						// Add a coupon
						cartItem.coupon = coupon;
					} else {
						if (coupon != null) {
							// Replace existing coupon with a new one
							cartItem.coupon = coupon;
						}
					}
				} else {
					// Create
					cartItem = new CartItem(orderItem.Id, productNumber, quantity, coupon);

					System.debug('OrderItem with ProductNumber ' + productNumber + ' is new, adding Quantity ' + quantity);
				}

				cartItemMap.put(productNumber, cartItem);
				System.debug('cartItemMap at loginUserEvent: ' + cartItemMap);
			}
			//INC339486
			//productSwap();
			doProductSwap_OBOM();
			//filterInacessibleProducts();

			storeCart();
			//INC339486
			//doProductSwap(getCartOrderItems());
			clearCartInCookies();
			cartItemMap.clear();		// clear all items from Cart (it will be reloaded later).
		}
		
		System.debug('loginUserEvent end');	
	}

	/**
		Event called after an order is Submitted.

	*/
	public void submitEvent() {
		System.debug('submitEvent start');

		cartItemMap.clear();

		clearCartInCookies();

		System.debug('submitEvent end');
	}

	/**
		Get the Cart Content.

	*/
	public List<CartItem> getCartContent() {
		return cartItemMap.values();
	}

	/**
		Add a new Item to the Cart, indexed by productNumber. If product already exists
		then update the product with existing quantity + new quantity. If new product,
		just add it.

	*/
	public void addItem(String productNumber, Decimal quantity, String coupon) {
		CartItem cartItem;

		System.debug('addItem start');

		if (cartItemMap.containsKey(productNumber)) {
			cartItemMap.remove(productNumber);
		}

		cartItem = new CartItem(null, productNumber, quantity, coupon);

		cartItemMap.put(productNumber, cartItem);

		storeCart();

		System.debug('addItem end');
	}

	/**
		Update Item in the Cart, indexed by productNumber.

	*/
	public void updateItem(String productNumber, Decimal quantity, String coupon) {
		CartItem cartItem;

		System.debug('updateItem start');

		if (quantity > 0) {
			if (cartItemMap.containsKey(productNumber) == false) {
				throw new CartException('Error updating Cart Item with Key ' + productNumber + ': not found on Cart');
			}

			cartItem = cartItemMap.get(productNumber);

			cartItem.quantity = quantity;
			cartItem.coupon = coupon;

			storeCart();
		} else {
			deleteItem(productNumber);
		}

		System.debug('updateItem end');
	}

	/**
		Delete Item from the Cart, indexed by productNumber.

	*/
	public void deleteItem(String productNumber) {
		System.debug('deleteItem start');

		if (cartItemMap.containsKey(productNumber) == false) {
			throw new CartException('Error deleting Cart Item Key ' + productNumber + ': not found on Cart');
		}

		cartItemMap.remove(productNumber);

		storeCart();

		System.debug('deleteItem end');
	}
	
	/**
		Get Ecom Products by Product Id.

	*/
	@testVisible
	private List<EComProduct_DTO> getEcomProductsByProductIdList(List<Id> productIdList) {
		List<EComProduct_DTO> result = new List<EComProduct_DTO>();

		for (Id productId : productIdList) {
			String productNumber = productNumberMap.get(productId);
			EComProduct_DTO ecomProduct = ecomProductByProductNumberMap.get(productNumber);

			if (ecomProduct != null) {
				result.add(ecomProduct);
			}
		}

		return result;
	}

	/**
		Get the Order Items to be used in IEC_ShoppingCartController.

	*/
	public List<OrderItem_DTO> getOrderItems() {
		List<OrderItem_DTO> orderItems = new List<OrderItem_DTO>();

		System.debug('getOrderItems start');

		Map<String, Decimal> items = new Map<String, Decimal>();

		for (CartItem cartItem : getCartContent()) {
			items.put(cartItem.productNumber, cartItem.quantity);
		}

		if (items.isEmpty() == false) {
			Map<String,Product2> productByCode = Product_Sel.getProductsByCode(items.keySet());
			List<Id> listProductId = new List<Id>();

			for (String pCode : productByCode.keySet()) {
				Product2 p = productByCode.get(pCode);

				listProductId.add(p.Id);
			}

			//Product Swap in case it as swap configured
            /////////////////doProductSwap(items, listProductId);

			List<EComProduct_DTO> ecomProducts = getEcomProductsByProductIdList(listProductId);

			String customerType = User_Sel.getCustomerType(UserInfo.getUserId());

			for (EComProduct_DTO ecomProduct : ecomProducts) {
				if (ecomProduct.PriceInfo == null) {
					deleteItem(ecomProduct.ProductNumber);
					continue;
				}

				Decimal quantity = items.get(ecomProduct.ProductNumber);
				Decimal setupFee = (ecomProduct.setupFee != null) ?  ecomProduct.setupFee : 0;
				OrderItem_DTO oi_dto = new OrderItem_DTO();

				oi_dto.IECStaticCartQuantity = ecomProduct.IECStaticCartQuantity;

				if (oi_dto.IECStaticCartQuantity != null && oi_dto.IECStaticCartQuantity > 0) {
					quantity = oi_dto.IECStaticCartQuantity;	// Default quantity for phase 1 and phase 2 products
				}

				oi_dto.productId = ecomProduct.ProductId;
				oi_dto.productName = ecomProduct.ProductName;
				oi_dto.productCode = ecomProduct.ProductNumber;
				oi_dto.description = ecomProduct.ProductDesc;
				oi_dto.imageName = ecomProduct.ImageName;
				oi_dto.quantity = quantity;
				oi_dto.PriceInfo = ecomProduct.PriceInfo;
				oi_dto.IsQuantityInteger = ecomProduct.IsQuantityInteger;
				oi_dto.setupFee = setupFee;
				oi_dto.unitPrice = Order_Svc.getUnitPrice(ecomProduct.PriceInfo, oi_dto.quantity, customerType);
				oi_dto.subTotal = (oi_dto.unitPrice != null) ? (oi_dto.unitPrice * quantity) + setupFee : setupFee;

				orderItems.add(oi_dto);
			}
		}

		if (orderItems.size() > 0) {
			orderItems.sort();
		}

		System.debug('getOrderItems end');

		return orderItems;
	}


	private void doProductSwap_OBOM(){
		Map<Id, Product2> srcProductRatePlaneToProductMap = new Map<Id, Product2>();
		Map<Id, Swap_Configuration__c> trgSwapConfMap = new Map<Id, Swap_Configuration__c>();
		//Source product from cartItem
		List<Product2> srcProductList = new List<Product2>([SELECT id,SAP_Material_Number__c, ZProduct__c,IEC_Product_Rate_Plan_Information__c 
			FROM Product2 where SAP_Material_Number__c in :cartItemMap.keySet()]);
		system.debug('aqui srcProductList ' + srcProductList); 
		//Map of source ProductRatePlaces mapped by Product rate planes
		for(Product2 scrProduct : srcProductList){
			srcProductRatePlaneToProductMap.put(scrProduct.IEC_Product_Rate_Plan_Information__c, scrProduct);
		}

		system.debug('aqui IEC_Product_Rate_Plan_Information__c' + srcProductRatePlaneToProductMap);
		//Retrieves the swap configurations
		List<Swap_Configuration__c> swapConfigurationList = new List<Swap_Configuration__c>();
		swapConfigurationList = [SELECT id,Relationship_Type__c, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c 
			from Swap_Configuration__c where Relationship_Type__c = :IECConstants.SwappingType_Swap and 
			Source_Product_Rate_Plan_Information__c in :srcProductRatePlaneToProductMap.keySet()];

		system.debug('aqui swapConfigurationList' + swapConfigurationList);

		for(Swap_Configuration__c swapConf : swapConfigurationList){
			//Target product
			List<Product2> trgProduct = new List<Product2>([SELECT id,SAP_Material_Number__c, ZProduct__c,IEC_Product_Rate_Plan_Information__c 
			FROM Product2 where IEC_Product_Rate_Plan_Information__c = :swapConf.Target_Product_Rate_Plan_Information__c limit 1]);
			//Source product
			Product2 srcProduct = srcProductRatePlaneToProductMap.get(swapConf.Source_Product_Rate_Plan_Information__c);
			//Source CartItem
			CartItem srcCarItem = cartItemMap.get(srcProduct.SAP_Material_Number__c);
			//Remove source Item
			cartItemMap.remove(srcProduct.SAP_Material_Number__c);
			//Build the target item and add it to the cartItemMap
			CartItem trgCarItem = new CartItem (srcCarItem.Id, trgProduct[0].SAP_Material_Number__c, srcCarItem.quantity, srcCarItem.coupon);
			cartItemMap.put(trgProduct[0].SAP_Material_Number__c, trgCarItem);

		}

		system.debug('aqui doProductSwap_OBOM-->cartItemMap: ' + cartItemMap);

	}

	/****************************************************************************************************
        doProductSwap, function that retrieves a list of pricebookEntries for given
                                     pricebook and product
        @Id pricebookId, Id of the pricebook
        @Id productId, Id of the product
        @return, list of priceEntry by ProductId
        
        Author: Angela Lazaro 
    ****************************************************************************************************/
    private void doProductSwap(List<OrderItem> items){

    	System.debug('doProductSwap start ' + items);

    	Map<Id, OrderItem> orderItemMappedByProductId  = new Map<Id, OrderItem>();

    	Map<Id, OrderItem> orderItemMappedByProductRatePlan = new Map<Id, OrderItem>();

    	//Keeps a map of the orderItem to productId
    	for(OrderItem orderItem : items){
    		orderItemMappedByProductId.put(orderItem.PricebookEntry.Product2Id, orderItem);

    	}
    	System.debug('aqui orderItemMappedByProductId  ' + orderItemMappedByProductId);
    	//Fetch the product rate plan information configured in the product
    	List<Product2> productsList = [Select Id, IEC_Product_Rate_Plan_Information__c from Product2 where Id in :orderItemMappedByProductId.keySet()];
    	System.debug('aqui productsList  ' + productsList);
    	//Keeps a map of the orderItem to productRatePlan
    	for(Product2 product : productsList){
    		orderItemMappedByProductRatePlan.put(product.IEC_Product_Rate_Plan_Information__c, orderItemMappedByProductId.get(product.Id));
    	}

    	System.debug('angielaz, doProductSwap-->orderItemMappedByProductId: ' + orderItemMappedByProductId);
    	System.debug('angielaz, doProductSwap-->orderItemMappedByProductRatePlan: ' + orderItemMappedByProductRatePlan);

        List<Swap_Configuration__c> swapConfList = [Select Id, Relationship_Type__c, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c
                            from Swap_Configuration__c where Source_Product_Rate_Plan_Information__c in :orderItemMappedByProductRatePlan.keySet() and Relationship_Type__c = :IECConstants.SwappingType_Swap];
        
        for(Swap_Configuration__c swapConf : swapConfList){

            //Format from 18 digits Id to 15 digits Id
            /*String srcProductPlan = String.valueOf(swapConf.Source_Product_Rate_Plan_Information__c);
            srcProductPlan = srcProductPlan.substring(0, srcProductPlan.length() - 3);

            String trgProductPlan = String.valueOf(swapConf.Target_Product_Rate_Plan_Information__c);
            trgProductPlan = trgProductPlan.substring(0, trgProductPlan.length() - 3);
            */

            if(orderItemMappedByProductRatePlan.get(swapConf.Source_Product_Rate_Plan_Information__c) != null){
            	OrderItem orderItem = orderItemMappedByProductRatePlan.get(swapConf.Source_Product_Rate_Plan_Information__c);
            	List<Product2> products = [Select Id from Product2 where IEC_Product_Rate_Plan_Information__c = :swapConf.Target_Product_Rate_Plan_Information__c limit 1];
            	orderItem.PricebookEntry.Product2Id = products[0].Id;

            	System.debug('angielaz, orderItem: ' + orderItem);

            }
        }

        System.debug('doProductSwap end');
    }

	/**
		Check if User is Logged In.

	*/
	protected Boolean isUserLoggedIn() {
		return loggedCustomer != null;
	}

	/**
		Do Product Swap (because user is logged-in or customer type has been updated)

	*/
	@testVisible
	private void productSwap() {
		Set<Id> productRatePlanInformationIdSet = new Set<Id>();
		Map<String,String> swapMap = new Map<String,String>();

		System.debug('productSwap start');

		for (Id fromId : IEC_Cart.productRatePlanInformationSwapMap.keySet()) {
			Id toId = IEC_Cart.productRatePlanInformationSwapMap.get(fromId);
			String fromProductNumber = productRatePlanInformationProductNumberMap.get(fromId);
			String toProductNumber = productRatePlanInformationProductNumberMap.get(toId);

			swapMap.put(fromProductNumber, toProductNumber);
		}

		for (String productNumber : cartItemMap.keySet()) {
			CartItem cartItem = cartItemMap.get(productNumber);

			if (swapMap.containsKey(productNumber)) {
				String newProductNumber = swapMap.get(productNumber);
				CartItem existingCartItem = cartItemMap.get(newProductNumber);

				if (newProductNumber != null && newProductNumber != productNumber) {
					if (existingCartItem == null) {
						// Swapped to new Cart Item
						cartItemMap.put(newProductNumber, cartItem);
					} else {
						// Swapped to existing Cart Item
						existingCartItem.quantity += cartItem.quantity;

						if (existingCartItem.coupon == null && cartItem.coupon != null) {
							existingCartItem.coupon = cartItem.coupon;
						}
					}

					cartItemMap.remove(productNumber);
				}
			}
		}

		System.debug('productSwap end');
	}

	/**
		Remove Inacessible Products from the Cart.

	*/
	@testVisible
	private void filterInacessibleProducts() {
		String customerType = loggedCustomer.sfAccount.Customer_Type__c;
		Set<String> inacessibleProductNumberSet = new Set<String>();

		System.debug('filterInacessibleProducts start');

		if (String.isBlank(customerType)) {
			customerType = IECConstants.PARAM_CUSTOMERTYPE_DEFAULT;
		}
	
	System.debug('aqui customerType ' + customerType);
	System.debug('aqui cartItemMap ' + cartItemMap.keySet());
	System.debug('aqui productAccessMap ' + productAccessMap);		
	
		for (String productNumber : cartItemMap.keySet()) {
			System.debug('aqui productNumber ' + productNumber);
			Set<String> productAccessSet = productAccessMap.get(productNumber);

			if (
				productAccessSet == null
				||
				(
					productAccessSet != null
					&&
					productAccessSet.contains(null) == false	// No Access for all Customer Types
					&&
					productAccessSet.contains(customerType) == false	// No Access for specific Customer Type
				)
			) {
				// Remove inacessible product
				inacessibleProductNumberSet.add(productNumber);
			}
		}

		for (String productNumber : inacessibleProductNumberSet) {
			System.debug('Removing product number: ' + productNumber + ' because user has no access to it');

			cartItemMap.remove(productNumber);
		}

		System.debug('filterInacessibleProducts end');
	}

	/**
		Save Order and Cart Items to Database.

	*/
	@testVisible
	private void saveOrderAndCartItemsToDatabase(Order order, List<CartItem> cartItemList) {
		List<OrderItem> orderItemList = new List<OrderItem>();
		Map<String,CartItem> cartItemByProductNumberMap = new Map<String,CartItem>();
		List<Id> productIdList = new List<Id>();
		List<EComProduct_DTO> ecomProducts;
		Map<Id, EComProduct_DTO> ecomProductByIdMap = new Map<Id, EComProduct_DTO>();
		Map<String, PriceInfo_DTO> priceInfoByProductNumberMap = new Map<String, PriceInfo_DTO>();
		List<OrderItem> insertOrderItemList = new List<OrderItem>();
		List<OrderItem> updateOrderItemList = new List<OrderItem>();
		List<OrderItem> deleteOrderItemList = new List<OrderItem>();

		System.debug('saveOrderAndCartItemsToDatabase start');

		if (cartItemList != null && cartItemList.isEmpty() == false) {
			for (CartItem cartItem : cartItemList) {
				System.debug('cartItem: ' + cartItem);

				cartItemByProductNumberMap.put(cartItem.productNumber, cartItem);
			}

			for (String productNumber : cartItemByProductNumberMap.keySet()) {
				Product2 product = productMap.get(productNumber);
				
				if (product != null) {
					productIdList.add(product.Id);
				}
			}

			ecomProducts = getEcomProductsByProductIdList(productIdList);
			
			System.debug('angielaz, saveOrderAndCartItemsToDatabase-->ecomProducts: ' + ecomProducts);

			if (ecomProducts != null) {
				for (EComProduct_DTO ecomProduct : ecomProducts) {
					ecomProductByIdMap.put(ecomProduct.ProductId, ecomProduct);
					ecomProductByProductNumberMap.put(ecomProduct.ProductNumber, ecomProduct);
					priceInfoByProductNumberMap.put(ecomProduct.ProductNumber, ecomProduct.PriceInfo);
				}
			}		

			for (CartItem cartItem : cartItemList) {
				Product2 product = productMap.get(cartItem.productNumber);
				PricebookEntry pricebookEntry;
				EComProduct_DTO ecomProduct = ecomProductByProductNumberMap.get(cartItem.productNumber);
				
				if (product != null && ecomProduct != null) {
					pricebookEntry = pricebookEntryMap.get(product.Id);
	
					if (pricebookEntry != null) {	
						OrderItem orderItem = new OrderItem();

						if (cartItem.id != null) {
							// On Update specify only Id, the PricebookEntryId is not updatable
							orderItem.Id = cartItem.id;
						} else {
							// On Insert, specify PricebookEntryId
							orderItem.PricebookEntryId = pricebookEntry.Id;
						}

						orderItem.Quantity = cartItem.quantity;
						orderItem.Charge_Shipping__c = ecomProduct.ChargeShipping;
						orderItem.UnitPrice = ecomProduct.UnitPrice;
						orderItem.Source__c = 'Ecommerce';
						orderItem.Coupon__c = cartItem.coupon;

						orderItemList.add(orderItem);
					}
				}
			}
		}

		if (order.Id == null) {
			insert order;
		} else {
			update order;
		}

		for (OrderItem orderItem : orderItemList) {
			if (orderItem.Id == null) {
				orderItem.OrderId = order.Id;
			}
		}

		for (OrderItem orderItem : orderItemList) {
			if (orderItem.Id == null) {
				insertOrderItemList.add(orderItem);
			} else {
				updateOrderItemList.add(orderItem);
			}
		}

		Set<Id> orderItemIdSet = new Set<Id>();
		List<OrderItem> storedOrderItemList = new List<OrderItem>();

		for (OrderItem orderItem : updateOrderItemList) {
			orderItemIdSet.add(orderItem.Id);
		}

		for (OrderItem orderItem : [SELECT Id FROM OrderItem WHERE OrderId = :order.Id]) {
			if (orderItemIdSet.contains(orderItem.Id) == false) {
				deleteOrderItemList.add(orderItem);
			}
		}

		if (deleteOrderItemList.isEmpty() == false) {
			List<Order_Item_Charge__c> deleteOrderItemChargeList = [
				SELECT
					Id
				FROM
					Order_Item_Charge__c
				WHERE
				Order_Item__r.OrderId = :order.Id
			];

			if (deleteOrderItemChargeList.isEmpty() == false) {
				System.debug('DELETE Order Item Charge List: ' + deleteOrderItemChargeList);

				delete deleteOrderItemChargeList;
			}

			System.debug('DELETE Order Item List: ' + deleteOrderItemList);

			delete deleteOrderItemList;
		}

		if (updateOrderItemList.isEmpty() == false) {
			System.debug('UPDATE Order Item List: ' + updateOrderItemList);

			update updateOrderItemList;

			storedOrderItemList.addAll(updateOrderItemList);
		}

		if (insertOrderItemList.isEmpty() == false) {
			System.debug('INSERT Order Item List: ' + insertOrderItemList);

			insert insertOrderItemList;

			System.debug('INSERTED Order Item List: ' + insertOrderItemList);

			storedOrderItemList.addAll(insertOrderItemList);
		}

		if (storedOrderItemList.isEmpty() == false) {
			List<OrderItem> priceOrderItemList = getCartOrderItems();
			Order_Svc.setPriceToOrderItem(priceOrderItemList, priceInfoByProductNumberMap, order.ShipToContactId);
		}

		System.debug('saveOrderAndCartItemsToDatabase end');
	}

	/**
		Get most recent order being editer for user.
		If no Order is found, create a new Order of Type "Cart" and Status "New".

	*/
	public Order getCartOrder() {
		
		if(pendingOrder == null){
			pendingOrder = IECOrder_Svc.getPenddingOrder(true);
		}

		System.debug('getCartOrder() returning: ' + pendingOrder);

		return pendingOrder;
	}

	/**
		Get most recent order items for user's order being edited.

	*/
	@testVisible
	private List<OrderItem> getCartOrderItems() {
		Order order = getCartOrder();
		OrderItem_Sel itemSelector = new OrderItem_Sel();
		List<OrderItem> orderItemList;
		Map<Id,List<OrderItem>> orderItemMap = itemSelector.getOrderItems(new Set<Id>{ order.Id });
	
		orderItemList = orderItemMap.get(order.Id);

		if (orderItemList == null) {
			orderItemList = new List<OrderItem>();
		}

		return orderItemList;
	}

	/**
		Get the Product Name from the Product Number.

	*/
	@testVisible
	private static String getProductName(String productNumber) {
		return productNameMap.get(productNumber);
	}
}
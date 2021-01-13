/**  
  * Description: This class handles shopping cart
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  *   - 20160705-Sonny Leman: change getCartItems() for supporting eBroadcast special handling
  *
  */
public with sharing class IECShoppingCartHelper {

	class ShoppingCartRatePlanItem{
		ShoppingCartRatePlanItem(String i, Decimal q){ratePlanInformationId=i;quantity=q;}
		String ratePlanInformationId;
		Decimal quantity;
	}
	
	///////////////////////////
	// Public Methods
	
	/**
	 * Creates a new shopping cart object and associate it with a contact (if not null)
	 */
	public static IEC_Shopping_Cart__c createNewShoppingCart(Id contactId, Boolean saveGUIDinCookie) {
		try {
			
			IEC_Shopping_Cart__c cart = new IEC_Shopping_Cart__c();
			cart.CartGuid__c = (Test.isRunningTest()) ? IECCookieHelper.COOKIE_GUID_TEST : IECUtil.NewGuid();
			if (contactId != null)
				cart.Related_Contact__c = contactId;
			insert cart;
			
			if (saveGUIDinCookie)
				IECCookieHelper.storeCartGuid(cart.CartGuid__c);
			
			return cart;
		}
		catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * Returns the shooping cart for the current session
	 */
	public static IEC_Shopping_Cart__c getCurrentShoppingCart() {
		
		// check if user is logged in or not
		if (IECUserManager.isUserLoggedIn()) {

			IEC_Shopping_Cart__c cart = getShoppingCartsByContactID(IECUserManager.getContactId());
			if (cart != null)
				return cart;
			else
				return getShoppingCartByGUID(IECCookieHelper.getCartGuid());
		}
		else {
			// load the cart based on the GUID stored in a cookie
			String cartGuid = IECCookieHelper.getCartGuid();
			
			if(null!=cartGuid && cartGuid!='')
				return getShoppingCartByGUID(cartGuid, false);
			else
				return null;
		}
	}
	
	/**
	 * Returns a shopping cart by its GUID
	 */
	public static IEC_Shopping_Cart__c getShoppingCartByGUID(String cartGuid) {
		return getShoppingCartByGUID(cartGuid, false);
	}
	
	/**
	 * Returns a shopping cart by its GUID (throw error or return null if not found)
	 */
	public static IEC_Shopping_Cart__c getShoppingCartByGUID(String cartGuid, boolean throwError) {
		List<IEC_Shopping_Cart__c> carts = null;
		
		if (cartGuid != null && cartGuid != '') {
			carts = [SELECT Name, Related_Contact__c, CartGuid__c, Total_Items_in_Cart__c, 
						(SELECT Name,Quantity__c FROM IEC_Cart_Items__r) 
						FROM IEC_Shopping_Cart__c 
						WHERE CartGuid__c = :cartGuid];
		}

		if (carts == null || carts.size() == 0) {
			if (throwError)
				throw new IECApplicationException('No Shopping Cart found (' + cartGuid + ')');
			else
				return null;
		}
		
		return carts.get(0);
	}
	
	/**
	 * Returns the shopping carts associated to a Contact, ordered by CreatedDate desc
	 */
	public static IEC_Shopping_Cart__c getShoppingCartsByContactID(String contactId) {
		List<IEC_Shopping_Cart__c> carts = null;
		
		if (contactId != null && contactId != '') {
			carts = [SELECT Name, Related_Contact__c, CartGuid__c, Total_Items_in_Cart__c, 
						(SELECT Name,Quantity__c FROM IEC_Cart_Items__r) 
						FROM IEC_Shopping_Cart__c 
						WHERE Related_Contact__c = :contactId
						order by CreatedDate desc];
		}

		if (carts == null || carts.size() == 0)
			return null;
		else
			return carts.get(0);
	}
	
	/**
	 * Creates a new cart item object associated to an existing shopping cart
	 */
	public static void addCartItem(IEC_Shopping_Cart__c cart, String ratePlanInformationId, Integer quantity) {
		try {
			if (cart == null)
				throw new IECApplicationException('Cannot add a cart item to a null shopping cart');
			
			if (ratePlanInformationId == null || ratePlanInformationId == '')
				throw new IECApplicationException('ratePlanInformationId is empty or null');
			
			if (quantity <= 0)
				throw new IECApplicationException('Quantity is invalid: ' + quantity);
			
			// TODO: Business rule: cannot add more than once the same rate plan
			/*
			List<String> items = new List<String>(); items.add(ratePlanInformationId);
			if(itemsAlreadyExistsInCart(cart, items)){
				throw new IECApplicationException('Item(s) already exist in cart');
			}
			*/
			
			// 2014/08/08 : modification to only allow 1 cart item at a time 
			emptyCart(cart);
			
			// create cart item
			IEC_Cart_Item__c cartItem = new IEC_Cart_Item__c();
			cartItem.Related_Shopping_Cart__c = cart.Id;
			cartItem.Related_Rate_Plan_Information__c = ratePlanInformationId;
			cartItem.Quantity__c = quantity;
				
			insert cartItem;
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot add new item to cart: ' + ex.getMessage());
		}
	}

	/**
	 * Creates new cart item objects associated to an existing shopping cart
	 */
	public static void addCartItems(IEC_Shopping_Cart__c cart, List<ShoppingCartRatePlanItem> ratePlanItems) {
		try {
			if (cart == null)
				throw new IECApplicationException('Cannot add a cart item to a null shopping cart');
			
			List<IEC_Cart_Item__c> cartItems = new List<IEC_Cart_Item__c>();
			for(ShoppingCartRatePlanItem ratePlanItem : ratePlanItems){
				if (ratePlanItem.ratePlanInformationId == null || ratePlanItem.ratePlanInformationId == '')
					throw new IECApplicationException('ratePlanInformationId is empty or null');
				
				if (ratePlanItem.quantity <= 0)
					throw new IECApplicationException('Quantity is invalid: ' + ratePlanItem.quantity);
				
				// TODO: Business rule: cannot add more than once the same rate plan
					
				// create cart item
				IEC_Cart_Item__c cartItem = new IEC_Cart_Item__c();
				cartItem.Related_Shopping_Cart__c = cart.Id;
				cartItem.Related_Rate_Plan_Information__c = ratePlanItem.ratePlanInformationId;
				cartItem.Quantity__c = ratePlanItem.quantity;
				
				cartItems.add(cartItem);
			}	
			insert cartItems;
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot add new items to cart: ' + ex.getMessage());
		}
	}
	
	/**
	 * Returns a list of Cart Item related to the shopping cart
	 */
	public static List<IEC_Cart_Item__c> getCartItems(IEC_Shopping_Cart__c shoppingCart) {
		
		if (shoppingCart == null)
			return null;
		
		List<IEC_Cart_Item__c> cartItems = [SELECT Id, Name, Quantity__c, Related_Rate_Plan_Information__c,
											Related_Rate_Plan_Information__r.Short_Description__c,
											Related_Rate_Plan_Information__r.Is_Triable__c,
											Related_Rate_Plan_Information__r.Related_Product_Information__c,
											Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name,
											Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c,
											Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Banner_Image__c, 
											Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Product_Icon__c,
											Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Is_Quantifiable_Product__c,
											Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c,
											Related_Rate_Plan_Information__r.Related_Product_Information__r.New_Related_Product__r.zqu__SKU2__c,
											Related_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c,
											Related_Rate_Plan_Information__r.Product_Rate_Plan__r.Name,
											Related_Rate_Plan_Information__r.Product_Rate_Plan__r.IsTriable__c,
											Related_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c
											FROM IEC_Cart_Item__c
											WHERE Related_Shopping_Cart__c = :shoppingCart.Id
											ORDER BY CreatedDate];
		return cartItems;
	}
	
	/**
	 * Removes a cart item
	 */
	public static void removeCartItem(IEC_Cart_Item__c cartItem) {
		removeCartItemById(cartItem.Id);
	}
	
	/**
	 * Removes a cart item by its ID
	 */
	public static void removeCartItemById(String cartItemId) {
		try {
			if (cartItemId == null || cartItemId == '')
				throw new IECApplicationException('cartItemId is empty or null');
			
			List<IEC_Cart_Item__c> cartItem = [SELECT Id, Name 
												FROM IEC_Cart_Item__c 
												WHERE Id = :cartItemId];
			
			if (cartItem == null || cartItem.size() == 0)
				throw new IECApplicationException('Cart item not found: ' + cartItemId);
			
			delete cartItem.get(0);
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot remove cart item: ' + ex.getMessage());
		}
	}
	
	/**
	 * Checks if a given rate plan information is in a shopping cart
	 * @param oCart A Shopping Cart object
	 * @param sRatePlanInfoId The Rate Plan Information Id to check for
	 * @return True if the given rate plan information is part of the given shopping cart
	 */
	public static Boolean ratePlanExistsInCart(IEC_Shopping_Cart__c oCart, String sRatePlanInfoId) {
		try {
			if (sRatePlanInfoId == null || sRatePlanInfoId == '')
				throw new IECApplicationException('sRatePlanInfoId is empty or null');
			
			List<IEC_Cart_Item__c> cartItem = [SELECT Id, Name 
												FROM IEC_Cart_Item__c 
												WHERE Related_Shopping_Cart__c = :oCart.Id
													AND Related_Rate_Plan_Information__c = :sRatePlanInfoId];
			
			return !cartItem.isEmpty();
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot check if ratePlanExistsInCart: ' + ex.getMessage());
		}
	}
	
	/**
	 * Removes a cart item by its ID
	 */
	public static void removeCartItemsById(Set<ID> cartItemIds) {
		try {
			List<IEC_Cart_Item__c> cartItems = [SELECT Id, Name 
												FROM IEC_Cart_Item__c 
												WHERE Id IN :cartItemIds];
			
			delete cartItems;
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot remove cart items: ' + ex.getMessage());
		}
	}
	
	/**
	 * From the rate plans in the shopping cart, creates a list of RatePlanData (Zuora object)
	 * to be used for the subscription() API call of Zuora
	 * @param shoppingCart The shopping cart object to get the cart items from
	 * @return A list of RatePlanData (Zuora objects)
	 */
	public static List<Zuora.zObject> createRatePlanDataObjectFromCart(IEC_Shopping_Cart__c shoppingCart) {
		
		List<Zuora.zObject> listRatePlanData = new List<Zuora.zObject>();
		
		// XML structure of the RatePlanData to build (one per cart item):
		/*
		<ns1:RatePlanData>
			<ns1:RatePlan xmlns:ns2="http://object.api.zuora.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns2:RatePlan">
				<ns2:ProductRatePlanId>ff808181227d1cdb01227d1d54100048</ns2:ProductRatePlanId>
			</ns1:RatePlan>
			<ns1:RatePlanChargeData>
				<ns1:RatePlanCharge xmlns:ns2="http://object.api.zuora.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:type="ns2:RatePlanCharge">
					<ns2:ProductRatePlanChargeId>ff808181227d1cdb01227d1d571b004a</ns2:ProductRatePlanChargeId>
					<ns2:Quantity>19</ns2:Quantity>
				</ns1:RatePlanCharge>
			</ns1:RatePlanChargeData>
		</ns1:RatePlanData>
		*/
		
		// for each cart item 
		for (IEC_Cart_Item__c cartItem : getCartItems(shoppingCart)) {
			
			/*
			// loop for each quantity (did not found a way to provide quantity at the rate plan level in the subscribeRequest call)
			for (Integer i = 0; i < cartItem.Quantity__c.intValue(); i++) {
				Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
				ratePlan.setValue('ProductRatePlanId', cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c);
				
				// NOTE: the list of RatePlanChargeData for the RatePlanData object is not mandatory if we don't want to override the prices
				
				Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
				ratePlanData.setValue('RatePlan', ratePlan);
				listRatePlanData.add(ratePlanData);
			}
			*/
			
			
			Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
			
			// set the purchased Rate Plan
			Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
			ratePlan.setValue('ProductRatePlanId', cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c);
			ratePlanData.setValue('RatePlan', ratePlan);
			
			// get the charges related to the rate plan
			List<zqu__ProductRatePlanCharge__c> listCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c);
			
			// if the quantity is not 1 and the charge model is Per Unit Pricing, we need to override the RatePlanChargeData to specify the quantity
			if (cartItem.Quantity__c.intValue() != 1 && listCharges.get(0).zqu__Model__c == IECConstants.ChargeModel_Zuora_PerUnitPricing) {
				
				Zuora.zObject ratePlanChargeData = new Zuora.zObject('RatePlanChargeData');
				
				// take the first Rate Plan Charge (call only supports 1 charge...)
				Zuora.zObject ratePlanCharge = new Zuora.zObject('RatePlanCharge');
				ratePlanCharge.setValue('ProductRatePlanChargeId', listCharges.get(0).zqu__ZuoraId__c);
				ratePlanCharge.setValue('Quantity', cartItem.Quantity__c.intValue());

				ratePlanChargeData.setValue('RatePlanCharge', ratePlanCharge);
				ratePlanData.setValue('RatePlanChargeData', new List<Zuora.zObject>{ratePlanChargeData});
			}
			
			listRatePlanData.add(ratePlanData);
			
		}
		
		return listRatePlanData;
	}
	
	/**
	 * 
	 */
	public static List<Zuora.zObject> createRatePlanDataObjectFromCartItem(IEC_Cart_Item__c oCartItem) {
		
		List<Zuora.zObject> listRatePlanData = new List<Zuora.zObject>();
		Zuora.zObject oRatePlanChargeData = null;

		// loop for each quantity (did not found a way to provide quantity at the rate plan level in the subscribeRequest call)
		for (Integer i = 0; i < oCartItem.Quantity__c.intValue(); i++) {
			Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
			ratePlan.setValue('ProductRatePlanId', oCartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c);
			
			// NOTE: the list of RatePlanChargeData for the RatePlanData object is not mandatory if we don't want to override the prices
			
			/*
			List<zqu__ProductRatePlanCharge__c> lstRatePlanCharges = IECProductManager.getZuoraRatePlanChargesByRatePlanID(oCartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c);
			
			if (lstRatePlanCharges.size() > 0 && lstRatePlanCharges.get(0).zqu__Model__c == IECConstants.ChargeModel_Zuora_PerUnitPricing) {
				oRatePlanChargeData = new Zuora.zObject('RatePlanChargeData');
				Zuora.zObject oRatePlanCharge = new Zuora.zObject('RatePlanCharge');
				oRatePlanCharge.setValue('ProductRatePlanChargeId', lstRatePlanCharges.get(0).zqu__ZuoraId__c);
				oRatePlanCharge.setValue('Quantity', oCartItem.Quantity__c.intValue());
				oRatePlanChargeData.setValue('RatePlanCharge', oRatePlanCharge);
			}
			*/
			
			Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
			ratePlanData.setValue('RatePlan', ratePlan);
			//if (oRatePlanChargeData != null)
			//	ratePlanData.setValue('RatePlanChargeData', new List<Zuora.zObject> {oRatePlanChargeData});
			listRatePlanData.add(ratePlanData);
		}
		
		return listRatePlanData;
	}
	
	/**
	 * 
	 */
	public static List<Zuora.zObject> createRatePlanDataListObject(String sProductRatePlanZuoraID, Integer iQuantity) {
		
		List<Zuora.zObject> listRatePlanData = new List<Zuora.zObject>();
		Zuora.zObject oRatePlanChargeData = null;

		// loop for each quantity (did not found a way to provide quantity at the rate plan level in the subscribeRequest call)
		for (Integer i = 0; i < iQuantity; i++) {
			Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
			ratePlan.setValue('ProductRatePlanId', sProductRatePlanZuoraID);
			
			// NOTE: the list of RatePlanChargeData for the RatePlanData object is not mandatory if we don't want to override the prices
			
			Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
			ratePlanData.setValue('RatePlan', ratePlan);
			listRatePlanData.add(ratePlanData);
		}
		
		return listRatePlanData;
	}
	
	/** NOT USED
	 * Returns the Rate Plan Zuora IDs from a list of cart items
	 * @param A list of cart items
	 * @return A Set of Rate Plan Zuora ID
	 */
	 /*
	public static Set<String> getRatePlanZIDsFromCartItems(List<IEC_Cart_Item__c> cartItems) {
		
		if (cartItems == null || cartItems.size() == 0)
				return null;
			
		Set<String> ratePlanIds = new Set<String>();
		for (IEC_Cart_Item__c cartItem : cartItems) {
			ratePlanIds.add(cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c);
		}
		
		return ratePlanIds;
	}
	*/
	
	/**
	 * Deletes all cart items of a shopping cart
	 * @cart The Shopping cart to empty
	 * @return True if succeeded
	 */
	public static Boolean emptyCart(IEC_Shopping_Cart__c cart) {
		try {
			// delete all cart items
			for (IEC_Cart_Item__c cartItem : [SELECT Id FROM IEC_Cart_Item__c WHERE Related_Shopping_Cart__c = :cart.Id]) {
				delete cartItem;
			}

			return true;
		}
		catch (Exception ex) {
			throw ex;
		}
	}
	
	/**
	 * Updates a cart item (for now, only the quantity is updatable)
	 * @param cartItem The cart item to update
	 */
	public static void updateCartItem(IEC_Cart_Item__c cartItem) {
		try {
			
			if (cartItem.Related_Rate_Plan_Information__c == null)
				throw new IECApplicationException('ratePlanInformationId is empty or null');
			
			if (cartItem.Quantity__c <= 0)
				throw new IECApplicationException('Quantity is invalid: ' + cartItem.Quantity__c);
			
			update cartItem; 
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot update cart item: ' + ex.getMessage());
		}
	}

	/**
	 * Checks if items can be swapped for the given client type
	 * @param shoppingCart The customer's shopping cart
	 * @param clientType The customer's client type
	 */
	public static void swapCartItems(IEC_Shopping_Cart__c shoppingCart, String clientType){
		// get cart items
		List<IEC_Cart_Item__c> shoppingCartItems = getCartItems(shoppingCart);

		if(shoppingCartItems.IsEmpty()) return;
		
		Map<ID, IEC_Cart_Item__c> cartItemsByCartItemId = new Map<ID, IEC_Cart_Item__c>();
		Map<ID, IEC_Cart_Item__c> cartItemsByRatePlanId = new Map<ID, IEC_Cart_Item__c>();

		for (IEC_Cart_Item__c shoppingCartItem : shoppingCartItems) {
			cartItemsByCartItemId.put(shoppingCartItem.id, shoppingCartItem);
			cartItemsByRatePlanId.put(shoppingCartItem.Related_Rate_Plan_Information__c, shoppingCartItem);
		}
		
		// get the swappable rate plans with thier corresponding swapping rate plans
		Map<ID, Product_Rate_Plan_Information__c> newRatePlansBySourceRatePlanId = IECSubscriptionManager.getTargetSwappedRatePlans(cartItemsByRatePlanId.KeySet(), clientType);
		
		if (newRatePlansBySourceRatePlanId.IsEmpty()) return;
		
		Set<ID> cartItemsToRemove = new Set<ID>();
		List<ShoppingCartRatePlanItem> cartItemsToAdd = new List<ShoppingCartRatePlanItem>();

		for (ID sourceRatePlanId : newRatePlansBySourceRatePlanId.keySet()){
			ID oldCartItemId = cartItemsByRatePlanId.get(sourceRatePlanId).Id;
			ID newRatePlanId = newRatePlansBySourceRatePlanId.get(sourceRatePlanId).Id;
			Decimal ratePlanQuantity = cartItemsByCartItemId.get(oldCartItemId).Quantity__c;
			cartItemsToRemove.add(oldCartItemId);
			ShoppingCartRatePlanItem i = new ShoppingCartRatePlanItem(newRatePlanId, ratePlanQuantity);
			cartItemsToAdd.add(i);
		}
		
		// remove the swappable rate plans from the cart
		removeCartItemsById(cartItemsToRemove);
		
		// add the new items to the cart
		addCartItems(shoppingCart, cartItemsToAdd);
	}
	
	/**
	 * Associate a shopping cart to a contact
	 */
	public static void associateContactWithCart(IEC_Shopping_Cart__c shoppingCart, String contactId) {
		try {
			shoppingCart.Related_Contact__c = contactId;
			update shoppingCart;
			
			return;
		}
		catch (Exception ex) {
			throw new IECApplicationException('Cannot associate contact with current shopping cart: ' + ex.getMessage());
		}
	}
	
	/**
	 * Merge two shopping carts together; the items of the newCart will be added to the existingCart and the newCart will be deleted.
	 * @param existingCart Existing cart associated to a user
	 * @param newCart Anonymous cart to be merged with the existing. Will be deleted.
	 */
	public static void mergeCarts(IEC_Shopping_Cart__c existingCart, IEC_Shopping_Cart__c newCart) {
		try {
			
			List<IEC_Cart_Item__c> newCartItems = getCartItems(newCart);
			if (newCartItems != null && newCartItems.size() > 0) {
				for (IEC_Cart_Item__c cartItem : newCartItems) {
					// check if the rate plan already exists in the existing shopping cart, if not, add it
					if (ratePlanExistsInCart(existingCart, cartItem.Related_Rate_Plan_Information__c) == false)
						addCartItem(existingCart, cartItem.Related_Rate_Plan_Information__r.Id, cartItem.Quantity__c.intValue());
				}
			}
			
			delete newCart;
		}
		catch (Exception ex) {
			throw new IECApplicationException('Could not merge carts (existing: ' + existingCart.Id + ', new: ' + newCart.Id + '. Error: ' + ex.getMessage());
		}
	}
	
	/**
	 * Clean up in the cart if products were deactivated or are not available to a user type anymore
	 */
	public static void cleanUpCart(IEC_Shopping_Cart__c oCart, String sClientType, List<String> listErrMsgs, List<String> listInfoMsgs) {
		
		List<IEC_Cart_Item__c> cartItems = getCartItems(oCart);
		Set<String> setDeletedCartItemIDs = new Set<String>();
		
		if (cartItems == null || cartItems.size() == 0)
			return;
			 
		for (IEC_Cart_Item__c cartItem : cartItems) {
			
			if (setDeletedCartItemIDs.contains(cartItem.Id))
				continue;
			
			// check if product is still active and still accessible by the user's client type
			List<Product_Rate_Plan_Information__c> listRatePlan = 
				[SELECT Id, Active__c, Related_Product_Information__c
					, Related_Product_Information__r.Product_Audience__c, Related_Product_Information__r.Related_Product_Category__r.Is_Quantifiable_Product__c 
				 FROM Product_Rate_Plan_Information__c 
				 WHERE Id = :cartItem.Related_Rate_Plan_Information__c
				 	AND Active__c=true
				 	AND Related_Product_Information__r.Product_Audience__c IN :IECProductManager.getAvailableProductAudienceByClientType(sClientType)];
				 
			// rate plan not found
			if (listRatePlan.isEmpty()) {
				removeCartItemById(cartItem.Id);
				listInfoMsgs.add('The item ' + cartItem.Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c 
					+ ' ' + cartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.Name + ' was removed from your cart because it is no longer available.');
			}
			else {
				// if product is not quantifyable, check for doubles and remove them if found
				if (listRatePlan.get(0).Related_Product_Information__r.Related_Product_Category__r.Is_Quantifiable_Product__c == false) {
					for (IEC_Cart_Item__c iCartItem : cartItems) {
						if (iCartItem.Id != cartItem.Id && iCartItem.Related_Rate_Plan_Information__c == cartItem.Related_Rate_Plan_Information__c) {
							removeCartItemById(iCartItem.Id);
							setDeletedCartItemIDs.add(iCartItem.Id);
							listInfoMsgs.add('The item ' + iCartItem.Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c 
								+ ' ' + iCartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.Name + ' was removed from your cart because it was already there.');
						}
					}
				}
			}
		}
		
		// 2014/08/08 : modification to only allow 1 cart item at a time 
		// only keep last cart item if more than one
		cartItems = getCartItems(oCart);
		if (cartItems.size() > 1) {
			
			// remove all except the last cart item
			for (Integer i = 0; i < cartItems.size() - 1; i++) {
				removeCartItemById(cartItems.get(i).Id);
			}
		}
		
	}
}
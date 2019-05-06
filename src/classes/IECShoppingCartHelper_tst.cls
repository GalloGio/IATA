/**  
  * Description: This class tests the IEC Shopping Cart
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
@isTest
private class IECShoppingCartHelper_tst {

	private static Product_Category__c oProductCategory;
	private static Product_Information__c oProductInfo;
	private static Product_Information__c oProductInfo2;
	private static Product2 oProduct;
	private static Product2 oProduct2;
	private static zqu__ProductRatePlan__c oProductRatePlan;
	private static zqu__ProductRatePlan__c oProductRatePlan2;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
	private static Product_Rate_Plan_Information__c oProductRatePlanInfo2;
	private static Swap_Configuration__c oSwapConfig;
	private static Contact oContact;
	private static IEC_Shopping_Cart__c oCart;
	
	private static void setupData(Boolean triable){
		oProductCategory = IECTestUtil.CreateSampleProductCategory('PCTST', true);
		insert oProductCategory;
		
		oProduct = IECTestUtil.CreateSampleProduct2('PTST');
		insert oProduct;
		
		oProduct2 = IECTestUtil.CreateSampleProduct2('PTST2');
		insert oProduct2;
		
		oProductInfo = IECTestUtil.CreateSampleProductInfo2('PITST', oProductCategory, oProduct);
		oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
		insert oProductInfo;
		
		oProductInfo2 = IECTestUtil.CreateSampleProductInfo2('PITST2', oProductCategory, oProduct2);
		oProductInfo2.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
		insert oProductInfo2;
		
		oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan2('PRPTST', triable, oProduct);
		insert oProductRatePlan;
		
		oProductRatePlan2 = IECTestUtil.CreateSampleProductRatePlan2('PRPTST2', triable, oProduct2);
		insert oProductRatePlan2;
		
		oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', triable, oProductRatePlan, oProductInfo);
		oProductRatePlanInfo.Display_As_Monthly_Fee__c = !triable;
		insert oProductRatePlanInfo;
		
		oProductRatePlanInfo2 = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST2', triable, oProductRatePlan2, oProductInfo2);
		oProductRatePlanInfo2.Display_As_Monthly_Fee__c = !triable;
		insert oProductRatePlanInfo2;
		
		oSwapConfig = new Swap_Configuration__c(Source_Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id, 
												Target_Product_Rate_Plan_Information__c = oProductRatePlanInfo2.Id,
												Relationship_Type__c = IECConstants.SwappingType_Swap
												);
		insert oSwapConfig;
		 
		oContact = new Contact(FirstName = 'Test', LastName='User');
		insert oContact;
		
		oCart = IECTestUtil.createSampleShoppingCart(oContact.Id);
		insert oCart;
	}
	
    static testMethod void testAddRemoveEmpty() {

        // create dummy Zuora product
    	Product2 prod = IECTestUtil.CreateSampleProduct2('Product1');
    	prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
    	prod.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
    	insert prod;
    	
    	// create dummy Zuora rate plan
    	zqu__ProductRatePlan__c ratePlan = IECTestUtil.CreateSampleProductRatePlan2('Rate plan 1', false, prod);
    	ratePlan.zqu__Deleted__c = false;
    	insert ratePlan;
    	
    	// create dummy Zuora rate plan charge
    	zqu__ProductRatePlanCharge__c charge = IECTestUtil.CreateSampleProductRatePlanCharge(ratePlan, 'Charge 1', 42);
    	charge.zqu__Deleted__c = false;
    	insert charge;
    	
    	// create dummy product category
        Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        myProdCat.Active__c = true;
        insert myProdCat;
        
        // create dummy product info
        Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo2('My product', myProdCat, prod);
        insert myProdInfo;
        
        // create dummy rate plan information
        Product_Rate_Plan_Information__c ratePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Rate Plan Info 1', false, ratePlan, myProdInfo);
        ratePlanInfo.Display_As_Monthly_Fee__c = false;
        ratePlanInfo.Active__c = true;
        ratePlanInfo.Order__c = 1;
        insert ratePlanInfo;
        
        Test.startTest();
        
        // Test #1 - cart should be empty at first
        IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getShoppingCartByGUID(IECCookieHelper.getCartGuid(), false);
        system.assert(cart == null);
        List<IEC_Cart_Item__c> cartItems = IECShoppingCartHelper.getCartItems(cart);
        system.assert(cartItems == null || cartItems.size()==0);
        
        // Test #2 - add an empty item
        try {
        	IECShoppingCartHelper.addCartItem(cart, '', 2);
        	system.assert(false);
        }
        catch (Exception ex) {
        	system.assert(true);
        }
        
        // create shopping cart
        cart = IECShoppingCartHelper.createNewShoppingCart(null, true);
        
        cart = IECShoppingCartHelper.getCurrentShoppingCart();
        
        // Test #3  - associate contact with the cart
        User u = IECTestUtil.createSampleGuestUserAndLogin();
        IECShoppingCartHelper.associateContactWithCart(cart, u.ContactId);
        IEC_Shopping_Cart__c cart2 = IECShoppingCartHelper.getShoppingCartsByContactID(u.ContactId);
        system.assert(cart.Id == cart2.Id, 'Shopping cart should be found by its contact id');
        
        // Test #4 - add an item and make sure we have 1 item
        IECShoppingCartHelper.addCartItem(cart, ratePlanInfo.Id, 1);

        cartItems = IECShoppingCartHelper.getCartItems(cart);
        system.assert(cartItems != null || cartItems.size()==1);
        system.assert(IECShoppingCartHelper.ratePlanExistsInCart(cart, ratePlanInfo.Id), 'Rate plan should exist in shopping cart');
        
        // Test #5 - add an empty item
        try {
        	IECShoppingCartHelper.addCartItem(cart, null, 1);
        	system.assert(false, 'IECShoppingCartHelper.addCartItem should throw an exception');
        }
        catch (Exception ex) {
        	system.assert(true, 'IECShoppingCartHelper.addCartItem should throw an exception');
        }
        
        // Test #6 - add empty item with invalid quantity
        try {
        	IECShoppingCartHelper.addCartItem(cart, ratePlanInfo.Id, -42);
        	system.assert(false, 'IECShoppingCartHelper.addCartItem should throw an exception');
        }
        catch (Exception ex) {
        	system.assert(true, 'IECShoppingCartHelper.addCartItem should throw an exception');
        }
        
        // Test #7 - update quantity of item
        IEC_Cart_Item__c cartItem = cartItems.get(0);
        cartItem.Quantity__c = 3;
        IECShoppingCartHelper.updateCartItem(cartItem);
        cartItems = IECShoppingCartHelper.getCartItems(cart);
        cartItem = cartItems.get(0);
        system.assertEquals(3, cartItem.Quantity__c);
        
        // Test #8 - test createRatePlanDataFromCart - THROWS ERROR
        //List<Zuora.zObject> listRatePlanData = IECShoppingCartHelper.createRatePlanDataObjectFromCart(cart);
        //system.assert(listRatePlanData != null && listRatePlanData.size() > 0);
        
        // Test #9 - remove item
        IECShoppingCartHelper.removeCartItem(cartItems.get(0));
        cartItems = IECShoppingCartHelper.getCartItems(cart);
        system.assert(cartItems == null || cartItems.size()==0);
        
        // Test #10 - remove an empty item
        try {
        	IECShoppingCartHelper.removeCartItemById('');
        	system.assert(false);
        }
        catch (Exception ex) {
        	system.assert(true);
        }
        
        // Test #11 - test empty cart
        IECShoppingCartHelper.addCartItem(cart, ratePlanInfo.Id, 1);
        IECShoppingCartHelper.emptyCart(cart);
        cartItems = IECShoppingCartHelper.getCartItems(cart);
        system.assert(cartItems == null || cartItems.size()==0);
		
        Test.stopTest();
    }
    
    static testMethod void testSwapCartItems() {
    	setupData(false);
    	
    	IEC_Cart_Item__c oCartItem = IECTestUtil.createSampleShoppingCart(oCart, oProductRatePlanInfo.Id, 1);
    	insert oCartItem;
    	system.assertEquals(oCartItem.Related_Rate_Plan_Information__c,oProductRatePlanInfo.Id,'Non Member item should exist in the cart');
		
    	IECShoppingCartHelper.swapCartItems(oCart, IECConstants.ProductInformationAudience_MEMBERAIRLINE);
    	
    	List<IEC_Cart_Item__c> newCartItems = IECShoppingCartHelper.getCartItems(oCart);
    	system.assertEquals(newCartItems.size(),1,'There should be one item in the cart');
    	
    	IEC_Cart_Item__c newCartItem = newCartItems.get(0);
    	system.assertEquals(newCartItem.Related_Rate_Plan_Information__c,oProductRatePlanInfo2.Id,'Member item should exist in the cart');
    }
    
    static testMethod void testMergeAndCleanUp() {
    	setupData(false);
    	
    	List<String> listErrMsgs = new List<String>();
    	List<String> listInfoMsgs = new List<String>();
    	
    	Test.startTest();
    	
    	// create 2 shopping carts with one item each and merge them
    	IEC_Shopping_Cart__c cart1 = IECShoppingCartHelper.createNewShoppingCart(null, false);
    	IECShoppingCartHelper.addCartItem(cart1, oProductRatePlanInfo.Id, 1);
    	IEC_Shopping_Cart__c cart2 = IECShoppingCartHelper.createNewShoppingCart(null, false);
    	IECShoppingCartHelper.addCartItem(cart2, oProductRatePlanInfo2.Id, 1);
    	
    	// Test #1 - merge cart2 items into cart1 items
    	IECShoppingCartHelper.mergeCarts(cart1, cart2);
    	// 2014/08/08 : modification to only allow 1 cart item at a time 
    	List<IEC_Cart_Item__c> cart1Items = IECShoppingCartHelper.getCartItems(cart1);
    	//system.assertEquals(2, cart1Items.size(), 'The 2 items should be merged in the same shopping cart');
    	
    	// Test #2 - cart2 is deleted
    	List<IEC_Shopping_Cart__c> listDeletedCart = [SELECT Id, Name
													  FROM IEC_Shopping_Cart__c 
													  WHERE Id = :cart2.Id];
		system.assert(listDeletedCart == null || listDeletedCart.isEmpty(), 'Cart2 should be deleted after merge');			
    	
    	// Test #3 - clean up (nothing removed)
    	IECShoppingCartHelper.cleanUpCart(cart1, IECConstants.Account_ClientType_ThirdParty, listErrMsgs, listInfoMsgs);
    	// 2014/08/08 : modification to only allow 1 cart item at a time 
    	//system.assertEquals(2, cart1Items.size(), 'No items should be removed from the clean up process');
    	system.assertEquals(1, cart1Items.size(), 'No items should be removed from the clean up process');
    	
    	// Test #4 - clean up (inactive rate plan removed)
    	oProductRatePlanInfo.Active__c = false;
    	update oProductRatePlanInfo;
    	IECShoppingCartHelper.cleanUpCart(cart1, IECConstants.Account_ClientType_ThirdParty, listErrMsgs, listInfoMsgs);
    	cart1Items = IECShoppingCartHelper.getCartItems(cart1);
    	// 2014/08/08 : modification to only allow 1 cart item at a time
    	system.assertEquals(0, cart1Items.size(), 'Inactive rate plan info should be removed by clean up process');
    	system.assertEquals(1, listInfoMsgs.size(), 'There should be one info message added by clean up process');
    	
    	// Test #5 - clean up to remove double
    	oProductCategory.Is_Quantifiable_Product__c = false; // make the product not quantifyable
    	update oProductCategory;
    	IECShoppingCartHelper.addCartItem(cart1, oProductRatePlanInfo2.Id, 1);
    	IECShoppingCartHelper.cleanUpCart(cart1, IECConstants.Account_ClientType_ThirdParty, listErrMsgs, listInfoMsgs);
    	cart1Items = IECShoppingCartHelper.getCartItems(cart1);
    	// 2014/08/08 : modification to only allow 1 cart item at a time
    	system.assertEquals(0, cart1Items.size(), 'Double rate plan info should be removed by clean up process');
    	
    	Test.stopTest();
    }
}
/**

		Project: eCommerce Enhancements
	       File: IEC_Cart_Test.cls
	Description: Test class for Cart Class.
	     Author: blue-infinity sa
	    History: aosantos, 2017-07-04, Initial Release.


*/
@isTest
private class IEC_Cart_Test {
	static User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
	static List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(null, false, null, null, false, null);

	@isTest(seeAllData=true)
	static void test1() {		
		IEC_Cart cart;
		List<IEC_Cart.CartItem> items;
		List<OrderItem_DTO> orderItems;
		Order order;
		IEC_Cart.CartItem cartItem;
		String customerType;

		System.runAs(oUser) {
			cart = IEC_Cart.getInstance();

			order = cart.getCartOrder();

			customerType = (cart != null && cart.loggedCustomer != null && cart.loggedCustomer.sfAccount != null) ? cart.loggedCustomer.sfAccount.Customer_Type__c : 'Not Logged';

			cart.reloadOrder();

			Test.startTest();

			items = cart.getCartContent();

			order = cart.getCartOrder();

			orderItems = cart.getOrderItems();

			cart.loginUserEvent();
			cart.submitEvent();

			Test.stopTest();
		}
	}

	@isTest(seeAllData=true) 
	static void test2() {
		IEC_Cart cart;
		IEC_Cart.CartItem cartItem;
		String str;
		String productNumber = ecomProducts[0].ProductNumber;
		
		System.runAs(oUser) {
			cart = IEC_Cart.getInstance();

			str = IEC_Cart.serializeCartItem(new IEC_Cart.CartItem(null, productNumber, 1.0, null));
			str = IEC_Cart.serializeString('hello');
			str = IEC_Cart.serializeString(null);
			str = IEC_Cart.serializeDecimal(1.0);

			cartItem = IEC_Cart.deserializeCartItem(productNumber + ';9.0;null');

			str = cartItem.productName;

			cartItem = IEC_Cart.deserializeCartItem(productNumber + ';null;null');
			cartItem = IEC_Cart.deserializeCartItem('null;null;null');

			cartItem = IEC_Cart.deserializeCartItem('');
		}
	}

	/*@isTest(seeAllData=true)
	static void test3() {
		IEC_Cart cart;
		IEC_Cart.CartItem cartItem;
		String str;
		String productNumber = ecomProducts[0].ProductNumber;
		String productNumber2 = ecomProducts[1].ProductNumber;
		List<Id> productIdList = new List<Id>();
		List<EComProduct_DTO> ecomProductList;
		List<OrderItem_DTO> orderItemList;

		for (Product2 product : [SELECT Id FROM Product2 WHERE SAP_Material_Number__c != null LIMIT 2]) {
			productIdList.add(product.Id);
		}

		cart = IEC_Cart.getInstance();
		
		cartItem = new IEC_Cart.CartItem(null, productNumber, 1, null);

		cart.cartItemMap.put(cartItem.productNumber, cartItem);
		
		cart.serializeCartInCookies();

		cart.deserializeCartFromCookies();

		cart.storeCart();
		cart.retrieveCart();

		cart.clearCart();

		cart.addItem(productNumber, 1.0, null);
		cart.addItem(productNumber, 3.0, null);

		cart.updateItem(productNumber, 1.0, null);

		cart.updateItem(productNumber, -1.0, null);

		cart.addItem(productNumber, 4.0, null);

		System.runAs(oUser) {
			try {
				//cart.saveOrderAndCartItemsToDatabase(cart.getCartOrder(), cart.cartItemMap.values());
			} catch (Exception e) {
			}

			Test.startTest();

			cart.retrieveCart();

			try {
				cart.loginUserEvent();
			} catch (Exception e) {
			}

			try {
				cart.updateItem(productNumber2, 2.0, null);
			} catch (Exception e) {
			}

			try {
				cart.deleteItem(productNumber2);
			} catch (Exception e) {
			}

			orderItemList = cart.getOrderItems();

			try {
				cart.addItem(productNumber, 4.0, null);
			} catch (Exception e) {
			}

			try {
				cart.deleteItem(productNumber);
			} catch (Exception e) {
			}

			Test.stopTest();
		}
		
		ecomProductList = cart.getEcomProductsByProductIdList(productIdList);
	}*/

}

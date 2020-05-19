@isTest
private class IEC_ShoppingCartControllerTest
{
	static void testSetupNewShoppingCart() {
		List<IEC_Functionality__c> l = IEC_Functionality__c.getAll().values();

		if (l.isEmpty() == false) {
			delete l;
		}

		IEC_Functionality__c f = new IEC_Functionality__c(
			Order__c = 0,
			Name='Test New Shopping Cart',
			Functionality_Name__c = 'New Shopping Cart',
			Is_Active__c = true,
			Audience__c = 'all=true'
		);

		insert f;
	}

	static void testSetupOldShoppingCart() {
		List<IEC_Functionality__c> l = IEC_Functionality__c.getAll().values();

		if (l.isEmpty() == false) {
			delete l;
		}

		IEC_Functionality__c f = new IEC_Functionality__c(
			Order__c = 0,
			Name='Test New Shopping Cart',
			Functionality_Name__c = 'New Shopping Cart',
			Is_Active__c = true,
			Audience__c = 'all=false'
		);

		insert f;
	}

	static List<Location__c> createTestLocation(Contact oContact, List<IECAddress__c> lstAddress)
	{
		List<Location__c> lstLocation =  [SELECT ID, Active__c, Type__c, SAP_Id__c, Address__c, Account__c FROM Location__c WHERE Id in (:oContact.Account.SoldTo_Location__c , :oContact.BillTo_Location__c, :oContact.ShipTo_Location__c)];

		return lstLocation;
	}


	static List<Product2> createTestProduct(Integer nb)
	{
		//*** remove additional filters when query products for ECommerce
		delete [select Id from Apex_Setting__c where Name like 'ECommerce Products Filter%'];

		//*** create products
		List<Product2> lstProduct = TestDataGenerator.generateProductsWithPrice(nb);

		System.assert(lstProduct.size() == nb, 'Created ' + lstProduct.size() + ' products instead of ' + nb);

		for(Integer x =0; x < lstProduct.size(); x++)
		{
			Product2 p = lstProduct[x];
			p.Post_to_Ecommerce_Date__c = Date.today().addDays(-10);
			p.Sell_through_eCommerce__c = true;
			p.Inventory_Status__c = 'In stock';
			p.SAP_Status_Code__c = 'A';
			p.Line_of_Business__c = (Math.mod(x,2)==0) ? 'Publications' : 'GDP';
			p.Mega_Menu__c = (Math.mod(x,2)==0) ? 'publications' : 'data-and-statistics';
			p.Refinement_Language__c = (Math.mod(x,2)==0) ? 'English' : 'French';
		}
		update lstProduct;
		return lstProduct;
	}


	static Order createTestOrder(User oUser, Contact oContact, List<Product2> lstProduct, List<Location__c> lstLocation)
	{
		Order oOrder = TestDataGenerator.generateOrder(1, oContact.AccountId, oContact.Id, oContact.Id, false)[0];
		oOrder.SoldTo_Location__c = lstLocation[0].Id;
		oOrder.BillTo_Location__c = lstLocation[1].Id;
		oOrder.ShipTo_Location__c = lstLocation[2].Id;
		oOrder.OwnerId = oUser.Id;
		oOrder.Type = 'Cart';
		oOrder.Status = 'New';
		insert oOrder;
		oOrder = [select Id, OrderNumber from Order where Id = :oOrder.Id limit 1];

		List<Id> lstProductId = new List<Id>();
		for (Product2 p : lstProduct)
			lstProductId.add(p.Id);
		List<OrderItem> lstOrderItem = new List<OrderItem>();
		for (PricebookEntry pbe : [select Id from PricebookEntry where Product2Id in :lstProductId])
			lstOrderItem.add(new OrderItem(OrderId=oOrder.Id, PriceBookEntryId=pbe.Id, Quantity=1, UnitPrice=15, Charge_Shipping__c = true, ServiceDate=Date.Today()));

		insert lstOrderItem;

		System.assert(lstProduct.size() == lstOrderItem.size(), 'Created ' + lstOrderItem.size() + ' order items  instead of ' + lstProduct.size());

		return oOrder;
	}


	@isTest
	static void test_cart_empty()
	{
		testSetupNewShoppingCart();

		Test.setCurrentPage(Page.IEC_ShoppingCart);
		IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController();
		ctrl.vfOrder = new Order_DTO();
		System.assertEquals(true, ctrl.isCartEmpty);
	}


	@isTest (SeeAllData=true)
	static void test_not_logged_in()
	{
		testSetupNewShoppingCart();

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		IEC_ShoppingCartController ctrl;

		//*** with a requested order
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?order=abc'));
		ctrl = new IEC_ShoppingCartController();
		system.assert(ctrl.onLoadAction() != null, 'Should return login page');

		//*** with cart already have a time-based subscription or sibling in cart
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?msg=siblingInCart'));
		ctrl = new IEC_ShoppingCartController();
		ctrl.onLoadAction();
		System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Itemalready_in_cart), 'Invalid error: ' + ApexPages.getMessages());
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?msg=time-based'));
		ctrl = new IEC_ShoppingCartController();
		ctrl.onLoadAction();
		System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Only_one_subscription_can_be_purchased), 'Invalid error: ' + ApexPages.getMessages());

		//*** checkout
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?action=checkout'));
		ctrl = new IEC_ShoppingCartController();
		system.assert(ctrl.onLoadAction() != null, 'Should return login page');
	}


	@isTest (SeeAllData=true)
	static void test_logged_in()
	{
		testSetupNewShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		oOrder.Type = 'Quote';
		update oOrder;
		IECQuotePDFEmailNotification_Ctrl const1 = new IECQuotePDFEmailNotification_Ctrl();
		const1.orderId = oOrder.id;
		Order_DTO order1 = const1.vfQuote;
		System.runAs(oUser)
		{
			//*** get pending cart - nothing to assert
			Test.setCurrentPage(Page.IEC_ShoppingCart);
			ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();

			//*** have a request order and add product already existed
			Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?order=' + oOrder.OrderNumber + '&productNumber=' + lstProduct[0].SAP_Material_Number__c));
			ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();
			//*** assert on product already existed is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Item_already_in_your_cart), 'Invalid error: ' + ApexPages.getMessages());

			//*** continue shopping and checkout with non-compliant
			//system.assert(ctrl.continueShopping() == null, 'Continue shopping should NOT be allowed');
			ctrl.continueShopping();

			//system.assert(ctrl.startCheckout() == null, 'Checkout should NOT be allowed');
			ctrl.startCheckout();
		}
		Test.stopTest();
	}

	@isTest (SeeAllData=true)
	static void test_logged_in2()
	{
		testSetupNewShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		IATA_ISO_Country__c country = [SELECT Id, Is_Non_Compliant__c FROM IATA_ISO_Country__c WHERE Id = :lstAddress[0].ISO_Country__c];
		country.Is_Non_Compliant__c = true;
		update country;

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		//oOrder.Type = 'Quote';
		//update oOrder;

		//*** have a request order and add product already existed

		System.runAs(oUser)
		{
			//*** get pending cart - nothing to assert
			Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?order=' + oOrder.OrderNumber));
			ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();

			//*** remove product
			system.debug('SAP_Material_Number__c: '+lstProduct[1].SAP_Material_Number__c);
			ApexPages.currentPage().getParameters().put('productCode', lstProduct[1].SAP_Material_Number__c);
			ctrl.removeProduct();

			ctrl.onLoadAction();

			//system.assert(ctrl.vfOrder.orderItems.size() == 1, 'Wrong count, expecting 1, got ' + ctrl.vfOrder.orderItems.size() + ': ' + ctrl.vfOrder.orderItems);

			//*** continue shopping and checkout with non-compliant
			//system.assert(ctrl.continueShopping() == null, 'Continue shopping should NOT be allowed');
			//system.assert(ctrl.startCheckout() == null, 'Checkout should NOT be allowed');
		}
		Test.stopTest();
	}

	@isTest (SeeAllData=true)
	static void test_logged_in3()
	{
		testSetupNewShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		System.runAs(oUser)
		{
			//*** get pending cart - nothing to assert
			Test.setCurrentPage(Page.IEC_ShoppingCart);
			ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();

			//*** update quantity
			ApexPages.currentPage().getParameters().put('productCode', lstProduct[0].SAP_Material_Number__c);
			ApexPages.currentPage().getParameters().put('quantity', '-1');
			ctrl.updateProductQuantity();

			//system.assert(ctrl.vfOrder.orderItems.size() == 1, 'Wrong count: ' + ctrl.vfOrder.orderItems.size() + ', expecting 1');
		}
		Test.stopTest();
	}

	@isTest (SeeAllData=true)
	static void test_logged_in4()
	{
		testSetupNewShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);

		Test.startTest();
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

			System.runAs(oUser)
			{
				//*** get pending cart - nothing to assert
				Test.setCurrentPage(Page.IEC_ShoppingCart);
				ctrl = new IEC_ShoppingCartController();
				ctrl.onLoadAction();

				//*** update quantity
				ApexPages.currentPage().getParameters().put('productCode', lstProduct[0].SAP_Material_Number__c);
				ApexPages.currentPage().getParameters().put('quantity', '-1');
				ctrl.updateProductQuantity();
				ctrl.onLoadAction();

				//system.assert(ctrl.vfOrder.orderItems.size() == 1, 'Wrong count, expecting 1 got ' + ctrl.vfOrder.orderItems.size() + ': ' + ctrl.vfOrder.orderItems);

				ApexPages.currentPage().getParameters().put('productCode', lstProduct[1].SAP_Material_Number__c);
				ApexPages.currentPage().getParameters().put('quantity', '5');
				ctrl.updateProductQuantity();
				ctrl.onLoadAction();

				//system.assert(ctrl.vfOrder.orderItems.size() == 1 && ctrl.vfOrder.orderItems[0].quantity == 5, 'Wrong quantity: ' + ctrl.vfOrder.orderItems);

				Test.stopTest();

				//*** continue shopping and checkout
				system.assert(ctrl.continueShopping() != null, 'Continue shopping should be allowed');
				system.assert(ctrl.startCheckout() != null, 'Checkout should be allowed');
			}

	}

	// ------------------------ old version ---------------------------------

	@isTest
	static void test_cart_empty_old()
	{
		testSetupOldShoppingCart();

		Test.setCurrentPage(Page.IEC_ShoppingCart);
		IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController();
		ctrl.vfOrder = new Order_DTO();
		System.assertEquals(true, ctrl.isCartEmpty);
	}


	@isTest (SeeAllData=true)
	static void test_not_logged_in_old()
	{
		testSetupOldShoppingCart();

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		IEC_ShoppingCartController ctrl;

		//*** with a requested order
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?order=abc'));
		ctrl = new IEC_ShoppingCartController();
		system.assert(ctrl.onLoadAction() != null, 'Should return login page');

		//*** with cart already have a time-based subscription or sibling in cart
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?msg=siblingInCart'));
		ctrl = new IEC_ShoppingCartController();
		ctrl.onLoadAction();
		System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Itemalready_in_cart), 'Invalid error: ' + ApexPages.getMessages());
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?msg=time-based'));
		ctrl = new IEC_ShoppingCartController();
		ctrl.onLoadAction();
		System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Only_one_subscription_can_be_purchased), 'Invalid error: ' + ApexPages.getMessages());

		//*** checkout
		Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?action=checkout'));
		ctrl = new IEC_ShoppingCartController();
		system.assert(ctrl.onLoadAction() != null, 'Should return login page');
	}


	@isTest (SeeAllData=true)
	static void test_logged_in_old()
	{
		testSetupOldShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		oOrder.Type = 'Quote';
		update oOrder;

			System.runAs(oUser)
			{
				//*** get pending cart - nothing to assert
				Test.setCurrentPage(Page.IEC_ShoppingCart);
				ctrl = new IEC_ShoppingCartController();
				ctrl.onLoadAction();

				//*** have a request order and add product already existed
				Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?order=' + oOrder.OrderNumber + '&productNumber=' + lstProduct[0].SAP_Material_Number__c));
				ctrl = new IEC_ShoppingCartController();
				ctrl.onLoadAction();
				//*** assert on product already existed is risky due to merge field: System.assert(String.valueOf(ApexPages.getMessages()[ApexPages.getMessages().size() - 1]).contains(Label.Item_already_in_your_cart), 'Invalid error: ' + ApexPages.getMessages());

				//*** continue shopping and checkout with non-compliant
				//system.assert(ctrl.continueShopping() == null, 'Continue shopping should NOT be allowed');
				//system.assert(ctrl.startCheckout() == null, 'Checkout should NOT be allowed');
			}
		Test.stopTest();
	}

	@isTest (SeeAllData=true)
	static void test_logged_in_old2()
	{
		testSetupOldShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		oOrder.Type = 'Quote';
		update oOrder;

		//*** have a request order and add product already existed

			System.runAs(oUser)
			{
				//*** get pending cart - nothing to assert
				Test.setCurrentPageReference(new PageReference('/apex/IEC_ShoppingCart?order=' + oOrder.OrderNumber));
				ctrl = new IEC_ShoppingCartController();
				ctrl.onLoadAction();


				//*** remove product
				ApexPages.currentPage().getParameters().put('productCode', lstProduct[1].SAP_Material_Number__c);
				ctrl.removeProduct();
				ctrl.onLoadAction();

				system.assert(ctrl.vfOrder.orderItems.size() == 1, 'Wrong count, expecting 1, got ' + ctrl.vfOrder.orderItems.size() + ': ' + ctrl.vfOrder.orderItems);

				//*** continue shopping and checkout with non-compliant
				//system.assert(ctrl.continueShopping() == null, 'Continue shopping should NOT be allowed');
				//system.assert(ctrl.startCheckout() == null, 'Checkout should NOT be allowed');
			}
		Test.stopTest();
	}

	@isTest (SeeAllData=true)
	static void test_logged_in_old3()
	{
		testSetupOldShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		System.runAs(oUser)
		{
			//*** get pending cart - nothing to assert
			Test.setCurrentPage(Page.IEC_ShoppingCart);
			ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();

			//*** update quantity
			ApexPages.currentPage().getParameters().put('productCode', lstProduct[0].SAP_Material_Number__c);
			ApexPages.currentPage().getParameters().put('quantity', '-1');
			ctrl.updateProductQuantity();

			system.assert(ctrl.vfOrder.orderItems.size() == 1, 'Wrong count: ' + ctrl.vfOrder.orderItems);
		}
		Test.stopTest();
	}

	@isTest (SeeAllData=true)
	static void test_logged_in_old4()
	{
		testSetupOldShoppingCart();

		//*** create portal user
		User oUser = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		//*** create locations
		Contact oContact = new Contact_Sel().getContactById(oUser.ContactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = createTestLocation(oContact, lstAddress);

		//*** create products
		List<Product2> lstProduct = createTestProduct(2);

		Test.startTest();

		//*** create order
		Order oOrder = createTestOrder(oUser, oContact, lstProduct, lstLocation);

		IEC_ShoppingCartController ctrl;

		System.runAs(oUser)
		{
			//*** get pending cart - nothing to assert
			Test.setCurrentPage(Page.IEC_ShoppingCart);

			ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();
			//*** update quantity
			ApexPages.currentPage().getParameters().put('productCode', lstProduct[0].SAP_Material_Number__c);
			ApexPages.currentPage().getParameters().put('quantity', '-1');

			ctrl.updateProductQuantity();
			ctrl.onLoadAction();

			system.assert(ctrl.vfOrder.orderItems.size() == 1, 'Wrong count, expecting 1 got ' + ctrl.vfOrder.orderItems.size() + ': ' + ctrl.vfOrder.orderItems);
			/*
			ApexPages.currentPage().getParameters().put('productCode', lstProduct[1].SAP_Material_Number__c);
			ApexPages.currentPage().getParameters().put('quantity', '5');
			ctrl.updateProductQuantity();
			ctrl.onLoadAction();

			system.assert(ctrl.vfOrder.orderItems.size() == 1 && ctrl.vfOrder.orderItems[0].quantity == 5, 'Wrong quantity: ' + ctrl.vfOrder.orderItems);
			*/
			//*** continue shopping and checkout
			system.assert(ctrl.continueShopping() != null, 'Continue shopping should be allowed');
			system.assert(ctrl.startCheckout() != null, 'Checkout should be allowed');
			Test.stopTest();
		}
	}
}
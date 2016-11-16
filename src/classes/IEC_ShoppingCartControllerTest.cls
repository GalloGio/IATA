@isTest
private class IEC_ShoppingCartControllerTest 
{
	@isTest
	static void test_cart_empty()
	{
		Test.setCurrentPage(Page.IEC_ShoppingCart);
		IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController(); 
		ctrl.vfOrder = new Order_DTO();
		System.assertEquals(true, ctrl.isCartEmpty);
	}

	@isTest (SeeAllData=true)
	static void test_not_logged_in()
	{
		Test.setCurrentPage(Page.IEC_ShoppingCart);

		//-- Generate ecom products & add to cookie
		List<Product2> products = TestDataGenerator.generateProductsWithPrice(2);
		for(Integer x =0; x < products.size(); x++)
		{
			Product2 p = products[x];
			p.Post_to_Ecommerce_Date__c = Date.today().addDays(-1);
			p.Sell_through_eCommerce__c = true; 
			p.Inventory_Status__c = 'In stock';
			p.Status__c = (Math.mod(x,2)==0) ? 'A' : 'Z4';
			p.Line_of_Business__c = (Math.mod(x,2)==0) ? 'Publications' : 'GDP';
			p.Mega_Menu__c = (Math.mod(x,2)==0) ? 'publications' : 'data-and-statistics';
			p.Refinement_Language__c = (Math.mod(x,2)==0) ? 'English' : 'French';

			//-- Add products into cookies
			IECOrder_Svc.addProductToCookie(p.SAP_Material_Number__c, 1, true);
		}
		update products;

		//-- Simulate product already exist 
		ApexPages.currentPage().getParameters().put('productCode', products[0].SAP_Material_Number__c);


		//-- Load Page
		IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController(); 
		ctrl.onLoadAction();

		//-- Validate 2 items in carts 
		//System.assertEquals(2, ctrl.vfOrder.orderItems.size());

		try{
			//-- Update quantiy for 1st item
			ApexPages.currentPage().getParameters().put('quantity', '2');
			ApexPages.currentPage().getParameters().put('productCode', ctrl.vfOrder.orderItems[0].productCode);
			ctrl.updateProductQuantity();
			System.assertEquals(2,ctrl.vfOrder.orderItems[0].quantity);

			

			//-- Remove 2nd item from cart 
			ApexPages.currentPage().getParameters().put('productCode', ctrl.vfOrder.orderItems[1].productCode);
			ctrl.removeProduct();
			System.assertEquals(1,ctrl.vfOrder.orderItems.size());

			//-- Continue Shopping 
			ctrl.continueShopping();
		}
		catch(Exception ex){}
	}

	@isTest (SeeAllData=true)
	static void test_logged_in() 
	{
		Test.setCurrentPage(Page.IEC_ShoppingCart);

		//-- Generate ecom products & add to cookie
		Test.startTest();
			List<Product2> products = TestDataGenerator.generateProductsWithPrice(2);
			for(Integer x =0; x < products.size(); x++)
			{
				Product2 p = products[x];
				p.Post_to_Ecommerce_Date__c = Date.today().addDays(-1);
				p.Sell_through_eCommerce__c = true; 
				p.Inventory_Status__c = 'In stock';
				p.Status__c = (Math.mod(x,2)==0) ? 'A' : 'Z4';
				p.Line_of_Business__c = (Math.mod(x,2)==0) ? 'Publications' : 'GDP';
				p.Mega_Menu__c = (Math.mod(x,2)==0) ? 'publications' : 'data-and-statistics';
				p.Refinement_Language__c = (Math.mod(x,2)==0) ? 'English' : 'French';

				//-- Add products into cookies
				IECOrder_Svc.addProductToCookie(p.SAP_Material_Number__c, 1, true);
			}
			update products;

			User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		Test.stopTest();

		System.runAs(usr)
		{
			IECOrder_Svc.addProductToCookie(products[0].SAP_Material_Number__c, 1, true);
			IECOrder_Svc.addProductToCookie(products[1].SAP_Material_Number__c, 1, true);

			IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController();
			ctrl.onLoadAction();

			try{
				//-- Remove 2nd item from cart 
				ApexPages.currentPage().getParameters().put('productCode', ctrl.vfOrder.orderItems[1].productCode);
				ctrl.removeProduct();
				System.assertEquals(1,ctrl.vfOrder.orderItems.size());

				//--Start Checkout 
				ctrl.startCheckout();
			}
			catch(Exception ex){}
		}
	}

	@isTest 
	static void test_renewal_link_not_logged() 
	{
		//-- Create Renewal 
		Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Contact oContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true)[0];
		Order oOrder = TestDataGenerator.generateOrder(1, oAccount.Id, oContact.Id, oContact.Id,true)[0];
		
		//-- Go to Shopping cart without loggin 
		Test.setCurrentPage(Page.IEC_ShoppingCart);
		IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController(); 
		ApexPages.currentPage().getParameters().put('order', oOrder.Id);
		System.assert(ctrl.pageParams.containsKey('order'));

		System.assertEquals(null, ctrl.loggedCustomer);
		ctrl.onLoadAction();

		//-- Start checkout 
		ctrl.startCheckout();
	}	

	@isTest (SeeAllData=true)
	static void test_renewal_link_logged() 
	{
		
		//-- Create portal user		
		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		if(usr.Id == null )insert usr; 

		Contact oContact = new Contact_Sel().getContactById(usr.contactId);
		//-- Generate locations
		List<IECAddress__c> addresses = TestDataGenerator.generateAddresses(2, true);
		Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
		Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, addresses[0].Id, oContact.AccountId,  usr.contactId);
		
		oContact.BillTo_Location__c = billToLocation.Id;
		oContact.ShipTo_Location__c = shipToLocation.Id;
		update oContact;
		

		//-- Create REnewal
		Account oAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Order oOrder = TestDataGenerator.generateOrder(1, oAccount.Id, usr.contactId, usr.contactId,false)[0];
		oOrder.OwnerId = usr.Id;
		oOrder.Type = 'Renewal Notification';
		insert oOrder;

		Test.startTest();
			System.runAs(usr)
			{
				Test.setCurrentPage(Page.IEC_ShoppingCart);
				IEC_ShoppingCartController ctrl = new IEC_ShoppingCartController(); 
				ApexPages.currentPage().getParameters().put('order', oOrder.Id);
				System.assert(ctrl.pageParams.containsKey('order'));
				ctrl.onLoadAction();
			}
		Test.stopTest();
	}
}
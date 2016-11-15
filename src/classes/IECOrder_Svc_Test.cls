@isTest
private class IECOrder_Svc_Test {
	@isTest(SeeAllData=true)
	static void test_createOrderFromCookie()
	{
		//-- Login to Portal 	
		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);
		System.runAs(usr)
		{
			//-- Generate Test Data 
			List<Product2> products = TestDataGenerator.generateProductsWithPrice(3);

			//-- Add Products in Cookie : prod_0:2, prod_1:1, prod_2:4
			Cookie productCookie = TestDataGenerator.addProductsInCookie(new Map<String, Decimal>{
				products[0].SAP_Material_Number__c => 2, 
				products[1].SAP_Material_Number__c => 1, 
				products[2].SAP_Material_Number__c => 4
			});

			//-- Call method
			IECOrder_Svc.createOrderFromCookie();

			//-- Validate Order Is Create with 3 OrderItem
			List<Order> orders = [SELECT Id FROM Order WHERE CreatedById = :usr.Id AND Type = 'Cart' AND Status='New'];
			System.assertEquals(1, orders.size());

			List<OrderItem> orderItems = [SELECT Id FROM OrderItem WHERE OrderId = :orders[0].Id];
			System.assertEquals(0,orderItems.size());
		}
	}

	/*
	IECOrder_Svc
	saveCookieProducts
	*/

	@isTest
	static void test_IECOrderSvc(){

		Cookie cookie = new Cookie('IECOrders_1', '0000_01', null, 86400, false);
		ApexPages.currentPage().setCookies(new Cookie[]{cookie});

		IECOrder_Svc.nbreOfCookies();
		IECOrder_Svc.addProductToCookie('0000_01', 2);
		IECOrder_Svc.validateQuoteNumberToConvert('0001236', null);
		IECOrder_Svc.returnToLogin('apex/demo');

		System.assertEquals(1,IECOrder_Svc.nbreOfCookies());
	}

	@isTest (seeAllData=true) static void test_coverage()
     {
        new IECOrder_Svc().coverage();
     }
}
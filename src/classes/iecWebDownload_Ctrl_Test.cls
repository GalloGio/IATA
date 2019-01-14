@isTest
public with sharing class iecWebDownload_Ctrl_Test {
	
	@isTest (SeeAllData = true)
	static void test_iecWebDownload_Ctrl(){

		User usr = IECTestUtil.createSampleGuestUserAndLogin(IECConstants.Account_ClientType_MemberAirline);

		iecWebDownload_Ctrl iecWebDownloadNot = new iecWebDownload_Ctrl();
		iecWebDownloadNot.pageLoad();
		
		System.runAs(usr){
			
			// Create Orders 
			TestDataGenerator.generateApexSetting();
			List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
			List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
			//List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, contacts[1].Id,true); // 1 Order
			List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, usr.ContactId, true); // 1 Order
			List<OrderItem> orderItems = TestDataGenerator.generateWebDownloadOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order
			
			set<Id> oiIds = new set<Id>();
			for(OrderItem oi : orderItems){
				oiIds.add(oi.Id);
			}

			orderItems = [SELECT id, OrderItemNumber, Product__c from OrderItem where id in :oiIds ];

			PageReference pageRef = Page.iecWebDownload;
			Test.setCurrentPage(pageRef);
			ApexPages.currentPage().getParameters().put('itemNumber',orderItems[0].OrderItemNumber);

			iecWebDownload_Ctrl iecWebDownload = new iecWebDownload_Ctrl();
			iecWebDownload.pageLoad();
			iecWebDownload.accessKeyId = 'accessKeyId';
			iecWebDownload.secretAccessKey = 'secretAccessKey';

			iecWebDownload_Ctrl.updateOrderItemDownloadNumber(orderItems[0].OrderItemNumber, 'OneTimeWebDownload/9648-53/Visio-Quote_Business_Process.pdf');


			System.assertEquals(1*24*60*60,iecWebDownload.expires);
			System.assertEquals(1,orders.size());
			System.assertEquals(3,orderItems.size());

			//Cover the File upload to Amazon
			List<Product2> products = [SELECT id,SAP_Material_Number__c from Product2 where id =:orderItems[0].Product__c];
			
			PageReference pageRe = Page.iecWebUpload;
			Test.setCurrentPage(pageRe);
			ApexPages.currentPage().getParameters().put('id',products[0].Id);

			iecWebUpload_Ctrl webUpdoad = new iecWebUpload_Ctrl(new ApexPages.StandardController(products[0]));
			String s3Url = 'https://publications-nonprod-0dc549c78af932bd.s3.amazonaws.com/OneTimeWebDownload/9648-53/Z-Tax%20Instructions.pdf';
			iecWebUpload_Ctrl.getS3Values(products[0].Id,'UPLOADED.', s3Url);

			iecWebUpload_Ctrl iecWebUpload = new iecWebUpload_Ctrl();
			iecWebUpload.accessKeyId = 'accessKeyId';
			iecWebUpload.secretAccessKey = 'secretAccessKey';

			List<Product2> lstProduct = [SELECT id,SAP_Material_Number__c,File_Path__c from Product2 where id =:orderItems[0].Product__c];
			System.assert(lstProduct[0].File_Path__c != null,'The file path cannot be null');

			iecWebUpload_Ctrl.backToRegularProduct(lstProduct[0].Id);
			lstProduct = [SELECT id,SAP_Material_Number__c,File_Path__c from Product2 where id =:lstProduct[0].Id];
			System.assertEquals(lstProduct[0].File_Path__c,null);

		}



	}

}
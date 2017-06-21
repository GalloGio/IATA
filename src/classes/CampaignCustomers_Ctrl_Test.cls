@isTest
public class CampaignCustomers_Ctrl_Test 
{
	@isTest(SeeAllData=true) 
	static void test_CustomerFiltering() 
	{	
		//-- generate test data 

		//Custom settings
		TestDataGenerator.generateApexSetting();
		TestDataGenerator.generateISOCountryState();

		test.startTest();
		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		if(usr.Id == null)insert usr;

		//Create location for the customer
		Contact oContact = new Contact_Sel().getContactById(usr.contactId);
		List<IECAddress__c> lstAddress = TestDataGenerator.generateAddresses(1, true);
		List<Location__c> lstLocation = new List<Location__c>();
		lstLocation.add(new Location__c(Type__c='Sold To', Address__c=lstAddress[0].Id, Account__c=oContact.AccountId, SAP_Id__c='sold1'));
		lstLocation.add(new Location__c(Type__c='Bill To', Address__c=lstAddress[0].Id, Account__c=oContact.AccountId, Contact__c=oContact.Id, SAP_Id__c='bill1'));
		lstLocation.add(new Location__c(Type__c='Ship To', Address__c=lstAddress[0].Id, Account__c=oContact.AccountId, Contact__c=oContact.Id, SAP_Id__c='ship1'));
		insert lstLocation;
		update new Account(Id=oContact.AccountId, SoldTo_Location__c=lstLocation[0].Id);
		update new Contact(Id=oContact.Id, BillTo_Location__c=lstLocation[1].Id, ShipTo_Location__c=lstLocation[2].Id);

		//Products
		List<Product2> products = TestDataGenerator.generateProducts(5, false);
		for(Integer x =0; x < products.size(); x++)
		{
			Product2 p = products[x];
				p.Post_to_Ecommerce_Date__c = Date.today().addDays(-1);
				p.Sell_through_eCommerce__c = true; 
				p.Recommended__c = true;
				p.Inventory_Status__c = 'In stock';
				p.Status__c = (Math.mod(x,2)==0) ? 'A' : 'Z4';
				p.Line_of_Business__c = (Math.mod(x,2)==0) ? 'Publications' : 'GDP';
		}
		upsert products SAP_Material_Number__c;

		//Orders & OrderItems
		List<Order> orders = TestDataGenerator.generateOrder(1, oContact.AccountId, usr.contactId, usr.contactId, false); 
		orders[0].Type = 'Order';
		orders[0].Status = 'Order Created';
		orders[0].SoldTo_Location__c = lstLocation[0].Id;
		orders[0].BillTo_Location__c = lstLocation[1].Id;
		orders[0].ShipTo_Location__c = lstLocation[2].Id;
		insert orders;
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, products, true);

		List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        	listCS.add(new Apex_Setting__c(Name='ContactId to populate email Template', Text_1__c=usr.contactId));
    	insert listCS;

		//Campaigns
		List<Campaign> campaigns = TestDataGenerator.generateCampaigns(2, false);
		for(Integer x = 0; x < campaigns.size(); x++)
		{
			Campaign c = campaigns[x];
				c.IsActive = true;
		}
		insert campaigns;

		Test.stopTest();
		//-- Call controller methods 
		Test.setCurrentPage(new PageReference('/apex/CampaignCustomers'));
		CampaignCustomers_Ctrl ctrl = new CampaignCustomers_Ctrl(); 
		
		//-- Validate there is 5 available products 
		System.assert(ctrl.availableProducts.size() >= 5);

		//-- Validate there is 2 active campaign
		System.assert(ctrl.campaigns.size() >= 2);

		//-- Validate nothing selected by default
		System.assertEquals(null, ctrl.campaignId);
		System.assertEquals(null, ctrl.selectedProducts);
		System.assertEquals(null, ctrl.startDate);
		System.assertEquals(null, ctrl.endDate);
		System.assertEquals(null, ctrl.selectedCustomerTypes);
		System.assertEquals(null, ctrl.selectedRegions);
		System.assertEquals(null, ctrl.selectedCountries);
		System.assertEquals(null, ctrl.minUnit);
		System.assertEquals(null, ctrl.maxUnit);
		System.assertEquals(null, ctrl.minVolume);
		System.assertEquals(null, ctrl.maxVolume);

		//-- Select first campaign 
		ctrl.campaignId = campaigns[0].Id; 
		
		
		//-- Select 3 products 
		ApexPages.currentPage().getParameters().put('productsNumbers',products[0].SAP_Material_Number__c + '_' + products[1].SAP_Material_Number__c+ '_' + products[2].SAP_Material_Number__c);
		ctrl.selectProducts();
		System.assertEquals(3, ctrl.selectedProducts.size());

		//-- Remove 1 product 
		ApexPages.currentPage().getParameters().put('productsNumbers',products[2].SAP_Material_Number__c);
		ctrl.removeProducts();
		System.assertEquals(2, ctrl.selectedProducts.size());

		//-- Generate Campaign Members & Campaign Products 
		//Test.startTest();
			ctrl.generateCampaignMembers();
		
		//Create Campaign Members
		CampaignMember cm = new CampaignMember(
			CampaignId = campaigns[0].Id,
			ContactId = usr.ContactId
		);
		insert cm;

		List<Id> lstSelectedProdId = new List<Id>();
		for (Integer id : ctrl.selectedProducts.keySet())
			lstSelectedProdId.add(ctrl.selectedProducts.get(Id).id);
		orderItems = [select Id, PriceBookEntryId, OrderId, Quantity, UnitPrice, Charge_Shipping__c, ServiceDate, Product__c, Invoice_Date__c, Order.BillToContactId
		              from OrderItem where OrderId = :orders[0].Id and PricebookEntry.Product2.Id in :lstSelectedProdId];

		insert new CampaignMember(CampaignId = campaigns[1].Id, ContactId = usr.ContactId );
		CampaignMembers_Batch batch = new CampaignMembers_Batch('renewalNotice', campaigns[1].Id, campaigns[1].Campaign_AutoNumber__c);
		Database.executeBatch(batch);

		//-- Generate Campaign_Member_Product__c to validate no-duplicates 
		//String key = ctrl.campaignId+'_'+contacts[0].Id+'_'+products[0].Id; 
		String key = ctrl.campaignId+'_'+ usr.ContactId +'_'+products[0].Id; 

		Campaign_Member_Product__c cmp1 = new Campaign_Member_Product__c(
            Campaign__c = ctrl.campaignId,
            Contact__c  = usr.ContactId, //contacts[0].Id,
            Product__c  = products[0].Id,
            Quantity__c = 2,
            Key__c = key,
            Invoice_Date__c = Date.today().addDays(-7)
        );
        insert cmp1;

        Campaign_Member_Product__c cmp2 = new Campaign_Member_Product__c(
            Campaign__c = ctrl.campaignId,
            Contact__c  = usr.ContactId, //contacts[0].Id,
            Product__c  = products[0].Id,
            Quantity__c = 4,
            Key__c = key,
            Invoice_Date__c = Date.today().addDays(-5)
        );
        insert cmp2;

        CampaignMemberProduct_Svc.removeDuplicates(new Set<String>{key});
        for (Integer i1 = orderItems.size() - 1; i1 >= 0; i1--)
        {
            orderItems.add(orderItems[i1].clone(false, true));
            orderItems[orderItems.size() - 1].Invoice_Date__c = Date.today().addDays(10);
        }
        cmp1.Id = null;
        cmp1.Key__c = campaigns[0].Id+'_'+ usr.ContactId +'_'+orderItems[0].Product__c;
        insert cmp1;
        cmp2.Id = null;
        cmp2.Key__c = campaigns[0].Id+'_'+ usr.ContactId +'_'+orderItems[0].Product__c;
        insert cmp2;
        CampaignMemberProduct_Svc.generateCampaignMemberProducts(campaigns[0].Id,orderItems);


		//System.assertEquals(1, [SELECT Id FROM CampaignMember WHERE CampaignId = :campaigns[0].Id].size());
		//System.assertEquals(2,[SELECT id from Campaign_Product__c where Campaign__c =:campaigns[0].Id].size());

		Campaign campaign = [select id, Campaign_AutoNumber__c from Campaign where id =:campaigns[0].Id ];

		System.debug('campaign ' + campaign);

		List<Campaign_Member_Product__c> lstCampaignMemberProduct = [select id, Product__c from Campaign_Member_Product__c where Campaign__c =:campaign.Id];
		System.debug('lstCampaignMemberProduct ' + lstCampaignMemberProduct);

		Campaign_Product__c cp = new Campaign_Product__c(
			Campaign__c = campaigns[0].Id,
			Product__c = lstCampaignMemberProduct[0].Product__c,
			Product_Last_Version__c = lstCampaignMemberProduct[0].Product__c
		);
		insert cp;

		CampaignProduct_Sel  campProdSel = new CampaignProduct_Sel();
		campProdSel.getProductIdsByCampaign(new Set<Id>{campaigns[0].Id});
		//System.debug('campProdSel ' + campProdSel);
		campaign.Generate_Members_Completed_On__c = Datetime.now();
		update campaign;


		
		Campaign_Svc.generateRenewalNotice(campaign.Id, campaign.Campaign_AutoNumber__c);
		CampaignMember_Svc.generateRenewalOrder(campaign.Id, new List<CampaignMember>{cm});

		CampaignMember_Svc.generateCampaignMembers(campaign.Id, orderItems);
		


		////Cover the sendBatchFinishNotification Class in CampaignMember_Svc
		List<EmailTemplate> lstEmailTemplate = TestDataGenerator.generateTemplate(1, false);
		try{
			CampaignMember_Svc.sendBatchFinishNotification(new List<String> {'test@test.ca'},campaigns[0].Campaign_AutoNumber__c,UserInfo.getName(),lstEmailTemplate[0]);
		}
		catch(Exception ex){}
	}
}
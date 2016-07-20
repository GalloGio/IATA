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

		User usr = IECTestUtil.createSampleGuestUserAndLogin();
		insert usr;

		//Create location for the customer
		Location_Svc.InitializeContactLocations(usr.ContactId);

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
		insert products;

		//Orders & OrderItems
		List<Account> accounts = TestDataGenerator.generateAccounts(1,true);
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,1,true);
		List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, usr.ContactId, usr.ContactId,true); 
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, products, true);

		List<Apex_Setting__c> listCS = new List<Apex_Setting__c>();
        	listCS.add(new Apex_Setting__c(Name='ContactId to populate email Template', Text_1__c=contacts[0].Id));
    	insert listCS;

		//Campaigns
		List<Campaign> campaigns = TestDataGenerator.generateCampaigns(2, false);
		for(Integer x = 0; x < campaigns.size(); x++)
		{
			Campaign c = campaigns[x];
				c.IsActive = true;
		}
		insert campaigns;


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
		Test.startTest();
			ctrl.generateCampaignMembers();
		

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


		//System.assertEquals(1, [SELECT Id FROM CampaignMember WHERE CampaignId = :campaigns[0].Id].size());
		//System.assertEquals(2,[SELECT id from Campaign_Product__c where Campaign__c =:campaigns[0].Id].size());

		Campaign campaign = [select id, Campaign_AutoNumber__c from Campaign where id =:campaigns[0].Id ];

		CampaignProduct_Sel  campProdSel = new CampaignProduct_Sel();
		campProdSel.getProductIdsByCampaign(new Set<Id>{campaigns[0].Id});

		Campaign_Svc.generateRenewalNotice(campaign.Id, campaign.Campaign_AutoNumber__c);
Test.stopTest();
		//Cover generateRenewalNotice
		Campaign_Svc.generateRenewalNotice(campaigns[0].Id, campaigns[0].Campaign_AutoNumber__c);

		//Cover the sendBatchFinishNotification Class in CampaignMember_Svc
		List<EmailTemplate> lstEmailTemplate = TestDataGenerator.generateTemplate(1, false);
		CampaignMember_Svc.sendBatchFinishNotification(new List<String> {'test@test.ca'},campaigns[0].Campaign_AutoNumber__c,UserInfo.getName(),lstEmailTemplate[0]);

	}
}
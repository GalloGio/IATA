@isTest 
private class MiniDeploymentCoverage_Test {
  @isTest (seeAllData=true)
  static void test_ZuoraUtil() {
    //-- Call zquery
    List<Zuora.zObject> lst_zquery = ZuoraUtil.zquery('SELECT ABC','Account',1);

    //-- Call zupdate
    List<Zuora.zApi.SaveResult> lst_zupdate = ZuoraUtil.zupdate(lst_zquery);

    //-- Call zdelete 
    List<Zuora.zApi.DeleteResult> lst_zdelete =  ZuoraUtil.zdelete('Account', new List<String>{'Id1', 'Id2'});

    ///-- Cal zsubscribe 
    List<Zuora.zApi.SubscribeResult> lst_subscribe = ZuoraUtil.zsubscribe(new List<Zuora.zApi.SubscribeRequest>());

  }
  
  @isTest
  static void test_PricebookEntry_Sel() {

    //insert a new product
    Product2 p = new product2(name='product1');
    insert p;

    //define the standart price for the product
    //Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];

    insert new PricebookEntry(pricebook2id = Test.getStandardPricebookId(), product2id = p.id,unitprice=1.0, isActive=true);

    Pricebook2 pb = new pricebook2(name='test');
    insert pb;

    PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=p.id,unitprice=1.0, isActive=true);
    insert pbe;

    Map<Id, PricebookEntry> pbe_sel = new PricebookEntry_Sel().getPricebookEntryByProductId(pbe.Id, new set<Id>{p.Id});
  }

  @isTest (seeAllData=true)
  static void test_Contact_Sel()
  {
    List<Account> accounts   = TestDataGenerator.generateAccounts(1,true); // 1 Account
    List<Contact> contacts   = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts

    Contact_Sel selector = new Contact_Sel();
    Contact ct1 = selector.getContactById(contacts[0].Id);
    Map<Id,Id> accountByContact = Contact_Sel.getAccountIdByContactId(new Set<Id>{contacts[0].Id, contacts[1].Id});
    Map<Id,Contact> contactById = Contact_Sel.getContactById(new Set<Id>{contacts[0].Id, contacts[1].Id});
  }

  @isTest (seeAllData=true)
  static void test_ProductRatePlanCharge_Sel(){
    
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

    list<zqu__ProductRatePlanCharge__c> prpc = ProductRatePlanCharge_Sel.getChargesToSetToZero(ratePlan.Id, charge.Id);

    List<zqu__ProductRatePlanCharge__c> prpc2 = ProductRatePlanCharge_Sel.getProductRatePlanChargeByRatePlanId(new set<Id>{ratePlan.Id});

    Map<String,String> prpc3 = ProductRatePlanCharge_Sel.getProductRatePlanChargeModelByZuoraId(new set<String>{charge.zqu__ZuoraId__c});

  }

  @isTest
  static void test_OrderItemCharge_DTO()
  {
    //-- Generate Test Data
    List<Account> accounts         = TestDataGenerator.generateAccounts(1,true); // 1 Account
    List<Contact> contacts         = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
    List<Order> orders           = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
    List<OrderItem> orderItems       =  TestDataGenerator.generateOrderItem(orders[0].Id, 1,true);
    List<Order_Item_Charge__c> charges  = TestDataGenerator.generateOrderItemCharge(orderItems[0].Id, 1, true);

    List<OrderItemCharge_DTO> charge_dtos = OrderItemCharge_DTO.format2DTO(charges);
    List<OrderItem_DTO> item_dtos = OrderItem_DTO.format2DTO(orderItems);
    item_dtos.sort();

    OrderItem_DTO item_dto = OrderItem_DTO.format2DTO(orderItems[0], charges);

    Map<Id, List<Order_Item_Charge__c>> chargesByItem = new Map<Id, List<Order_Item_Charge__c>>{
      orderItems[0].Id => charges
    };

    List<OrderItem_DTO> item_dtos2 = OrderItem_DTO.format2DTO(orderItems, chargesByItem);

  }

  @isTest
  static void test_OrderItem_DTO()
  {
    //-- Generate Test Data
    List<Account> accounts         = TestDataGenerator.generateAccounts(1,true); // 1 Account
    List<Contact> contacts         = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
    List<Order> orders           = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
    List<OrderItem> orderItems       =  TestDataGenerator.generateOrderItem(orders[0].Id, 1,true);
    List<Order_Item_Charge__c> charges  = TestDataGenerator.generateOrderItemCharge(orderItems[0].Id, 1, true);

    List<OrderItemCharge_DTO> dto = OrderItemCharge_DTO.format2DTO(charges);
  }


  @isTest
  static void test_Mail_DTO()
  {
    Mail_DTO dto = new Mail_DTO();
        dto.targetObjectId = '';
      dto.whatId = '';
      dto.templateId = '';
        dto.orgWideEmailAddressId = '';
      dto.recipients = new List<String>{''};
  }

  @isTest (seeAllData = true)
  static void test_Discount_DTO(){
        
        List<Product2> lstProducts = TestDataGenerator.generateProductsWithPrice(1);
    
        List<zqu__ProductRatePlanChargeTier__c> lstPrpct = [select id, ZCharge_Model__c, ZRatePlan_IsFreeShipping__c, zqu__Price__c,
                                                   ZRatePlan_ZuoraId__c, ZCharge_ZuoraId__c, ZRatePlan_CustomerType__c,
                                                   ZRatePlan_Region__c, ZRatePlan_Country__c, ZRatePlan_CouponCode__c
                                                   from zqu__ProductRatePlanChargeTier__c 
                                                  where ZCharge_Model__c != null limit 1];
        
        Discount_DTO discountDtoWithParam = new Discount_DTO();
        if(lstPrpct != null && lstPrpct.size() > 0){
            discountDtoWithParam = new Discount_DTO(lstPrpct[0]);
        }    
        
        Discount_DTO.createChargeRecord(discountDtoWithParam);

  }
  
}
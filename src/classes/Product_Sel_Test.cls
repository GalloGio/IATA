@isTest
private class Product_Sel_Test
{
    @isTest (seeAllData=true)
    static void test_getProductPriceInfo_and_getProductByZproduct()
    {
        TestDataGenerator.generateApexSetting(); 

        

        //-- generate Products 
        zqu__ZProduct__c zProduct = TestDataGenerator.generateZProducts(1, false)[0];
        zProduct.SAPProductMaterialNo__c = '99999-99';
        insert zProduct;

        Product2 product  = TestDataGenerator.generateProducts(1, false)[0];
            product.ZProduct__c = zProduct.Id; 
            product.SAP_Material_Number__c = '99999-99';
        insert product; 

        //-- generate 6 Rate plans: standard, CustomerType, Coupon, Region, Country, presale
        List<zqu__ProductRatePlan__c> zRatePlans = TestDataGenerator.generateZRatePlans(zProduct.Id,6,false);
            zRatePlans[1].CustomerType__c = 'Member';
            zRatePlans[2].Couponcode__c = 'COUP-0007';
            zRatePlans[3].Region__c = 'Africa & Middle East';
            zRatePlans[4].Country__c = 'Canada'; 
            zRatePlans[5].IsPreSale__c = 'Yes'; 
        insert zRatePlans;     

        //-- generate Charges for each plan 
        //Standard Charges: UnitPrice + Volume Price 
        List<zqu__ProductRatePlanCharge__c> stdZCharges = TestDataGenerator.generateZCharges(zRatePlans[0].Id, 2, false);
            stdZCharges[0].zqu__Model__c = 'Per Unit';
            stdZCharges[1].zqu__Model__c = 'Volume';

        //Customer Type Charge : percentage Discount 
        zqu__ProductRatePlanCharge__c ctZCharge = TestDataGenerator.generateZCharges(zRatePlans[1].Id, 1, false)[0];
            ctZCharge.zqu__Model__c = 'Discount-Percentage';

        //Coupon Code Charge : Amount discount 
        zqu__ProductRatePlanCharge__c ccZCharge = TestDataGenerator.generateZCharges(zRatePlans[2].Id, 1, false)[0];
            ccZCharge.zqu__Model__c = 'Discount-Fixed Amount';

        //Region Charge: percentage discount 
        zqu__ProductRatePlanCharge__c rZCharge = TestDataGenerator.generateZCharges(zRatePlans[3].Id, 1, false)[0];
            rZCharge.zqu__Model__c = 'Discount-Percentage';

        //Country Charge: Ammount discount 
        zqu__ProductRatePlanCharge__c cZCharge = TestDataGenerator.generateZCharges(zRatePlans[4].Id, 1, false)[0];
            cZCharge.zqu__Model__c = 'Discount-Fixed Amount';

        //PreSale Charge:percentage discount 
        zqu__ProductRatePlanCharge__c psZCharge = TestDataGenerator.generateZCharges(zRatePlans[5].Id, 1, false)[0];
            psZCharge.zqu__Model__c = 'Discount-Percentage';

        List<zqu__ProductRatePlanCharge__c> zCharges = new List<zqu__ProductRatePlanCharge__c>{
            stdZCharges[0],stdZCharges[1],ctZCharge,ccZCharge,rZCharge,cZCharge,psZCharge
        };
        insert zCharges;

        //-- Generate Tiers 

        zqu__ProductRatePlanChargeTier__c stdUnitPriceTier = TestDataGenerator.generateZTiers(stdZCharges[0].Id, 1, false)[0];
        List<zqu__ProductRatePlanChargeTier__c> stdVolumeTiers = TestDataGenerator.generateZTiers(stdZCharges[1].Id, 2, false);
        zqu__ProductRatePlanChargeTier__c ctZTier = TestDataGenerator.generateZTiers(ctZCharge.Id, 1, false)[0];
        zqu__ProductRatePlanChargeTier__c ccZTier = TestDataGenerator.generateZTiers(ccZCharge.Id, 1, false)[0];
        zqu__ProductRatePlanChargeTier__c rZTier = TestDataGenerator.generateZTiers(rZCharge.Id, 1, false)[0];
        zqu__ProductRatePlanChargeTier__c cZTier = TestDataGenerator.generateZTiers(cZCharge.Id, 1, false)[0];
        zqu__ProductRatePlanChargeTier__c psZTier = TestDataGenerator.generateZTiers(psZCharge.Id, 1, false)[0];


        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>{
            stdUnitPriceTier, stdVolumeTiers[0], stdVolumeTiers[1], ctZTier, ccZTier, rZTier, cZTier, psZTier
        };
        insert zTiers;


        //IEC_Product_Rate_Plan_Information__c myRatePlanInfo = 
        List<EComProduct_DTO> products = Product_Sel.getEComProduct(null, false, 'IEC_Product_Information__c != null AND IEC_Product_Rate_Plan_Information__c != null', null, true, null);
        

        Test.startTest();
            Product_Sel pSelector = new Product_Sel(); 
            
            Map<String, PriceInfo_DTO> result = pSelector.getProductPriceInfo(new Set<String>{'99999-99'}, null,null,null,true);

            Map<Id,Product2> result1 = pSelector.getProductByZproduct(new List<Id>{product.Id});

            Map<String, Product2> result2 = Product_Sel.getProductsByProductRatePlan(new set<String>{'123456789'});

        Test.stopTest();

        //-- Call method
        
        
        

        //-- Assertions 

    }

    @isTest (seeAllData=true) static void test_selectById_and_getProductById_and_getProducts_and_getDirectSaleProducts() 
    {
        TestDataGenerator.generateUtilitySetting();
        
        //-- Generate Test Data
        Product2 ProdA = new Product2(
            Name = 'Product A',
            SAP_Material_Number__c = '1212',
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'
        ); 
        Product2 ProdB = new Product2(
            Name = 'Product B',
            SAP_Material_Number__c = '2323',
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'
        ); 

        Product2 ProdC = new Product2(
            Name = 'Product C',
            SAP_Status_Code__c = 'A',
            SAP_Product_Type_Code__c = '07',
            Inventory_Status__c = 'In stock',
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House',
            SAP_Material_Number__c = '4321',
            Post_to_Ecommerce_Date__c = Date.newInstance(2016, 11, 20)
        ); 

        insert new List<Product2>{ProdA, ProdB};
        insert ProdC;

        //-- Call Method 
        Product_Sel prodSelector = new Product_Sel(); 
        List<Product2> result = prodSelector.selectById(new Set<Id>{ProdA.Id, ProdB.Id}); 
        List<Product2> result2 = prodSelector.selectById(new Set<Id>{ProdA.Id, ProdB.Id}, new List<String>{'Id'});
        Map<Id,Product2> result3 = prodSelector.getProductById(new Set<Id>{ProdA.Id, ProdB.Id});
        List<Product2> result4 = prodSelector.getProducts('SAP_Material_Number__c != null',null,null,null);
        List<Product2> result5 = prodSelector.getProducts('SAP_Material_Number__c != null',null,5,0);
        List<EComProduct_DTO> result6 = prodSelector.getDirectSaleProducts(null);
        list<Product2> result7 = Product_Svc.productsToSendToSAP(new list<Product2>{ProdA,ProdB,ProdC});
        Set<Id> result8 = Product_Sel.getNonCompliantProductId(new Set<Id>{ProdA.Id, ProdB.Id, ProdC.Id}, new Set<String>{'FR'}); 
        Map<Id, Product2> result9 = prodSelector.getProductLastVersions(new Set<Id>{ProdA.Id, ProdB.Id,ProdC.Id});
        List<Product2> result10 = Product_Sel.getMiniCartProducts(new Set<String>{ProdA.SAP_Material_Number__c,ProdB.SAP_Material_Number__c,ProdC.SAP_Material_Number__c});
        List<Product2> result11 = Product_Sel.getListOfProducts(new List<Id>{ProdA.Id, ProdB.Id, ProdC.Id}, true, null, null, false);
        //-- Assert
        System.assertEquals(2, result.size());

        try{
            String name = result2[0].Name;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Name'));
        }
    }

        @isTest (seeAllData=true) static void test_selectAll_and_findProducts_and_updateProductsByMaterialNumb() 
    {
        TestDataGenerator.generateUtilitySetting();
        List<Product2> prods = new List<Product2>();
        List<Product_Information__c> prodInfo = new List<Product_Information__c>();
        
        //-- Generate Test Data
        Product2 ProdA = new Product2(
            Name = 'Product A',
            SAP_Status_Code__c = 'A',
            SAP_Product_Type_Code__c = '07',
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House',
            SAP_Material_Number__c = '4321',
            Post_to_Ecommerce_Date__c = Date.newInstance(2016, 11, 20)
        ); 
        prods.add(ProdA);

        Product2 ProdB = new Product2(
            Name = 'Product B',
            SAP_Status_Code__c = 'A',
            SAP_Product_Type_Code__c = '07',
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House',
            SAP_Material_Number__c = '1234',
            Post_to_Ecommerce_Date__c = Date.newInstance(2016, 11, 20)
        ); 
        prods.add(ProdB);

        insert prods;

        // create dummy Zuora product
        zqu__ZProduct__c prod = IECTestUtil.CreateSampleProduct('Product1');
        prod.ProductAudience__c = IECConstants.ProductAudience_Zuora_NONMEMBERSINGLE;
        prod.ProductCategory__c = IECConstants.ProductCategory_SF_CACPRO;
        insert prod;

        // create dummy product category
        Product_Category__c myProdCat = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        myProdCat.Active__c = true;
        insert myProdCat;

        // create dummy product info
        Product_Information__c myProdInfo = IECTestUtil.CreateSampleProductInfo('My product', myProdCat, prod);
        myProdInfo.Product_Audience__c = IECConstants.ProductInformationAudience_MEMBERAIRLINE;
        insert myProdInfo;

        //-- Call Method 
        Product_Sel prodSelector = new Product_Sel(); 
        List<Product2> result = prodSelector.selectAll();
        List<EComProduct_DTO> result2 = Product_Sel.findProducts('Product', null, null);
        //List<Product2> result3 = Product_Sel.activeProducts();
        Map<Id, Product2> result3 = Product_Sel.getProductsByProductInfo(new set<Id>{myProdInfo.Id});
        //-- Assert

    }


    @isTest (seeAllData=true)
    static void test_format2zObject()
    {
        //-- Generate Test Data
        Product2 ProdA = new Product2(
            Name = 'Product A',
            Description = 'Description for Product A',
            SAP_Material_Number__c = TestDataGenerator.generateProductCode(),
            Effective_From__c = TestDataGenerator.DEFAULT_EFFECTIVE_START_DATE,
            Effective_To__c = TestDataGenerator.DEFAULT_EFFECTIVE_END_DATE,
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'
        ); 
        Product2 ProdB = new Product2(
            Name = 'Product B',
            Description = 'Description for Product B',
            SAP_Material_Number__c = TestDataGenerator.generateProductCode(),
            Zuora_Id__c = TestDataGenerator.generateZuoraFakeId(),
            Effective_From__c = TestDataGenerator.DEFAULT_EFFECTIVE_START_DATE,
            Effective_To__c = TestDataGenerator.DEFAULT_EFFECTIVE_END_DATE,
            Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'
        ); 

        List<Product2> lst = new List<Product2>{ProdA, ProdB};

        insert lst;

        
        //new Product_Sel().updateProducts(lst);

        //-- Call Method
        Product_Sel prodSelector = new Product_Sel(); 
        List<Zuora.zObject> zObjects = prodSelector.format2zObject(lst);

        //-- ASsert
    }
    
    /****************************************************************************************************
    Created by CGI, Kevin 2015-08-26
        Cover code of method "getProductsByCode" and ""
    ****************************************************************************************************/
    
    @isTest (seeAllData=true)
    static void test_products(){
        TestDataGenerator.generateUtilitySetting();

        List<Product2> listProd = new List<Product2>();
        listProd.add(new Product2(Name='Test 1', Product_Section__c='tst111', Division__c='division 1', Sales_Channel__c='channel 1',SAP_Material_Number__c='1245-78', Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='Test 2', Product_Section__c='tst222', Division__c='division 2',Status__c='A',SAP_Material_Number__c='7845-12',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='Test 3', Division__c='division 1', Sales_Channel__c='channel 2',Status__c='A',SAP_Material_Number__c='3265-98',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        insert listProd;

        new Product_Sel().updateProducts(listProd);
        Product_Sel.getViewAllProducts(' name = \'Test 1\' ');

        new Product_Sel().getProductCategoryMap2(null, null);
        
        listProd = [Select id,SAP_Material_Number__c from Product2 where Name LIKE 'Test%' order by Name ];
        //system.assert(listProd.size() == 3, 'Wrong number of products: ' + listProd.size());
        
        //list<Product_Status__c> productsStatus = new list<Product_Status__c>();
        //for(Product2 product : listProd){
        //    Product_Status__c prdStatus = new Product_Status__c();
        //    prdStatus.SAP_Material_Number__c = product.SAP_Material_Number__c;
        //    prdStatus.Status__c = 'In stock';
        //    prdStatus.Status_Date__c = Date.today();
        //    productsStatus.add(prdStatus);
        //}
        //insert productsStatus;
        
        set<String> prodCode = new set<String>();
        //map<String,Boolean> outofStock = new map<String,Boolean>();
        for(Product2 prd : listProd){
            prodCode.add(prd.SAP_Material_Number__c);
            //outofStock.put(prd.SAP_Material_Number__c,false);
        }
        
        Product_Sel.getProductsByCode(prodCode);
        
        /*Product_Sel.getProductsBySeachCriteria('Name',null, 'test');*/
        
        //cover the update the product status
        map<String,String> materialNumbers_status = new map<String,String>();
        materialNumbers_status.put('1245-78','In stock');
        materialNumbers_status.put('7845-12','Out of stock');
        materialNumbers_status.put('3265-98','In stock');
        /*Product_Sel.updateProductsByMaterialNumb(materialNumbers_status);*/
    }
}
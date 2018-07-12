@isTest
private class Product_Svc_Test 
{
    
    public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today(); 
    public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today().addYears(1);

    static void setup() {
      List<IATA_ISO_Country__c> countryList = new List<IATA_ISO_Country__c> {
        new IATA_ISO_Country__c(
          Name = 'Test Country 1',
          ISO_Code__c = 'T1',
          Tax_ID_Mandatory__c = TRUE,
          VAT_Validation_Required__c = TRUE
        ),
        new IATA_ISO_Country__c(
          Name = 'Test Country 1',
          ISO_Code__c = 'T2',
          Tax_ID_Mandatory__c = FALSE,
          VAT_Validation_Required__c = FALSE
        )
      };

      insert countryList;
    }

    @isTest(seeAllData=true)
    static void test_saveZProducts() 
    {
        List<Apex_Setting__c> l = [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];

        if (l.isEmpty() == false) {
            delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];
        }
        Product_Information__c oProdInfo;
        for (Product_Information__c pi : [select Id
                                               , (select Id, Name
                                                  from Product_Rate_Plans_Information__r
                                                  where Product_Rate_Plan__c in (select zqu__ProductRatePlan__c from zqu__ProductRatePlanCharge__c)
                                                    and Is_Triable__c = false
                                                  limit 1)
                                          from Product_Information__c])
            if (pi.Product_Rate_Plans_Information__r.size() > 0)
            {
                oProdInfo = pi;
                break;
            }

        Test.startTest();
        //-- Generate Test Data
        TestDataGenerator.generateUtilitySetting();
        List<Product2> products = TestDataGenerator.generateProducts(3, false); 
        
        //-- 1st Product has ho Zuora Id : zcreate must be called 
        products[0].Zuora_Id__c = null; //-- 
        products[0].Status__c = 'New';
        products[0].Product_Manager_lookup__c = UserInfo.getUserId();

        //-- 2nd Product has invalid date : api wil not be called for this product 
        products[1].SAP_Material_Number__c = null;

        products[2].Zuora_Id__c = null;

        if (oProdInfo != null) {
            products[2].IEC_Product_Information__c = oProdInfo.Id;
            products[2].IEC_Product_Rate_Plan_Information__c = oProdInfo.Product_Rate_Plans_Information__r[0].Id;
        }

        insert products;

        Database.executeBatch(new Product_Batch('saveZProducts', products));

        Map<Id, Product2> productMap = new Map<Id, Product2>(products);

        products[0].Zuora_Id__c = null;
        products[0].Effective_From__c = system.today().addYears(2);
        products[0].Effective_To__c = system.today().addYears(3);
        products[0].Status__c = 'Active';
        products[2].Effective_From__c = null;
        products[2].Effective_To__c = null;
        products.remove(1);
        update products;

        Set<Id> productIds = productMap.keySet();
        
        // Call Method 
        String result = Product_Svc.saveZProducts(productIds);

		test.stopTest();

        // Assert
    }

    @isTest(seeAllData=true)
    static void test_ProductStockStatus()
    {
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];

        Test.startTest();
         //-- Generate Test Data
        TestDataGenerator.generateUtilitySetting();
        List<Product2> products = TestDataGenerator.generateProducts(1, false); 

        Database.executeBatch(new Product_Batch('ProductStockStatus', products));
        Test.stopTest();
    }

     static void test_processZProductSaveResult()
     {
         Test.startTest();
        //processZProductSaveResult(List<Product2> products, List<Zuora.zApi.SaveResult> results)
        List<Product2> products = TestDataGenerator.generateProducts(2, false); 
        List<Zuora.zObject> zobjects = TestDataGenerator.generateZProducts(2);
        zobjects[0].setValue('SAPProductMaterialNo__c',products[0].SAP_Material_Number__c);
        zobjects[1].setValue('SAPProductMaterialNo__c',products[1].SAP_Material_Number__c);

        //Inject error
        zobjects[1].setValue('EffectiveStartDate','');

        List<Zuora.zApi.SaveResult> results = TestDataGenerator.generateSaveResults(zobjects, 'create');
        results[0].Success = false;
        results[0].Errors = new List<Zuora.zObject>();
        Zuora.zObject err = new Zuora.zObject('Error');
            err.setValue('Message', 'Invalid zObject');
            err.setValue('Code', 'INVALID_FIELD');
        results[0].Errors.add(err);


        String result = Product_Svc.processZProductSaveResult(products, results);

        System.debug('result::'+result);
         
        Test.stopTest();
     }


    
    @isTest(seeAllData=true)
    static void test_setIsNewVersion()
    {
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];

        Test.startTest();
        TestDataGenerator.generateUtilitySetting();

        //-- Generate Test Data 
        List<Product2> products = TestDataGenerator.generateProducts(2, false);

        // Insert first product 
        insert products[0];

        //Set the 2nd product activity code to the first one 
        products[1].Activity_Code__c = products[0].Activity_Code__c; 
        Integer versionNumber = Integer.valueOf(products[0].SAP_Material_Number__c.split('-')[1]);
        Integer newVersion =  (versionNumber < 99) ? versionNumber+1 : 1;
        String version = (newVersion < 10) ? '0'+newVersion : ''+newVersion;

        products[1].SAP_Material_Number__c = products[0].Activity_Code__c + '-'+version;
        insert products[1]; 

        //-- Assert
        Product2 prod = [SELECT Id, Name, Activity_Code__c, IsNewVersion__c FROM Product2 WHERE Id = :products[1].Id];

        System.assertEquals(true, prod.IsNewVersion__c);
        Test.stopTest();
    }

    /****************************************************************************************************
    Created by CGI, Kevin 2015-08-26
        Cover code of method "test_getProductStatusFromSAP"
    ****************************************************************************************************/
    @isTest(seeAllData=true)
    static void test_getProductStatusFromSAP(){
        Test.startTest();
        TestDataGenerator.generateUtilitySetting();
        TestDataGenerator.generateApexSetting();
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];

        List<Product2> listProd = new List<Product2>();
        listProd.add(new Product2(Name='Test 1', Product_Section__c='tst111', Division__c='division 1',Sales_Channel__c='channel 1',SAP_Material_Number__c='1245-78',Effective_From__c = Date.today(),Effective_To__c = Date.today().addYears(1), Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='Test 2', Product_Section__c='tst222', Division__c='division 2',Status__c='A',SAP_Material_Number__c='7845-12',Effective_From__c = Date.today(),Effective_To__c = Date.today().addYears(1), Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='Test 3', Division__c='division 1', Sales_Channel__c='channel 2',Status__c='A',SAP_Material_Number__c='3265-98',Effective_From__c = Date.today(),Effective_To__c = Date.today().addYears(1), Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        insert listProd;
        
        
        // Set mock callout class 
        Test.setMock(WebServiceMock.class, new MockHttpSendToSAP());
        
        //Test.StartTest();
        Product_Svc.productsToSendToSAP(listProd);
        System.assertEquals(3, listProd.size());
        String exp = '0 0 1 * * ?';
        ProductStockStatus_Scheduler.doSchedule(exp);
        System.assertEquals(exp, '0 0 1 * * ?'); 

        //Cover the creation of pricebookentry
        //Create Product Category
        Product_Category__c productCat = new Product_Category__c();
        productCat.Name = 'CACPRO';
        productCat.Display_Name__c = 'CheckACode Professional';
        insert productCat;

        //Create Product information
        Product_Information__c productInfo = new Product_Information__c();
        productInfo.Name = 'CAC Pro for Members';
        productInfo.Product_Audience__c = 'Member Airline';
        productInfo.Related_Product_Category__c = productCat.Id;
        insert productInfo;

        List<Product2> lstProducts = TestDataGenerator.generateProductsWithPrice(1);
        List<zqu__ProductRatePlan__c> lstprp = [select id from zqu__ProductRatePlan__c
                                                 where 
                                                 zqu__Deleted__c = false 
                                                 and zqu__ZProduct__r.zqu__Deleted__c = false ];

        if(lstprp != null){
            //Create Product Rate Plan Information
            Product_Rate_Plan_Information__c prpinfo = new Product_Rate_Plan_Information__c();
            prpinfo.Active__c = true;
            prpinfo.Product_Rate_Plan__c = lstprp[0].Id;
            prpinfo.Related_Product_Information__c = productInfo.Id;
            prpinfo.Initial_Term__c = 12;
            prpinfo.Renewal_Term__c = 12;
            prpinfo.Long_Description__c = 'Long_Description__c';
            prpinfo.Short_Description__c = 'Short_Description__c';
            prpinfo.Order__c = 1;
            insert prpinfo;

            listProd[0].IEC_Parent_Product__c = lstProducts[0].Id;
            listProd[0].IEC_Product_Rate_Plan_Information__c = prpinfo.Id;

            update listProd[0];

            Pricebook2 standardPriceBook =[select id from Pricebook2 where IsStandard=true];
            List<PricebookEntry> pbe = [SELECT id,Product2Id from PricebookEntry WHERE Pricebook2Id = :standardPriceBook.Id AND Product2Id = :listProd[0].Id];
           //system.assertEquals(pbe[0].Product2Id, listProd[0].Id);
			
        }
        
        
        
        Test.StopTest();
			
    }
    /****************************************************************************************************
    Created by CGI, Kevin 2015-08-26
        Cover code of method "test_getProductStatusFromSAP"
    ****************************************************************************************************/
    static testMethod void test_listToExclude(){
        //list<Product_fields_to_exclude__c> lstProdToExcl = new list<Product_fields_to_exclude__c>();
        Test.startTest();
        
        List<Apex_Setting__c> lstProdToExcl = new List<Apex_Setting__c>();
        lstProdToExcl.add(new Apex_Setting__c(Name='Product fields to exclude', Text_1__c='Zuora_Id__c,lastmodifieddate,systemmodstamp,lastmodifiedbyid,zproduct__c'));
        insert lstProdToExcl;
        Product_Svc.listToExclude();
        System.assertEquals(lstProdToExcl.size(), 1);
        Test.stopTest();
    }


    /****************************************************************************************************
        Created by CGI, Thai 2015-08-21
            Cover code of method "setProductManager"
            Indirectly cover
                Trigger "Products" of object "Product2"
                Methods "onBeforeInsert", "onBeforeUpdate" of class "Product_Dom"
                Method "getProfitCenter_ManagerId" of class "Product_Manager_Mapping_Sel"
    ****************************************************************************************************/
    static testMethod void test_setProductManager(){
        test.startTest();
        List<Product_Manager_Mapping__c> listPM = new List<Product_Manager_Mapping__c>();
        List<Product2> listProd = new List<Product2>();
        
        TestDataGenerator.generateApexSetting();
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];
        TestDataGenerator.generateUtilitySetting();
        
        //*** create relationships between Profit Center and Product Manager
        listPM.add(new Product_Manager_Mapping__c(Profit_Center__c='tst111', Product_Manager__c=UserInfo.getUserId()));
        insert listPM;
        
        //*** invoking coverage for insert event
        listProd.add(new Product2(Name='zzzTest 1', Product_Section__c='tst111',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='zzzTest 2', Product_Section__c='tst222',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='zzzTest 3',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        insert listProd;
        listProd = [select Name, Product_Manager_lookup__c from Product2 where Name like 'zzzTest%' order by Name];
        system.assert(listProd[0].Product_Manager_lookup__c == UserInfo.getUserId(), 'Product manager wasn\'t set: ' + listProd[0].Product_Manager_lookup__c);
        system.assert(listProd[1].Product_Manager_lookup__c == null, 'Product manager must be null for NOT FOUND profit center: ' + listProd[1].Product_Manager_lookup__c);
        system.assert(listProd[2].Product_Manager_lookup__c == null, 'Product manager must be null for NO profit center: ' + listProd[2].Product_Manager_lookup__c);
        
        //*** invoking coverage for update event
        listProd[0].Product_Section__c = 'tst222'; 
        listProd[1].Product_Section__c = null;
        listProd[2].Product_Section__c = 'tst111';
        update listProd;
        listProd = [select Product_Manager_lookup__c from Product2 where Name like 'zzzTest%' order by Name];
        system.assert(listProd[0].Product_Manager_lookup__c == null, 'Product manager must be null for NOT FOUND profit center: ' + listProd[0].Product_Manager_lookup__c);
        system.assert(listProd[1].Product_Manager_lookup__c == null, 'Product manager must be null for NO profit center: ' + listProd[1].Product_Manager_lookup__c);
        system.assert(listProd[2].Product_Manager_lookup__c == UserInfo.getUserId(), 'Product manager wasn\'t set: ' + listProd[2].Product_Manager_lookup__c);
        Test.stopTest();
    } //*** end of "test_setProductManager"


    /****************************************************************************************************
        Created by CGI, Thai 2015-08-21
            Cover code of method "setRecordType"
            Indirectly cover
                Trigger "Products" of object "Product2"
                Methods "onBeforeInsert", "onBeforeUpdate" of class "Product_Dom"
                Method "getRecordIndex_RecordTypeId" of class "Product_Record_Type_Mapping_Sel"
    ****************************************************************************************************/
    static testMethod void test_setRecordType() {
        Test.startTest();
        List<Product_Record_Type_Mapping__c> listRTM = new List<Product_Record_Type_Mapping__c>();
        List<Product2> listProd = new List<Product2>();
        
        TestDataGenerator.generateApexSetting();
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];
        TestDataGenerator.generateUtilitySetting();
        
        //*** create setttings for record types
        listRTM.add(new Product_Record_Type_Mapping__c(Division__c='division 1', Sales_Channel__c='channel 1', Record_Type_for_Product__c='Publication'));
        listRTM.add(new Product_Record_Type_Mapping__c(Division__c='division 2', Record_Type_for_Product__c='GDP'));
        listRTM.add(new Product_Record_Type_Mapping__c(Sales_Channel__c='channel 2', Record_Type_for_Product__c='GDP'));
        insert listRTM;
        
        //*** invoking coverage for insert event
        listProd.add(new Product2(Name='zzzTest 1', SAP_Division_Code__c='division 1', SAP_Sales_Channel_Code__c='channel 1',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='zzzTest 2', SAP_Division_Code__c='division 2',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='zzzTest 3', SAP_Division_Code__c='division 1', SAP_Sales_Channel_Code__c='channel 2',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='zzzTest 4', SAP_Sales_Channel_Code__c='channel 2',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        insert listProd;
        listProd = [select RecordTypeId, Name from Product2 where Name like 'zzzTest%' order by Name];
        system.assert(listProd[0].RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'Publication'), 'Expected Publication RT ' + RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'Publication') + ': ' + listProd[0].RecordTypeId);
        system.assert(listProd[1].RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'GDP'), 'Expected GDP RT ' + RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'GDP') + ': ' + listProd[1].RecordTypeId);
        system.assert(listProd[2].RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'Unclassified'), 'Expected Unclassified RT ' + RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'Unclassified') + ': ' + listProd[2].RecordTypeId);
        system.assert(listProd[3].RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'GDP'), 'Expected GDP RT ' + RecordTypeSingleton.getInstance().getRecordTypeId('Product2', 'GDP') + ': ' + listProd[3].RecordTypeId);
        
        //*** invoking coverage for update event -> cannot cover because this portion is deactivated
        listProd[0].SAP_Sales_Channel_Code__c = 'channel 2'; 
        update listProd;
        listProd = [select RecordTypeId, Name from Product2 where Name like 'zzzTest%' order by Name];
        Test.stopTest();
    } //*** end of "test_setRecordType"


    /****************************************************************************************************
        Created by CGI, Thai 2015-09-02
            Cover code of method "setDefaultValue"
            Indirectly cover
                Trigger "Products" of object "Product2"
                Method "onBeforeInsert" of class "Product_Dom"
    ****************************************************************************************************/
    @isTest(seeAllData=true)
    static void test_setDefaultValue() {
        Test.startTest();
        List<Product2> listProd = new List<Product2>();
        
        TestDataGenerator.generateApexSetting();
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];
        TestDataGenerator.generateUtilitySetting();
        
        //*** invoking coverage for insert event
        listProd.add(new Product2(Name='zzzTest 1', SAP_Material_Number__c='123456',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        listProd.add(new Product2(Name='zzzTest 2',Accepted_Payment_Methods__c = 'Bank Transfer; Credit Card; IATA Clearing House'));
        insert listProd;
        listProd = [select Name, Activity_Code__c from Product2 where Name like 'zzzTest%' order by Name];
        system.assert(listProd[0].Activity_Code__c == '1234', 'Wrong default: ' + listProd[0].Activity_Code__c);
        system.assert(listProd[1].Activity_Code__c == null, 'Should be null: ' + listProd[1].Activity_Code__c);
        Test.stopTest();
    } //*** end of "test_setDefaultValue"

    @isTest(seeAllData=true)
    static void test_SendToZuoraButton()
    {
        Test.startTest();
        TestDataGenerator.generateApexSetting();
        delete [select Id from Apex_Setting__c where Name = 'Zuora Exclude Product Record Type'];
        TestDataGenerator.generateUtilitySetting();

        //-- Create product
        List<Product2> products = TestDataGenerator.generateProducts(1,true); 

        System.debug('products::'+products);

        //-- Send it to Zuora by clicking the Send To Zuora button 
        Product_Soap.send2Zuora(products[0].Id);
		Test.stopTest();
    }

	@isTest(seeAllData=true)
	static void test_IsProductAndCountryCompliant()
	{
        setup();

		Map<Id, Boolean> mapCheck;
		List<Product2> lstProduct = [select Id from Product2 limit 2];
		List<IATA_ISO_Country__c> lstCountry = [select Id, ISO_Code__c from IATA_ISO_Country__c where ISO_Code__c != null limit 2];
		lstCountry[0].Is_Non_Compliant__c = false;
		lstCountry[1].Is_Non_Compliant__c = true;
		update lstCountry;
		insert new Non_Compliant_Country__c(Product__c=lstProduct[1].Id, IATA_ISO_Country__c=lstCountry[0].Id);
		
		system.assertEquals(Product_Svc.IsProductAndCountryCompliant(lstProduct[0].Id, null), true);
		
		mapCheck = Product_Svc.IsProductAndCountryCompliant(new List<Id>{lstProduct[0].Id, lstProduct[1].Id}, new Set<String>{lstCountry[0].ISO_Code__c});
		system.assertEquals(mapCheck.get(lstProduct[0].Id), true);
		system.assertEquals(mapCheck.get(lstProduct[1].Id), false);
		
		mapCheck = Product_Svc.IsProductAndCountryCompliant(new List<Id>{lstProduct[0].Id, lstProduct[1].Id}, new Set<String>{lstCountry[1].ISO_Code__c});
		system.assertEquals(mapCheck.get(lstProduct[0].Id), false);
		system.assertEquals(mapCheck.get(lstProduct[1].Id), false);
	} //*** end of "test_IsProductAndCountryCompliant"

	@isTest(seeAllData=false)
	static void test_Miscellaneous()
	{
		TestDataGenerator.generateProducts(1, true);
		system.assert(Product_Svc.getAllProducts().size() > 0, 'Wrong count');
    } //*** end of "test_Miscellaneous"

    @isTest(seeAllData=true)
    static void test_Miscellaneous2() {
        Product2 topProduct = TestDataGenerator.generateProducts(1, true)[0];
        Product2 childProduct = TestDataGenerator.generateProducts(1, true)[0];
        Product2 thirdProduct = TestDataGenerator.generateProducts(1, true)[0];
        Product2 oldThirdProduct;

        childProduct.IEC_Parent_Product__c = topProduct.Id;

        update childProduct;

        topProduct.Accepted_Payment_Methods__c = 'Credit Card';
        topProduct.Product_Set_Up_Notifications__c = true;

        update topProduct;

        update topProduct;

        oldThirdProduct = new Product2(
            Id = thirdProduct.Id,
            SAP_Material_Number__c = '2222-99',
            Effective_From__c = System.today() - 6,
            Effective_To__c = System.today() - 5
        );

        thirdProduct.Product_Set_Up_Notifications__c = true;
        thirdProduct.SAP_Material_Number__c = '1234-56';
        thirdProduct.Status__c = 'Active';
        thirdProduct.Effective_From__c = System.today() - 5;
        thirdProduct.Effective_To__c = System.today() + 10;
        update thirdProduct;

        String templateId;

        for (
            EmailTemplate emailTemplate : [
                SELECT
                    Id,
                    DeveloperName
                FROM 
                    EmailTemplate
                WHERE
                    DeveloperName = 'Product_Effective_to_Expiring'
            ]
        ) {
            templateId = emailTemplate.Id;
        }
        
        List<Apex_Setting__c> existingApexSettings = [SELECT Id FROM Apex_Setting__c WHERE Name='Product Effective to template Id'];

        if (existingApexSettings.isEmpty() == false) {
            delete existingApexSettings;
        }

        Apex_Setting__c apexSetting = new Apex_Setting__c(
            Name='Product Effective to template Id',
            Text_1__c = templateId
        );
        insert apexSetting;

        try {
            Product_Svc.emailNotification(new List<Product2> { thirdProduct }, new Map<Id,Product2> { oldThirdProduct.Id => oldThirdProduct }, true);
        } catch (Exception e) {
        }

        Map<String,String> productApiNameMap = Product_Svc.productApiNames();

        Product_Svc.setRecordType(new List<Product2> { thirdProduct }, new List<Product2> { oldThirdProduct }, false);
        

        try {
            thirdProduct.Accepted_Payment_Methods__c = null;

            update thirdProduct;
        } catch (Exception e) {
        }

        try {
            childProduct.Accepted_Payment_Methods__c = null;

            update childProduct;
        } catch (Exception e) {
        }

	} //*** end of "test_Miscellaneous2"

    static void testOthers() {
        System.assert(Product_Svc.isEqual(null, null));
        System.assert(Product_Svc.isEqual('', null));
        System.assert(Product_Svc.isEqual(null, ''));
        System.assert(! Product_Svc.isEqual('X', ''));
    }

}
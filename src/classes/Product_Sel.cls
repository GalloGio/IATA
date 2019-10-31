/**
 * Class encapsulates query logic for Product__c
 *
 * @author: David Daboue <daboued@iata.org>
 * @date: 2015-08-14
 *
 **/
public class Product_Sel extends Selector
{
    /****************************************************************************************************
        Created by CGI - David
            return list fields for dynamic query
    ****************************************************************************************************/
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Product2.Id,
            Product2.Name,
            Product2.Description, 
            Product2.Short_Description__c,
            Product2.Short_Title__c,
            Product2.Keywords__c,
            Product2.ProductCode,
            Product2.SAP_Material_Number__c,
            Product2.Activity_Code__c,
            Product2.Product_Segment__c,
            Product2.Formula_Activity_Code__c,
            Product2.Formula_Version_Number__c,
            Product2.Effective_From__c,
            Product2.Effective_To__c,
            Product2.Family,
            Product2.Line_of_Business__c, 
            Product2.Edition__c, 
            Product2.Charge_Shipping__c,
            Product2.Media__c, 
            Product2.Language__c, 
            Product2.Display_to_Direct_Sales__c,
            Product2.Display_Price__c,
            Product2.Display_Ecom_Topic__c,
            Product2.Display_Ecom_Customer_Type__c,
            Product2.Inventory_Status__c, 
            Product2.Expected_Availability_Date__c, 
            Product2.Category_Group__c, 
            Product2.SAP_Media_Code__c,
            Product2.Product_Manager_lookup__c,
            Product2.Alternate_Product_Manager__c,
            Product2.Hide_Effective_To_Date_in_eCommerce__c,
            Product2.Available_for_Subscription__c,
            Product2.Number_of_months_of_subscription__c,
            Product2.Is_Electronic_Product__c,
            Product2.Is_Shippable__c,
            Product2.SAP_SalesOrg__c,
            Product2.SAP_Sales_Channel_Code__c,
            Product2.SAP_Division_Code__c,
            Product2.SAP_Contract_OrderReason__c,
            Product2.Product_Section__c,
            Product2.Image__c,
            Product2.Is_Quantity_Integer__c,
            Product2.IsNewRelease__c,
            Product2.Product_Set_Up_Notifications__c,
            Product2.Display_to_ECommerce__c,
            Product2.IATA_ORG_Group__c,
            Product2.LastModifiedDate,
            Product2.IEC_Product_Information__c,
            Product2.IEC_Product_Rate_Plan_Information__c,
            Product2.IEC_Static_Cart_Quantity__c,
            Product2.IEC_SAP_DocType__c,
            Product2.IEC_SAP_EmpResp__c,
            Product2.IEC_SAP_ProfitCenter__c,
            Product2.Mega_Menu__c,
            Product2.Product_Type__c,
            Product2.Restricted_Customer_Type__c,
            Product2.Notes__c,
            Product2.IEC_Sample_Link__c,
            Product2.IEC_OrderBy__c,
            Product2.IEC_Page_Areas_of_Activity__c,
            Product2.IEC_Page_Content_Types__c,
            Product2.IEC_Use_on_IATA_org__c,
            Product2.zqu__ZuoraId__c,
            Product2.zqu__EffectiveStartDate__c,
            Product2.zqu__EffectiveEndDate__c,
            Product2.zqu__SKU2__c,
            Product2.zqu__Deleted__c,
            Product2.Accepted_Payment_Methods__c,
            Product2.ProductAudience__c,
            Product2.ProductCategory__c,
            Product2.imagefile__c



        };
    }

    /****************************************************************************************************
        Created by CGI - David
            return Product2 for dynamic query
    ****************************************************************************************************/
    public Schema.SObjectType getSObjectType()
    {
        return Product2.sObjectType;
    }

    /****************************************************************************************************
        Created by CGI - David
            return list List of products information(default fields) for a given set of product Ids
    ****************************************************************************************************/
    public List<Product2> selectById(Set<Id> productIds)
    {
        String query = String.format(
            'SELECT {0}, RecordType.DeveloperName ' +
            'FROM {1} ' + 
            'WHERE Id in :productIds ', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return Database.query(query);
    }

    public List<Product2> selectAll()
    {
        String query = String.format(
            'SELECT {0} ' +
            'FROM {1} ' + 
            'WHERE SAP_Material_Number__c != null AND (Display_to_Direct_Sales__c = true OR Display_to_ECommerce__c = true) ', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return Database.query(query);
    }

    /****************************************************************************************************
        Created by CGI - Kevin
            return product by product id
    ****************************************************************************************************/
    public Map<Id,Product2> getProductById(Set<Id> productIds)
    {

        String query = String.format(
            'SELECT {0}, Use_Contract_when_ordered__c,  Product_Manager_lookup__r.Email, Product_Manager_lookup__r.EmployeeNumber, Alternate_Product_Manager__r.Email,Sales_Notification__c  ' +
            '   , (select IATA_ISO_Country__r.Name from Non_Compliance_Countries__r) ' +
            'FROM {1} ' + 
            'WHERE Id  in :productIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return new map<Id,Product2>((List<Product2>)Database.query(query));
    }

    public List<Product2> getProducts(String conditions, String orderBy, Integer queryLimit, Integer queryOffset)
    {
        if(String.isBlank(orderBy))
            orderBy = 'Name ASC';

        String query;

        if(queryLimit != null && queryOffset != null)
        {
            query = String.format(
                'SELECT {0}, Refinement_Language__c,  IEC_Product_Information__r.Related_Product_Category__r.Short_Description__c ' +
                '   , IEC_Product_Information__r.Related_Product_Category__r.Long_Description__c, Sell_through_eCommerce__c ' + 
                'FROM {1} ' + 
                'WHERE {2} ' + 
                'ORDER BY {3} ' +
                'LIMIT :queryLimit ' +
                'OFFSET :queryOffset ' , 
                new List<String>{
                    String.join(getDefaultFields(), ', '),
                    getSObjectType().getDescribe().getName(),
                    conditions,
                    orderBy
                }
            );
        }   
        else
        {
            query = String.format(
                'SELECT {0}, Refinement_Language__c,  IEC_Product_Information__r.Related_Product_Category__r.Short_Description__c ' +
                '   , IEC_Product_Information__r.Related_Product_Category__r.Long_Description__c, Sell_through_eCommerce__c ' + 
                'FROM {1} ' + 
                'WHERE {2} ' + 
                'ORDER BY {3} ' , 
                new List<String>{
                    String.join(getDefaultFields(), ', '),
                    getSObjectType().getDescribe().getName(),
                    conditions,
                    orderBy
                }
            );
        } 

        System.debug('query::'+query);

        return Database.query(query);
    }

    /****************************************************************************************************
        Created by CGI - David
            return list List of products information (fields sepecified) for a given set of product Ids
    ****************************************************************************************************/
    public List<Product2> selectById(Set<Id> productIds, List<String> fields)
    {
        return (List<Product2>) selectSObjectById(productIds, fields);
    }

    /****************************************************************************************************
        Created by CGI - David
            return List of products for direct Sales 
    ****************************************************************************************************/
    public List<EComProduct_DTO> getDirectSaleProducts(String customerType)
    {
        List<EComProduct_DTO> eComProducts = new List<EComProduct_DTO>();
        List<Product2> products = getProducts('Display_to_Direct_Sales__c = true AND SAP_Material_Number__c != null',null,null,null);
        
        //-- Get Pricing Data 
        Set<String> productCodes = new Set<String>(); 
        for(Product2 p: products)
            productCodes.add(p.SAP_Material_Number__c);

        Map<String, PriceInfo_DTO> productPriceInfo = getProductPriceInfo(productCodes, customerType, null, null, true);

        Map<String, Map<String, String>> mapPickList_Label = new Map<String, Map<String, String>>();
            mapPickList_Label.put('Category',   Utility.getPicklistValue_Label('Product2', 'Line_of_Business__c'));
            mapPickList_Label.put('Media',      Utility.getPicklistValue_Label('Product2', 'Media__c'));
            mapPickList_Label.put('Language',   Utility.getPicklistValue_Label('Product2', 'Language__c'));  //*** do not use Refinement_Language__c because less values
            mapPickList_Label.put('InvStatus',  Utility.getPicklistValue_Label('Product2', 'Inventory_Status__c'));

        for (Product2 p : products)
        {
            if(productPriceInfo.containsKey(p.SAP_Material_Number__c))
            {
                eComProducts.add(new EComProduct_DTO(p, productPriceInfo, mapPickList_Label, false, customerType));
            }
        }

        return eComProducts;
    }

    //public Map<Id, Product2> getProductByZproduct(List<Id> zProductIdList)
    //{
    //    Map<Id, Product2> ret = new Map<Id, Product2>();

    //    Set<String> zProductIds = new Set<String>();
    //    for(Id zprodId : zProductIdList)
    //        zProductIds.add((String) zprodId);

    //    List<Product2> products = (List<Product2>) selectSObjectByField('ZProduct__c', zProductIds);
        
    //    for(Product2 prod : products)
    //    {
    //        ret.put(prod.ZProduct__c, prod);
    //    }
    //    return ret;
    //}

    /****************************************************************************************************
        Created by CGI - David
           Create Zuora Product object from SFDC Product Object
    ****************************************************************************************************/
    public Zuora.zObject format2zObject(Product2 product)
    {
        Zuora.zObject ret = (Test.isRunningTest()) ? TestDataGenerator.generateZObject('Product') : new Zuora.zObject('Product'); 

        ret.setValue('Id', product.zqu__ZuoraId__c);
        
        if(product.Name != null)
            ret.setValue('Name', product.Name);
        
        if(product.Description != null)
            ret.setValue('Description', product.Description);
            
        //The Zuora ProductAudience__c and ProductCategory__c are required fields, for new product add default value for those fields
        if(product.zqu__ZuoraId__c == null){
            ret.setValue('ProductAudience__c', 'DO NOT DISPLAY');
            ret.setValue('ProductCategory__c', 'DO NOT DISPLAY');
        }
        
        if(product.SAP_Material_Number__c != null)
            ret.setValue('SAPProductMaterialNo__c', product.SAP_Material_Number__c);
        
        if(product.Effective_From__c != null)
            ret.setValue('EffectiveStartDate', Zuora.zUtil.getZuoraDateOnly(product.Effective_From__c));
        
        if(product.Effective_To__c != null)
            ret.setValue('EffectiveEndDate', Zuora.zUtil.getZuoraDateOnly(product.Effective_To__c));
        
        return ret; 
    }

    /****************************************************************************************************
        Created by CGI - David
           Create List of Zuora Product object from List of SFDC Product Object
    ****************************************************************************************************/
    public List<Zuora.zObject> format2zObject(List<Product2> products)
    {
        List<Zuora.zObject> ret = new List<Zuora.zObject>(); 

        for(Product2 p: products)
        {
            ret.add(format2zObject(p));
        }

        return ret; 
    }

    /****************************************************************************************************
        Created by CGI - David
           Group products by Activity Code
    ****************************************************************************************************/
    public Map<String, List<Product2>> getProductsByActivityCode(List<Product2> products)
    {
        Map<String, List<Product2>> ret = new Map<String, List<Product2>>(); 

        for(Product2 p : products)
        {
            List<Product2> tmp = (ret.containsKey(p.Activity_Code__c)) ? ret.get(p.Activity_Code__c) : new List<Product2>();
            tmp.add(p);

            ret.put(p.Activity_Code__c, tmp);
        }

        return ret;
    }

    /****************************************************************************************************
        Created by CGI - David
           Find existing products by Activity Code
    ****************************************************************************************************/
    public Map<String, List<Product2>> getExistingProductsByActivityCode(Set<String> activityCodes)
    {
        Map<String, List<Product2>> ret = new Map<String, List<Product2>>();

        List<Product2> existingProducts = (List<Product2>) selectSObjectByField('Activity_Code__c', activityCodes);

        for(Product2 p : existingProducts)
        {
            if(String.isNotBlank(p.Activity_Code__c))
            {
                List<Product2> tmp = (ret.containsKey(p.Activity_Code__c)) ? ret.get(p.Activity_Code__c) : new List<Product2>();
                tmp.add(p);

                ret.put(p.Activity_Code__c, tmp);
            }
        }

        return ret;
    }

    public static List<EComProduct_DTO> findProducts(String searchToken, String whereClause, String sortBy)
    {
        List<EComProduct_DTO> result = new List<EComProduct_DTO>();

        String sosl = 'FIND \'*' + searchToken + '*\' IN ALL FIELDS RETURNING  Product2 (Id)';
        List<List <sObject>> searchResult = search.query(sosl);
        
        List<Product2> productsResult = (List<Product2>)searchResult[0];
        
        if(productsResult.size() > 0)
        {
            List<Id> productsId = new List<Id>();
            for(Product2 prod : productsResult)
            {
                productsId.add(prod.Id);
            }

            result =  getEComProduct(productsId,true,whereClause, sortBy);
        }

        return result;
    }
    
    //Return all Products for View All Products Page
    public static list<Product2> getViewAllProducts(String wherecriteria){
        String query = 'SELECT Id,Family, Name,Media__c,zqu__ZuoraId__c FROM Product2  where '+ wherecriteria  ;
        return (list<Product2>)Database.query(query);
    }
    

    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            Return list of products by product code
    ****************************************************************************************************/
    public static map<String,Product2> getProductsByCode(set<String> productCode){
        
        map<String,Product2> productCode_product = new map<String,Product2>();
        
        //get the list of Product by SAP material number
        list<Product2> products = [SELECT id, SAP_Material_Number__c, IEC_Static_Cart_Quantity__c, 
                                    Charge_Shipping__c, Use_Contract_when_ordered__c
                                    From Product2 
                                    where SAP_Material_Number__c in :productCode];
        
        if(products != null && products.size() > 0){
            for(Product2 product : products){
                productCode_product.put(product.SAP_Material_Number__c,product);
            }
        }
        //return list of product SAP Material Number by Product
        return productCode_product;
    }
    
    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            Return All active products to send to SAP for inventory
    ****************************************************************************************************/
    public static list<Product2> activeProducts(){
        //Get the Product to SAP inventory query from custom setting
        String query = '';
        List<String> lstStr = Utility.getSeqTextSettingToArray('Product to SAP inventory query');
        for(String str : lstStr){
            query += str + ' ';
        }
        //String query = Utility.getTextSetting('Product to SAP inventory query');
        return Database.query(query);
        //return [SELECT Id, SAP_Material_Number__c FROM Product2 where /*Status__c = 'A' and*/ SAP_Material_Number__c != null and CreatedById = '00520000000iYyxAAE'];
    }
    
    /****************************************************************************************************
        Created by CGI - Kevin 8/26/2015
            update products base on the SAP Material Number with the callout response
    ****************************************************************************************************/
    public static list<Product2> updateProductsByMaterialNumb(map<String,ProductAvailabilityCheck_Soap.ProductAvailability_element> materialNumbers_availabilityObjc){
        
        //List of errors to log
        List<IEC_Error_Log__c> lstErrors = new List<IEC_Error_Log__c>();

        list<Product2> toUpdate = new list<Product2>();
        //retrieve all the existing products by product SAP material number
        list<Product2> products = [SELECT 
                                        id, 
                                        Inventory_Status__c,
                                        Expected_Availability_Date__c,
                                        Status__c,
                                        SAP_Material_Number__c 
                                    from Product2 
                                    where SAP_Material_Number__c in :materialNumbers_availabilityObjc.keySet() ];
                                    
        if(products != null && products.size() > 0){
            for(Product2 product : products){
                Boolean productChanged = false;

                //retrieve the product availability object by SAP material number
                ProductAvailabilityCheck_Soap.ProductAvailability_element productAvailabilityObj = materialNumbers_availabilityObjc.get(product.SAP_Material_Number__c);
                system.debug('productAvailabilityObj.Status ' + productAvailabilityObj.Status);

                if(productAvailabilityObj != null){
                    
                    product.Expected_Availability_Date__c = null;
                    
                    //if Status == IS, means the product is In-stock
                    if(productAvailabilityObj.Status.startsWith('IS') && product.Inventory_Status__c != 'In stock'){
                        productChanged = true;
                        product.Inventory_Status__c = 'In stock';
                    }
                    //if Status contains OS, means the product is Out-of-stock 
                    if(productAvailabilityObj.Status.startsWith('OS') && product.Inventory_Status__c != 'Out of stock'){
                        productChanged = true;
                        product.Inventory_Status__c = 'Out of stock';
                    }
                    //if Status == OS-D, means the product is Out of stock without next available date value
                    if(productAvailabilityObj.Status.startsWith('OS-D')){
                        if(product.Status__c != Utility.getTextSetting('Product inactive status for SAP calls'))
                        {
                            productChanged = true;
                            product.Status__c = Utility.getTextSetting('Product inactive status for SAP calls');    
                        }

                        if(product.SAP_Status_Code__c != Utility.getTextSetting('Product inactive status code for SAP'))
                        {
                            productChanged = true;
                            product.SAP_Status_Code__c = Utility.getTextSetting('Product inactive status code for SAP');    
                        }
                        
                        
                    }
                    //if Status == OS+D, means the product is Out of stock with next available date value
                    if(productAvailabilityObj.Status.startsWith('OS+D')){
                        if(productAvailabilityObj.AvailableDate != null && productAvailabilityObj.AvailableDate != ''){
                            //get a new instance of availableDate
                            Date availableDate = Utility.getDate(productAvailabilityObj.AvailableDate);
                            if(availableDate != null){
                                if(product.Expected_Availability_Date__c != availableDate)
                                {
                                    productChanged = true;
                                    product.Expected_Availability_Date__c = availableDate;
                                }
                            }
                        }
                    }
                    //if Status == IM, means taht it's a invalid material number in SAP)
                    if(productAvailabilityObj.Status.startsWith('IM')){

                        //Get the product invalid material number and add it to the error list
                        lstErrors.add(IECErrorLogger.createErrorLog('Product_Sel/updateProductsByMaterialNumb',JSON.serialize(productAvailabilityObj),'update product availability from SAP: ' + productAvailabilityObj.MaterialNumber,'STACKTRACE invalid product material number in SAP'));
                    }

                    if(productChanged) toUpdate.add(product);
                }
            }
        }
        
        //Log errors
        if(lstErrors.size() > 0) IECErrorLogger.logErrors(lstErrors, true);

        if(toUpdate.size() > 0){
            try{
                update toUpdate;
                return toUpdate;
            }catch(Exception ex){
                //Add the error list the inventory products that was not updated successfully
                lstErrors.add(IECErrorLogger.createErrorLog('Product_Sel/updateProductsByMaterialNumb','',ex.getMessage(),ex.getStackTraceString()));
                if(lstErrors.size() > 0) IECErrorLogger.logErrors(lstErrors, true);
            }
        }
        return null;
    }
    
    
    // Update list of products
    public void updateProducts(List<Product2> products)
    {
        update products;
    }

    public Map<String, PriceInfo_DTO> getProductPriceInfo(Set<String> productNumbers, String customerType, String customerRegion, String customerCountry, Boolean showAll)
    {
        System.debug('productNumbers::'+productNumbers);

        Map<String, String> gdpRatePlanZId_ProductNumber = new Map<String, String>();
        Set<String> nongdpProductNumbers = new Set<String>();
        
        // First query the product object to split the productNumbers
        for (Product2 prod :
            [SELECT SAP_Material_Number__c, IEC_Parent_Product__c, IEC_Product_Information__c
                , IEC_Product_Rate_Plan_Information__c, IEC_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c
            FROM Product2
            WHERE SAP_Material_Number__c IN :productNumbers])
        {
            if (prod.IEC_Product_Rate_Plan_Information__c == null && prod.IEC_Product_Information__c == null)
            {
                nongdpProductNumbers.add(prod.SAP_Material_Number__c);
            }
            else if (prod.IEC_Product_Rate_Plan_Information__c != null)
            {
                gdpRatePlanZId_ProductNumber.put(prod.IEC_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c, prod.SAP_Material_Number__c);
            }
        }

        System.debug('nongdpProductNumbers::'+nongdpProductNumbers);
        System.debug('gdpRatePlanZId_ProductNumber::'+gdpRatePlanZId_ProductNumber);
        
        Map<String, PriceInfo_DTO> result = new Map<String, PriceInfo_DTO>();
        ProductRatePlanChargeTier_Sel tSelector = new ProductRatePlanChargeTier_Sel(); 

        List<zqu__ProductRatePlanChargeTier__c> zTiers = new List<zqu__ProductRatePlanChargeTier__c>(); 
        
        // Check if there are non-GDP products to get price info
        if (!nongdpProductNumbers.isEmpty())
        {
            zTiers.addAll(showAll 
                ? tSelector.getProductTiers(nongdpProductNumbers) 
                : tSelector.getProductTiers(nongdpProductNumbers, customerType, customerRegion, customerCountry));
        }
        
        // Check if there are GDP products to get price info
        if (!gdpRatePlanZId_ProductNumber.isEmpty())
        {
            zTiers.addAll(tSelector.getProductTiersByRatePlan(gdpRatePlanZId_ProductNumber.keySet()));
        }

        System.debug('zTiers::'+zTiers);
        
        Map<String, List<VolumePrice_DTO>> volumesByCharge = new Map<String, List<VolumePrice_DTO>>();
        Map<String, PriceDetail_DTO> priceByRatePlan = new Map<String, PriceDetail_DTO>();

        if(zTiers.size() > 0)
        {
            for(zqu__ProductRatePlanChargeTier__c zTier: zTiers)
            {
                PriceDetail_DTO priceDetail = (priceByRatePlan.containsKey(zTier.ZRatePlan_ZuoraId__c))
                    ? priceByRatePlan.get(zTier.ZRatePlan_ZuoraId__c)
                    : new PriceDetail_DTO();

                priceDetail.isFreeShipping = (zTier.ZRatePlan_IsFreeShipping__c == 'Yes');    
                
                    if(String.isNotBlank(zTier.ZRatePlan_CustomerType__c))
                        priceDetail.discountName = zTier.ZRatePlan_CustomerType__c;
                    else if(String.isNotBlank(zTier.ZRatePlan_Region__c))
                        priceDetail.discountName = zTier.ZRatePlan_Region__c;
                    else if(String.isNotBlank(zTier.ZRatePlan_Country__c))
                        priceDetail.discountName = zTier.ZRatePlan_Country__c;
                    else if(String.isNotBlank(zTier.ZRatePlan_CouponCode__c))
                        priceDetail.discountName = zTier.ZRatePlan_CouponCode__c;
                    else if(zTier.ZRatePlan_IsPreSale__c == 'Yes')
                        priceDetail.discountName = 'Pre-Sales';
                    else
                        priceDetail.discountName = null;

                //-- Unit Price
                if(zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_PER_UNIT))
                {
                    priceDetail.unitPrice = zTier.ZCharge_ListPrice__c;
                    priceDetail.unitPricePlanId = zTier.ZRatePlan_ZuoraId__c;
                    priceDetail.unitPriceChargeId = zTier.ZCharge_ZuoraId__c;
                }
                //-- Setup Fee 
                else if(zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_FLAT_FEE))
                {
                    priceDetail.setupFee = zTier.ZCharge_ListPrice__c;
                    priceDetail.setupFeePlanId = zTier.ZRatePlan_ZuoraId__c;
                    priceDetail.setupFeeChargeId = zTier.ZCharge_ZuoraId__c;
                }
                //-- Volume Prices
                else if(zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_VOLUME))
                {
                    List<VolumePrice_DTO> standardVolumes = (volumesByCharge.containsKey(zTier.ZCharge_ZuoraId__c))
                        ? volumesByCharge.get(zTier.ZCharge_ZuoraId__c)
                        : new List<VolumePrice_DTO>();

                    standardVolumes.add(new VolumePrice_DTO(zTier));
                    volumesByCharge.put(zTier.ZCharge_ZuoraId__c, standardVolumes);

                    priceDetail.volumePrice = standardVolumes;
                }
                //-- Discounts
                else if(zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_PERCENTAGE) || zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_FIXED_AMOUNT))
                {   
                    priceDetail.discountPlanId = zTier.ZRatePlan_ZuoraId__c;
                    priceDetail.discountChargeId = zTier.ZCharge_ZuoraId__c;

                    if(zTier.ZCharge_Model__c.contains(ZuoraUtil.ZCHARGE_MODEL_DISCOUNT_PERCENTAGE))
                    {
                        priceDetail.discountPercentage = zTier.zqu__Price__c;    
                    }
                    else
                    {
                        priceDetail.discountAmount = zTier.zqu__Price__c;
                    }
                }

                priceByRatePlan.put(zTier.ZRatePlan_ZuoraId__c,priceDetail);
            }

            for(zqu__ProductRatePlanChargeTier__c zTier: zTiers)
            {
                // Determine the actual product number based on previously split product numbers
                String sProdNumber = (gdpRatePlanZId_ProductNumber.containsKey(zTier.ZRatePlan_ZuoraId__c)
                    ? gdpRatePlanZId_ProductNumber.get(zTier.ZRatePlan_ZuoraId__c)
                    : zTier.Product_Number__c);
                
                PriceInfo_DTO price = (result.containsKey(sProdNumber))
                    ? result.get(sProdNumber)
                    : new PriceInfo_DTO(); 

                PriceDetail_DTO priceDetail = priceByRatePlan.get(zTier.ZRatePlan_ZuoraId__c);

                //-- Set Standard Prices
                if(ProductRatePlanChargeTier_Sel.isStandardPrice(zTier))
                {
                    if(price.standardPrice == null)
                    {
                        price.standardPrice = new List<PriceDetail_DTO>();
                    }
                    price.standardPrice.add(priceDetail); 
                }
                //-- CustomerType Prices
                else if(String.isNotBlank(zTier.ZRatePlan_CustomerType__c) && (showAll==true || zTier.ZRatePlan_CustomerType__c == customerType))
                {
                    if(price.customerPrice == null)
                    {
                        price.customerPrice = new List<PriceDetail_DTO>();
                    }

                    price.customerPrice.add(priceDetail);
                }   
                //-- Region Prices
                else if(String.isNotBlank(zTier.ZRatePlan_Region__c) && (showAll==true || zTier.ZRatePlan_Region__c == customerRegion))
                {
                    if(price.regionPrice == null)
                    {
                        price.regionPrice = new List<PriceDetail_DTO>();
                    }

                    price.regionPrice.add(priceDetail);
                }
                //-- Country Prices
                else if(String.isNotBlank(zTier.ZRatePlan_Country__c) && (showAll==true || zTier.ZRatePlan_Country__c == customerCountry))
                {
                    if(price.countryPrice == null)
                    {
                        price.countryPrice = new List<PriceDetail_DTO>();
                    }

                    price.countryPrice.add(priceDetail);
                }
                //-- Coupon Code Prices
                else if(String.isNotBlank(zTier.ZRatePlan_CouponCode__c))
                {
                    if(price.couponPrice == null)
                    {
                        price.couponPrice = new List<PriceDetail_DTO>();
                    }

                    price.couponPrice.add(priceDetail);
                }
                else if(zTier.ZRatePlan_IsPreSale__c == 'Yes')
                {
                    if(price.preSalePrice == null)
                    {
                        price.preSalePrice = new List<PriceDetail_DTO>();
                    }
                    price.preSalePrice.add(priceDetail); 
                }

                //--Update Map 
                if(!result.containsKey(sProdNumber))
                {
                    result.put(sProdNumber, price);
                }
            }
        }

        return result;
    }

    /****************************************************************************************************
        Created by CGI, David
            Return list of products per category in map format to display in eCommerce
    ****************************************************************************************************/
    public Map<String, List<EComProduct_DTO>> getProductCategoryMap2(String productCriteria, String productSort) {
        Map<String, List<EComProduct_DTO>> ret = new Map<String, List<EComProduct_DTO>>();
        
        //*** build map of list of products per category
        for(EComProduct_DTO pro : getEComProduct(null, false, productCriteria, productSort)) {
            if (!ret.containsKey(pro.ProductCategory))
                ret.put(pro.ProductCategory, new List<EComProduct_DTO>());
            ret.get(pro.ProductCategory).add(pro);
        }
        
        //*** replace category null
        if (ret.containsKey(null)) {
            ret.put(Label.Label_For_Missing_Product_Category, ret.get(null));
            ret.remove(null);
        }
        
        return ret;
    } //*** end of "getProductCategoryMap2"

    
    /****************************************************************************************************
        Created by CGI, Thai 2015-08-31
            Return list of products to display in eCommerce
            Code is covered in test methods for controllers displaying products i.e. "IECProductDetail_Ctrl_Test",
            "IECProductRelated_Ctrl_Test", etc.
    ****************************************************************************************************/
    public static List<EComProduct_DTO> getEComProduct (List<Id> listProductId, Boolean includeBOM, String productCriteria, String productSort) {
        return getEComProduct (listProductId, includeBOM, productCriteria, productSort, true, null);
    }


    public static List<EComProduct_DTO> getEComProduct (List<Id> listProductId, Boolean includeBOM, String productCriteria, String productSort, Boolean onlyParent, String customerType) {
        System.debug('listProductId::'+listProductId);
		
        Map<String, Map<String, String>> mapPickList_Label = new Map<String, Map<String, String>>();
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();
        Product_Sel exe = new Product_Sel();
        String SOQL = ' select Id, Name, IEC_Static_Cart_Quantity__c, Line_of_Business__c, Is_Electronic_Product__c, IsNewRelease__c, Short_Title__c, Keywords__c, Family, Charge_Shipping__c, SAP_Material_Number__c, Edition__c, Media__c, Language__c, Effective_From__c, Effective_To__c, Short_Description__c, Description'
                    + '      , Sell_through_eCommerce__c, Inventory_Status__c, Expected_Availability_Date__c, Product_Segment__c, Category_Group__c, SAP_Media_Code__c, Display_Price__c,Image__c'
                    + '      , Hide_Effective_To_Date_in_eCommerce__c, Is_Quantity_Integer__c, Mega_Menu__c, Refinement_Language__c '
                    + ((!includeBOM) ? '' : ', (select Related_Product__c, Related_Product__r.Name, Related_Product__r.Media__c, Related_Product__r.Edition__c' +
                                                    ', Related_Product__r.Effective_From__c, Related_Product__r.Effective_To__c, Related_Product__r.SAP_Material_Number__c, Related_Product__r.Short_Description__c' +
                                              ' from Product_BOM__r order by Related_Product__r.Name)')
                    + '      , (select IATA_ISO_Country__r.Name, Display_in_E_Com__c from Non_Compliance_Countries__r) '
                    + '     , IEC_Product_Information__c, IEC_Product_Rate_Plan_Information__c '
                    + '     , IEC_Product_Information__r.Related_Product_Category__r.Short_Description__c '
                    + '     , IEC_Product_Information__r.Related_Product_Category__r.Long_Description__c, imageFile__c '
                    + ' from Product2'
                    + ' where SAP_Material_Number__c != null '
                    + 'and Display_to_ECommerce__c = true ' 
                    + Utility.getSeqTextSetting('ECommerce Products Filter', '')
                    + ((onlyParent) ? ' and IEC_Parent_Product__c = null' : '')
                    + ((listProductId == null || listProductId.size() == 0) ? '' : ' and Id in :listProductId');
                
        customerType = customerType == null ? User_Sel.getCustomerType(UserInfo.getUserId()) : customerType;
        
        SOQL += ' and (Restricted_Customer_Type__c = null' + (String.isBlank(customerType) ? '' : ' or Restricted_Customer_Type__c includes (:customerType)') + ')';
        
        if (productCriteria != null & productCriteria != '')
            SOQL += ' and (' + productCriteria + ')';
        
        if (productSort != null & productSort != '')
            SOQL += ' order by ' + productSort;
        else
            SOQL += ' order by Name';
        
        List<Product2> listProduct, listFilteredProduct;
        List<EComProduct_DTO> listEComProduct = new List<EComProduct_DTO>();

        //*** get products list and prepare for additional information
        system.debug('SOQL::'+SOQL);
        listProduct = Database.query(SOQL);

        // Filter products based on compliance requirements
        Contact contactCurrent = IECUserManager.getContact();
        if (contactCurrent != null) {
            Set<String> setCountry = new Set<String>();
            
            if (contactCurrent.MailingCountry != null) setCountry.add(contactCurrent.MailingCountry);
            if (contactCurrent.Account.ShippingCountry != null) setCountry.add(contactCurrent.Account.ShippingCountry);
            if (contactCurrent.Account.BillingCountry != null) setCountry.add(contactCurrent.Account.BillingCountry);
            
            listFilteredProduct = new List<Product2>();
            Boolean bAddProduct;
            
            for (Product2 prod : listProduct) {
                if (prod.Non_Compliance_Countries__r == null) {
                    listFilteredProduct.add(prod);
                }
                else {
                    bAddProduct = true;
                    
                    for (Non_Compliant_Country__c country : prod.Non_Compliance_Countries__r) {
                        if (setCountry.contains(country.IATA_ISO_Country__r.Name) && !country.Display_in_E_Com__c) {
                            bAddProduct = false;
                            break;
                        }
                    }
                    
                    if (bAddProduct)
                        listFilteredProduct.add(prod);
                }
            }
        }
        else {
            listFilteredProduct = listProduct;
        }

        // Filter price info for products not related to Phase 1& 2 products only
        for (Product2 p : listFilteredProduct)
        {
            if (p.IEC_Product_Information__c == null)
            {
                mapProductNumber_Price.put(p.SAP_Material_Number__c, null);
            }
        }   

        mapProductNumber_Price = exe.getProductPriceInfo(mapProductNumber_Price.keySet(), customerType, null, null, true);

        //*** get picklist translations
        mapPickList_Label.put('Category', Utility.getPicklistValue_Label('Product2', 'Line_of_Business__c'));
        mapPickList_Label.put('Media', Utility.getPicklistValue_Label('Product2', 'Media__c'));
        mapPickList_Label.put('Language', Utility.getPicklistValue_Label('Product2', 'Language__c'));  //*** do not use Refinement_Language__c because less values
        mapPickList_Label.put('InvStatus', Utility.getPicklistValue_Label('Product2', 'Inventory_Status__c'));
        
        //*** build ECom products list
        for (Product2 p : listFilteredProduct)
            listEComProduct.add(new EComProduct_DTO(p, mapProductNumber_Price, mapPickList_Label, includeBOM, customerType));
        
        return listEComProduct;
    } //*** end of "getEComProduct"



    /****************************************************************************************************
        Created by CGI - Samy
            return list of products id that are non-compliant with specified countries
    ****************************************************************************************************/
    public static Set<Id> getNonCompliantProductId(Set<Id> setProductId, Set<String> setCountryCode)
    {
        Set<Id> setNonCompliantProductId = new Set<Id>();
        
        for (Non_Compliant_Country__c ncc :
            [SELECT Product__c
            FROM Non_Compliant_Country__c
            WHERE Product__c IN :setProductId
                AND IATA_ISO_Country__r.ISO_Code__c IN :setCountryCode]) {
                    
            setNonCompliantProductId.add(ncc.Product__c);
        }

        return setNonCompliantProductId;
    }

    public Map<Id, Product2> getProductLastVersions(Set<Id> productIds)
    {
        Map<Id, Product2> ret = new Map<Id, Product2>();

        Map<Id, String> givenActivityCodeByProduct = new Map<Id, String>();

        Map<Id, Product2> productsById = new Map<Id, Product2>();

        Set<String> activityCodes = new Set<String>(); 

        for(Product2 p : [SELECT Id, SAP_Material_Number__c, Formula_Activity_Code__c FROM Product2 WHERE Id IN :productIds])
        {
            givenActivityCodeByProduct.put(p.Id, p.Formula_Activity_Code__c);
            productsById.put(p.Id, p);
            activityCodes.add(p.Formula_Activity_Code__c);
        }

        //-- Search for products with same code 
        Map<String, List<Product2>> productsByActivityCode = new  Map<String, List<Product2>>();
        for(Product2 p : [SELECT Id, Formula_Version_Number__c, Formula_Activity_Code__c FROM Product2 WHERE Formula_Activity_Code__c IN :activityCodes])
        {
            List<Product2> tmp = (productsByActivityCode.containsKey(p.Formula_Activity_Code__c))
                ? productsByActivityCode.get(p.Formula_Activity_Code__c)
                : new List<Product2>();

            tmp.add(p);

            productsByActivityCode.put(p.Formula_Activity_Code__c, tmp);
        }

        //-- Select latest vesion : 

        for(Id productId : givenActivityCodeByProduct.keySet())
        {
            if(productsByActivityCode.containsKey(givenActivityCodeByProduct.get(productId)))
            {
                Product2 lastVersion; 
                for(Product2 p : productsByActivityCode.get(givenActivityCodeByProduct.get(productId)))
                {
                    if(lastVersion == null || (lastVersion.Formula_Version_Number__c < p.Formula_Version_Number__c))
                    {
                        lastVersion = p;    
                    }
                }

                ret.put(productId, lastVersion);
            }
            else
            {
                //-- Last version is same has current version if not found 
                ret.put(productId, productsById.get(productId));
            }
        }
        
        return ret;
    }

    public static List<Product2> getMiniCartProducts(Set<String> productNumbers)
    {
        return [
            SELECT Id, Name, SAP_Material_Number__c 
            FROM Product2 
            WHERE SAP_Material_Number__c != null 
                AND Display_to_ECommerce__c = true
                AND SAP_Material_Number__c IN :productNumbers
        ];
    }
    
    /****************************************************************************************************
        Created by CGI - Samy 2016-04-20
            Return list of products filtered by rateplanid
    ****************************************************************************************************/
    public static map<String, Product2> getProductsByProductRatePlan(set<String> setProductRatePlanZId)
    {
        map<String, Product2> mapProductRatePlanZId_Product = new map<String,Product2>();
        
        //get the list of Product by SAP material number
        list<Product2> lstProduct = [SELECT id, SAP_Material_Number__c, Charge_Shipping__c, Use_Contract_when_ordered__c
                                        , IEC_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c
                                        , IEC_Parent_Product__r.SAP_Material_Number__c
                                    FROM Product2 
                                    WHERE IEC_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c IN :setProductRatePlanZId];
        
        if(lstProduct != null && lstProduct.size() > 0){
            for(Product2 oProduct : lstProduct){
                mapProductRatePlanZId_Product.put(oProduct.IEC_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c, oProduct);
            }
        }
        
        //return list of product by ProductRatePlanZId
        return mapProductRatePlanZId_Product;
    }
    
    /****************************************************************************************************
        Created by CGI - Samy 2016-04-26
            Return list of products filtered by ProductInfo Id
    ****************************************************************************************************/
    public static map<Id, Product2> getProductsByProductInfo(set<Id> setProductInfoId)
    {
        map<Id, Product2> mapProductInfoId_Product = new map<Id, Product2>();
        
        //get the list of Product by SAP material number
        list<Product2> lstProduct = [SELECT id, SAP_Material_Number__c, Charge_Shipping__c, Use_Contract_when_ordered__c
                                        , IEC_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c
                                        , IEC_Parent_Product__r.SAP_Material_Number__c
                                    FROM Product2 
                                    WHERE IEC_Product_Rate_Plan_Information__c IN :setProductInfoId];
        
        if(lstProduct != null && lstProduct.size() > 0){
            for(Product2 oProduct : lstProduct){
                mapProductInfoId_Product.put(oProduct.IEC_Product_Rate_Plan_Information__c, oProduct);
            }
        }
        
        //return list of product by ProductInfoId
        return mapProductInfoId_Product;
    }


//susana
 public static List<Product2> getListOfProducts (List<Id> listProductId, Boolean includeBOM, String productCriteria, String productSort, Boolean onlyParent) {
        System.debug('listProductId::'+listProductId);

        String SOQL = ' select Id, Name, IEC_Static_Cart_Quantity__c, Line_of_Business__c, Is_Electronic_Product__c, IsNewRelease__c, Short_Title__c, Keywords__c, Family, Charge_Shipping__c, SAP_Material_Number__c, Edition__c, Media__c, Language__c, Effective_From__c, Effective_To__c, Short_Description__c, Description'
                    + '      , Sell_through_eCommerce__c, Inventory_Status__c, Expected_Availability_Date__c, Product_Segment__c, Category_Group__c, SAP_Media_Code__c, Display_Price__c,Image__c'
                    + '      , Hide_Effective_To_Date_in_eCommerce__c, Is_Quantity_Integer__c, Mega_Menu__c, Refinement_Language__c '
                    + ((!includeBOM) ? '' : ', (select Related_Product__c, Related_Product__r.Name, Related_Product__r.Media__c, Related_Product__r.Edition__c' +
                                                    ', Related_Product__r.Effective_From__c, Related_Product__r.Effective_To__c, Related_Product__r.SAP_Material_Number__c, Related_Product__r.Short_Description__c' +
                                              ' from Product_BOM__r order by Related_Product__r.Name)')
                    + '      , (select IATA_ISO_Country__r.Name, Display_in_E_Com__c from Non_Compliance_Countries__r) '
                    + '     , IEC_Product_Information__c, IEC_Product_Rate_Plan_Information__c '
                    + '     , IEC_Product_Information__r.Related_Product_Category__r.Short_Description__c '
                    + '     , IEC_Product_Information__r.Related_Product_Category__r.Long_Description__c, ImageFile__c '
                    + ' from Product2'
                    + ' where SAP_Material_Number__c != null and Display_to_ECommerce__c = true ' + Utility.getSeqTextSetting('ECommerce Products Filter', '')
                    + ((onlyParent) ? ' and IEC_Parent_Product__c = null' : '')
                    + ((listProductId == null || listProductId.size() == 0) ? '' : ' and Id in :listProductId');
                
        String customerType = User_Sel.getCustomerType(UserInfo.getUserId());
        
        //if (UserInfo.getUserType() == 'PowerPartner')
            SOQL += ' and (Restricted_Customer_Type__c = null' + (String.isBlank(customerType) ? '' : ' or Restricted_Customer_Type__c includes (:customerType)') + ')';
        
        if (productCriteria != null & productCriteria != '')
            SOQL += ' and (' + productCriteria + ')';
        
        if (productSort != null & productSort != '')
            SOQL += ' order by ' + productSort;
        else
            SOQL += ' order by Name';
        
        List<Product2> listProducts;

        system.debug('SOQL::'+SOQL);
        listProducts = Database.query(SOQL);

        return listProducts;
    }

     
}

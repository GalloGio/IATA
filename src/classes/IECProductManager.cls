/**  
  * Description: This class contains methods to query product categories, products and rate plans 
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
public with sharing class IECProductManager {

    /**
     * Returns all the Product_Category__c objects
     * @return A list of all the Product Category
     */
    public static List<Product_Category__c> getAllProductsCategory() {
        
        return [SELECT p.Name, p.Display_Name__c, p.Short_Description__c, p.Long_Description__c, p.Feature_1_Description__c
                    , p.Banner_Image__c, p.Banner_Image_Small__c, p.Product_Icon__c
                    , p.Product_Feature__c, p.Feature_6_Image__c, p.Feature_6_Description__c, p.Feature_5_Image__c
                    , p.Feature_5_Description__c, p.Feature_4_Image__c, p.Feature_4_Description__c, p.Feature_3_Image__c
                    , p.Feature_3_Description__c, p.Feature_2_Image__c, p.Feature_2_Description__c, p.Feature_1_Image__c 
                FROM Product_Category__c p
                WHERE Active__c = true
                ORDER BY p.Display_Name__c];
    }
    
    /**
     * Returns all product category filtered by feature
     * @param sFeature The feature by which to filter
     * @return A filtered list of Product Category
     */
    public static List<Product_Category__c> getProductsCategoryByFeature(string sFeature) {
        
        return [SELECT p.Name, p.Display_Name__c, p.Short_Description__c, p.Long_Description__c, p.Feature_1_Description__c
                    , p.Banner_Image__c, p.Banner_Image_Small__c, p.Product_Icon__c
                    , p.Product_Feature__c, p.Feature_6_Image__c, p.Feature_6_Description__c, p.Feature_5_Image__c
                    , p.Feature_5_Description__c, p.Feature_4_Image__c, p.Feature_4_Description__c, p.Feature_3_Image__c
                    , p.Feature_3_Description__c, p.Feature_2_Image__c, p.Feature_2_Description__c, p.Feature_1_Image__c 
                FROM Product_Category__c p
                WHERE p.Active__c = true
                    AND p.Product_Feature__c includes(:sFeature)
                ORDER BY p.Display_Name__c];
    }
    
    /**
     * Returns all product category filtered by feature
     * @param strFeature The feature by which to filter
     * @return A filtered list of Product Category
     */
    public static List<Product_Category__c> getProductsCategoryByProductCategoryCode(string sProductCategoryCode) {
        
        return [SELECT Id, Name, Button_Type__c, Display_Name__c, Short_Description__c
                    , Banner_Image__c, Banner_Image_Small__c, Product_Icon__c
                    , Feature_1_Description__c, Feature_1_Image__c, Feature_2_Description__c, Feature_2_Image__c
                    , Feature_3_Description__c, Feature_3_Image__c, Feature_4_Description__c, Feature_4_Image__c
                    , Feature_5_Description__c, Feature_5_Image__c, Feature_6_Description__c, Feature_6_Image__c
                    , Long_Description__c, Product_Feature__c
                    , Section_1_Show__c, Section_2_Name__c, Section_2_Show__c, Section_2_Description__c
                    , Section_3_Name__c, Section_3_Show__c, Section_3_Description__c, Section_4_Show__c
                    , Section_5_Name__c, Section_5_Show__c, Section_5_Description__c, Section_6_Show__c, Section_7_show__c
                    , Resource_1_File__c, Resource_1_Description__c
                    , Resource_2_File__c, Resource_2_Description__c
                    , Resource_3_File__c, Resource_3_Description__c
                    , Trial_available_for_this_Product__c, Resources_Main_Text__c, Show_price_on_eCommerce__c
                FROM Product_Category__c
                WHERE Active__c = true
                    AND Name = :sProductCategoryCode
                ORDER BY Display_Name__c];
    }

    public static Product_Category__c getProductCategoryBySFDCProduct(String productId) {
        Product2 p =  [SELECT Id,  IEC_Product_Information__r.Related_Product_Category__c FROM Product2 WHERE Id = :productId];

        return [SELECT Id, Name, Button_Type__c, Display_Name__c, Short_Description__c
                    , Banner_Image__c, Banner_Image_Small__c, Product_Icon__c
                    , Feature_1_Description__c, Feature_1_Image__c, Feature_2_Description__c, Feature_2_Image__c
                    , Feature_3_Description__c, Feature_3_Image__c, Feature_4_Description__c, Feature_4_Image__c
                    , Feature_5_Description__c, Feature_5_Image__c, Feature_6_Description__c, Feature_6_Image__c
                    , Long_Description__c, Product_Feature__c
                    , Section_1_Show__c, Section_2_Name__c, Section_2_Show__c, Section_2_Description__c
                    , Section_3_Name__c, Section_3_Show__c, Section_3_Description__c, Section_4_Show__c
                    , Section_5_Name__c, Section_5_Show__c, Section_5_Description__c, Section_6_Show__c, Section_7_show__c
                    , Resource_1_File__c, Resource_1_Description__c
                    , Resource_2_File__c, Resource_2_Description__c
                    , Resource_3_File__c, Resource_3_Description__c
                    , Trial_available_for_this_Product__c, Resources_Main_Text__c, Show_price_on_eCommerce__c
                FROM Product_Category__c
                WHERE Active__c = true
                    AND Id = : p.IEC_Product_Information__r.Related_Product_category__c
                ORDER BY Display_Name__c];
    }


    
    /**
     * Returns all Product Information filtered by product category code for anonymous users.
     * Only product with Audience "Default" will be displayed
     * @param sProductCategoryCode The Product Category code to filter on
     * @param sClientType The Client Type (member/non-member)
     * @return A filtered list of Product Information
     */
    public static List<Product_Information__c> getProductInformationsByCategoryForAnonymousUser(string sProductCategoryCode) {
        
        // validate product category code
        if (IECConstants.isProductCategoryCode(sProductCategoryCode) == false)
            throw new IECApplicationException(IECConstants.Error_InvalidProductCode + ': ' + sProductCategoryCode);
            
        return [SELECT Id, IsDeleted, Product_Audience__c, Name, Related_Product__c, Related_Product_Category__c
                    , Has_Most_Popular_Counter__c 
                FROM Product_Information__c
                WHERE IsDeleted = false
                    AND Related_Product_Category__r.Name = :sProductCategoryCode
                    AND Product_Audience__c = :IECConstants.ProductInformationAudience_DEFAULT];
    }
    
    /**
     * Returns the available ProductAudience based on the client type
     */
    public static List<String> getAvailableProductAudienceByClientType(string sClientType) {
        List<string> listAvailableProductAudience = new List<string>();
        
        // Member Airline
        if (sClientType == IECConstants.Account_ClientType_MemberAirline) {
            listAvailableProductAudience.add(IECConstants.ProductInformationAudience_MEMBERAIRLINE);
        }
        else if(sClientType == IECConstants.Account_ClientType_ThirdParty){
            listAvailableProductAudience.add(IECConstants.ProductInformationAudience_NonMember);
        }
        else {
            listAvailableProductAudience.add(IECConstants.ProductInformationAudience_DEFAULT);
        }
        
        return listAvailableProductAudience;
    }
    
    /**
     * Returns true if the specified product audience is allowed for the specified client type
     */
    public static Boolean isProductAudienceAllowedForClientType(String sProductAudience, String sClientType) {
        List<String> lstProductAudiences = getAvailableProductAudienceByClientType(sClientType);
        for (String audience : lstProductAudiences) {
            if (audience == sProductAudience)
                return true;
        }
        return false;
    }
    
    /**
     * Returns all Product Information filtered by product category code and client type
     * @param sProductCategoryCode The Product Category code to filter on
     * @param sClientType The Client Type (member/non-member)
     * @return A filtered list of Product Information
     */
    public static List<Product_Information__c> getProductInformationsByCategoryByClientType(string sProductCategoryCode, string sClientType) {
        
        // validate product category code
        if (IECConstants.isProductCategoryCode(sProductCategoryCode) == false)
            throw new IECApplicationException(IECConstants.Error_InvalidProductCode + ': ' + sProductCategoryCode);
            
        // validate client type
        if (String.isNotBlank(sClientType) && IECConstants.isClientType(sClientType) == false)
            throw new IECApplicationException(IECConstants.Error_InvalidClientType + ': ' + sClientType);

        List<string> listAvailableProductAudience = getAvailableProductAudienceByClientType(sClientType);
        
        return [SELECT Id, IsDeleted, Product_Audience__c, Name, Related_Product__c, Related_Product_Category__c
                    , Has_Most_Popular_Counter__c 
                FROM Product_Information__c
                WHERE IsDeleted = false
                    AND Related_Product_Category__r.Name = :sProductCategoryCode
                    AND Product_Audience__c IN :listAvailableProductAudience];
    }
    
    /**
     * 
     */
    public static List<Product_Rate_Plan_Information__c> getProductRatePlansInformationByProductInformation(Product_Information__c oProductInformation) {
        return [SELECT Name, Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                    , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                    , Product_Rate_Plan__r.zqu__ZuoraId__c, Related_Product_Information__r.Related_Product_Category__r.Button_Type__c, Is_Triable__c 
                FROM Product_Rate_Plan_Information__c
                WHERE Related_Product_Information__c = :oProductInformation.Id
                    AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                    AND Active__c = true
                    //AND User_Interface_Display__c = 'YES'
                    AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__Deleted__c = false
                ORDER BY Order__c];
    }

    public static List<Product_Rate_Plan_Information__c> getProductRatePlansInformations(Set<Id> ids) {
        return [SELECT Name, Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                    , Rate_Plan_ID__c, Product_Rate_Plan__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                    , Product_Rate_Plan__r.zqu__ZuoraId__c, Related_Product_Information__r.Related_Product_Category__r.Button_Type__c, Is_Triable__c 
                FROM Product_Rate_Plan_Information__c
                WHERE Id IN  :ids 
                    
                ORDER BY Order__c];
            /*AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                    AND Active__c = true
                    //AND User_Interface_Display__c = 'YES'
                    AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__Deleted__c = false*/
    }
    
    /**
     * 
     */
    public static List<Product_Rate_Plan_Information__c> getProductRatePlansInformationById(Id idProductRatePlan) {
        return [SELECT Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                    , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                    , Product_Rate_Plan__r.zqu__ZuoraId__c, Is_Triable__c, Subscription_Usage_Qty__c
                    , Related_Product_Information__r.Related_Product_Category__c
                    , Related_Product_Information__r.Related_Product_Category__r.Name
                    , Related_Product_Information__r.Related_Product_Category__r.Button_Type__c
                    , Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                    , Related_Product_Information__r.Related_Product_Category__r.Application_URL__c
                    , Related_Product_Information__r.Related_Product_Category__r.Is_Quantifiable_Product__c
                    , Related_Product_Information__r.Related_Product_Category__r.Product_Icon__c
                    , Related_Product_Information__r.Related_Product_Category__r.Show_price_on_eCommerce__c
                    , Related_Product_Information__c 
                    , Related_Product_Information__r.Related_Product__r.zqu__SKU__c
                FROM Product_Rate_Plan_Information__c
                WHERE Id = :idProductRatePlan
                    AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                    AND Active__c = true
                    //AND User_Interface_Display__c = 'YES'
                    AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__Deleted__c = false
                ORDER BY Order__c];
    }
    
    /**
     * Returns the Product_Rate_Plan_Information__c configured for the related Zuora Rate Plan
     * @param sZuoraIdProductRatePlan The Zuora ID of the Rate Plan
     * @return A Product_Rate_Plan_Information__c
     */
    public static Product_Rate_Plan_Information__c getProductRatePlansInformationByZuoraId(String sZuoraIdProductRatePlan) {
        
        List<Product_Rate_Plan_Information__c> lstRatePlan =
                [SELECT Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                    , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                    , Product_Rate_Plan__r.zqu__ZuoraId__c, Is_Triable__c
                    , Related_Product_Information__r.Related_Product_Category__c
                    , Related_Product_Information__r.Related_Product_Category__r.Button_Type__c
                    , Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                    , Related_Product_Information__c 
                    , Related_Product_Information__r.Related_Product__r.zqu__SKU__c
                FROM Product_Rate_Plan_Information__c
                WHERE Product_Rate_Plan__r.zqu__ZuoraId__c = :sZuoraIdProductRatePlan
                    AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                    AND Active__c = true
                    //AND User_Interface_Display__c = 'YES'
                    AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                    AND Product_Rate_Plan__r.zqu__Deleted__c = false
                ORDER BY Order__c];
                
        return (lstRatePlan.size() > 0 ? lstRatePlan.get(0) : null);
    }
    
    /**
     * Returns a list of Zuora rate plans from the list of provided IDs
     * @param sProductCategoryCode The Product Category code to filter on
     * @param sClientType The Client Type (member/non-member)
     * @return A filtered list of Product Rate Plan
     */
    public static List<zqu__ProductRatePlan__c> getZuoraRatePlansFromIDs(Set<String> setZuoraRatePlanIds) {
        List<zqu__ProductRatePlan__c> ratePlans = 
            [Select z.Id, z.zqu__ZuoraId__c, z.zqu__ZProduct__r.zqu__Description__c, z.zqu__ZProduct__r.Name
                , z.zqu__ZProduct__r.ProductCategory__c, z.zqu__ZProduct__c, z.zqu__Description__c, z.Name
                , (Select Name, zqu__ListPrice__c, zqu__Description__c From zqu__R00N40000001mFVKEA2__r where zqu__Deleted__c = false) 
             From zqu__ProductRatePlan__c z 
             where z.zqu__ZuoraId__c IN : setZuoraRatePlanIds];
        
        return ratePlans;
    }
    
    /**
     * Returns a list of Zuora rate plan charges of a rate plan
     * @param sRatePlanId The salesforce Rate Plan ID
     * @return A list of zuora Product Rate Plan Charges
     */
    public static List<zqu__ProductRatePlanCharge__c> getZuoraRatePlanChargesByRatePlanID(String sRatePlanId) {
        List<zqu__ProductRatePlanCharge__c> listRatePlanCharges = 
            [SELECT zqu__Deleted__c, zqu__Description__c, zqu__Discount_Apply_Type__c, zqu__Discount_Level__c
                , zqu__ListPrice__c, zqu__PriceTable__c, Name, zqu__ZuoraId__c, zqu__Model__c 
             FROM zqu__ProductRatePlanCharge__c 
             WHERE zqu__ProductRatePlan__c = :sRatePlanId
                AND zqu__Deleted__c = false];
        
        return listRatePlanCharges;
    }

    public static Map<Id, List<zqu__ProductRatePlanCharge__c>> getZuoraRatePlanChargesByRatePlanIDs(Set<Id> setRatePlanId) {
        List<zqu__ProductRatePlanCharge__c> listRatePlanCharges = 
            [SELECT zqu__Deleted__c, zqu__Description__c, zqu__Discount_Apply_Type__c, zqu__Discount_Level__c, zqu__ProductRatePlan__c
                , zqu__ListPrice__c, zqu__PriceTable__c, Name, zqu__ZuoraId__c, zqu__Model__c 
             FROM zqu__ProductRatePlanCharge__c 
             WHERE zqu__ProductRatePlan__c IN :setRatePlanId
                AND zqu__Deleted__c = false];

        Map<Id, List<zqu__ProductRatePlanCharge__c>> ret = new Map<Id, List<zqu__ProductRatePlanCharge__c>>(); 
        
        for(zqu__ProductRatePlanCharge__c c : listRatePlanCharges)   
        {
            List<zqu__ProductRatePlanCharge__c> tmp = (ret.containsKey(c.zqu__ProductRatePlan__c)) ? ret.get(c.zqu__ProductRatePlan__c) : new List<zqu__ProductRatePlanCharge__c>();
                tmp.add(c);

            ret.put(c.zqu__ProductRatePlan__c, tmp);
        }     
        
        return ret;
    }
    
    /**
     * Returns the currently active Terms & Conditions of a Product
     * @param oProductInfo The related Product Information object
     * @return A Terms_and_Conditions__c object
     */
    public static Terms_and_Conditions__c getCurrentTermsAndConditionForProduct(String sProductInfoId) {

        List<Terms_and_Conditions__c> listTC =
            [SELECT Effective_Start_Date__c, Is_Current__c, Product_Information__c, Name
                , Product_Information__r.Related_Product_Category__r.Display_Name__c
                , (SELECT Id,ContentType,BodyLength FROM Attachments WHERE IsDeleted = false ORDER BY CreatedDate desc) 
             FROM Terms_and_Conditions__c
             WHERE Product_Information__c = :sProductInfoId
                AND Effective_Start_Date__c <= :Datetime.now()
             ORDER BY Effective_Start_Date__c DESC];
                //AND Is_Current__c = true];
        
        return (listTC.isEmpty() ? null : listTC.get(0));
    }
    
    /**
     * Returns the currently active Terms & Conditions by Id
     * @param idTermsAndConditions The id for the terms and condition required
     * @return A Terms_and_Conditions__c object
     */
     /* NOT USED
    public static Terms_and_Conditions__c getTermsAndConditionByID(Id idTermsAndConditions) {
        List<Terms_and_Conditions__c> listTC =
            [SELECT Effective_Start_Date__c, Is_Current__c, Product_Information__c, Name
                , Product_Information__r.Related_Product_Category__r.Display_Name__c
                , (SELECT Id, ContentType, BodyLength
                    FROM Attachments
                    WHERE IsDeleted = false
                    ORDER BY CreatedDate desc) 
             FROM Terms_and_Conditions__c
             WHERE Id = :idTermsAndConditions];
        
        return (listTC.isEmpty() ? null : listTC.get(0));
    }
    */
    
    /**
     * Returns true if the specified T&C has been accepted by at least one customer
     */
    public static Boolean hasTnCBeenAcceptedByACustomer(String sTnCId) {
        
        List<IEC_Subscription_History__c> lstSubHist = IECSubscriptionManager.getSubscriptionHistoryByTnC(sTnCId);
        return (lstSubHist != null && lstSubHist.size() > 0);
    }
    

    /**
     * Returns true if the specified T&C has been accepted by the specified customer
     * @param idTnC The ID of the T&C object
     * @param idContact The ID of the Contact
     * @return True if the T&C has already been accepted by the specified contact
     */
    public static Boolean hasTnCBeenAcceptedByCustomer(Id idTnC, Id idContact) {
        List<IEC_Subscription_History__c> lstSubHist = IECSubscriptionManager.getSubscriptionHistoryByTnCAndContact(idTnC, idContact);
        return (lstSubHist != null && lstSubHist.size() > 0);
    }
    
    /**
     * Returns the last accepted T&C for a subscription
     */
    public static Terms_and_Conditions__c getLastAcceptedTermsAndConditionBySubscriptionName(String sSubscriptionName) {
        
        List<IEC_Subscription_History__c> lstSubHist =
            [SELECT Accepted_Terms_and_Conditions__c
                FROM IEC_Subscription_History__c
                WHERE Subscription_Number__c = :sSubscriptionName
                    and Accepted_Terms_and_Conditions__c <> null
                ORDER BY CreatedDate DESC limit 1];
        
        if (lstSubHist.isEmpty())
            return null;
        
        List<Terms_and_Conditions__c> listTC =
            [SELECT Effective_Start_Date__c, Is_Current__c, Product_Information__c, Name
                , Product_Information__r.Related_Product_Category__r.Display_Name__c
                , (SELECT Id, ContentType, BodyLength
                    FROM Attachments
                    WHERE IsDeleted = false
                    ORDER BY CreatedDate desc) 
             FROM Terms_and_Conditions__c
             WHERE Id = :lstSubHist.get(0).Accepted_Terms_and_Conditions__c];
        
        return (listTC.isEmpty() ? null : listTC.get(0));
    }

    /**
     * Returns the last accepted T&C for a subscription
     */
    public static Map<String,Terms_and_Conditions__c> getLastAcceptedTermsAndConditionBySubscriptionName(set<String> sSubscriptionNames) {
        
        Map<String,IEC_Subscription_History__c> subscriptionHistoryByNumber = new Map<String,IEC_Subscription_History__c>();
        Map<Id,String> subNumberByTermCondition = new Map<Id,String>();
        Map<String,Terms_and_Conditions__c> termConditionBySubNumber = new Map<String,Terms_and_Conditions__c>();

        List<IEC_Subscription_History__c> lstSubHist =
            [SELECT Accepted_Terms_and_Conditions__c,Subscription_Number__c
                FROM IEC_Subscription_History__c
                WHERE Subscription_Number__c in :sSubscriptionNames
                    and Accepted_Terms_and_Conditions__c <> null
                ORDER BY CreatedDate DESC ];
        
        if (lstSubHist.isEmpty())
            return null;

        for(IEC_Subscription_History__c sub : lstSubHist){
            if(!subscriptionHistoryByNumber.containsKey(sub.Subscription_Number__c)){
                subscriptionHistoryByNumber.put(sub.Subscription_Number__c, sub);
                subNumberByTermCondition.put(sub.Accepted_Terms_and_Conditions__c, sub.Subscription_Number__c);
            }
        }
        
        List<Terms_and_Conditions__c> listTC =
            [SELECT id, Effective_Start_Date__c, Is_Current__c, Product_Information__c, Name
                , Product_Information__r.Related_Product_Category__r.Display_Name__c
                , (SELECT Id, ContentType, BodyLength
                    FROM Attachments
                    WHERE IsDeleted = false
                    ORDER BY CreatedDate desc) 
             FROM Terms_and_Conditions__c
             WHERE Id in :subNumberByTermCondition.keySet()];

        if(!listTC.isEmpty()){
            for(Terms_and_Conditions__c tc : listTC){
                String subscriptionNumber = subNumberByTermCondition.get(tc.Id);
                if(!termConditionBySubNumber.containsKey(subscriptionNumber)){
                    termConditionBySubNumber.put(subscriptionNumber,tc);
                }
            }
        }
        
        //return (listTC.isEmpty() ? null : listTC.get(0));
        return termConditionBySubNumber;
    }
    
    /**
     * Returns the Rate Plan Information Trial for a given Product Info id
     * @param oProductInfo A Product_Information__c object
     * @return The trial Product_Rate_Plan_Information__c if any, null otherwise
     */
    public static Product_Rate_Plan_Information__c getTrialRatePlanForProduct(String sProductInfoId) {
        List<Product_Rate_Plan_Information__c> listRatePlanInfo =
            [SELECT Active__c, Is_Triable__c, Related_Product_Information__c, Id 
             FROM Product_Rate_Plan_Information__c
             WHERE Is_Triable__c = true
                AND Active__c = true
                AND Related_Product_Information__c = :sProductInfoId];
                
        return (listRatePlanInfo.isEmpty() ? null : listRatePlanInfo.get(0));
    }
    
    /**
     * Determines the availability of the product category
     * @param idProductCategory Id reference to the specified product category
     * @return Whether product category is available or not
     */
    public static Boolean isProductCategoryAvailable(ID idProductCategory) {
        List<Product_Category__c> lstProdCat =
            [SELECT Id 
             FROM Product_Category__c
             WHERE Id = :idProductCategory
                AND Active__c = true];

        return (!lstProdCat.isEmpty());
    }

    /**
     * Determines the availability of the product category
     * @param idProductCategory Id reference to the specified product category
     * @return Whether product category is available or not
     */
    public static Map<Id,Boolean> isProductCategoryAvailable(Set<ID> idsProductCategory) {
        
        Map<Id,Boolean> productCategoryById = new Map<Id,Boolean>();

        List<Product_Category__c> lstProdCat =
            [SELECT Id 
             FROM Product_Category__c
             WHERE Id in :idsProductCategory
                AND Active__c = true];

        if(lstProdCat != null && lstProdCat.size() > 0){
            for(Product_Category__c pc : lstProdCat){
                productCategoryById.put(pc.Id,True);
            }
        }
        return productCategoryById;
    }
    
    /**
     * Determines the availability of the product category
     * @param setProductCategory: Product category codes that is in question 
     * @return Whether product category is available or not
     */
    public static Map<String, Boolean> isProductCategoryAvailable(Set<String> setProductCategory) {
        List<Product_Category__c> lstProdCat =
            [SELECT Name
             FROM Product_Category__c
             WHERE Name IN :setProductCategory
                AND Active__c = true];
        
        Map<String, Boolean> mapProductCategoryAvailable = new Map<String, Boolean>();
        
        // Initialize Product Categories availability
        for (String sProductCategory : setProductCategory) {
            mapProductCategoryAvailable.put(sProductCategory, false);
        }
        
        // Set actual availability
        for (Product_Category__c pc : lstProdCat) {
            mapProductCategoryAvailable.put(pc.Name, true);
        }

        return mapProductCategoryAvailable;
    }
    
    /**
     * Determines the availability of the product rate plan according to the specified user type
     * @param idRatePlanInfo Id reference to the specified rate plan information
     * @param sClientType Client type to determine product audience
     * @return Whether product rate plan is active or not
     */
    public static Boolean isRatePlanAvailable(String idRatePlanInfo, String sClientType) {
        List<Product_Rate_Plan_Information__c> lstRatePlanInfo =
            [SELECT Id 
             FROM Product_Rate_Plan_Information__c
             WHERE Id = :idRatePlanInfo
                AND Active__c = true
                //AND User_Interface_Display__c = 'Yes'
                AND Related_Product_Information__r.Product_Audience__c IN :getAvailableProductAudienceByClientType(sClientType)
                AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY
                AND Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY];

        return (!lstRatePlanInfo.isEmpty());
    }
    public static Map<Id,Boolean> isRatePlanAvailable(set<Id> idRatePlanInfo, String sClientType) {
        map<Id,Boolean> isRatePlanAvailableMap = new map<Id,Boolean>();
        List<Product_Rate_Plan_Information__c> lstRatePlanInfo =
            [SELECT Id 
             FROM Product_Rate_Plan_Information__c
             WHERE Id in :idRatePlanInfo
                AND Active__c = true
                //AND User_Interface_Display__c = 'Yes'
                AND Related_Product_Information__r.Product_Audience__c IN :getAvailableProductAudienceByClientType(sClientType)
                AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY
                AND Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY];

        if(lstRatePlanInfo != null && !lstRatePlanInfo.isEmpty())
            for(Product_Rate_Plan_Information__c prpi : lstRatePlanInfo)
                isRatePlanAvailableMap.put(prpi.Id,true);
            
        
        return isRatePlanAvailableMap;
    }
    
    /**
     * Returns the possible rate plan info upgrades from a specified rate plan info
     * @param sRatePlanInfoID The source Rate Plan Information ID
     * @return A list of Product_Rate_Plan_Information__c that represents the possible upgrade paths
     */
    public static List<Product_Rate_Plan_Information__c> getRatePlanInformationUpgradesBySourceRatePlan(String sRatePlanInfoID) {
        return getRatePlanInformationUpgradesBySourceRatePlan(sRatePlanInfoID, null);
    }
    
    public static List<Product_Rate_Plan_Information__c> getRatePlanInformationUpgradesBySourceRatePlan(String sRatePlanInfoID, String sClientType) {
        Set<Id> upgradeIds = new Set<Id>();
        
        // get the upgradable rate plans
        List<Swap_Configuration__c> lstUpgrades =
            [SELECT Name, Relationship_Type__c, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c 
             FROM Swap_Configuration__c
             WHERE Source_Product_Rate_Plan_Information__c = :sRatePlanInfoID
                AND Relationship_Type__c = :IECConstants.SwappingType_Upgrade];

        for (Swap_Configuration__c upgrade : lstUpgrades)
            upgradeIds.add(upgrade.Target_Product_Rate_Plan_Information__c);

        // return associated product rate plan info
        if (String.isNotBlank(sClientType))
            return [SELECT Name, Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                        , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                        , Product_Rate_Plan__r.zqu__ZuoraId__c, Is_Triable__c
                        , Related_Product_Information__r.Related_Product_Category__r.Button_Type__c
                        , Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Related_Product_Information__c 
                    FROM Product_Rate_Plan_Information__c
                    WHERE Id IN :upgradeIds
                        AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                        AND Active__c = true
                        //AND User_Interface_Display__c = 'YES'
                        AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__Deleted__c = false
                        AND Related_Product_Information__r.Product_Audience__c IN :IECProductManager.getAvailableProductAudienceByClientType(sClientType)
                    ORDER BY Order__c];
        else
            return [SELECT Name, Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                        , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                        , Product_Rate_Plan__r.zqu__ZuoraId__c, Is_Triable__c
                        , Related_Product_Information__r.Related_Product_Category__r.Button_Type__c
                        , Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Related_Product_Information__c 
                    FROM Product_Rate_Plan_Information__c
                    WHERE Id IN :upgradeIds
                        AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                        AND Active__c = true
                        //AND User_Interface_Display__c = 'YES'
                        AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__Deleted__c = false
                    ORDER BY Order__c];
    }
    
    public static Map<Id,Product_Rate_Plan_Information__c> getRatePlanInformationUpgradesBySourceRatePlan(set<String> sRatePlanInfoIDs, String sClientType) {

        Set<Id> upgradeIds = new Set<Id>();
        Map<Id,Id> target_sourceRatePlanInfo = new Map<Id,Id>();
        List<Product_Rate_Plan_Information__c> lstPrpi = new List<Product_Rate_Plan_Information__c>();
        Map<Id,Product_Rate_Plan_Information__c> upgradeRpInfoById = new Map<Id,Product_Rate_Plan_Information__c>();
        
        // get the upgradable rate plans
        List<Swap_Configuration__c> lstUpgrades =
            [SELECT Name, Relationship_Type__c, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c 
             FROM Swap_Configuration__c
             WHERE Source_Product_Rate_Plan_Information__c in :sRatePlanInfoIDs
                AND Relationship_Type__c = :IECConstants.SwappingType_Upgrade];

        for (Swap_Configuration__c upgrade : lstUpgrades){
            //upgradeIds.add(upgrade.Target_Product_Rate_Plan_Information__c);
            if(upgrade.Target_Product_Rate_Plan_Information__c != null)
                target_sourceRatePlanInfo.put(upgrade.Target_Product_Rate_Plan_Information__c,upgrade.Source_Product_Rate_Plan_Information__c);
        }

        system.debug('sClientType ' + sClientType);
        
        // return associated product rate plan info
        if (String.isNotBlank(sClientType))
            lstPrpi = [SELECT Name, Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                        , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                        , Product_Rate_Plan__r.zqu__ZuoraId__c, Is_Triable__c
                        , Related_Product_Information__r.Related_Product_Category__r.Button_Type__c
                        , Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Related_Product_Information__c 
                    FROM Product_Rate_Plan_Information__c
                    WHERE Id IN :target_sourceRatePlanInfo.keySet()
                        AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                        AND Active__c = true
                        //AND User_Interface_Display__c = 'YES'
                        AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__Deleted__c = false
                        AND Related_Product_Information__r.Product_Audience__c IN :IECProductManager.getAvailableProductAudienceByClientType(sClientType)
                    ORDER BY Order__c];

        else
            lstPrpi = [SELECT Name, Display_As_Monthly_Fee__c, Is_Most_Popular__c, Long_Description__c, Monthly_Price__c, Order__c, Short_Description__c
                        , Rate_Plan_ID__c, User_Interface_Display__c, Product_Rate_Plan__r.Name, Product_Rate_Plan__r.zqu__ZProduct__c
                        , Product_Rate_Plan__r.zqu__ZuoraId__c, Is_Triable__c
                        , Related_Product_Information__r.Related_Product_Category__r.Button_Type__c
                        , Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Related_Product_Information__c 
                    FROM Product_Rate_Plan_Information__c
                    WHERE Id IN :target_sourceRatePlanInfo.keySet()
                        AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                        AND Active__c = true
                        //AND User_Interface_Display__c = 'YES'
                        AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                        AND Product_Rate_Plan__r.zqu__Deleted__c = false
                    ORDER BY Order__c];

        if(lstPrpi.size() > 0){
            for(Product_Rate_Plan_Information__c prpi : lstPrpi){
                Id srpi = target_sourceRatePlanInfo.get(prpi.Id);
                if(srpi != null)
                    upgradeRpInfoById.put(srpi,prpi);
            }
        }            
        //return new Map<Id,Product_Rate_Plan_Information__c>(lstPrpi);
        return upgradeRpInfoById;

    }
    
    /**
     * Returns true if the specified T&C has an attachment related to it
     */
    public static Boolean isTermsAndConditionsHasAttachment(String sTnCId) {
        List<Attachment> lstAttachments =
            [SELECT Id, Body, Name, ParentId 
             FROM Attachment
             WHERE ParentId =:sTnCId];

        return (!lstAttachments.isEmpty());
    }
}
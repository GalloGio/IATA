/**
  * Description: This class handles all subscription related
  * Author: Samy Saied
  * Version: 1.0
  * History: 
        - Sayed Ramadan
            Added method to check if a given product is triable
            Added method to get all triable products in the system
            Added method to re-enable purchasing trials for a given contact/product
        - Sayed Ramadan
            Added method to get swapping rate plans
        - 20160805-Sonny Leman:
            Merge change from eBroadcast special handling for subscription creation for Ebroadcast Pay-As-You-Go product
        - 20160928-Sonny Leman:
            ebcSubscriptionInitialization uses EBC_Setup/IECEBC_Utility.ebcPayAsYouGoProductRatePlanIdSet to check if it is an Ebroadcast Pay-As-You-Go product rate plan, for code consistency.
         
  */
public with sharing class IECSubscriptionManager {

    public static final String TERM_TYPE = 'TERMED';
    public static final Integer INVOICE_PREVIEW_TERM = 12;
    public static final Integer SUBSCRIPTION_TERM = 12;
    public static final Integer EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM = 1; 
    public static final String EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM_PERIOD = 'Day';
    public static final String EBC_PAY_AS_YOU_GO_SUBSCRIPTION_NOTES = 'eBroadcast Pay-As-You-Go activation';
    public static final String EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO = 'Pay-As-You-Go';

    /**
     * Checks whether the Customer Portal Contact is eligible for a Trial or not
     * @param idContact Salesforce ID for customer portal contact
     * @param idRatePlan Salesforce ID for trial rate plan information
     * @return True/False whether the contact can checkout the specified trial rate plan
     */
    public static boolean canContactPurchaseTrialPlan(Id idContact, Id idRatePlanInformation) {
        List<Trial__c> lstTrials =
            [SELECT Product_Rate_Plan_Information__c
            FROM Trial__c
            WHERE Contact__c = :idContact
                AND Product_Rate_Plan_Information__c = :idRatePlanInformation
                //AND Trial_Date__c = LAST_N_DAYS:180
                AND Ignore__c = false];

        return lstTrials.isEmpty();
    }
    
    /**
     * Records the trial purchase by the contact for future checks
     * @param idContact Salesforce ID for customer portal contact
     * @param idRatePlan Salesforce ID for trial rate plan information
     */
    public static void addTrialSubscription(Id idContact, Id idRatePlanInformation) {
        
        Trial__c trl = new Trial__c(
            Product_Rate_Plan_Information__c = idRatePlanInformation
            , Contact__c = idContact
            , Trial_Date__c = Date.today()
            , Ignore__c = false
        );
        insert trl;
        
    }
    
    /**
     * Re-enables a contact to purchase a trial product
     * @param idContact Salesforce ID for customer portal contact
     * @param idRatePlan Salesforce ID for trial rate plan
     */
    public static void enableTrialSubscription(Id idContact, Id idRatePlanInformation) {
        
        List<Trial__c> trials =
            [SELECT Id, Ignore__c 
            FROM Trial__c
            WHERE Contact__c = :idContact
                AND Product_Rate_Plan_Information__c = :idRatePlanInformation
                AND Ignore__c = false];
        for(Trial__c trial : trials){
            trial.Ignore__c = true;
        }
        if(!trials.isEmpty()){
            update trials;
        }       
    }
    
    /**
     * Checks whether a given product is triable or not
     * @param idProduct Salesforce ID for product information
     * @return True/False whether the product is triable
     */
    public static boolean isProductTriable(Id idProduct){
        List<Product_Rate_Plan_Information__c> ratePlans =
            [SELECT Id 
            FROM Product_Rate_Plan_Information__c 
            WHERE Is_Triable__c = true
                AND Related_Product_Information__c=:idProduct
                AND Related_Product_Information__r.Related_Product_Category__r.Active__c = true
                AND Active__c = true
                //AND User_Interface_Display__c = 'YES'
                AND Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__ZProduct__r.zqu__EffectiveEndDate__c >= TODAY
                AND Product_Rate_Plan__r.zqu__EffectiveStartDate__c <= TODAY and Product_Rate_Plan__r.zqu__EffectiveEndDate__c >= TODAY
                AND Product_Rate_Plan__r.zqu__Deleted__c = false
                ];
        return !ratePlans.isEmpty();
    }
    
    /**
     * Returns a list of all triable products in the system
     * @return List of product information objects with the following fields:
     *          - Id
                - Name
     */
    public static List<Product_Information__c> getTriableProducts(){
        return [SELECT Id, Name
                FROM Product_Information__c
                WHERE Id IN
                    (SELECT Related_Product_Information__c
                    FROM Product_Rate_Plan_Information__c
                    WHERE Is_Triable__c = true)];
    }
    
    /**
     * Returns a map of product rate plans information where:
     *      - map key is the source rate plan id (usually non member rate plan)
     *      - map value is the target rate plan of a swap (usually a member rate plan) 
     * @return Map of product rate plan objects with the following fields:
     *          - Id
                - Name
                - Short_Description__c
                - Monthly_Price__c
                - Order__c
                - Rate_Plan_ID__c
                - Related_Product_Information__c
                - Product_Rate_Plan__c
     */
    public static Map<Id,Product_Rate_Plan_Information__c> getTargetSwappedRatePlans(Set<ID> sourceRatePlanIds, String targetUserType){
        Map<Id,Product_Rate_Plan_Information__c> m = new Map<Id,Product_Rate_Plan_Information__c>();
        List<Swap_Configuration__c> swapConfigs =
            [SELECT Id, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c
            FROM Swap_Configuration__c
            WHERE Source_Product_Rate_Plan_Information__c IN :sourceRatePlanIds
                //AND Product_Information__r.Product_Audience__c = :targetUserType
                AND Target_Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c = :targetUserType
                AND Relationship_Type__c = :IECConstants.SwappingType_Swap];
        System.debug('Swap configs' + swapConfigs);
        
        if(!swapConfigs.IsEmpty()){
            Map<ID,ID> sourcePlanIdsByTarget = new Map<ID,ID>();
            for(Swap_Configuration__c swapConfig : swapConfigs){
                sourcePlanIdsByTarget.put(swapConfig.Target_Product_Rate_Plan_Information__c, swapConfig.Source_Product_Rate_Plan_Information__c);
            }
            List<Product_Rate_Plan_Information__c> targetPlans =
                [SELECT Id, Name, Short_Description__c, Monthly_Price__c, Order__c, Rate_Plan_ID__c, Related_Product_Information__c, Product_Rate_Plan__c
                FROM Product_Rate_Plan_Information__c
                WHERE Id IN :sourcePlanIdsByTarget.keySet()
                    AND Active__c = true];
            System.debug('Targer plans' + targetPlans);
            for (Product_Rate_Plan_Information__c targetPlan : targetPlans){
                m.put(sourcePlanIdsByTarget.get(targetPlan.Id), targetPlan);
            }
        }
        return m;
    }
    
    /**
     * Returns a map of product rate plans information where:
     *      - map key is the target rate plan id (usually member rate plan)
     *      - map value is the source rate plan of a swap (usually a non member rate plan) 
     * @return Map of product rate plan objects with the following fields:
     *          - Id
                - Name
                - Short_Description__c
                - Monthly_Price__c
                - Order__c
                - Rate_Plan_ID__c
                - Related_Product_Information__c
                - Product_Rate_Plan__c
     */
    public static Map<Id,Product_Rate_Plan_Information__c> getSourceSwappedRatePlans(Set<ID> targetRatePlanIds, String userType){
        Map<Id,Product_Rate_Plan_Information__c> m = new Map<Id,Product_Rate_Plan_Information__c>();
        List<Swap_Configuration__c> swapConfigs =
            [SELECT Id, Source_Product_Rate_Plan_Information__c, Target_Product_Rate_Plan_Information__c
            FROM Swap_Configuration__c
            WHERE Target_Product_Rate_Plan_Information__c IN :targetRatePlanIds
                AND Source_Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c = :userType
                AND Relationship_Type__c = :IECConstants.SwappingType_Swap];

        if(!swapConfigs.IsEmpty()){
            Map<ID,ID> targetPlanIdsBySource = new Map<ID,ID>();
            for(Swap_Configuration__c swapConfig : swapConfigs){
                targetPlanIdsBySource.put(swapConfig.Source_Product_Rate_Plan_Information__c, swapConfig.Target_Product_Rate_Plan_Information__c);
            }

            List<Product_Rate_Plan_Information__c> sourcePlans =
                [SELECT Id, Name, Short_Description__c, Monthly_Price__c, Order__c, Rate_Plan_ID__c, Related_Product_Information__c, Product_Rate_Plan__c
                FROM Product_Rate_Plan_Information__c
                WHERE Id IN :targetPlanIdsBySource.keySet()
                    AND Active__c = true];

            for (Product_Rate_Plan_Information__c sourcePlan : sourcePlans){
                m.put(targetPlanIdsBySource.get(sourcePlan.Id), sourcePlan);
            }
        }
        return m;
    }
    
    /**
     * Preview an invoice for an anonynous user with all the product/rate plans from the provided list
     * @param listRatePlanDataZuoraObject A list of RatePlanData (Zuora API object) containing the rate plans
     * @param contact bill/sold-to contact to render the invoice as, if value is NULL then render as guest contact
     * @return A Zuora Invoice object
     */
    public static Zuora.zObject previewInvoice(List<Zuora.zObject> listRatePlanDataZuoraObject, Contact contact) {
        try {
            Zuora.zApi.SubscribeOptions subscribeOptions = new Zuora.zApi.SubscribeOptions();
            subscribeOptions.GenerateInvoice = true;
            subscribeOptions.ProcessPayments = false;
            
            Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
            previewOpt.EnablePreviewMode = true;
            previewOpt.NumberOfPeriods = 1;
            
            // create subscription object
            Zuora.zObject subscription = new Zuora.zObject('Subscription');
            subscription.setValue('Name', 'Subscription preview price');
            subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
            subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
            subscription.setValue('TermType', TERM_TYPE);
            subscription.setValue('InitialTerm', INVOICE_PREVIEW_TERM);
            subscription.setValue('RenewalTerm', INVOICE_PREVIEW_TERM);
            
            // create subscription data object
            Zuora.zApi.SubscriptionData subscriptionData = new Zuora.zApi.SubscriptionData();
            subscriptionData.Subscription = subscription;
            subscriptionData.RatePlanData = listRatePlanDataZuoraObject;
                
            // create subscribe request object
            Zuora.zApi.SubscribeRequest subsRequest = new Zuora.zApi.SubscribeRequest();
            
            // since user is anonymous, create sample account and contacts
            subsRequest.ZAccount = IECTestUtil.createSampleZuoraAccount();
            if (contact == null) {
                subsRequest.BillToContact = IECTestUtil.createSampleZuoraBillToContact();
                subsRequest.SoldToContact = IECTestUtil.createSampleZuoraSoldToContact();
            }
            else {
                if (IECUserManager.isBillingAddressFilled(contact.Id))
                    subsRequest.BillToContact = IECZuoraHelper.createZuoraBillToContact(contact);
                else
                    subsRequest.BillToContact = IECTestUtil.createSampleZuoraBillToContact();
                
                // NOTE: for subscription preview, we ignore the Sold To contact (the billing country will be considered)
            }

            // No payment method set; it will use the DefaultPaymentMethodId set in the Sample Account
            subsRequest.SubscribeOptions = subscribeOptions;
            subsRequest.SubscriptionData = subscriptionData;
            subsRequest.PreviewOptions = previewOpt;
            
            List<Zuora.zApi.SubscribeRequest> listSubsRequests = new List<Zuora.zApi.SubscribeRequest>{subsRequest};
            List<Zuora.zApi.SubscribeResult> subscribeResults;
            
            // not in test method
            if (!Test.isRunningTest()) {
                subscribeResults = IECZuoraHelper.zApiInstance.zsubscribe(listSubsRequests);
            } 
            // in test method so we fake the call
            else {
                subscribeResults = new List<Zuora.zApi.SubscribeResult>();
                Zuora.zApi.SubscribeResult res = new Zuora.zApi.SubscribeResult();
                res.Success = !listRatePlanDataZuoraObject.isEmpty();
                List<Zuora.zObject> lstInvoiceDatas = new List<Zuora.zObject>();
                Zuora.zObject oInvoiceData = new Zuora.zObject('InvoiceData');
                Zuora.zObject oInvoice = new Zuora.zObject('Invoice');
                oInvoice.setValue('AmountWithoutTax', 42.0);
                oInvoice.setValue('TaxAmount', 0.2);
                oInvoice.setValue('Amount', 42.2);
                oInvoiceData.setValue('Invoice', oInvoice);
                lstInvoiceDatas.add(oInvoiceData);
                res.InvoiceDatas = lstInvoiceDatas;
                subscribeResults.add(res);
            }
            
            // check the result
            for (Zuora.zApi.SubscribeResult result: subscribeResults) {
                if (result.Success) {
                    if (result.InvoiceDatas != null) {
                        for (Zuora.zObject invData: result.InvoiceDatas) {
                            Zuora.zObject invoice = (Zuora.zObject) invData.getValue('Invoice');
                            return invoice;
                        }
                    }
                } 
                else {
                    // failure
                    for (Zuora.zObject error: result.errors) {
                        String errorCode = (String) error.getValue('Code');
                        String message = (String) error.getValue('Message');
                        throw new IECApplicationException(errorCode + ' : ' + message);
                    }
                }
            }
                
            return null;
        }
        catch (Exception ex) {
            throw new IECApplicationException('Cannot preview invoice: ' + ex.getMessage());
        }
    }
        
    /**
     * Renews an existing subscription
     * @param zIdSubscription Zuora ID for the subscription to be renewed
     * @param autoRenew flag to determine whether the subscription will be set to auto-renew or not
     * @param isPreview flag to determine whether this call is a preview or actual amendment
     * @param ePaymentType Enumeration holding the payment method
     * @param creditCard The zuora payment method to use (mandatory if payment method is CREDIT_CARD)
     * @param lstAcceptedTnCs The list of Terms & Conditions that were accepted
     * @return AmendResult object holding the status and invoice for related amendment
     */
    public static Zuora.zApi.AmendResult renewSubscription(IECCustomer oCustomer, String sSubscriptionNumber, String zIdSubscription, Id idRatePlanInfo, Integer iQuantity, DateTime dtRenewalTermStartDate, Boolean autoRenew, Boolean isPreview, IECConstants.PaymentType ePaymentType, IECZuoraHelper.PaymentMethod creditCard, List<Terms_and_Conditions__c> lstAcceptedTnCs, String sPurchaseOrder) {
        Boolean bPOUpdated = false;
        try {
            if (!isPreview) {
                if (oCustomer == null)
                    throw new IECApplicationException(Label.IEC_Error_MustLogin);
    
                if (ePaymentType == null)
                    throw new IECApplicationException(Label.IEC_Error_PleaseSelectPaymentMethod);

                ////////////
                // Account: Update payment method if required
                String DefaultPaymentMethodId = '';
                
                if(ePaymentType == IECConstants.PaymentType.BANK_TRANSFER) 
                    DefaultPaymentMethodId = IECConstants.PaymentMethod_BankTransfer_ZuoraID;
                else if(ePaymentType == IECConstants.PaymentType.ICH) 
                    DefaultPaymentMethodId = IECConstants.PaymentMethod_ICH_ZuoraID;
                else if (creditCard != null && creditCard.zId != '') 
                    DefaultPaymentMethodId = creditCard.zId;
    
                // if the default payment method has changed, update the Default Payment Method, AutoPay flag and Invoice Template Id 
                if (((String)oCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId')) != DefaultPaymentMethodId && !Test.isRunningTest()) {
                    Zuora.zApi.SaveResult result = IECZuoraHelper.updateDefaultPaymentMethod((String)oCustomer.RelatedZuoraAccount.getValue('Id'), DefaultPaymentMethodId );
    
                    if (!result.Success)
                        throw new IECApplicationException(Label.IEC_Error_Cannot_update_default_payment_method);
                    else
                        oCustomer.RelatedZuoraAccount.setValue('DefaultPaymentMethodId', defaultPaymentMethodId);
                }
            }
            
            // An array of all amendments required to upgrade the subscription
            List<Zuora.zObject> lstAmendments = new List<Zuora.zObject>();

            // create amendment
            Zuora.zObject amend = new Zuora.zObject('Amendment');
            amend.setValue('Name', 'Renewing Subscription');
            amend.setValue('Type', 'Renewal');
            amend.setValue('SubscriptionId', zIdSubscription);
            amend.setValue('AutoRenew', autoRenew);
            amend.setValue('Status', 'Completed');
            amend.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
            amend.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
            amend.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
            lstAmendments.add(amend);
                        
            /**************************************************
            *   2016-04-26: Samy: Add Tax calculation
            **************************************************/
            
            // TODO verify the Charge Type for the products with Thai
            // Retrieve all Charges under the specified subscription
            List<Zuora__SubscriptionProductCharge__c> lstSubChrg = new IEC_ZSubscriptionProductCharge_Sel().getZSubscriptionProductChargeByProdRatePlanChargeZId(
                    new Set<String> {zIdSubscription}
                    , new Set<String> {Utility.getTextSetting('Zuora tax Charge id'), Utility.getTextSetting('Zuora shipping Charge id')}
                    , false
                    , 'Product_Rate_Plan_Charge__r.zqu__Model__c NOT IN (\'\'Discount-Fixed Amount\'\', \'\'Discount-Percentage\'\')').get(zIdSubscription);
            
            // Proceed only if able to get Subscription Charges
            if (lstSubChrg == null || lstSubChrg.isEmpty())
                throw new IECApplicationException('Unable to find the main product charge for the specified subscription.');


            // Determine the price and the quantity from the existing charge
            // Assuming there is only one charge per product
            Decimal dProductPrice = 0 , dQuantity = 0, dSubTotal = 0;
            dProductPrice = lstSubChrg[0].Zuora__Price__c;
            dQuantity = lstSubChrg[0].Zuora__Quantity__c;
            dSubTotal = dProductPrice * dQuantity;
            
            // Retrieve the SoldTo Location for the current contact
            Location__c oLocSoldTo = new Location_Sel().getSoldToLocationByContactId(new Set<Id> {oCustomer.RelatedContact.Id}).get(oCustomer.RelatedContact.Id);
            
            // Initialize a fake OrderItem DTO for tax and shipping calculation
            OrderItem_DTO dtoOrderItem = new OrderItem_DTO();
            Product2 oProduct;
            
            //Get Product Info
            Map<Id, Product2> mapProductInfoId_Product = Product_Sel.getProductsByProductInfo(new Set<Id> {idRatePlanInfo});
            
            if (mapProductInfoId_Product == null || mapProductInfoId_Product.isEmpty())
                throw new IECApplicationException('Unable to locate a Salesforce Product for the ProductInfo: ' + idRatePlanInfo);
            else
            {
                oProduct = mapProductInfoId_Product.get(idRatePlanInfo);
                String sProductNumber = oProduct.SAP_Material_Number__c;
                // Get the Parent SAP Code as this is the one to be used with the TAX webservice
                String sParentProductNumber = oProduct.IEC_Parent_Product__r.SAP_Material_Number__c;
                
                String sCustomerType = User_Sel.getCustomerType(UserInfo.getUserId());
                
                dtoOrderItem.sapProductCode = sParentProductNumber;
                dtoOrderItem.quantity = dQuantity;
                dtoOrderItem.subTotal = dSubTotal;
                dtoOrderItem.chargeShipping = oProduct.Charge_Shipping__c;
                dtoOrderItem.isContractProduct = oProduct.Use_Contract_when_ordered__c;
                // Set any random ID since it is a fake item
                dtoOrderItem.orderItemId = 'RANDOM';
                
                // Retrieve Tax & Shipping information for current Order Item/Subscription
                if (!Test.isRunningTest())
                {
                    String result = Order_Svc.getSAP_Freight_Tax_for_DTO(Utility.getTextSetting('vfOrder-DefaultType')
                        , Utility.getTextSetting('vfOrder-DefaultSource')
                        , Utility.getTextSetting('vfOrder-DefaultChannel')
                        , oLocSoldTo.SAP_Id__c
                        , oCustomer.RelatedContact.BillTo_Location__r.SAP_Id__c
                        , oCustomer.RelatedContact.ShipTo_Location__r.SAP_Id__c
                        , new List<OrderItem_DTO> {dtoOrderItem});
                    
                    if (result != null)
                        throw new IECApplicationException('Error returned from Tax & Shipping webservice. ' + result);
                }
                else
                {
                    dtoOrderItem.taxAmount = 10;
                    dtoOrderItem.shippingAmount = 5;
                }
            }
            
            Decimal dTax = dtoOrderItem.taxAmount;

            /////////////////////////////////////////////// 
            // create amendment to add a tax product
            if (dTax != null)
            {
                Zuora.zObject zAmend_AddProd_Tax = new Zuora.zObject('Amendment');
                zAmend_AddProd_Tax.setValue('Name', 'Add Tax Product');
                zAmend_AddProd_Tax.setValue('Description', 'Add Tax Product');
                zAmend_AddProd_Tax.setValue('Type', 'NewProduct');
                zAmend_AddProd_Tax.setValue('SubscriptionId', zIdSubscription);
                zAmend_AddProd_Tax.setValue('AutoRenew', autoRenew);
                zAmend_AddProd_Tax.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
                zAmend_AddProd_Tax.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtRenewalTermStartDate));
                
                // if paying by credit card or ICH, upgrade is active now
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                    zAmend_AddProd_Tax.setValue('Status', 'Completed');
                    zAmend_AddProd_Tax.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtRenewalTermStartDate));
                }
                else 
                    zAmend_AddProd_Tax.setValue('Status', 'Draft');
                
                // set the RatePlanCharge of the product being added
                Zuora.zObject zRatePlanCharge_AddProd_Tax = new Zuora.zObject('RatePlanCharge');
                zRatePlanCharge_AddProd_Tax.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora tax Charge id'));
                zRatePlanCharge_AddProd_Tax.setValue('Price', dTax);
                zRatePlanCharge_AddProd_Tax.setValue('Description', 'For tax calculation\nDo not delete');
                Zuora.zObject zRatePlanChargeData_AddProd_Tax = new Zuora.zObject('RatePlanChargeData');
                zRatePlanChargeData_AddProd_Tax.setValue('RatePlanCharge', zRatePlanCharge_AddProd_Tax);
            
                // set the RatePlanData of the product being added
                Zuora.zObject zRatePlan_AddProd_Tax = new Zuora.zObject('RatePlan');
                zRatePlan_AddProd_Tax.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
                Zuora.zObject zRatePlanData_AddProd_Tax = new Zuora.zObject('RatePlanData');
                zRatePlanData_AddProd_Tax.setValue('RatePlan', zRatePlan_AddProd_Tax);
                zRatePlanData_AddProd_Tax.setValue('RatePlanChargeData', new List<Zuora.zObject> {zRatePlanChargeData_AddProd_Tax});
                
                // Now add the RatePlanData to the amendment record
                zAmend_AddProd_Tax.setValue('RatePlanData', zRatePlanData_AddProd_Tax);
                
                // Add the amendment to the amendment request
                lstAmendments.add(zAmend_AddProd_Tax);
            }
                
            Decimal dShipping = (dtoOrderItem.shippingAmount == null && dtoOrderItem.handlingCharges == null) ? null
                : ((dtoOrderItem.shippingAmount == null ? 0 : dtoOrderItem.shippingAmount)
                    + (dtoOrderItem.handlingCharges == null ? 0 : dtoOrderItem.handlingCharges));
                
             /////////////////////////////////////////////// 
            // create amendment to add a shipping product
            if (dShipping != null && dShipping > 0)
            {
                Zuora.zObject zAmend_AddProd_Ship = new Zuora.zObject('Amendment');
                zAmend_AddProd_Ship.setValue('Name', 'Add Shipping Product');
                zAmend_AddProd_Ship.setValue('Description', 'Add Shipping Product');
                zAmend_AddProd_Ship.setValue('Type', 'NewProduct');
                zAmend_AddProd_Ship.setValue('SubscriptionId', zIdSubscription);
                zAmend_AddProd_Ship.setValue('AutoRenew', autoRenew);
                zAmend_AddProd_Ship.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
                zAmend_AddProd_Ship.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtRenewalTermStartDate));
                
                // if paying by credit card or ICH, upgrade is active now
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                    zAmend_AddProd_Ship.setValue('Status', 'Completed');
                    zAmend_AddProd_Ship.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtRenewalTermStartDate));
                }
                else 
                    zAmend_AddProd_Ship.setValue('Status', 'Draft');
        
                // set the RatePlanCharge of the product being added
                Zuora.zObject zRatePlanCharge_AddProd_Ship = new Zuora.zObject('RatePlanCharge');
                zRatePlanCharge_AddProd_Ship.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora shipping Charge id'));
                zRatePlanCharge_AddProd_Ship.setValue('Price', dShipping);
                zRatePlanCharge_AddProd_Ship.setValue('Description', 'For Shipping calculation\nDo not delete');
                Zuora.zObject zRatePlanChargeData_AddProd_Ship = new Zuora.zObject('RatePlanChargeData');
                zRatePlanChargeData_AddProd_Ship.setValue('RatePlanCharge', zRatePlanCharge_AddProd_Ship);
            
                // set the RatePlanData of the product being added
                Zuora.zObject zRatePlan_AddProd_Ship = new Zuora.zObject('RatePlan');
                zRatePlan_AddProd_Ship.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
                Zuora.zObject zRatePlanData_AddProd_Ship = new Zuora.zObject('RatePlanData');
                zRatePlanData_AddProd_Ship.setValue('RatePlan', zRatePlan_AddProd_Ship);
                zRatePlanData_AddProd_Ship.setValue('RatePlanChargeData', new List<Zuora.zObject> {zRatePlanChargeData_AddProd_Ship});
                
                // Now add the RatePlanData to the amendment record
                zAmend_AddProd_Ship.setValue('RatePlanData', zRatePlanData_AddProd_Ship);
                
                // Add the amendment to the amendment request
                lstAmendments.add(zAmend_AddProd_Ship);
            }
            
            /**************************************************
            *   End Of: 2016-04-26: Samy: Add Tax calculation
            **************************************************/

            // create amendment request
            Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
            
            // Specify amendment options for generating invoice to determine total amount and taxes
            Zuora.zApi.AmendOptions amendOpt = new Zuora.zApi.AmendOptions();
            amendOpt.GenerateInvoice = true;
            amendOpt.ProcessPayments = (!isPreview && ePaymentType == IECConstants.PaymentType.CREDIT_CARD); // can only set ProcessPayments=true for electronic payments (credit card)
            amendRequest.AmendOptions = amendOpt;

            if (isPreview) {
                // Specify preview options for to simulate the amendment without actually submitting it
                Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
                previewOpt.EnablePreviewMode = true;
                previewOpt.NumberOfPeriods = 1;
                amendRequest.PreviewOptions = previewOpt;
            }
            else {
                // Specify target date for the invoice to generate an invoice for the renewal
                Zuora.zApi.InvoiceProcessingOptions invoiceOpt = new Zuora.zApi.InvoiceProcessingOptions();
                invoiceOpt.InvoiceTargetDate = IECZuoraHelper.getFutureDate(dtRenewalTermStartDate);
                invoiceOpt.InvoiceDate = IECZuoraHelper.getCurrentDate();
                amendRequest.AmendOptions.InvoiceProcessingOptions = invoiceOpt;
            }
            
            if (!isPreview && String.isNotBlank(sPurchaseOrder)) {
                IECZuoraHelper.UpdateSubscriptionPO(zIdSubscription, sPurchaseOrder);
                bPOUpdated = true;
            }
            
            amendRequest.Amendments = lstAmendments;
            Zuora.zApi.AmendResult result =
                (!Test.isRunningTest())
                    ? IECZuoraHelper.amendApiCall(amendRequest)
                    : IECTestUtil.CreateSampleAmendResult();
            
            ///////////////////////////////////////////////
            // On-demand sync for the user Billing Account
            
            if (!isPreview) {
                if (result.Success) {
                    /* Commented: 2016-05-05: Sales Order will be created from the generated ZInvoice Item trigger
                    // Create an order once the subscription is confirmed through Zuora
                    String sPaymentMethod = IECConstants.parsePaymentMethodEnumToPicklistValue(ePaymentType);
                    Customer_DTO oCurrentCustomer = Customer_DTO.getLoggedCustomer();
                    Order oOrder = new Order_Sel().initializeOrder(oCurrentCustomer.sfAccount, oCurrentCustomer.sfContact);
    
                    // Update order fields
                    oOrder.Type = 'Order';
                    oOrder.Payment_Type__c = sPaymentMethod;
                    oOrder.Status = Order_Svc.getOrderStatusByPaymentType(sPaymentMethod);
                    oOrder.Is_Paid__c = Order_Svc.isOrderPaidByPaymentType(sPaymentMethod);
                    oOrder.IEC_Payment_Date__c = (Order_Svc.isOrderPaidByPaymentType(sPaymentMethod)) ? Date.today() : null;
                    update oOrder;
                    
                    //Set the pricebookEntry
                    Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
                    PricebookEntry pbe  = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, new set<Id>{oProduct.Id}).get(oProduct.Id);
    
                    //get Item by order
                    OrderItem oOrderItem = new OrderItem (
                        OrderId = oOrder.Id
                        , PriceBookEntryId = pbe.Id
                        , Quantity = dtoOrderItem.quantity
                        , UnitPrice = dProductPrice
                        , Charge_Shipping__c = oProduct.Charge_Shipping__c
                        , Tax__c = dTax
                        , Freight_Charge__c = dShipping
                    );
                    insert oOrderItem;
                    */
                    
                    OnDemandSyncAccounts(new Set<String> {(String) oCustomer.RelatedZuoraAccount.getValue('Id')});
                
                    if (autoRenew) {
                        Zuora.zApi.AmendResult zResult = IECZuoraHelper.updateZuoraAutoRenew(oCustomer, zIdSubscription, autoRenew, dtRenewalTermStartDate);
                        if (!zResult.Success)
                            throw new IECApplicationException(Label.IEC_Error_CannotUpdateAutoRenew);
                    }
                    
                    // keep track of the upgrade purchase in our custom object
                    insertSubscriptionHistory('Renew', oCustomer, idRatePlanInfo, iQuantity, ePaymentType, creditCard, lstAcceptedTnCs.get(0).Id, (String) oCustomer.RelatedZuoraAccount.getValue('AccountNumber'), sSubscriptionNumber, null, result.InvoiceId);
                    
                    // get the Product Rate Plan Info
                    /* PENDING BECAUSE NOT TESTED
                    List<Product_Rate_Plan_Information__c> lstPRPI = IECProductManager.getProductRatePlansInformationById(idRatePlanInfo);
                    
                    // if rate plan is related to Product Category CAC, GAD or [insert other here]
                    String sProductCategory = lstPRPI.get(0).Related_Product_Information__r.Related_Product_Category__r.Name;
                    if (sProductCategory == IECConstants.ProductCategory_SF_CACPRO || sProductCategory == IECConstants.ProductCategory_SF_CACWEB || sProductCategory == IECConstants.ProductCategory_SF_GAD) {
                        
                        // create a new Product Access with the renewed date
                        IECApplicationsManager.createProductAccessOnRenewedSubscription(oCustomer.RelatedContact.Id, sSubscriptionNumber, zIdSubscription);
                    }
                    */
                }
                else {
                    // Rollback PO Changes
                    if (bPOUpdated)
                        IECZuoraHelper.UpdateSubscriptionPO(zIdSubscription, '');
                }
            }
            
            return result;          
        }
        catch(Exception ex) {
            // Rollback PO Changes
            if (bPOUpdated)
                IECZuoraHelper.UpdateSubscriptionPO(zIdSubscription, '');
            throw new IECApplicationException('Could not Renew Subscription. Error: ' + ex.getMessage() + ex.getStackTraceString());
        }
        
        return null;
    }
    
    /**
     * Upgrades an existing subscription by removing a rate plan and adding a new one.
     * @param oCustomer An object representing teh customer
     * @param zIdSubscription Zuora ID for the subscription to be upgraded
     * @param currentRatePlanZId Rate Plan Zuora ID of the current rate plan
     * @param upgradeToProductRatePlanZId Rate Plan Zuora ID of the product being upgraded to
     * @param dtUpgradeDate Date of the upgrade
     * @param autoRenew Flag to determine whether the subscription will be set to auto-renew or not
     * @param isPreview flag to determine whether this call is a preview or actual amendment
     * @param ePaymentType Enumeration holding the payment method
     * @param creditCard The zuora payment method to use (mandatory if payment method is CREDIT_CARD)
     * @return AmendResult object holding the status and invoice for related amendment
     */
    public static Zuora.zApi.AmendResult upgradeSubscription(IECCustomer oCustomer, String sSubscriptionNumber, String zIdSubscription
                    , String currentRatePlanZId, String upgradeToProductRatePlanZId, String upgradeToProductRatePlanInfoId
                    , Integer iQuantity, DateTime dtUpgradeDate, Boolean autoRenew, Boolean isPreview, IECConstants.PaymentType ePaymentType
                    , IECZuoraHelper.PaymentMethod creditCard, Terms_and_Conditions__c oAcceptedTnCs, String sPurchaseOrder
                    , Decimal dUnitPrice, Decimal dQuantity, Decimal dTax, Decimal dShipping) {
        Boolean bPOUpdated = false;
        try {
            if (!isPreview) {
                if (oCustomer == null)
                    throw new IECApplicationException(Label.IEC_Error_MustLogin);
    
                if (ePaymentType == null)
                    throw new IECApplicationException(Label.IEC_Error_PleaseSelectPaymentMethod);

                ////////////
                // Account: Update payment method if required
                String DefaultPaymentMethodId = '';
                
                if(ePaymentType == IECConstants.PaymentType.BANK_TRANSFER) 
                    DefaultPaymentMethodId = IECConstants.PaymentMethod_BankTransfer_ZuoraID;
                else if(ePaymentType == IECConstants.PaymentType.ICH) 
                    DefaultPaymentMethodId = IECConstants.PaymentMethod_ICH_ZuoraID;
                else if (creditCard != null && creditCard.zId != '') 
                    DefaultPaymentMethodId = creditCard.zId;

                // if the default payment method has changed, update the Default Payment Method, AutoPay flag and Invoice Template Id 
                if (((String)oCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId')) != DefaultPaymentMethodId && !Test.isRunningTest()) {
                    Zuora.zApi.SaveResult result = IECZuoraHelper.updateDefaultPaymentMethod((String)oCustomer.RelatedZuoraAccount.getValue('Id'), DefaultPaymentMethodId );

                    if (!result.Success)
                        throw new IECApplicationException(Label.IEC_Error_Cannot_update_default_payment_method);
                    else
                        oCustomer.RelatedZuoraAccount.setValue('DefaultPaymentMethodId', defaultPaymentMethodId);
                }
            }
            
            // An array of all amendments required to upgrade the subscription
            List<Zuora.zObject> lstAmendments = new List<Zuora.zObject>();
            
            // get the Term Start Date of the the Subscription
            Zuora__Subscription__c oSubscription = getSubscriptionByName(sSubscriptionNumber);
            if (oSubscription == null)
                throw new IECApplicationException(Label.IEC_Error_SubscriptionNotFound);
            Datetime dtSubscriptionTermStartDate = Datetime.newInstance(oSubscription.Zuora__TermStartDate__c.year(), oSubscription.Zuora__TermStartDate__c.month(), oSubscription.Zuora__TermStartDate__c.day());
            Datetime dtContractAndServiceActivationDate = IECZuoraHelper.GetDateInAmericasNewYorkTZ(dtSubscriptionTermStartDate > dtUpgradeDate ? dtSubscriptionTermStartDate : dtUpgradeDate);

            // check if auto-renew value has changed
            Boolean bAutoRenewHasChanged = (oSubscription.Zuora__AutoRenew__c != autoRenew);

            /////////////////////////////////////////////// 
            // create first amendment to remove a product
            
            Zuora.zObject amendRemoveProduct = new Zuora.zObject('Amendment');
            amendRemoveProduct.setValue('Name', 'Upgrade subscription - remove product');
            amendRemoveProduct.setValue('Description', 'asdfasdf');
            amendRemoveProduct.setValue('Type', 'RemoveProduct');
            amendRemoveProduct.setValue('SubscriptionId', zIdSubscription);
            amendRemoveProduct.setValue('AutoRenew', autoRenew);
            amendRemoveProduct.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
            amendRemoveProduct.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
            
            // if paying by credit card or ICH, upgrade is active now
            if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                amendRemoveProduct.setValue('Status', 'Completed');
                amendRemoveProduct.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
            }
            else 
                amendRemoveProduct.setValue('Status', 'Draft');
            
            // set the RatePlanData of the product being removed
            Zuora.zObject removeRatePlan = new Zuora.zObject('RatePlan');
            removeRatePlan.setValue('AmendmentSubscriptionRatePlanId', currentRatePlanZId);
            Zuora.zObject removeRatePlanData = new Zuora.zObject('RatePlanData');
            removeRatePlanData.setValue('RatePlan', removeRatePlan);
            amendRemoveProduct.setValue('RatePlanData', removeRatePlanData);
            
            lstAmendments.add(amendRemoveProduct);
                        
            /////////////////////////////////////////////// 
            // create second amendment to add a new product
            
            Zuora.zObject amendNewProduct = new Zuora.zObject('Amendment');
            amendNewProduct.setValue('Name', 'Upgrade subscription - add product');
            amendNewProduct.setValue('Description', 'asdfasdf');
            amendNewProduct.setValue('Type', 'NewProduct');
            amendNewProduct.setValue('SubscriptionId', zIdSubscription);
            amendNewProduct.setValue('AutoRenew', autoRenew);
            amendNewProduct.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
            amendNewProduct.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
            
            // if paying by credit card or ICH, upgrade is active now
            if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                amendNewProduct.setValue('Status', 'Completed');
                amendNewProduct.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
            }
            else 
                amendNewProduct.setValue('Status', 'Draft');

            // set the RatePlanData of the product being added
            Zuora.zObject addRatePlan = new Zuora.zObject('RatePlan');
            addRatePlan.setValue('ProductRatePlanId', upgradeToProductRatePlanZId);
            Zuora.zObject addRatePlanData = new Zuora.zObject('RatePlanData');
            addRatePlanData.setValue('RatePlan', addRatePlan);
            amendNewProduct.setValue('RatePlanData', addRatePlanData);
            
            lstAmendments.add(amendNewProduct);

            //////////////////////////////////////////////////////////////
            // create third amendment only if auto-renew flag has changed
            
            Zuora.zObject amendAutoRenew = null;
            if (bAutoRenewHasChanged) {
                // create amendment
                amendAutoRenew = new Zuora.zObject('Amendment');
                amendAutoRenew.setValue('Type', 'TermsAndConditions');
                amendAutoRenew.setValue('AutoRenew', autoRenew);
                amendAutoRenew.setValue('Name', 'Autorenew change to ' + autoRenew);
                amendAutoRenew.setValue('SubscriptionId', zIdSubscription);
                amendAutoRenew.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
                amendAutoRenew.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
                
                // if paying by credit card or ICH, upgrade is active now
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                    amendAutoRenew.setValue('Status', 'Completed');
                    amendAutoRenew.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
                }
                else 
                    amendAutoRenew.setValue('Status', 'Draft');
                
                lstAmendments.add(amendAutoRenew);
            }
            
            /**************************************************
            *   2016-04-19: Samy: Add Tax calculation
            **************************************************/
            //Get Product Info
            Map<String, Product2> mapProductRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(new Set<String> {upgradeToProductRatePlanZId});
            
            if (mapProductRatePlanZId_Product == null || mapProductRatePlanZId_Product.isEmpty())
                throw new IECApplicationException('Unable to locate a Salesforce Product for the ProductRatePlan: ' + upgradeToProductRatePlanZId);
            
            Product2 oProduct = mapProductRatePlanZId_Product.get(upgradeToProductRatePlanZId);
            
            /////////////////////////////////////////////// 
            // create amendment to add a tax product
            if (!isPreview && dTax != null)
            {
                Zuora.zObject zAmend_AddProd_Tax = new Zuora.zObject('Amendment');
                zAmend_AddProd_Tax.setValue('Name', 'Add Tax Product');
                zAmend_AddProd_Tax.setValue('Description', 'Add Tax Product');
                zAmend_AddProd_Tax.setValue('Type', 'NewProduct');
                zAmend_AddProd_Tax.setValue('SubscriptionId', zIdSubscription);
                zAmend_AddProd_Tax.setValue('AutoRenew', autoRenew);
                zAmend_AddProd_Tax.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
                zAmend_AddProd_Tax.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
                
                // if paying by credit card or ICH, upgrade is active now
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                    zAmend_AddProd_Tax.setValue('Status', 'Completed');
                    zAmend_AddProd_Tax.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
                }
                else 
                    zAmend_AddProd_Tax.setValue('Status', 'Draft');
                
                // set the RatePlanCharge of the product being added
                Zuora.zObject zRatePlanCharge_AddProd_Tax = new Zuora.zObject('RatePlanCharge');
                zRatePlanCharge_AddProd_Tax.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora tax Charge id'));
                zRatePlanCharge_AddProd_Tax.setValue('Price', dTax);
                zRatePlanCharge_AddProd_Tax.setValue('Description', 'For tax calculation\nDo not delete');
                Zuora.zObject zRatePlanChargeData_AddProd_Tax = new Zuora.zObject('RatePlanChargeData');
                zRatePlanChargeData_AddProd_Tax.setValue('RatePlanCharge', zRatePlanCharge_AddProd_Tax);
            
                // set the RatePlanData of the product being added
                Zuora.zObject zRatePlan_AddProd_Tax = new Zuora.zObject('RatePlan');
                zRatePlan_AddProd_Tax.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
                Zuora.zObject zRatePlanData_AddProd_Tax = new Zuora.zObject('RatePlanData');
                zRatePlanData_AddProd_Tax.setValue('RatePlan', zRatePlan_AddProd_Tax);
                zRatePlanData_AddProd_Tax.setValue('RatePlanChargeData', new List<Zuora.zObject> {zRatePlanChargeData_AddProd_Tax});
                
                // Now add the RatePlanData to the amendment record
                zAmend_AddProd_Tax.setValue('RatePlanData', zRatePlanData_AddProd_Tax);
                
                // Add the amendment to the amendment request
                lstAmendments.add(zAmend_AddProd_Tax);
            }
                
             /////////////////////////////////////////////// 
            // create amendment to add a shipping product
            if (!isPreview && dShipping != null && dShipping > 0)
            {
                Zuora.zObject zAmend_AddProd_Ship = new Zuora.zObject('Amendment');
                zAmend_AddProd_Ship.setValue('Name', 'Add Shipping Product');
                zAmend_AddProd_Ship.setValue('Description', 'Add Shipping Product');
                zAmend_AddProd_Ship.setValue('Type', 'NewProduct');
                zAmend_AddProd_Ship.setValue('SubscriptionId', zIdSubscription);
                zAmend_AddProd_Ship.setValue('AutoRenew', autoRenew);
                zAmend_AddProd_Ship.setValue('CustomerAcceptanceDate', IECZuoraHelper.getCurrentDate());
                zAmend_AddProd_Ship.setValue('ContractEffectiveDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
                
                // if paying by credit card or ICH, upgrade is active now
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH || isPreview) {
                    zAmend_AddProd_Ship.setValue('Status', 'Completed');
                    zAmend_AddProd_Ship.setValue('ServiceActivationDate', IECZuoraHelper.getFutureDate(dtContractAndServiceActivationDate));
                }
                else 
                    zAmend_AddProd_Ship.setValue('Status', 'Draft');
        
                // set the RatePlanCharge of the product being added
                Zuora.zObject zRatePlanCharge_AddProd_Ship = new Zuora.zObject('RatePlanCharge');
                zRatePlanCharge_AddProd_Ship.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora shipping Charge id'));
                zRatePlanCharge_AddProd_Ship.setValue('Price', dShipping);
                zRatePlanCharge_AddProd_Ship.setValue('Description', 'For Shipping calculation\nDo not delete');
                Zuora.zObject zRatePlanChargeData_AddProd_Ship = new Zuora.zObject('RatePlanChargeData');
                zRatePlanChargeData_AddProd_Ship.setValue('RatePlanCharge', zRatePlanCharge_AddProd_Ship);
            
                // set the RatePlanData of the product being added
                Zuora.zObject zRatePlan_AddProd_Ship = new Zuora.zObject('RatePlan');
                zRatePlan_AddProd_Ship.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
                Zuora.zObject zRatePlanData_AddProd_Ship = new Zuora.zObject('RatePlanData');
                zRatePlanData_AddProd_Ship.setValue('RatePlan', zRatePlan_AddProd_Ship);
                zRatePlanData_AddProd_Ship.setValue('RatePlanChargeData', new List<Zuora.zObject> {zRatePlanChargeData_AddProd_Ship});
                
                // Now add the RatePlanData to the amendment record
                zAmend_AddProd_Ship.setValue('RatePlanData', zRatePlanData_AddProd_Ship);
                
                // Add the amendment to the amendment request
                lstAmendments.add(zAmend_AddProd_Ship);
            }
            
            /**************************************************
            *   End Of: 2016-04-19: Samy: Add Tax calculation
            **************************************************/

            // create amendment request
            Zuora.zApi.AmendRequest amendRequest = new Zuora.zApi.AmendRequest();
            
            // Specify amendment options for generating invoice to determine total amount and taxes
            Zuora.zApi.AmendOptions amendOpt = new Zuora.zApi.AmendOptions();
            amendOpt.GenerateInvoice = true;
            amendOpt.ProcessPayments = (!isPreview && ePaymentType == IECConstants.PaymentType.CREDIT_CARD); // can only set ProcessPayments=true for electronic payments (credit card)
            amendRequest.AmendOptions = amendOpt;

            if (isPreview) {
                // Specify preview options for to simulate the amendment without actually submitting it
                Zuora.zApi.PreviewOptions previewOpt = new Zuora.zApi.PreviewOptions();
                previewOpt.EnablePreviewMode = true;
                previewOpt.NumberOfPeriods = 1;
                amendRequest.PreviewOptions = previewOpt;
            }
            else {
                // Specify target date for the invoice to generate an invoice for the renewal
                Zuora.zApi.InvoiceProcessingOptions invoiceOpt = new Zuora.zApi.InvoiceProcessingOptions();
                invoiceOpt.InvoiceTargetDate = IECZuoraHelper.getCurrentDate();
                invoiceOpt.InvoiceDate = IECZuoraHelper.getCurrentDate();
                amendRequest.AmendOptions.InvoiceProcessingOptions = invoiceOpt;
            }
            
            amendRequest.Amendments = lstAmendments;
                                            
            if (!isPreview && String.isNotBlank(sPurchaseOrder)) {
                IECZuoraHelper.UpdateSubscriptionPO(zIdSubscription, sPurchaseOrder);
                bPOUpdated = true;
            }

            Zuora.zApi.AmendResult result =
                (!Test.isRunningTest()
                    ? IECZuoraHelper.amendApiCall(amendRequest)
                    : IECTestUtil.CreateSampleAmendResult());
                    
            if (Zuora.zApi.currentLogger != null) {
                system.debug('SOAP Upgrade Request : ' + Zuora.zApi.currentLogger.request );
                system.debug('SOAP Upgrade Response : ' + Zuora.zApi.currentLogger.response );
            }

            ///////////////////////////////////////////////
            // On-demand sync for the user Billing Account
            if (!isPreview) {
                if (result.Success) {
                    /* Commented: 2016-05-05: Sales Order will be created from the generated ZInvoice Item trigger
                    // Create an order once the subscription is confirmed through Zuora
                    String sPaymentMethod = IECConstants.parsePaymentMethodEnumToPicklistValue(ePaymentType);
                    Customer_DTO oCurrentCustomer = Customer_DTO.getLoggedCustomer();
                    Order oOrder = new Order_Sel().initializeOrder(oCurrentCustomer.sfAccount, oCurrentCustomer.sfContact);
    
                    // Update order fields
                    oOrder.Type = 'Order';
                    oOrder.Payment_Type__c = sPaymentMethod;
                    oOrder.Status = Order_Svc.getOrderStatusByPaymentType(sPaymentMethod);
                    oOrder.Is_Paid__c = Order_Svc.isOrderPaidByPaymentType(sPaymentMethod);
                    oOrder.IEC_Payment_Date__c = (Order_Svc.isOrderPaidByPaymentType(sPaymentMethod)) ? Date.today() : null;
                    update oOrder;
                    
                    //Set the pricebookEntry
                    Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
                    PricebookEntry pbe  = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, new set<Id>{oProduct.Id}).get(oProduct.Id);
    
                    //get Item by order
                    OrderItem oOrderItem = new OrderItem (
                        OrderId = oOrder.Id
                        , PriceBookEntryId = pbe.Id
                        , Quantity = dQuantity
                        , UnitPrice = dUnitPrice
                        , Charge_Shipping__c = oProduct.Charge_Shipping__c
                        , Tax__c = dTax
                        , Freight_Charge__c = dShipping
                    );
                    insert oOrderItem;
                    */
                    
                    if (!Test.isRunningTest()) {
                        // sync of the account
                        List<Zuora.SyncResult> lstSyncResults = OnDemandSyncAccounts(new Set<String> {(String) oCustomer.RelatedZuoraAccount.getValue('Id')});
                    }
                    
                    // keep track of the upgrade purchase in our custom object
                    insertSubscriptionHistory('Upgrade', oCustomer, upgradeToProductRatePlanInfoId, iQuantity, ePaymentType, creditCard, (oAcceptedTnCs == null ? null : oAcceptedTnCs.Id), (String) oCustomer.RelatedZuoraAccount.getValue('AccountNumber'), sSubscriptionNumber, null, result.InvoiceId);
                }
                else {
                    // Rollback PO Changes
                    if (bPOUpdated)
                        IECZuoraHelper.UpdateSubscriptionPO(zIdSubscription, '');
                }
            }
            
            return result;
        }
        catch(Exception ex) {
            // Rollback PO Changes
            if (bPOUpdated)
                IECZuoraHelper.UpdateSubscriptionPO(zIdSubscription, '');
            throw new IECApplicationException('Could not upgrade subscription. Error: ' + ex.getMessage() + ex.getStackTraceString());
        }
    }
    
    /**
     * Upgrades a trial (creates a new subscription)
     * @param sUpgradeRatePlanZuoraID The Zuora Id of the Rate Plan to upgrade to
     * @param oCustomer Object representing the customer
     * @param ePaymentType Enumeration holding the payment method
     * @param creditCard The zuora payment method to use (mandatory if payment method is CREDIT_CARD)
     * @param bAutoRenew True if the new subscription must auto-renew
     * @param oAcceptedTnCs The Terms & Conditions that was accepted
     * @return A SubscribeResult (Zuora object)
     */
    public static Zuora.zApi.SubscribeResult upgradeTrial(String sRatePlanInfoId, String sUpgradeRatePlanZuoraID, IECCustomer oCustomer, IECConstants.PaymentType ePaymentType, IECZuoraHelper.PaymentMethod creditCard, Boolean bAutoRenew, Terms_and_Conditions__c oAcceptedTnCs, String sPurchaseOrder) {
        try {
            if (oCustomer == null)
                throw new IECApplicationException(Label.IEC_Error_MustLogin);

            if (String.isBlank(sUpgradeRatePlanZuoraID))
                return null;
                
            if (ePaymentType == null)
                throw new IECApplicationException(Label.IEC_Error_PleaseSelectPaymentMethod);

            List<Zuora.zApi.SubscribeRequest> listSubscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
            List<Zuora.zApi.SubscribeResult> listSubscribeResults = null;

            Zuora.zApi.SubscribeRequest oSubsRequest = new Zuora.zApi.SubscribeRequest();
            
            // Subscription Options
            oSubsRequest.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
            oSubsRequest.SubscribeOptions.GenerateInvoice = true;
            oSubsRequest.SubscribeOptions.ProcessPayments = (ePaymentType == IECConstants.PaymentType.CREDIT_CARD); // can only set ProcessPayments=true for electronic payments (credit card)
            
            oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
            //oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceProcessingScope = 'Account';
            oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceTargetDate = IECZuoraHelper.getCurrentDate();
            oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceDate = IECZuoraHelper.getCurrentDate();

            // No Preview Options (preview is used for previewing the price)
            oSubsRequest.PreviewOptions = null;
            
            // Create Subscription object
            Zuora.zObject subscription = new Zuora.zObject('Subscription');
            subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
            subscription.setValue('TermType', TERM_TYPE);
            subscription.setValue('InitialTerm', SUBSCRIPTION_TERM);
            subscription.setValue('RenewalTerm', SUBSCRIPTION_TERM);
            // only activate subscription if payment is by credit card or ICH
            if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH)
                subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
            subscription.setValue('AutoRenew', bAutoRenew);
            subscription.setValue('IsInvoiceSeparate', false);
            if (String.isNotBlank(sPurchaseOrder))
                subscription.setValue('PurchaseOrder__c', sPurchaseOrder);

            // Set the source of the Subscription Creation
            subscription.setValue('Source__c', 'Salesforce');
        
            // Create the Subscription Data object
            oSubsRequest.SubscriptionData = new Zuora.zApi.SubscriptionData();
            oSubsRequest.SubscriptionData.Subscription = subscription;
            oSubsRequest.SubscriptionData.RatePlanData = IECShoppingCartHelper.createRatePlanDataListObject(sUpgradeRatePlanZuoraID, 1);
            
            /**************************************************
            *   2016-04-27: Samy: Add Tax calculation
            **************************************************/
            // Retrieve the SoldTo Location for the current contact
            Location__c oLocSoldTo = new Location_Sel().getSoldToLocationByContactId(new Set<Id> {oCustomer.RelatedContact.Id}).get(oCustomer.RelatedContact.Id);
            
            // Initialize a fake OrderItem DTO for tax and shipping calculation
            OrderItem_DTO dtoOrderItem = new OrderItem_DTO();
            Product2 oProduct;
            
            //Get Product Info
            Map<String, Product2> mapProductRatePlanZId_Product = Product_Sel.getProductsByProductRatePlan(new Set<String> {sUpgradeRatePlanZuoraID});
            
            if (mapProductRatePlanZId_Product == null || mapProductRatePlanZId_Product.isEmpty())
                throw new IECApplicationException('Unable to locate a Salesforce Product for the ProductRatePlan: ' + sUpgradeRatePlanZuoraID);
            else
            {
                oProduct = mapProductRatePlanZId_Product.get(sUpgradeRatePlanZuoraID);
                String sProductNumber = oProduct.SAP_Material_Number__c;
                // Get the Parent SAP Code as this is the one to be used with the TAX webservice
                String sParentProductNumber = oProduct.IEC_Parent_Product__r.SAP_Material_Number__c;
                
                String sCustomerType = User_Sel.getCustomerType(UserInfo.getUserId());
                // Retrieve the price for the upgrade product
                Map<String, PriceInfo_DTO> mapProductNumber_Price = new Product_Sel().getProductPriceInfo(new Set<String> {sProductNumber}, sCustomerType, null, null, true);
                
                dtoOrderItem.PriceInfo = mapProductNumber_Price.get(sProductNumber);
                dtoOrderItem.sapProductCode = sParentProductNumber;
                dtoOrderItem.quantity = 1;
                dtoOrderItem.chargeShipping = oProduct.Charge_Shipping__c;
                dtoOrderItem.isContractProduct = oProduct.Use_Contract_when_ordered__c;
                // Set any random ID since it is a fake item
                dtoOrderItem.orderItemId = 'RANDOM';
                
                Order_Svc.setPriceToOrderItemDTO(dtoOrderItem, sCustomerType);

                // Retrieve Tax & Shipping information for current Order Item/Subscription
                if (!Test.isRunningTest())
                {
                    String result = Order_Svc.getSAP_Freight_Tax_for_DTO(Utility.getTextSetting('vfOrder-DefaultType')
                        , Utility.getTextSetting('vfOrder-DefaultSource')
                        , Utility.getTextSetting('vfOrder-DefaultChannel')
                        , oLocSoldTo.SAP_Id__c
                        , oCustomer.RelatedContact.BillTo_Location__r.SAP_Id__c
                        , oCustomer.RelatedContact.ShipTo_Location__r.SAP_Id__c
                        , new List<OrderItem_DTO> {dtoOrderItem});
                    
                    if (result != null)
                        throw new IECApplicationException('Error returned from Tax & Shipping webservice. ' + result);
                }
                else
                {
                    dtoOrderItem.taxAmount = 10;
                    dtoOrderItem.shippingAmount = 5;
                }
            }
            
            Decimal dTax = dtoOrderItem.taxAmount;

            /////////////////////////////////////////////// 
            // create amendment to add a tax product
            if (dTax != null)
            {
                // set the RatePlanCharge of the product being added
                Zuora.zObject zRatePlanCharge_Tax = new Zuora.zObject('RatePlanCharge');
                zRatePlanCharge_Tax.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora tax Charge id'));
                zRatePlanCharge_Tax.setValue('Price', dTax);
                zRatePlanCharge_Tax.setValue('Description', 'For tax calculation\nDo not delete');
                Zuora.zObject zRatePlanChargeData_Tax = new Zuora.zObject('RatePlanChargeData');
                zRatePlanChargeData_Tax.setValue('RatePlanCharge', zRatePlanCharge_Tax);
            
                // set the RatePlanData of the product being added
                Zuora.zObject zRatePlan_Tax = new Zuora.zObject('RatePlan');
                zRatePlan_Tax.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora tax Plan id'));
                Zuora.zObject zRatePlanData_Tax = new Zuora.zObject('RatePlanData');
                zRatePlanData_Tax.setValue('RatePlan', zRatePlan_Tax);
                zRatePlanData_Tax.setValue('RatePlanChargeData', new List<Zuora.zObject> {zRatePlanChargeData_Tax});
                
                // Now add the RatePlanData to the SubscribeRequest record
                oSubsRequest.SubscriptionData.RatePlanData.add(zRatePlanData_Tax);
            }
                
            Decimal dShipping = (dtoOrderItem.shippingAmount == null && dtoOrderItem.handlingCharges == null) ? null
                : ((dtoOrderItem.shippingAmount == null ? 0 : dtoOrderItem.shippingAmount)
                    + (dtoOrderItem.handlingCharges == null ? 0 : dtoOrderItem.handlingCharges));
                
             /////////////////////////////////////////////// 
            // create amendment to add a shipping product
            if (dShipping != null && dShipping > 0)
            {
                // set the RatePlanCharge of the product being added
                Zuora.zObject zRatePlanCharge_Ship = new Zuora.zObject('RatePlanCharge');
                zRatePlanCharge_Ship.setValue('ProductRatePlanChargeId', Utility.getTextSetting('Zuora shipping Charge id'));
                zRatePlanCharge_Ship.setValue('Price', dShipping);
                zRatePlanCharge_Ship.setValue('Description', 'For Shipping calculation\nDo not delete');
                Zuora.zObject zRatePlanChargeData_Ship = new Zuora.zObject('RatePlanChargeData');
                zRatePlanChargeData_Ship.setValue('RatePlanCharge', zRatePlanCharge_Ship);
            
                // set the RatePlanData of the product being added
                Zuora.zObject zRatePlan_Ship = new Zuora.zObject('RatePlan');
                zRatePlan_Ship.setValue('ProductRatePlanId', Utility.getTextSetting('Zuora shipping Plan id'));
                Zuora.zObject zRatePlanData_Ship = new Zuora.zObject('RatePlanData');
                zRatePlanData_Ship.setValue('RatePlan', zRatePlan_Ship);
                zRatePlanData_Ship.setValue('RatePlanChargeData', new List<Zuora.zObject> {zRatePlanChargeData_Ship});
                
                // Now add the RatePlanData to the SubscribeRequest record
                oSubsRequest.SubscriptionData.RatePlanData.add(zRatePlanData_Ship);
            }
            
            /**************************************************
            *   End Of: 2016-04-27: Samy: Add Tax calculation
            **************************************************/

            ////////////
            // Account

            // if account already exists in Zuora, only specify the ID
            if (oCustomer.AccountExistsInZuora) {
                oSubsRequest.ZAccount = new Zuora.zObject('Account');
                oSubsRequest.ZAccount.setValue('Id', (String)oCustomer.RelatedZuoraAccount.getValue('Id'));
                
                if(ePaymentType == IECConstants.PaymentType.BANK_TRANSFER) 
                    oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_BankTransfer_ZuoraID);
                else if(ePaymentType == IECConstants.PaymentType.ICH) 
                    oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_ICH_ZuoraID);
                else if (creditCard != null && creditCard.zId != '') 
                    oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', creditCard.zId);

                // if the default payment method has changed, update the Default Payment Method, AutoPay flag and Invoice Template Id 
                if (((String)oCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId')) != ((String)oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId')) && !Test.isRunningTest()) {
                    Zuora.zApi.SaveResult result = IECZuoraHelper.updateDefaultPaymentMethod((String)oCustomer.RelatedZuoraAccount.getValue('Id'), (String)oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId'));
                    if (!result.Success)
                        throw new IECApplicationException(Label.IEC_Error_Cannot_update_default_payment_method);
                    else
                        oCustomer.RelatedZuoraAccount.setValue('DefaultPaymentMethodId', oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId'));
                }
            }
            // if not, create an object with all fields (for creation)
            else {
                oSubsRequest.ZAccount = IECZuoraHelper.createZuoraAccount(oCustomer.RelatedAccount, oCustomer.RelatedContact, ePaymentType, creditCard.zId);
                // contacts
                oSubsRequest.BillToContact = IECZuoraHelper.createZuoraBillToContact(oCustomer.RelatedContact);
        
                // check if a Shipping Address exists
                List<IECAddress__c> lstShippingAddresses = IECUserManager.getAddressByContact(oCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Shipping);
                if (!lstShippingAddresses.isEmpty())
                    oSubsRequest.SoldToContact = IECZuoraHelper.createZuoraSoldToContact(oCustomer.RelatedContact);
            }
            
            ///////////////////
            // Payment Method
            
            if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD) {
                oSubsRequest.PaymentMethod = new Zuora.zObject('PaymentMethod');
    
                // if a payment method was provided, only set the id of the existing payment method
                if (String.isNotBlank(creditCard.zId))
                    oSubsRequest.PaymentMethod.setValue('Id', creditCard.zId);
                else 
                    throw new IECApplicationException('paymentMethodZId was not provided');
            }
            
            listSubscribeRequests.add(oSubsRequest);
                
            
            ///////////////////////////
            // Subscribe call to Zuora
            
            // not in test method
            if (!Test.isRunningTest()) {
                listSubscribeResults = IECZuoraHelper.zApiInstance.zsubscribe(listSubscribeRequests);
            } 
            // in test method so we fake the call
            else {
                listSubscribeResults = new List<Zuora.zApi.SubscribeResult>{ IECTestUtil.createSampleSubscriptionResult(String.isNotBlank(sUpgradeRatePlanZuoraID)) };
            }
            
            
            ///////////////////////////////////////////////
            // On-demand sync for the user Billing Account

            if (listSubscribeResults[0].Success)
            {
                /* Commented: 2016-05-05: Sales Order will be created from the generated ZInvoice Item trigger
                // Create an order once the subscription is confirmed through Zuora
                String sPaymentMethod = IECConstants.parsePaymentMethodEnumToPicklistValue(ePaymentType);
                Customer_DTO oCurrentCustomer = Customer_DTO.getLoggedCustomer();
                Order oOrder = new Order_Sel().initializeOrder(oCurrentCustomer.sfAccount, oCurrentCustomer.sfContact);

                // Update order fields
                oOrder.Type = 'Order';
                oOrder.Payment_Type__c = sPaymentMethod;
                oOrder.Status = Order_Svc.getOrderStatusByPaymentType(sPaymentMethod);
                oOrder.Is_Paid__c = Order_Svc.isOrderPaidByPaymentType(sPaymentMethod);
                oOrder.IEC_Payment_Date__c = (Order_Svc.isOrderPaidByPaymentType(sPaymentMethod)) ? Date.today() : null;
                update oOrder;
                
                //Set the pricebookEntry
                Pricebook2 stdPriceBook = new Pricebook_Sel().getStandardPriceBook();
                PricebookEntry pbe  = new PricebookEntry_Sel().getPricebookEntryByProductId(stdPriceBook.Id, new set<Id>{oProduct.Id}).get(oProduct.Id);

                //get Item by order
                OrderItem oOrderItem = new OrderItem (
                    OrderId = oOrder.Id
                    , PriceBookEntryId = pbe.Id
                    , Quantity = dtoOrderItem.quantity
                    , UnitPrice = dtoOrderItem.subTotal
                    , Charge_Shipping__c = oProduct.Charge_Shipping__c
                    , Tax__c = dTax
                    , Freight_Charge__c = dShipping
                );
                insert oOrderItem;
                */
                
                if (!Test.isRunningTest())
                    OnDemandSyncAccounts(new Set<String> {listSubscribeResults[0].AccountId});
            }

            ///////////////////////////////////////////////////
            // Keep track of the purchase in our custom object

            for (Zuora.zApi.SubscribeResult subResult : listSubscribeResults) {
                if (subResult.Success) {
                    insertSubscriptionHistory('Subscription', oCustomer, sRatePlanInfoId, 1, ePaymentType, creditCard, (oAcceptedTnCs != null ? oAcceptedTnCs.Id : null), subResult.AccountNumber, subResult.SubscriptionNumber, subResult.InvoiceNumber, subResult.InvoiceId);
                }
            }            

            /////////////////////////////////////////////////////////
            // Post-subscription logic for earch rate plan purchased
            
            /* TODO: part of provisionning
            for (Zuora.zObject ratePlanData : listRatePlanData) {
                Zuora.zObject ratePlan = (Zuora.zObject)ratePlanData.getValue('RatePlan');
                
                // Check-A-Code logic
                if (GDPProductManager.isRatePlanCheckACode((String)ratePlan.getValue('ProductRatePlanId'))) {
                    GDPCACProductManager.postSubscribe(customer.RelatedContact.Id, result);
                }
            }
            */

            return listSubscribeResults.get(0);
        }
        catch (IECApplicationException ex) {
            throw ex;
        }
        catch (Exception ex) {
            if (Zuora.zApi.currentLogger != null) {
                system.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request );
                system.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response );
            }
            throw new IECApplicationException('Could not upgrade trial: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
        }
    }
    
    /**
     * Returns the payment methods of a customer by its zuora Account Id
     * @param zuoraAccountId The Zuora Account Id
     * @return A list of Zuora.zObject (payment methods)
     */
    public static List<Zuora.zObject> getPaymentMethodsFromZuora(String zuoraAccountId) {
        try {
            if (zuoraAccountId != null) {
                List<Zuora.zObject> paymentMethods;
                
                // if not in test method
                if (!Test.isRunningTest()) {
                    paymentMethods = IECZuoraHelper.queryApiCall('select Id,Active,Name,CreditCardAddress1,CreditCardAddress2,CreditCardCity,CreditCardCountry,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardMaskNumber,CreditCardType,LastTransactionStatus,Type from PaymentMethod where AccountId = \'' + zuoraAccountId + '\'');
                }
                // in test method
                else {
                    paymentMethods = new List<Zuora.zObject> {IECTestUtil.createSampleZuoraPaymentMethod()};
                }
                 
                return paymentMethods;
            }
            else {
                return null;
            }
        } 
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Payment Methods for accountId ' + zuoraAccountId + '. Error: ' + e.getMessage());
        }
    }
    
    /* NOT USED FOR NOW. MAYBE GET SUBSCRIPTION FROM SF INSTEAD of ZUORA
    public static List<Zuora.zObject> getSubscriptionsFromZuora(String zuoraAccountId) {
        try {
            if (zuoraAccountId != null) {
                List<Zuora.zObject> subscriptions = IECZuoraHelper.queryApiCall('select Id,AccountId,AutoRenew,CancelledDate,ContractEffectiveDate,ServiceActivationDate,ContractAcceptanceDate,InitialTerm,Name,RenewalTerm,Status,SubscriptionEndDate,SubscriptionStartDate,TermEndDate,TermStartDate,TermType,Version from Subscription where AccountId = \'' + zuoraAccountId + '\'');
                
                // filter to only have latest version of each subscription !!!
                Map<String, Zuora.zObject> allSubscriptions = new Map<String, Zuora.zObject>();
                for (Zuora.zObject subs : subscriptions) {
                    String subName = (String)subs.getValue('Name');
                    // add the subscription to the list if not already in it, or if has a higher version
                    if(!allSubscriptions.containsKey(subName) || (allSubscriptions.containsKey(subName) && (Integer)allSubscriptions.get(subName).getValue('Version') < (Integer)subs.getValue('Version')))
                        allSubscriptions.put(subName, subs);
                }
                
                return allSubscriptions.values();
            }
            else {
                return null;
            }
        } 
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Subscription(s) for accountId ' + zuoraAccountId + '. Error: ' + e.getMessage());
        }
    }
    */
    
    public static List<Zuora.zObject> getCreditCardsByAccountZId(String zuoraAccountZId) {
        try {
            List<Zuora.zObject> creditCards = IECZuoraHelper.queryApiCall('select Id,Name,CreditCardType,CreditCardMaskNumber,CreditCardExpirationMonth,CreditCardExpirationYear,CreditCardHolderName,CreditCardCountry,CreditCardCity,CreditCardAddress1,CreditCardAddress2,CreditCardState,CreditCardPostalCode,LastTransactionStatus, Type from PaymentMethod where AccountId = \'' + zuoraAccountZId + '\' and Type =\'CreditCard\'');
            return creditCards;
        }
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Credit Cards for account ' + zuoraAccountZId + '. Error: ' + e.getMessage());
        }
    }
    
    /**
     * Returns the Invoices related to an account
     * @param accountSFID The SalesForce Account ID
     * @param bIncludeICHInvoices True to include invoices that have been created when paying by ICH
     * @return A list of Zuora__ZInvoice__c
     */
    public static List<Zuora__ZInvoice__c> getInvoicesByBillingAccount(Id idBillingAccount, Boolean bIncludeICHInvoices) {
        try {
            Date dtInvoiceCutoffDate = Date.valueOf(Test.isRunningTest() ? '2999-12-30' : Utility.getTextSetting('Legacy Invoice Cutoff Date'));
             if (bIncludeICHInvoices) {
                return [Select z.Zuora__TotalAmount__c, z.Zuora__Status__c, z.Name, z.Zuora__InvoiceDate__c, z.Zuora__DueDate__c, z.Zuora__Description__c, z.Zuora__Balance__c
                        , Zuora__ZuoraId__c, z.Zuora__Balance2__c 
                            , (SELECT Name, Id, Zuora__Invoice__c, Zuora__PaymentMethod__c, Zuora__Amount__c
                                FROM Zuora__Payments__r) 
                         From Zuora__ZInvoice__c z
                         Where z.Zuora__BillingAccount__c = :idBillingAccount
                            AND CreatedDate < :dtInvoiceCutoffDate
                         Order by z.Zuora__InvoiceDate__c desc];
             }
             else {
                // only return invoices that have a payment
                return [Select z.Zuora__TotalAmount__c, z.Zuora__Status__c, z.Name, z.Zuora__InvoiceDate__c, z.Zuora__DueDate__c, z.Zuora__Description__c, z.Zuora__Balance__c
                        , Zuora__ZuoraId__c, z.Zuora__Balance2__c 
                            , (SELECT Name, Id, Zuora__Invoice__c, Zuora__PaymentMethod__c, Zuora__Amount__c
                                FROM Zuora__Payments__r) 
                         From Zuora__ZInvoice__c z
                         Where z.Zuora__BillingAccount__c = :idBillingAccount
                            and z.Id in (Select Zuora__Invoice__c From Zuora__PaymentInvoice__c)
                            AND CreatedDate < :dtInvoiceCutoffDate
                         Order by z.Zuora__InvoiceDate__c desc];
             }
        }
        catch (Exception ex) {
            throw new IECApplicationException('Could not query invoices. Error: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns the sorted Invoices related to an account
     * @param accountSFID The SalesForce Account ID
     * @param bIncludeICHInvoices True to include invoices that have been created when paying by ICH
     * @param sSortByColumn The column name to sort by
     * @param sSortDirection The direction of the sort (ASC or DESC)
     * @return A list of Zuora__ZInvoice__c
     */
    public static List<Zuora__ZInvoice__c> getSortedInvoicesByBillingAccount(String sBillingAccountID, Boolean bIncludeICHInvoices, String sSortByColumn, String sSortDirection) {
        try {
             //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
             String dtInvoiceCutoffDate = (Test.isRunningTest() ? '2999-12-30' : Utility.getTextSetting('Legacy Invoice Cutoff Date'));
             String sQuery;
             
             if (bIncludeICHInvoices)
                sQuery =
                    'SELECT z.Zuora__TotalAmount__c, z.Zuora__Status__c, z.Name, z.Zuora__InvoiceDate__c' +
                    '   , z.Zuora__DueDate__c, z.Zuora__Description__c, z.Zuora__Balance__c, z.Zuora__Balance2__c' +
                    ' FROM Zuora__ZInvoice__c z' +
                    ' WHERE z.Zuora__BillingAccount__c = \'' + sBillingAccountId + '\'' +
                    '   AND CreatedDate < ' + dtInvoiceCutoffDate + 'T00:00:00.000Z' +   //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
                    ' ORDER BY z.' + sSortByColumn + ' ' + sSortDirection;
             else
                sQuery =
                    'SELECT z.Zuora__TotalAmount__c, z.Zuora__Status__c, z.Name, z.Zuora__InvoiceDate__c' +
                    '   , z.Zuora__DueDate__c, z.Zuora__Description__c, z.Zuora__Balance__c, z.Zuora__Balance2__c' +
                    ' FROM Zuora__ZInvoice__c z' +
                    ' WHERE z.Zuora__BillingAccount__c = \'' + sBillingAccountId + '\'' +
                    '   AND z.Id in (SELECT Zuora__Invoice__c FROM Zuora__PaymentInvoice__c)' +
                    '   AND CreatedDate < ' + dtInvoiceCutoffDate + 'T00:00:00.000Z' +   //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
                    ' ORDER BY z.' + sSortByColumn + ' ' + sSortDirection;
                
             return database.query(sQuery);
        }
        catch (Exception ex) {
            throw new IECApplicationException('Could not query sorted invoices. Error: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns the Payments related to an account
     * @param sAccountSFID The SalesForce Account ID
     * @return A list of Zuora__Payment__c
     */
    public static List<Zuora__Payment__c> getPaymentsByBillingAccount(Id idBillingAccount) {
    
        //set a Limit for the Zuora payment to retrive
        /*Datetime maxDateTime;
        try{
            Date dt = date.valueOf(Utility.getTextSetting('IEC phase 1 & 2 payment limit date'));
            maxDateTime = dateTime.newInstance(dt.year(),dt.month(),dt.day());
        }catch(Exception ex){
            maxDateTime = Datetime.now();
        }*/
        
        try {
             List<Zuora__Payment__c> lstPayments = 
                [SELECT Zuora__Status__c, Zuora__ReferenceId__c, Zuora__PaymentMethod__c, Zuora__GatewayStatus__c, Zuora__GatewayResponse__c
                 , Zuora__GatewayResponseCode__c, Zuora__EffectiveDate__c, Zuora__CreatedDate__c, Zuora__CancelledOn__c, Zuora__AppliedInvoiceAmount__c
                 , Zuora__AppliedCreditBalanceAmount__c, Zuora__Amount__c, Name, Id, SISInvoiceNumber__c
                 , Order__c,
                 (SELECT Zuora__Payment__r.Zuora__PaymentMethod__c, Zuora__Payment__r.Zuora__InvoiceNumber__c
                    , Zuora__Payment__r.Zuora__CreatedDate__c, Zuora__Payment__r.Zuora__Amount__c, Zuora__Payment__c
                    , Zuora__Payment__r.Id, Zuora__Payment__r.Name, Zuora__Invoice__c, Zuora__Invoice__r.Name, Name 
                    FROM Zuora__PaymentInvoices__r
                    ORDER BY Zuora__Payment__r.Zuora__CreatedDate__c) 
                 FROM Zuora__Payment__c 
                 WHERE Zuora__BillingAccount__c = :idBillingAccount 
                 ORDER BY Zuora__CreatedDate__c desc];
             return lstPayments;
        }
        catch (Exception ex) {
            throw new IECApplicationException('Could not query payments. Error: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns the sorted Payments related to an account
     * @param sAccountSFID The SalesForce Account ID
     * @param sSortByColumn The column name to sort by
     * @param sSortDirection The direction of the sort (ASC or DESC)
     * @return A list of Zuora__Payment__c
     */
    public static List<Zuora__Payment__c> getSortedPaymentsByBillingAccount(String sBillingAccountID, String sSortByColumn, String sSortDirection) {
        try {
             String sQuery =
                'SELECT Zuora__Status__c, Zuora__ReferenceId__c, Zuora__PaymentMethod__c' + 
                '   , Zuora__GatewayStatus__c, Zuora__GatewayResponse__c, Zuora__GatewayResponseCode__c' + 
                '   , Zuora__EffectiveDate__c, Zuora__CreatedDate__c, Zuora__CancelledOn__c, Zuora__AppliedInvoiceAmount__c' + 
                '   , Zuora__AppliedCreditBalanceAmount__c, Zuora__Amount__c, Name, Id, SISInvoiceNumber__c' + 
                ' FROM Zuora__Payment__c' + 
                ' WHERE Zuora__BillingAccount__c = \'' + sBillingAccountID + '\'' + 
                ' Order by ' + sSortByColumn + ' ' + sSortDirection;
             return database.query(sQuery);
        }
        catch (Exception ex) {
            throw new IECApplicationException('Could not query sorted payments. Error: ' + ex.getMessage());
        }
    }
    
    /**
     * Checks if a total amount can be purchased for a given payment method
     * @param sPaymentType The payment type
     * @param dTotalAmountWithTaxes The amount to verify (total including taxes)
     * @return True if the amount is allowed based on the given payment type
     */
    public static Boolean canPurchaseAmountWithPaymentMethod(String sPaymentType, Decimal dTotalAmountWithTaxes) {
        try {
             List<IEC_Payment_Threshold__c> listPaymentThreshold = getPaymentMethodThresholdByType(sPaymentType);
             
             if (listPaymentThreshold.isEmpty())
                return false;
             else
                return ((listPaymentThreshold.get(0).Min_amount__c == null || dTotalAmountWithTaxes >= listPaymentThreshold.get(0).Min_amount__c)
                        && (listPaymentThreshold.get(0).Max_amount__c == null || dTotalAmountWithTaxes <= listPaymentThreshold.get(0).Max_amount__c));
        }
        catch (Exception ex) {
            throw new IECApplicationException('Could not check payment threshold for payment type ' + sPaymentType + '. Error: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns a list of payment threshold by payment type
     */
    public static List<IEC_Payment_Threshold__c> getPaymentMethodThresholdByType(String sPaymentType) {
        
        return [SELECT Name, Min_amount__c, Max_amount__c, Payment_Type__c 
                 FROM IEC_Payment_Threshold__c
                 Where Payment_Type__c = :sPaymentType];
    }

    /**
     * Creates a subscription per line item for the specified customer and payment method
     * @param listCartItems The list of cart items to purchase
     * @param oCustomer Object representing the customer
     * @param ePaymentType Enumeration holding the payment method
     * @param creditCard The zuora payment method to use (mandatory if payment method is CREDIT_CARD)
     * @param lstAutoRenew List of the auto-renew flags chosen by the customer (index matches the cart items list)
     * @param lstAcceptedTnCs The list of Terms & Conditions that were accepted
     * @return A list of subscribeResult (Zuora objects)
     */
    public static List<Zuora.zApi.SubscribeResult> subscribe(List<IEC_Cart_Item__c> listCartItems, IECCustomer oCustomer, IECConstants.PaymentType ePaymentType, IECZuoraHelper.PaymentMethod creditCard, List<Boolean> lstAutoRenew, List<Terms_and_Conditions__c> lstAcceptedTnCs, String sPurchaseOrder) {
        try {
            if (oCustomer == null)
                throw new IECApplicationException(Label.IEC_Error_MustLogin);

            if (listCartItems == null || listCartItems.isEmpty())
                return null;
                
            if (ePaymentType == null)
                throw new IECApplicationException(Label.IEC_Error_PleaseSelectPaymentMethod);
            /* TODO: DELETE AFTER CONFIRMING WITH LUC THAT ONLY ONE PRODUCT FOR THE INITIAL PURCHASE
            if (!oCustomer.AccountExistsInZuora) {
                Zuora.zObject zNewAccount = IECZuoraHelper.createZuoraAccount(oCustomer.RelatedAccount, oCustomer.RelatedContact, ePaymentType, (creditCard != null ? creditCard.zId : null));
                zNewAccount.setValue('Status', 'Draft');
                Zuora.zApi.SaveResult result = IECZuoraHelper.createApiCall(zNewAccount);
                 
                if (result.Success) {
                    throw new IECApplicationException('done');
                }
                else {
                    //failure
                    throw new IECApplicationException('failed to add billing account for the following reason(s):' + IECZuoraHelper.getErrorMessagesString(result.Errors, '<BR> - '));
                }
            }
            return null;*/

            List<Zuora.zApi.SubscribeRequest> listSubscribeRequests = new List<Zuora.zApi.SubscribeRequest>();
            List<Zuora.zApi.SubscribeResult> listSubscribeResults = null;

            // for each cart item, create a separated subscription
            Integer i = 0;
            for (IEC_Cart_Item__c cartItem : listCartItems) {

                Zuora.zApi.SubscribeRequest oSubsRequest = new Zuora.zApi.SubscribeRequest();
                
                // Subscription Options
                oSubsRequest.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
                //if (i == listCartItems.size() - 1) {
                oSubsRequest.SubscribeOptions.GenerateInvoice = true;
                oSubsRequest.SubscribeOptions.ProcessPayments = (ePaymentType == IECConstants.PaymentType.CREDIT_CARD); // can only set ProcessPayments=true for electronic payments (credit card)
                
                oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions = new Zuora.zApi.SubscribeInvoiceProcessingOptions();
                //oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceProcessingScope = 'Account';
                oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceTargetDate = IECZuoraHelper.getCurrentDate();
                oSubsRequest.SubscribeOptions.SubscribeInvoiceProcessingOptions.InvoiceDate = IECZuoraHelper.getCurrentDate();
                /*}
                else {
                oSubsRequest.SubscribeOptions.GenerateInvoice = false;
                oSubsRequest.SubscribeOptions.ProcessPayments = false;
                }*/
                
                // No Preview Options (preview is used for previewing the price)
                oSubsRequest.PreviewOptions = null;
                
                // Create Subscription object
                Zuora.zObject subscription = new Zuora.zObject('Subscription');
                subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
                subscription.setValue('TermType', TERM_TYPE);
                subscription.setValue('InitialTerm', SUBSCRIPTION_TERM);
                subscription.setValue('RenewalTerm', SUBSCRIPTION_TERM);
                // only activate subscription if payment is by credit card or ICH
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD || ePaymentType == IECConstants.PaymentType.ICH)
                    subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
                subscription.setValue('AutoRenew', lstAutoRenew.get(i));
                subscription.setValue('IsInvoiceSeparate', false);
                if (String.isNotBlank(sPurchaseOrder))
                    subscription.setValue('PurchaseOrder__c', sPurchaseOrder);
                
                //subscription = 
                ebcSubscriptionInitialization(cartItem, subscription); // special handling, in case it is an ebroadcast pay as you go
                
                // Create the Subscription Data object
                oSubsRequest.SubscriptionData = new Zuora.zApi.SubscriptionData();
                oSubsRequest.SubscriptionData.Subscription = subscription;
                oSubsRequest.SubscriptionData.RatePlanData = IECShoppingCartHelper.createRatePlanDataObjectFromCartItem(cartItem);
    
                ////////////
                // Account
    
                // if account already exists in Zuora, only specify the ID
                if (oCustomer.AccountExistsInZuora) {
                    oSubsRequest.ZAccount = new Zuora.zObject('Account');
                    oSubsRequest.ZAccount.setValue('Id', (String)oCustomer.RelatedZuoraAccount.getValue('Id'));
                    
                    if(ePaymentType == IECConstants.PaymentType.BANK_TRANSFER) 
                        oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_BankTransfer_ZuoraID);
                    else if(ePaymentType == IECConstants.PaymentType.ICH) 
                        oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', IECConstants.PaymentMethod_ICH_ZuoraID);
                    else if (creditCard != null && creditCard.zId != '') 
                        oSubsRequest.ZAccount.setValue('DefaultPaymentMethodId', creditCard.zId);
    
                    // if the default payment method has changed, update the Default Payment Method, AutoPay flag and Invoice Template Id 
                    if (((String)oCustomer.RelatedZuoraAccount.getValue('DefaultPaymentMethodId')) != ((String)oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId')) && !Test.isRunningTest()) {
                        Zuora.zApi.SaveResult result = IECZuoraHelper.updateDefaultPaymentMethod((String)oCustomer.RelatedZuoraAccount.getValue('Id'), (String)oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId'));
                        if (!result.Success)
                            throw new IECApplicationException(Label.IEC_Error_Cannot_update_default_payment_method);
                        else
                            oCustomer.RelatedZuoraAccount.setValue('DefaultPaymentMethodId', oSubsRequest.ZAccount.getValue('DefaultPaymentMethodId'));
                    }
                }
                // if not, create an object with all fields (for creation)
                else {
                    oSubsRequest.ZAccount = IECZuoraHelper.createZuoraAccount(oCustomer.RelatedAccount, oCustomer.RelatedContact, ePaymentType, (creditCard != null ? creditCard.zId : null));
                    // contacts
                    oSubsRequest.BillToContact = IECZuoraHelper.createZuoraBillToContact(oCustomer.RelatedContact);
                    
                    // check if a Shipping Address exists
                    List<IECAddress__c> lstShippingAddresses = IECUserManager.getAddressByContact(oCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Shipping);
                    if (!lstShippingAddresses.isEmpty())
                        oSubsRequest.SoldToContact = IECZuoraHelper.createZuoraSoldToContact(oCustomer.RelatedContact);
                }
                
                ///////////////////
                // Payment Method
                
                if (ePaymentType == IECConstants.PaymentType.CREDIT_CARD) {
                    oSubsRequest.PaymentMethod = new Zuora.zObject('PaymentMethod');
        
                    // if a payment method was provided, only set the id of the existing payment method
                    if (String.isNotBlank(creditCard.zId))
                        oSubsRequest.PaymentMethod.setValue('Id', creditCard.zId);
                    else 
                        throw new IECApplicationException('paymentMethodZId was not provided');
                }
                
                listSubscribeRequests.add(oSubsRequest);
                i++;
            }
            
            ///////////////////////////
            // Subscribe call to Zuora
            
            // not in test method
            if (!Test.isRunningTest()) {
                listSubscribeResults = IECZuoraHelper.zApiInstance.zsubscribe(listSubscribeRequests);
            } 
            // in test method so we fake the call
            else {
                listSubscribeResults = new List<Zuora.zApi.SubscribeResult>{ IECTestUtil.createSampleSubscriptionResult(listCartItems.size() > 0) };
            }
            
            
            ///////////////////////////////////////////////
            // On-demand sync for the user Billing Account

            if (listSubscribeResults[0].Success && !Test.isRunningTest())
                OnDemandSyncAccounts(new Set<String> {listSubscribeResults[0].AccountId});


            /////////////////////////////////////////////////////
            // Keep track of the purchase in our custom objects

            i = 0;
            for (Zuora.zApi.SubscribeResult subResult : listSubscribeResults) {
                if (subResult.Success) {
                
                    // find the appropriate T&C (not by index because multiple rate plans can have the same T&Cs)
                    Terms_and_Conditions__c oAcceptedTnC = null;
                    String sProductInformationId = listCartItems.get(i).Related_Rate_Plan_Information__r.Related_Product_Information__r.Id;
                    for (Terms_and_Conditions__c TnC : lstAcceptedTnCs) {
                        if (TnC.Product_Information__r.Id == sProductInformationId) {
                            oAcceptedTnC = TnC;
                            break;
                        }
                    }

                    // insert IEC_Subscription_History__c
                    insertSubscriptionHistory('Subscription', oCustomer, listCartItems.get(i).Related_Rate_Plan_Information__c, listCartItems.get(i).Quantity__c.intValue(), ePaymentType, creditCard, (oAcceptedTnC != null) ? oAcceptedTnC.Id : null, subResult.AccountNumber, subResult.SubscriptionNumber, subResult.InvoiceNumber, subResult.InvoiceId);
                }
                i++;
            }

            return listSubscribeResults;
        }
        catch (IECApplicationException ex) {
            throw ex;
        }
        catch (Exception ex) {
            if (Zuora.zApi.currentLogger != null) {
                system.debug('SOAP Request = ' + Zuora.zApi.currentLogger.request );
                system.debug('SOAP Response = ' + Zuora.zApi.currentLogger.response );
            }
            throw new IECApplicationException('Could not subscribe: ' + ex.getMessage() + ' ' + ex.getStacktraceString());
        }
    }
    
    /**
     * Creates a trial subscription for the specified customer
     * @param oCustomer Object representing the customer
     * @param zidProductRatePlan the Zuora ID for the product rate plan requested
     * @return A list of subscribeResult (Zuora objects)
     */
    public static List<Zuora.zApi.SubscribeResult> subscribeTrial(IECCustomer oCustomer, String zidProductRatePlan, List<Terms_and_Conditions__c> lstAcceptedTnCs) {
        try {
            if (oCustomer == null)
                throw new IECApplicationException('Could not subscribe. Must be logged in.');

            Zuora.zApi.SubscribeRequest oSubsRequest = new Zuora.zApi.SubscribeRequest();
                
            // Subscription Options
            oSubsRequest.SubscribeOptions = new Zuora.zApi.SubscribeOptions();
            oSubsRequest.SubscribeOptions.GenerateInvoice = true;
            oSubsRequest.SubscribeOptions.ProcessPayments = true;

            // No Preview Options (preview is used for previewing the price)
            oSubsRequest.PreviewOptions = null;
            
            // Create Subscription object
            Zuora.zObject subscription = new Zuora.zObject('Subscription');
            subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
            subscription.setValue('TermType', TERM_TYPE);
            subscription.setValue('InitialTerm', SUBSCRIPTION_TERM);
            subscription.setValue('RenewalTerm', SUBSCRIPTION_TERM);
            subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate());
            subscription.setValue('AutoRenew', false);

            // Create the Subscription Data object
            oSubsRequest.SubscriptionData = new Zuora.zApi.SubscriptionData();
            oSubsRequest.SubscriptionData.Subscription = subscription;
            
            // Create a Zuora Rate Plan for requested Trial Plan
            List<Zuora.zObject> listRatePlanData = new List<Zuora.zObject>();

            Zuora.zObject ratePlan = new Zuora.zObject('RatePlan');
            ratePlan.setValue('ProductRatePlanId', zidProductRatePlan);
            // Related_Rate_Plan_Information__r.Product_Rate_Plan__r.zqu__ZuoraId__c);
                
            Zuora.zObject ratePlanData = new Zuora.zObject('RatePlanData');
            ratePlanData.setValue('RatePlan', ratePlan);
            listRatePlanData.add(ratePlanData);
            
            oSubsRequest.SubscriptionData.RatePlanData = listRatePlanData;

            ////////////
            // Account

            // if account already exists in Zuora, only specify the ID
            if (oCustomer.AccountExistsInZuora) {
                Zuora.zObject existingAccount = new Zuora.zObject('Account');
                existingAccount.setValue('Id', (String)oCustomer.RelatedZuoraAccount.getValue('Id'));

                oSubsRequest.ZAccount = existingAccount;
            }
            // if not, create an object with all fields (for creation)
            else {
                oSubsRequest.ZAccount = IECZuoraHelper.createZuoraAccount(oCustomer.RelatedAccount, oCustomer.RelatedContact);

                // override autopay to false to avoid error of sending subscription without payment method
                oSubsRequest.ZAccount.setValue('AutoPay', false);

                // contacts
                oSubsRequest.BillToContact = IECZuoraHelper.createZuoraBillToContact(oCustomer.RelatedContact);
                
                // check if a Shipping Address exists
                List<IECAddress__c> lstShippingAddresses = IECUserManager.getAddressByContact(oCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Shipping);
                if (!lstShippingAddresses.isEmpty())
                    oSubsRequest.SoldToContact = IECZuoraHelper.createZuoraSoldToContact(oCustomer.RelatedContact);
            }

            List<Zuora.zApi.SubscribeResult> lstSubscribeResults = null;

            // not in test method
            if (!Test.isRunningTest()) {
                // Subscribe call to Zuora
                lstSubscribeResults = IECZuoraHelper.zApiInstance.zsubscribe(new List <Zuora.zApi.SubscribeRequest> {oSubsRequest});
            } 
            // in test method so we fake the call
            else {
                lstSubscribeResults = new List<Zuora.zApi.SubscribeResult>{ IECTestUtil.createSampleSubscriptionResult(true) };
            }
            
            Zuora.zApi.SubscribeResult result = lstSubscribeResults[0]; 
            
            ///////////////////////////////////////////////
            // On-demand sync for the user Billing Account

            if (result.Success && !Test.isRunningTest()) {
                OnDemandSyncAccounts(new Set<String> {result.AccountId});
            }

            // on success
            if (result.Success) {
                Product_Rate_Plan_Information__c oRatePlanInfo = IECProductManager.getProductRatePlansInformationByZuoraId(zidProductRatePlan);
                if (oRatePlanInfo != null) {
                    insertSubscriptionHistory('Trial', oCustomer, oRatePlanInfo.Id, 1, null, null, lstAcceptedTnCs.get(0).Id, result.AccountNumber, result.SubscriptionNumber, result.InvoiceNumber, result.InvoiceId);
                }
            }

            return lstSubscribeResults;
        }
        catch (IECApplicationException ex) {
            throw ex;
        }
        catch (Exception ex) {
            throw new IECApplicationException('Could not subscribe: ' + ex.getMessage());
        }
    }
    
    /**
     * Sync a speicifc customer account from Zuora back to Salesforce
     * @param zuoraAccountIdSet the Zuora AccountId that needs to be sync
     * @return A list of SyncResult (Zuora objects)
     */
    public static List<Zuora.SyncResult> OnDemandSyncAccounts (Set<String> zuoraAccountIdSet) {
        try {
            Zuora.OnDemandSyncManager syncManager = new Zuora.OnDemandSyncManager();
            syncManager.syncObjectType = Zuora.OnDemandSyncManager.ObjectType.BILLING_ACCOUNT;
            syncManager.emailNotificationEnabled = false; 
            syncManager.syncZuoraObjectIdSet = zuoraAccountIdSet;
            return (!Test.isRunningTest())
                ? syncManager.sendRequest()
                : null;
        }
        catch (Zuora.OnDemandSyncManager.OnDemandSyncException ex) {
            throw new IECApplicationException('Could not sync Account: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns a list of PaymentInvoice associated to an Invoice
     * @param sInvoiceID The Invoice ID
     * @return A list of Zuora__PaymentInvoice__c
     */
    public static List<Zuora__PaymentInvoice__c> getPaymentInvoicesByInvoiceID(String sInvoiceID) {
        try {
            return [SELECT Zuora__Payment__r.Zuora__PaymentMethod__c, Zuora__Payment__r.Zuora__InvoiceNumber__c
                    , Zuora__Payment__r.Zuora__CreatedDate__c, Zuora__Payment__r.Zuora__Amount__c, Zuora__Payment__c
                    , Zuora__Payment__r.Id, Zuora__Payment__r.Name, Zuora__Invoice__c, Zuora__Invoice__r.Name, Name 
                    FROM Zuora__PaymentInvoice__c
                    WHERE Zuora__Invoice__c = :sInvoiceID
                    ORDER BY Zuora__Payment__r.Zuora__CreatedDate__c];
        }
        catch (Zuora.OnDemandSyncManager.OnDemandSyncException ex) {
            throw new IECApplicationException('Could not retrieve payment invoices: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns a list of PaymentInvoice associated to a Payment
     * @param sPaymentID The Payment ID
     * @return A list of Zuora__PaymentInvoice__c
     */
    public static List<Zuora__PaymentInvoice__c> getPaymentInvoicesByPaymentID(String sPaymentID) {
        try {
            return [SELECT Zuora__Payment__r.Zuora__PaymentMethod__c, Zuora__Payment__r.Zuora__InvoiceNumber__c
                    , Zuora__Payment__r.Zuora__CreatedDate__c, Zuora__Payment__r.Zuora__Amount__c, Zuora__Payment__c
                    , Zuora__Payment__r.Id, Zuora__Payment__r.Name, Zuora__Invoice__c, Zuora__Invoice__r.Name, Name 
                    FROM Zuora__PaymentInvoice__c
                    WHERE Zuora__Payment__c = :sPaymentID
                    ORDER BY Zuora__Payment__r.Zuora__CreatedDate__c];
        }
        catch (Zuora.OnDemandSyncManager.OnDemandSyncException ex) {
            throw new IECApplicationException('Could not retrieve payment invoices: ' + ex.getMessage());
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query SF for active subscriptions associated to a billing account, ordered by CreatedDate desc
    public static List<Zuora__Subscription__c> getActiveSubscriptionsByBillingAccount(Id idBillingAccount) {
        try {
            List<Zuora__Subscription__c> subscriptions = null;
            //*** (Thai 2016-10-06) added to remove shipping & tax subscription
            //List<String> lstExcludedCharge = new List<String>{ Utility.getTextSetting('Zuora shipping Charge id')
            //                                                 , Utility.getTextSetting('Zuora tax Charge id')};
            //*** (Thai 2016-11-03) added to filter only hierarchy products
            List<Id> lstHierProductId = new List<Id>();
            for (Product_Information__c p : [select Related_Product__c from Product_Information__c where Related_Product__c != null])
                lstHierProductId.add(p.Related_Product__c);
        
            if (idBillingAccount != null) {
                subscriptions = [SELECT Name, Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__c
                                , Zuora__Account__c, Zuora__Status__c, Zuora__AutoRenew__c, Zuora__Zuora_Id__c,Zuora__ContractAcceptanceDate__c 
                                , Zuora__TermSettingType__c,Product_Rate_Plan_Information__c,OrderItemId__c,Zuora__RenewalTerm__c,Zuora__InitialTerm__c
                                , Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__NextRenewalDate__c
                                , (Select Name, Zuora__ProductName__c, Zuora__RatePlanName__c, Zuora__Quantity__c, Zuora__Price__c
                                    , Zuora__Type__c, Zuora__BillingPeriod__c,Zuora__Subscription__c, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c
                                    From Zuora__Subscription_Product_Charges__r
                                    //where Product_Rate_Plan_Charge__r.zqu__ZuoraId__c not in :lstExcludedCharge   //*** (Thai 2016-10-06) added to remove shipping & tax subscription
                                    where Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c in :lstHierProductId)   //*** (Thai 2016-11-03) added to filter only hierarchy products
                                , Product_Rate_Plan_Information__r.Is_Triable__c
                                , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                                , Product_Rate_Plan_Information__r.Related_Product_Information__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c
                                FROM Zuora__Subscription__c
                                WHERE Zuora__CustomerAccount__c = :idBillingAccount
                                    AND Zuora__Status__c = 'Active'
                                    AND Zuora__SubscriptionEndDate__c > TODAY
                                ORDER by CreatedDate desc];
            }

            if (subscriptions != null && subscriptions.size() > 0) {
                //*** (Thai 2016-10-06) added to remove shipping & tax subscription -> subscription without any charge
                if (!Test.isRunningTest())
                    for (Integer i1 = subscriptions.size() - 1; i1 >= 0; i1--)
                        if (subscriptions[i1].Zuora__Subscription_Product_Charges__r.size() == 0)
                            subscriptions.remove(i1);
                return subscriptions;
            }
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve active subscriptions: ' + ex.getMessage());
        }
        
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query SF for active subscriptions associated to a billing account, ordered by CreatedDate desc
    public static List<Zuora__Subscription__c> getActiveSubscriptionsByBillingAccountAndProductCategory(Id idBillingAccount, String sProductCategory) {
        try {
            List<Zuora__Subscription__c> subscriptions = null;
        
            if (idBillingAccount != null) {
                subscriptions = [SELECT Name, Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__c
                                    , Zuora__Account__c, Zuora__Status__c
                                    , Zuora__TermSettingType__c
                                    , (Select Zuora__ProductName__c, Zuora__RatePlanName__c
                                        From Zuora__Subscription_Product_Charges__r
                                        LIMIT 1)
                                FROM Zuora__Subscription__c
                                WHERE Zuora__CustomerAccount__c = :idBillingAccount
                                    AND Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = :sProductCategory
                                    AND Zuora__Status__c = 'Active'
                                    AND Zuora__SubscriptionEndDate__c > TODAY
                                ORDER by CreatedDate desc];
            }

            if (subscriptions != null && subscriptions.size() > 0) 
                return subscriptions;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve active subscriptions: ' + ex.getMessage());
        }
        
        return null;
    }
    
    
    /**
     * Returns the sorted Invoices related to an account
     * @param accountSFID The SalesForce Account ID
     * @param bIncludeICHInvoices True to include invoices that have been created when paying by ICH
     * @param sSortByColumn The column name to sort by
     * @param sSortDirection The direction of the sort (ASC or DESC)
     * @return A list of Zuora__ZInvoice__c
     */
    public static List<Zuora__Subscription__c> getSortedSubscriptionsByBillingAccount(String idBillingAccount, String sSortByColumn, String sSortDirection) {
        
        try {
            List<Zuora__Subscription__c> subscriptions = null;
        
            if (idBillingAccount != null) {
                
                String qString =    'SELECT Name, Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__c, Zuora__Account__c, ' +
                                        'Zuora__Status__c, ' +
                                        'Zuora__TermSettingType__c, ' +
                                        '(Select  Zuora__ProductName__c, Zuora__RatePlanName__c From Zuora__Subscription_Product_Charges__r LIMIT 1) ' +
                                    'FROM Zuora__Subscription__c ' + 
                                    'WHERE Zuora__CustomerAccount__c = \'' + idBillingAccount + '\'' +
                                    'AND Zuora__Status__c = \'Active\' ' +
                                    'AND Zuora__SubscriptionEndDate__c > TODAY '+
                                    'ORDER by ' + sSortByColumn + ' ' + sSortDirection;
                                
                subscriptions = database.query(qString);
            }

            if (subscriptions != null && subscriptions.size() > 0) 
                return subscriptions;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve active subscriptions: ' + ex.getMessage());
        }
        
        return null;        

    }
    
    
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query SF for active subscriptions associated to a billing account, ordered by CreatedDate desc
    public static List<Zuora__Subscription__c> getInactiveSubscriptionsByBillingAccount(Id idBillingAccount) {
        try {
            List<Zuora__Subscription__c> subscriptions = null;
            //*** (Thai 2016-11-07) added to filter only hierarchy products
            List<Id> lstHierProductId = new List<Id>();
            for (Product_Information__c p : [select Related_Product__c from Product_Information__c where Related_Product__c != null])
                lstHierProductId.add(p.Related_Product__c);
        
            if (idBillingAccount != null) {
                subscriptions = [SELECT Name, Id, Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c, Zuora__CustomerAccount__c, Zuora__Account__c, Zuora__Status__c, 
                                Zuora__TermSettingType__c,
                                Zuora__ContractAcceptanceDate__c,Product_Rate_Plan_Information__r.Related_Product_Information__c,Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c,
                                Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c, Product_Rate_Plan_Information__c,OrderItemId__c,  
                                //*** (Thai 2016-11-07) modify to filter only hierarchy products
                                //(Select  Zuora__ProductName__c, Zuora__RatePlanName__c From Zuora__Subscription_Product_Charges__r LIMIT 1)
                                (Select  Zuora__ProductName__c, Zuora__RatePlanName__c
                                 From Zuora__Subscription_Product_Charges__r
                                 where Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c in :lstHierProductId
                                 LIMIT 1)
                                , Product_Rate_Plan_Information__r.Is_Triable__c
                                , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c
                                , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c
                                FROM Zuora__Subscription__c
                                WHERE (Zuora__CustomerAccount__c = :idBillingAccount)
                                    AND ((Zuora__Status__c != 'Active' AND Zuora__Status__c != 'Pending Activation')
                                        OR (Zuora__SubscriptionEndDate__c < TODAY))
                                ORDER by CreatedDate desc]; 
            }

            if (subscriptions != null && subscriptions.size() > 0) {
                //*** (Thai 2016-11-07) added to remove subscriptions not belong to hierarchy products -> subscription without any charge
                if (!Test.isRunningTest())
                    for (Integer i1 = subscriptions.size() - 1; i1 >= 0; i1--)
                        if (subscriptions[i1].Zuora__Subscription_Product_Charges__r.size() == 0)
                            subscriptions.remove(i1);
                return subscriptions;
            }
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve inactive subscriptions: ' + ex.getMessage());
        }
        
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query to get the link between Subscription and Invoice 
    public static Invoice_Item__c getInvoiceItemBySFSubscriptionName(String subscriptionNumber) {
        try {
            //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
            Date dtInvoiceCutoffDate = Date.valueOf(Test.isRunningTest() ? '2999-12-30' : Utility.getTextSetting('Legacy Invoice Cutoff Date'));
            
            List<Invoice_Item__c> lstInvoiceItem = 
                [SELECT Invoice__c
                FROM Invoice_Item__c
                WHERE Subscription_Number__c = :subscriptionNumber
                  AND Invoice__r.CreatedDate < :dtInvoiceCutoffDate   //*** (Thai 2016-11-07) added criteria on creation date to filter applicable Zuora invoices
                ORDER BY CreatedDate DESC LIMIT 1];

            if (!lstInvoiceItem.isEmpty()) 
                return lstInvoiceItem.get(0);
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve invoice items. Error: ' + ex.getMessage());
        }

        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query to get the link between Subscription and Invoice 
    public static Map<String,Invoice_Item__c> getInvoiceItemBySFSubscriptionName(set<String> subscriptionNumbers) {
        try {
            //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
            Date dtInvoiceCutoffDate = Date.valueOf(Test.isRunningTest() ? '2999-12-30' : Utility.getTextSetting('Legacy Invoice Cutoff Date'));
            
            Map<String,Invoice_Item__c> invoiceItemBySFSubscriptionName = new Map<String,Invoice_Item__c>();
            List<Invoice_Item__c> lstInvoiceItem = 
                [SELECT Invoice__c, Subscription_Number__c 
                FROM Invoice_Item__c
                WHERE Subscription_Number__c in :subscriptionNumbers
                  AND Invoice__r.CreatedDate < :dtInvoiceCutoffDate   //*** (Thai 2016-11-07) added criteria on creation date to filter applicable Zuora invoices
                ORDER BY CreatedDate DESC];

            if (!lstInvoiceItem.isEmpty()){
                for(Invoice_Item__c ii : lstInvoiceItem){
                    invoiceItemBySFSubscriptionName.put(ii.Subscription_Number__c,ii);
                }
            } 
            return invoiceItemBySFSubscriptionName;
                
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve invoice items. Error: ' + ex.getMessage());
        }

        return null;
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query SF for an Invoice based on its Id
    public static Zuora__ZInvoice__c getInvoiceById (Id idInvoice) {
        try {
            //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
            Date dtInvoiceCutoffDate = Date.valueOf(Test.isRunningTest() ? '2999-12-30' : Utility.getTextSetting('Legacy Invoice Cutoff Date'));
            
            List<Zuora__ZInvoice__c> invoices =
                [SELECT Name, Id, Zuora__Zuora_Id__c
                    , (SELECT Name, Id, Zuora__Invoice__c, Zuora__PaymentMethod__c, Zuora__Amount__c
                        FROM Zuora__Payments__r) 
                FROM Zuora__ZInvoice__c
                WHERE Id = :idInvoice AND CreatedDate < :dtInvoiceCutoffDate];   //*** (Thai 2016-11-07) added criteria on creation date to filter applicable Zuora invoices

            if (invoices != null && invoices.size() > 0) 
                return invoices.get(0);
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve invoices: ' + ex.getMessage());
        }
        
        return null;
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //Query SF for an Invoice based on its Ids
    public static Map<Id,Zuora__ZInvoice__c> getInvoiceById (set<Id> idInvoices) {
        try {
            //*** (Thai 2016-11-07) added to filter applicable Zuora invoices
            Date dtInvoiceCutoffDate = Date.valueOf(Test.isRunningTest() ? '2999-12-30' : Utility.getTextSetting('Legacy Invoice Cutoff Date'));
            
            Map<Id,Zuora__ZInvoice__c> invoiceById = new Map<Id,Zuora__ZInvoice__c>();
            List<Zuora__ZInvoice__c> invoices =
                [SELECT Name, Id, Zuora__Zuora_Id__c
                    , (SELECT Name, Id, Zuora__Invoice__c, Zuora__PaymentMethod__c, Zuora__Amount__c
                        FROM Zuora__Payments__r) 
                FROM Zuora__ZInvoice__c
                WHERE Id in :idInvoices AND CreatedDate < :dtInvoiceCutoffDate];   //*** (Thai 2016-11-07) added criteria on creation date to filter applicable Zuora invoices

            if (invoices != null && invoices.size() > 0){
                for(Zuora__ZInvoice__c invoice : invoices){
                    invoiceById.put(invoice.Id,invoice);
                }
            }
            return invoiceById;    
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not retrieve invoices: ' + ex.getMessage());
        }
        
        return null;
        
    }

    
    /**
     * Creates a IEC_Subscription_History__c object to keep track of the purchase subscription and all interlinked objects (subscription, invoice, payment method, T&Cs, etc)
     * @param oCustomer The IEC customer that purchased the cart item
     * @param oCartItem The cart item being purchased
     * @param ePaymentType The payment type selected (CREDIT_CARD, BANK_TRANSFER or ICH)
     * @param oAcceptedTnC The Terms & Conditions accepted at the time of purchase
     * @param oSubsResult The SubscribeResult returned by Zuora after the subscribe() call
     */
    private static void insertSubscriptionHistory(String sAction, IECCustomer oCustomer, Id idRatePlanInfo, Integer iQuantity, IECConstants.PaymentType ePaymentType, IECZuoraHelper.PaymentMethod creditCard
        , Id idAcceptedTnC, String sBillingAccountNumber, String sSubscriptionNumber, String sInvoiceNumber, String sZIDInvoice) {
        try {
            IEC_Subscription_History__c oSubHist = new IEC_Subscription_History__c();
            List<Product_Rate_Plan_Information__c> lstRatePlanInfo = IECProductManager.getProductRatePlansInformationById(idRatePlanInfo);
            
            if (lstRatePlanInfo.size() == 0)
                throw new IECApplicationException('Could not find Product_Rate_Plan_Information__c with id ' + idRatePlanInfo);
            
            // fill user-related info
            oSubHist.Billing_Account_Number__c = sBillingAccountNumber;
            oSubHist.Related_Account__c = oCustomer.RelatedAccount.Id;
            oSubHist.Related_Contact__c = oCustomer.RelatedContact.Id;
            
            // Fill Billing fields
            List<IECAddress__c> lstAddresses = IECUserManager.getAddressByContact(oCustomer.RelatedContact.Id, IECConstants.IECAddress_AddressType_Billing);

            if (!lstAddresses.isEmpty()) {
                IECAddress__c oBillingAddress = lstAddresses.get(0);
                oSubHist.Billing_City__c = oBillingAddress.City__c;
                oSubHist.Billing_Country__c = oBillingAddress.ISO_Country_Name__c;  //*** changed by Thai (2016-02-26) from "Country__c"
                oSubHist.Billing_State__c = oBillingAddress.ISO_State_Name__c;      //*** changed by Thai (2016-02-26) from "State__c"
                oSubHist.Billing_Street__c = oBillingAddress.Street__c;
                oSubHist.Billing_Zip__c = oBillingAddress.ZipCode__c;

                IECVATUtil.VATConfiguration vatConfig = IECVATUtil.GetVATConfiguration(oBillingAddress.ISO_Country_Name__c);  //*** changed by Thai (2016-02-26) from "Country__c"

                // Only provide VAT Number for VAT Countries that require validation for their VAT Number
                if (vatConfig != null && vatConfig.VATValidationRequired)
                    oSubHist.VAT_Number__c = (String.isBlank(oCustomer.RelatedContact.VAT_Country_Code__c) ? '' : oCustomer.RelatedContact.VAT_Country_Code__c) + oCustomer.RelatedContact.Tax_1_ID__c;
            }
            
            // fill product/rate plan related info
            oSubHist.Purchased_Product_Category__c = lstRatePlanInfo.get(0).Related_Product_Information__r.Related_Product_Category__c;
            oSubHist.Purchased_Product_Information__c = lstRatePlanInfo.get(0).Related_Product_Information__c;
            oSubHist.Purchased_Product_Rate_Plan_Information__c = lstRatePlanInfo.get(0).Id;
            oSubHist.Purchased_Product_SKU__c = lstRatePlanInfo.get(0).Related_Product_Information__r.Related_Product__r.zqu__SKU__c;
            oSubHist.Rate_Plan_Quantity__c = iQuantity;
            
            // fill subscription related info
            oSubHist.Subscription_Number__c = sSubscriptionNumber;
            oSubHist.Invoice_Number__c = (String.isNotBlank(sInvoiceNumber) ? sInvoiceNumber : null);
            oSubHist.Invoice_Zuora_ID__c = (String.isNotBlank(sZIDInvoice) ? sZIDInvoice : null);
            oSubHist.Action__c = sAction;
            
            // Termsn & Conditions
            oSubHist.Accepted_Terms_and_Conditions__c = (idAcceptedTnC == null ? null : idAcceptedTnC);
            
            // Payment method
            oSubHist.Selected_Payment_Method__c = (ePaymentType == null) ? null : IECConstants.parsePaymentMethodEnumToPicklistValue(ePaymentType);
            oSubHist.Credit_Card__c = (creditCard == null) ? null : (creditCard.creditCardType + ' - ' + creditCard.creditCardMaskNumber);
            
            insert oSubHist;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not insert Subscription History: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns a datailed subscription based on its SF id
     */
    public static Zuora__Subscription__c getSubscriptionById(String subsId) {
        try {
            return [SELECT Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c,Zuora__AutoRenew__c
                        , Name, Id, Zuora__Zuora_Id__c,  Zuora__RenewalTerm__c, Zuora__InitialTerm__c
                        , Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__NextRenewalDate__c
                        , Zuora__TermSettingType__c
                        , Zuora__ContractAcceptanceDate__c
                        ,  (Select  Name, Zuora__ProductName__c, Zuora__RatePlanName__c, Zuora__Quantity__c, Zuora__Price__c
                                , Zuora__Type__c, Zuora__BillingPeriod__c, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c
                            From Zuora__Subscription_Product_Charges__r)
                        , Product_Rate_Plan_Information__c
                        , Product_Rate_Plan_Information__r.Is_Triable__c
                        , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                        , Product_Rate_Plan_Information__r.Related_Product_Information__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c
                    FROM Zuora__Subscription__c 
                    WHERE Id = :subsId];
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription with Id: '+ subsId + ' with the error: ' + ex.getMessage());
        }

        return null;
    }

    /**
     * Returns a datailed subscription based on its Name (subscription number in Zuora)
     */
    public static Zuora__Subscription__c getSubscriptionByName(String subsName) {
        try {
            return [SELECT Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c,Zuora__AutoRenew__c
                        , Name, Id, Zuora__Zuora_Id__c,  Zuora__RenewalTerm__c, Zuora__InitialTerm__c
                        , Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__NextRenewalDate__c
                        , Zuora__ContractAcceptanceDate__c
                        , Zuora__TermSettingType__c
                        ,  (Select  Name, Zuora__ProductName__c, Zuora__RatePlanName__c, Zuora__Quantity__c, Zuora__Price__c
                                , Zuora__Type__c, Zuora__BillingPeriod__c, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c
                            From Zuora__Subscription_Product_Charges__r)
                        , Product_Rate_Plan_Information__c
                        , Product_Rate_Plan_Information__r.Is_Triable__c
                        , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                        , Product_Rate_Plan_Information__r.Related_Product_Information__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c
                    FROM Zuora__Subscription__c 
                    WHERE Name = :subsName
                    order by Zuora__Version__c desc limit 1];
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription with Name: '+ subsName + ' with the error: ' + ex.getMessage());
        }

        return null;
    }

    /**
     * Returns a datailed subscription based on Product Category Name
     */
    public static Zuora__Subscription__c getSubscriptionByProductCategory(Id idBillingAccount, String sProductCategory) {
        try {
            List<Zuora__Subscription__c> lstSub =
                    [SELECT Zuora__SubscriptionStartDate__c, Zuora__SubscriptionEndDate__c,Zuora__AutoRenew__c
                        , Name, Id, Zuora__Zuora_Id__c,  Zuora__RenewalTerm__c, Zuora__InitialTerm__c
                        , Zuora__TermStartDate__c, Zuora__TermEndDate__c, Zuora__NextRenewalDate__c
                        , Zuora__ContractAcceptanceDate__c
                        , Zuora__TermSettingType__c
                        ,  (Select  Name, Zuora__ProductName__c, Zuora__RatePlanName__c, Zuora__Quantity__c, Zuora__Price__c
                                , Zuora__Type__c, Zuora__BillingPeriod__c, Zuora__EffectiveStartDate__c, Zuora__EffectiveEndDate__c
                            From Zuora__Subscription_Product_Charges__r)
                        , Product_Rate_Plan_Information__c
                        , Product_Rate_Plan_Information__r.Is_Triable__c
                        , Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                        , Product_Rate_Plan_Information__r.Related_Product_Information__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Product_Audience__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Renewal_Window__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Application_URL__c
                        , Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Auto_Renewal_Window__c
                    FROM Zuora__Subscription__c 
                    WHERE Zuora__CustomerAccount__c = :idBillingAccount
                        AND Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name = :sProductCategory
                    order by Zuora__SubscriptionEndDate__c desc limit 1];
                    
            return (lstSub.isEmpty() ? null : lstSub.get(0));
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription with Product Category  '+ sProductCategory + ' for BillingAccountId ' + idBillingAccount + ' with the error: ' + ex.getMessage());
        }

        return null;
    }
    
    /**
     * Retrieve the latest IEC_Subscription_History_c using subscription name
     * @param sName The subscription name
     * @return oSubsResult The SubscribeResult returned by Zuora after the subscribe() call
     */
    public static IEC_Subscription_History__c getSubscriptionHistoryByName(String sName) {
        try {
            // Validate name is not empty
            if (String.isBlank(sName)) return null;
            
            List<IEC_Subscription_History__c> lstSubHist =
                [SELECT Subscription_Number__c, Accepted_Terms_and_Conditions__c, Billing_Account_Number__c, Invoice_Number__c, CreatedDate
                    , Action__c, Purchased_Product_Category__c, Purchased_Product_Information__c, Purchased_Product_Rate_Plan_Information__c
                    , Purchased_Product_SKU__c, Rate_Plan_Quantity__c, Related_Contact__c, Related_Account__c, Selected_Payment_Method__c
                    , Credit_Card__c
                    , Purchased_Product_Category__r.Name
                    , Purchased_Product_Category__r.Display_Name__c
                    , Purchased_Product_Category__r.Renewal_Window__c
                    , Purchased_Product_Category__r.Auto_Renewal_Window__c
                    , Purchased_Product_Category__r.Application_URL__c
                    , Purchased_Product_Information__r.Product_Audience__c
                    , Purchased_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                FROM IEC_Subscription_History__c
                WHERE Subscription_Number__c = :sName
                order by CreatedDate desc limit 1];
            
            return (lstSubHist.isEmpty() ? null : lstSubHist.get(0));
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription History for subscription: '+ sName + ' for the error: ' + ex.getMessage());
        }
    }
    
    /**
     * Retrieve the latest IEC_Subscription_History_c using subscription name
     * @param sName The subscription name
     * @return oSubsResult The SubscribeResult returned by Zuora after the subscribe() call
     */
    public static Map<String,IEC_Subscription_History__c> getSubscriptionHistoryByName(set<String> sNames) {
        try {
            // Validate name is not empty
            if (sNames == null) return null;
            
            Map<String,IEC_Subscription_History__c> subscriptionHistoryByName = new Map<String,IEC_Subscription_History__c>();
            List<IEC_Subscription_History__c> lstSubHist =
                [SELECT Subscription_Number__c, Accepted_Terms_and_Conditions__c, Billing_Account_Number__c, Invoice_Number__c, CreatedDate
                    , Action__c, Purchased_Product_Category__c, Purchased_Product_Information__c, Purchased_Product_Rate_Plan_Information__c
                    , Purchased_Product_SKU__c, Rate_Plan_Quantity__c, Related_Contact__c, Related_Account__c, Selected_Payment_Method__c
                    , Credit_Card__c
                    , Purchased_Product_Category__r.Name
                    , Purchased_Product_Category__r.Display_Name__c
                    , Purchased_Product_Category__r.Renewal_Window__c
                    , Purchased_Product_Category__r.Auto_Renewal_Window__c
                    , Purchased_Product_Category__r.Application_URL__c
                    , Purchased_Product_Information__r.Product_Audience__c
                    , Purchased_Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name
                FROM IEC_Subscription_History__c
                WHERE Subscription_Number__c in :sNames
                order by CreatedDate desc limit 1];

            if(lstSubHist != null && !lstSubHist.isEmpty()){
                for(IEC_Subscription_History__c sh : lstSubHist){
                    subscriptionHistoryByName.put(sh.Subscription_Number__c,sh);
                }
            }
            
            //return (lstSubHist.isEmpty() ? null : lstSubHist.get(0));
            return subscriptionHistoryByName;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription History for subscription: '+ JSON.serialize(sNames) + ' for the error: ' + ex.getMessage());
        }
    }
    
    /**
     * Retrieve IEC_Subscription_History_c using the accepted T&C
     * @param sTnCId The Id of the Terms & Conditions object
     * @return A list of IEC_Subscription_History__c 
     */
    public static List<IEC_Subscription_History__c> getSubscriptionHistoryByTnC(String sTnCId) {
        try {
            // Validate name is not empty
            if (String.isBlank(sTnCId)) return null;
            
            List<IEC_Subscription_History__c> lstSubHist =
                [SELECT Subscription_Number__c, Accepted_Terms_and_Conditions__c, Billing_Account_Number__c, Invoice_Number__c, CreatedDate
                    , Action__c, Purchased_Product_Category__c, Purchased_Product_Information__c, Purchased_Product_Rate_Plan_Information__c
                    , Purchased_Product_SKU__c, Rate_Plan_Quantity__c, Related_Contact__c, Related_Account__c, Selected_Payment_Method__c
                    , Purchased_Product_Category__r.Name
                    , Purchased_Product_Category__r.Renewal_Window__c
                    , Purchased_Product_Category__r.Auto_Renewal_Window__c
                    , Purchased_Product_Category__r.Application_URL__c
                    , Purchased_Product_Information__r.Product_Audience__c
                FROM IEC_Subscription_History__c
                WHERE Accepted_Terms_and_Conditions__c = :sTnCId];
            
            return lstSubHist;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription History by T&C: '+ sTnCId + ' for the error: ' + ex.getMessage());
        }
    }
    
    /**
     * Retrieve IEC_Subscription_History_c using the specified T&C and Contact 
     * @param idTnC The Id of the Terms & Conditions object
     * @param idContact The Id of the logged Contact
     * @return A list of IEC_Subscription_History__c 
     */
    public static List<IEC_Subscription_History__c> getSubscriptionHistoryByTnCAndContact(Id idTnC, Id idContact) {
        try {
            // Validate input
            if (idTnC == null || idContact == null) return null;
            
            List<IEC_Subscription_History__c> lstSubHist =
                [SELECT Id
                FROM IEC_Subscription_History__c
                WHERE Accepted_Terms_and_Conditions__c = :idTnC
                    AND Related_Contact__c = :idContact];
            
            return lstSubHist;
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get Subscription History by T&C: '+ idTnC + ' and Contact: '+ idContact + ' for the error: ' + ex.getMessage());
        }
    }
    
    /**
     * Returns the Rate Plan Zuora Id (from Zuora) derived from the Subscription and Product Rate Plan
     * @param productRatePlanZId Zuora Id of the Product Rate Plan that was subscribed to
     * @param subscriptionZId Zuora Id of the Subscription
     * @return The Zuora Id of the Rate Plan
     */
    public static String getRatePlanZIdFromProductRatePlanAndSubscription(String productRatePlanZId, String subscriptionZId) {
        try {
            if (Test.isRunningTest())
                return '2sdf98sa7ergsdf98g731l12lkj3';
            
            List<Zuora.zObject> ratePlans = IECZuoraHelper.queryApiCall('select Id from RatePlan where SubscriptionId = \'' + subscriptionZId + '\' and ProductRatePlanId = \'' + productRatePlanZId + '\'');

            if (ratePlans == null || ratePlans.size() == 0)
                throw new IECApplicationException('No Rate Plan found for ProductRatePlan ' + productRatePlanZId + ' and subscription ' + subscriptionZId);
                
            return (String)ratePlans.get(0).getValue('Id');
        }
        catch (IECApplicationException ex) {
            throw ex;
        }
        catch (Exception e) {
            throw new IECApplicationException('Could not retreive Rate Plan Zuora ID for subscription ' + subscriptionZId + '. Error: ' + e.getMessage());
        }
    }
    
    /**
     * Determines the next bill cycle date for a subscription charge
     * @param dtEffectiveStart Charge effective start date
     * @param dtEffectiveEnd Charge effective end date
     * @param bAutoRenew Whether subscription is on auto-renewal or not
     * @param sType Charge type
     * @param sPeriod Charge billing period
     * @return Next bill date for charge 
     */
    public static Date getNextBillDate(Date dtEffectiveStart, Date dtEffectiveEnd, boolean bAutoRenew, String sType, String sPeriod) {
        if (sType == 'Recurring') {
            IEC_Zuora_Billing_Period__c period = IEC_Zuora_Billing_Period__c.getInstance(sPeriod);
            if (period == null)
                throw new IECApplicationException('Could not find a setting for the specified billing period: ' + sPeriod);

            // Determine how many months in the billing period
            integer iMonths = integer.valueOf(period.Months_in_Period__c);
            
            Date dtNextBill = dtEffectiveStart.addMonths(iMonths);
            
            while (dtNextBill < Date.today()) {
                // No bill run since it has reached the end of the subscription with no auto-renewal
                if (!bAutoRenew && dtNextBill >= dtEffectiveEnd)
                    return null;
                dtNextBill = dtNextBill.addMonths(iMonths);
            }
            
            return dtNextBill;
        }
        else
            return null;        
    }
    
    /**
     * Retrieve the latest GSS_Subscription_Detail__c using subscription name
     * @param sName The subscription name
     */
    public static List<GSS_Subscription_Detail__c> getFileSubscriptionDetailByName(String sName, String sProductCode) {
        try {
            // Validate name is not empty
            if (String.isBlank(sName)) return null;
            
            return [SELECT Calendar_Weekly_Option__c
                    , Calendar_Semi_Monthly_First_Option__c
                    , Calendar_Semi_Monthly_Second_Option__c
                    , Calendar_Monthly_Option__c
                    , Calendar_Next_Submission_Date__c
                    , Calendar_New_Submission_Effective_Date__c
                    , File_Name_Applies_on__c
                    , File_Name_Custom_Prefix__c
                    , File_Name_Custom_Suffix__c 
                    , File_Name_Prefix_Option__c
                    , File_Name_Suffix_Option__c
                    , Trigger_File_Name__c
                    , FileRecipientFirstName__c
                    , FileRecipientLastName__c
                    , FileRecipientEmail__c 
                    , FileRecipientPhone__c 
                    , FileRecipientSalutation__c 
                    , FileRecipientJobTitle__c 
                    , Zuora_Subscription__c
                    , Zuora_Subscription__r.Zuora__SubscriptionStartDate__c
                    , Zuora_Subscription__r.Zuora__CustomerAccount__r.IINETUserID__c                   
                    , GDP_File_Description__r.Frequency__c
                    , GDP_File_Description__r.Geo_Coverage_Definition__r.Name
                    , GDP_File_Description__r.Class__c
                    , GDP_File_Description__r.File_Format__c
                    , GDP_File_Description__r.Magnitude__c
                FROM GSS_Subscription_Detail__c
                WHERE Name = :sName
                    AND GDP_File_Description__r.Product_Type__c = :sProductCode
                order by CreatedDate desc];
        }
        catch(Exception ex) {
            throw new IECApplicationException('Could not get GSS Subscription Detail for subscription: '+ sName + ' for the error: ' + ex.getMessage());
        }
    }
    
    
    
    /**
     * Special handling for eBroadcast subscription
     *   called by subscribe()
     * Add additional customization for EBC Pay-As-You-Go
     * @param oCartItem specific IEC_Cart_Item to check 
     * @param oSubscription: current subscription (Zuora.zObject) being prepared
     * @return oSubscription
     *
     * assumption oCartItem already contains the followin fields
     * - Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name // EBC or not 
     * - Related_Rate_Plan_Information__r.Product_Rate_Plan__r.Name // (values: null,'Pay-As-You-Go', 'Professional-Edition')
     * - Related_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c // (values: null,'Pay-As-You-Go', 'Pre-Paid')
     *  
     */
    private static Zuora.zObject ebcSubscriptionInitialization(IEC_Cart_Item__c oCartItem, Zuora.zObject subscription)
    {
        if ((oCartItem != null)
            && (oCartItem.Related_Rate_Plan_Information__c != null)
            && (oCartItem.Related_Rate_Plan_Information__r.Related_Product_Information__c != null)
            && (oCartItem.Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__c != null)
            && (oCartItem.Related_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Name == IECConstants.ProductCategory_SF_EBROADCAST)
            //&& (oCartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__r.EBC_SubscriptionType__c == EBC_PRODUCT_RATE_PLAN_SUBSCRIPTION_TYPE_PAY_AS_YOU_GO ) // 'Pay-As-You-Go', not 'Pre-Paid'
            && ( IECEBC_Utility.ebcPayAsYouGoProductRatePlanIdSet.contains(oCartItem.Related_Rate_Plan_Information__r.Product_Rate_Plan__c) ) // 'Pay-As-You-Go' as defined in the EBC_Setup
            )
        {
                subscription.setValue('ContractEffectiveDate', IECZuoraHelper.getCurrentDate());
                subscription.setValue('TermType', TERM_TYPE);
                subscription.setValue('InitialTerm', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM);
                subscription.setValue('RenewalTerm', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM);
                //subscription.setValue('InitialTermPeriodType', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM_PERIOD);
                //subscription.setValue('RenewalTermPeriodType', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_TERM_PERIOD);
                subscription.setValue('Notes', EBC_PAY_AS_YOU_GO_SUBSCRIPTION_NOTES);
                subscription.setValue('AutoRenew', false);
                subscription.setValue('ServiceActivationDate', IECZuoraHelper.getCurrentDate()); 
                // subscription.setValue('SubscriptionStartDate', IECZuoraHelper.getCurrentDate()); // this is not insertable
                //subscription.setValue('Status', EBC_PAY_AS_YOU_GO_DEFAULT_STATUS); // set to Active
        }
        return subscription;
    } // end of ebcSubscriptionInitialization
}
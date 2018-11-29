/****************************************************************************************************
    Created by Samy 2016/03
        REST web service to be called by Zuora to request update for tax and shipping charges
****************************************************************************************************/
@RestResource(urlMapping='/Zuora/TaxShipping/v1.0/*')
global class IEC_REST_Zuora_TaxShipping {

    //*** class used to read parameters from REST call
    class SubscriptionInfo {
        String zAccountId;              // Zuora Account Id
        String zSubscriptionId;         // Zuora Subscription Id
        String zSubscriptionName;       // Zuora Subscription Name
        String zAmendmentDate;          // Effective date for the amendment to take place
        String zEventCategory;          // Type of event triggering the webservice in Zuora
    }
    
    private static SubscriptionInfo ParseXmlRequest(String sXML)
    {
        if (String.isBlank(sXML)) return null;
        
        SubscriptionInfo oSubInfo = new SubscriptionInfo();
        
        Dom.Document doc = new Dom.Document();
        doc.load(sXML);

        for(Dom.XmlNode node : doc.getRootElement().getChildElements())
        {
            if (node.getAttribute('name', '') == 'zAccountId')
            {
                oSubInfo.zAccountId = node.getText();
            }
            else if (node.getAttribute('name', '') == 'zSubscriptionId')
            {
                oSubInfo.zSubscriptionId = node.getText();
            }
            else if (node.getAttribute('name', '') == 'zSubscriptionName')
            {
                oSubInfo.zSubscriptionName = node.getText();
            }
            else if (node.getAttribute('name', '') == 'zAmendmentDate')
            {
                oSubInfo.zAmendmentDate = String.format('{2}-{0}-{1}', node.getText().split('/'));
            }
            
            else if (node.getAttribute('name', '') == 'zEventCategory')
            {
                oSubInfo.zEventCategory = node.getText();
            }
        }
        
        return oSubInfo;
    }
    
    @HttpPut
    global static void updateTaxAndShipping() {
        
        system.debug('in rest call');
        
        RestRequest apiRequest = RestContext.request;
        RestResponse apiResponse = RestContext.response;

        SubscriptionInfo oSubInfo = ParseXmlRequest(apiRequest.requestBody.toString());
        
        system.debug('oSubInfo ' + oSubInfo);
        
        try
        {
            // Ensure that caller is from Zuora
            /*if (ZuoraUtil.isRESTCalledFromZuora(apiRequest.remoteAddress, apiRequest.headers) != true)
                throw new IECApplicationException('Webservice cannot be initiated unless connections issued from Zuora servers.');
            */
            
            // Retrieve the Source custom field to determine whether Tax & Shipping needs to be calculated
            String sSource = (Test.isRunningTest()) ? IEC_REST_Zuora_TaxShipping_Test.sSource : (String) IEC_Zuora_Sel.getSubscriptionsByZId(new Set<String> {oSubInfo.zSubscriptionId}).get(oSubInfo.zSubscriptionId).getValue('Source__c');
            
            system.debug('sSource ' + sSource);
            // If this is the Event of 'SubscriptionCreated' then check if Source is Salesforce/Zuora, 
            // then return and do nothing since the subscription is created from the Portal with Tax & Shipping calculated already
            // If it is an event of 'UpcomingRenewal' then skip and calculate tax normally
            if (oSubInfo.zEventCategory == 'SubscriptionCreated'
                && (String.isBlank(sSource) || sSource == 'Salesforce'))
            {
                apiResponse.statusCode = 200;
                //apiResponse.responseBody = Blob.valueOf('Subscription is created from Salesforce. Tax and Shipping calculation is not required.');
                apiResponse.responseBody = Blob.valueOf('Tax and Shipping have been updated successfully.');
                return;
            }

            // Retrieve the Salesforce Contact for the specified Billing Account
            String sContactId = (Test.isRunningTest()) ? IEC_REST_Zuora_TaxShipping_Test.oContact.Id : (String) IEC_Zuora_Sel.getAccountsByZId(new Set<String> {oSubInfo.zAccountId}).get(oSubInfo.zAccountId).getValue('CRMContactID__c');
            Contact oContact;
            Location__c oLocSoldTo;
            
            if (String.isBlank(sContactId))
                throw new IECApplicationException('CRM Contact Id cannot be null.');
            else
            {
                oContact = Contact_Sel.getContactById(new Set<Id> {sContactId}).get(sContactId);
                oLocSoldTo = new Location_Sel().getSoldToLocationByContactId(new Set<Id> {sContactId}).get(sContactId);
            }
            
            // Retrieve all RatePlans under the specified subscription
            List<Zuora.zObject> lstRatePlan = (Test.isRunningTest()) ? IEC_REST_Zuora_TaxShipping_Test.lstRatePlan : IEC_Zuora_Sel.getRatePlanFromSubscription(oSubInfo.zSubscriptionId);
            
            // Proceed only if able to get RatePlans
            if (lstRatePlan == null || lstRatePlan.isEmpty())
                throw new IECApplicationException('Could not query Zuora RatePlans from Subscription.');
            else
            {
                Set<String> setRatePlanZId = new Set<String>();
                // Get list of RatePlan ZId to get related charges
                for (Zuora.zObject oRatePlan : lstRatePlan)
                {
                    setRatePlanZId.add((String)oRatePlan.getValue('Id'));
                }
                
                // Retrieve all RatePlanChargess under the specified rateplans
                Map<String, List<Zuora.zObject>> mapRatePlanZId_ZCharge = (Test.isRunningTest()) ? IEC_REST_Zuora_TaxShipping_Test.mapRatePlanCharge : IEC_Zuora_Sel.getRatePlanChargeFromRatePlan(setRatePlanZId);
                
                String sSubRatePlanId_RemoveProd_Tax, sSubRatePlanId_RemoveProd_Ship, sProductRatePlanId;
                Decimal dProductPrice = 0, dQuantity = 0, dSubTotal = 0;
                
                // Determine which rate plans exist on the subscription (i.e: Product, Tax, Shipping, Discount)
                for (Zuora.zObject oRatePlan : lstRatePlan)
                {
                    // If the Product is a Tax Product
                    if ((String)oRatePlan.getValue('ProductRatePlanId') == Utility.getTextSetting('Zuora tax Plan id'))
                    {
                        sSubRatePlanId_RemoveProd_Tax = (String)oRatePlan.getValue('Id');
                    }
                    // If the Product is a Shipping Product
                    else if ((String)oRatePlan.getValue('ProductRatePlanId') == Utility.getTextSetting('Zuora shipping Plan id'))
                    {
                        sSubRatePlanId_RemoveProd_Ship = (String)oRatePlan.getValue('Id');
                    }
                    // Otherwise it is the actual product that we are renewing
                    else
                    {
                        sProductRatePlanId = (String)oRatePlan.getValue('ProductRatePlanId');
                        // Assuming there is only one charge per product
                        String sRatePlanZId = (String)oRatePlan.getValue('Id');
                        Zuora.zObject rpc = mapRatePlanZId_ZCharge.get(sRatePlanZId)[0];
                        dProductPrice += (Decimal) rpc.getValue('Price');
                        dQuantity += (Decimal) rpc.getValue('Quantity');
                        dSubTotal += dProductPrice * dQuantity;
                    }
                }

                if (String.isBlank(sProductRatePlanId))
                    throw new IECApplicationException('Unable to locate the main product in the specified subscription.');
                else
                {
                    List<zqu__ProductRatePlan__c> lstProdRatePlan = new IEC_ZProductRatePlan_Sel().getZProductRatePlanByZId(new Set<String> {sProductRatePlanId});
                    
                    if (lstProdRatePlan == null || lstProdRatePlan.isEmpty() || String.isBlank(lstProdRatePlan[0].Product_Number__c))
                        throw new IECApplicationException('Unable to locate a SAP Product Code for the product on the subscription. ProductRatePlanId: ' + sProductRatePlanId);
                    else
                    {
                        String sProductNumber = lstProdRatePlan[0].Product_Number__c;

                        //Get Product Info
                        Map<String,Product2> mapProductCode_Prod = Product_Sel.getProductsByCode(new Set<String> {sProductNumber});
                        
                        if (mapProductCode_Prod == null || mapProductCode_Prod.isEmpty())
                            throw new IECApplicationException('Unable to locate a Salesforce Product for the product code on the ZProduct. Product Code: ' + sProductNumber);
                        else
                        {
                            // Initialize a fake OrderItem DTO
                            OrderItem_DTO dtoOrderItem = new OrderItem_DTO();

                            dtoOrderItem.sapProductCode = sProductNumber;
                            dtoOrderItem.quantity = dQuantity;
                            dtoOrderItem.subTotal = dSubTotal;
                            dtoOrderItem.chargeShipping = mapProductCode_Prod.get(sProductNumber).Charge_Shipping__c;
                            dtoOrderItem.isContractProduct = mapProductCode_Prod.get(sProductNumber).Use_Contract_when_ordered__c;
                            // Set any random ID since it is a fake item
                            dtoOrderItem.orderItemId = 'RANDOM';
                            
                            system.debug('oLocSoldTo.SAP_Id__c ' + oLocSoldTo.SAP_Id__c);
                            system.debug('oContact.BillTo_Location__r.SAP_Id__c ' + oContact.BillTo_Location__r.SAP_Id__c);
                            system.debug('oContact.ShipTo_Location__r.SAP_Id__c ' + oContact.ShipTo_Location__r.SAP_Id__c);
                            system.debug('dtoOrderItem ' + dtoOrderItem);
                            
                            // Retrieve Tax & Shipping information for current Order Item/Subscription
                            String result = Order_Svc.getSAP_Freight_Tax_for_DTO(Utility.getTextSetting('vfOrder-DefaultType')
                                , Utility.getTextSetting('vfOrder-DefaultSource')
                                , Utility.getTextSetting('vfOrder-DefaultChannel')
                                , oLocSoldTo.SAP_Id__c
                                , oContact.BillTo_Location__r.SAP_Id__c
                                , oContact.ShipTo_Location__r.SAP_Id__c
                                , new List<OrderItem_DTO> {dtoOrderItem});
                            
                            system.debug('result ' + result);
                            if (result != null)
                            {
                                apiResponse.statusCode = 200; //424
                                apiResponse.responseBody = Blob.valueOf('Error returned from Tax & Shipping webservice. ' + Result);

                                IECErrorLogger.logError(null
                                    , 'Error returned from Tax & Shipping webservice.'
                                    , result
                                    , 'zAccountId: ' + oSubInfo.zAccountId
                                        + '\nzSubscriptionId: ' + oSubInfo.zSubscriptionId
                                        + '\nzSubscriptionName: ' + oSubInfo.zSubscriptionName
                                        + '\nzAmendmentDate: ' + oSubInfo.zAmendmentDate
                                    , 'IEC_REST_Zuora_TaxShipping.updateTaxAndShipping'
                                    , null
                                );
                                
                                return;
                            }
                            else
                            {
                                // Prepare an Amendment Request to add amendments to if tax/shipping rates have changed
                                Zuora.zApi.AmendRequest zAmendRequest = new Zuora.zApi.AmendRequest();
                                zAmendRequest.Amendments = new List<Zuora.zObject>();
                                
                                // Specify amendment options for generating invoice to determine total amount and taxes
                                Zuora.zApi.AmendOptions zAmendOpt = new Zuora.zApi.AmendOptions();
                                zAmendOpt.GenerateInvoice = false;//true;
                                zAmendOpt.ProcessPayments = false;
                                zAmendRequest.AmendOptions = zAmendOpt;
                    
                                // Now we have the new tax & shipping information
                                
                                Decimal dTax = dtoOrderItem.taxAmount;
                                
                                /* Commented till further notice to see whether do we need to remove the Tax & Shipping products first
                                /////////////////////////////////////////////// 
                                // create first amendment to remove a product
        
                                // First try to determine whether there was a previous Tax product or not
                                if (!String.isBlank(sSubRatePlanId_RemoveProd_Tax))
                                {
                                    Zuora.zObject zAmend_RemoveProd_Tax = new Zuora.zObject('Amendment');
                                    zAmend_RemoveProd_Tax.setValue('Name', 'Remove Tax Product');
                                    zAmend_RemoveProd_Tax.setValue('Description', 'Remove Tax Product');
                                    zAmend_RemoveProd_Tax.setValue('Type', 'RemoveProduct');
                                    zAmend_RemoveProd_Tax.setValue('SubscriptionId', oSubInfo.zSubscriptionId);
                                    zAmend_RemoveProd_Tax.setValue('Status', 'Completed');
                                    zAmend_RemoveProd_Tax.setValue('AutoRenew', false);
                                    zAmend_RemoveProd_Tax.setValue('CustomerAcceptanceDate', oSubInfo.zAmendmentDate);
                                    zAmend_RemoveProd_Tax.setValue('ContractEffectiveDate', oSubInfo.zAmendmentDate);
                                    zAmend_RemoveProd_Tax.setValue('ServiceActivationDate', oSubInfo.zAmendmentDate);
                                    
                                    // set the RatePlanData of the product being removed
                                    Zuora.zObject zRatePlan_RemoveProd_Tax = new Zuora.zObject('RatePlan');
                                    // Must query zuora to determine the original SubscriptionRatePlanId
                                    zRatePlan_RemoveProd_Tax.setValue('AmendmentSubscriptionRatePlanId', sSubRatePlanId_RemoveProd_Tax);
                                    Zuora.zObject zRatePlanData_RemoveProd_Tax = new Zuora.zObject('RatePlanData');
                                    zRatePlanData_RemoveProd_Tax.setValue('RatePlan', zRatePlan_RemoveProd_Tax);
                                    zAmend_RemoveProd_Tax.setValue('RatePlanData', zRatePlanData_RemoveProd_Tax);
                                    
                                    // Add the amendment to the amendment request
                                    zAmendRequest.Amendments.add(zAmend_RemoveProd_Tax);
                                }
                                */
                                    
                                /////////////////////////////////////////////// 
                                // create second amendment to add a new product
                                if (dTax != null)
                                {
                                    Zuora.zObject zAmend_AddProd_Tax = new Zuora.zObject('Amendment');
                                    zAmend_AddProd_Tax.setValue('Name', 'Add Tax Product');
                                    zAmend_AddProd_Tax.setValue('Description', 'Add Tax Product');
                                    zAmend_AddProd_Tax.setValue('Type', 'NewProduct');
                                    zAmend_AddProd_Tax.setValue('SubscriptionId', oSubInfo.zSubscriptionId);
                                    zAmend_AddProd_Tax.setValue('Status', 'Completed');
                                    zAmend_AddProd_Tax.setValue('AutoRenew', false);
                                    zAmend_AddProd_Tax.setValue('CustomerAcceptanceDate', oSubInfo.zAmendmentDate);
                                    zAmend_AddProd_Tax.setValue('ContractEffectiveDate', oSubInfo.zAmendmentDate);
                                    zAmend_AddProd_Tax.setValue('ServiceActivationDate', oSubInfo.zAmendmentDate);
                        
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
                                    zAmendRequest.Amendments.add(zAmend_AddProd_Tax);
                                }
                                
                                Decimal dShipping = (dtoOrderItem.shippingAmount == null && dtoOrderItem.handlingCharges == null) ? null
                                    : ((dtoOrderItem.shippingAmount == null ? 0 : dtoOrderItem.shippingAmount)
                                        + (dtoOrderItem.handlingCharges == null ? 0 : dtoOrderItem.handlingCharges));
                                
                                /* Commented till further notice to see whether do we need to remove the Tax & Shipping products first
                                /////////////////////////////////////////////// 
                                // create first amendment to remove a product
                                
                                // First try to determine whether there was a previous Shipping product or not
                                if (!String.isBlank(sSubRatePlanId_RemoveProd_Ship))
                                {
                                    Zuora.zObject zAmend_RemoveProd_Ship = new Zuora.zObject('Amendment');
                                    zAmend_RemoveProd_Ship.setValue('Name', 'Remove Shipping Product');
                                    zAmend_RemoveProd_Ship.setValue('Description', 'Remove Shipping Product');
                                    zAmend_RemoveProd_Ship.setValue('Type', 'RemoveProduct');
                                    zAmend_RemoveProd_Ship.setValue('SubscriptionId', oSubInfo.zSubscriptionId);
                                    zAmend_RemoveProd_Ship.setValue('Status', 'Completed');
                                    zAmend_RemoveProd_Ship.setValue('AutoRenew', false);
                                    zAmend_RemoveProd_Ship.setValue('CustomerAcceptanceDate', oSubInfo.zAmendmentDate);
                                    zAmend_RemoveProd_Ship.setValue('ContractEffectiveDate', oSubInfo.zAmendmentDate);
                                    zAmend_RemoveProd_Ship.setValue('ServiceActivationDate', oSubInfo.zAmendmentDate);
                                    
                                    // set the RatePlanData of the product being removed
                                    Zuora.zObject zRatePlan_RemoveProd_Ship = new Zuora.zObject('RatePlan');
                                    // Must query zuora to determine the original SubscriptionRatePlanId
                                    zRatePlan_RemoveProd_Ship.setValue('AmendmentSubscriptionRatePlanId', sSubRatePlanId_RemoveProd_Ship);
                                    Zuora.zObject zRatePlanData_RemoveProd_Ship = new Zuora.zObject('RatePlanData');
                                    zRatePlanData_RemoveProd_Ship.setValue('RatePlan', zRatePlan_RemoveProd_Ship);
                                    zAmend_RemoveProd_Ship.setValue('RatePlanData', zRatePlanData_RemoveProd_Ship);
                                    
                                    // Add the amendment to the amendment request
                                    zAmendRequest.Amendments.add(zAmend_RemoveProd_Ship);
                                }
                                */
                                    
                                 /////////////////////////////////////////////// 
                                // create second amendment to add a new product
                                if (dShipping != null && dShipping > 0)
                                {
                                    Zuora.zObject zAmend_AddProd_Ship = new Zuora.zObject('Amendment');
                                    zAmend_AddProd_Ship.setValue('Name', 'Add Shipping Product');
                                    zAmend_AddProd_Ship.setValue('Description', 'Add Shipping Product');
                                    zAmend_AddProd_Ship.setValue('Type', 'NewProduct');
                                    zAmend_AddProd_Ship.setValue('SubscriptionId', oSubInfo.zSubscriptionId);
                                    zAmend_AddProd_Ship.setValue('Status', 'Completed');
                                    zAmend_AddProd_Ship.setValue('AutoRenew', false);
                                    zAmend_AddProd_Ship.setValue('CustomerAcceptanceDate', oSubInfo.zAmendmentDate);
                                    zAmend_AddProd_Ship.setValue('ContractEffectiveDate', oSubInfo.zAmendmentDate);
                                    zAmend_AddProd_Ship.setValue('ServiceActivationDate', oSubInfo.zAmendmentDate);
                        
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
                                    zAmendRequest.Amendments.add(zAmend_AddProd_Ship);
                                }
            
                                if (!zAmendRequest.Amendments.isEmpty())
                                {
                                    Zuora.zApi.AmendResult zAmendResult = (Test.isRunningTest()) ? IECTestUtil.CreateSampleAmendResult() : IECZuoraHelper.amendApiCall(zAmendRequest);
                                    
                                    if (!zAmendResult.Success) {
                                        apiResponse.statusCode = 424;
                                        apiResponse.responseBody = Blob.valueOf('Error returned from Zuora Amend API webservice. Error: ' + IECZuoraHelper.getErrorMessagesString(zAmendResult.Errors, '\n - '));
                                        
                                        IECErrorLogger.logError(null
                                            , 'Error returned from Zuora Amend API webservice.'
                                            , IECZuoraHelper.getErrorMessagesString(zAmendResult.Errors, '\n - ')
                                            , 'zAccountId: ' + oSubInfo.zAccountId
                                                + '\nzSubscriptionId: ' + oSubInfo.zSubscriptionId
                                                + '\nzSubscriptionName: ' + oSubInfo.zSubscriptionName
                                                + '\nzAmendmentDate: ' + oSubInfo.zAmendmentDate
                                            , 'IEC_REST_Zuora_TaxShipping.updateTaxAndShipping'
                                            , null
                                        );
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }
            }

            apiResponse.statusCode = 200;
            apiResponse.responseBody = Blob.valueOf('Tax and Shipping have been updated successfully.');
        }
        catch (Exception e)
        {
            apiResponse.statusCode = (e.getTypeName() == 'IECApplicationException') ? 424 : 422;
            apiResponse.responseBody = Blob.valueOf(e.getMessage());
            IECErrorLogger.logApexException('IEC_REST_Zuora_TaxShipping.updateTaxAndShipping'
                , 'Exception thrown while updating tax & shipping the Zuora API call:\nzAccountId: ' + oSubInfo.zAccountId
                    + '\nzSubscriptionId: ' + oSubInfo.zSubscriptionId
                    + '\nzSubscriptionName: ' + oSubInfo.zSubscriptionName
                    + '\nzAmendmentDate: ' + oSubInfo.zAmendmentDate
                , e.getMessage()
                , e.getStackTraceString()
            );
        }
    }
}
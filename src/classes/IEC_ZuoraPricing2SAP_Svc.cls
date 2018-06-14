public class IEC_ZuoraPricing2SAP_Svc
{
    //****************************************************************************************************
    //  Functionalities for interface Zuora Pricing to SAP
    //****************************************************************************************************


    // centralize static values for SAP pricing types
    @TestVisible Enum sapPT {DISCOUNT_AMT, DISCOUNT_PCT, COUPON_AMT, COUPON_PCT, VOLUME, UNIT}
    @TestVisible final Map<sapPT, String> sapPrice = new Map<sapPT, String>
    {
        sapPT.DISCOUNT_AMT => 'CUSTOMERTYPEDISCOUNT_DOLLARS'
      , sapPT.DISCOUNT_PCT => 'CUSTOMERTYPEDISCOUNT_PERCENTAGE'
      , sapPT.COUPON_AMT => 'COUPONDISCOUNT_DOLLARS'
      , sapPT.COUPON_PCT => 'COUPONDISCOUNT_PERCENTAGE'
      , sapPT.VOLUME => 'VOLUME_PRICE'
      , sapPT.UNIT => 'STANDARD_PRICE'
    };
    // some utility for SAP value
    Boolean isSAPDiscountAmt(String strPriceType) { return strPriceType == sapPrice.get(sapPT.DISCOUNT_AMT); }
    Boolean isSAPDiscountPct(String strPriceType) { return strPriceType == sapPrice.get(sapPT.DISCOUNT_PCT); }
    Boolean isSAPCouponAmt(String strPriceType) { return strPriceType == sapPrice.get(sapPT.COUPON_AMT); }
    Boolean isSAPCouponPct(String strPriceType) { return strPriceType == sapPrice.get(sapPT.COUPON_PCT); }
    Boolean isSAPVolume(String strPriceType) { return strPriceType == sapPrice.get(sapPT.VOLUME); }
    Boolean isSAPUnit(String strPriceType) { return strPriceType == sapPrice.get(sapPT.UNIT); }


    // centralize static values for SAP pricing operations
    @TestVisible Enum sapOT {DEL, INS, UPD}
    @TestVisible final Map<sapOT, String> sapOperation = new Map<sapOT, String>
    {
        sapOT.DEL => 'D'
      , sapOT.INS => 'I'
      , sapOT.UPD => 'U'
    };


    // centralize static values for Zuora pricing types
    Enum zuoraPT {DISCOUNT_AMT, DISCOUNT_PCT, VOLUME, UNIT}
    final Map<zuoraPT, String> zuoraPrice = new Map<zuoraPT, String>
    {
        zuoraPT.DISCOUNT_AMT => 'Discount-Fixed Amount'
      , zuoraPT.DISCOUNT_PCT => 'Discount-Percentage'
      , zuoraPT.VOLUME => 'Volume'   // startsWith
      , zuoraPT.UNIT => 'Per Unit'   // startsWith
    };
    // some utility for Zuora value
    Boolean isZuoraTrue(String strPicklistValue) { return 'Yes'.equalsIgnoreCase(strPicklistValue); }
    Boolean isZuoraDiscountAmt(String strModel) { return zuoraPrice.get(zuoraPT.DISCOUNT_AMT).equalsIgnoreCase(strModel); }
    Boolean isZuoraDiscountPct(String strModel) { return zuoraPrice.get(zuoraPT.DISCOUNT_PCT).equalsIgnoreCase(strModel); }
    Boolean isZuoraRecurring(String strModel, String strType) { return !strModel.startsWithIgnoreCase('Discount') &&
                                                                       'Recurring'.equalsIgnoreCase(strType); }
    Boolean isZuoraVolume(String strModel) { return strModel.startsWithIgnoreCase(zuoraPrice.get(zuoraPT.VOLUME)); }
    Boolean isZuoraUnit(String strModel) { return strModel.startsWithIgnoreCase(zuoraPrice.get(zuoraPT.UNIT)); }
    String zuoraCurrency(zqu__ProductRatePlanChargeTier__c pricing)
    {
        return (isZuoraDiscountPct(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c) ? '%' :
                (!String.isBlank(pricing.zqu__Currency__c) ? pricing.zqu__Currency__c : pricing.CurrencyIsoCode));
    }
    String zuoraCustomerType(zqu__ProductRatePlanChargeTier__c pricing)
    {
        return pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.CustomerType__c;
        //return (String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.CustomerType__c) ? IECConstants.PARAM_CUSTOMERTYPE_DEFAULT :
        //        pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.CustomerType__c);
    }


    // get products to track pricing
    public Map<Id, Product2> getTrackingProduct()
    {
        // build criteria specified by business
        String strSOQL = '';
        for (IEC_ZuoraPricing2SAP_Filter__c filter : [select SAP_Sales_Channel_Code__c, SAP_Division_Code__c, Exclude_SAP_Material_Number__c
                                                      from IEC_ZuoraPricing2SAP_Filter__c])
            strSOQL += ' or (SAP_Sales_Channel_Code__c = \'' + filter.SAP_Sales_Channel_Code__c + '\''
                           + ' and SAP_Division_Code__c = \'' + filter.SAP_Division_Code__c + '\''
                           + (String.isBlank(filter.Exclude_SAP_Material_Number__c) ? ''
                              : ' and SAP_Material_Number__c not in (' + filter.Exclude_SAP_Material_Number__c + ')')
                           + ')';
        
        // search products
        Map<Id, Product2> mapZProductId_Product = new Map<Id, Product2>();
        if (!String.isBlank(strSOQL))
        {
            strSOQL = 'select SAP_Material_Number__c, ZProduct__c from Product2'
                    + ' where SAP_Material_Number__c != null and ZProduct__c != null and SAP_Status_Code__c in (\'A\', \'Z4\')'
                    + ' and (' + strSOQL.substring(4) + ')';
            for (Product2 p : Database.query(strSOQL))
                mapZProductId_Product.put(p.ZProduct__c, p);
        }
        return mapZProductId_Product;
    }


    // determine if to delete a pricing
    Boolean isPricingDeleted(zqu__ProductRatePlanChargeTier__c pricing)
    {
        return pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__Deleted__c ||
               pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Deleted__c ||
               pricing.zqu__ProductRatePlanCharge__r.zqu__Deleted__c ||
               pricing.zqu__Deleted__c || pricing.IsDeleted;
    }


    // determine the latest Zuora timestamp to compare with tracking
    Datetime getLatestTimestamp(zqu__ProductRatePlanChargeTier__c pricing)
    {
        Datetime dtLatest = pricing.LastModifiedDate;
        if (dtLatest < pricing.zqu__ProductRatePlanCharge__r.LastModifiedDate)
            dtLatest = pricing.zqu__ProductRatePlanCharge__r.LastModifiedDate;
        if (dtLatest < pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.LastModifiedDate)
            dtLatest = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.LastModifiedDate;
        if (dtLatest < pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.LastModifiedDate)
            dtLatest = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.LastModifiedDate;
        return dtLatest;
    }


    // build key served to track pricing
    @TestVisible String buildTrackingKey(zqu__ProductRatePlanChargeTier__c pricing) { return String.valueOf(pricing.Id).left(15); }


    // build key that stop tracking of price
    @TestVisible String buildDiscardKey(IEC_ZuoraPricing2SAP_Tracking__c tracking) { return String.valueOf(tracking.Id).left(15) + '+' + tracking.Key__c; }


    // determine if tracking is new and not sent yet to SAP
    Boolean isNewTracking(IEC_ZuoraPricing2SAP_Tracking__c tracking) { return tracking.Operation__c == sapOperation.get(sapOT.INS) &&
                                                                              tracking.SendingTimestamp__c == null; }


    // determine if updated price changes SAP pricing condition already sent
    @TestVisible Boolean isPricingConditionChanged(String strMaterial, zqu__ProductRatePlanChargeTier__c pricing, IEC_ZuoraPricing2SAP_Tracking__c tracking)
    {
        return tracking.Material_Number__c != strMaterial
            || tracking.CustomerType__c != zuoraCustomerType(pricing)
            || tracking.Currency__c != zuoraCurrency(pricing)
            || tracking.EffectiveFrom__c != pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c
            || tracking.EffectiveTo__c != pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c
            || isSAPUnit(tracking.Pricing_Type__c) && !isZuoraUnit(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c)
            || (isSAPVolume(tracking.Pricing_Type__c) &&
                    (!isZuoraVolume(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c) ||
                     tracking.StartingUnit__c != pricing.zqu__StartingUnit__c || tracking.EndingUnit__c != pricing.zqu__EndingUnit__c))
            || (isSAPDiscountAmt(tracking.Pricing_Type__c) &&
                    (!isZuoraDiscountAmt(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c) ||
                     !String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c)))
            || (isSAPDiscountPct(tracking.Pricing_Type__c) &&
                    (!isZuoraDiscountPct(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c) ||
                     !String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c)))
            || (isSAPCouponAmt(tracking.Pricing_Type__c) &&
                    (!isZuoraDiscountAmt(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c) ||
                     String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c)))
            || (isSAPCouponPct(tracking.Pricing_Type__c) &&
                    (!isZuoraDiscountPct(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c) ||
                     String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c)))
            ;
    }


    // indicate tracking is to send to SAP
    void prepareSendingTracking(IEC_ZuoraPricing2SAP_Tracking__c tracking, String strOperation)
    {
        tracking.Operation__c = strOperation;
        tracking.SendingTimestamp__c = null;
    }


    // track prices deleted/inserted/updated
    public void trackPricing(List<zqu__ProductRatePlanChargeTier__c> lstPricing, Map<Id, Product2> mapZProductId_Product)
    {
        // build map of pricing
        Map<String, zqu__ProductRatePlanChargeTier__c> mapKey_Pricing = new Map<String, zqu__ProductRatePlanChargeTier__c>();
        for (Integer ix1 = 0; ix1 < lstPricing.size(); ix1++)
            mapKey_Pricing.put(buildTrackingKey(lstPricing[ix1]), lstPricing[ix1]);
        
        List<IEC_ZuoraPricing2SAP_Tracking__c> lstInsertTracking = new List<IEC_ZuoraPricing2SAP_Tracking__c>();
        List<IEC_ZuoraPricing2SAP_Tracking__c> lstUpdateTracking = new List<IEC_ZuoraPricing2SAP_Tracking__c>();
        zqu__ProductRatePlanChargeTier__c pricing;
        Datetime dtLatestSourceTimestamp;
        
        // check modification on existing pricings
        for (IEC_ZuoraPricing2SAP_Tracking__c tracking : [select Operation__c, Key__c, LatestSourceTimestamp__c, Material_Number__c
                                                               , Pricing_Type__c, EffectiveFrom__c, EffectiveTo__c, Currency__c
                                                               , StartingUnit__c, EndingUnit__c, AmountOrPercentage__c
                                                               , CustomerType__c, Region__c, Country__c, Coupon__c
                                                               , IsFreeShipping__c, IsPreSale__c, SendingTimestamp__c
                                                          from IEC_ZuoraPricing2SAP_Tracking__c
                                                          where Key__c in :mapKey_Pricing.keySet()])
        {
            pricing = mapKey_Pricing.get(tracking.Key__c);
            
            dtLatestSourceTimestamp = getLatestTimestamp(pricing);
            if (tracking.LatestSourceTimestamp__c >= dtLatestSourceTimestamp)
            {
                // no change - do nothing with input and tracking prices
                mapKey_Pricing.remove(tracking.Key__c);
            }
            else
            {
                // save latest timestamp
                tracking.LatestSourceTimestamp__c = dtLatestSourceTimestamp;
                
                // updated price is deleted
                if (isPricingDeleted(pricing))
                {
                    // ignore updated price
                    mapKey_Pricing.remove(tracking.Key__c);
                    // new pricing not send yet to SAP - mark to not send anymore
                    if (isNewTracking(tracking))
                        tracking.SendingTimestamp__c = system.Now();
                    // send to SAP previous price as deletion
                    else if (tracking.Operation__c != sapOperation.get(sapOT.DEL))
                        prepareSendingTracking(tracking, sapOperation.get(sapOT.DEL));
                    // change key to skip tracking in future
                    tracking.Key__c = buildDiscardKey(tracking);
                    lstUpdateTracking.add(tracking);
                }
                // updated price changes SAP condition pricing
                else if (isPricingConditionChanged(mapZProductId_Product.get(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c).SAP_Material_Number__c
                                                 , pricing, tracking))
                {
                    // insert updated price later
                    
                    // new pricing not send yet to SAP - discard tracking
                    if (isNewTracking(tracking))
                        tracking.SendingTimestamp__c = system.Now();
                    // send to SAP previous price as deletion
                    else
                        prepareSendingTracking(tracking, sapOperation.get(sapOT.DEL));
                    // change key to skip tracking in future
                    tracking.Key__c = buildDiscardKey(tracking);
                    lstUpdateTracking.add(tracking);
                }
                // save changes of updated price
                else
                {
                    // skip insert later
                    mapKey_Pricing.remove(tracking.Key__c);
                    
                    // determine if to send changes to SAP
                    if (!isNewTracking(tracking) && tracking.AmountOrPercentage__c != pricing.zqu__Price__c)
                        prepareSendingTracking(tracking, sapOperation.get(sapOT.UPD));
                    
                    // save information
                    tracking.Region__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Region__c;
                    tracking.Country__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Country__c;
                    tracking.IsFreeShipping__c = isZuoraTrue(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.IsFreeShipping__c);
                    tracking.IsPreSale__c = isZuoraTrue(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.IsPreSale__c);
                    tracking.AmountOrPercentage__c = pricing.zqu__Price__c;
                    lstUpdateTracking.add(tracking);
                }
            }
        }
        
        // add new pricing if not deleted and still effective
        IEC_ZuoraPricing2SAP_Tracking__c newTracking;
        for (String key : mapKey_Pricing.keySet())
        {
            pricing = mapKey_Pricing.get(key);
            if (!isPricingDeleted(pricing) && pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c > system.today())
            {
                newTracking = new IEC_ZuoraPricing2SAP_Tracking__c(Operation__c=sapOperation.get(sapOT.INS), Key__c=key);
                newTracking.LatestSourceTimestamp__c = getLatestTimestamp(pricing);
                newTracking.EffectiveFrom__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c;
                newTracking.EffectiveTo__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c;
                newTracking.Region__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Region__c;
                newTracking.Country__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Country__c;
                newTracking.Coupon__c = pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c;
                newTracking.IsFreeShipping__c = isZuoraTrue(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.IsFreeShipping__c);
                newTracking.IsPreSale__c = isZuoraTrue(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.IsPreSale__c);
                newTracking.CustomerType__c = zuoraCustomerType(pricing);
                newTracking.Material_Number__c = mapZProductId_Product.get(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__c).SAP_Material_Number__c;
                newTracking.Currency__c = zuoraCurrency(pricing);
                newTracking.AmountOrPercentage__c = pricing.zqu__Price__c;
                newTracking.IsRecurring__c = isZuoraRecurring(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c, pricing.zqu__ProductRatePlanCharge__r.zqu__Type__c);
                if (isZuoraDiscountAmt(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c))
                {
                    if (String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c))
                        newTracking.Pricing_Type__c = sapPrice.get(sapPT.DISCOUNT_AMT);
                    else
                        newTracking.Pricing_Type__c = sapPrice.get(sapPT.COUPON_AMT);
                }
                else if (isZuoraDiscountPct(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c))
                {
                    if (String.isBlank(pricing.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Couponcode__c))
                        newTracking.Pricing_Type__c = sapPrice.get(sapPT.DISCOUNT_PCT);
                    else
                        newTracking.Pricing_Type__c = sapPrice.get(sapPT.COUPON_PCT);
                }
                else if (isZuoraVolume(pricing.zqu__ProductRatePlanCharge__r.zqu__Model__c))
                {
                    newTracking.Pricing_Type__c = sapPrice.get(sapPT.VOLUME);
                    newTracking.StartingUnit__c = pricing.zqu__StartingUnit__c;
                    newTracking.EndingUnit__c = pricing.zqu__EndingUnit__c;
                }
                else // Per Unit or Per Unit Pricing
                {
                    newTracking.Pricing_Type__c = sapPrice.get(sapPT.UNIT);
                    newTracking.StartingUnit__c = 1;
                }
                
                lstInsertTracking.add(newTracking);
            }
        }
        
        // should perform update before insert and cannot use upsert because of unique key
        Savepoint sp;
        if (lstUpdateTracking.size() > 0)
        {
            sp = Database.setSavepoint();
            try
            {
                update lstUpdateTracking;
            }
            catch (Exception e)
            {
                Database.rollback(sp);
                IECErrorLogger.logApexException('IEC_ZuoraPricing2SAP_Svc/trackPricing'
                                              , ('Update Error\n\nlstUpdateTracking\n' + String.join(lstUpdateTracking, '\n')).left(32768)
                                              , e.getMessage(), e.getStackTraceString());
            }
        }
        if (lstInsertTracking.size() > 0)
        {
            sp = Database.setSavepoint();
            try
            {
                insert lstInsertTracking;
            }
            catch (Exception e)
            {
                Database.rollback(sp);
                IECErrorLogger.logApexException('IEC_ZuoraPricing2SAP_Svc/trackPricing'
                                              , ('Insert Error\n\nlstInsertTracking\n' + String.join(lstInsertTracking, '\n')).left(32768)
                                              , e.getMessage(), e.getStackTraceString());
            }
        }
    }


    // send prices to SAP
    public void sendPricing(List<IEC_ZuoraPricing2SAP_Tracking__c> lstTracking)
    {
        // prepare lists of prices to send based on operation
        Map<String, List<IEC_ZuoraPricing2SAP_Tracking__c>> mapPriority_Pricing = new Map<String, List<IEC_ZuoraPricing2SAP_Tracking__c>>{
            sapOperation.get(sapOT.DEL) => new List<IEC_ZuoraPricing2SAP_Tracking__c>()
          , sapOperation.get(sapOT.INS) => new List<IEC_ZuoraPricing2SAP_Tracking__c>()
          , sapOperation.get(sapOT.UPD) => new List<IEC_ZuoraPricing2SAP_Tracking__c>()
        };
        for (IEC_ZuoraPricing2SAP_Tracking__c tracking : lstTracking)
            mapPriority_Pricing.get(tracking.Operation__c).add(tracking);
        
        // send prices based on operation - should send the deletion first to prevent possible conflicts on SAP
        List<IEC_ZuoraPricing2SAP_Tracking__c> lstUpdateTracking = new List<IEC_ZuoraPricing2SAP_Tracking__c>();
        List<IEC_Error_Log__c> lstError = new List<IEC_Error_Log__c>();
        sendPricingByOperation(mapPriority_Pricing.get(sapOperation.get(sapOT.DEL)), lstUpdateTracking, lstError);
        sendPricingByOperation(mapPriority_Pricing.get(sapOperation.get(sapOT.UPD)), lstUpdateTracking, lstError);
        sendPricingByOperation(mapPriority_Pricing.get(sapOperation.get(sapOT.INS)), lstUpdateTracking, lstError);
        
        // set mechanism to prevent sending again for prices successfully sent to SAP
        if (lstUpdateTracking.size() > 0)
        {
            Datetime dtSendTS = system.now();
            for (IEC_ZuoraPricing2SAP_Tracking__c tracking : lstUpdateTracking)
                tracking.SendingTimestamp__c = dtSendTS;
            update lstUpdateTracking;
        }
        if (lstError.size() > 0)
            insert lstError;
    }


    // send prices to SAP per type of operation
    // this interface is an asynchronous interface for PI/SAP which causes following issues
    //     cannot parse the WSDL provided by SAP team because it does not contain the response
    //     if the response is manually added to WSDL then the WSDL can be imported to Salesforce but will get error on callout
    //     cannot build an Apex class to simulate a callout without response because failed at execution as WebServiceCallout needs response
    // therefore need to build XML content to use in a HTTP request
    public void sendPricingByOperation(List<IEC_ZuoraPricing2SAP_Tracking__c> lstTracking, List<IEC_ZuoraPricing2SAP_Tracking__c> lstUpdate
                                     , List<IEC_Error_Log__c> lstError)
    {
        if (lstTracking.size() == 0)
            return;
        
        // by giving a maximum of 400 characters par each pricing item uses 1500 characters in average of message
        // by limiting of 5000 pricing items per call, a callout message will use less than 2 MB of heap
        final Integer intLimitPricingPerCall = (Test.isRunningTest() ? 5 : 5000);
        
        // determine range of pricings per call
        List<Integer> lstFrom = new List<Integer>(), lstTo = new List<Integer>();
        for (Integer ix1 = 0; ix1 < lstTracking.size(); ix1 += intLimitPricingPerCall)
        {
            lstFrom.add(ix1);
            lstTo.add(ix1 + intLimitPricingPerCall - 1);
        }
        lstTo[lstTo.size()-1] = lstTracking.size() - 1;
        
        // callout
        List<IEC_ZuoraPricing2SAP_Tracking__c> lstTrackingToUpdate = new List<IEC_ZuoraPricing2SAP_Tracking__c>();
        for (Integer ix1 = 0; ix1 < lstFrom.size(); ix1++)
        {
            // build callout message
            lstTrackingToUpdate.clear();
            XmlStreamWriter xml = initializeOutputXML();
            for (Integer ix2 = lstFrom[ix1]; ix2 <= lstTo[ix1]; ix2++)
            {
                addPricingToOutputXML(xml, lstTracking[ix2]);
                lstTrackingToUpdate.add(lstTracking[ix2]);
                
            }
            String xmlOutput = getOutputXML(xml);
            //system.debug(system.now().format('yyyy-MM-dd hh:mm:ss') + ': ' + xmlOutput);
            
            // callout
            String strCallError = sendPricingCallout(xmlOutput);
            if (strCallError == null)
                lstUpdate.addAll(lstTrackingToUpdate);
            else
                lstError.add(IECErrorLogger.createErrorLog('IEC_ZuoraPricing2SAP_Svc.sendPricingByOperation', xmlOutput.left(32768), strCallError, null));
        }
    }


    // perform a callout
    String sendPricingCallout(String xmlOutput)
    {
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        // URL got from WSDL
        httpReq.setEndpoint(Utility.fixEndpointDomain('http://ixidweb.sap.iata.org:8030/XISOAPAdapter/MessageServlet?senderParty=&' +
                                                      'senderService=SFDC&receiverParty=&receiverService=&interface=SI_SFDC_Pricing_OB&' +
                                                      'interfaceNamespace=http://iata.com/xi/SFDC/OTC/WID5614_Pricing/'));
        httpReq.setHeader('Authorization', Utility.getSAPauthorization());
        httpReq.setHeader('Accept', 'text/xml');
        httpReq.setHeader('Content-Type', 'text/xml');
        httpReq.setBody(xmlOutput);
        //system.debug(httpReq.getEndpoint());
        Http httpTarget = new Http();
        HttpResponse httpResp = httpTarget.send(httpReq);
        //system.debug(httpResp.getBody());
        //system.debug(httpResp.toString());
        Set<Integer> setSuccessStatusCode = new Set<Integer> {200, 201};
        return (setSuccessStatusCode.contains(httpResp.getStatusCode()) ? null : httpResp.toString());
    }


    // format a date according to SAP format
    String buildSAPDate(Date inDate) { return Datetime.newInstance(inDate.year(), inDate.month(), inDate.day()).format('yyyy-MM-dd'); }


    // initialize the content to send in XML format
    XmlStreamWriter initializeOutputXML()
    {
        XmlStreamWriter xml = new XmlStreamWriter();
        xml.writeStartDocument(null, '1.0');
        xml.writeStartElement('soapenv', 'Envelope', 'http://schemas.xmlsoap.org/soap/envelope/');
        xml.writeNamespace('soapenv', 'http://schemas.xmlsoap.org/soap/envelope/');
        xml.writeNamespace('m', 'http://iata.com/xi/SFDC/OTC/WID5614_Pricing/');
        xml.writeEmptyElement('soapenv', 'Header', 'http://schemas.xmlsoap.org/soap/envelope/');
        xml.writeStartElement('soapenv', 'Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        xml.writeStartElement('m', 'MT_SFDC_Pricing_Request', 'http://iata.com/xi/SFDC/OTC/WID5614_Pricing/');
        return xml;
    }


    // add a pricing to the XML content
    void addPricingToOutputXML(XmlStreamWriter xml, IEC_ZuoraPricing2SAP_Tracking__c tracking)
    {
        xml.writeStartElement(null, 'Pricing', null);
        
        xml.writeStartElement(null, 'Action', null);
        xml.writeCharacters(tracking.Operation__c);
        xml.writeEndElement();
        
        if (isSAPVolume(tracking.Pricing_Type__c))
        {
            xml.writeStartElement(null, 'ID', null);
            xml.writeCharacters((tracking.StartingUnit__c == null ? '1' : String.valueOf(tracking.StartingUnit__c.setScale(2, system.RoundingMode.HALF_UP)))
                                + '-' +
                                (tracking.EndingUnit__c == null ? '' : String.valueOf(tracking.EndingUnit__c.setScale(2, system.RoundingMode.HALF_UP))));
            xml.writeEndElement();
        }
        
        xml.writeStartElement(null, 'PriceType', null);
        xml.writeCharacters(tracking.Pricing_Type__c);
        xml.writeEndElement();
        
        xml.writeStartElement(null, 'CustomerType', null);
        xml.writeCharacters(String.isBlank(tracking.CustomerType__c) ? '': tracking.CustomerType__c);
        //xml.writeCharacters(String.isBlank(tracking.CustomerType__c) ? IECConstants.PARAM_CUSTOMERTYPE_DEFAULT : tracking.CustomerType__c);
        xml.writeEndElement();
        
        xml.writeStartElement(null, 'Material', null);
        xml.writeCharacters(tracking.Material_Number__c);
        xml.writeEndElement();
        
        xml.writeStartElement(null, 'AmountPercentage', null);
        xml.writeCharacters(String.valueOf(tracking.AmountOrPercentage__c.setScale(2, system.RoundingMode.HALF_UP)));
        xml.writeEndElement();
        
        xml.writeStartElement(null, 'Currency', null);
        xml.writeCharacters(tracking.Currency__c);
        xml.writeEndElement();
        
        if (isSAPUnit(tracking.Pricing_Type__c))
        {
            xml.writeStartElement(null, 'Per', null);
            xml.writeCharacters(String.valueOf(tracking.StartingUnit__c.setScale(0, system.RoundingMode.HALF_UP)));
            xml.writeEndElement();
        }
        
        if (isSAPUnit(tracking.Pricing_Type__c) || isSAPVolume(tracking.Pricing_Type__c))
        {
            xml.writeStartElement(null, 'Unit', null);
            xml.writeCharacters('EA');
            xml.writeEndElement();
        }
        
        xml.writeStartElement(null, 'ValidFrom', null);
        xml.writeCharacters(buildSAPDate(tracking.EffectiveFrom__c));
        xml.writeEndElement();
        
        xml.writeStartElement(null, 'ValidTo', null);
        xml.writeCharacters(buildSAPDate(tracking.EffectiveTo__c));
        xml.writeEndElement();
        
        xml.writeEndElement(); // end Pricing
    }


    // finalize XML content and return final content
    String getOutputXML(XmlStreamWriter xml)
    {
        xml.writeEndElement(); // end m
        xml.writeEndElement(); // end Body
        xml.writeEndElement(); // end Envelope
        xml.writeEndDocument();
        String xmlOutput = xml.getXmlString();
        xml.close();
        return xmlOutput;
    }
}
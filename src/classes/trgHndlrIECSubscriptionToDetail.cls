/*
* Trigger Helper class for zuora__Subscription__c to create/update the GSS_Subscription_Details
*  
*  The method processRelatedSubscriptionDetail will update/insert related GSS_Subscription_Detail__c, 
*  with information from zuora__Subscription__c and GDP_File_Description__c.
*  
*  This is done by using related Zuora_SubscriptionProductCharge__c, Product_Rate_Plan_Charge__c,
*  zqu_ProductRatePlan__c, GDP_File_Description_To_Rate_Plan__c, GDP_File_Description__c.
*  
*  Author: Sonny Leman
*  Change Log: 
*   - 20151223-sl: initial version
*   - 20160112-sl: change default monthly day of delivery to 10
*   - 20160122-sl: refine the default delivery days
*   - 20160229-sl: Calendar_New_Submission_Effective_Date__c  should be initialized to null
*   - 20160719-ab: Avoid creating GSS or CACWEB line when Cancelled Subscription
*   - 20161201-ab: Avoid to create inactive and Active record when CAC Subscription is Active
*/

public with sharing class trgHndlrIECSubscriptionToDetail {
    
    private static final String CALENDAR_OPTION_DEFAULT_WEEKLY = 'Monday'; 
    private static final String CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_1 = '10';
    private static final String CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_2 = '24';
    private static final String CALENDAR_OPTION_DEFAULT_MONTHLY = '10';
    private static final Integer CALENDAR_OPTION_MIDDLE_OF_MONTH = 15; 
    
    
    // ========================================================================
    // given a collection of Zuora__Subscription, rebuilt the GSS_Subscription_Detail related list
    //
    // this will be called as after update trigger on Zuora__Subscription__c
    // or indirectly by upsert trigger on Zuora__SubscriptionProductCharge (currently through processRelatedSubscriptionDetailSpc)
    public static void processRelatedSubscriptionDetail( Map<Id,Zuora__Subscription__c> zuoraSubscriptionIdToObjectMap)
    
    {
        List<Zuora__Subscription__c> zuoraSubscriptionList = zuoraSubscriptionIdToObjectMap.values();
        Set<Id> zuoraSubscriptionIdSet = zuoraSubscriptionIdToObjectMap.keySet();
        
        // get related Subscription Product & Charge
        List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList = [select Id
                , Zuora__Subscription__c 
                , Product_Rate_Plan_Charge__c
                , Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c
            from Zuora__SubscriptionProductCharge__c
            where Zuora__Subscription__c in : zuoraSubscriptionIdSet] ;
        
        // get related Product Rate Plan Charge , not needed, as it is covered above 
        
        // get mapping from Zuora__Subscription to set of ProductRatePlan Id
        Map<Id, Set<Id>> zuoraSubIdToProductRatePlanSetMap = new Map<Id, Set<Id>>(); // Zuora__Subcription mapping to its set of zqu__ProductRatePlan
        Set<Id> productRatePlanIdSet = new Set<Id>(); // all zqu__ProductRatePlan Id, used to get related GDP_File_Description through GDP_File_Description_To_Rate_Plan__c
        for ( Zuora__SubscriptionProductCharge__c zSubsProdCharge : zuoraSubscriptionProductChargeList)
        {
            Set<Id> prodRatePlanIdSet = zuoraSubIdToProductRatePlanSetMap.get(zSubsProdCharge.Zuora__Subscription__c);
            if (prodRatePlanIdSet == null) 
            {
                prodRatePlanIdSet = new Set<Id>();
                zuoraSubIdToProductRatePlanSetMap.put(zSubsProdCharge.Zuora__Subscription__c, prodRatePlanIdSet);
            }
            prodRatePlanIdSet.add(zSubsProdCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c);
            productRatePlanIdSet.add(zSubsProdCharge.Product_Rate_Plan_Charge__r.zqu__ProductRatePlan__c); 
        } // for zuoraSubscriptionProductChargeList
        
        
        // get related GDP_File_Description_To_Rate_Plan and related relevant GDP_File_Description fields
        List<GDP_File_Description_To_Rate_Plan__c> fileDescRatePlanList = [select Id
                ,GDP_File_Description__c
                ,Product_Rate_Plan__c
                ,GDP_File_Description__r.Frequency__c
                ,GDP_File_Description__r.Product_Type__c
                ,Share_Authorized_Usage__c
                ,Authorized_Usage__c
                //, GDP_File_Description__r.Reference__c
                //, GDP_File_Description__r.Reference__r.Frequency__c
            From GDP_File_Description_To_Rate_Plan__c
            Where Product_Rate_Plan__c in : productRatePlanIdSet
            Order by Product_Rate_Plan__c, GDP_File_Description__c
            ];
        
        // map the Product_Rate_Plan Id to Set of GDP_File_Description_To_Rate_Plan__c and also more important to GDP_File_Description 
        Map<Id,Set<GDP_File_Description_To_Rate_Plan__c>> prodRatePlanIdToFileDescRatePlanSetMap = new Map<Id,Set<GDP_File_Description_To_Rate_Plan__c>>();
        
        for (GDP_File_Description_To_Rate_Plan__c fileDescRatePlan : fileDescRatePlanList)
        {
            Set<GDP_File_Description_To_Rate_Plan__c> singleFileDescRatePlanSet = prodRatePlanIdToFileDescRatePlanSetMap.get(fileDescRatePlan.Product_Rate_Plan__c);
            if ( singleFileDescRatePlanSet==null)
            {
                singleFileDescRatePlanSet = new Set<GDP_File_Description_To_Rate_Plan__c>();
                prodRatePlanIdToFileDescRatePlanSetMap.put(fileDescRatePlan.Product_Rate_Plan__c, singleFileDescRatePlanSet);
            }
            singleFileDescRatePlanSet.add(fileDescRatePlan);
        }
        
        
        
/*
        createNewSubscriptionDetails( zuoraSubscriptionList, zuoraSubIdToProductRatePlanSetMap, prodRatePlanIdToFileDescRatePlanSetMap);
    } // end of processRelatedSubscriptionDetail
    
    
    
    // ========================================================================
    private static void createNewSubsriptionDetails(List<Zuora__Subscription__c> zuoraSubscriptionList
            , Map<Id, Set<Id>> zuoraSubIdToProductRatePlanSetMap
            , Map<Id,Set<GDP_File_Description_To_Rate_Plan__c>> prodRatePlanIdToFileDescRatePlanSetMap
    )
    {
*/
        
        // get the names
        Map<String, Zuora__Subscription__c> zuoraNameToSubscriptionObjectMap = new Map<String, Zuora__Subscription__c>();
        for (Zuora__Subscription__c zsub : zuoraSubscriptionList) 
        {
            zuoraNameToSubscriptionObjectMap.put( zsub.Name, zsub);
        }
        
        // get existing GSS Subscription_Details
        // in case we want, we can also filter with zuoraSubscriptionId for maintenance/cleaning up.
        List<GSS_Subscription_Detail__c> existingGSSSubscriptionDetailList = [select Id, Name
                , Zuora_Subscription__c
                , GDP_File_Description__c
                              
            from GSS_Subscription_Detail__c
            where (Name in :zuoraNameToSubscriptionObjectMap.keySet()) ];
        
        // get existing CAC Subscription_Details
        // in case we want, we can also filter with zuoraSubscriptionId for maintenance/cleaning up.
        List<CAC_Subscription_Detail__c> existingCACSubscriptionDetailList = [select Id, Name
                , Subscription__c
                , Service_Specification__c
                , Status__c  
            from CAC_Subscription_Detail__c
            where (Name in :zuoraNameToSubscriptionObjectMap.keySet()) ];
        
        // prepare mapping for existing GSS_Subscription_Detail__c
        Map<String, Set<GSS_Subscription_Detail__c>> subDetailNameToObjectSetMap = new Map<String, Set<GSS_Subscription_Detail__c>>();  
        Set<GSS_Subscription_Detail__c> subDetailSet = null;
        for(GSS_Subscription_Detail__c existingSubDet: existingGSSSubscriptionDetailList) 
        {
        
            subDetailSet = subDetailNameToObjectSetMap.get(existingSubDet.Name);
            if (subDetailSet == null)
            {

                subDetailSet = new Set<GSS_Subscription_Detail__c>();
                subDetailNameToObjectSetMap.put(existingSubDet.Name,subDetailSet);
            }
            if (existingSubDet.Zuora_Subscription__c==null) {
                Zuora__Subscription__c subscription =  zuoraNameToSubscriptionObjectMap.get(existingSubDet.Name);
                existingSubDet.Zuora_Subscription__c=subscription.id;
                }
            subDetailSet.add(existingSubDet);
        } // end of for existingGSSSubscriptionDetailList
        
        
        // prepare mapping for existing GSS_Subscription_Detail__c
        Map<String, Set<CAC_Subscription_Detail__c>> CAC_subDetailNameToObjectSetMap = new Map<String, Set<CAC_Subscription_Detail__c>>();  
        Set<CAC_Subscription_Detail__c> CAC_subDetailSet = null;
        for(CAC_Subscription_Detail__c CAC_existingSubDet: existingCACSubscriptionDetailList) 
        {
            CAC_subDetailSet = CAC_subDetailNameToObjectSetMap.get(CAC_existingSubDet.Name);
            if (CAC_subDetailSet == null)
            {

                CAC_subDetailSet = new Set<CAC_Subscription_Detail__c>();
                CAC_subDetailNameToObjectSetMap.put(CAC_existingSubDet.Name,CAC_subDetailSet);
            }
            System.Debug('CAC_existingSubDet >>>'+CAC_existingSubDet);
            if (CAC_existingSubDet.Subscription__c==null) {
              Zuora__Subscription__c subscription =  zuoraNameToSubscriptionObjectMap.get(CAC_existingSubDet.Name);
               CAC_existingSubDet.Subscription__c=subscription.id;
             }
            CAC_subDetailSet.add(CAC_existingSubDet);
        } // end of for existingGSSSubscriptionDetailList
        
        // --------------------------------------------------------------------
        // done with existing data collection here, now start with updating
        List<GSS_Subscription_Detail__c> GSS_subscriptionDetailToUpsertList = new List<GSS_Subscription_Detail__c>();
        List<CAC_Subscription_Detail__c> CAC_subscriptionDetailToUpsertList = new List<CAC_Subscription_Detail__c>();
        
        // for each zuora_subscription
        //  get related product rate plan by scanning Zuora__SubscriptionProductCharge__c
        //  for each, create subscription detail
        
        // the following fields actually are only used inside the loop below.
        Set<Id> prodRatePlanIdSet; // set of ProductRatePlan.Id related to a zSub 
        Boolean subcriptionDetailExists = false; // does GSS_Subscription_Detail exists for a File_Description/Zuora__Subscription
        GSS_Subscription_Detail__c relatedSubscriptionDetail = null; // new or matched GSS_Subscription_Detail record for a File_Description/Zuora__Subscription
        Boolean CAC_subcriptionDetailExists = false; // does GSS_Subscription_Detail exists for a File_Description/Zuora__Subscription
        CAC_Subscription_Detail__c CAC_relatedSubscriptionDetail = null; // new or matched GSS_Subscription_Detail record for a File_Description/Zuora__Subscription
        Set<GDP_File_Description_To_Rate_Plan__c> singleFileDescRatePlanSet; // set of File Description to Rate Plan junction object for the same Rate Plan
        Set<GSS_Subscription_Detail__c> existingSubDetailSet; // related set of existing Subscription Detail with the same name as zSub.Name 
        Set<CAC_Subscription_Detail__c> CAC_existingSubDetailSet; // related set of existing Subscription Detail with the same name as zSub.Name 
        System.debug('zuoraSubscriptionList >>>'+zuoraSubscriptionList);
        for (Zuora__Subscription__c zSub : zuoraSubscriptionList)
        {
            // get rate plan id set
            prodRatePlanIdSet = zuoraSubIdToProductRatePlanSetMap.get(zSub.Id);
            if (prodRatePlanIdSet!=null) 
            { // only process if there is related ProudctRatePlan 
                System.debug('prodRatePlanIdSet >>>'+prodRatePlanIdSet);
                for (Id productRatePlanId : prodRatePlanIdSet)
                {
                    // use list of File Description / GDP_File_Description_To_Rate_Plan
                    //fileDescRatePlanMatching = prodRatePlanIdToFileDescRatePObjectMap.get( productRatePlanId);
                    //Set<GDP_File_Description_To_Rate_Plan__c> 
                    singleFileDescRatePlanSet = prodRatePlanIdToFileDescRatePlanSetMap.get(productRatePlanId);
                    if (singleFileDescRatePlanSet == null) continue; // no need to process GSS_Subscription_Detail for this zqu_ProductRatePlan 
                    // for each GDP_File_Description_To_Rate_Plan__c, create GSS_Subscription_Detail with GDP_File_Description, if necessary  
                    for (GDP_File_Description_To_Rate_Plan__c fileDescRatePlanMatching : singleFileDescRatePlanSet)
                    {
                        // search/check if its GSS_Subscription_Detail already exists for a zSub and GDP_File_Description (note: it is one to many)
                        subcriptionDetailExists = false;
                        relatedSubscriptionDetail = null;
                        CAC_subcriptionDetailExists = false;
                        CAC_relatedSubscriptionDetail = null;
                        Integer ProductLevel=0;
                        if (fileDescRatePlanMatching.GDP_File_Description__r.Product_Type__c=='CACSWS'
                            || fileDescRatePlanMatching.GDP_File_Description__r.Product_Type__c=='CACEWS') ProductLevel=1;
                        //Set<GSS_Subscription_Detail__c> 
                        if (ProductLevel==0)
                        {
                            existingSubDetailSet = subDetailNameToObjectSetMap.get( zSub.Name);
                            if (existingSubDetailSet != null) 
                            { // only check on existing if there exist GSS_Subscription_Detail with same name as zSub.Name 
                                for (GSS_Subscription_Detail__c existingSubDetail : existingSubDetailSet )
                                {
                                    if (fileDescRatePlanMatching.GDP_File_Description__c == existingSubDetail.GDP_File_Description__c) {
                                        relatedSubscriptionDetail = existingSubDetail;
                                        subcriptionDetailExists = true;
                                        break;
                                    }
                                } // end for existingSubDetailSet
                            } // end if 
                            if (subcriptionDetailExists)
                            { // only set the link (previously has been emptied)
                                relatedSubscriptionDetail.Zuora_Subscription__c = zSub.Id;
                            } else { // create and initialize new GSS_Subscription_Detail
                                if (zSub.Zuora__Status__c!='Cancelled') relatedSubscriptionDetail = GSS_newSubscriptionDetail(fileDescRatePlanMatching,zSub);
                            }
                            if (relatedSubscriptionDetail!=null) GSS_subscriptionDetailToUpsertList.add(relatedSubscriptionDetail);
                        }
                        if (ProductLevel==1)
                        {
                            CAC_existingSubDetailSet = CAC_subDetailNameToObjectSetMap.get( zSub.Name);
                            System.debug('CAC_existingSubDetailSet >>>'+CAC_existingSubDetailSet);
                            if (CAC_existingSubDetailSet != null) 
                            { // only check on existing if there exist GSS_Subscription_Detail with same name as zSub.Name 
                                for (CAC_Subscription_Detail__c CAC_existingSubDetail : CAC_existingSubDetailSet )
                                {
                                    if (fileDescRatePlanMatching.GDP_File_Description__c == CAC_existingSubDetail.Service_Specification__c && CAC_existingSubDetail.Status__c=='Active') {
                                        CAC_relatedSubscriptionDetail = CAC_existingSubDetail;
                                        CAC_subcriptionDetailExists = true;
                                        break;
                                    }
                                } // end for existingSubDetailSet
                            } // end if 

                        
                            if (CAC_subcriptionDetailExists)
                            { // only set the link (previously has been emptied)
                                CAC_relatedSubscriptionDetail.Subscription__c = zSub.Id;
                            } else { // create and initialize new CAC_Subscription_Detail
                                if (zSub.Zuora__Status__c!='Cancelled') CAC_relatedSubscriptionDetail = CAC_newSubscriptionDetail(fileDescRatePlanMatching,zSub);
                            }
                            System.debug('CAC_relatedSubscriptionDetail'+CAC_relatedSubscriptionDetail);
                            if (CAC_relatedSubscriptionDetail!=null) CAC_subscriptionDetailToUpsertList.add(CAC_relatedSubscriptionDetail);
                        }
                        
                    } // end of for singleFileDescRatePlanSet
                } // end of for prodRatePlanIdSet
            } // if there is productRatePlan
            
        } // end of for zuoraSubscriptionList
        if (GSS_subscriptionDetailToUpsertList.Size()>0) upsert GSS_subscriptionDetailToUpsertList;
        System.debug('CAC_subscriptionDetailToUpsertList >>>'+CAC_subscriptionDetailToUpsertList);
        if (CAC_subscriptionDetailToUpsertList.Size()>0) upsert CAC_subscriptionDetailToUpsertList;        
        
        //review the one that have not been processed by the above loop
        List<CAC_Subscription_Detail__c> CAC_Inactive = new List<CAC_Subscription_Detail__c>();
        for(CAC_Subscription_Detail__c CAC_existingSubDet: existingCACSubscriptionDetailList) 
        {
           boolean cacfound=false;
           for(CAC_Subscription_Detail__c o: CAC_subscriptionDetailToUpsertList)
           {
             if (o.Id== CAC_existingSubDet.Id) {cacfound=true; break;}
           }
           if (!cacfound) { 
              for (Zuora__Subscription__c zSub : zuoraSubscriptionList)
              {
                  if (zSub.Id==CAC_existingSubDet.Subscription__c && zSub.Zuora__Status__c.equals('Cancelled')) {CAC_existingSubDet.Status__c='Inactive'; break;}
              }
            CAC_Inactive.add( CAC_existingSubDet);
           }
        } // end of for existingGSSSubscriptionDetailList

        
        if (CAC_Inactive.Size()>0) upsert CAC_Inactive;
    } // end of processRelatedSubscriptionDetail (was createNewSubsriptionDetails)
    
    
    // ========================================================================
    // set the GSS_Subscription_Detail fields:
    // assumption: fileDescRatePlanMatching contains relevant GDP_File_Description fields
    private static GSS_Subscription_Detail__c GSS_newSubscriptionDetail( 
            GDP_File_Description_To_Rate_Plan__c fileDescRatePlanMatching
            ,Zuora__Subscription__c zSub)
    {
        GSS_Subscription_Detail__c relatedSubscriptionDetail = new GSS_Subscription_Detail__c(Name = zSub.Name
                                , GDP_File_Description__c = fileDescRatePlanMatching.GDP_File_Description__c
                                , Zuora_Subscription__c = zSub.Id);
        
        // ----------------------------------------------------------
        // delivery calendar setting
        relatedSubscriptionDetail.Calendar_Weekly_Option__c = null;
        relatedSubscriptionDetail.Calendar_Monthly_Option__c = null;
        relatedSubscriptionDetail.Calendar_Semi_Monthly_First_Option__c = null;
        relatedSubscriptionDetail.Calendar_Semi_Monthly_Second_Option__c = null;
        
        //if (relatedSubscriptionDetail.GDP_File_Description__r.Frequency__c == 'Daily')
        //{
        //} else
        if (fileDescRatePlanMatching.GDP_File_Description__r.Frequency__c == 'Weekly')
        {
            relatedSubscriptionDetail.Calendar_Weekly_Option__c = CALENDAR_OPTION_DEFAULT_WEEKLY; // 'Monday'
        } else if (fileDescRatePlanMatching.GDP_File_Description__r.Frequency__c == 'Semi-Monthly')
        {
            relatedSubscriptionDetail.Calendar_Semi_Monthly_First_Option__c = CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_1; // '10'
            relatedSubscriptionDetail.Calendar_Semi_Monthly_Second_Option__c = CALENDAR_OPTION_DEFAULT_SEMI_MONTHLY_2; // '24'
        } else if (fileDescRatePlanMatching.GDP_File_Description__r.Frequency__c == 'Monthly')
        {
            relatedSubscriptionDetail.Calendar_Monthly_Option__c = CALENDAR_OPTION_DEFAULT_MONTHLY; // '10'
        }
        
        
        relatedSubscriptionDetail.Calendar_New_Submission_Effective_Date__c = null; // zSub.Zuora__SubscriptionStartDate__c;
        
        return relatedSubscriptionDetail;
    } // end of newSubscriptionDetail
    
    
    // ========================================================================
    // set the CAC_Subscription_Detail fields:
    // assumption: fileDescRatePlanMatching contains relevant Service_Specification fields
    private static CAC_Subscription_Detail__c CAC_newSubscriptionDetail( 
            GDP_File_Description_To_Rate_Plan__c fileDescRatePlanMatching
            ,Zuora__Subscription__c zSub)
    {
        CAC_Subscription_Detail__c relatedSubscriptionDetail = new CAC_Subscription_Detail__c(Name = zSub.Name
                                , Service_Specification__c = fileDescRatePlanMatching.GDP_File_Description__c
                                , Share_Authorized_Usage__c = fileDescRatePlanMatching.Share_Authorized_Usage__c
                                , Max_API_Call_Per_Month__c = fileDescRatePlanMatching.Authorized_Usage__c
                                , Service_Activation_Date__c = System.Today()
                                , Status__c='Active'
                                , Subscription__c = zSub.Id);
        
        
        return relatedSubscriptionDetail;
    } // end of newSubscriptionDetail
    
    
    // ========================================================================
    // this will be called as after insert trigger on Zuora__SubscriptionProductCharge__c
    // This is similar to the method above, but different triggering object
    //
    // Quick unoptimized version uses the method above processRelatedSubscriptionDetail. 
    // done by collecting zuora__Subscription first.
    public static void processRelatedSubscriptionDetailSpc( List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList)
    {
        // based on Zuora__SubscriptionProductCharge__c, get related zuora__Subscription (up) -- THIS IS THE MAIN DIFFERENCE WITH zuora__Subscription update trigger
        // and process down startring with ProductRatePlanCharge (down) using processRelatedSubscriptionDetail method above
        Set<Id> zuoraSubscriptionIdSet = new Set<Id>();  // used to get zuora__Subscription records
        for ( Zuora__SubscriptionProductCharge__c zSubsProdCharge : zuoraSubscriptionProductChargeList)
        {
            zuoraSubscriptionIdSet.add(zSubsProdCharge.Zuora__Subscription__c);
        } // for zuoraSubscriptionProductChargeList
        
        Map<Id,Zuora__Subscription__c> zuoraSubscriptionIdToObjectMap = new Map<Id,Zuora__Subscription__c> (
            [select Id
                    , Name 
                    , Zuora__Status__c
                    , Zuora__SubscriptionStartDate__c
                 From Zuora__Subscription__c
                 Where Id in : zuoraSubscriptionIdSet
                ]);
        processRelatedSubscriptionDetail(zuoraSubscriptionIdToObjectMap);
    } // end processRelatedSubscriptionDetailSpc TEMPORARY version
    
    
    
    
    // ========================================================================
    // this will be called as after insert trigger on Zuora__SubscriptionProductCharge__c
    // This is similar to the method above, but different triggering object
    // based on incoming Zuora__SubscriptionProductCharge__c, get related zuora__Subscription (up) -- THIS IS THE MAIN DIFFERENCE WITH zuora__Subscription update trigger
    // and process down startring with ProductRatePlanCharge (down) using processRelatedSubscriptionDetail method above
    //
    //private static void processRelatedSubscriptionDetailSpc1( List<Zuora__SubscriptionProductCharge__c> zuoraSubscriptionProductChargeList)
    //{
    //} // end of processRelatedSubscriptionDetailSpc1
    //
    
    
    
} // end of trgHndlrIECSubscriptionToDetail class
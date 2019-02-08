public class CampaignMemberProduct_Svc {
    /**
     *  Author David D - 02/216   
     *  call by a batch to create Campaign Member and Product records.
     */
    public static List<Campaign_Member_Product__c> generateCampaignMemberProducts(Id campaignId, List<OrderItem> items){
        List<Campaign_Member_Product__c> cmpSaved = new List<Campaign_Member_Product__c>();        
        
        Map<String, Campaign_Member_Product__c> cmpByKey = new Map<String, Campaign_Member_Product__c>();
        Map<Id, List<OrderItem>> itemsByContactId = new Map<Id, List<OrderItem>>(); 
        //Set<Id> productsOrdered = new Set<Id>();
        //Set<String> cmpSearchKeys = new Set<String>();
        List<IEC_Renewal_notice_log__c> lstErrorLog = new List<IEC_Renewal_notice_log__c>();



        //Set order items product ids
        Set<String> setProductsNumbers = new Set<String>();
        Set<Id> contactIds = new Set<Id>();
        for(OrderItem item : items){
            contactIds.add(item.Order.BillToContactId);
            setProductsNumbers.add(item.Product_Number__c.substringBefore('-')+'%');
        }

        System.debug('JJ setProductsNumbers : ' + setProductsNumbers);

        //get the subscriptions for this products and contacts
        List<IEC_Event_Subscription__c> lstEventSubscriptions = new IEC_EventSubscription_Sel().getEventSubscriptionByProductNumbersListAndContactsList(setProductsNumbers,contactIds);
        System.debug('JJ lstEventSubscriptions: ' + lstEventSubscriptions);
        
        Map<String,List<IEC_Event_Subscription__c>> mapSubscriptionByProductNbrWoVersion = IEC_EventSubscription_Svc.buildMapWithSubscByProductNbrWoVersion(lstEventSubscriptions);


        System.debug('JJ mapSubscriptionByProductNbrWoVersion : ' + mapSubscriptionByProductNbrWoVersion);

        
        for(OrderItem item : items){
            if(item.Order.BillToContactId != null){

                //get the subscription, if exists, for this order item by the product id and contact
                IEC_Event_Subscription__c iecEventSubsAux = null;
                if(mapSubscriptionByProductNbrWoVersion.containsKey(item.Product_Number__c.substringBefore('-'))){
                    List<IEC_Event_Subscription__c>  lstIecEventSubsAux = mapSubscriptionByProductNbrWoVersion.get(item.Product_Number__c.substringBefore('-'));
                    for(IEC_Event_Subscription__c iecAux : lstIecEventSubsAux){
                        if(iecAux.Subscriber__c == item.Order.BillToContactId){
                            iecEventSubsAux = iecAux;
                        }
                    }
                }
                System.debug('JJ iecEventSubsAux : ' + iecEventSubsAux);


                if(iecEventSubsAux == null || !(iecEventSubsAux != null && iecEventSubsAux.Active__c)){
                    List<OrderItem> tmp = (itemsByContactId.containsKey(item.Order.BillToContactId)) 
                        ?   itemsByContactId.get(item.Order.BillToContactId) 
                        :   new List<OrderItem>(); 
                    tmp.add(item);
                    
                    itemsByContactId.put(item.Order.BillToContactId, tmp);
                }
            }
            //productsOrdered.add(item.Product__c);
        }
        
        //*** build set of contact not deleted
        Set<Id> setLiveContactId = new Set<Id>();
        for (Contact c : [select Id from Contact where IsDeleted = false and Id in :itemsByContactId.keySet()]){
            setLiveContactId.add(c.Id);
        }
        
        for(Id contactId : itemsByContactId.keySet()){
            if (setLiveContactId.contains(contactId)){
                for(OrderItem item : itemsByContactId.get(contactId)){
                    String key = campaignId+'_'+contactId+'_'+item.Product__c;
                    
                    //validate key unicity 
                    if(cmpByKey.containsKey(key)){
                        //-- summarize quantity of all orders
                        Campaign_Member_Product__c cmp = cmpByKey.get(key);
                        if (item.Invoice_Date__c != null && (cmp.Invoice_Date__c == null || item.Invoice_Date__c > cmp.Invoice_Date__c))
                            cmp.Invoice_Date__c = item.Invoice_Date__c;
                        //if(item.Invoice_Date__c > cmp.Invoice_Date__c)
                            cmp.Quantity__c += item.Quantity;
                    }
                    else{
                        cmpByKey.put(key, new Campaign_Member_Product__c(
                            Campaign__c = campaignId,
                            Contact__c  = contactId,
                            Product__c  = item.Product__c,
                            Quantity__c = item.Quantity,
                            Key__c = key,
                            Invoice_Date__c = item.Invoice_Date__c
                        ));
                    }
                }
            }else {
                lstErrorLog.add(IEC_RenewalNotice_Svc.logError('Trying to create Campaign Member Product for deleted contact', String.valueOf(itemsByContactId.get(contactId)), null, campaignId, null, false));
            }
        }
        //-- Check in existing CMP if there is no duplicates with the one we are about to save 
        Map<String, Campaign_Member_Product__c> existingCMPByKey = new CampaignMemberProduct_Sel().getCampaignMemberProductByKey(cmpByKey.keySet());
        
        List<Campaign_Member_Product__c> cmpToInsert = new List<Campaign_Member_Product__c>();
        List<Campaign_Member_Product__c> cmpToUpdate = new List<Campaign_Member_Product__c>();
        
        for(String key : cmpByKey.keySet()){
            Campaign_Member_Product__c cmp = cmpByKey.get(key);
            
            if(existingCMPByKey.containsKey(key)){
                Campaign_Member_Product__c existingCMP = existingCMPByKey.get(key);
                //if(cmp.Invoice_Date__c > existingCMP.Invoice_Date__c)
                //{
                    //CMP more recent than the existing  => update the existing qty 
                    existingCMP.Quantity__c += cmp.Quantity__c;
                    cmpToUpdate.add(existingCMP);
                //}
            }else{
                cmpToInsert.add(cmp);
            }
        }
        
        if(cmpToUpdate.size() > 0){
            try{
                update cmpToUpdate; 
                cmpSaved.addAll(cmpToUpdate);
            }catch(Exception ex){
                lstErrorLog.add(IEC_RenewalNotice_Svc.logError('Error when trying to update Campaign Member Product', String.valueOf(ex), null, campaignId, null, false));
            }
        }
        if(cmpToInsert.size() > 0){
            try{
                insert cmpToInsert; 
                cmpSaved.addAll(cmpToInsert);
            }catch(Exception ex){
                lstErrorLog.add(IEC_RenewalNotice_Svc.logError('Error when trying to insert Campaign Member Product', String.valueOf(ex), null, campaignId, null, false));
            }
        }
        //*** log error if applicable
        if(lstErrorLog.size() > 0){
            insert lstErrorLog;
        }
        
        return cmpSaved;
    }
    
    /**
     *  Author David D - 02/216
     *  remove duplicates records at the end of the creation batch
     */
    public static void removeDuplicates(Set<String> duplicateKeys){
        List<Campaign_Member_Product__c> cmp2remove = new List<Campaign_Member_Product__c>(); 
        
        Map<String, List<Campaign_Member_Product__c>> cmpsByKey = new CampaignMemberProduct_Sel().getCampaignMemberProductsByKey(duplicateKeys);
        for(String key : cmpsByKey.keySet()){
            //-- We keep the most CMP (Latest Invoice Date)
            Campaign_Member_Product__c cmpToKeep; 
            for(Campaign_Member_Product__c cmp : cmpsByKey.get(key)){
                if(cmpToKeep == null || cmp.Invoice_Date__c > cmpToKeep.Invoice_Date__c){
                    cmpToKeep = cmp;
                }
            }
            
            for(Campaign_Member_Product__c cmp : cmpsByKey.get(key)){
                if(cmp.Id != cmpToKeep.Id){
                    cmp2remove.add(cmp);
                }
            }
        }
        
        if(cmp2remove.size() > 0){
            delete cmp2remove;
        }
    }
}
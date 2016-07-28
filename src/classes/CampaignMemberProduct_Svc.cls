public class CampaignMemberProduct_Svc 
{
    /**
     *  Author David D - 02/216   
     *  call by a batch to create Campaign Member and Product records.
     */
	public static List<Campaign_Member_Product__c> generateCampaignMemberProducts(Id campaignId, List<OrderItem> items)
    {
		List<Campaign_Member_Product__c> cmpSaved = new List<Campaign_Member_Product__c>();        
        
        Map<String, Campaign_Member_Product__c> cmpByKey = new Map<String, Campaign_Member_Product__c>();
        Map<Id, List<OrderItem>> itemsByContactId = new Map<Id, List<OrderItem>>(); 
        Set<Id> productsOrdered = new Set<Id>();
        Set<String> cmpSearchKeys = new Set<String>();
        
        for(OrderItem item : items)
        {
            if(item.Order.BillToContactId != null)
            {
				List<OrderItem> tmp = (itemsByContactId.containsKey(item.Order.BillToContactId)) 
                    ?   itemsByContactId.get(item.Order.BillToContactId) 
                    :   new List<OrderItem>(); 
                tmp.add(item);
                
                itemsByContactId.put(item.Order.BillToContactId, tmp);
            }
            
            productsOrdered.add(item.Product__c);
        }
        
        for(Id contactId : itemsByContactId.keySet())
        {
            for(OrderItem item : itemsByContactId.get(contactId))
            {
                String key = campaignId+'_'+contactId+'_'+item.Product__c;
                
                //validate key unicity 
                if(cmpByKey.containsKey(key))
                {
                    //-- If item Invoice Date is more recent the update qty 
                    Campaign_Member_Product__c cmp = cmpByKey.get(key);
                    if(item.Invoice_Date__c > cmp.Invoice_Date__c)
                        cmp.Quantity__c = item.Quantity;
                }
                else
                {
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
        }
        
        //-- Check in existing CMP if there is no duplicates with the one we are about to save 
        Map<String, Campaign_Member_Product__c> existingCMPByKey = new CampaignMemberProduct_Sel().getCampaignMemberProductByKey(cmpSearchKeys);
        
        List<Campaign_Member_Product__c> cmpToInsert = new List<Campaign_Member_Product__c>();
        List<Campaign_Member_Product__c> cmpToUpdate = new List<Campaign_Member_Product__c>();
        
        for(String key : cmpByKey.keySet())
        {
            Campaign_Member_Product__c cmp = cmpByKey.get(key);
            
            if(existingCMPByKey.containsKey(key))
            {
                Campaign_Member_Product__c existingCMP = existingCMPByKey.get(key);
                if(cmp.Invoice_Date__c > existingCMP.Invoice_Date__c)
                {
                    //CMP more recent than the existing  => update the existing qty 
                    existingCMP.Quantity__c = cmp.Quantity__c;
                    cmpToUpdate.add(existingCMP);
                }
            }
            else
            {
                cmpToInsert.add(cmp);
            }
        }
        
        if(cmpToUpdate.size() > 0)
        {
            update cmpToUpdate; 
            cmpSaved.addAll(cmpToUpdate);
        }
        
        if(cmpToInsert.size() > 0)
        {
            insert cmpToInsert; 
            cmpSaved.addAll(cmpToInsert);
        }
        
        return cmpSaved;
    }
    
    /**
     *  Author David D - 02/216
     *  remove duplicates records at the end of the creation batch
     */
    public static void removeDuplicates(Set<String> duplicateKeys)
    {
        List<Campaign_Member_Product__c> cmp2remove = new List<Campaign_Member_Product__c>(); 
        
        Map<String, List<Campaign_Member_Product__c>> cmpsByKey = new CampaignMemberProduct_Sel().getCampaignMemberProductsByKey(duplicateKeys);
        for(String key : cmpsByKey.keySet())
        {
            //-- We keep the most CMP (Latest Invoice Date)
            Campaign_Member_Product__c cmpToKeep; 
			for(Campaign_Member_Product__c cmp : cmpsByKey.get(key))
            {
                if(cmpToKeep == null || cmp.Invoice_Date__c > cmpToKeep.Invoice_Date__c)
                {
                    cmpToKeep = cmp;
                }
            }
            
            for(Campaign_Member_Product__c cmp : cmpsByKey.get(key))
            {
                if(cmp.Id != cmpToKeep.Id)
                {
                    cmp2remove.add(cmp);
				}
            }
        }
        
        if(cmp2remove.size() > 0)
        {
            delete cmp2remove;
        }
    }
}
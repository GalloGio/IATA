public class IEC_EventRelease_Svc 
{
    //1. Set Product Last Version 
    //2. Validate that the product to be use for the renewal has price
    public static void validateProducts(List<IEC_Event_Release__c> releases)
    {
        validateProducts(releases, new Set<Id>());
    }
    public static void validateProducts(List<IEC_Event_Release__c> releases, Set<Id> setEventToSkip)
    {
        //*** do not continue if data is updated from batch
        if (System.isBatch())
            return;
        
        Product_Sel pSelector = new Product_Sel();

        Set<Id> productIds4LastVersion  = new Set<Id>(); //To find last version
        Set<Id> productIds4PriceCheck   = new Set<Id>(); //To validate price exist
        
        for(IEC_Event_Release__c release : releases)
        { 
            //-- 1. Unflag Orders_Generated__c 
            //if(!System.isBatch()){
            if (!setEventToSkip.contains(release.Id))
            {
                release.Released__c = false;
                release.Last_Version__c = null;
                release.Sales_Amout__c = null;
                release.Sales_Quantity__c = null;
                release.Nb_Customer__c = null;
                release.Processing_Status__c = null;

                productIds4LastVersion.add(release.Product__c);
            }
        }

        //-- 2. Set Product Last Version 
        Map<Id, Product2> productLastVersion = pSelector.getProductLastVersions(productIds4LastVersion);
        
        for(IEC_Event_Release__c release : releases)
        {
            if (!setEventToSkip.contains(release.Id))
                if(productLastVersion.containsKey(release.Product__c))
                {
                    Product2 lastVersion = productLastVersion.get(release.Product__c);
                    release.Last_Version__c = lastVersion.Id;

                    productIds4PriceCheck.add((release.Swapped_Product__c != null)? release.Swapped_Product__c: release.Last_Version__c);
                    //productIds4PriceCheck.add(lastVersion.Id);
                }
        }

        //-- 3. Validate Products has price
        List<EComProduct_DTO> ecomProducts = Product_Sel.getEComProduct(new List<Id>(productIds4PriceCheck), false,null, null);
         System.debug('ecomProducts::'+ecomProducts);

        Map<Id, Decimal> unitPriceByProductId = new Map<Id, Decimal>();
        for(EComProduct_DTO prod : ecomProducts)
            if(prod.UnitPrice != null)
                unitPriceByProductId.put(prod.ProductId, prod.UnitPrice);
        
        
        for(IEC_Event_Release__c release : releases)
        {
            if (!setEventToSkip.contains(release.Id))

                if(!unitPriceByProductId.containsKey(release.Last_Version__c) && !unitPriceByProductId.containsKey(release.Swapped_Product__c))
                {
                    String msg = (release.Swapped_Product__c != null)
                        ? 'The Swapped products has not Unit Price. Set its price first'
                        : 'The Last Version of your Product has no unit Price. Set its price first';
                    release.addError(msg);
                }
                else
                    release.Processing_Status__c = 'Preparing ....';
        }
    }


    /****************************************************************************************************
    Created by Kevin 2015-4-06
        Call batch to generate renewals
    ****************************************************************************************************/
    public static void generateAutoRenewals(List<IEC_Event_Release__c> releases, Map<Id,IEC_Event_Release__c> releasesMap)
    {
        generateAutoRenewals(releases, releasesMap, new Set<Id>());
    }
    public static void generateAutoRenewals(List<IEC_Event_Release__c> releases, Map<Id,IEC_Event_Release__c> releasesMap, Set<Id> setEventToSkip)
    {
        System.debug('In generateAutoRenewals');
        //*** do not continue if data is updated from batch
        if (System.isBatch())
            return;
        
        if(releasesMap == null)
        {
            //-- New Releases: generate Orders no cleanup needed
            for(IEC_Event_Release__c release : releases)
            {
                System.debug('before call IEC_Event_Renewal_CreateOrders_Batch');
                Database.executeBatch(new IEC_Event_Renewal_CreateOrders_Batch(release, null), Utility.getIntegerSetting('IEC Event renewal batch size'));
            }
        }
        else 
        {
            //-- Only process releases when Product or Customer Type changes 
            List<IEC_Event_Release__c> releasesToProcess = new List<IEC_Event_Release__c>();
            List<IEC_Event_Release__c> releasesToClearMessage = new List<IEC_Event_Release__c>();

            for(IEC_Event_Release__c release : releases)
            {
                if (!setEventToSkip.contains(release.Id))
                    if(release.Last_Version__c != releasesMap.get(release.Id).Last_Version__c || release.Swapped_Product__c != releasesMap.get(release.Id).Swapped_Product__c ||
                       release.Customer_Type__c != releasesMap.get(release.Id).Customer_Type__c || release.Product__c != releasesMap.get(release.Id).Product__c)
                    {
                        releasesToProcess.add(release);
                    }
                    else
                        releasesToClearMessage.add(new IEC_Event_Release__c(Id=release.Id, Processing_Status__c=null));
            }

            //Clear Logs then Auto Renewals on update
            if(releasesToProcess.size() > 0)
            {
                Database.executeBatch(new IEC_ReleaseLogCleanup_Batch(releasesToProcess, 'ClearAutoRenewals')); 
            }
            
            //*** remove message for release not proceed
            if(releasesToClearMessage.size() > 0)
                update releasesToClearMessage;
        }   
    }


    /****************************************************************************************************
        Created by Thai 2016-04-19
            Ensure that changes on record are related with fields exposed on UI
    ****************************************************************************************************/
    public static Set<Id> skipChangedRecord(List<IEC_Event_Release__c> oldList, List<IEC_Event_Release__c> newList)
    {
        Set<Id> setEventToSkip = new Set<Id>();
        for (Integer i1 = 0; i1 < newList.size(); i1++)
            if (newList[i1].Name == oldList[i1].Name && newList[i1].Customer_Type__c == oldList[i1].Customer_Type__c &&
                newList[i1].Product__c == oldList[i1].Product__c && newList[i1].Swapped_Product__c == oldList[i1].Swapped_Product__c &&
                newList[i1].Released__c == oldList[i1].Released__c)
                setEventToSkip.add(newList[i1].Id);
        return setEventToSkip;
    } //*** end of "skipChangedRecord"


    /****************************************************************************************************
        Created by Thai 2016-04-22
            Prevent deletion when a process is running
    ****************************************************************************************************/
    public static void preventDeletion(List<IEC_Event_Release__c> oldList)
    {
        for (IEC_Event_Release__c event : oldList)
            if (!String.isBlank(event.Processing_Status__c))
                event.addError('Please wait! A process is running for release.');
    } //*** end of "preventDeletion"


}
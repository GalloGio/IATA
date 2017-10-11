/**  
  * Description: Trigger Handler for the IECAddress__c object of the IEC project
  * Author: Alexandre McGraw
  * Version: 1.0
  * History: 
  */
public with sharing class trgHndlrIECAddress {

    /**
     * Business rule logic after an IECAddress has been inserted
     */
    /* Commented by Samy Saied (2016-02-29) for using the new Location model instead of only iecaddress
    public static void OnBeforeInsert(List<IECAddress__c> newRecords) {
        Set<Id> setContactId = new Set<Id>();
        List<Contact> ContactstoUpdate = new List<Contact>();
        
        for (IECAddress__c address : newRecords) {
            setContactId.add(address.Contact__c);
            
            if(address.Address_Type__c  == 'Billing')
             {
                 Contact temp = new Contact();
                 temp.Id = address.Contact__c;
                 temp.MailingCountry = address.Country__c;
                 temp.MailingState = address.State__c;
                 ContactstoUpdate.add(temp);
             }   
        }
        
        //try catch added to fix issue on ecommerce community user access restriction.
        try{ Update ContactstoUpdate;}
        catch(exception e){ }
        
        
        List<AggregateResult> results =
            [SELECT Contact__c GroupByKey1
                , Address_Type__c GroupByKey2
                , COUNT(Id) CountAddress
            FROM IECAddress__c
            WHERE Contact__c IN :setContactId
            GROUP BY Contact__c, Address_Type__c];

        Map<String, AggregateResult> mapResults = IECUtil.GetAggregateResultMap(results, new List<String> {'String', 'String'});
        
        for (IECAddress__c address : newRecords) {
            if (mapResults.containsKey(address.Contact__c + ':' + address.Address_Type__c))
                address.Address_Type__c.addError(Label.IEC_Error_OnlyOneAddressPerType);
        }
    }
    */

    /**
     * Business rule logic after an IECAddress has been updated
     */
    public static void OnAfterUpdate(List<IECAddress__c> newRecords, Map<Id, IECAddress__c> newRecordsMap)
    {
        List<Location__c> locs = [SELECT Id, Type__c from Location__c
        where Address__c in:newRecords AND Type__c = 'Sold To'
        AND Account__r.ACLI_SAP_Id__c <> null AND Account__r.ACLI_Status__c = 'Active company'];

        if (locs.size() > 0) newRecords[0].addError('You can not update IEC Addresses associated with Sold-To locations for ACLI accounts');

/* Commented by Samy Saied for using the new Location model instead of only iecaddress
        List<String> lstAddressIds = new List<String>();
        List<Contact> ContactstoUpdate = new List<Contact>();
        
        // Build list of IECAddress__c id to sync
        for (IECAddress__c oAddress : newRecords) {
            
            // check if the IECAddress object is linked to a Billing Account (cannot sync if contact does not exists in Zuora)
            Zuora__CustomerAccount__c oBillingAccount = IECZuoraHelper.getBillingAccountByContactId(oAddress.Contact__c);
            if (oBillingAccount != null)
                lstAddressIds.add(oAddress.Id);

            if(oAddress.Address_Type__c  == 'Billing')
             {
                 Contact temp = new Contact();
                 temp.Id = oAddress.Contact__c;
                 temp.MailingCountry = oAddress.Country__c;
                 temp.MailingState = oAddress.State__c;
                 ContactstoUpdate.add(temp);
             }   
        }
        
        //try catch added to fix issue on ecommerce community user access restriction.
        try{ Update ContactstoUpdate;}
        catch(exception e){ }

        // sync (future method)
        if (!lstAddressIds.isEmpty())
            IECZuoraHelper.syncAddressInformationWithZuora(lstAddressIds);
		*/
		// Make a future call to Zuora to update the related contacts that share the same address record
		IECAddress_Svc.syncIECAddressWithZuora(newRecordsMap.keySet());
		
		// Make a future call to SAP to update the related contacts that share the same address record
		IECAddress_Svc.syncIECAddressWithSAP(newRecordsMap.keySet());
    }
}
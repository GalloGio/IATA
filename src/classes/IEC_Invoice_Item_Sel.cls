/*
 * Test Coverage is provided under the trgHndlrIECInvoice_tst class
 */
public without sharing class IEC_Invoice_Item_Sel extends Selector {
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Invoice_Item__c.Id,
            Invoice_Item__c.Unit_Price__c,
            Invoice_Item__c.Quantity__c,
            Invoice_Item__c.Subscription_Zuora_ID__c,
            Invoice_Item__c.Subscription_Number__c,
            Invoice_Item__c.Invoice__c,
            Invoice_Item__c.Subscription_Product_Charge_Zuora_ID__c,
            Invoice_Item__c.Charge_Amount__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Invoice_Item__c.sObjectType;
    }

    /****************************************************************************************************
    Created by Samy 2016-05-05
        return an Invoice_Item__c by Set of Id
        	will exclude tax and shipping invoice items to avoid messing up calculations
    ****************************************************************************************************/
    public List<Invoice_Item__c> getInvoiceItemsById(Set<Id> setInvoiceItemId)
    {
         String query = String.format(
            'SELECT {0}, Name, Service_Start_Date__c, Service_End_Date__c ' + 
            '     , Invoice__r.Zuora__Account__c, Invoice__r.Zuora__BillingAccount__r.Contact__c ' +
            '     , Invoice__r.Name, Invoice__r.Zuora__External_Id__c, Invoice__r.Zuora__InvoiceDate__c ' +
            '     , Product__r.SAPProductMaterialNo__c, Product__r.Name, Product__c ' +
            '     , Subscription_Product_Charge__r.Product_Rate_Plan_Charge__r.zqu__ZuoraId__c ' +
            'FROM {1} ' + 
            ' WHERE Id IN :setInvoiceItemId ' +
            '	AND Charge_Name__c NOT IN (\'\'Tax\'\', \'\'Shipping\'\')', 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);
    }

    /****************************************************************************************************
    Created by Samy 2016-05-20
        return an Invoice_Item__c by Set of Subscription Zuora Ids
    ****************************************************************************************************/
    /*public List<Invoice_Item__c> getInvoiceItemsBySubZId(Set<String> setSubZId)
    {
         String query = String.format(
            'SELECT {0} ' + 
            'FROM {1} ' + 
            ' WHERE Subscription_Zuora_ID__c IN :setSubZId ' +
            '	AND Charge_Name__c NOT IN (\'\'Tax\'\', \'\'Shipping\'\')',
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);
    }*/
}
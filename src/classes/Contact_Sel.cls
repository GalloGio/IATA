/****************************************************************************************************
    Created by Kevin Ky 2015-09-29
    
****************************************************************************************************/
public without sharing class Contact_Sel extends Selector {
    
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            Contact.id,
            Contact.Name,
            Contact.FirstName,
            Contact.LastName,
            Contact.Email,
            Contact.Title,
            Contact.Phone,
            Contact.Tax_1_ID__c,
            Contact.Tax_2_ID__c,
            Contact.MailingStreet,
            Contact.MailingCity,
            Contact.MailingPostalCode,
            Contact.MailingState,
            Contact.MailingCountry,
            Contact.AccountId,
            Contact.BillTo_Location__c,
            Contact.ShipTo_Location__c 
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Contact.sObjectType;
    }

    public Contact getContactById(Id contactId)
    {
        /*List<Contact> contacts = (List<Contact>) selectSObjectById(new Set<Id>{contactId}); 
        return (contacts != null && contacts.size() > 0)  ? contacts[0]  : null; */

        String query = String.format(
            'SELECT {0}, Account.Name, Account.CurrencyIsoCode ' +
            '   ,BillTo_Location__r.Address__c, BillTo_Location__r.Street__c, BillTo_Location__r.City__c, BillTo_Location__r.ZipCode__c' +
            '   ,BillTo_Location__r.ISO_Country_Name__c, BillTo_Location__r.ISO_Country_Code__c' +
            '   ,BillTo_Location__r.ISO_State_Name__c, BillTo_Location__r.ISO_State_Code_SAP__c' +
            '   ,ShipTo_Location__r.Address__c, ShipTo_Location__r.Street__c, ShipTo_Location__r.City__c, ShipTo_Location__r.ZipCode__c' +
            '   ,ShipTo_Location__r.ISO_Country_Name__c, ShipTo_Location__r.ISO_Country_Code__c' +
            '   ,ShipTo_Location__r.ISO_State_Name__c, ShipTo_Location__r.ISO_State_Code_SAP__c' +
            ' FROM {1} ' + 
            ' WHERE Id = :contactId ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        List<Contact> contacts = Database.query(query);
        return (contacts != null && contacts.size() > 0)  ? contacts[0]  : null;
    }


    /****************************************************************************************************
        Created by Kevin Ky 2015-09-29
            Return Account Id by Contact Id
    ****************************************************************************************************/
    public static map<Id,Id> getAccountIdByContactId(set<Id> contactIds){
        map<Id,Id> contactIds_accountIds = new map<Id,Id>();
        list<Contact> lstContact = [SELECT id,AccountId from Contact where id in :contactIds];
        if(lstContact != null && lstContact.size() > 0){
            for(Contact contact : lstContact){
                contactIds_accountIds.put(contact.Id,contact.AccountId);
            }
        }
        
        return contactIds_accountIds;
    }
    
    /****************************************************************************************************
        Created by Kevin Ky 2015-10-02
            Return Contact by Contact Id
    ****************************************************************************************************/
    public static map<Id,Contact> getContactById(set<Id> contactIds){

        return new map<Id,Contact>([
                                    SELECT 
                                        Id,FirstName,LastName,Email,Phone,Tax_1_ID__c,Tax_2_ID__c,Title,Name,Salutation,
                                        MailingStreet,MailingCity,MailingPostalCode,MailingState,MailingCountry, IsDeleted, Account.CurrencyIsoCode, Account.Parent.CurrencyIsoCode,
                                        Account.BillingStreet,Account.BillingCity,Account.BillingPostalCode,Account.BillingState,Account.BillingCountry,
                                        Account.ShippingStreet,Account.ShippingCity,Account.ShippingPostalCode,Account.ShippingState,Account.ShippingCountry,
                                        Account.Sector__c, Account.Name, Account.Parent.Name, Account.Parent.Sector__c, Account.Parent.BillingStreet, 
                                        Account.Parent.BillingCity,Account.Parent.BillingPostalCode,Account.Parent.BillingState,Account.Parent.BillingCountry, 
                                        Account.ParentId,Account.SoldTo_Location__c, AccountId,BillTo_Location__r.Account__r.SoldTo_Location__c,
                                        BillTo_Location__c, BillTo_Location__r.Address__c,BillTo_Location__r.VAT_Number__c,BillTo_Location__r.SAP_Id__c,
                                        BillTo_Location__r.Street__c,BillTo_Location__r.City__c,BillTo_Location__r.ZipCode__c,BillTo_Location__r.Account__c,
                                        BillTo_Location__r.ISO_Country_Name__c,BillTo_Location__r.ISO_Country_Code__c,BillTo_Location__r.Account_Name__c,
                                        BillTo_Location__r.ISO_State_Name__c,BillTo_Location__r.ISO_State_Code__c,BillTo_Location__r.ISO_State_Code_SAP__c,
                                        BillTo_Location__r.Contact_First_Name__c,BillTo_Location__r.Contact_Last_Name__c,BillTo_Location__r.Contact_Phone__c,
                                        BillTo_Location__r.Contact_Email__c,BillTo_Location__r.Contact_Salutation__c,BillTo_Location__r.Country__c,
                                        BillTo_Location__r.State__c,BillTo_Location__r.Email__c,BillTo_Location__r.Phone__c,BillTo_Location__r.Contact__c,
                                        ShipTo_Location__c, ShipTo_Location__r.Address__c,ShipTo_Location__r.VAT_Number__c,ShipTo_Location__r.SAP_Id__c,
                                        ShipTo_Location__r.Street__c,ShipTo_Location__r.City__c,ShipTo_Location__r.ZipCode__c,ShipTo_Location__r.Account__c,
                                        ShipTo_Location__r.ISO_Country_Name__c,ShipTo_Location__r.ISO_Country_Code__c,ShipTo_Location__r.Account_Name__c,
                                        ShipTo_Location__r.ISO_State_Name__c,ShipTo_Location__r.ISO_State_Code__c,ShipTo_Location__r.ISO_State_Code_SAP__c,
                                        ShipTo_Location__r.Contact_First_Name__c,ShipTo_Location__r.Contact_Last_Name__c,ShipTo_Location__r.Contact_Phone__c,
                                        ShipTo_Location__r.Contact_Email__c,ShipTo_Location__r.Contact_Salutation__c,ShipTo_Location__r.Country__c,
                                        ShipTo_Location__r.State__c,ShipTo_Location__r.Email__c,ShipTo_Location__r.Phone__c ,ShipTo_Location__r.Contact__c
                                    from Contact 
                                    where id in : contactIds
                                ]);
    }
    
}
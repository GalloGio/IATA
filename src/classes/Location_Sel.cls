public without sharing class Location_Sel extends Selector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Location__c.Id,
            Location__c.Email__c,
            Location__c.Phone__c,
            Location__c.Attention__c,
            Location__c.Address_Name__c,
            Location__c.Account__c,
            Location__c.Account_Contact_ID__c,
            Location__c.Account_Email__c,
            Location__c.Account_Name__c,
            Location__c.Account_Payment_Term__c,
            Location__c.Account_Payment_Type__c,
            Location__c.Account_Phone__c,
            Location__c.Account_Record_Type_Id__c,
            Location__c.Account_VAT_Number__c,
            Location__c.Address__c,
            Location__c.Country__c,
            Location__c.City__c,
            Location__c.State__c,
            Location__c.Contact__c,
            Location__c.Contact_Email__c,
            Location__c.Contact_First_Name__c,
            Location__c.Contact_Last_Name__c,
            Location__c.Contact_Phone__c,
            Location__c.Contact_Salutation__c,
            Location__c.Contact_Title__c,
            Location__c.Active__c,
            Location__c.ISO_Country_Code__c,
            Location__c.ISO_Country_Name__c,
            Location__c.ISO_State_Code__c,
            Location__c.ISO_State_Code_SAP__c,
            Location__c.ISO_State_Name__c,
            Location__c.SAP_Id__c,
            Location__c.Shipping_Condition__c,
            Location__c.Street__c,
            Location__c.Type__c,
            Location__c.ZipCode__c,
            Location__c.Full_Address__c,
            Location__c.VAT_Number__c,
            Location__c.Is_Postal_Code_Required__c,
            Location__c.IEC_Valid_SAP_State__c
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Location__c.sObjectType;
    }

    //return the Location by Account base on the sold to on the location 
    public map<Id,Location__c> getSoldToAccountLocation(set<Id> accountIds){

        map<Id,Location__c> accountId_Location = new map<Id,Location__c>();

        String type = 'Sold To';
        String query = String.format(
            'SELECT {0} ' +
            'FROM {1} ' + 
            'WHERE Account__c in :accountIds and Type__c = :type ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        List<Location__c> locations = (List<Location__c>)Database.query(query);
        if(locations != null && locations.size() > 0){
            for(Location__c location : locations){
                accountId_Location.put(location.Account__c,location);
            }
        }
        return accountId_Location;
    }

    //return locations base on the contact id
    public map<Id,Location__c> getContactsLocations(set<Id> contactIds){
        
        map<Id,Location__c> locationMap = new map<Id,Location__c>();

        String query = String.format(
            'SELECT {0}, ' + 
            'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
            'Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, ' + 
            'Address__r.Street__c,Address__r.City__c,Address__r.Country__c,Address__r.State__c,Address__r.ZipCode__c, Address__r.IEC_Zip_Postal_Code_required__c, ' +
            'Address__r.ISO_Country__r.VAT_Validation_Required__c ' +
            'FROM {1} ' + 
            'WHERE Contact__c in :contactIds and Active__c = true '+
            'ORDER BY Full_Address__c ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        List<Location__c> locations = (List<Location__c>)Database.query(query);

        locationMap = new map<Id,Location__c>(locations);

        return locationMap;
    }

	 //return locations base on the contact id
    public map<Id,Location__c> getContactsBillToLocations(set<Id> contactIds){
        
        map<Id,Location__c> locationMap = new map<Id,Location__c>();
        String type_x = 'Bill To';
        String query = String.format(
            'SELECT {0}, ' + 
            'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
            'Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, ' + 
            'Address__r.Street__c,Address__r.City__c,Address__r.Country__c,Address__r.State__c,Address__r.ZipCode__c, Address__r.IEC_Zip_Postal_Code_required__c, ' +
            'Address__r.ISO_Country__r.VAT_Validation_Required__c ' +
            'FROM {1} ' + 
            'WHERE Contact__c in :contactIds and Active__c = true AND Type__c = :type_x '+
            'ORDER BY Full_Address__c ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        List<Location__c> locations = (List<Location__c>)Database.query(query);

        locationMap = new map<Id,Location__c>(locations);

        return locationMap;
    }

    //get the list of Location by Id
    public List<Location__c> getLocations(set<Id> locationIds){

        String query = String.format(
            'SELECT {0}, ' + 
            'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
            'Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, ' + 
            'Address__r.Street__c,Address__r.City__c,Address__r.Country__c,Address__r.State__c,Address__r.ZipCode__c, Address__r.IEC_Zip_Postal_Code_required__c, ' +
            'Address__r.ISO_Country__r.VAT_Validation_Required__c, Contact__r.AccountId, Contact__r.Account.Name ' +
            'FROM {1} ' + 
            'WHERE Id in :locationIds and Active__c = true ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return (List<Location__c>)Database.query(query);
    }

    //get the list of ShipTo Location by Address
    public List<Location__c> getLocationByAddressId(Id billToAddressId){

        string shipTo = IECConstants.SHIPTO;
        String query = String.format(
            'SELECT {0}, ' + 
            'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
            'Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, ' + 
            'Address__r.Street__c,Address__r.City__c,Address__r.Country__c,Address__r.State__c,Address__r.ZipCode__c, Address__r.IEC_Zip_Postal_Code_required__c, ' +
            'Address__r.ISO_Country__r.VAT_Validation_Required__c ' +
            'FROM {1} ' + 
            'WHERE Address__c =:billToAddressId and Type__c = :shipTo and Active__c = true ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return (List<Location__c>)Database.query(query);
    }

    //Get the map of locations by Id
    public map<Id,Location__c> getLocationById(set<Id> locationIds){

        String query = String.format(
            'SELECT {0}, ' + 
            'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
            'Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, ' + 
            'Address__r.Street__c,Address__r.City__c,Address__r.Country__c,Address__r.State__c,Address__r.ZipCode__c, Address__r.IEC_Zip_Postal_Code_required__c, ' +
            'Address__r.ISO_Country__r.VAT_Validation_Required__c, Contact__r.AccountId, Contact__r.Account.Name ' +
            'FROM {1} ' + 
            'WHERE Id in :locationIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return new map<Id,Location__c>((List<Location__c>)Database.query(query));
    }

    // Retrieve list of Active Bill-To locations based on Account/Contact Ids
    public List<Location__c> getBillToLocationsByAccountContactId(Set<String> setAccountContactId)
    {
        return [SELECT Id, Account_Contact_ID__c 
            FROM Location__c
            WHERE Account_Contact_ID__c IN :setAccountContactId
                AND Active__c = true
                AND Type__c = 'Bill To'
            ORDER BY LastModifiedDate DESC];
    }

    public Map<Id, Location__c> getOrdersLocations(List<Order> orders)
    {
        Set<Id> locationIds = new Set<Id>();
        for(Order ord : orders)
        {
            locationIds.add(ord.SoldTo_Location__c);
            locationIds.add(ord.BillTo_Location__c);
            locationIds.add(ord.ShipTo_Location__c);
        }

        String query = String.format(
            'SELECT {0}, Contact__r.AccountId, Contact__r.Name, Contact__r.Account.Name, Contact__r.Account.ParentId, ' + 
                'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
                'Contact__r.Account.Parent.Name, Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, Address__r.IEC_Zip_Postal_Code_required__c, ' + 
                'Address__r.ISO_Country__r.VAT_Validation_Required__c ' +
            'FROM {1} ' + 
            'WHERE Id IN :locationIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        return new Map<Id,Location__c>((List<Location__c>)Database.query(query));
    }

    public Map<Id, Location__c> getSoldToLocationByContactId(Set<Id> contactIds)
    {
        Map<Id, Location__c> ret = new Map<Id, Location__c>();
        String soldTo = 'Sold To';

        List<Contact> contacts = [SELECT Id, AccountId, Account.ParentId FROM Contact WHERE Id IN :contactIds];
        
        Map<Id, Id> headOfficeAccountByContact = new Map<Id, Id>();
        Set<Id> headOfficeIds = new Set<Id>();
        for(Contact c : contacts)
        {
            Id headOfficeId = (c.Account.ParentId != null) ? c.Account.ParentId : c.AccountId;
            headOfficeAccountByContact.put(c.Id, headOfficeId);
            headOfficeIds.add(headOfficeId);
        }
        
        String query = String.format(
            'SELECT {0}, Contact__r.AccountId, Contact__r.Name, Contact__r.Account.Name, Contact__r.Account.ParentId, Contact__r.Account.Parent.Name, ' + 
            'Address__r.ISO_Country__r.Name,Address__r.ISO_Country__c,Address__r.ISO_Country__r.ISO_Code__c, ' + 
            'Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__c, Address__r.IEC_Zip_Postal_Code_required__c ' + 
            'FROM {1} ' + 
            'WHERE Account__c IN :headOfficeIds AND Type__c = :soldTo' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );

        List<Location__c> locations = (List<Location__c>)Database.query(query);
        Map<Id, Location__c> soldToLocationByAccountId = new Map<Id, Location__c>();

        for(Location__c loc : locations)
        {
            soldToLocationByAccountId.put(loc.Account__c, loc);
        }

        for(Id contactId : headOfficeAccountByContact.keySet())
        {
            Id accountId = headOfficeAccountByContact.get(contactId);
            ret.put(contactId, soldToLocationByAccountId.get(accountId));
        }

        return ret; 
    }

    public static List<Location__c> getLocationsByContactIdAndType(Id contactId, String type){
        return [select id,Address__c from Location__c where Contact__c =: contactId and Type__c = :type];
    }
    
    /**
     * Returns a list of Location associated to a Contact by the Address Type
     * @param contactId The Id of the Contact to get the location
     * @param sAddressType Picklist value of the field Location__c.Type__c (Bill To or Ship To)
     * @return A list of Location__c related to the contact
     *
     */
    public static List<Location__c> getLocationByContact(Id idContact, String sAddressType) {
        return [SELECT Account__c, Contact__c, Address__c, Type__c, VAT_Number__c 
             FROM Location__c
             WHERE Contact__c = :idContact
               AND Type__c = :sAddressType
               AND Active__c = true];
    }

    public static Map<Id, Location__c> getActiveBillToByContact(Set<Id> contactIds)
    {
        Map<Id, Location__c> ret = new Map<Id, Location__c>();

        List<Location__c> locations = [
            SELECT Id, Account__c, Contact__c, Address__c, Type__c, VAT_Number__c 
            FROM Location__c
            WHERE Contact__c IN :contactIds
               AND Type__c = :IECConstants.BILLTO
               AND Active__c = true
       ];

        if(locations.size() > 0)
            for(Location__c loc : locations)
                ret.put(loc.Contact__c, loc);
            

        return ret;
    }

	/****************************************************************************************************
	    Created by Thai 2016-12-09
	        Return location records with all necessary information to synchronize to SAP
	****************************************************************************************************/
	public static Map<Id, Location__c> getLocationToSyncSAP(List<Id> lstLocationId, List<Id> lstAccountId, List<Id> lstContactId, String strType, Boolean activeOnly)
	{
		String SOQL = ' select Id, Type__c, VAT_Number__c, Phone__c, Email__c, Attention__c, SAP_Id__c, Active__c'
		            +       ', Address__c, Address__r.Street__c, Address__r.City__c, Address__r.ZipCode__c'
		            +       ', Address__r.ISO_State__c, Address__r.ISO_State__r.Name, Address__r.ISO_State__r.ISO_Code__c, Address__r.ISO_State__r.IEC_Valid_SAP__c'
		            +       ', Address__r.ISO_Country__r.Name, Address__r.ISO_Country__r.ISO_Code__c, Address__r.ISO_Country__c'
		            +       ', Contact__c, Contact__r.Name, Contact__r.Salutation, Contact__r.FirstName, Contact__r.LastName'
		            +       ', Account__c, Account__r.Name, Account__r.Phone, Account__r.Email__c, Account__r.Default_Payment_Type__c'
		            +       ', Account__r.SoldTo_Location__r.SAP_Id__c'
		            + ' from Location__c where Type__c in (\'Sold To\',\'Bill To\',\'Ship To\')'
		            + (lstLocationId != null && lstLocationId.size() > 0 ? ' and Id in :lstLocationId' : '')
		            + (lstAccountId != null && lstAccountId.size() > 0 ? ' and Account__c in :lstAccountId' : '')
		            + (lstContactId != null && lstContactId.size() > 0 ? ' and Contact__c in :lstContactId' : '')
		            + (!String.isBlank(strType) ? ' and Type__c = :strType' : '')
		            + (activeOnly != null && activeOnly ? ' and Active__c = true' : '');
		List<Location__c> lstLocation = Database.query(SOQL);
		return new Map<Id, Location__c>(lstLocation);
	} //*** end of "getLocationToSyncSAP"

}
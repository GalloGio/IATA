public without sharing class IECAddress_Sel extends Selector{

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> 
        {
            IECAddress__c.Id,
            IECAddress__c.City__c,
            IECAddress__c.Contact__c,
            IECAddress__c.Country__c,
            IECAddress__c.Full_Address__c,
            IECAddress__c.ISO_Country__c,
            IECAddress__c.ISO_Country_Code__c,
            IECAddress__c.ISO_Country_Name__c,
            IECAddress__c.ISO_State__c,
            IECAddress__c.ISO_State_Code__c,
            IECAddress__c.ISO_State_Name__c,
            IECAddress__c.State__c,
            IECAddress__c.Street__c,
            IECAddress__c.ZipCode__c 
        };
    }

    public Schema.SObjectType getSObjectType()
    {
        return IECAddress__c.sObjectType;
    }

    public List<IECAddress__c> getFullAddress(String fullAddress){

        String query = String.format(
            'SELECT {0}, ISO_State__r.ISO_Code__c  ' + 
            'FROM {1} ' + 
            'WHERE Full_Address__c = :fullAddress' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);

    }

    //get addresses base on the address and iso country and State code
    public List<IECAddress__c> getAddress(String street,String city,String isoCountryCode, String isoStateCode, String zipCode){
        street = Utility.removeNewline(street);
        
        String query = String.format(
            'SELECT {0}, ISO_State__r.ISO_Code__c, ISO_State__r.Name, ISO_State__r.IEC_Valid_SAP__c, ISO_Country__r.ISO_Code__c, ISO_Country__r.Name  ' + 
            'FROM {1} ' + 
            'WHERE Street__c = :street and City__c = :city and ISO_Country__r.ISO_Code__c =:isoCountryCode and ISO_State__r.ISO_Code__c =:isoStateCode and ZipCode__c =:zipCode ' +
            'ORDER BY Id' ,
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);
    }

    //get addresses base on the address and iso country and State id
    public List<IECAddress__c> getAddressByIsoIds(String street,String city,Id isoCountryId, Id isoStateId, String zipCode){
        street = Utility.removeNewline(street);
        
        String query = String.format(
            'SELECT {0}, ISO_State__r.ISO_Code__c, ISO_Country__r.ISO_Code__c  ' + 
            'FROM {1} ' + 
            'WHERE Street__c = :street and City__c = :city and ISO_Country__c =:isoCountryId and ISO_State__c =:isoStateId and ZipCode__c =:zipCode ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);
    }


    public List<IECAddress__c> getAddresses(set<Id> addressesIds){
        String query = String.format(
            'SELECT {0}, ISO_State__r.ISO_Code__c, ISO_Country__r.ISO_Code__c, ISO_Country__r.VAT_Validation_Required__c ' + 
            'FROM {1} ' + 
            'WHERE Id in :addressesIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
        
        return Database.query(query);
    }


    /****************************************************************************************************
        Created by CGI, Thai 2016-03-22
            Return addresses for autocomplete
    ****************************************************************************************************/
    public static List<String> getAutocompleteAddresses(String strInput)
    {
        //List<String> lstAddress = new List<String>();
        
        //strInput = strInput + '%';
        //for (IECAddress__c address : [select Full_Address__c from IECAddress__c where Full_Address__c like :strInput limit 10])
            //lstAddress.add(address.Full_Address__c);
        //return lstAddress;
        return getAutocompleteAddresses(strInput, null, null);
    } //*** end of "getAutocompleteAddresses"
    public static List<String> getAutocompleteAddresses(String strInput, String isoCountryCode, String isoStateCode)
    {
        List<String> lstAddress = new List<String>();
        
        strInput = strInput + '%';
        String SOQL = 'select Full_Address__c from IECAddress__c where Full_Address__c like :strInput';
        if (!String.isBlank(isoCountryCode))
            SOQL += ' and ISO_Country_Code__c = :isoCountryCode';
        if (!String.isBlank(isoStateCode))
            SOQL += ' and ISO_State_Code__c = :isoStateCode';
        for (IECAddress__c address : Database.query(SOQL + ' limit 10'))
            lstAddress.add(address.Full_Address__c);
        return lstAddress;
    } //*** end of "getAutocompleteAddresses"

}
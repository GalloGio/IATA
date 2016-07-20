public class AMS_AddressHelper {

    public static void setPrimaryAddressesOnAgencies(List<AMS_Address__c> news){
        List<Id> agencyIds = new List<Id>();
        List<Id> addressIds = new List<Id>();
        
        for(AMS_Address__c add : news){
            agencyIds.add(add.Agency__c);
            addressIds.add(add.Id);
        }
        Map<Id,AMS_Address__c> addWithCountryState = new Map<Id,AMS_Address__c>(
                                                    [SELECT Country__r.ISO_code__c, Country__r.AIMS_Area_Name__c, State__r.Name, State__r.ISO_Code__c, Country__r.AIMS_Area_ID__c,TTY__c,Country__r.Name, State__c
                                                     FROM AMS_Address__c WHERE Id IN :addressIds]);
        
        Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([SELECT Id, Account__r.Id, Account__r.BillingStreet, Account__r.BillingPostalCode, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry,  
                                                                       Account__r.ShippingStreet,Account__r.ShippingPostalCode, Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingCountry, Primary_address__c,
                                                                       Iso_State__c
                                                                       FROM AMS_Agency__c 
                                                                       WHERE Id IN :agencyIds]);
        
        List<AMS_Agency__c> agenciesToUpdate = new List<AMS_Agency__c>();
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        for(AMS_Address__c add : news){
            AMS_Address__c addCS = addWithCountryState.get(add.id);
            AMS_Agency__c theAgency = mapAgencies.get(add.Agency__c);
            Account theAccount = accountsToUpdate.get(theAgency.Account__c)!=null ? 
                                        accountsToUpdate.get(theAgency.Account__c) : 
                                        theAgency.Account__r;
            if(theAgency!=null){
                boolean saveAcc = false;
                if(add.Address_Type__c.contains('Primary') && theAccount!=null){
                    theAccount.Fax = (add.Fax_Int__c==null?'':add.Fax_Int__c + ' ') + (add.Fax_STD__c==null?'':add.Fax_STD__c) + (add.Fax__c==null?'':add.Fax__c);
                    theAccount.Phone = (add.Telephone_Int__c==null?'':add.Telephone_Int__c + ' ') + (add.Telephone_STD__c==null?'':add.Telephone_STD__c) + (add.Telephone__c==null?'':add.Telephone__c);
                    theAccount.Email__c = add.Email__c;
                    theAccount.Website = add.Website__c;
                    theAccount.TTY__c = add.TTY__c; 
                    theAccount.IATA_Area__c = add.Country__r.AIMS_Area_ID__c;
                    theAccount.IATA_ISO_Country__c = add.Country__c;
                    saveAcc = true;
                }
                if(add.Address_Type__c.contains('Primary') && isShippingAddressEmpty(theAccount)){
                    theAccount = copyShippingAddressInfo(theAccount, add, addCS);
                    saveAcc = true;
                }if(add.Address_Type__c.contains('Primary') && isBillingAddressEmpty(theAccount)){
                    theAccount = copyBillingAddressInfo(theAccount, add, addCS);
                    saveAcc = true;
                }
                if(saveAcc && accountsToUpdate.get(theAccount.id)==null)
                    accountsToUpdate.put(theAccount.id, theAccount);
                
                if(add.Address_Type__c.contains('Primary') || (add.Address_Type__c.contains('Billing')  && theAgency.Primary_address__c == null)){
                    theAgency.Primary_address__c = add.id;
                    if(add.State__c != null)
                        theAgency.Iso_State__c = add.State__c;
                    //theAccount.IATA_Area__c = add.Country__r.AIMS_Area_ID__c;
                    //theAccount.IATA_ISO_Country__c = add.Country__c;
                    agenciesToUpdate.add(theAgency);
                }
                    
            }
        }
        System.debug('------ agenciesToUpdate: ' + agenciesToUpdate);
        update agenciesToUpdate;
        update accountsToUpdate.values();
        
    }
    
        
    public static void deletePrimaryAddressesOnAgencies(List<Id> agencyIds){
        List<AMS_Agency__c> agencies = [SELECT Id //Main_address_country__c,Main_address_state__c,Main_address_city__c,Main_address_zip_code__c,Main_address__c
                                        FROM AMS_Agency__c WHERE Id IN :agencyIds];

        for(AMS_Agency__c theAgency : agencies){
                theAgency.Primary_Address__c = null;
        }
        update agencies;
        
    }
    
    public static void UpdatePrimaryAddresses(List<AMS_Address__c> addresses){
        

        for(AMS_Address__c add : addresses){

                List<String> splitAddressType = add.Address_Type__c.split(';',0); 

                System.debug('------ splitAddressType: ' + splitAddressType);
                System.debug('------ splitAddressType: ' + splitAddressType.size());

                if(splitAddressType.size() > 1){
                    String result = '';
                    for(String sAddressType : splitAddressType){
                        
                        System.debug('------ sAddressType: ' + sAddressType);
                        if(!sAddressType.equalsIgnoreCase('Primary')){
                            result = result == '' ? sAddressType : result + ';' + sAddressType;
                        }
                        System.debug('------ result: ' + result);
                    }
                    add.Address_Type__c = result;
                }else{
                    //have only the primary value
                    add.Address_Type__c = 'Old';
                }
                System.debug('------ add.Address_Type__c: ' + add.Address_Type__c);
        }
        update addresses;
        
    }
    
    /*public static void setBillingShippingAddressesOnAccount(List<AMS_Address__c> news){
        List<Id> agencyIds = new List<Id>();
        List<Id> addressIds = new List<Id>();
        
        for(AMS_Address__c add : news){
            agencyIds.add(add.Agency__c);
            addressIds.add(add.Id);
        }
        Map<Id,AMS_Address__c> addWithCountryState = new Map<Id,AMS_Address__c>(
                                                    [SELECT Country__r.ISO_code__c, State__r.Name ,TTY__c,Country__r.Name, State__c
                                                     FROM AMS_Address__c WHERE Id IN :addressIds]);
        
        Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([SELECT Id, Account__r.Id, Account__r.TTY__c,Account__r.BillingStreet,Account__r.BillingPostalCode, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry,  
                                                                       Account__r.ShippingStreet,Account__r.ShippingPostalCode, Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingCountry,
                                                                       Iso_State__c
                                                                       FROM AMS_Agency__c 
                                                                       WHERE Id IN :agencyIds]);
                 
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        for(AMS_Address__c add : news){
            AMS_Address__c addCS = addWithCountryState.get(add.id);
            AMS_Agency__c theAgency = mapAgencies.get(add.Agency__c);
            Account theAccount = accountsToUpdate.get(theAgency.Account__c)!=null ? 
                                        accountsToUpdate.get(theAgency.Account__c) : 
                                        theAgency.Account__r;
            if(theAgency!=null && theAccount!=null){
                if(add.Address_Type__c.contains('Shipping') && isShippingAddressEmpty(theAccount))
                    theAccount = copyShippingAddressInfo(theAccount, add, addCS);
                if(add.Address_Type__c.contains('Billing') && isBillingAddressEmpty(theAccount))
                    theAccount = copyBillingAddressInfo(theAccount, add, addCS);
                if(add.Address_Type__c.contains('Primary') && isBillingAddressEmpty(theAccount))
                    theAccount = copyBillingAddressInfo(theAccount, add, addCS);
                
                theAgency.Primary_address__c = add.id;
                if(add.State__c != null)
                        theAgency.Iso_State__c = add.State__c;
                if(accountsToUpdate.get(theAccount.id)==null)
                    accountsToUpdate.put(theAccount.id, theAccount);
            }
        }
        update accountsToUpdate.values();
        
    }*/
    
    //FM 14-10-2015 - INC:10933
    public static void updateBillingShippingAddressesOnAccount(List<AMS_Address__c> news){
        List<Id> agencyIds = new List<Id>();
        List<Id> addressIds = new List<Id>();
        
        for(AMS_Address__c add : news){
            agencyIds.add(add.Agency__c);
            addressIds.add(add.Id);
        }
        Map<Id,AMS_Address__c> addWithCountryState = new Map<Id,AMS_Address__c>(
                                                    [SELECT Country__r.ISO_code__c,Country__r.Name, Country__r.AIMS_Area_Name__c,State__r.Name, State__r.ISO_Code__c, TTY__c, State__c, Website__c, Email__c, Telephone_Int__c, Telephone_STD__c, Telephone__c, Fax_Int__c, Fax_STD__c, Fax__c
                                                     FROM AMS_Address__c WHERE Id IN :addressIds]);
        
        Map<Id,AMS_Agency__c> mapAgencies = new Map<Id,AMS_Agency__c>([SELECT Id,Account__r.TTY__c, Account__r.Id, Account__r.BillingStreet,Account__r.BillingPostalCode, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingCountry,  
                                                                       Account__r.ShippingStreet,Account__r.ShippingPostalCode, Account__r.ShippingCity, Account__r.ShippingState, Account__r.ShippingCountry,
                                                                       Iso_State__c
                                                                       FROM AMS_Agency__c 
                                                                       WHERE Id IN :agencyIds]);
                 
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        for(AMS_Address__c add : news){
            AMS_Address__c addCS = addWithCountryState.get(add.id);
            AMS_Agency__c theAgency = mapAgencies.get(add.Agency__c);
            Account theAccount = accountsToUpdate.get(theAgency.Account__c)!=null ? 
                                        accountsToUpdate.get(theAgency.Account__c) : 
                                        theAgency.Account__r;
            if(theAgency!=null && theAccount!=null){
                if(add.Address_Type__c.contains('Shipping') )
                    theAccount = copyShippingAddressInfo(theAccount, add, addCS);
                if(add.Address_Type__c.contains('Billing') )
                    theAccount = copyBillingAddressInfo(theAccount, add, addCS);
                if(add.Address_Type__c.contains('Primary') )
                    theAccount = copyBillingAddressInfo(theAccount, add, addCS);
                
                //theAgency.Primary_address__c = add.id;
                if(accountsToUpdate.get(theAccount.id)==null)
                    accountsToUpdate.put(theAccount.id, theAccount);
            }
        }
        update accountsToUpdate.values();
        
    }
    //FM 14-10-2015 - END
    
    
    public static boolean isBillingAddressEmpty(Account theAccount){
        if(theAccount==null)return false;
        return  String.isEmpty(theAccount.BillingStreet) &&
                String.isEmpty(theAccount.BillingCity) &&
                String.isEmpty(theAccount.BillingCountry) &&
                String.isEmpty(theAccount.BillingState) &&
                String.isEmpty(theAccount.BillingPostalCode);
    }
    
    public static boolean isShippingAddressEmpty(Account theAccount){
        if(theAccount==null)return false;
        return  String.isEmpty(theAccount.ShippingStreet) &&
                String.isEmpty(theAccount.ShippingCity) &&
                String.isEmpty(theAccount.ShippingCountry) &&
                String.isEmpty(theAccount.ShippingState) &&
                String.isEmpty(theAccount.ShippingPostalCode);
    }
    
    public static Account copyBillingAddressInfo(Account theAccount, AMS_Address__c add, AMS_Address__c addCS){
        if(theAccount==null)return null;
        theAccount.BillingStreet = (add.Address_1__c==null?'':add.Address_1__c + ' ')  + 
                                   (add.Address_2__c==null?'':add.Address_2__c + ' ')  + 
                                   (add.Address_3__c==null?'':add.Address_3__c) ;
        theAccount.BillingCity = add.City__c;
        theAccount.BillingCountry = addCS.Country__r.Name;
        //theAccount.BillingState = addCS.State__r.Name;
        theAccount.BillingState = getValideState(addCS);
        theAccount.BillingPostalCode = add.AMS_ZipCode__c;
        if(add.Address_Type__c.contains('Primary')){
            theAccount.TTY__c = add.TTY__c;
        }
        theAccount.website =   add.Website__c;
        theAccount.Email__c=   add.Email__c;
        theAccount.Phone=   (add.Telephone_Int__c == null?'':add.Telephone_Int__c+' ') 
                                    + (add.Telephone_STD__c==null?'':add.Telephone_STD__c)
                                    + (add.Telephone__c==null?'':add.Telephone__c);
        theAccount.Fax=   (add.Fax_Int__c==null?'':add.Fax_Int__c + ' ') 
                                    + (add.Fax_STD__c==null?'':add.Fax_STD__c)
                                    + (add.Fax__c==null?'':add.Fax__c);

        return theAccount;
    }

    public static Account copyShippingAddressInfo(Account theAccount, AMS_Address__c add, AMS_Address__c addCS){
        if(theAccount==null)return null;
        theAccount.ShippingStreet = (add.Address_1__c==null?'':add.Address_1__c + ' ')  + 
                                   (add.Address_2__c==null?'':add.Address_2__c + ' ')  + 
                                   (add.Address_3__c==null?'':add.Address_3__c) ;
        theAccount.ShippingCity = add.City__c;
        theAccount.ShippingCountry = addCS.Country__r.Name;
        //theAccount.ShippingState = addCS.State__r.Name;
        theAccount.ShippingState = getValideState(addCS);
        theAccount.ShippingPostalCode = add.AMS_ZipCode__c;
        
        return theAccount;
    }

    public static List<AMS_Address__c> getAgencyAddresses(Id agencyId){

        List<AMS_Address__c> lAMS_Address = [SELECT Address_1__c,Address_2__c,Address_3__c,Address_Type__c,Agency__c,AMS_ZipCode__c,
                                                City__c,Country_postal_abbreviation__c,Country__c,Email__c,Fax__c,Id,Mobile__c,Name,
                                                State__c,Telephone__c,TTY__c,Website__c,
                                                Country__r.ISO_Code__c,Country__r.Name,
                                                State__r.ISO_Code__c
                                                FROM AMS_Address__c
                                                WHERE Agency__c = :agencyId];

        return lAMS_Address;
    }

    public static String getValideState(AMS_Address__c add){
        if((add.State__c != null && add.Country__c != null) && (add.State__r.Name == add.Country__r.AIMS_Area_Name__c || add.State__r.Name == add.State__r.ISO_Code__c || add.State__r.Name == add.Country__r.ISO_Code__c))
            return '';
        else
            return add.State__r.Name;
    }

}
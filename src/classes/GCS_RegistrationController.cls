public without sharing class GCS_RegistrationController{

    @AuraEnabled(cacheable=true)
    public static CountryInformation getISOCountries() {
        List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
        for(IATA_ISO_Country__c iso : IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name')){
            if (iso.Name != 'All Countries' &&  iso.Name != 'NO COUNTRY'){
                countries.add(iso);
            }
        }
        return new CountryInformation(countries);
    }

    @AuraEnabled
    public static GCS_Customer_Type_For_Registration__mdt getMetadataCustomerType(String customerTypeKey) {
        return GCS_AccountCreation.getMetadataCustomerType(customerTypeKey);
    }

    @AuraEnabled
    public static boolean registration(Account acc, Contact con, String serviceName, Map<String, String> cityAndStateIds){
        System.debug('GCS Registration process - account information : ' + acc);
        if(acc.Id != null){
            Account existingAccount = [SELECT Sector__c,IATA_ISO_Country__c,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_State__c,IATA_ISO_Billing_State__c
                    FROM Account 
                    WHERE Id =: acc.Id];
                    
            acc.Sector__c = existingAccount.Sector__c;
            acc.IATA_ISO_Country__c = existingAccount.IATA_ISO_Country__c;
            acc.IATA_ISO_Shipping_Country__c = existingAccount.IATA_ISO_Shipping_Country__c;
            acc.IATA_ISO_Shipping_State__c = existingAccount.IATA_ISO_Shipping_State__c;
            acc.IATA_ISO_Billing_State__c = existingAccount.IATA_ISO_Billing_State__c;
        }
        return OneId_RegistrationProcessController.registrationAux(acc, con, serviceName, cityAndStateIds);
    }


    @AuraEnabled
    public static boolean automaticRegistration(Contact con, String country,GCS_Customer_Type_For_Registration__mdt customerType,String serviceName){
        String accountQuery = '';
        accountQuery +='SELECT Id,Sector__c,IATA_ISO_Country__c,ParentId,Legal_name__c,Airline_designator__c,Reason_for_creation__c,IATA_ISO_Shipping_Country__c,BillingCountry,ShippingCountry,IATA_ISO_Billing_State__c,IATA_ISO_Shipping_State__c,Category__c,RecordType.DeveloperName';
        accountQuery +=' FROM Account';
        accountQuery +=' WHERE Id != null';

        if(!String.isEmpty(country)){
            accountQuery +=' AND IATA_ISO_Country__c=\''+country+'\'';
        }

        if(!String.isEmpty(customerType.Filter_on_Record_Type__c)){
            accountQuery +=' AND RecordType.DeveloperName =\''+customerType.Filter_on_Record_Type__c+'\'';
        }
        if(!String.isEmpty(customerType.Filter_on_Sector__c)){
            accountQuery +=' AND Sector__c =\''+customerType.Filter_on_Sector__c+'\'';
        }
        if(!String.isEmpty(customerType.Filter_on_Category__c)){
            accountQuery +=' AND Category__c =\''+customerType.Filter_on_Category__c+'\'';
        }

        List<Account> accs = new List<Account>();

        System.debug('Account query: '+accountQuery);

        accs = Database.query(accountQuery);

        System.debug('Found accounts : '+accs.size());

        if(!accs.isEmpty()){
            return OneId_RegistrationProcessController.registration(accs.get(0), con, serviceName);
        }

        return false;
    }

    @AuraEnabled
    public static Map<String,String> getAccountLabels() {
        List<String> contactFields = new List<String> {
                'BillingAddress',
                'BillingCity',
                'BillingCountry',
                'BillingPostalCode',
                'BillingState',
                'BillingStreet',
                'Category__c',
                'Email__c',
                'IATACode__c',
                'Legal_name__c',
                'Name',
                'Sector__c',
                'ShippingAddress',
                'ShippingCity',
                'ShippingCountry',
                'ShippingPostalCode',
                'ShippingState',
                'ShippingStreet',
                'TradeName__c',
                'Website',
                'Airline_designator__c',
                'Airline_Prefix__c'
        };
        Map<String, SObjectField> accountFields = Schema.SObjectType.Account.fields.getMap();
        Map<String,String> labels = new Map<String,String>();
        for (String name : contactFields) {
            SObjectField f = accountFields.get(name);
            if (f!=null){
                labels.put(f.getDescribe().getName(), f.getDescribe().getLabel());
            }
        }
        return labels;
    }

    @AuraEnabled(cacheable=true)
    public static List<GCS_CustomerType> getCustomerTypesList(){
        return GCS_CustomerType.getCustomerTypesList();
    }
    

    @AuraEnabled(cacheable=true)
    public static AccountListWrapper searchAccounts(String customerTypeKey, String countryId, String userInputIataCodes, String userInputCompanyName){
        System.debug('customerTypeKey ' + customerTypeKey);
        System.debug('countryId ' + countryId);
        System.debug('userInputIataCodes ' + userInputIataCodes);
        System.debug('userInputCompanyName ' + userInputCompanyName);

        GCS_Customer_Type_For_Registration__mdt customerType = GCS_CustomerType.getCustomerTypesMap().get(customerTypeKey).metadataCustomerType;
        
        String fieldsToRetrieve = '';
        if(customerType.Fields_Displayed__c != '' && customerType.Fields_Displayed__c != null){
            fieldsToRetrieve = ', ' + customerType.Fields_Displayed__c;
        }

        String query = 'SELECT Id, RecordType.DeveloperName, ACLI_Status__c, Status__c ' + fieldsToRetrieve +' FROM Account';
        String filters = '';

        // Filter on Record Type
        if(customerType.Filter_on_Record_Type__c != '' && customerType.Filter_on_Record_Type__c != null){
            if(filters != ''){
                filters += ' AND ';
            }

            List<String> recordTypes = new List<String>();
            for(String recordType : customerType.Filter_on_Record_Type__c.split(',')){
                recordTypes.add('\'' + recordType.trim() + '\'');
            }

            filters += 'RecordType.DeveloperName in (' + String.join(recordTypes, ',') + ')';
        }

        // Filter on Sector
        if(customerType.Filter_on_Sector__c != '' && customerType.Filter_on_Sector__c != null){
            if(filters != ''){
                filters += ' AND ';
            }

            List<String> sectors = new List<String>();
            for(String sector : customerType.Filter_on_Sector__c.split(';')){
                sectors.add('\'' + sector.trim() + '\'');
            }

            filters += 'Sector__c in (' + String.join(sectors, ',') + ')';
        }

        // Filter on Category
        if(customerType.Filter_on_Category__c != '' && customerType.Filter_on_Category__c != null){
            if(filters != ''){
                filters += ' AND ';
            }

            List<String> categories = new List<String>();
            for(String cat : customerType.Filter_on_Category__c.split(';')){
                categories.add('\'' + cat.trim() + '\'');
            }

            filters += 'Category__c in (' + String.join(categories, ',') + ')';
        }

        // Filter on Country
        if(countryId != '' && countryId != null){
            if(filters != ''){
                filters += ' AND ';
            }

            filters += 'IATA_ISO_Country__c = \'' + countryId + '\'';
        }
        
        // Filter on User inputs
        List<String> inputFilters = new List<String>();

        // Filter on Account Name
        if(userInputCompanyName != null && userInputCompanyName != '' && userInputCompanyName.length() >= 3){
            inputFilters.add('Name LIKE  \'%' + userInputCompanyName + '%\'');
        }
        
        // Filter on IATA Codes    
        if(userInputIataCodes != null && userInputIataCodes != '' && userInputIataCodes.length() >= 2){
            //Partial Match
            if(customerType.Fields_Targeted_Partial_Match__c != null){
                for(String targetedField : customerType.Fields_Targeted_Partial_Match__c.split(',')){
                    inputFilters.add(targetedField + ' LIKE  \'%' + userInputIataCodes + '%\'');
                }
            }
    
            // Exact Match
            if(customerType.Fields_Targeted_Exact_Match__c != null){
                GCS_CustomerType customerTypeParent = GCS_CustomerType.getCustomerTypesMap().get(customerType.Parent__c);
                for(String targetedField : customerType.Fields_Targeted_Exact_Match__c.split(',')){
                    //For Travel Agents the code must be of 7 or 8 digits
                    //For Cargo Agents the code must be of 10 or 11 digits
                    if((customerTypeParent.metadataCustomerType.MasterLabel == 'Travel Agent' && ( userInputIataCodes.length() == 7 || userInputIataCodes.length() == 8))
                            || (customerTypeParent.metadataCustomerType.MasterLabel == 'Cargo Agent' && ( userInputIataCodes.length() == 10 || userInputIataCodes.length() == 11 ))){
                        inputFilters.add(targetedField + ' LIKE  \'%' + userInputIataCodes + '%\'');
                    }else{
                        inputFilters.add(targetedField + ' =  \'' + userInputIataCodes + '\'');
                    }
                }
            }
        }

        if(!inputFilters.isEmpty()){
            if(filters != ''){
                filters += ' AND ';
            }

            filters += '(' + String.join(inputFilters, ' OR ') + ')';
        }


        if(filters != ''){
            query += ' WHERE ' + filters;
        }

        System.debug('QUERY : ' + query);

        return new AccountListWrapper(customerTypeKey, Database.query(query));
    }

    public class AccountListWrapper{
        @AuraEnabled
        public List<String> fieldLabels { get; private set; }

        @AuraEnabled
        public List<List<String>> results { get; private set; }

        @AuraEnabled
        public List<String> accountIds { get; private set; }

        @AuraEnabled
        public Integer totalAccounts { get; private set; }
        
        @AuraEnabled
        public List<WrappedResult> wrappedResults { get; private set; }

        

        public AccountListWrapper(String customerTypeKey, List<Account> accounts){
            // Retrieve list of requested fields
            String fieldsToRetrieve = GCS_CustomerType.getCustomerTypesMap().get(customerTypeKey).metadataCustomerType.Fields_Displayed__c;
            List<String> fieldsToRetrieveList = fieldsToRetrieve.split(',');

            // Retrieve the fields Labels
            Map<String,String> accountLabels = GCS_RegistrationController.getAccountLabels();

            List<String> fieldsAPIName = new List<String>();
            fieldLabels = new List<String>();
            for(String field : fieldsToRetrieveList){
                fieldsAPIName.add(field.trim());
                if(field.trim() == 'BillingStreet'){
                    fieldLabels.add(Label.ISSP_Street);
                }
                else{
                    fieldLabels.add(accountLabels.get(field.trim()));
                }
            }
            
            Integer lim = 20;

            results = new List<List<String>>();
            accountIds = new List<String>();
            wrappedResults = new List<WrappedResult>();

            // Store accounts fields values in a List<List<String>>
            // Replace nulls by empty Strings
            for(Integer i = 0; i < lim && i < accounts.size(); i++){
                List<String> result = new List<String>();

                Account acc = accounts[i];
                
                // remove accounts which are not verified
                if((acc.RecordType.DeveloperName == 'IATA_Airline' && acc.ACLI_Status__c == 'Inactive Company')
                    || (acc.RecordType.DeveloperName == 'IATA_Agency' && acc.Status__c == 'Terminated')
                    || (acc.RecordType.DeveloperName == 'IATA_GSA' && acc.Status__c == 'Terminated')){
                    continue;
                }
                
                accountIds.add(acc.Id);

                for(String fieldAPIName : fieldsAPIName){
                    String fieldValue;
                    if(fieldAPIName.contains('.')){
                        List<String> split = fieldAPIName.split('\\.');
                        String relationshipApiName = split[0];
                        String relatedFieldApiName = split[1];
                        fieldValue = (String) acc.getSobject(relationshipApiName).get(relatedFieldApiName);
                    }else if(fieldAPIName == 'IATACode__c'){
                        // Display only last 3 characters of the IATA Code
                        String iataCode = (String) acc.get(fieldAPIName);
                        
                        if(iataCode == null || iataCode.length() <= 3){
                            fieldValue = iataCode;
                        }
                        else{
                            String star = '*';
                            String last3Chars = iataCode.substring(iataCode.length() - 3);
                            fieldValue = star.repeat(iataCode.length() - 3) + last3Chars;
                        }
                    }
                    else{
                        fieldValue = (String) acc.get(fieldAPIName);
                    }

                    if(fieldValue == null){
                        fieldValue = '';
                    }
                    result.add(fieldValue);
                }
                results.add(result);
                
                System.debug('RESULTS: ' + result);
                
                wrappedResults.add(new WrappedResult(acc.Id, acc.Name, result));
            }
            totalAccounts = results.size();
        }
    }

    public class CountryInformation {
        @AuraEnabled
        public Map<Id, IATA_ISO_Country__c> countryMap { get; private set; }

        @AuraEnabled
        public List<IATA_ISO_Country__c> countryList { get; private set; }

        public CountryInformation(List<IATA_ISO_Country__c> countryList){
            this.countryList = countryList;
            this.countryMap = new Map<Id, IATA_ISO_Country__c>(countryList);
        }
    }
    
    public class WrappedResult{
        @AuraEnabled
        public List<String> fields { get; private set; }

        @AuraEnabled
        public String accountId { get; private set; }

        @AuraEnabled
        public String accountName { get; private set; }

        public WrappedResult(String accountId, String accountName, List<String> fields){
            this.accountId = accountId;
            this.accountName = accountName;
            this.fields = fields;
        }
    }
}
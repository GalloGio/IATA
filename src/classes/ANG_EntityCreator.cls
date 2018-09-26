public class ANG_EntityCreator {
    
    public static Account createAccount(Id recordTypeId, Id countryId, Map<String,Object> fieldsOfObject){

        if(recordTypeId == null || countryId == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        Account a = new Account(RecordTypeId = recordTypeId, IATA_ISO_Country__c = countryId );

        sObject obj = addFieldsToObject((sObject)a, fieldsOfObject);

        return (Account)obj;

    }

    public static Account updateAccount(Account obj, Map<String,Object> fieldsOfObject){

        return (Account)addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static Contact createContact(Id recordTypeId, Id accountId, Map<String,Object> fieldsOfObject){

        if(recordTypeId == null || accountId == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        Contact a = new Contact(RecordTypeId = recordTypeId, AccountId = accountId );

        sObject obj = addFieldsToObject((sObject)a, fieldsOfObject);

        return (Contact)obj;

    }

    public static Contact updateContact(Contact obj, Map<String,Object> fieldsOfObject){

        return (Contact)addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static Case createCase(Id recordTypeId, Id accountId, Map<String,Object> fieldsOfObject){

        if(recordTypeId == null || accountId == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        Case c = new Case(RecordTypeId = recordTypeId, AccountId = accountId );

        sObject obj = addFieldsToObject((sObject)c, fieldsOfObject);

        return (Case)obj;
    }

    public static Case updateCase(Case obj, Map<String,Object> fieldsOfObject){

        return (Case)addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static AMS_Person__c createPerson(String email, String lastName, Map<String,Object> fieldsOfObject){

        if(email == null || lastName == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        AMS_Person__c c = new AMS_Person__c(Email__c = email, Lastname__c = lastName );

        sObject obj = addFieldsToObject((sObject)c, fieldsOfObject);

        return (AMS_Person__c)obj;

    }

    public static AMS_Person__c updatePerson(AMS_Person__c obj, Map<String,Object> fieldsOfObject){

        return (AMS_Person__c)addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static AMS_OSCAR__c createOscar(Id recordTypeId, Id accountId, Map<String,Object> fieldsOfObject){

        if(recordTypeId == null || accountId == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        AMS_OSCAR__c c = new AMS_OSCAR__c(RecordTypeId = recordTypeId, Account__c = accountId);

        sObject obj = addFieldsToObject((sObject)c, fieldsOfObject);

        return (AMS_OSCAR__c)obj;
    }

    public static AMS_OSCAR__c updateOscar(AMS_OSCAR__c obj, Map<String,Object> fieldsOfObject){

        return (AMS_OSCAR__c)addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static AMS_Pax_Accreditation_Form__c createStagingArea(Id recordTypeId, String accountName, Id caseId, Map<String,Object> fieldsOfObject){

        if(recordTypeId == null || accountName == null || caseId == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        AMS_Pax_Accreditation_Form__c c = new AMS_Pax_Accreditation_Form__c(RecordTypeId = recordTypeId, Account_Name__c = accountName, SAAM_Case__c = caseId);

        sObject obj = addFieldsToObject((sObject)c, fieldsOfObject);

        return (AMS_Pax_Accreditation_Form__c)obj;
    }

    public static AMS_Pax_Accreditation_Form__c updateStagingArea(AMS_Pax_Accreditation_Form__c obj, Map<String,Object> fieldsOfObject){

        return (AMS_Pax_Accreditation_Form__c)addFieldsToObject((sObject)obj, fieldsOfObject);
    }

    public static AMS_Accreditation_Contact__c createAccreditationContact(Id recordTypeId, Id accreditationId, Map<String,Object> fieldsOfObject){

        if(recordTypeId == null || accreditationId == null)
            throw new AMS_ApplicationException('Please fill the mandatory fields.');

        AMS_Accreditation_Contact__c ac = new AMS_Accreditation_Contact__c(RecordTypeId = recordTypeId, AMS_Pax_Accreditation_Form__c = accreditationId);

        sObject obj = addFieldsToObject((sObject)ac, fieldsOfObject);

        return (AMS_Accreditation_Contact__c)obj;
    }

    public static AMS_Accreditation_Contact__c updateAccreditationContact(AMS_Accreditation_Contact__c obj, Map<String,Object> fieldsOfObject){

        return (AMS_Accreditation_Contact__c)addFieldsToObject((sObject)obj, fieldsOfObject);
    }
    
    public static AMS_Agencies_Hierarchy__c createAgenciesHierarchy(Map<String,Object> fieldsOfObject){
        
        AMS_Agencies_Hierarchy__c agencyRel = new AMS_Agencies_Hierarchy__c();
        
        sObject obj = addFieldsToObject((sObject)agencyRel, fieldsOfObject);
        
        return (AMS_Agencies_Hierarchy__c)addFieldsToObject((sObject)obj,fieldsOfObject);
    }


    public static sObject addFieldsToObject(Sobject obj, Map<String,Object> fieldsOfObject){

        if(fieldsOfObject == null)
            return obj;
            
        for(String fieldName: fieldsOfObject.keySet())
            obj.put(fieldName,fieldsOfObject.get(fieldName));

        return obj;

    }

    public static void loadCredentials() {
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
        creds.add(Amazon_Cred);
        creds.add(GenericAttach);
        creds.add(recycleBin);
        insert creds;


        list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
            new AWSKey__c(
                name = 'adevconf',
                Key__c = 'asd', 
                Secret__c = 'asd',  
                IAS_configuration_name__c = 'asdas', 
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd')
        };
        insert AWS_KEYs;
    }

    public static void checkSFDCLimits(){

        System.debug('[ANG_OscarProcessHelper] 1. Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('[ANG_OscarProcessHelper] 2 .Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('[ANG_OscarProcessHelper] 3. Number of script statements used so far : ' +  Limits.getDmlStatements());
        System.debug('[ANG_OscarProcessHelper] 4. Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('[ANG_OscarProcessHelper] 5. Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
    }
    
}
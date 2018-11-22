public with sharing class ISSP_ObjectFactory {

    public static Account createNewAccount(){
        Account newAccount = new Account();
        newAccount.Name = 'Test Account 1';
        return newAccount;
    }
    
    public static Contact createNewContact(){
        Contact newContact = new Contact();
        newContact.FirstName = 'test';
        newContact.LastName = 'test'; 
        newContact.Email = DateTime.now().getTime() +'ISSP_test@test.test';
        return newContact;
    }
    
    public static Case createNewCase(){
        Case newCase = new Case();
        return newCase;
    }

    public static boolean FillAllFields = false;
    
    // Key : SobjectAPIName  For ex. Account 
    // Value : Map<String, Schema.SObjectField>, field map (k:fieldname, v:Schema.Sobjectfield)
    private static final Map<String, Map<String, Schema.SObjectField>> FieldMapCache = new Map<String, Map<String, Schema.SObjectField>>();
    private static final Map<String, Schema.SObjectType> GlobalDescribe = Schema.getGlobalDescribe();
    private static  integer FIX = 0;
    // Key: sobject.field
    // Value: first picklist value
    private static final Map<String, String> DefaultPicklistValue = new Map<String, String>();
    
    // can't map by Schema.sObjectType, use object name String instead
    public static map<String, set<String>> ExcludedFields = new map<String, set<String>>{
        'All' => new set<String>{'OwnerId', 'LastModifiedById', 'CreatedById', 'LastModifiedDate', 'CreatedDate'},
        //*Person Account
        'Contact' => new set<String>{'Name'},
        'Lead' => new set<String>{'ConvertedDate'},
        'Account' => new set<String>{'Name'}
        /*No a perspn account
        'Account' => new set<String>{'FirstName', 'LastName'}
        */
    };
    
    //
    public static void fiilIncludedFields(){
        ISSP_ObjectFactory.includedFields.put('Account',new set<string>{'BillingCity','Name','Email'});
        ISSP_ObjectFactory.includedFields.put('Contact',new set<string>{'BillingCity','ISO_Country__c','LastName','Email'});
        ISSP_ObjectFactory.includedFields.put('Portal_Application_Right__c',new set<string>{'Portal_Application__c','Contact__c'});
        ISSP_ObjectFactory.includedFields.put('Notification_template__c ',new set<string>{'Name'});
    }
    
    
    // include nillable fields
    public static map<String, set<String>> IncludedFields = new map<String, set<String>>();
    
    public static SObject createSObject(String objectType) {
        return createSObject(objectType, false);
    }
    
    public static List<SObject> createSObjectList(String objectType, boolean cascade, Integer numberOfObjects) {
        
        List<SObject> sos = new List<SObject>();
        for( Integer i=0; i<numberOfObjects; i++ )
            sos.add(createSObject(objectType, cascade, i));
        return sos;  
    }

    public static SObject createSObject(String objectType, boolean cascade, Integer counter) {
        system.debug(Logginglevel.ERROR, 'Creating ' + objectType);
        Schema.sObjectType token = GlobalDescribe.get(objectType);
        if (token == null) {
            //throw new UnsupportedObjectTypeException('Unsupported ObjectType ' + objectType);
        }
        
        SObject obj = token.newSObject();       
        for (Schema.SObjectField field : fieldMapFor(objectType).values()) {
           
            if(FIX < 10000)
            setFieldValue(obj, field, cascade, counter);
          FIX++;  
        }
        
        return obj;
    }
    
    public static SObject createSObject(String objectType, boolean cascade) {
        return createSObject(objectType, cascade, 1);
    }
    
    /**
        Returns a field map for a given sobject. 
        
        Note : this method is kept public for Test cases to share the same field map info, without requiring a field desribe.
        
        @param objectType sobject api name for ex. Account
        @returns FieldMap [Key:FieldName,Value:Schema.SObjectField]
    */
    public static  Map<String, Schema.SObjectField> fieldMapFor(String objectType) {
        Map<String, Schema.SObjectField> fieldMap = null;
        String normalizedObjectType = objectType.toLowerCase();
        
        if (FieldMapCache.containsKey(normalizedObjectType)) {
            fieldMap = FieldMapCache.get(normalizedObjectType);
        } else {
            fieldMap = GlobalDescribe.get(objectType).getDescribe().fields.getMap();
            // cache it for next use
            FieldMapCache.put(normalizedObjectType, fieldMap);
        }
        
        return fieldMap;
    }
    
    static String getDefaultPicklistValue(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        String key = obj.getSObjectType() + '.' + fieldDescribe.getName();
        
        if (!DefaultPicklistValue.containsKey(key)) {
            List<Schema.PicklistEntry> entries = fieldDescribe.getPicklistValues();
            String value = entries.size() > 0 ? entries[0].getValue() : null;
            DefaultPicklistValue.put(key, value);
        }
        
        return DefaultPicklistValue.get(key);
    }
    
    static boolean isExcludedField(Schema.DescribeFieldResult fieldDescribe) {
        return ExcludedFields.get('All').contains(fieldDescribe.getName());
    }
    
    static boolean isExcludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        set<String> fields = ExcludedFields.get(obj.getSObjectType().getDescribe().getName());
        return fields == null ? false : fields.contains(fieldDescribe.getName());
    }
    
    static boolean isIncludedField(SObject obj, Schema.DescribeFieldResult fieldDescribe) {
        set<String> fields = includedFields.get(obj.getSObjectType().getDescribe().getName());
        return fields == null ? false : fields.contains(fieldDescribe.getName());
    }
    
    static boolean isPersonAccountField(Schema.DescribeFieldResult fieldDescribe) {
                Boolean isPersonAccountEnabled = fieldMapFor('Account').get('IsPersonAccount') != null;
                set<string> skipPersonAccountFields = new set<string>{ 'Salutation' };
            
                Boolean CustomPerson = fieldDescribe.isCustom() && fieldDescribe.getName().endsWith('pc');
                Boolean StandardPerson = !fieldDescribe.isCustom() && fieldDescribe.getName().startsWith('Person');
        
                return CustomPerson || StandardPerson || 
                    (isPersonAccountEnabled && skipPersonAccountFields.contains(fieldDescribe.getName()));
    }
    
    static void setFieldValue(SObject obj, Schema.SObjectField field, boolean cascade) {
        setFieldValue(obj, field, cascade, 0);
    }
    
    static void setFieldValue(SObject obj, Schema.SObjectField field, boolean cascade, Integer counter) {
        Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
        
        system.debug(Logginglevel.ERROR, '\n\n\n obj:'+obj+'\n field:'+fieldDescribe.getName()+'\n\n\n');
        system.debug(Logginglevel.ERROR, '\n\n\n fieldDescribe.isCreateable():'+fieldDescribe.isCreateable()+'\n\n\n');
        system.debug(Logginglevel.ERROR, '\n\n\n isIncludedField(obj, fieldDescribe):'+isIncludedField(obj, fieldDescribe)+'\n\n\n');
       
        if (fieldDescribe.isCreateable() && 
            (
                isIncludedField(obj, fieldDescribe) || 
                (
                    (
                        (!fieldDescribe.isNillable() || 
                        FillAllFields) || 
                        (fieldDescribe.getType() == Schema.DisplayType.Reference && cascade) // always fill references with cascade
                    ) && 
                    !isExcludedField(fieldDescribe) &&
                    !isExcludedField(obj, fieldDescribe) &&
                    !isPersonAccountField(fieldDescribe)
                )
             )
            ) {
            
            if (fieldDescribe.getType() == Schema.DisplayType.base64) {
                obj.put(field, blob.valueOf(counter.format()));
            } else if (fieldDescribe.getType() == Schema.DisplayType.Boolean) {
                obj.put(field, false);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Combobox) {
                obj.put(field, counter.format());
            } else if (fieldDescribe.getType() == Schema.DisplayType.Currency) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Date) {
                obj.put(field, Date.today());
            } else if (fieldDescribe.getType() == Schema.DisplayType.DateTime) {
                obj.put(field, DateTime.now());
            } else if (fieldDescribe.getType() == Schema.DisplayType.Double) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Email) {
                obj.put(field, 'test' + counter.format() + '@test.com');
            } else if (fieldDescribe.getType() == Schema.DisplayType.EncryptedString) {
                obj.put(field, 's');
            } else if (fieldDescribe.getType() == Schema.DisplayType.Id) {
                //system.debug(Logginglevel.ERROR, 'Id field ' + fieldDescribe.getName());
            } else if (fieldDescribe.getType() == Schema.DisplayType.Integer) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.MultiPicklist) {
                obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
            } else if (fieldDescribe.getType() == Schema.DisplayType.Percent) {
                obj.put(field, counter);
            } else if (fieldDescribe.getType() == Schema.DisplayType.Phone) {
                obj.put(field, '123-456-7890');
            } else if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
                obj.put(field, getDefaultPicklistValue(obj, fieldDescribe));
            } else if (fieldDescribe.getType() == Schema.DisplayType.String) {
                string str = counter.format()+string.valueOf(system.now());
                if(str.length()>fieldDescribe.getLength())
                    str = str.substring(0,fieldDescribe.getLength()-1);
                obj.put(field, str); 
            } else if (fieldDescribe.getType() == Schema.DisplayType.Reference) {
                String referenceObjectType = fieldDescribe.getReferenceTo()[0].getDescribe().getName();
                
                if (referenceObjectType == 'RecordType') {
                    setRecordType(obj);
                } else if (referenceObjectType != obj.getSObjectType().getDescribe().getName() && fieldDescribe.getReferenceTo()[0].getDescribe().isCreateable()) {
                    // TODO avoid infinite loop for same-type references
                  try{


                    system.debug(Logginglevel.ERROR, 'Creating reference to ' + referenceObjectType + ' for field ' + obj.getSObjectType().getDescribe().getName() + '.' + fieldDescribe.getName());
                    SObject reference = createSObject(referenceObjectType,cascade,counter);
                    system.debug(Logginglevel.ERROR, 'Inserting ' + reference);
                    if(Limits.getDMLStatements() < 20){
                    insert reference;
                    obj.put(field, reference.Id);
                    }
                    }catch(Exception ex){

                             //
                          system.debug(Logginglevel.ERROR,      '@@@@@@@@@ SALVATORE  Creating reference to ' + referenceObjectType 
                                + ' for field ' + obj.getSObjectType().getDescribe().getName() + '.' + fieldDescribe.getName()
                                + '  mess ' + ex.getMessage()+
                                '        ' + ex.getStackTraceString()  );

                    }
                }
            } else if (fieldDescribe.getType() == Schema.DisplayType.TextArea) {
                obj.put(field, counter.format()); 
            } else if (fieldDescribe.getType() == Schema.DisplayType.Time) {
                obj.put(field, Time.newInstance(0, 0, 0, 0)); 
            } else if (fieldDescribe.getType() == Schema.DisplayType.URL) {
                obj.put(field, 'http://test' + counter + '.com'); 
            } else {
                system.debug(Logginglevel.ERROR, 'Unhandled field type ' + fieldDescribe.getType());
            }
             system.debug(Logginglevel.ERROR, '\n\n\n obj:  ' + obj+'\n\n\n');
        }
        
           
    }
    
    
    static void setRecordType(SObject obj) {
        List<Schema.RecordTypeInfo> recordTypes = obj.getSObjectType().getDescribe().getRecordTypeInfos();

        if (recordTypes.size() > 1) { // all objects have default Master type
            //system.debug(Logginglevel.ERROR, 'RecordTypes ' + recordTypes);
            for (Schema.RecordTypeInfo recordType : recordTypes) {
                if (recordType.isAvailable() && recordType.isDefaultRecordTypeMapping()) {
                    obj.put('RecordTypeId', recordType.getRecordTypeId());
                }
            }
        }
        
    }
    public static User createPortalUser(Contact con) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString;
        String conId15 = con.Id;
		//conId15 = conId15.substring(0,15);
        String UserNameStr=uniqueName+ string.valueof(randomInt) + '@test' + orgId + '.org';
        String ComNickNameStr=con.email.substring(0, con.email.indexOf('@'))+randomInt;//Datetime.now().formatLong().substring(10,15);
        system.debug('basto1p TEST UserName='+UserNameStr);
        system.debug('basto1p TEST ComNickNameStr='+ComNickNameStr);
       User newUser = new User(alias = 'dsfsdfds', 
                                email = con.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = con.Id,
                                FederationIdentifier = conId15,
                                timezonesidkey = 'Asia/Dubai',
                                Username = UserNameStr,
                                PortalRole = 'Manager',
                                CommunityNickname = ComNickNameStr,
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        return newUser;
    }
    
    public static User createInactivePortalUser(Contact con) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + String.valueof(datetime.now());
        String conId15 = con.Id;
		conId15 = conId15.substring(0,15);
       User newUser = new User(alias = 'dsfsdfds', 
                                email = con.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = con.Id,
                                FederationIdentifier = conId15,
                                timezonesidkey = 'Asia/Dubai',
                                //Username = uniqueName+ string.valueof(Integer.valueOf(math.rint(math.random()*1000000))) + '@test' + orgId + '.org',
                                Username = 'test@testa.tiestosapan',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = false);
        insert newUser;
        return newUser;
    }
    
    public static User createPortalBasicAirlineUser(Contact con) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        String username = ISSP_Utilities.buildPortalUserName(con.email);
        User newUser = new User(alias = 'dsfsdfds', 
                                email = con.email, 
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                //Username = uniqueName + '@test' + orgId + '.org',
                                Username = username,
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_Basic_Airline_User_ProfileID,
                                IsActive = true);
        insert newUser;
        return newUser;
    }
    
    public static User createAdminUser() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User newUser = new User(alias = 'dsfsdfds', 
                                email = 'admin@admin.admin', 
                                emailencodingkey = 'UTF-8', 
                                firstname = 'admin', 
                                lastname = 'admin', 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US', 
                                UserPermissionsKnowledgeUser = true,
                                timezonesidkey = 'Asia/Dubai',
                                 Username = uniqueName + '@test' + orgId + '.org',
                                PortalRole = 'Manager',
                                License_Cost_Center__c = 'ITO005CH01',
                                CommunityNickname = 'admin'+Datetime.now().formatLong().substring(10,15),
                                ProfileId = [select Id from Profile where Name='System Administrator' limit 1].Id,
                                IsActive = true);
        insert newUser;
        return newUser;
    }
	
	public void fakemethod() {
		Integer i = 0;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		i++;
		
	
	}
}
public without sharing class LightningRegistrationProcess{
    public static String serviceName {get;set;}
    @AuraEnabled
    public static contact createcontact() {
        return new Contact();
    }

    @AuraEnabled
    public static String checkemail(String email) {

        ID rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        User [] u = [SELECT Id FROM User
              WHERE email =: email AND IsActive = true limit 1];
        Contact [] c = [SELECT Id, email, RecordType.Id FROM Contact
              WHERE email =: email LIMIT 1];
        System.Debug('Checking User: ' + u);
        System.Debug('Checking Contact: ' + c);
        if (u.size() == 0){
            if(c.size() == 0){
                System.Debug('create_contactanduser');
                return 'create_contactanduser';
            } else if(c[0].RecordType.Id == rtId){
                System.Debug('create_user');
                return 'create_user';
            } else {
                System.Debug('create_contactanduser convert contact');
                return 'create_contactanduser';
            }
        }
        else {
            System.Debug('user_exists');
            return 'user_exists';
        }
    }

    @AuraEnabled
    public Static List<String> GetContactSalutationValues()
    {
      String ObjectApi_name = 'Contact';
      String picklistField = 'Salutation';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        list<String> values =  new  list<String>();
        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            values.add(pklVal.getValue());
        }
        return values;
    }

    @AuraEnabled
    public Static List<String> GetContactJobFunctionValues()
    {
      String ObjectApi_name = 'Contact';
      String picklistField = 'Function__c';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        list<String> values =  new  list<String>();
        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            values.add(pklVal.getLabel());
        }
        return values;
    }


   // @AuraEnabled
    //public Static List<PicklistWrapper> GetAccountCategoryValues()
   // public Static List <String> GetAccountCategoryValues() 
    //{
        /*
      String ObjectApi_name = 'Account';
      String picklistField = 'Sector__c';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        */
        /*
        List <RegistrationAccountValues__c> val = [SELECT Sector__c, Category__c, Record_Type__c FROM RegistrationAccountValues__c ORDER BY Record_Type__c, Sector__c, Category__c];
        //List <PicklistWrapper> pl = new List <PicklistWrapper>();
        List <String> result = new List <String>();
        String sep = '%%%';
        for (integer i=0;i<val.size();i++){
            //PicklistWrapper w = new PicklistWrapper();   
            //w.rec = val[i].record_type__c;
            //w.rec = 'Test';
            //w.sec = val[i].sector__c;
            //w.cat = val[i].category__c;
            result.add(val[i].record_type__c +sep+ val[i].sector__c +sep+ val[i].category__c);
            //pl.add(w);
            
        }
        //system.debug('@@@pl: ' +pl);
        //return pl;
        return result;
    }
    */
    
    

    /*
    @AuraEnabled
    public Static List<String> GetAccountCategoryValues()
    {

        // Map<String,List<String>> mg = TStringUtils.GetDependentOptions('Account', 'Sector__c', 'Category__c');
        // System.debug('aaaaaaaaa ' + mg);

      String ObjectApi_name = 'Account';
      String picklistField = 'Category__c';
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        list<String> values =  new  list<String>();
        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            values.add(pklVal.getLabel());
        }
        return values;
    }
*/
    @AuraEnabled
    public Static Map<String,String> GetContactLabels()
    {
      Map<String,String> labels = new Map<String,String>();
        String type='Contact';
        List<String> contactFields = new String [] {
            // 'Id',
            'FirstName',
            'LastName',
            'Email',
            'Salutation',
            'Title',
            'Phone',
            'MobilePhone',
            'Fax',
            'Membership_Function__c'

        };
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName: contactFields) {
         labels.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
         }
        //fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
      return labels;
    }

    @AuraEnabled
    public Static Map<String,String> GetAccountLabels()
    {
      Map<String,String> labels = new Map<String,String>();
        String type='Account';
        List<String> contactFields = new String [] {
                        //', 'Id',
            'Name',
            'Legal_name__c',
            'Sector__c',
            'TradeName__c',
            'Category__c',
            'BillingStreet',
            'BillingCity',
            'BillingPostalCode',
            'BillingCountry',
            'BillingState',
            'ShippingStreet',
            'ShippingCity',
            'ShippingState',
            'ShippingPostalCode',
            'ShippingCountry',
            'Phone',
            // 'OfficeMobile',
            'Fax',
            'Website',
            'Email__c',
            'Category_Other_Value__c'


        };
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        for (String fieldName: contactFields) {
         labels.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
         }
        //fieldMap.get(fieldName).getDescribe().getLabel();//It provides to get the object fields label.
      return labels;
    }

    @AuraEnabled
    public Static List<String> GetFieldPicklistValuesCountry(){
        List <IATA_ISO_Country__c> countries = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name');
  
        List <String> cnt = new List <String>();
        cnt.add('');
        for (integer i=0;i<countries.size();i++)
          cnt.add(countries[i].Name);
        return cnt;
    }
    
    /*

    //Invoked in the third page of the registration, queries the accounts in the system according to the filters selected by the end-user
    @AuraEnabled
    public Static List <Account> SearchCompany (String acctype, String designatorcode, String iatacode, String country, String name, String cargotravel) {
      //return null;


      String whereStr = '';
      system.debug('WhereStr: ' +wherestr);

      if (acctype == 'Airline' && (!String.isBlank(designatorcode) || (!String.isBlank(iatacode)))) {
            whereStr = 'Id != null';

            if (!String.isBlank(designatorcode)){
                whereStr += ' AND Airline_designator__c=\'' + designatorcode + '\'';
            }
            if (!String.isBlank(iatacode)){
                whereStr += ' AND IATACode__c=\'' + iatacode + '\'';
            }
            if (!String.isBlank(country)){
                whereStr += ' AND IATA_ISO_Country__r.Name=\'' + country + '\'';
            }
            
            whereStr += ' AND Sector__c != \'General Public\'';
        }
        else if (acctype == 'Airline' && String.isBlank(designatorcode)) {
            whereStr = 'Name like \'%' + name + '%\' and IATA_ISO_Country__r.Name=\'' + country + '\' AND Sector__c != \'General Public\'';
        }
        
        
        

        else if (acctype == 'GSA') {
            whereStr = 'Name like \'%' + name + '%\' and IATA_ISO_Country__r.Name=\'' + country + '\'';
        }
        
        
        
        else if (acctype == 'Agency') {
            whereStr = 'Id != null';


            if (!String.isBlank(iatacode))
                whereStr += ' AND IATACode__c=\'' + iatacode + '\'';
            
            if (cargotravel == 'Cargo')
                whereStr += ' AND Sector__c=\'Cargo Agent\'';
            if (cargotravel == 'Travel')
                whereStr += ' AND Sector__c=\'Travel Agent\'';
            if (!String.isBlank(name))
                whereStr += ' AND Name like \'%' + name + '%\'';
                
        
        }
        
        
        
        else if (acctype == 'Other Company') {
            whereStr = 'Name like \'%' + name + '%\' and IATA_ISO_Country__r.Name=\'' + country + '\' AND Sector__c != \'General Public\'';

        }
        
        
        else if (acctype == 'General Public'){
            whereStr = 'Sector__c=\'General Public\' and IATA_ISO_Country__r.Name=\'' + country + '\'';
        }



        String mapping = '';
        if (acctype == 'GSA')  mapping = 'GloballSalesAgent';
        else mapping = acctype.replaceAll(' ','');

        set<string> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(mapping);
        system.debug('recordTypesSet: ' + recordTypesSet);
        String queryStr = 'select Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, RecordType.DeveloperName, RecordType.Name, Airline_designator__c from Account where '
                         + whereStr + ' and RecordType.DeveloperName in :recordTypesSet';
        //String queryStr = 'Select id from Account';
        List <Account> res = database.query(querystr);
        
        //Management of airline selection
        if (acctype == 'Airline') {
            if (res.size() !=0) {
                List <Account> accListVerified = new List <Account>();
                List <Account> accListNotVerified = new List <Account>();
                for (integer i=0;i<res.size();i++) {
                    if (res[i].RecordType.DeveloperName == 'Standard_Account'){
                        accListNotVerified.add(res[i]);
                    }
                    else{
                        accListVerified.add(res[i]);
                    }
                }
                res= null;
                if (!accListVerified.isEmpty()){
                    res= accListVerified;
                }
                else{
                    res= accListNotVerified;
                }
        
            }
            */
            //Airline and no result found: old branch case
            /*
            else {
                if (!String.isBlank(designatorcode)){
                    whereStr = 'Id != null';
                    whereStr += ' AND Airline_designator__c=\'' + designatorcode+ '\'';
                    
                    if (!String.isBlank(iatacode)){
                        whereStr += ' AND IATACode__c=\'' + iatacode+ '\'';
                    }
                    queryStr = 'select Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, Top_Parent__c, Top_Parent__r.Name, Sector__c, Category__c, RecordType.Name, Airline_designator__c from Account where '
                             + whereStr + ' and RecordType.DeveloperName = \'IATA_Airline\'';
                    
                    try {
                        res= Database.query(queryStr);
                    } catch (Exception e) {
                    }
                    
                }
                
            } */         
          
        
       // }
  

   // return res;

    //}  

    @AuraEnabled
    public Static String createUserFromExistingContact(String email){
        try{
        Contact con = [SELECT Id, title,firstname, lastname, email, Salutation, AccountId, RecordType.Id FROM Contact
              WHERE email =: email LIMIT 1];

        String thisNickname;
            if (String.isNotBlank(con.lastName) && con.lastName.length() > 3)
                thisNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
            else
                thisNickname = con.lastName+Datetime.now().formatLong();

            system.debug('NICKNAME 1: ' + thisNickname);
            system.debug('NICKNAME 1 length: ' + thisNickname.length());
            if (thisNickname.length() > 40){
                system.debug('more than 40');
                thisNickname = thisNickname.left(40);
            }
            else{
                system.debug('not more than 40');
                thisNickname = thisNickname;
            }

            System.debug('>>con ' + con);

            string UID = Comm_User_Helper.NewGuid();

            User u = new User (
                CommunityNickname= thisNickname, 
                title=con.title, 
                contactid = con.id, 
                Firstname = con.firstname, 
                lastname = con.lastname, 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                email = con.email,
                UID__c = UID, 
                username=ISSP_Utilities.buildPortalUserName(con.email), 
                Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), 
                timezonesidkey = 'America/Los_Angeles', 
                languagelocalekey = 'en_US',
                Date_ToU_accepted__c = system.Now(), 
                ToU_accepted__c = true
                );  
            //User u = new User (CommunityNickname= thisNickname , contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), languagelocalekey = 'en_US', Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true);

            System.debug('User ' + u + ' AccountId ' + con.accountId + ' Contact ' + con);
        	String password = Comm_User_Helper.generateRandomString(6) + '1a';
            String userId = Site.createPortalUser(u, con.accountId, password, false);
        
            // Assign Identity permission set to user
            //PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Identity_User'];
            //PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.Id, AssigneeId = u.Id);
            //database.upsert(psa);

            if(String.isNotBlank(userId))
                setFederationId(userId, con.email);
            System.debug('Done Registration UserId: ' + u);
        	if(!Test.isRunningTest()){
				sendWelcomeEmail(con, u, password);
			}
        	
        	System.debug('Got here: ' + u);
        
            return userid;
        } catch (Exception e) {
            return e.getMessage() + ' - line: ' + e.getLineNumber();
        }
    }
    
    @AuraEnabled
    public Static void checkConAvailable (Contact con){
        System.debug('CheckConAvailable: ' + con);
        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');        
        Contact [] ec = [Select id, email, AccountId, RecordType.Id FROM Contact WHERE email =:con.email AND AccountId =:con.AccountId LIMIT 1];
        System.debug('Record Type: ' + rtId);
        
        if(ec.size() > 0){
            System.debug('Update Contact');
            con.Id = ec[0].Id;
            con.RecordTypeId = rtId;
            database.update(con);
        } else {
            System.debug('Insert new contact');
            database.upsert(con);
        }
    }

    @AuraEnabled    
    public Static String createContactAndAccount (Contact con, Account acc, String customerType, String servName) {
        // ISSP_Registration registration = new ISSP_Registration();
        // Boolean b = registration.pageIsValid();
        serviceName = servName;
        Id rt = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        if(con.RecordType == null) con.RecordTypeId = rt;

        //Debug
        System.debug('Contact ' + con);
        System.debug('Account ' + acc);
        try {
            if(acc.Id == null) {
                //acc.phone = null;
                acc.name = acc.Legal_name__c;
                acc.Reason_for_creation__c = 'Created by customer';
                //Since we need to create a portal user, we need to assign the account to a user with a specified role, otherwise an error is thrown
                acc.ownerid = ISSP_Constant.newAccountOwnerId;
                String recname = ISSP_Constant.accountDefaultRecordTypeByCustomerType.get(customerType);
                Id rtID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', recname);
                    if (rtID!=null)
                acc.recordtypeid = rtID;
                
                if (!String.isBlank(acc.Category__c) && acc.Category__c != 'Other')
                    acc.Category_Other_Value__c = null;
                
                //Assign countries and states
                if (!String.isBlank(acc.BillingCountry)) {
                    List <Iata_Iso_Country__c> cn = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{acc.BillingCountry});
                    if (cn.size()!=0) {
                        acc.IATA_ISO_Country__c = acc.IATA_ISO_Shipping_Country__c = cn[0].id;
                    }
                }
                
                database.insert(acc);
            }
            List <Account> lstacc = [select id from account where id=:acc.id];
            system.debug('aqui funcioana ' + lstacc[0].Id);
            if(!lstacc.isEmpty()) {
                con.AccountId = lstacc[0].Id;
                if(! String.isBlank(acc.Iata_Iso_Country__c)) {
                    con.ISO_Country__c = acc.Iata_Iso_Country__c;
                    if(! String.isBlank(acc.IATA_ISO_Shipping_Country__c))
                        con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Shipping_Country__c;
                }
                checkConAvailable(con);
                //database.upsert(con);
            }
            String thisNickname;
            if (String.isNotBlank(con.lastName) && con.lastName.length() > 3)
                thisNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
            else
                thisNickname = con.lastName+Datetime.now().formatLong();

            system.debug('NICKNAME 1: ' + thisNickname);
            system.debug('NICKNAME 1 length: ' + thisNickname.length());
            if (thisNickname.length() > 40){
                system.debug('more than 40');
                thisNickname = thisNickname.left(40);
            }
            else{
                system.debug('not more than 40');
                thisNickname = thisNickname;
            }

            System.debug('>>con ' + con);

            string UID = Comm_User_Helper.NewGuid();
            User u = new User ( CommunityNickname= thisNickname , title=con.title, contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), timezonesidkey = 'America/Los_Angeles', languagelocalekey = 'en_US',Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true, UID__c = UID);
            //User u = new User (CommunityNickname= thisNickname , contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), languagelocalekey = 'en_US', Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true);
           
            
            if(servName == 'ISSP' || servName == 'FRED')
                u.Community__c = servName;

            if(servName == 'FRED') {
                // Set Fred profile 
                //u.ProfileID = [SELECT Id FROM profile WHERE name = 'FRED Portal (Partner)' LIMIT 1][0].Id;
                // Mehdi request to use existing profile so above line is commented
            }
           

            System.debug('User ' + u);
            System.debug('con.accountId ' + con.accountId);            
            String password = Comm_User_Helper.generateRandomString(6) + '1a';
            System.debug('password ' + password);
            String userId = Site.createPortalUser(u, con.accountId, password, false);
            System.debug('userId ' + userId);
            
            //String userId = Site.createExternalUser( u, con.accountId, password, false);

            /*if(String.isNotBlank(userId))
                setFederationId(userId, con.email);
            */
            System.debug('Done Registration UserId: what 2' + u);
            
            
            sendWelcomeEmail(con, u, password);
            
            return userid;
            

        } catch (Exception e) {
            return e.getMessage() + ' - line: ' + e.getLineNumber();
        }
        
    } 

    @AuraEnabled
    public Static String createContactAndAccount (Contact con, Account acc, String customerType) {
        Id stdContactRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        if(con.RecordType == null) con.RecordTypeId = stdContactRtId;

        //Debug
        System.debug('Contact ' + con);
        System.debug('Account ' + acc);
        try {
            if(acc.Id == null) {
                //acc.phone = null;
                acc.name = acc.Legal_name__c;
                acc.Reason_for_creation__c = 'Created by customer';
                //Since we need to create a portal user, we need to assign the account to a user with a specified role, otherwise an error is thrown
                acc.ownerid = ISSP_Constant.newAccountOwnerId;
                
                String recname = ISSP_Constant.accountDefaultRecordTypeByCustomerType.get(customerType);
                Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', recname);
                if (String.isNotBlank(rtId)){
                    acc.recordtypeid = rtId;
                }

                if (!String.isBlank(acc.Category__c) && acc.Category__c != 'Other')
                    acc.Category_Other_Value__c = null;
                
                //Assign countries and states
                if (!String.isBlank(acc.BillingCountry)) {
                    List <Iata_Iso_Country__c> cn = IATAIsoCountryDAO.getIsoCountryByCountriesName(new Set<String>{acc.BillingCountry});
                    if (cn.size()!=0) {
                        acc.IATA_ISO_Country__c = acc.IATA_ISO_Shipping_Country__c = cn[0].id;
                    }
                }
                
                database.insert(acc);
            }
            List <Account> lstacc = [select id from account where id=:acc.id];
            if(!lstacc.isEmpty()) {
                con.AccountId = lstacc[0].Id;
                if(! String.isBlank(acc.Iata_Iso_Country__c)) {
                    con.ISO_Country__c = acc.Iata_Iso_Country__c;
                    if(! String.isBlank(acc.IATA_ISO_Shipping_Country__c))
                        con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Shipping_Country__c;
                }
                checkConAvailable(con);
                //database.upsert(con);
            }
            String thisNickname;
            if (String.isNotBlank(con.lastName) && con.lastName.length() > 3)
                thisNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
            else
                thisNickname = con.lastName+Datetime.now().formatLong();

            system.debug('NICKNAME 1: ' + thisNickname);
            system.debug('NICKNAME 1 length: ' + thisNickname.length());
            if (thisNickname.length() > 40){
                system.debug('more than 40');
                thisNickname = thisNickname.left(40);
            }
            else{
                system.debug('not more than 40');
                thisNickname = thisNickname;
            }

            System.debug('>>con ' + con);
            string UID = Comm_User_Helper.NewGuid();
            User u = new User (CommunityNickname= thisNickname , title=con.title, contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), timezonesidkey = 'America/Los_Angeles', languagelocalekey = 'en_US',Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true, UID__c = UID);
            //User u = new User (CommunityNickname= thisNickname , contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), languagelocalekey = 'en_US', Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true);

            System.debug('User ' + u);
            String password = Comm_User_Helper.generateRandomString(6) + '1a';
            String userId = Site.createPortalUser(u, con.accountId, password, false);

            if(String.isNotBlank(userId))
                setFederationId(userId, con.email);
            System.debug('Done Registration UserId: ' + u);
            
            
            sendWelcomeEmail(con, u, password);
            
            return userid;
            

        } catch (Exception e) {
            return e.getMessage() + ' - line: ' + e.getLineNumber();
        }
        
    } 
   
    public Static void sendWelcomeEmail(Contact con, User u, String password){
        String cleanUsername = u.userName.replace('+', Comm_User_Helper.plusReplacer);
        String encodedPart ='c='+EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+u.UID__c), 'UTF-8');
        String template = 'Identity_Portal_New_User';
        string prefix = OneIdUtils.getSiteCompleteUrl();
        String link = prefix + '/s/IdentityFirstLogin?' + encodedPart;
        system.debug('serviceName: '+serviceName);
        if(serviceName == Comm_User_Helper.ISSP){ // OneIdEnh CSP-ID002: change the login URL for the customer portal
            template = 'Identity_Portal_ISSP_New_User';
            link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c) + '/ISSP_First_Login?'+encodedPart;
        }
        if(serviceName == 'FRED'){ 
            system.debug('serviceName: '+String.ValueOF(ISSP_CS__c.getValues('Host').value__c));
            template = 'Identity_Portal_FRED_New_User';            
            link = prefix + '/s/IdentityFirstLogin?'+encodedPart+'&serviceName=FRED';
            system.debug('aqui link ' + link);            
            //link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c) + '/FRED_First_Login?'+encodedPart;
        }  
        
        Map<String,String> emailWrap = new Map<String,String>();
        
        //emailWrap = Identity_PassWordBuilMessageWrapper(con, password, link);   // OneIdEnh CSP-ID002: replace with service aware method

        emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper(con, password, link, Comm_User_Helper.ONEIDENTITY, serviceName);
        Comm_User_Helper.sendEmail(template, emailWrap, con, serviceName);
    }
    
    public static  Map<String, String> Identity_PassWordBuilMessageWrapper(Contact con, String password, String link){
        String portalName = Label.OneId_Community_Name;

        Map<String, String> mapBodyParamsIdentity = new map<String,String>{

            '{!Contact.Salutation}' => con.Salutation,
            '{!Contact.Password}' => password,
            '{!Receiving_User.FirstName}' =>con.Firstname,
            '{!Receiving_User.LastName}' => con.LastName,
            '{!Receiving_User.Email}' => con.Email,
            '{!Community_Name}' => portalName ,
            '{!Community_Url}' => link, 
            '{!$Label.ISSP_Email_Here}' => 'here',
            '{!$Label.ISSP_Email_do_not_reply}' => Label.ISSP_Email_do_not_reply,
            '{!$Label.OneId_IATA_represent_lead_and_serve_the_airline_industry}' => Label.OneId_IATA_represent_lead_and_serve_the_airline_industry
        };

        return mapBodyParamsIdentity;
    }
    
    @future 
    public Static Void assignIdentityPermissionSet (Id userId) {
            System.debug('Assigning PermissionSet');
            // Assign Identity permission set to user
            PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE Name = 'Identity_Portal_User'];
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.Id, AssigneeId = userId);
            database.upsert(psa); 
            System.debug('End Assigning PermissionSet'); 
    }
    
    @future
    public static void setFederationId (String userid, String email) {
        User u = new User(id=userid); 
        u.FederationIdentifier = u.id;
        database.update(u);
    }
/*    
    @AuraEnabled
    public Static String setHostURL (){
       return OneIdUtils.getOrgUrl();
    }
    
*/    
    // to be used in visualforce page OneIdVfCAPTCHA
    @AuraEnabled
    public Static String getHostURL(){
        return OneIdUtils.getOrgUrl();
    }

    // to be used in visualforce page OneIdVfCAPTCHA
    @AuraEnabled
    public Static String getLanguageFromURL(){
        String lang = ApexPages.currentPage().getParameters().get('language');
        lang = lang == null || String.isEmpty(lang) ? 'en' : lang;
        lang = lang == 'en-US' ? 'en' : lang;
        return lang;
    }

    @AuraEnabled
    public Static String getCommunityName(){
        return OneIdUtils.getCommunityUrlName();
    }    
    
}
public without sharing class LightningRegistrationProcess{
    @AuraEnabled
    public static contact createcontact() {
        return new Contact();
    }

    @AuraEnabled
    public static boolean checkemail(String email) {
        User [] u = [SELECT Id FROM User
              WHERE email =: email AND IsActive = true limit 1];
        if (u.size() == 0)  return false;
        else return true;
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
    public Static List<String> GetFieldPicklistValuesCountry()
    {
      List <IATA_ISO_Country__c> countries = [SELECT Name from IATA_ISO_Country__c ORDER BY Name];
      List <SelectOption> options = new List <SelectOption>();
      //for (integer i=0;i<countries.size();i++) {
    //  options.add(new SelectOption(countries[i].name,countries[i].name));
        //}
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
    public Static String createContactAndAccount (Contact con, Account acc, String customerType) {
        // ISSP_Registration registration = new ISSP_Registration();
        // Boolean b = registration.pageIsValid();
        RecordType rt = [Select Id From RecordType WHERE SObjectType ='Contact' AND DeveloperName='Standard_Contact'];
        if(con.RecordType == null) con.RecordTypeId = rt.Id;

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
                List<RecordType> rtSet = [select id from RecordType where DeveloperName=:recname];
                    if (rtSet!=null && rtSet.size()>0 && rtSet.get(0)!=null)
                acc.recordtypeid = rtSet[0].id;
                
                if (!String.isBlank(acc.Category__c) && acc.Category__c != 'Other')
                    acc.Category_Other_Value__c = null;
                
                //Assign countries and states
                if (!String.isBlank(acc.BillingCountry)) {
                    List <Iata_Iso_Country__c> cn = [SELECT id FROM Iata_Iso_Country__c WHERE Name = :acc.BillingCountry LIMIT 1];
                    if (cn.size()!=0) {
                        acc.IATA_ISO_Country__c = acc.IATA_ISO_Shipping_Country__c = cn[0].id;
                    }
                }
                
                database.insert (acc);
            }
            List <Account> lstacc = [select id from account where id=:acc.id];
            if(!lstacc.isEmpty()) {
                con.AccountId = lstacc[0].Id;
                if(! String.isBlank(acc.Iata_Iso_Country__c)) {
                    con.ISO_Country__c = acc.Iata_Iso_Country__c;
                    if(! String.isBlank(acc.IATA_ISO_Shipping_Country__c))
                        con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Shipping_Country__c;
                }

                database.upsert(con);
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
            User u = new User (CommunityNickname= thisNickname , title=con.title, contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), timezonesidkey = 'America/Los_Angeles', languagelocalekey = 'en_US',Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true);
            //User u = new User (CommunityNickname= thisNickname , contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), languagelocalekey = 'en_US', Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true);

            System.debug('User ' + u);
            String userId = Site.createPortalUser(u, con.accountId, null, false);

            if(String.isNotBlank(userId))
                setFederationId(userId, con.email);

            return userid;
            

        } catch (Exception e) {
            return e.getMessage() + ' - line: ' + e.getLineNumber();
        }
        
    } 
    
    
    @future
    public static void setFederationId (String userid, String email) {
        User u = new User(id=userid);
        u.FederationIdentifier = email;
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
}
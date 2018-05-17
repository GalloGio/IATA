public without sharing class OneId_Fred_AccountSelection_CTRL {
	private static final string Airline = 'Airline';
    private static final string Agency = 'Agency';
    private static final string GSA = 'GloballSalesAgent';
    private static final string TIESS = 'TIESS';
    private static final string NonIATA = 'NonIATAAgent';
    private static final string OtherCompany = 'OtherCompany';
    private static final string GeneralPublic = 'GeneralPublic';

    @AuraEnabled
    public static boolean registration(Account acc, Contact con, String selectedCustomerType) {
        System.debug('SMH register');
        System.debug('SMH acc '+acc);
        System.debug('SMH con '+con);

        //TODO: Get service name
        String serviceName = 'FRED';

        // TODO: Get language from URL / Browser
        String languageString = 'English';

       // Existing account selected => Create contact
        if(acc != null) {
            // Define account base on account information
            con.AccountId = acc.Id;
            con.ISO_Country__c = acc.IATA_ISO_Country__c;
            con.IATA_ISO_Shipping_Country__c = acc.IATA_ISO_Country__c;
            con.Country__c = acc.IATA_ISO_Country__c;
            con.Preferred_Language__c = languageString;
            con.IATA_ISO_Billing_State__c = acc.IATA_ISO_Billing_State__c;
            con.IATA_ISO_Shipping_State__c = acc.IATA_ISO_Shipping_State__c;

            // Define account fields
            acc.Legal_name__c = acc.Name;

            // Define field specific to services
            if(serviceName == 'ISSP'){
                con.User_Portal_Status__c ='Pending Approval';
                con.Community__c = 'ISS Customer Portal';
            }

            if(serviceName == 'FRED'){
                con.User_Portal_Status__c ='Pending Approval';
                con.Community__c = 'FRED Customer Portal';
            }
            
            Savepoint sp = Database.setSavepoint();
            try {
              
                String returnedString = LightningRegistrationProcess.createContactAndAccount(con,acc,selectedCustomerType,serviceName);
                //String returnedString = createSecondary(con,acc,selectedCustomerType,serviceName);



                System.debug('@SMH'+returnedString);
                if (returnedString.contains('line:')){
                    // Error during creation of contact and user
                    Database.rollback(sp);
                    return false;
                } else {
                    /*
                    if(serviceName == 'ISSP'){
                        permissionCSPortal(returnedString); // assign Permission Set CS Portal, give access to CS Portal Connected App
                    }
                    if(serviceName == 'ISSP' && isNewAcc == true){
                        permissionNewAgency(returnedString);                    
                        portalServiceNewAgency(con.Id);
                        updatePortalUseProfile(returnedString);
                    }
                    */

                    if(serviceName == 'FRED'){
                        permissionCSPortal(returnedString); // assign Permission Set CS Portal, give access to CS Portal Connected App
                    }
                }
                

            } catch(exception ex){
                Database.rollback(sp);
                System.debug(ex);
                return false;
            }
        }
       return true;
    }


    public static String createSecondary(Contact con, Account acc, String customerType, String servName) {
        String serviceName = servName;
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
           
            if(servName == 'FRED') {
                // JIRA ISI-51 + ISI-14: Self registration primary or secondary 
                String profileID = '';
                list<Profile> fredProfiles = [SELECT Id FROM profile WHERE name like '%Fred%' ORDER BY Name];
                // Check if primary user exists on request account
                list<User> primaryUsers = [SELECT ProfileId FROM User WHERE Contact.AccountId =: con.accountId AND Profile_Name__c like '%Primary%'];
                if(primaryUsers.isEmpty()) {
                   // Create primary as primary exists yet
                   profileID = fredProfiles[0].Id;
                } else {
                    // Create secondary as primary exists
                    profileID = fredProfiles[1].Id;
                }
                u.ProfileID = profileID;
            }

            
            if(servName == 'ISSP' || servName == 'FRED')
                u.Community__c = servName;
           

            System.debug('User ' + u);
            String password = Comm_User_Helper.generateRandomString(6) + '1a';
            

            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail= false;
            Database.saveresult sr = Database.insert(u,dlo);

            String userId = u.Id;
            return userId;
            } catch (Exception e) {
            return e.getMessage() + ' - line: ' + e.getLineNumber();
        }
            
    }

     @AuraEnabled
    public Static void checkConAvailable (Contact con){
        System.debug('CheckConAvailable: ' + con);
        RecordType rt = [Select Id From RecordType WHERE SObjectType ='Contact' AND DeveloperName='Standard_Contact'];        
        Contact [] ec = [Select id, email, AccountId, RecordType.Id FROM Contact WHERE email =:con.email AND AccountId =:con.AccountId LIMIT 1];
        System.debug('Record Type: ' + rt);
        
        if(ec.size() > 0){
            System.debug('Update Contact');
            con.Id = ec[0].Id;
            con.RecordTypeId = rt.Id;
            database.update(con);
        } else {
            System.debug('Insert new contact');
            database.upsert(con);
        }
    }

    @Future
    public static void permissionCSPortal(String userId){
        if (userId != null && userId != '') {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FRED_Provisioning' LIMIT 1];
            if(ps != null){
                PermissionSetAssignment newAssignCS = new PermissionSetAssignment();
                newAssignCS.AssigneeId = userId;
                newAssignCS.PermissionSetId = ps.Id;
                insert newAssignCS;
            }
        }
    }

    @Future
    public static void permissionNewAgency(String userId){
        if (userId != null && userId != '') {
            List <PermissionSet> permList = [SELECT Id FROM PermissionSet WHERE Name = 'ISSP_New_Agency_permission_set'];            
            if (!permList.isEmpty()){
                PermissionSetAssignment newAssign = new PermissionSetAssignment();
                newAssign.AssigneeId = userId;
                newAssign.PermissionSetId = permList[0].Id;
                insert newAssign;
            }
        }
    }


    public class SearchWrap {
        @AuraEnabled
        public list<Account> accList {get; set;}
        @AuraEnabled
        public Integer totalAccListNotLimited {get; set;}
        /*
        @AuraEnabled
        public Account HQAccount {get; set;}
        @AuraEnabled
        public Account acc {get; set;}
        @AuraEnabled
        public String msg {get; set;}
        @AuraEnabled
        public String buttonLabel {get; set;}
        @AuraEnabled
        public Boolean accountFound {get; set;}
        @AuraEnabled
        public Boolean showCreateAccount {get; set;}
        @AuraEnabled
        public Boolean showcreateother {get; set;}
        */
    }

    @AuraEnabled
    public static Account getPartnerAccount() {
        User u = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()];
        if(u.AccountId != null)
            return [SELECT RecordType.DeveloperName,  RecordType.Name, Id, Name, IATACode__c,ICAO_designator__c,Airline_designator__c, ICAO_Member__r.State_Name__c, ICAO_Member__r.ICAO_Iso_2_Code__c, ICAO_Member__r.ICAO_Iso_3_Code__c, State_Name__c,ICAO_Iso_2_Code__c,ICAO_Iso_3_Code__c FROM Account WHERE Id =: u.AccountId LIMIT 1];
        return null;
    }

    
    @AuraEnabled
    public static SearchWrap getAccountsByType(String customerType, String userInput) {
        system.debug(customerType+' => '+userInput);
        SearchWrap sw = new SearchWrap();

        String recordTypeSearch = customerType;

        set<string> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(recordTypeSearch);

        String queryStr = 'SELECT Id,IATACode__c,Airline_designator__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry FROM Account WHERE ';
        queryStr += ' RecordType.DeveloperName in :recordTypesSet';
        queryStr += ' AND Name like \'%' + userInput + '%\'';

        if(customerType=='Aircraft Operator') {
            queryStr = 'SELECT Id, Name, IATACode__c,ICAO_designator__c,Airline_designator__c, ICAO_Member__r.State_Name__c, ICAO_Member__r.ICAO_Iso_2_Code__c, ICAO_Member__r.ICAO_Iso_3_Code__c ';
            String queryStr2 = ' FROM Account WHERE';
            queryStr2 += ' RecordType.DeveloperName = \'IATA_Airline\'';
            queryStr2 += ' AND (Name like \'%' + userInput + '%\'';
            queryStr2 += ' OR Airline_designator__c like \'%' + userInput + '%\'';
            queryStr2 += ' OR ICAO_Member__r.State_Name__c like \'%' + userInput + '%\'';
            queryStr2 += ' OR ICAO_Member__r.ICAO_Iso_3_Code__c like \'%' + userInput + '%\')';
            
            sw.totalAccListNotLimited = Database.countQuery('select count()'+queryStr2);

            queryStr += queryStr2;
            queryStr += ' LIMIT '+Label.OneId_AccountSearch_Limit; // Default limit is 20
        }

        if(customerType=='ICAO Member State') {
            queryStr = 'SELECT Id, State_Name__c,ICAO_Iso_2_Code__c,ICAO_Iso_3_Code__c ';
            String queryStr2 = ' FROM Account WHERE';
            queryStr2 += ' RecordType.DeveloperName = \'ICAO_Member_State\'';
            queryStr2 += ' AND (State_Name__c like \'%' + userInput + '%\'';
            queryStr2 += ' OR ICAO_Iso_2_Code__c like \'%' + userInput + '%\'';
            queryStr2 += ' OR ICAO_Iso_3_Code__c like \'%' + userInput + '%\')';
            
            sw.totalAccListNotLimited = Database.countQuery('select count()'+queryStr2);

            queryStr += queryStr2;
            queryStr += ' LIMIT '+Label.OneId_AccountSearch_Limit; // Default limit is 20
        }


        
        
       
        list<Account> accs = new list<Account>();
        accs = Database.query(queryStr);
        system.debug(accs);
        sw.accList = accs;
        return sw;
    }

	@AuraEnabled
    public static SearchWrapper searchAccount(String customerType, String countryID, map<String, String> filters) {
        SearchWrapper sw = new SearchWrapper();

        system.debug('filters'+filters);

        // Record types definition
        String recordTypeSearch = customerType;
        if(customerType == Agency && filters.containsKey('hasIATACode') && filters.get('hasIATACode') == 'false')
            recordTypeSearch = NonIATA;
        set<string> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(recordTypeSearch);

        // Query + filters
        String queryStr = 'SELECT Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, RecordType.DeveloperName, RecordType.Name, Airline_designator__c FROM Account WHERE ';
        queryStr += ' RecordType.DeveloperName in :recordTypesSet';
        if(customerType != Agency)
            queryStr += ' AND IATA_ISO_Country__c = :countryID';
        if(customerType == Airline) {
            if(Boolean.valueOf(filters.get('hasDesignatorCode'))) {
                if(filters.containsKey('designatorCode') &&  String.isNotBlank(filters.get('designatorCode'))) {
                     queryStr += ' AND Airline_designator__c=\''+filters.get('designatorCode')+'\''; 
                }
                if(filters.containsKey('iataCode') && String.isNotBlank(filters.get('iataCode'))) {
                     queryStr += ' AND (IATACode__c=\''+filters.get('iataCode')+'\' OR Airline_Prefix__c=\''+filters.get('iataCode')+'\')'; 
                }
            } else {
                queryStr += ' AND Name LIKE \'%'+filters.get('accountName')+'%\'';
                queryStr += ' AND Sector__c != \'General Public\'';
            }
        } else if(customerType == GSA) {
            queryStr += ' AND Name like \'%' + filters.get('accountName') + '%\'';
        } else if(customerType == Agency && filters.containsKey('hasIATACode') && filters.get('hasIATACode') == 'true'){
            queryStr += ' AND (IATACode__c=\''+filters.get('iataCode')+'\' OR Airline_Prefix__c=\''+filters.get('iataCode')+'\')'; 
        } else if(customerType == OtherCompany || (customerType == Agency && filters.containsKey('hasIATACode') && filters.get('hasIATACode') == 'false')) {
            queryStr += ' AND Name like \'%' + filters.get('accountName') + '%\' AND Sector__c != \'General Public\'';
        } else if(customerType == GeneralPublic) {
            queryStr += ' AND Sector__c=\'General Public\'';
        } else    // unknown type
            return null;

        system.debug('queryStr: '+queryStr);
        list<Account> accList = new list<Account>();
        try {
            accList = Database.query(queryStr);
            system.debug(accList);
            sw.accountFound = !accList.isEmpty();
            
            //If other company add another option (to create new account)
            if (customerType == OtherCompany && sw.accountFound) {
                Account dummy = accList[accList.size()-1].clone(false,true);
                dummy.Name = Label.ISSP_Create_New_Other_Account;
                dummy.IATACode__c = 'Create New Account';
                sw.acc = new Account(Name=filters.get('accountName'));
                accList.add(dummy);
                sw.showcreateother = true;
            } //else
               // showcreateother = false;

        } catch (Exception e) {
            return null;
        }

        if(customerType == Airline) {
            if(! accList.isEmpty()) {
                List <Account> accListVerified = new List <Account>();
                List <Account> accListNotVerified = new List <Account>();
                for (Account thisAccount : accList){
                    if (thisAccount.RecordType.DeveloperName == 'Standard_Account'){
                        accListNotVerified.add(thisAccount);
                    }
                    else{
                        accListVerified.add(thisAccount);
                    }
                }
                accList = null;
                if (!accListVerified.isEmpty()){
                    accList = accListVerified;
                }
                else{
                    accList = accListNotVerified;
                }
                sw.accList = accList;
                
            } else {
                system.debug('filters: ' + filters);
                 if (filters.containsKey('hasDesignatorCode') && filters.get('hasDesignatorCode')== 'true') {
                    queryStr = 'SELECT Id,IATACode__c,Field_Head_Office__c,Name,BillingStreet,BillingCity,BillingCountry, IATA_ISO_Country__r.Name, Top_Parent__c, Top_Parent__r.Name, Sector__c, Category__c, RecordType.Name, Airline_designator__c FROM Account WHERE ';
                    queryStr += 'RecordType.DeveloperName = \'IATA_Airline\'';
                    if (filters.containsKey('designatorCode') && String.isNotBlank(filters.get('designatorCode')))
                        queryStr += ' AND Airline_designator__c=\'' + filters.get('designatorCode') + '\'';
                    if (filters.containsKey('iataCode') && String.isNotBlank(filters.get('iataCode')) ){
                        queryStr += ' AND (IATACode__c=\'' + filters.get('iataCode') + '\' OR Airline_Prefix__c=\'' + filters.get('iataCode') + '\')';
                    }
                    system.debug('queryStr2: ' + queryStr);
                    try {
                        accList = Database.query(queryStr);
                    } catch (Exception e) {
                         system.debug(e);

                    }
                    if (!accList.isEmpty()){
                            Account acc = new Account();
                            sw.HQAccount = accList[0];
                            sw.msg = Label.ISSP_NoRecordsFoundBranch;
                            sw.buttonLabel = Label.ISSP_Create_New_Airline_Branch;
                            sw.showCreateAccount = true;
                            
                        if (accList[0].Top_Parent__c != null){
                            acc.Name = accList[0].Top_Parent__r.Name;
                            acc.Top_Parent__c = accList[0].Top_Parent__c;
                            acc.ParentId = accList[0].Top_Parent__c;
                            
                        } else{
                            acc.Name = accList[0].Name;
                            acc.Top_Parent__c = accList[0].Id;
                            acc.ParentId = accList[0].Id;
                        }
                       sw.acc = acc;
                       sw.accList = accList;
                        return sw;
                    } else{
                        sw.msg = Label.OneId_NoRecordsFoundGP;
                        sw.accList = null;
                        return sw;
                    } 
                } else {
                    sw.showCreateAccount = true;
                    sw.msg = Label.ISSP_NoRecordsFoundCreateStandardAirline;
                    sw.buttonLabel = Label.ISSP_Create_New_Airline;
                    sw.acc = new Account(Name=filters.get('accountName'));
                    sw.accList = null;
                    return sw;
                }
            }
         } else if (customerType == OtherCompany){
            if (!sw.accountFound){
                sw.msg = Label.ISSP_NoRecordsFoundCreateAgency;
                sw.buttonLabel = Label.OneId_CreateNewAccount;
                sw.showCreateAccount = true;
            }
        } else if (customerType == Agency && filters.containsKey('hasIATACode') && filters.get('hasIATACode') == 'false'){
            // isNotIATA
            if (!sw.accountFound){
                sw.acc = new Account(Name=filters.get('accountName'));
                if (filters.get('agencyType') == 'cargo'){
                    sw.acc.Sector__c = 'Cargo Agent';
                    sw.acc.Category__c = 'Non-IATA Cargo Agent';
                } else if (filters.get('agencyType') == 'travel'){
                    sw.acc.Sector__c = 'Travel Agent';
                    sw.acc.Category__c = 'Non-IATA Travel Agent';
                }
                sw.msg = Label.ISSP_NoRecordsFoundCreateAgency;
                sw.buttonLabel = Label.ISSP_Create_New_Agency;
                sw.showCreateAccount = true;
            }
        } else if (customerType == Agency && filters.containsKey('hasIATACode') && filters.get('hasIATACode') == 'true'){
            if (!sw.accountFound){
                sw.msg = Label.ISSP_NoRecordsFoundNext;
            }
        } else if (customerType == GSA){
            if (!sw.accountFound){
                sw.msg = Label.ISSP_NoRecordsFoundGSA;
            }
        } else if (customerType == OtherCompany){
            if (!sw.accountFound){
                sw.msg = Label.ISSP_NoRecordsFoundCreateAgency;
                sw.buttonLabel = Label.OneId_CreateNewAccount;
                sw.showCreateAccount = true;
            }
        } else if (customerType == GeneralPublic){
            if (!sw.accountFound){
                sw.msg = Label.ISSP_GeneralPublicNotFound;
                sw.buttonLabel = 'NEXT TODO';
                sw.showCreateAccount = true;
            }
        }
        sw.accList = accList;
        return sw; 
    }

    public class searchWrapper {
        @AuraEnabled
        public list<Account> accList {get; set;}
        
        @AuraEnabled
        public Account HQAccount {get; set;}
        @AuraEnabled
        public Account acc {get; set;}
        @AuraEnabled
        public String msg {get; set;}
        @AuraEnabled
        public String buttonLabel {get; set;}
        @AuraEnabled
        public Boolean accountFound {get; set;}
        @AuraEnabled
        public Boolean showCreateAccount {get; set;}
        @AuraEnabled
        public Boolean showcreateother {get; set;}
    }

    @AuraEnabled
    public static list<CountryPicklist> getISOCountries() {
        list<CountryPicklist> listCountryISOCodeLMap = new list<CountryPicklist>();
        for(IATA_ISO_Country__c iso:[select Id,Name, ISO_Code__c from IATA_ISO_Country__c order by Name]){
            if (iso.Name != 'All Countries'){
                listCountryISOCodeLMap.add(new CountryPicklist(iso.Name, iso.Id, iso.ISO_Code__c));
            }
        }
        return listCountryISOCodeLMap;
    }

    public class CountryPicklist {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String iso2Code {get; set;}
        public CountryPicklist(String l, String v, String i) {
            label = l;
            value = v;
            iso2Code = i;
        }
    }

    @AuraEnabled
    public static list<CustomerTypeByServicePicklist> getCustomerTypeBySP(String serviceName) {
        list<CustomerTypeByServicePicklist> listCustomerTypeSP = new list<CustomerTypeByServicePicklist>();
        One_Id_Service_Provider_Config__c customerTypeAvailable = [SELECT Customer_Type_Activation__c FROM One_Id_Service_Provider_Config__c WHERE Service_Provider_Name__c =: serviceName LIMIT 1];
        
        if(customerTypeAvailable != null) {
            String[] cts = customerTypeAvailable.Customer_Type_Activation__c.split(';');    
            For(String ct : cts)
                listCustomerTypeSP.add(new CustomerTypeByServicePicklist(ct, ct));
        }
        return listCustomerTypeSP;
    }

    public class CustomerTypeByServicePicklist {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        public CustomerTypeByServicePicklist(String l, String v) {
            label = l;
            value = v;
        }
    }

    @AuraEnabled
    public static string register(String accountID) {
        return 'Registration done';
    }
}
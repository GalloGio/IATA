public without sharing class OneId_Fred_AccountSelection_CTRL {
    public class RegistrationResponse {
        @AuraEnabled
        public boolean success {get; set;}
        @AuraEnabled
        public String error  {get; set;}

        public RegistrationResponse(Boolean success) {
            this.success = success;
        }
        public RegistrationResponse(Boolean success, String error) {
            this.success = success;
            this.error = error;
        }
    }

    @AuraEnabled
    public static RegistrationResponse registration(Account acc, Contact con, String selectedCustomerType, Boolean isGuest, Boolean createPrimary, Integer userTypeToCreate) {
        System.debug('SMH register');
        System.debug('SMH acc '+acc);
        System.debug('SMH con '+con);
        System.debug('SMH createPrimary '+createPrimary);
        System.debug('SMH userTypeToCreate '+userTypeToCreate);
        System.debug('SMH isGuest '+isGuest);

        String serviceName = 'FRED';

        // FRED is english only
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

            // no need for FRED
            //con.User_Portal_Status__c ='Pending Approval';
            con.Community__c = 'FRED Customer Portal';

            // Determine if is primary or a guest
            system.debug('@@@ isGuest '+isGuest);
            
			// Retrieve the number of primary and secondary fred users for the selected account
            list<PermissionSetAssignment> fredUsers = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name in ('FRED_Primary_User', 'FRED_SSO') AND Assignee.AccountId =: acc.Id];

            set<Id> primariesIds = new set<Id>();
            set<Id> secondariesIds = new set<Id>();
            
            for(PermissionSetAssignment psa : fredUsers) {
                if(psa.PermissionSet.Name == 'FRED_Primary_User'){
	                primariesIds.add(psa.AssigneeId);
                }
                else{
	                secondariesIds.add(psa.AssigneeId);
                }
            }

			// Remove from the secondaries set, the users identified as primary user (they should have both permission sets assigned)
			secondariesIds.removeAll(primariesIds);

            Integer nbOfPrimaryInAccount = primariesIds.size();
            Integer nbOfSecondaryInAccount = secondariesIds.size();

            if(isGuest) {
                // Get account and found any user that has primary user permission set
                //Integer nbOfPrimaryInAccount = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId =: acc.Id];
                createPrimary = createPrimary || nbOfPrimaryInAccount == 0; // Account doesn't have primary user so I became the unique primary user
                system.debug('@@@ createPrimary? '+createPrimary);
            }
            

            // Load  FRED limit and compare to account number
			List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'One_Id_Service_Provider_Config__c' AND DeveloperName = 'Service_Provider'];

            One_Id_Service_Provider_Config__c config;

			if(! recordTypes.isEmpty()){
				config = [select Max_Number_Of_Primary_User__c, Max_Number_Of_Secondary_User__c FROM One_Id_Service_Provider_Config__c  WHERE Service_Provider_Name__c =: serviceName AND RecordTypeId =: recordTypes[0].Id LIMIT 1];
			}
			else{
				config = [select id, Max_Number_Of_Primary_User__c, Max_Number_Of_Secondary_User__c FROM One_Id_Service_Provider_Config__c  WHERE Service_Provider_Name__c =: serviceName LIMIT 1];
			}
            
           
			System.debug('SMH LIMIT PRIMARY: '+nbOfPrimaryInAccount+' over '+config.Max_Number_Of_Primary_User__c);
			System.debug('SMH LIMIT SECONDARY: '+nbOfSecondaryInAccount+' over '+config.Max_Number_Of_Secondary_User__c);
			System.debug('SMH isGuest '+isGuest);

            if((createPrimary && nbOfPrimaryInAccount >= config.Max_Number_Of_Primary_User__c) || (!createPrimary && nbOfSecondaryInAccount >= config.Max_Number_Of_Secondary_User__c)) {
                // Limit reached
                return new RegistrationResponse(false, Label.OneId_Max_Account_Reached);
            }
                

            Savepoint sp = Database.setSavepoint();
            try {
                String returnedString = '';
                if(isGuest)
                    returnedString = LightningRegistrationProcess.createContactAndAccount(con, acc, selectedCustomerType, serviceName);
                else {// Another way to user creation because Site.createUserPortal does not work with a user connected (secondary user created by primary user)
                    
                    returnedString = createSecondary(con, acc, selectedCustomerType, serviceName, userTypeToCreate);
                }

                System.debug('@SMH'+returnedString);
                if (returnedString.contains('line:')){
                    // Error during creation of contact and user
                    Database.rollback(sp);
                    return new RegistrationResponse(false, returnedString);
                } else {
                    // For guest, primary permission set is done at change password step
                    if(! isGuest) { // Assign permission set only in case primary user tries to create a primary
                        permissionSetAssignenent(returnedString, createPrimary, userTypeToCreate); // assign Permission Set Fed user provisionning to grant access to Connected App
                    }
                }

            } catch(exception ex){
                Database.rollback(sp);
                System.debug(ex);
                return new RegistrationResponse(false, ''+ex);
            }
        }
       return new RegistrationResponse(true);
    }


    public static String createSecondary(Contact con, Account acc, String customerType, String servName, Integer userTypeToCreate) {
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
                thisNickname = con.lastName.substring(0, 3)+Datetime.now().formatLong();
            else
                thisNickname = con.lastName+Datetime.now().formatLong();

       
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
            User u = new User ( CommunityNickname= thisNickname , title=con.title, contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), timezonesidkey = 'America/Los_Angeles', languagelocalekey = 'en_US', Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true, UID__c = UID);
            //User u = new User (CommunityNickname= thisNickname , contactid = con.id, Firstname = con.firstname, lastname = con.lastname, emailencodingkey = 'UTF-8', localesidkey = 'en_US', email = con.email, username=ISSP_Utilities.buildPortalUserName(con.email), languagelocalekey = 'en_US', Date_ToU_accepted__c = system.Now(), ToU_accepted__c = true);
           
            // Set Fred profile => Request by Mehdi to use ISSP Profile to avoid managing a new one
            u.ProfileID = [SELECT Id FROM profile WHERE name = 'ISS Portal (Partner)' LIMIT 1][0].Id;
            u.Community__c = servName;

            System.debug('User ' + u);
            String password = Comm_User_Helper.generateRandomString(6) + '1a';

            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerUserEmail= false;
            Database.saveresult sr = Database.insert(u, dlo);

            String userId = u.Id;
            System.setPassword(userId, password);
            LightningRegistrationProcess.serviceName = 'FRED';
            LightningRegistrationProcess.sendWelcomeEmail(con, u, password);

            return userId;

        } catch (Exception e) {
            return e.getMessage() + ' - line: ' + e.getLineNumber();
        }
    }

    @AuraEnabled
    public Static void checkConAvailable (Contact con){
        RecordType rt = [Select Id From RecordType WHERE SObjectType ='Contact' AND DeveloperName='Standard_Contact'];        
        Contact [] ec = [Select id, email, AccountId, RecordType.Id FROM Contact WHERE email =:con.email AND AccountId =:con.AccountId LIMIT 1];
        
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
    public static void permissionSetAssignenent(String userId, Boolean createPrimary, Integer userTypeToCreate){
        system.debug('FRED - userId ' + userId);
        system.debug('FRED - createPrimary ' + createPrimary);
        system.debug('FRED - userTypeToCreate ' + userTypeToCreate);
        if (userId != null && userId != '') {
            list<PermissionSet>  pss = [SELECT Id, Name FROM PermissionSet WHERE Name='FRED_Primary_User'];
            if(! pss.isEmpty()){
                // JIRA ISI-51 + ISI-14: Self registration primary => Add special permission set to grant delegated admin persmission
                list<PermissionSetAssignment> assignment = new list<PermissionSetAssignment>();
                for(PermissionSet ps : pss) {
                    if(userTypeToCreate == 1) {
                        assignment.add(
                            new PermissionSetAssignment(
                                AssigneeId = userId,
                                PermissionSetId = ps.Id
                            )
                        );
                    } 
                }
                if(! assignment.isEmpty())
                    insert assignment;
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
    public static InitParam initParams(Boolean isInvitation, String invitationId) {
        InitParam param = new InitParam();
        param.isInvitation = isInvitation;

        // is guest OR a connected partner user (like primare user)
        Integer nb = [SELECT count() FROM User WHERE Name = 'identity Site Guest User' AND Id =: UserInfo.getUserId()];
        Boolean isGuest = nb > 0;
        param.isGuest = isGuest;
        if(!isGuest) {
            // Is a primary user connected?
            Integer n = [SELECT Count() FROM PermissionSetAssignment WHERE PermissionSet.name = 'FRED_Primary_User' AND AssigneeId =: UserInfo.getUserId()];
            param.isFredPrimaryUser = n > 0;
            param.primaryUserId = UserInfo.getUserId();
            

            // Get account linked to primary user - To block account selection
            User u = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            if(u!=null && u.AccountId != null) {
                param.partnerAccount = [SELECT RecordType.DeveloperName, RecordType.Name, Id, Name, IATACode__c, X8585_Code__c, Airline_designator__c, State_Name__c, ICAO_Iso_2_Code__c, ICAO_Iso_3_Code__c FROM Account WHERE Id =: u.AccountId LIMIT 1];

                // To change when implemnting another primary
                Integer nbOfPrimaryInAccount = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId =: u.AccountId];
                param.createPrimary = nbOfPrimaryInAccount == 0;
            }
        } else {
            param.primaryUserId = null;
            param.partnerAccount = null;

            param.isFredPrimaryUser = false;
            param.createPrimary = false;

            // Get info from invitation
            if(isInvitation) {
                list<Invitation__c> invitation = [SELECT  AccountId__c, Role__c FROM Invitation__c WHERE Id =: invitationId];
                if(! invitation.isEmpty()) {
                    list<Account> acct = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id =: invitation[0].AccountId__c]; 
                    if(! acct.isEmpty()) {
                        param.partnerAccount = acct[0];
						param.createPrimary = invitation[0].Role__c == 'Primary';
                    }
                }
            }
        }
        
        return param;
    }

    public class InitParam {
        @AuraEnabled
        Boolean isGuest {get; set;}
        @AuraEnabled
        Boolean isFredPrimaryUser {get; set;}
        @AuraEnabled
        String primaryUserId {get; set;}
        @AuraEnabled
        Account partnerAccount {get; set;}
        @AuraEnabled
        Boolean createPrimary {get; set;}
        @AuraEnabled
        Boolean isInvitation {get; set;}
    }

    
    @AuraEnabled
    public static SearchWrap getAccountsByType(String customerType, String userInput) {
        system.debug(customerType+' => '+userInput);
        SearchWrap sw = new SearchWrap();

        String recordTypeSearch = customerType;

        set<string> recordTypesSet = ISSP_Constant.accountRecordTypeByUserType.get(recordTypeSearch);

        String queryStr = 'SELECT Id, IATACode__c, Airline_designator__c, Field_Head_Office__c, Name, BillingStreet, BillingCity, BillingCountry FROM Account WHERE ';
        queryStr += ' RecordType.DeveloperName in :recordTypesSet';
        queryStr += ' AND Name like \'%' + userInput + '%\'';

        if(customerType=='Aircraft Operator') {
            queryStr = 'SELECT Id, Name, IATACode__c, X8585_Code__c, Airline_designator__c, IATA_ISO_Country__r.fred_icaomemberstate__r.IATA_ISO_Country__r.ISO_Code__c ';
            String queryStr2 = ' FROM Account WHERE';
            //queryStr2 += ' RecordType.DeveloperName = \'IATA_Airline\'';
            queryStr2 += ' (RecordType.DeveloperName = \'IATA_Airline\' OR RecordType.DeveloperName = \'Operator\' )';
            queryStr2 += ' AND (X8585_Code__c <> \'\')';
            queryStr2 += ' AND (X8585_Code__c <> null )';
            queryStr2 += ' AND (Name like \'%' + userInput + '%\'';
            /*
            // Jira ISI-46: Search only by commercial name for aircraft operator
            queryStr2 += ' OR Airline_designator__c like \'%' + userInput + '%\'';
            */
            queryStr2 += ')';
            queryStr2 += ' AND (fredp_aircraftoperator_eligibility__c = true)'; // Jira ISI-42
            sw.totalAccListNotLimited = Database.countQuery('select count()'+queryStr2);

            queryStr += queryStr2;
            queryStr += ' LIMIT '+Label.OneId_AccountSearch_Limit; // Default limit is 20
        }

        if(customerType=='ICAO Member State') {
            queryStr = 'SELECT Id, Name, ICAO_Iso_2_Code__c, ICAO_Iso_3_Code__c, IATA_ISO_Country__r.ISO_Code__c ';
            String queryStr2 = ' FROM Account WHERE';
            queryStr2 += ' RecordType.DeveloperName = \'ICAO_Member_State\'';
            queryStr2 += ' AND (Name like \'%' + userInput + '%\'';
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
}
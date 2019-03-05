public without sharing class ISSP_WS_Utilities {

    public static Portal_Application_Right__c createApp(Id appId, Id contactId){
    	Portal_Application_Right__c appRight = new Portal_Application_Right__c();
		appRight.Portal_Application__c = appId;
		appRight.Contact__c = contactId;
		appRight.Right__c = 'Access Granted';
		return appRight;
    }

    public static Contact createContact(String firstName, String lastName, String email, String accountId, Boolean isCNS){
    	Contact con = new Contact();
		con.User_Portal_Status__c = ISSP_Constant.APPROVED_CONTACT_STATUS;
		con.FirstName = firstName;
		con.LastName = lastName;
		con.Email = email;
		con.AccountId = accountId;
		con.RecordTypeId = ISSP_Constant.Standard_Contact_Record_Type;
		con.Community__c = 'ISS Customer Portal';
        if(isCNS) {
            con.CNS_Contact__c = true;
            con.Community__c = 'CNS Customer Portal';
        }else{
        	con.Community__c = 'ISS Customer Portal';
        }
		return con;
    }

    public static User createUser(String firstName, String lastName, String email, String accountType, String contactId, Boolean isCNS){
    	User u = new User();
        u.Username = ISSP_Utilities.buildPortalUserName(email);
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        if(isCNS){
		u.Community__c = 'CNS';
        }else{
        u.Community__c = 'ISSP';
        }
        if (lastName.length() > 3)
            u.CommunityNickname = lastName.substring(0,3)+Datetime.now().formatLong();
        else
            u.CommunityNickname = lastName+Datetime.now().formatLong();
        String profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('OtherCompany');
        if (ISSP_Constant.userTypeByAccountRtDeveloperNameMap.containsKey(accountType)){
        	profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(ISSP_Constant.userTypeByAccountRtDeveloperNameMap.get(accountType));
        }
        String profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
        u.ProfileId = profileId;
        u.IsActive = true;
        //u.IsPortalEnabled = true;
        u.alias = createAlias(firstName, lastName);
        u.emailencodingkey = 'UTF-8';
        u.languagelocalekey = 'en_US';
        u.localesidkey = 'en_US';
        u.contactId = contactId;
        u.timezonesidkey = 'Asia/Dubai';
        u.UID__c = Comm_User_Helper.NewGuid();
        return u;
    }

    public static void sendUserEmail(User newUser, Contact con){
    	String password = Comm_User_Helper.generateRandomString(6)+'1a';
        System.setPassword(newUser.Id, password);
        String cleanUsername = ISSP_Utilities.buildPortalUserName(con.email);
        cleanUsername = cleanUsername.replace('+', Comm_User_Helper.plusReplacer);
        string encodedPart = EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+newUser.UID__c), 'UTF-8');
        String link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c)+ '/ISSP_First_Login?c='+encodedPart;
    	String template = 'ISSP_New_Member_Welcome_Email_2';
		Map<String,String> emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, 'ISSP');
		Comm_User_Helper.sendEmail( template ,emailWrap, con, 'ISSP');
		Comm_User_Helper.permissionASS(new list<Id>{newUser.Id});
    }

    public static String createAlias(String pFirstName, String pLastName) {
        if(pFirstName==null)
            pFirstName='-';
        if(pLastName==null)
            pLastName='';

        if (pLastName.length() > 7)
            return pLastName.substring(0, 7) + pFirstName.substring(0,1);
        else
            return pLastName + pFirstName.substring(0,1);
    }

    @Future(callout=true)
	public static void invokeAsdDisableUser(String contactId){
		ISSP_WS_ASD_DeactivateUser.AsdIssPortalServicePort ws = new ISSP_WS_ASD_DeactivateUser.AsdIssPortalServicePort();
    	ISSP_WS_ASD_DeactivateUser.disablePortalUserResult res = ws.disablePortalUser(contactId);
    	system.debug('webservice result: ' + res);
    }
    
    /**
        Call SIS Integration to update a User
    **/
    @Future(callout=true)
	public static void invokeSisModifyUser(list<Id> listContactId) {
        //find incoming users
        list<User> listUser = [
            SELECT Id, FederationIdentifier, Contact.FirstName, Contact.LastName, Contact.Email
            FROM User
            WHERE ContactId in :listContactId];
        System.debug('listUser ' + listUser);

        // call to external web service to update SIS users
        list<ISSP_Web_Service_Log__c> listLogs = new list<ISSP_Web_Service_Log__c>();

        for (User user: listUser) {
            ISSP_WS_SIS_Callout_UpdateUser.ResponseData response = ISSP_WS_SIS_Callout_UpdateUser.updateUser(user,user.contact);
            // generate log record
            ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateUser.createLog(response);
            listLogs.add(log);
        }
        // insert logs
        try {
            if (!listLogs.isEmpty()) insert listLogs;
        } catch (Exception e) {
            System.debug('ERROR inserting logs ' + e.getMessage());
        }
    }
    
    /**
        Call SIS Integration to update revoke SIS access to a user
    **/
    @Future(callout=true)
	public static void invokeSisDeactivateUsers(list<Id> listContactId) {
        //find incoming users
        list<User> listUser = [
            SELECT Id, FederationIdentifier, contact.Account.SIS_ID__c
            FROM User
            WHERE ContactId in :listContactId];
        System.debug('listUser ' + listUser);

        // call to external web service to activate SIS users
        list<ISSP_Web_Service_Log__c> listLogs = new list<ISSP_Web_Service_Log__c>();

        for (User user: listUser) {
            ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.deactivateUser(user);
            // generate log record
            ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_ActivateUser.createLog(response);
            listLogs.add(log);
        }
        // insert logs
        try {
            if (!listLogs.isEmpty()) insert listLogs;
        } catch (Exception e) {
            System.debug('ERROR inserting logs ' + e.getMessage());
        }
    }
    
    /**
        Call SIS Integration to grant accress to a User (and creates the user if still does not exist)
    **/
    @Future(callout=true)
	public static void invokeSisActivateUsers(list<Id> listContactId) {
        //find incoming users
        List<String> allowRT = new List<String>();
        for(ISSP_SIS_Account_Status__c setting: ISSP_SIS_Account_Status__c.getAll().values()){
            allowRT.add(setting.Recordtype__c);
        }
        list<User> listUser = [
            SELECT Id, FederationIdentifier,
                contact.Id, contact.FirstName, contact.LastName, contact.Email, contact.SIS_Contact_Type__c,
                contact.Account.SIS_ID__c, contact.account.RecordType.DeveloperName
            FROM User
            WHERE ContactId in :listContactId and contact.account.RecordType.DeveloperName in :allowRT];
        System.debug('listUser ' + listUser);
        
        list<ISSP_Web_Service_Log__c> listLogs = new list<ISSP_Web_Service_Log__c>();
        list<User> listExistingUsers = new list<User>();
        
        // First call external SIS WS to create users (new users are activated by default)
        for (User user: listUser) {
            ISSP_WS_SIS_Callout_CreateUser.ResponseData response = ISSP_WS_SIS_Callout_CreateUser.createUser(user, user.Contact);
            // generate log record
            ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateUser.createLog(response);
            // if the user was already in SIS then store it to call enable user
            if (!response.IsSuccess && response.ErrorCode == ISSP_WS_SIS_Callout_CreateUser.ERROR_FEDERATIONID_DUPLICATE) {
                listExistingUsers.add(user);
            }
            listLogs.add(log);
        }
        // Second call external SIS WS to activate SIS users that were already created
        for (User user: listExistingUsers) {
            ISSP_WS_SIS_Callout_ActivateUser.ResponseData response = ISSP_WS_SIS_Callout_ActivateUser.activateUser(user);
            // generate log record
            ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_ActivateUser.createLog(response);
            listLogs.add(log);
        }
        // insert logs
        try {
            if (!listLogs.isEmpty()) insert listLogs;
        } catch (Exception e) {
            System.debug('ERROR inserting logs ' + e.getMessage());
        }
    }
    
    
    /**
        Call SIS Integration to create an Account
    **/
    @Future(callout=true)
	public static void invokeCreateAccount(list<Id> listAccountId){
        //find incoming accounts
        String query = 'SELECT Id, BillingAddress, Country_ISO_Code__c, Status__c, '
            + String.join(ISSP_WS_SIS_Callout_CreateAccount.LIST_FIELD_NAMES,',')
            + ' FROM Account WHERE Id IN :listAccountId '
            + ' AND (SIS_ID__c = null OR SIS_ID__c = \'\')';
		
		//EM - fix sfdc bug
		if (Test.isRunningTest())
			query = query.replace('BillingAddress, ', '');
		
        System.debug('query ' + query);
        list<Account> listAccount = Database.query(query);
        System.debug('listAccount ' + listAccount);
        
        // call to external web service to create the account in SIS
        list<ISSP_Web_Service_Log__c> listLogs = new list<ISSP_Web_Service_Log__c>();
        list<Account> listAccountToUpdate = new list<Account>();
        for (Account account: listAccount) {
            ISSP_WS_SIS_Callout_CreateAccount.ResponseData response = ISSP_WS_SIS_Callout_CreateAccount.createAccount(account);
            // if the response to the WS is success we update the SIS ID field in the account
            if (response.IsSuccess) {
                account.SIS_ID__c = response.SISMemberID;
                listAccountToUpdate.add(account);
            }
            // generate log record
            ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_CreateAccount.createLog(response);
            listLogs.add(log);
            System.debug('Account SIS Create Account log: ' + log);
        }
        // update accounts
        try {
            if (!listAccountToUpdate.isEmpty()) {
                ISSP_SIS_AccountHandler.BLOCK_EXECUTION = true;
                update listAccountToUpdate;
            }
        } catch(Exception e) {
            System.debug('ERROR updating accounts with SIS ID' + e.getMessage());
        }
        // insert logs
        try {
            if (!listLogs.isEmpty()) insert listLogs;
        } catch (Exception e) {
            System.debug('ERROR inserting logs ' + e.getMessage());
        }
    }
    
    /**
        Call SIS Integration to update an Account
    **/
    @Future(callout=true)
    public static void invokeUpdateAccount(list<Id> listAccountId){
        //find incoming accounts
        String query = 'SELECT Id, BillingAddress, Country_ISO_Code__c, Status__c, '
        + String.join(ISSP_WS_SIS_Callout_UpdateAccount.LIST_FIELD_NAMES,',')
            + ' FROM Account WHERE Id IN :listAccountId';
		
		//EM - fix sfdc bug
		if (Test.isRunningTest())
			query = query.replace('BillingAddress, ', '');
		
        System.debug('query ' + query);
        list<Account> listAccount = Database.query(query);
        System.debug('listAccount ' + listAccount);
        
        // call to external web service to create the account in SIS
        list<ISSP_Web_Service_Log__c> listLogs = new list<ISSP_Web_Service_Log__c>();

        for (Account account: listAccount) {
            ISSP_WS_SIS_Callout_UpdateAccount.ResponseData response = ISSP_WS_SIS_Callout_UpdateAccount.updateAccount(account);
            // generate log record
            ISSP_Web_Service_Log__c log = ISSP_WS_SIS_Callout_UpdateAccount.createLog(response);
            listLogs.add(log);
            System.debug('Account SIS Update Account log: ' + log);
        }
        // update accounts and insert logs
        try {
            if (!listLogs.isEmpty()) insert listLogs;
        } catch (Exception e) {
            System.debug('ERROR inserting logs ' + e.getMessage());
        }
    }

    /**
        Find all valid SIS contacts from the input accounts to give them access
        to SIS Joining app
    **/
    @future
    public static void invokeGiveSISAppToAccountUsers(list<Id> listAccountId) {
        list<User> listUser = [SELECT Id, ContactId FROM User WHERE ProfileId IN :ISSP_Constant.adminIdSet AND (Contact.AccountId IN :listAccountId OR Contact.Account.Top_Parent__c IN :listAccountId)];

        list<Id> listContactId = new list<Id>();
        for (User user: listUser) {
            listContactId.add(user.contactId);
        }
        grantAccessToSIS(listContactId);
    }

    /**
        Grant access to SIS Membership application (not SIS App) to a list of contacts
    **/
    public static void grantAccessToSIS(list<Id> listContactId) {
        Portal_Applications__c app = [
            SELECT Id, Name FROM Portal_Applications__c WHERE Name = :ISSP_SISMembershipApplication_Ctrl.APP_NAME];

        map<Id,Portal_Application_Right__c> mapContactAppId = new map<Id,Portal_Application_Right__c>();
        for (Portal_Application_Right__c appRight:
                [SELECT Id, Right__c, Contact__c FROM Portal_Application_Right__c WHERE Contact__c IN :listContactId AND Portal_Application__c = :app.Id]) {
            mapContactAppId.put(appRight.Contact__c, appRight);
        }

        list<Portal_Application_Right__c> listRightsToUpsert = new list<Portal_Application_Right__c>();
        for (Id contactId: listContactId) {
            Portal_Application_Right__c appRight = mapContactAppId.get(contactId);
            if (appRight==null){
                //create new app right
                try {
                    listRightsToUpsert.add(createApp(app.Id, contactId));
                } catch (Exception e) {
                    System.debug('Error adding ' + app.Name + ' to Contact ' + contactId + ': ' + e.getMessage());
                }
            } else {
                //grant access to already existing app right
                if (appRight.Right__c != 'Access Granted'){
                    appRight.Right__c = 'Access Granted';
                    listRightsToUpsert.add(appRight);
                }
            }
        }
        if (!listRightsToUpsert.isEmpty()) {
            Database.upsert(listRightsToUpsert,false);
        }
    }
}

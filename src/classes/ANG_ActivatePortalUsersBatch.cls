global class ANG_ActivatePortalUsersBatch implements Database.Batchable<sObject> {
	
	public List<Contact> contactsToCreatePortalUser;

	public ANG_ActivatePortalUsersBatch(List<Contact> contactsToCreatePortalUser){
		this.contactsToCreatePortalUser = contactsToCreatePortalUser;
	}

    global Iterable<sObject> start(Database.BatchableContext bc) {
        return contactsToCreatePortalUser;
    }

    //This is only prepared to invoke the process for 1 record at a time
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
    	 runAction(scope[0].Id, String.valueOf(scope[0].Email), 'CreateNewUserWithPartnerProfile', 'Approved Admin', null);
    }

    global void finish(Database.BatchableContext BC) {

    }

    /*REPLICATED FROM PORTAL CODE IN ORDER TO GET RID OF FUTURE METHODS
	  EVERYTHING CONCERNED WITH USER CREATION IS NOW ASYNC
    */
    public static String runAction(Id conId, String currentEmail, String theAction, String newValue, String inactiveReason){
    	IECTestUtil.trgPortalUserAfterInserUpdate = true;
        ISSP_ContactList.avoidContactStatusTrigger = true;
        system.debug('runAction CONTACT ID: ' + conId);
        system.debug('runAction ACTION: ' + theAction);
        system.debug('runAction NEW STATUS: ' + newValue);
        system.debug('runAction inactiveReason: ' + inactiveReason);
        String errorMessageResult = '';
        
        if (theAction == 'CreateNewUserWithPartnerProfile'){
            string userType = ISSP_Utilities.getContactTypeById(conId);
            string profileName = ISSP_Constant.profilNameByUserTypeMap.get('Admin').get(userType);
            string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
            List <Contact> conList = [SELECT Id, Status__c, Community__c FROM Contact WHERE Id = :conId];
            if (!conList.isEmpty()){
                try{
                    Contact contactToUpdate = conList[0];
                    if(String.isBlank(contactToUpdate.Community__c)) {/*** AMSU-163 in case of empty community set as ISSP ***/
                        contactToUpdate.Community__c = 'ISSP';
                    }
                    contactToUpdate.Status__c = 'Active';
                    contactToUpdate.Email = currentEmail;
                    contactToUpdate.User_Portal_Status__c = 'Approved Admin';
                    update contactToUpdate;
                }
                catch(Exception e){
                    system.debug('ERROR: ' + e.getMessage());
                    errorMessageResult = e.getMessage(); return errorMessageResult;
                }
                
                List <User> userList = [select Id, ContactId, UserType from User where ContactId = :conId AND UserType = 'PowerPartner'];
                if (!userList.isEmpty()){
                    ISSP_PortalUserStatusChange.updateUserSync(conId, true, currentEmail, profileId, ''); /*** AMSU-163 changed to be synchronous ***/
                    //ISSP_HierarchyAccountTeamAccounts.HierarchyAccountTeamMemberAccounts(new Set<Id>{userList[0].Id});
                }
                else{
                    createNewUser(profileId,conId);
                }
            }
        }
        
        return errorMessageResult;
    }

    public static User createUser(Contact con,Id userProfile){
        system.debug('createUser with profile: ' + userProfile);
        string nick = con.email!=null?con.email.substring(0, con.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        if (nick.length() > 40){
            nick = nick.left(40);
        }
        else{
            nick = nick;
        }
        User user;
        list<User> userList = [select Id,ProfileId,IsActive,IsPortalEnabled,languagelocalekey from User where contactId =: con.Id];
        if(!userList.isEmpty()){
            system.debug('user exists');
            user = userList.get(0);
            user.IsActive = true;
            user.IsPortalEnabled = true;
            user.ProfileId = userProfile;
            user.Username = ISSP_Utilities.buildPortalUserName(user.email);//AEF:
            
        }else{
            system.debug('user not exists');
             user = new User(
                        alias = ISSP_PortalUserStatusChange.createAlias(con.firstName, con.lastName), 
                        email = con.email, 
                        emailencodingkey = 'UTF-8', 
                        firstname = con.firstName, 
                        lastname = con.lastname, 
                        languagelocalekey = 'en_US', 
                        localesidkey = 'en_US', 
                        contactId = con.Id,
                        timezonesidkey = 'Asia/Dubai', 
                        username = ISSP_Utilities.buildPortalUserName(con.email),//AEF
                        CommunityNickname = nick,
                        ProfileId = userProfile,
                        IsActive = true);
        }
         if(con.Preferred_Language__c!=null && ISSP_PortalUserStatusChange.languageMap.containsKey(con.Preferred_Language__c))
                user.languagelocalekey = ISSP_PortalUserStatusChange.languageMap.get(con.Preferred_Language__c);
        return user;
     }
    public static void createNewUser(Id userProfile,string contactId){
        system.debug('\n\n\n contactId'+contactId+'\n\n\n');
        Contact con = [select id,email,firstName,lastname,accountId,Preferred_Language__c, Salutation, Community__c from Contact where Id =:contactId];
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false; 
        dmo.EmailHeader.triggerOtherEmail = false; 
        dmo.EmailHeader.triggerAutoResponseEmail = false; 
        dmo.optAllOrNone = false; 
                
        // create portal user
        
        
        User newUser = createUser(  con,userProfile);
        system.debug('\n\n\n newUser'+newUser+'\n\n\n');
        String UID = Comm_User_Helper.NewGuid();
        system.debug('newuser id: ' + newUser.Id);
        if(newUser.Id == null){
            newUser.setOptions(dmo);
            
            // new email process
            newUser.UID__c = UID;
            newUser.Community__c = 'ISSP';
            system.debug('inserting newuser');
            insert newUser;
            system.debug('inserted newuser: ' + newUser.Id);
            // new email process
            String password = Comm_User_Helper.generateRandomString(6)+'1a';
            System.setPassword(newUser.Id, password);
            String cleanUsername = ISSP_Utilities.buildPortalUserName(con.email);
            cleanUsername = cleanUsername.replace('+', Comm_User_Helper.plusReplacer);
            string encodedPart = EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+UID), 'UTF-8');

            String link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c)+ '/ISSP_First_Login?c='+encodedPart ;
            String template = 'ISSP_New_Member_Welcome_Email_2';
            if(con.Community__c != null && con.Community__c.contains('CNS')){
                link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c)+ '/ISSP_First_Login?CommunityName=CNS&c='+encodedPart ;
                template = 'ISSP_New_Member_Welcome_Email_2_CNS';
            }

            Map<String,String> emailWrap = Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, con.Community__c);
            Comm_User_Helper.sendEmail( template ,emailWrap, con, con.Community__c);
            
        }else{
            system.debug('will update user with this profile id: ' + newUser.ProfileId);
            update newUser;
        }

    }

}
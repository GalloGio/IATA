public with sharing class ISSP_PortalUserStatusChange {

    public Contact con {get;set;}
    public ISSP_FieldSetController fieldSetCtrl{get; set;}
    public string UserPortalStatus {get;set;}
    public Boolean portalUser {get;set;}
    public List<String> errorMessages {get;set;}
    public String contactStatus {get;set;}
    public List<SelectOption> rejectionReasonOptions {get;set;}
    public List<SelectOption> inactiveReasonOptions {get;set;}
    public String createUserStatus {get;set;}
    public String createUser {get;set;}
    public Boolean userExists {get;set;}
    public String rejectionReason {get;set;}
    public String inactivationReason {get;set;}
    public Boolean hasIdCard {get; set;}
    public Boolean hasProducts {get; set;}
    public List<SelectOption> communityOptions {get;set;}
    public String selectedVal {get;set;}
    public List<String> firstCommunity {get;set;}
     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    
    public ISSP_PortalUserStatusChange(Apexpages.Standardcontroller ctrl){
        Map<String, String> communityMap = new Map<String, String>{'CNS' => 'CNS Customer Portal', 'IEC' => 'E-Commerce','ISSP' => 'ISS Customer Portal'};
        portalUser = false;
        userExists = false;
        hasIdCard = false;
        hasProducts = false;

        con = [select id,Status__c,User_Portal_Status__c,Account.Top_Parent__c,AccountId,Regional_Administrator_Countries__c, Community__c,
            (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE NOT card_status__c like 'Cancelled%'),
            (SELECT Id FROM IEC_Subscriptions_History__r)
            from Contact where Id=:ctrl.getId()];
        if (!con.ID_Cards__r.isEmpty()){
            hasIdCard = true;
        }
        if (!con.IEC_Subscriptions_History__r.isEmpty()){
            hasProducts = true;
        }        
        system.debug('con.Id: ' + con.Id);
        UserPortalStatus = con.User_Portal_Status__c;
        fieldSetCtrl = new ISSP_FieldSetController(getCountrysMap(),con.Regional_Administrator_Countries__c);
        List <User> userList = [select Id, ContactId, UserType from User where ContactId = :con.Id];
        system.debug('userList: ' + userList);
        if (!userList.isEmpty()){
            system.debug('UserType: ' + userList[0].UserType);
            if (userList[0].UserType == 'PowerPartner'){
                userExists = true;
            }
        }
        User currentUser = [select Id, ContactId, UserType from User where Id = :Userinfo.getUserId()];
        if (currentUser.UserType == 'PowerPartner'){
            portalUser = true;
        }
        
        rejectionReasonOptions = new List<SelectOption>();
        rejectionReasonOptions.add(new SelectOption('Retired', Label.ISSP_RejectReason_Retired));
        rejectionReasonOptions.add(new SelectOption('LeftCompany', Label.ISSP_RejectReason_Left));
        rejectionReasonOptions.add(new SelectOption('UnknownContact', Label.ISSP_RejectReason_Unknown));
        
        inactiveReasonOptions = new List<SelectOption>();
        inactiveReasonOptions.add(new SelectOption('Retired', Label.ISSP_RejectReason_Retired));
        inactiveReasonOptions.add(new SelectOption('LeftCompany', Label.ISSP_RejectReason_Left));
        inactiveReasonOptions.add(new SelectOption('UnknownContact', Label.ISSP_RejectReason_Unknown));
        //CummunityOptions
        communityOptions = new List<SelectOption>();
        communityOptions.add(new SelectOption('','-Select a Community-'));
        if(con.Community__c != ''){
            for (String key : communityMap.keySet()) {
                communityOptions.add(new SelectOption(key,communityMap.get(key)));
                if(con.Community__c == communityMap.get(key))
                    selectedVal = key;
            }            
        }
    }

    public Pagereference save(){
        if(con.User_Portal_Status__c == 'Regional Administrator' && fieldSetCtrl.fieldSet.split(';')[0]==''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Please select at least one value in Regional Administrator Countries.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        else{    
            if(con.User_Portal_Status__c == 'Regional Administrator'){
                con.Regional_Administrator_Countries__c = fieldSetCtrl.fieldSet;
            }else { con.Regional_Administrator_Countries__c = '';     }
        }
        if ((con.Community__c == '' || con.Community__c == null) && communityName!='CNS'){
            con.Community__c = 'ISS Customer Portal';
        }else if((con.Community__c == '' || con.Community__c == null) && communityName =='CNS'){
             con.Community__c = 'CNS Customer Portal';
        }
        update con;
        if (portalUser){
            return new Pagereference('/ISSP_Contact?Id='+con.Id + commParam);
        }
        else{
            return new Pagereference('/'+con.Id);
        }
    }
    
    public PageReference customCancel(){
        return new Pagereference('/ISSP_Contact?Id='+con.Id + commParam);
    }
    
    public map<string,string> getCountrysMap(){
        User user = [select Id,ContactId,Contact.User_Portal_Status__c from User where Id =: Userinfo.getUserId()];
        map<string,string> countrysMap = new map<string,string>();

        if(user.ContactId == null || user.Contact.User_Portal_Status__c == 'Approved Admin'){ 
            set <Id> accIdSet = new set <Id>();
            if(con.AccountId != null)
                accIdSet.add(con.AccountId);
            if(con.Account.Top_Parent__c != null)
                accIdSet.add(con.Account.Top_Parent__c);
            list <Account> accList = [Select a.Top_Parent__c ,IATA_ISO_Country__c,IATA_ISO_Country__r.Name
                                       From Account a
                                       Where a.Top_Parent__c IN :accIdSet or Id=:con.AccountId];
            for(Account acc : accList){
                if(acc.IATA_ISO_Country__c != null){
                    countrysMap.put(acc.IATA_ISO_Country__r.Name,acc.IATA_ISO_Country__r.Name);
                }
            }
            
        }else{

            Contact con= [select Id,Regional_Administrator_Countries__c,User_Portal_Status__c  from Contact where Id =:user.ContactId];
          
            if(con.Regional_Administrator_Countries__c!=null){
                for(string country : con.Regional_Administrator_Countries__c.split(';')){
                    countrysMap.put(country,country);
                }
            }
        }
        return countrysMap;
        
    }
    
    public Pagereference disabelUser(){
        update new Contact(Id=con.Id,User_Portal_Status__c='Deactivate');
        ISSP_PortalUserStatusChange.futureDisabelUser(con.Id);
        
        Set <Id> teamMemberIdSet = new Set <Id>();
        list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where contactId =:con.Id];
        for(User u : usersToUpdate){
            teamMemberIdSet.add(u.Id);
        }
        if (!teamMemberIdSet.isEmpty()){
            delete [select Id from AccountTeamMember where UserId in:teamMemberIdSet and TeamMemberRole =:'Portal Administrator'];
        }
        
        return null;
    }
    
    public Pagereference rejectUser(){
        update new Contact(Id=con.Id,User_Portal_Status__c='Rejected');
        ISSP_PortalUserStatusChange.futureDisabelUser(con.Id);
        
        Set <Id> teamMemberIdSet = new Set <Id>();
        list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where contactId =:con.Id];
        for(User u : usersToUpdate){
            teamMemberIdSet.add(u.Id);
        }
        if (!teamMemberIdSet.isEmpty()){
            delete [select Id from AccountTeamMember where UserId in:teamMemberIdSet and TeamMemberRole =:'Portal Administrator'];
        }
        
        return null;
    }
    
    @future 
    public static void futureDisabelUser(string conId) {
        
        list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where contactId =:conId];
        for(User u : usersToUpdate){
            if(u.IsActive || u.IsPortalEnabled ){
                u.IsActive = false;
            }
        }
        update usersToUpdate;
        
    }
    
    @RemoteAction
    public static string getActionName(string newValue, string oldValue){
        if(newValue==''||newValue==null)
            newValue = 'New user';
        if(oldValue==''||oldValue==null)
            oldValue = 'New user';
        if(actionsMap.get(oldValue)==null)
            return '';
        if(actionsMap.get(oldValue).get(newValue)==null)
            return '';
        return actionsMap.get(oldValue).get(newValue);
    }
    
   
    @RemoteAction 
    public static  map<String,String> preformAction(string contactId,string portalStatus,string oldPortalStatus){
        string actionName = getActionName(portalStatus,oldPortalStatus);
        if(actionName == '' || actionName == null) 
            actionName = 'DoNothing';
        system.debug('preformAction actionName: ' + actionName);
        system.debug('preformAction old: ' + oldPortalStatus);
        system.debug('preformAction new: ' + portalStatus);
        Type t = Type.forName('ISSP_PortalUserStatusChange.'+actionName);
        
        IActions action = (IActions) t.newInstance();
        try{
            action.processAction(contactId);
        }catch(Exception e){        
           return new map<String, String> { 'error' => e.getMessage() };
        } 
        return new map<String, String> { 'status' => 'ok' };
    }
    
    public static  map<String,String> preformActionImmediate(string contactId,string portalStatus,string oldPortalStatus){
        string actionName = getActionName(portalStatus,oldPortalStatus);
        if(actionName == '' || actionName == null) 
            actionName = 'DoNothing';
        system.debug('preformAction (not remote) actionName: ' + actionName);
        system.debug('preformAction (not remote) old: ' + oldPortalStatus);
        system.debug('preformAction (not remote) new: ' + portalStatus);
        Type t = Type.forName('ISSP_PortalUserStatusChange.'+actionName);
        
        IActions action = (IActions) t.newInstance();
        try{
            action.processAction(contactId);
        }catch(Exception e){        
           return new map<String, String> { 'error' => e.getMessage() };
        } 
        return new map<String, String> { 'status' => 'ok' };
    }
    
    @future 
    public static void preformActionFuture(string contactId,string portalStatus,string oldPortalStatus){
        string actionName = getActionName(portalStatus,oldPortalStatus);
        if(actionName == '' || actionName == null) 
            actionName = 'DoNothing';
        system.debug('preformAction actionName: ' + actionName);
        system.debug('preformAction old: ' + oldPortalStatus);
        system.debug('preformAction new: ' + portalStatus);
        Type t = Type.forName('ISSP_PortalUserStatusChange.'+actionName);
        
        IActions action = (IActions) t.newInstance();
        action.processAction(contactId);
    }
    
    
    public Pagereference sendEmailToUser(){
        
        User user = [select Id from User where ContactId =:contactId];
        ISSP_Registration.password =  ISSP_Registration.generatePassword();
        system.setPassword(user.Id, ISSP_Registration.password);
        if(CommunityName=='CNS'){
            ISSP_Registration.sendCNSEmail(user.Id,contactId);
        }else{ ISSP_Registration.sendEmail(user.Id,contactId); }
        
        return null;
    }

///////
    
    public string contactId {get;set;}
    public string portalStatus{get;set;}
    public string oldPortalStatus {get;set;}
    public  Pagereference preformAction(){
        
        string actionName = getActionName(portalStatus,oldPortalStatus);
        if(actionName == '' || actionName == null) 
            actionName = 'DoNothing';
        
        Type t = Type.forName('ISSP_PortalUserStatusChange.'+actionName);
        
        IActions action = (IActions) t.newInstance();
        action.processAction(contactId);
        return null;
    }



    
////////////////////////////////////////////////////////////////////////////////////
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
                        alias = createAlias(con.firstName, con.lastName), 
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
         if(con.Preferred_Language__c!=null && languageMap.containsKey(con.Preferred_Language__c))
                user.languagelocalekey = languageMap.get(con.Preferred_Language__c);
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
        
        
        User newUser = createUser(con,userProfile);
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
            Comm_User_Helper.permissionASS(new list<Id>{newUser.Id});
            
        }else{
            system.debug('will update user with this profile id: ' + newUser.ProfileId);
            update newUser;
        }

    }
    
    public static void disabelUser(string contactId) {
        list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where contactId =:contactId];
        for(User u : usersToUpdate){
            if(u.IsActive || u.IsPortalEnabled ){
                u.IsActive = false;
            }
        }
        update usersToUpdate;
        update new Contact(Id=contactId,User_Portal_Status__c='');
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
    
/////////////////////////////////////////////////////////////////

    public static map<string,map<string,string>> actionsMap = new map<string,map<string,string>>{
            'New user' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'DoNothing',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Approved User' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'DoNothing',
                'Active' => 'DoNothing',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Active' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'DoNothing',
                'Active' => 'DoNothing',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Approved Admin' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'DoNothing',
                'Administrator' => 'DoNothing',
                'Regional Administrator' => 'DoNothing',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Administrator' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'DoNothing',
                'Administrator' => 'DoNothing',
                'Regional Administrator' => 'DoNothing',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Regional Administrator' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'DoNothing',
                'Regional Administrator' => 'DoNothing',
                'Pending Approval' => 'DoNothing',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Deactivated' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Deactivate' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Pending Approval' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'DoNothing',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'},
            'Rejected' => new map<string,string>{
                'New user'=>'DoNothing',
                'Approved User' => 'CreateNewUserWithCustomerProfile',
                'Active' => 'CreateNewUserWithCustomerProfile',
                'Approved Admin' => 'CreateNewUserWithPartnerProfile',
                'Administrator' => 'CreateNewUserWithPartnerProfile',
                'Regional Administrator' => 'CreateNewUserWithPartnerProfile',
                'Pending Approval' => 'CreateNewUserWithStandardProfile',
                'Deactivate' => 'DisableTheUser',
                'Deactivated' => 'DisableTheUser',
                'Rejected' => 'DisableTheUserReject'}
    };
    
////////////////////////////////////////////////////////////////////////////////////
    public interface IActions
    {
        void processAction(string conId);
    }
    
     
    public class DisableTheUser implements IActions
    {
        public void processAction(string conId)
        {
            Set <Id> teamMemberIdSet = new Set <Id>();
            list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled from User u where contactId =:conId];
            for(User u : usersToUpdate){
                teamMemberIdSet.add(u.Id);
            }
            if (!teamMemberIdSet.isEmpty()){
                delete [select Id from AccountTeamMember where UserId in:teamMemberIdSet and TeamMemberRole =:'Portal Administrator'];
            }
           futureDisabelUser(conId);
        }
    }
    
    public class CreateNewUserWithCustomerProfile implements IActions
    { 
        public void processAction(string conId)
        {
           string userType = ISSP_Utilities.getContactTypeById(conId);
           system.debug('CreateNewUserWithCustomerProfile userType: ' + userType);
           string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(userType);
           system.debug('CreateNewUserWithCustomerProfile profileName: ' + profileName);
           string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
           system.debug('CreateNewUserWithCustomerProfile profileId: ' + profileId);
           createNewUser(profileId,conId);
        }
    }
    
    public class CreateNewUserWithPartnerProfile implements IActions
    {
        public void processAction(string conId)
        {
           string userType = ISSP_Utilities.getContactTypeById(conId);
           string profileName = ISSP_Constant.profilNameByUserTypeMap.get('Admin').get(userType);
           string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
           createNewUser(profileId,conId);
        }
    }
    
    public class CreateNewUserWithStandardProfile implements IActions
    {
        public void processAction(string conId)
        {
           string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('Other');
           string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
           createNewUser(profileId,conId);
        }
    }
    
      
    public class DoNothing implements IActions
    {
        public void processAction(string conId)
        {
            
        }
    }
    
    ///////////////////////////////// Mass User Creation /////////////////////////////////
    public static map<string,string> languageMap = new map<string,string>{
                                                            'German' =>'de',
                                                            'English' =>'en_US',
                                                            'French' =>'fr',
                                                            'Italian' =>'it',
                                                            'Danish' =>'da',
                                                            'Spanish' =>'es',
                                                            'Dutch' =>'nl',
                                                            'Finnish' =>'fi',
                                                            'Portuguese' =>'pt',
                                                            'Swedish' =>'sv',
                                                            'Polish' =>'pl',
                                                            'Norweigian' =>'no',
                                                            'Chinese' =>'zh_CN',
                                                            'Japanese' =>'ja',
                                                            'Portuguese' =>'pt_BR'
                                                    };
     public static void maasUserCreation(list<Contact> vContactList, String communityName){ //CNS added parameter to change the email template, for cns users
        list<Contact> conList = vContactList.deepClone(true, false, false);
        map<Id,Contact> conMap = new map<Id,Contact>( [select Id,Account.RecordType.DeveloperName,Preferred_Language__c from Contact where Id in:conList]);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false; 
        dmo.EmailHeader.triggerOtherEmail = false; 
        dmo.EmailHeader.triggerAutoResponseEmail = false; 
        dmo.optAllOrNone = false; 
        list<User> UserList = new list <User>();
        
        for(Contact con:conList){
            con.Is_from_migration__c = false;
            string userType = ISSP_Constant.userTypeByAccountRtDeveloperNameMap.get(conMap.get(con.Id).Account.RecordType.DeveloperName);
            string profileName = ISSP_Constant.profilNameByUserTypeMap.get('Admin').get(userType);
            string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
            User user = createUser(con,profileId);
            
            if(con.Preferred_Language__c!=null && languageMap.containsKey(con.Preferred_Language__c))
                user.languagelocalekey = languageMap.get(con.Preferred_Language__c);
            user.setOptions(dmo);
            UserList.add(user);
        }
        if (!UserList.isEmpty()) {
            Database.SaveResult[] results = Database.insert(UserList, false);
           list<Messaging.SingleEmailMessage> ml = new list<Messaging.SingleEmailMessage>();
            EmailTemplate et = [Select e.Id, e.Name, e.DeveloperName From EmailTemplate e where DeveloperName=:'ISSP_New_Member_Welcome_Email'];
           if(communityName=='CNS'){ //
                et = [Select e.Id, e.Name, e.DeveloperName From EmailTemplate e where DeveloperName=:'ISSP_New_Member_Welcome_Email_CNS'];
           }           
                
            for(Database.SaveResult r:results){
                system.debug('\n\n\n'+r.getErrors()+'\n\n\n');
                system.debug('\n\n\n'+r.isSuccess()+'\n\n\n');
                system.debug('\n\n\n'+r.getId()+'\n\n\n');
                if(r.isSuccess()){
                    string password =  ISSP_Registration.generatePassword();
                    ISSP_Registration.passwordMap.put(r.getId(),password);
                    system.setPassword(r.getId(), password);
                    ml.add(createEmail( et.Id,r.getId(), communityName));
                }
            }
            Messaging.sendEmail(ml);
        }
        Database.SaveResult[] results = Database.update(conList, false);
        
     }
     
    @future(callout=true)
    public static void futureUpdateUsers(set<string> conIdSet) {
        map<Id,Contact> contactMap = new map<Id,Contact>([select Id,email,firstName,lastname,Title,Preferred_Language__c,Status__c from Contact where Id in:conIdSet]);
        if(!contactMap.values().isEmpty()){
            list<User> userList = [select Id,ContactId, ContactKaviId__c,languagelocalekey,email,firstname,lastname,Title,IsActive,IsPortalEnabled,username from User where ContactId in:contactMap.keySet() OR ContactKaviId__c in:contactMap.keySet()];
            for(User user : userList){
                //Code extension to consider internal users
                Contact con = new Contact();
                if (user.ContactId <> null)
                {
                    con = contactMap.get(user.ContactId);
                }
                if (user.ContactKaviId__c <> null)
                {
                    con = contactMap.get(user.ContactKaviId__c);   
                }

                user.firstname = con.firstName;
                user.lastname = con.lastname;
                user.Title = con.Title;
                if(con.Preferred_Language__c!=null && languageMap.containsKey(con.Preferred_Language__c))
                    user.languagelocalekey = ISSP_PortalUserStatusChange.languageMap.get(con.Preferred_Language__c);
                if(con.Status__c == 'Inactive' || con.Status__c == 'Retired' || con.Status__c == 'Left Company / Relocated' )
                    user.IsActive = false;
                else
                    user.IsActive = true;
             }

            ISSP_WS_KAVI.updateKaviUsers(conIdSet, userList);
            update userList;
            
        }
    }
    
    @future
    public static void futureDeactivateUsers(set<string> conIdSet) {
        list<User> userList = [select Id,IsActive,IsPortalEnabled from User where ContactId in:conIdSet OR ContactKaviId__c in:conIdSet];
        for(User user : userList){
             user.IsActive = false;
        }
        if(!userList.isEmpty())
            update userList;
    }
    
       public static Messaging.SingleEmailMessage createEmail(string templateId,string userId, string communityName){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(templateId);
            mail.setTargetObjectId(userId);
            mail.setSaveAsActivity(false); 
            if(communityName=='CNS'){
                mail.setReplyTo('cns_noreply@cnsc.us'); mail.setSenderDisplayName('CNS Portal ');
            }else{ mail.setReplyTo('noreply@iata.org'); mail.setSenderDisplayName('ISS Portal ');}            
            
            return mail;
       }
       
     public static String runAction(Id conId, String currentEmail, String theAction, String newValue, String inactiveReason, List<String> firstCommunity){
        ISSP_ContactList.avoidContactStatusTrigger = true;
        system.debug('firstCommunity: ' + firstCommunity);
        if(firstCommunity == null || firstCommunity.isEmpty()){        
            firstCommunity = new List<String>();   
            firstCommunity.add('');
            firstCommunity.add('');
            system.debug('firstCommunity!!!: ' + firstCommunity);
        }
        system.debug('runAction CONTACT ID: ' + conId);
        system.debug('runAction ACTION: ' + theAction);
        system.debug('runAction NEW STATUS: ' + newValue);
        system.debug('runAction inactiveReason: ' + inactiveReason);
        String errorMessageResult = '';
        if (theAction == 'DisableTheUser'){
            if (inactiveReason == '' || inactiveReason == null){
                errorMessageResult = 'Please provide a reason to inactivate this user';
                return errorMessageResult;
            }
            String thisEmail = currentEmail;
            List <Contact> conList = [SELECT Id, Status__c, Community__c, (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE NOT card_status__c like 'Cancelled%') FROM Contact WHERE Id = :conId];
            if (!conList.isEmpty()){
                try{
                    integer emailDigit = 0;
                    String newContactStatus = conList[0].Status__c;
                    if (inactiveReason == 'Retired'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Retired;
                        system.debug('currentEmail: ' + currentEmail);
                        emailDigit = ISSP_PortalUserStatusChange.inactiveEmailNumber(currentEmail);
                        system.debug('emailDigit: ' + emailDigit);
                        thisEmail = currentEmail + '.inactive';
                        if (emailDigit > 0)
                            thisEmail = thisEmail + String.valueOf(emailDigit);
                        system.debug('thisEmail: ' + thisEmail);
                        newContactStatus = 'Retired';
                    }
                    else if (inactiveReason == 'AccessDenied'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Denied;
                        newContactStatus = 'Active';
                    }
                    else if (inactiveReason == 'LeftCompany'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Left;
                        system.debug('currentEmail: ' + currentEmail);
                        emailDigit = ISSP_PortalUserStatusChange.inactiveEmailNumber(currentEmail);
                        system.debug('emailDigit: ' + emailDigit);
                        thisEmail = currentEmail + '.inactive';
                        if (emailDigit > 0)
                            thisEmail = thisEmail + String.valueOf(emailDigit);
                        system.debug('thisEmail: ' + thisEmail);
                        newContactStatus = 'Left Company / Relocated';
                    }
                    else if (inactiveReason == 'UnknownContact'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Unknown;
                        system.debug('currentEmail: ' + currentEmail);
                        emailDigit = ISSP_PortalUserStatusChange.inactiveEmailNumber(currentEmail);
                        system.debug('emailDigit: ' + emailDigit);
                        thisEmail = currentEmail + '.inactive';
                        if (emailDigit > 0)
                            thisEmail = thisEmail + String.valueOf(emailDigit);
                        system.debug('thisEmail: ' + thisEmail);
                        newContactStatus = 'Inactive';
                    }
                    conList[0].Contact_Old_Email__c = currentEmail;
                    conList[0].Status__c = newContactStatus;
                    conList[0].Email = thisEmail;
                    conList[0].User_Portal_Status__c = 'Deactivated'; 
                    update conList[0];
                    if (!conList[0].ID_Cards__r.isEmpty()){
                        List <ID_Card__c> idCardList = new List <ID_Card__c>();
                        for (ID_Card__c thisCard : conList[0].ID_Cards__r){
                            thisCard.Card_Status__c = 'Cancelled ID Card';
                            idCardList.add(thisCard);
                        }
                        update idCardList;
                    }
                }
                catch(Exception e){                    
                    return AMS_Utils.errorMessageBeautifyer(e);                     
                }
                
                List <User> userList = [select Id, ContactId, UserType from User where ContactId = :conId AND UserType = 'PowerPartner'];
                if (!userList.isEmpty()){
                    updateUser(conId, false, thisEmail, '', firstCommunity[0]);
                    ISSP_HierarchyAccountTeamAccounts.deleteHierarchyAccountTeamMemberAccounts(new Set<Id>{userList[0].Id});
                }
            }
        }
        else if (theAction == 'DisableTheUserReject'){
            if (inactiveReason == '' || inactiveReason == null){
                errorMessageResult = 'Please provide a reason to reject this user';
                return errorMessageResult;
            }
            String thisEmail = currentEmail;
            List <Contact> conList = [SELECT Id, Status__c, (SELECT Id, Valid_To_Date__c FROM ID_Cards__r WHERE NOT card_status__c like 'Cancelled%') FROM Contact WHERE Id = :conId];
            if (!conList.isEmpty()){
                try{
                    integer emailDigit = 0;
                    String newContactStatus = conList[0].Status__c;
                    if (inactiveReason == 'Retired'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Retired;
                        system.debug('currentEmail: ' + currentEmail);
                        emailDigit = ISSP_PortalUserStatusChange.inactiveEmailNumber(currentEmail);
                        system.debug('emailDigit: ' + emailDigit);
                        thisEmail = currentEmail + '.inactive';
                        if (emailDigit > 0)
                            thisEmail = thisEmail + String.valueOf(emailDigit);
                        system.debug('thisEmail: ' + thisEmail);
                        newContactStatus = 'Retired';
                    }
                    else if (inactiveReason == 'AccessDenied'){
                        newContactStatus = 'Active';
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Denied;
                    }
                    else if (inactiveReason == 'LeftCompany'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Left;
                        system.debug('currentEmail: ' + currentEmail);
                        emailDigit = ISSP_PortalUserStatusChange.inactiveEmailNumber(currentEmail);
                        system.debug('emailDigit: ' + emailDigit);
                        thisEmail = currentEmail + '.inactive';
                        if (emailDigit > 0)
                            thisEmail = thisEmail + String.valueOf(emailDigit);
                        system.debug('thisEmail: ' + thisEmail);
                        newContactStatus = 'Left Company / Relocated';
                    }
                    else if (inactiveReason == 'UnknownContact'){
                        conList[0].Portal_Inactivation_Reason__c = Label.ISSP_RejectReason_Unknown;
                        system.debug('currentEmail: ' + currentEmail);
                        emailDigit = ISSP_PortalUserStatusChange.inactiveEmailNumber(currentEmail);
                        system.debug('emailDigit: ' + emailDigit);
                        thisEmail = currentEmail + '.inactive';
                        if (emailDigit > 0)
                            thisEmail = thisEmail + String.valueOf(emailDigit);
                        system.debug('thisEmail: ' + thisEmail);
                        newContactStatus = 'Inactive';
                    }
                    conList[0].Contact_Old_Email__c = currentEmail;
                    conList[0].Status__c = newContactStatus;
                    conList[0].Email = thisEmail;
                    conList[0].User_Portal_Status__c = 'Rejected';
                    update conList[0];
                    if (!conList[0].ID_Cards__r.isEmpty()){
                        List <ID_Card__c> idCardList = new List <ID_Card__c>();
                        for (ID_Card__c thisCard : conList[0].ID_Cards__r){
                            thisCard.Card_Status__c = 'Cancelled';
                            idCardList.add(thisCard);
                        }
                        update idCardList;
                    }
                }
                catch(Exception e){
                    system.debug('ERROR: ' + e.getMessage());
                    errorMessageResult = e.getMessage();
                    return errorMessageResult;
                }
                
                List <User> userList = [select Id, ContactId, UserType from User where ContactId = :conId AND UserType = 'PowerPartner'];
                if (!userList.isEmpty()){
                    updateUser(conId, false, thisEmail, '', firstCommunity[0]);
                    ISSP_HierarchyAccountTeamAccounts.deleteHierarchyAccountTeamMemberAccounts(new Set<Id>{userList[0].Id});
                }
            }
        }
        else if (theAction == 'CreateNewUserWithCustomerProfile'){
            string userType = ISSP_Utilities.getContactTypeById(conId);
            string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(userType);
            string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
            List <Contact> conList = [SELECT Id, Status__c FROM Contact WHERE Id = :conId];

            if (!conList.isEmpty()){
                try{
                    conList[0].Status__c = 'Active';
                    conList[0].Email = currentEmail;
                    conList[0].User_Portal_Status__c = 'Approved User';
                    if(firstCommunity[1] != ''){                  
                        conList[0].Community__c = firstCommunity[1];
                    }else{
                        conList[0].Community__c = 'ISS Customer Portal';
                    }
                    update conList[0];
                }
                catch(Exception e){
                    system.debug('ERROR: ' + e.getMessage());
                    errorMessageResult = AMS_utils.errorMessageBeautifyer(e);
                    return errorMessageResult.remove('ERROR: ');
                }
                
                List <User> userList = [select Id, ContactId, UserType from User where ContactId = :conId AND UserType = 'PowerPartner'];
                if (!userList.isEmpty()){
                    updateUser(conId, true, currentEmail, profileId, firstCommunity[0]);
                    ISSP_HierarchyAccountTeamAccounts.deleteHierarchyAccountTeamMemberAccounts(new Set<Id>{userList[0].Id});
                }
                else{
                    createNewUser(profileId,conId);
                }
            }
        }
        else if (theAction == 'CreateNewUserWithPartnerProfile'){
            system.debug('ACTION: ' + theAction);
            string userType = ISSP_Utilities.getContactTypeById(conId);
            string profileName = ISSP_Constant.profilNameByUserTypeMap.get('Admin').get(userType);
            string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
            List <Contact> conList = [SELECT Id, Status__c FROM Contact WHERE Id = :conId];
            if (!conList.isEmpty()){
                try{
                    conList[0].Status__c = 'Active';
                    conList[0].Email = currentEmail;
                    conList[0].User_Portal_Status__c = 'Approved Admin';
                    if(firstCommunity[1] != '')                   
                        conList[0].Community__c = firstCommunity[1];
                    update conList[0];
                }
                catch(Exception e){
                    system.debug('ERROR: ' + e.getMessage());
                    errorMessageResult = AMS_utils.errorMessageBeautifyer(e);
                    return errorMessageResult.remove('ERROR: ');
                }
                
                List <User> userList = [select Id, ContactId, UserType from User where ContactId = :conId AND UserType = 'PowerPartner'];
                if (!userList.isEmpty()){
                    updateUser(conId, true, currentEmail, profileId, firstCommunity[0]);
                    ISSP_HierarchyAccountTeamAccounts.HierarchyAccountTeamMemberAccounts(new Set<Id>{userList[0].Id});
                }
                else{
                    createNewUser(profileId,conId);
                }
            }
        }
        else if (theAction == 'CreateNewUserWithStandardProfile'){
            system.debug('ACTION: ' + theAction);
            string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('Other');
            string profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
            List <Contact> conList = [SELECT Id, Status__c FROM Contact WHERE Id = :conId];
            if (!conList.isEmpty()){
                try{
                    conList[0].Status__c = 'Active';
                    conList[0].Email = currentEmail;
                    conList[0].User_Portal_Status__c = newValue;
                    if(firstCommunity[1] != '')                   
                        conList[0].Community__c = firstCommunity[1];
                    update conList[0];
                }
                catch(Exception e){
                    system.debug('ERROR: ' + e.getMessage());
                    errorMessageResult = e.getMessage();
                    return errorMessageResult;
                }
                
                List <User> userList = [select Id, ContactId, UserType from User where ContactId = :conId AND UserType = 'PowerPartner'];
                if (!userList.isEmpty()){
                    updateUser(conId, true, currentEmail, profileId, firstCommunity[0]);
                    ISSP_HierarchyAccountTeamAccounts.deleteHierarchyAccountTeamMemberAccounts(new Set<Id>{userList[0].Id});
                }
                else{
                    createNewUser(profileId,conId);
                }
            }
        }
        return errorMessageResult;
    }
     
     public PageReference saveNewStatus(){
        firstCommunity = new List<String>();
        errorMessages = new List<String>();
        for (SelectOption so : communityOptions){
            if (so.getValue() == selectedVal){
                firstCommunity.add(so.getValue());
                firstCommunity.add(so.getLabel());
            }
        }

        system.debug('firstCommunity: ' + firstCommunity);
        system.debug('userExists: ' + userExists);
        system.debug('createUser: ' + createUser);
        system.debug('con.User_Portal_Status__c: ' + con.User_Portal_Status__c);
        system.debug('con.Status__c: ' + con.Status__c);
        system.debug('CONTACT ID: ' + con.Id);
        List <Contact> contactList = [SELECT Id, User_Portal_Status__c, Email FROM Contact WHERE Id = :con.Id];
        system.debug('CURRENT STATUS: ' + contactList[0].User_Portal_Status__c);
        system.debug('NEW STATUS: ' + con.User_Portal_Status__c);
        String theAction = '';
        String newValue = con.User_Portal_Status__c;
        String oldValue = contactList[0].User_Portal_Status__c;
        if(newValue==''||newValue==null)
            newValue = 'New user';
        if(oldValue==''||oldValue==null)
            oldValue = 'New user';
        if(actionsMap.get(oldValue)==null)
            theAction = '';
        if(actionsMap.get(oldValue).get(newValue)==null)
            theAction = '';
        theAction = actionsMap.get(oldValue).get(newValue);
        system.debug('NEW VALUE: ' + newValue);
        system.debug('OLD VALUE: ' + oldValue);
        system.debug('ACTION: ' + theAction);
        
        //TF - S-01567 - If user has active services, cannot be inactivated
        if (theAction == 'DisableTheUser' || theAction == 'DisableTheUserReject'){
            List <Portal_Application_Right__c> appList =
                [SELECT Id, Application_Name__c FROM Portal_Application_Right__c
                WHERE Right__c = 'Access Granted' AND Contact__c = :con.Id
                AND Portal_Application__r.Critical_Service__c = true];
            if (!appList.isEmpty()){
                String message = Label.ISSP_UserInactivation_ServiceMsg_1;
                for (Portal_Application_Right__c thisAppRight : appList){
                    message += '<br/> - ' + thisAppRight.Application_Name__c;
                }
                message += Label.ISSP_UserInactivation_ServiceMsg_2;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,message);
                ApexPages.addMessage(myMsg);
                message += Label.ISSP_UserInactivation_ServiceMsg_3;
                errorMessages.add(message);
                return null;
            }
        }
        if (theAction == 'DisableTheUser'){ 
            contactStatus = inactivationReason;
        }
        else if (theAction == 'DisableTheUserReject'){
            contactStatus = rejectionReason;
        }
        system.debug('contactStatus: ' + contactStatus);
        Savepoint sPointContact = Database.setSavepoint();       
        String runActionResult = runAction(con.Id, contactList[0].Email, theAction, newValue, contactStatus, firstCommunity);
        
        if (runActionResult != ''){
            Database.rollback(sPointContact);
            if (portalUser){
                errorMessages.add('Error: ' + runActionResult);
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: ' + runActionResult);
                ApexPages.addMessage(myMsg);
            }
            return null;
        }
        else{
            if (portalUser){
             return new Pagereference('/ISSP_Contact?Id='+con.Id + commParam);
            }
            else{
                return new Pagereference('/'+con.Id);
            }
        }
    }
   
   
    public static integer inactiveEmailNumber(String currentEmail){
        system.debug('currentEmail: ' + currentEmail);
        String searchEmail = currentEmail + '.inactive%';
        system.debug('searchEmail: ' + searchEmail);
        integer emailInt = 0;
        List <Contact> contactList = [SELECT Id, Email FROM Contact WHERE Email LIKE :searchEmail ORDER BY Email DESC];
        List <User> userList = [SELECT Id, Email FROM User WHERE Email LIKE :searchEmail ORDER BY Email DESC];
        if (contactList.isEmpty() && userList.isEmpty()){
            system.debug('empte');
            return emailInt;
        }
        else{
            String emailString = currentEmail + '.inactive';
            String contactString = emailString.difference(contactList[0].Email);
            system.debug('contactString: ' + contactString);
            String userString = emailString.difference(userList[0].Email);
            system.debug('userString: ' + userString);
            integer contactNumber = 0;
            integer emailNumber = 0;
            if (contactString == '' || contactString == null){
                contactNumber = 0;
                system.debug('contactNumber: is 0');
            }
            else{
                contactNumber = Integer.valueOf(contactString) + 1;
                system.debug('contactNumber: ' + contactNumber);
            }
            if (userString == '' || userString == null){
                emailNumber = 0;
                system.debug('emailNumber: is 0');
            }
            else{
                emailNumber = Integer.valueOf(userString) + 1;
                system.debug('emailNumber: ' + emailNumber);
            }
            if (contactNumber > emailNumber){
                system.debug('return contact');
                return contactNumber;
            }
            else{
                system.debug('return email');
                return emailNumber;
            }
        }
        system.debug('return zero');
        return emailInt;
    }
    
    public static String removeInactiveEmail(String currentEmail){
        Integer myIndex = currentEmail.indexOf('.inactive');
        return currentEmail.left(myIndex);
    }
    
    @future
    public static void updateUser(String conId, Boolean isActive, String email, String profileId, String firstCommunity){
        updateUserSync(conId, isActive, email, profileId, firstCommunity);
    }

    /*** AMSU-163 ***/
    public static void updateUserSync(String conId, Boolean isActive, String email, String profileId, String firstCommunity){
        list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled, u.Email, u.Contact.Email, u.Community__c
                                     from User u where contactId =:conId];

        if (!usersToUpdate.isEmpty()){
            for(User u : usersToUpdate){
                u.IsActive = isActive;
                u.IsPortalEnabled = true;
                if (profileId != ''){
                    u.ProfileId = profileId;
                }
                u.Email = email;
                string userName = ISSP_Utilities.buildPortalUserName(email);
                u.Username = userName;
                if(firstCommunity != '')
                    u.Community__c = firstCommunity;
            }

            update usersToUpdate;
        }
    }
}
public with sharing class ISSP_EditPortalServiceAccess{

    public Portal_Application_Right__c PSA {get;set;}   
    public List<Portal_Application_Right__c> PortalServiceAccess_List {get;set;}
    public String Operation{get;set;}  
    public String AccessStatus{get;set;}  
    public boolean isAddUser{get;set;} 
    public String servName{get;set;} 
    public String ServiceId {get;set;} 
    public String grantReason {get;set;}
    public String denyReason {get;set;}
    //public List<SelectOption> RightsOptions  {get;set;}
    public String SelectedRightOption {get;set;}
    public boolean AdminCannotManage {get;set;} // ed sp9
    public String SelectedContacts {get;set;}
    
    public Boolean pendingApproval {get; set;}
    public Boolean noUser {get; set;}
    public Boolean inactiveUser {get; set;}
    public String contactStatus {get; set;}
    public Contact thisContact {get; set;}
    public list<String> errorMessage {get; set;}
    public list<String> contactIds {get; set;}
    public list<String> pendingApprovalIds {get; set;}
    public list<String> noUserIds {get; set;}
    public list<String> inactiveUserIds {get; set;}
    
    public Boolean usersToActivate {get; set;}
    public list<Contact> usersToActivateList {get; set;}
    public Boolean usersToCreate {get; set;}
    public list<Contact> usersToCreateList {get; set;}
    public Boolean otherUsers {get; set;}
    public list<Contact> otherUsersList {get; set;}
    public Boolean isEasyPayService {get; set;}
    public String portalServiceRole {get; set;}
    public List<SelectOption2> availablePortalServiceRoles {get; set;} 
    public Map<String, String> helpTextPortalRoles {get; set;}    

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    
    public List<SelectOption> getRightsOptions(){
        List<SelectOption> options = new List<SelectOption>();
            //options.add(new SelectOption('','-- None --'));
            options.add(new SelectOption('Access Granted','Access Granted'));
        return options;
    }

    public class SelectOption2 {
        public String value {get; set;}
        public String label {get; set;}
        public String helpText {get; set;}

        public SelectOption2(String value, String label, String helpText) {
            this.value = value;
            this.label = label;
            this.helpText = helpText;
        }
    }    

    public ISSP_EditPortalServiceAccess(){
        
        pendingApproval = false;
        noUser = false;
        inactiveUser = falsE;
        errorMessage = new list<string>();
        pendingApprovalIds = new list<string>();
        noUserIds = new list<string>();
        inactiveUserIds = new list<string>();
        usersToActivate = false;
        usersToCreate = false;
        otherUsers = false;
        
        string psaId = Apexpages.currentPage().getParameters().get('id');
        ServiceId = Apexpages.currentPage().getParameters().get('PSid');
        servName = Apexpages.currentPage().getParameters().get('PSname');
        
        isEasyPayService = false;

        this.helpTextPortalRoles = new Map<String, String>();

        Portal_Applications__c pa = [Select name From Portal_Applications__c where Id =: ServiceId];

        for(Connected_App_Roles__c role : Connected_App_Roles__c.getAll().values()){
            if(role.Connected_App__c.startsWith('IATA EasyPay')) {
                if(!this.helpTextPortalRoles.containsKey(role.Role__c)) {
                    String aux = role.Role__c.replaceAll(' ','');
                    String aux2 = aux.replaceAll('-','');

                    String helpText = Ams_Utils.getCustomLabel('ISSP_ANG_Portal_Role_' + aux2);

                    if(helpText == 'NONE') helpText = '';

                    this.helpTextPortalRoles.put(role.Role__c, helpText);

                }
            }
        }        

        if(servName != null && servName != ''){
            isAddUser = true ;
            if(servName.contains('EasyPay')) {
                isEasyPayService = true;
                Operation = Label.ANG_ISSP_IATA_EasyPay;
            } else {
                if(ServName.contains('IATA Accreditation')) {
                    Operation = Label.ISSP_Become_Accredited_Agent;
                } else {
                    Operation = servName;
                }
            }
        }

        availablePortalServiceRoles = new List<SelectOption2>();

        List<Connected_App_Roles__c> roles = [SELECT Default_User_Role__c, Role__c FROM Connected_App_Roles__c where Connected_App__c =: pa.name order by Order__c];
                
        for (Connected_App_Roles__c role : roles) {
            availablePortalServiceRoles.add(new SelectOption2(role.Role__c, role.Role__c, this.helpTextPortalRoles.get(role.Role__c)));
        }
        
        PortalServiceAccess_List = new List<Portal_Application_Right__c>(
            [Select p.Name, p.Application_Name__c, p.Right__c, p.PortalServiceTranslatedName__c , p.Portal_Application__r.Description__c,p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c, p.Portal_Application__r.Requestable__c, p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,
                    p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c,p.Contact__r.Name, p.Contact__r.AccountId, p.Application_Start_URL__c ,
                    p.Case_creation_record_Type__c,p.Access_Status_Reason__c, p.Contact__r.User_Portal_Status__c,ANG_Portal_Service_Role__c
             From Portal_Application_Right__c p 
             where p.Id = : psaId]
        );
        
        if( PortalServiceAccess_List != null && PortalServiceAccess_List .size() > 0){
            PSA = PortalServiceAccess_List[0];
            Operation = PSA.Application_Name__c;
            if(PSA.Application_Name__c.contains('EasyPay')){
                Operation = Label.ANG_ISSP_IATA_EasyPay;
            }else{
                Operation = PSA.Application_Name__c;        
            }
            AccessStatus = PSA.Right__c;
            AdminCannotManage = PSA.Portal_Application__r.Cannot_be_managed_by_portal_admin__c;
            
            List <Contact> contactList = [SELECT Id FROM Contact WHERE Id = :PSA.Contact__c];
            if (!contactList.isEmpty()){
                thisContact = contactList[0];
            }
            contactStatus = PSA.Contact__r.User_Portal_Status__c;
            if (contactStatus == 'Pending Approval'){
                pendingApproval = true;
                pendingApprovalIds.add(PSA.Contact__c);
            }
            else if (contactStatus == 'Inactive'
                    || contactStatus == 'Rejected'
                    || contactStatus == 'Deactivated'){
                inactiveUser = true;
                inactiveUserIds.add(PSA.Contact__c);
            }
            else{
                List <User> userList = [SELECT Id, IsActive FROM User WHERE ContactId = :PSA.Contact__r.Id];
                if (userList.isEmpty()){
                    noUser = true;
                    noUserIds.add(PSA.Contact__c);
                }
            }
        }else{
            PSA = new Portal_Application_Right__c ();
        }
    }
    
   /* public Pagereference SavePSA(){
        Pagereference p  = new Pagereference ('/apex/ISSP_PortalServiceAccess?Id='+PSA.Id );
        p.setredirect(true);
        
        try{
            update PSA;
        }catch (Exception e){
            System.debug('Error while updating PSA==>'+e);
        }
        return p;
    }
    
   
    public Pagereference CancelPSA(){
        Pagereference p;
        string retURL = Apexpages.currentPage().getParameters().get('retURL');
        system.debug('RETURL: ' + retURL);
        if (retURL != '' && retURL != null){
            p  = new Pagereference (retURL);
        }
        else{
            p  = new Pagereference ('/ISSP_PortalServiceAccess?Id='+PSA.Id );
        }
        p.setredirect(true);
        return p;
    }
    */
   
    public Pagereference AssignIFAPContact(){
        Pagereference p  = new Pagereference ('/ISSP_AssignFinancialContact?MainNav=Services&subNav=Access&mid=M4S2&id='+ PSA.Contact__r.AccountId + '&vContactId=' + PSA.Contact__c + '&vContactName=' + EncodingUtil.urlEncode(PSA.Contact__r.Name, 'UTF-8') + commParam);
        p.setredirect(true);
        return p;
      //return null;
    }
    
    public Pagereference DenyAccess(){
        Pagereference p  = new Pagereference ('/ISSP_EditPortalServiceAccess?&mid=M4S2&id='+ PSA.Id + commParam);
        String oldStatus = PSA.Right__c;
        String oldReason = PSA.Access_Status_Reason__c;
        PSA.Right__c = 'Access Denied';
        PSA.Access_Status_Reason__c = denyReason;
        try{
            update PSA;
        }
        catch(Exception e){
            errorMessage = new List<String>(); errorMessage.add(e.getdmlMessage(0));
            PSA.Right__c = oldStatus; PSA.Access_Status_Reason__c = oldReason;
            return null;
        }
        p.setredirect(true);
        return p;
    }
    
    public Pagereference GrantAccess(){
        Pagereference p  = new Pagereference ('/ISSP_EditPortalServiceAccess?&mid=M4S2&id='+ PSA.Id + commParam);
        String oldStatus = PSA.Right__c;
        String oldReason = PSA.Access_Status_Reason__c;
        PSA.Right__c = 'Access Granted';
        PSA.Access_Status_Reason__c = grantReason;
        system.debug('grantReason: ' + grantReason);
        try{
            update PSA;
        }
        catch(Exception e){
            errorMessage = new List<String>(); errorMessage.add(e.getdmlMessage(0));
            PSA.Right__c = oldStatus; PSA.Access_Status_Reason__c = oldReason;
            return null;
        }
        
        if (pendingApproval){
            if (thisContact != null){
                thisContact.User_Portal_Status__c = 'Approved User';
                update thisContact;
                ISSP_EditPortalServiceAccessExt.updateUserProfile(thisContact.Id);
            }
        }
        else if (noUser){
            if (thisContact != null){
                List<Contact> cls = new List<Contact>();
                cls.add(thisContact);
                ISSP_ContactList ctrl = new ISSP_ContactList();
                ctrl.processMultiplePortalUserStatusChange(cls, 'Approved User', 'Active');
            }
        }
        
        p.setredirect(true);
        return p;
    }
    
    ///////////////Create new PSA  Section ///////////////
    
    public PageReference confirmContacts(){
        usersToActivate = false;
        usersToCreate = false;
        otherUsers = false;
        system.debug('SelectedContacts: ' + SelectedContacts);
        List<string> selectedContact_Lst = SelectedContacts.substring(1,SelectedContacts.length() -1).split(',');
        Set <String> contactIdSet = new Set <String>();
        usersToActivateList = new List <Contact>();
        usersToCreateList = new List <Contact>();
        otherUsersList = new List <Contact>();
        system.debug('selectedContact_Lst: ' + SelectedContacts);

        for(String ContactId : selectedContact_Lst){
            system.debug('adding: ' + ContactId);
            contactIdSet.add(ContactId.trim());
        }
        system.debug('contactIdSet: ' + contactIdSet);
        List <Contact> processContactList = [SELECT Id, User_Portal_Status__c, Name FROM Contact WHERE Id IN :contactIdSet];
        for (Contact thisContact : processContactList){
            system.debug('User_Portal_Status__c: ' + thisContact.User_Portal_Status__c);
            if (thisContact.User_Portal_Status__c == 'Pending Approval'){
                usersToActivate = true;
                usersToActivateList.add(thisContact);
            }
            else if (thisContact.User_Portal_Status__c == '' || thisContact.User_Portal_Status__c == null){
                usersToCreate = true;
                usersToCreateList.add(thisContact);
            }
            else{
                otherUsers = true;
                otherUsersList.add(thisContact);
            }
        }
        system.debug('usersToActivateList: ' + usersToActivateList);
        system.debug('usersToCreateList: ' + usersToCreateList);
        system.debug('otherUsersList: ' + otherUsersList);

        return null;
    }

    public Pagereference activateUsers() {
        if(isEasyPayService) {
            //
            // If we are adding contacts to easyPay then we must check if the user is still active. Users that don't log in into the portal
            // for a certain amount of time get deactivated. The EASYPAY process will perform a user provisioning on the vendor's system and for
            // that all users must be active.
            //
            List<String> selectedContact_Lst = getSelectedContactsList();

            List<User> usersList = [select id, isActive, contactId from User where contactId in : selectedContact_Lst];
            List<User> usersToActivate = new List<User>();

            for(User user : usersList) {
                if(!user.isActive) {
                    user.isActive = true;
                    usersToActivate.add(user);
                }
            }

            if(usersToActivate.size() != 0) {
                update usersToActivate;
            }
        } 

        return null;       
    }
    
    public List<String> getSelectedContactsList() {
        List<String> selectedContact_Lst = new List<String>();

        List<String> selectedContact_Lst_aux = SelectedContacts.substring(1,SelectedContacts.length() -1).split(',');

        for(String s : selectedContact_Lst_aux) {
            selectedContact_Lst.add(s.trim());
        }
        return selectedContact_Lst;        
    }


    public Pagereference CreateNewPortalAccess() {

        List<String> selectedContact_Lst = getSelectedContactsList();

        List<Portal_Application_Right__c> ContactToAdd_Lst = new List<Portal_Application_Right__c>();

        Set <String> contactIdSet = new Set <String>();

        String auxRight;

        if(selectedContact_Lst.size()>0)
        {
            List<Portal_Application_Right__c> existPSA_Lst = new List<Portal_Application_Right__c>(
                [Select p.Name, p.Application_Name__c, p.Right__c,p.PortalServiceTranslatedName__c ,  p.Portal_Application__r.Description__c, p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c , p.Portal_Application__r.Requestable__c, p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,
                        p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c,p.Contact__r.Name, p.Contact__r.AccountId, p.Application_Start_URL__c ,
                        p.Case_creation_record_Type__c,p.Access_Status_Reason__c
                 From Portal_Application_Right__c p 
                 where p.Contact__c IN: selectedContact_Lst AND
                 p.Portal_Application__c =: ServiceId] 
            );
            System.debug('SFF existPSA_Lst'+existPSA_Lst);

            for(String ContactId : selectedContact_Lst){
                System.debug('SFF ContactId'+ContactId.trim());
                System.debug('SFF ServiceId'+ServiceId.trim());
                
                contactIdSet.add(ContactId.trim());

                if(isEasyPayService) {
                    auxRight = 'Access Requested';
                } else {
                    auxRight = 'Access Granted';
                }

                boolean isUpdated = false ;
                if(existPSA_Lst != null & existPSA_Lst.size() > 0 ){
                    for(Portal_Application_Right__c itemPSA : existPSA_Lst){
                            System.debug('SFF IF INNN');
                            itemPSA.Right__c = auxRight;
                            isUpdated = true ;
                            itemPSA.ANG_Portal_Service_Role__c = portalServiceRole;
                    }
                }

                 System.debug('SFF isUpdated'+isUpdated);
                if(isUpdated == false){
                    Portal_Application_Right__c PSAitem = new Portal_Application_Right__c();
                    
                    PSAitem.Portal_Application__c = ServiceId ;
                    PSAitem.Right__c = auxRight;
                    PSAitem.ANG_Portal_Service_Role__c = portalServiceRole;

                    System.debug('SFF ContactId'+ContactId);

                    PSAitem.Contact__c = Id.valueOf(ContactId.trim()) ;

                    //System.debug('ZzZz PSA==>'+PSA);
                    System.debug('SFF PSAitem'+PSAitem);

                    ContactToAdd_Lst.add(PSAitem);
                }
            }
            
            List <Contact> processContactList = [SELECT Id, User_Portal_Status__c, Name, Email FROM Contact WHERE Id IN :contactIdSet];
            List <String> activateIdList = new List <String>();
            List<Contact> cls = new List<Contact>();
            for (Contact thisContact : processContactList){
                system.debug('User_Portal_Status__c: ' + thisContact.User_Portal_Status__c);
                if (thisContact.User_Portal_Status__c == 'Pending Approval'){
                    activateIdList.add(thisContact.Id);
                    thisContact.User_Portal_Status__c = 'Approved User';
                }
                else if (thisContact.User_Portal_Status__c == '' || thisContact.User_Portal_Status__c == null){
                    cls.add(thisContact);
                }
            }

            if (!activateIdList.isEmpty()){
                ISSP_EditPortalServiceAccessExt.updateUserProfiles(activateIdList);
                update processContactList;
            }

            if (!cls.isEmpty()){
                ISSP_ContactList ctrl = new ISSP_ContactList();
                ctrl.processMultiplePortalUserStatusChange(cls, 'Approved User', 'Active');
            }

            //
            // Save all the Portal_Application_Right__c after creating the users.
            // This is important for all EASY PAY services because they need to have the portal users.
            //
            if(ContactToAdd_Lst != null && ContactToAdd_Lst.size() > 0) {
                insert ContactToAdd_Lst ;
            }

            if(existPSA_Lst != null && existPSA_Lst.size() > 0) {
                update existPSA_Lst ;
            }

        }
        Pagereference p  = new Pagereference ('/apex/ISSP_PortalService?Id='+ ServiceId + commParam);
        p.setredirect(true);
        return p;
    }

    public Pagereference RedirectToService(){       
        Pagereference p  = new Pagereference ('/apex/ISSP_PortalService?Id='+ ServiceId + commParam);
        p.setredirect(true);
        return p;
    }
    
    public List<List<SelectOption>> getContacts() {
        List<List<SelectOption>> options = new List<List<SelectOption>>();
        List<List<Contact>> NotGrantedContacts_Lst = new List<List<Contact>>();
        List <Contact> ContactList2 = new List<Contact>();
        List <Contact> ContactList3 = new List<Contact>();
        List <Contact> ContactList4 = new List<Contact>();
        List <Contact> ContactList5 = new List<Contact>();

        List<SelectOption> none = new List<SelectOption>();
        none.add(new SelectOption('', '--None--'));
        options.add(none);
        //INC314232: for governator limits we are creating 5 lists for limiting 1k contacts per list
        List <Contact> ContactList1 =
            [SELECT Id, Name , AccountId,
            (select id, Right__c from Portal_Application_Rights__r where Portal_Application__c = :ServiceId),
            Contact.IATA_Code__c , Account.IATA_ISO_Country__r.Name , Account.BillingCity ,
            Account.IATACode__c  from Contact
            WHERE User_Portal_Status__c NOT IN ('Inactive', 'Rejected', 'Deactivated')
            AND Community__c != null
            AND Email != null
            order by name
            Limit 1000];          
        
        NotGrantedContacts_Lst.add(NotGrantedContacts(ContactList1));
        if(ContactList1.size() == 1000 || Test.isRunningTest()){
            ContactList2=
            [SELECT Id, Name , AccountId,
            (select id, Right__c from Portal_Application_Rights__r where Portal_Application__c = :ServiceId),
            Contact.IATA_Code__c , Account.IATA_ISO_Country__r.Name , Account.BillingCity ,
            Account.IATACode__c  from Contact
            WHERE User_Portal_Status__c NOT IN ('Inactive', 'Rejected', 'Deactivated')
            AND Community__c != null
            AND Email != null            
            order by name
            Limit 1000
            OFFSET 1000
            ];
            NotGrantedContacts_Lst.add(NotGrantedContacts(ContactList2));
        }
        if(ContactList2.size() == 1000 || Test.isRunningTest()){
            ContactList3 =
            [SELECT Id, Name , AccountId,
            (select id, Right__c from Portal_Application_Rights__r where Portal_Application__c = :ServiceId),
            Contact.IATA_Code__c , Account.IATA_ISO_Country__r.Name , Account.BillingCity ,
            Account.IATACode__c  from Contact
            WHERE User_Portal_Status__c NOT IN ('Inactive', 'Rejected', 'Deactivated')
            AND Community__c != null
            AND Email != null            
            order by name
            Limit 1000
            OFFSET 2000
            ];
            NotGrantedContacts_Lst.add(NotGrantedContacts(ContactList3));
        }
        if(ContactList3.size() == 1000){
            ContactList4 =
            [SELECT Id, Name , AccountId,
            (select id, Right__c from Portal_Application_Rights__r where Portal_Application__c = :ServiceId),
            Contact.IATA_Code__c , Account.IATA_ISO_Country__r.Name , Account.BillingCity ,
            Account.IATACode__c  from Contact
            WHERE User_Portal_Status__c NOT IN ('Inactive', 'Rejected', 'Deactivated')
            AND Community__c != null
            AND Email != null            
            order by name
            Limit 1000
            OFFSET 3000];
            NotGrantedContacts_Lst.add(NotGrantedContacts(ContactList4));
        }
         if(ContactList4.size() == 1000){
            ContactList5 =
            [SELECT Id, Name , AccountId,
            (select id, Right__c from Portal_Application_Rights__r where Portal_Application__c = :ServiceId),
            Contact.IATA_Code__c , Account.IATA_ISO_Country__r.Name , Account.BillingCity ,
            Account.IATACode__c  from Contact
            WHERE User_Portal_Status__c NOT IN ('Inactive', 'Rejected', 'Deactivated')
            AND Community__c != null
            AND Email != null            
            order by name
            Limit 1000
            OFFSET 4000];
            NotGrantedContacts_Lst.add(NotGrantedContacts(ContactList5));
        }


        if(NotGrantedContacts_Lst!= null && NotGrantedContacts_Lst.size() >0 ){
            for(List<Contact> listContact : NotGrantedContacts_Lst ){
                List<SelectOption> listAux = new List<SelectOption>();
                for(Contact thisContact : listContact ){
                    String theLabel = thisContact.Name + ' (';
                    if (thisContact.Account.IATACode__c != null && thisContact.Account.IATACode__c != ''){
                            theLabel = theLabel + '    ' + thisContact .Account.IATACode__c;
                    }
                    if (thisContact.Account.IATA_ISO_Country__r.Name != null && thisContact.Account.IATA_ISO_Country__r.Name != ''){
                            theLabel = theLabel + '    ' + thisContact.Account.IATA_ISO_Country__r.Name;
                    }
                    if (thisContact.Account.BillingCity != null && thisContact.Account.BillingCity != ''){
                            theLabel = theLabel + ' - ' + thisContact.Account.BillingCity;
                    }                    
                    theLabel += ')' ;
                    if (thisContact.Portal_Application_Rights__r.size()>0){
                            theLabel = theLabel + '    ' + thisContact.Portal_Application_Rights__r[0].Right__c;
                    }                                        
                    listAux.add(new SelectOption(thisContact.Id, theLabel));
                }
                options.add(listAux);
            }
        }
        return options;
    }

    private List<Contact> NotGrantedContacts(List<Contact> contactList){
        List<Contact> cAux = new List<Contact>();
        for(Contact thisContact : contactList){
            boolean isGranted = false ;
            for(Portal_Application_Right__c APR : thisContact.Portal_Application_Rights__r){
                if(APR.Right__c == 'Access Granted'){
                    isGranted = true ;
                }
            }
            if(isGranted != true){
                cAux.add(thisContact);
            }
        }
        return cAux;   
    }    
}

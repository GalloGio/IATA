public class ISSP_Contact{

    public List<Contact> contactList {get;set;}
    public Contact Contact{get;set;}
    public List<ServiceWrapper> appsGrantedList {get {return getAppsGrantedListAux();} set;}
    public boolean isIATAAgencyAcct {get;set;}
    public boolean isPortalAdminUser {get;set;}
    public boolean isEditMode {get;set;}
    public String userPortalStatus {get;set;}
    public list<String> errorMessage {get; set;}
    public Boolean isEasyPay {get;set;}    
    public String denyReason {get;set;} 
    public String grantReason {get;set;}
    public boolean pollerOn {get; set;}
    public String contactStatus {get; set;}
    public Datetime timeStamp {get; set;}
    public String serviceId {get;set;} 
    public String serviceName {get;set;} 
    public String contactId {get;set;}
    public String contactIdParam {get;set;} 
    public String psId {get;set;}    

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    
    public ISSP_Contact(){
        isEditMode = false;
        
        //Only these 2 types of Agency Accounts can have Financial Contacts
        isIATAAgencyAcct = false;
                
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            //Verify if user is a Portal Admin
            if(profileName.equals('ISS Portal Agency Delegated Admin User') ){  isPortalAdminUser= true; }
        
        contactIdParam = Apexpages.currentPage().getParameters().get('id');
        
        string action = Apexpages.currentPage().getParameters().get('action');
        if (action == 'edit'){
            isEditMode = true;
        }

        User user = [SELECT id, Contact.User_Portal_Status__c from User where id =:UserInfo.getUserId()];
        if(user != null){
            userPortalStatus = user.Contact.User_Portal_Status__c;
        }
        
        contactList =new List<Contact>([select Id , Name , Email , Phone ,OtherPhone,
                                               User_Portal_Status__c , Fax, MobilePhone, ISO_Country__c,
                                               ISSP_Account_Name__c, Account_HQ_BO__c, IATA_Code__c,
                                               Title, Membership_Function__c  , AccountId , Financial_Assessment_Contact__c,
                                               Account.Name, Account.Category__c, Account.Location_Type__c,
                                               Salutation, FirstName, LastName, Account.IATA_ISO_Country__r.Name,
                                               Invoicing_Contact__c, BSP_CASS_Payment_contact__c, Services__c, 
                                               Airline_Contact_Type__c,Authorized_Signatory__c                                        
                                          From Contact
                                         Where Id =: contactIdParam ]);
                                                   
        if(contactList != null && contactList.size() > 0){
            Contact = contactList [0];
        }
        
         if (Contact.Account.Category__c=='IATA Passenger Sales Agent' || Contact.Account.Category__c=='IATA Cargo Agent')
            isIATAAgencyAcct = true;
        
        //Verify User Profile
        isPortalAdminUser = false;
        
        String currentUserProfileId = UserInfo.getProfileId();
        List <Profile> profileList = [SELECT Name FROM Profile WHERE Id = :currentUserProfileId];

        if (!profileList.isEmpty()){
            String currentUserProfileName = profileList[0].Name;
            system.debug('currentUserProfileName: ' + currentUserProfileName);
            if (currentUserProfileName.contains('dmin'))
                isPortalAdminUser = true;
            else
                isPortalAdminUser = false;
        }         
    }
    
    public List<ServiceWrapper> getAppsGrantedListAux() {

        List<ServiceWrapper> appsGrantedList = new List<ServiceWrapper>();

        List<Portal_Application_Right__c> auxServicesList;

        auxServicesList = new List<Portal_Application_Right__c>([Select p.Id, p.Application_Name__c, p.ANG_Portal_Service_Role__c,
                                                                        p.Portal_Application__r.Service_Description__c,
                                                                        p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c,
                                                                        p.Portal_Application__r.ServiceName__c, p.Portal_Application__r.Description__c,
                                                                        p.Portal_Application__r.Requestable__c, p.Application_icon_del__c, 
                                                                        p.Portal_Application__r.New_Window__c, p.Right__c, 
                                                                        p.Portal_Application__r.Application_icon_URL__c, 
                                                                        p.Portal_Application__r.Name, p.Portal_Application__c,
                                                                        p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c,
                                                                        p.Contact__r.User_Portal_Status__c,
                                                                        p.Contact__r.name,
                                                                        p.Account__c,
                                                                        p.Case_creation_record_Type__c, p.Portal_Application__r.Application_icon__c
                                                                   From Portal_Application_Right__c p 
                                                                  Where p.Contact__c =: Contact.id
                                                                    And (p.Right__c = 'Access Granted' Or p.Right__c = 'Access Requested')
                                                                    And p.Portal_Application__r.Hide_on_Homepage__c = false]); 

        Set<String> contactIds = new Set<String>();
        for (Portal_Application_Right__c par : auxServicesList) {
            contactIds.add(par.contact__c);
        }

        List<User> userList = [SELECT Id, IsActive, ContactId FROM User WHERE ContactId IN :contactIds];

        Map<String, String> userContact = new Map<String, String>();
        for(User u : userList) {
            userContact.put(u.contactId, u.id);
        }        

        isEasyPay = false;
        if(!auxServicesList.isEmpty()) {
            isEasyPay = auxServicesList[0].Application_Name__c.startsWith('IATA EasyPay');            
        }

        for(Portal_Application_Right__c par : auxServicesList) {
            ServiceWrapper sw = new ServiceWrapper();
            sw.par = par;

            String contactStatus = par.Contact__r.User_Portal_Status__c;

            sw.cannotBeManagedByPortalAdmin = par.Portal_Application__r.Cannot_be_managed_by_portal_admin__c;
            sw.isEasyPayService = ANG_ISSP_PortalServiceHelper.isIepPortalService(par.Application_Name__c);

            sw.hide = ((sw.isEasyPayService && !sw.cannotBeManagedByPortalAdmin) ||
                       (sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin && par.right__c != 'Access Granted') ||
                       (!sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin)
                      );

            if (contactStatus == 'Pending Approval') {
                sw.contactStatus = 'PA';
            } else if (contactStatus == 'Inactive' || contactStatus == 'Rejected' || contactStatus == 'Deactivated') {
                sw.contactStatus = 'IN';
            } else if (!userContact.containsKey(par.Contact__c)) {
                sw.contactStatus = 'NO';
            } 

            sw.showGrant = false;
            sw.showDeny = false;
            sw.showIfap = false;

            if(sw.isEasyPayService) {
                if(sw.cannotBeManagedByPortalAdmin && par.right__c == 'Access Granted') {
                    sw.showDeny = true;
                }
            } else {
                if(!sw.cannotBeManagedByPortalAdmin) {                
                    if(par.Application_Name__c == 'IFAP') {
                        sw.showIfap = true;
                        if(par.right__c == 'Access Requested') {
                            sw.showDeny = true;
                        }
                    } else if(par.right__c == 'Access Denied') {
                        sw.showGrant = true;
                    } else  if(par.right__c == 'Access Requested') {
                        sw.showGrant = true;
                        sw.showDeny = true;
                    } else {
                        sw.showDeny = true;
                    }
                }
            }
               
            appsGrantedList.add(sw);
        }

        return appsGrantedList;
    }

    public Pagereference edit(){
        isEditMode = true;
        return null;
    }
    
    public Pagereference save(){
        try {
                upsert Contact;
                return new Pagereference('/ISSP_Contact?id='+ Contact.Id + '&mid=M4S1' + commParam);
            } catch (DmlException ex) {
                ApexPages.addMessages(ex);
                }
      return null;
     }
    
    public Pagereference cancel(){
        string retURL = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL != null && retURL != '')
                return new Pagereference(retURL);
        else
                isEditMode = false;
                return null;
    }
    
    public Pagereference AssignIFAPContact(){
        Pagereference p  = new Pagereference ('/ISSP_AssignFinancialContact?id='+contact.AccountId + '&vContactId=' + contact.Id + commParam +'&vContactName=' + EncodingUtil.urlEncode(contact.Name, 'UTF-8'));
        p.setredirect(true);
        return p;
    }
    
    /**
        Send to another page to relocate user (change its parent account)
    **/
    public Pagereference RelocateContact(){
        Pagereference p  = new Pagereference ('/ISSP_RelocateContact?id='+contact.Id + '&mid=M4S1');
        p.setredirect(true);
        return p;
    }
    
    public Pagereference ChangePortalStatus(){
        try {
            errorMessage = new list<string>();
            Pagereference p  = new Pagereference ('/ISSP_PortalUserStatusChange?id='+ contact.Id + commParam);
            p.setredirect(true);
            return p;
        } catch(Exception exp) {
            ISSP_Utilities.exceptionDump(exp);
        }
        return null;
    }

    public class ServiceWrapper {
        public Portal_Application_Right__c par {get; set;}
        public String contactStatus {get; set;}
        public Boolean cannotBeManagedByPortalAdmin {get; set;}
        public Boolean isEasyPayService {get; set;}
        public boolean hide {get; set;}
        public boolean showGrant {get; set;}
        public boolean showDeny {get; set;}
        public boolean showIfap {get; set;}        
    }

    public Pagereference denyAccess() {

        Portal_Application_Right__c psa;

        pollerOn = true;

        List<Portal_Application_Right__c> psal = [Select Id, Right__c, Access_Status_Reason__c,
                                                         LastModifiedDate 
                                                    From Portal_Application_Right__c
                                                   Where Portal_Application__c =: serviceId
                                                     And Contact__c =: contactId];


        if(psal.size() != 0) {
            psa = psal[0];
        }

        if(psa == null) {
            System.debug(LoggingLevel.ERROR, 'PSA is null [serviceId : ' + serviceId + ' - contactId : ' + contactId + ']');            
            errorMessage = new List<String>(); errorMessage.add(Label.ISSP_ANG_GenericError);
        } else {
            this.timeStamp = psa.LastModifiedDate;                                              

            psa.Right__c = 'Access Denied';

            psa.Access_Status_Reason__c = denyReason;

            try {
                update psa;

                this.denyReason = '';
                this.grantReason = '';

            } catch(Exception e) {
                errorMessage = new List<String>(); errorMessage.add(e.getdmlMessage(0));
            }
        }

        return null;
    }    
   
    public Pagereference grantAccess() {

        Portal_Application_Right__c psa;

        pollerOn = true;

        List<Portal_Application_Right__c> psal = [Select Id, Right__c, Access_Status_Reason__c,
                                                         LastModifiedDate 
                                                    From Portal_Application_Right__c
                                                   Where Portal_Application__c =: serviceId
                                                     And Contact__c =: contactId];

        if(psal.size() != 0) {
            psa = psal[0];
        }

        if(psa == null) {
            System.debug(LoggingLevel.ERROR, 'PSA is null (2) [serviceId : ' + serviceId + ' - contactId : ' + contactId + ']');            
            errorMessage = new List<String>(); errorMessage.add(Label.ISSP_ANG_GenericError);
            
        } else {
            Contact contact = null;

            List<Contact> cl = [Select Id, User_Portal_Status__c, Email, Name From Contact Where id =: contactId];

            if(cl.size() != 0) {
                contact = cl[0];
            }

            if (this.contactStatus == 'PA') {
                // Pending Approval
                if (contact != null) {
                    contact.User_Portal_Status__c = 'Approved User';
                    update contact;
                    ISSP_EditPortalServiceAccessExt.updateUserProfile(contact.Id);
                }
            } else if (this.contactStatus == 'NO') {
                // No USer
                if (contact != null) {
                    Set <Id> idSet = new Set <Id>();
                    idSet.add(contact.Id);

                    ISSP_ContactList ctrl = new ISSP_ContactList();

                    ctrl.processMultiplePortalUserStatusChange(idSet, 'Approved User', 'Active');
                }
            }

            this.timeStamp = psa.LastModifiedDate;

            psa.Right__c = 'Access Granted';
            psa.Access_Status_Reason__c = grantReason;

            try {          
                update psa; 

                this.denyReason = '';
                this.grantReason = '';

            } catch(Exception e) {
                errorMessage = new List<String>(); errorMessage.add(e.getdmlMessage(0));
            }
        }

        return null;
    }

    public PageReference permissionSetPoller() {

        if(errorMessage != null) {
            pollerOn = false;
        } else {
            List<Portal_Application_Right__c> psal = [Select Id, Right__c, Access_Status_Reason__c,
                                                             LastModifiedDate 
                                                        From Portal_Application_Right__c
                                                       Where Portal_Application__c =: serviceId
                                                         And Contact__c =: contactId];

            Portal_Application_Right__c psa = null;

            if(psal.size() != 0) {
                psa = psal[0];
            }

            if(psa == null) {
                System.debug(LoggingLevel.ERROR, 'PSA is null (3) [serviceId : ' + serviceId + ' - contactId : ' + contactId + ']');            
                errorMessage = new List<String>(); errorMessage.add('And error has occured');
                pollerOn = false;
            } else {
                if(psa.LastModifiedDate > this.timeStamp) {
                    pollerOn = false;
                }
            }
        }
        return null;
    }    

    public Pagereference refreshList() {
        pollerOn = false;
        appsGrantedList = null;
        return null;
    }        

}
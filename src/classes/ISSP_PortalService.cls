public with sharing class ISSP_PortalService{

    public List<Portal_Applications__c> PortalService_List {get;set;}
    public Portal_Applications__c PortalService {get;set;}
    public List<ServiceWrapper> appsGrantedList {get {return getAppsGrantedListAux();} set;}
    public List<Contact> contactList {get;set;}
    public Boolean isEasyPay {get;set;}
    public String denyReason {get;set;} 
    public String grantReason {get;set;}
    public boolean pollerOn {get; set;}
    public list<String> errorMessage {get; set;}
    public String contactStatus {get; set;}
    public Datetime timeStamp {get; set;}
    public String serviceId {get;set;} 
    public String serviceName {get;set;} 
    public String contactId {get;set;}
    public String psId {get;set;}
    public boolean canAddUsers {get; set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    
    public ISSP_PortalService() {

        this.canAddUsers = false;
    
        pollerOn = false;

        psId = Apexpages.currentPage().getParameters().get('id');

        PortalService_List =new List<Portal_Applications__c >([select id , Name, ServiceName__c ,Service_Description__c ,Application_icon__c, Service_Description_Label__c, 
                                                               Cannot_be_managed_by_portal_admin__c
                                                   From Portal_Applications__c 
                                                   Where Id =: psId ]);
                                                   
        if(PortalService_List != null && PortalService_List .size() > 0){
            PortalService = PortalService_List [0];

            this.canAddUsers = (PortalService.Cannot_be_managed_by_portal_admin__c == false && PortalService.ServiceName__c != 'IFAP');
        }
    }


    public List<ServiceWrapper> getAppsGrantedListAux() {

        List<ServiceWrapper> appsGrantedList = new List<ServiceWrapper>();

        List<Portal_Application_Right__c> auxServicesList;
        
        auxServicesList = new List<Portal_Application_Right__c>([Select p.Application_Name__c, p.Portal_Application__r.Service_Description__c, p.Portal_Application__r.Service_Description_Label__c,
                                                                p.Portal_Application__r.Requestable__c,
                                                                p.Portal_Application__r.Cannot_be_managed_by_portal_admin__c,
                                                                p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,
                                                                p.Right__c, p.Portal_Application__r.Application_icon_URL__c,
                                                                p.Portal_Application__r.Name, p.Portal_Application__c,
                                                                p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c,
                                                                p.Case_creation_record_Type__c,
                                                                p.Contact__r.Id, p.Contact__r.Name, p.Contact__r.Email,
                                                                p.Contact__r.AccountId, p.Contact__r.FirstName,
                                                                p.Contact__r.LastName, p.Contact__r.Account.Name,
                                                                p.ANG_Portal_Service_Role__c,
                                                                p.Contact__r.User_Portal_Status__c,
                                                                p.Account__c
                                                                From Portal_Application_Right__c p 
                                                                where p.Portal_Application__c=: psId 
                                                                and (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested')
                                                                and p.Portal_Application__r.Hide_on_Homepage__c = false]);

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
    
    public PageReference RedirectToServiceAccess(){ 
        PageReference p = new PageReference ('/apex/ISSP_EditPortalServiceAccess?PSname=' +PortalService.Name + ' &PSid='+PortalService.Id + commParam); 
        p.setRedirect(true);
        return p;
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
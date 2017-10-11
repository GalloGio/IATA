public with sharing class ISSP_PortalService{

    public List<Portal_Applications__c> PortalService_List {get;set;}
    public Portal_Applications__c PortalService {get;set;}
    public List<Portal_Application_Right__c> appsGrantedList  {get;set;}
    public List<Contact> contactList {get;set;}
    public Boolean isEasyPay {get;set;}

    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
    
    public ISSP_PortalService(){
    
        string psId = Apexpages.currentPage().getParameters().get('id');

        PortalService_List =new List<Portal_Applications__c >([select id , Name, ServiceName__c ,Service_Description__c ,Application_icon__c,
                                                               Cannot_be_managed_by_portal_admin__c
                                                   From Portal_Applications__c 
                                                   Where Id =: psId ]);
                                                   
        if(PortalService_List != null && PortalService_List .size() > 0){
            PortalService = PortalService_List [0];
        }
        
        appsGrantedList = new List<Portal_Application_Right__c>([Select p.Application_Name__c, p.Portal_Application__r.Service_Description__c,
                                                                p.Portal_Application__r.Requestable__c,
                                                                p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,
                                                                p.Right__c, p.Portal_Application__r.Application_icon_URL__c,
                                                                p.Portal_Application__r.Name, p.Portal_Application__c,
                                                                p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c,
                                                                p.Case_creation_record_Type__c,
                                                                p.Contact__r.Id, p.Contact__r.Name, p.Contact__r.Email,
                                                                p.Contact__r.AccountId, p.Contact__r.FirstName,
                                                                p.Contact__r.LastName, p.Contact__r.Account.Name,
                                                                p.ANG_Portal_Service_Role__c
                                                                From Portal_Application_Right__c p 
                                                                where p.Portal_Application__c=: psId  and 
                                                                (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested') and
                                                                p.Portal_Application__r.Hide_on_Homepage__c = false]);

        isEasyPay = false;
        if(!appsGrantedList.isEmpty()) {
            isEasyPay = appsGrantedList[0].Application_Name__c.startsWith('IATA EasyPay');            
        }
        
        /*
        set<Id> set_IdsofContacts = new set<Id>();
        if( appsGrantedList  != null && appsGrantedList .size() > 0){
            for(Portal_Application_Right__c  ppr : appsGrantedList ){
                set_IdsofContacts .add(ppr.Contact__c );
            }
        }
        
        contactList =new List<Contact>([select id , Name , Email , Phone ,OtherPhone, User_Portal_Status__c , Fax, MobilePhone, ISO_Country__c, ISSP_Account_Name__c, Account_HQ_BO__c, IATA_Code__c, Title, Membership_Function__c ,OtherAddress ,AccountId, Account.Name , FirstName , LastName
                                        From Contact
                                        Where Id IN: set_IdsofContacts  ]);
        */
    }
    
    public PageReference RedirectToServiceAccess(){ 
        PageReference p = new PageReference ('/apex/ISSP_EditPortalServiceAccess?PSname=' +PortalService.Name + ' &PSid='+PortalService.Id + commParam); 
        p.setRedirect(true);
        return p;
    }
}
public class ISSP_Contact{

    public List<Contact> contactList {get;set;}
    public Contact Contact{get;set;}
    public List<Portal_Application_Right__c> appsGrantedList {get;set;}
    public boolean isIATAAgencyAcct {get;set;}
    public boolean isPortalAdminUser {get;set;}
    public boolean isEditMode {get;set;}
    
    public list<String> errorMessage {get; set;}

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
        
        string contactId = Apexpages.currentPage().getParameters().get('id');
        
        string action = Apexpages.currentPage().getParameters().get('action');
        if (action == 'edit'){
            isEditMode = true;
        }
        
        contactList =new List<Contact>([select id , Name , Email , Phone ,OtherPhone,
                                        User_Portal_Status__c , Fax, MobilePhone, ISO_Country__c,
                                        ISSP_Account_Name__c, Account_HQ_BO__c, IATA_Code__c,
                                        Title, Membership_Function__c  , AccountId , Financial_Assessment_Contact__c,
                                        Account.Name, Account.Category__c, Account.Location_Type__c,
                                        Salutation, FirstName, LastName, Account.IATA_ISO_Country__r.Name,
                                        Invoicing_Contact__c, BSP_CASS_Payment_contact__c, Services__c, Airline_Contact_Type__c
                                        From Contact
                                        Where Id =: contactId ]);
                                                   
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
         
         appsGrantedList = new List<Portal_Application_Right__c>([ Select p.Application_Name__c, p.Portal_Application__r.ServiceName__c ,p.Portal_Application__r.Description__c,p.Portal_Application__r.Requestable__c,p.Application_icon_del__c, p.Portal_Application__r.New_Window__c,p.Right__c, p.Portal_Application__r.Application_icon_URL__c, p.Portal_Application__r.Name, p.Portal_Application__c, p.My_Apps__c, p.Contact__c, p.Application_Start_URL__c ,p.Case_creation_record_Type__c ,p.Portal_Application__r.Application_icon__c
                                                                   From Portal_Application_Right__c p 
                                                                   where p.Contact__c =: ContactId and 
                                                                       
                                                                        (p.Right__c = 'Access Granted'  or p.Right__c = 'Access Requested') and
                                                                         p.Portal_Application__r.Hide_on_Homepage__c = false]); 
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
}
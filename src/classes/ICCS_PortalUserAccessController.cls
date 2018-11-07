public class ICCS_PortalUserAccessController{

    public Case cse {get;set;}

    public List<PortalUserWrapper> wrappedPortalUsers {get;set;}
    
    public List<SelectOption> ICCSPortalRoles {
        get{
            if(ICCSPortalRoles == null){
                ICCSPortalRoles = new List<SelectOption>();
                List<Connected_App_Roles__c> cars = Connected_App_Roles__c.getall().values();
                for(Connected_App_Roles__c car : cars){
                    if(car.Description__c == 'ICCS Service'){
                        ICCSPortalRoles.add(new SelectOption(car.Role__c,car.Role__c));
                    }
                }
                ICCSPortalRoles.sort();
            }
            return ICCSPortalRoles;
        }
        set;
    }

    public Boolean embedded {get;set;}

    public Integer rowsDisplayed {get;set;}
    public Integer contactsSize {get{return wrappedPortalUsers.size();}}
    
    public ICCS_PortalUserAccessController(ApexPages.StandardController controller) {
        cse = [select Id, CaseArea__c, CaseNumber, AccountId, Account.Name from Case where Id =: ((Case)controller.getRecord()).id];
         
        resetController();
    }
    
    public void resetController(){
        wrappedPortalUsers = new List<PortalUserWrapper>();
        
        for(Portal_Application_Right__c usr : [select Id, Contact__r.Name, Contact__r.Email, Right__c, Access_Status_Reason__c, ANG_Portal_Service_Role__c from Portal_Application_Right__c where Top_Account__c =: cse.AccountId and Portal_Application__c =: ISSP_ICCS_Utils.getIccsPortalApplication().Id]){
            wrappedPortalUsers.add(new PortalUserWrapper(this, usr));
        }

        if(ApexPages.currentPage().getParameters().get('rows') == 'all'){
            rowsDisplayed = wrappedPortalUsers.size();
            embedded = false;
        }
        else{
            rowsDisplayed = 4;
            embedded = true;
        }
    }
    
    public void newUser(){
        if(wrappedPortalUsers.isEmpty()){
            wrappedPortalUsers.add(new PortalUserWrapper(this));
        }
        else if(wrappedPortalUsers[0].usr.Id != null){
            wrappedPortalUsers.add(0, new PortalUserWrapper(this));     
        }
    }
    
    public class PortalUserWrapper {
        public ICCS_PortalUserAccessController ctrl {get;set;}
        public Portal_Application_Right__c usr {get;set;}
        
        public String portalUserStatus {
            get{
                if(usr.Contact__c == null){
                    return 'Not Selected';
                }
                else{
                    List<User> portalUsers = [select Id, IsActive from User where Profile.UserLicense.Name = 'Partner Community' and contactId =: usr.Contact__c LIMIT 5];

                    if(portalUsers.size() == 0){
                        return 'No User';   
                    }
                    else{
                        if(portalUsers[0].isActive){
                            return 'Active';
                        }
                        else{
                            return 'Inactive';
                        }
                    }
                }
            }
        }

        public String right {get;set;}
        public String reason {get;set;}
        public String role {get;set;}

        public Boolean editMode {get;set;}

        public PortalUserWrapper(ICCS_PortalUserAccessController ctrl, Portal_Application_Right__c usr){
            this.ctrl = ctrl;
            this.usr = usr;
            editMode = false;
        }
        
        public PortalUserWrapper(ICCS_PortalUserAccessController ctrl){
            this.ctrl = ctrl;
            this.usr = new Portal_Application_Right__c(Portal_Application__c = ISSP_ICCS_Utils.getIccsPortalApplication().Id);
            
            editMode = true;
        }
        
        public void updateUser(){
            right = usr.Right__c;
            reason = usr.Access_Status_Reason__c;
            role = usr.ANG_Portal_Service_Role__c;
            editMode = true;
        }
        
        public void cancel(){
            if(usr.Id != null){
                usr.Right__c = right;
                usr.Access_Status_Reason__c = reason;
                usr.ANG_Portal_Service_Role__c = role;
                editMode = false;
            }
            else{
                ctrl.wrappedPortalUsers.remove(0);
            }
        }
        
        public void save(){
            if(usr.Id != null){
                update usr;
                editMode = false;
            }
            else{
                insert usr;
                ctrl.resetController();
            }
        }
    }
}
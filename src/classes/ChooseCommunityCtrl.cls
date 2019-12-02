public class ChooseCommunityCtrl {
    
    ApexPages.StandardController controller;
    Contact contact;
    public string Community {get; set;}
    public boolean bccCS {get; set;}
    
    public boolean noUser {get;private set;}
    
    public ChooseCommunityCtrl(ApexPages.StandardController controller) {
        noUser = false;  
        this.controller = controller;
        contact = (Contact)controller .getRecord();
        bccCS = false;
        List<User> Users = [Select ID from User where ContactID =: contact.id and isactive = true];
        If(Users== null || Users.size() == 0){
            noUser = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'NO ELIGIBLE USER FOUND FOR THIS CONTACT'));
            }
              
    }
    
    public PageReference SendEmail(){
        string cID = String.valueOf(contact.id);
        if(community =='--None--') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please select a community'));
            return null;
        }
        else{
            if(community != Comm_User_Helper.ISSP){
                Comm_User_Helper.resetPasswordComm(cID ,community, bccCS);
            }
            else{
                PortalForgotPasswordController.handleResetPassword(contact.email);
            }
        }
       
        return controller.view();
    }

    @AuraEnabled
    public static void SendEmailAura(String contactId,String community){      
       sendAssinc(contactId,community);
    }

    @future
    private static void sendAssinc(String contactId,String community){  
         try{
             if(community != Comm_User_Helper.ISSP) {
                 comm_User_Helper.resetPasswordComm(Id.valueOf(contactId), community, false);
             }
             else{
                 List<contact> contactList = [Select email from contact where id =: contactId Limit 1];
                 if(!contactList.isEmpty()) PortalForgotPasswordController.handleResetPassword(contactList.get(0).email);
             }
        }catch(Exception e){
            throw e;
        }    
    }

     @AuraEnabled(cacheable=true)
    public static boolean hasValidUser(String contactId){
        list<user> userList=[Select id from User where ContactID =: Id.valueOf(contactId) and isactive = true];
        return !userList.isEmpty();
    }
    
        
    public List<SelectOption> getAvalaibleComms(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        options.add(new SelectOption(Comm_User_Helper.IEC,'E-commerce'));
        options.add(new SelectOption(Comm_User_Helper.ISSP,'ISS Customer Portal'));
        options.add(new SelectOption(Comm_User_Helper.CNS,'CNS Customer Portal'));
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<SelectOptionWrapper> getAvalaibleCommunities() {
        List<SelectOptionWrapper> options = new List<SelectOptionWrapper>();
       // options.add(new SelectOptionWrapper('--None--','--None--'));
        options.add(new SelectOptionWrapper(Comm_User_Helper.IEC,'E-commerce'));
        options.add(new SelectOptionWrapper(Comm_User_Helper.ISSP,'ISS Customer Portal'));
        options.add(new SelectOptionWrapper(Comm_User_Helper.CNS,'CNS Customer Portal'));
        return options;
    }  
}
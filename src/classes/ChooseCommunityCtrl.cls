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
        system.debug('BCC: ' + bccCS);
        string cID = String.valueOf(contact.id);
        //throw new transformationException(' '+ cID );
        if(community =='--None--') {ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please select a community')); return null;}
        else Comm_User_Helper.resetPasswordComm(cID ,community, bccCS);
        //else if(community == Comm_User_Helper.IEC)Comm_User_Helper.resetPasswordComm(cID  ,Comm_User_Helper.IEC, bccCS);
       
        return controller.view();


        
    }
    
        
    public List<SelectOption> getAvalaibleComms(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        options.add(new SelectOption(Comm_User_Helper.IEC,'E-commerce'));
        options.add(new SelectOption(Comm_User_Helper.ISSP,'ISS Customer Portal'));
        options.add(new SelectOption(Comm_User_Helper.CNS,'CNS Customer Portal'));
        return options;
    }
}
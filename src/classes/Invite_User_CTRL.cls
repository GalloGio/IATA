public without sharing class Invite_User_CTRL {
    
    @AuraEnabled
    public static string sendInvitation(string contactStr, string invitationStr) {
        Invitation__c invitation = null;
        Contact contact = null;
        try{
            contact = (Contact)JSON.deserialize(contactStr, Contact.Class);
        } catch (Exception ex){}
        try{
            invitation = (Invitation__c)JSON.deserialize(invitationStr, Invitation__c.Class);
        } catch (Exception ex){}
        
        try{
            if(contact == null && invitation != null){
                insert invitation;
                invitation = [SELECT Id, Email__c FROM Invitation__c WHERE Id =: invitation.Id];
                return sendEmail(true, invitation);
            } else if (contact != null) {
           		return sendEmail(false, contact);
            }
            return invitationStr;
            } catch(Exception e) {
    			return 'err:'+e.getMessage();
		}
    }
        
    private static string getEmailFromSObject(SObject obj){
        string objName = ((SObject)obj).getSObjectType().getDescribe().getName();
        switch on objName.toUpperCase() {
       when 'CONTACT'{
           return (String) obj.get('Email');
       }
       when 'INVITATION__C' {
            return (String) obj.get('Email__c');
       }
       when else {
           return '';
       }
        }
    }
    private static string sendEmail(boolean newUser, SObject obj){
        string linkSuffix = '';
        string emailTemplate = '';
        
        if (newUser){
            emailTemplate = 'Invite_user_new';
            linkSuffix = '/login/SelfRegister?serviceName=GADM&token='+obj.get('Id');
        } else {
            emailTemplate = 'Invite_user_already_exists';
            linkSuffix = '/login/';
        }
        EmailTemplate et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName =: emailTemplate];
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, UserInfo.getUserId(), obj.Id);
        string link = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + linkSuffix;

		mail.setToAddresses(new List<string>{'pavel.pop@b-i.com'});
	    mail.setSaveAsActivity(false);
        string body = mail.getHtmlBody();
        mail.setHtmlBody(body.replace('*link*', link) + getEmailFromSObject(obj));
        mail.setUseSignature(false);
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        system.debug(mail);
        try {
            Messaging.sendEmail(allmsg,false);
            return 'sent';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
    }
    @AuraEnabled 
    public static List<Account> getUserAccounts(){
        Id userId = UserInfo.getUserId();
        return Contact_Roles_Helper.getUserAccounts(userId);
    }
    @AuraEnabled
    public static List<String> getContactJobFunctionValues() {
        return OneId_RegistrationProcessController.getContactJobFunctionValues();
    }
    @AuraEnabled
    public static Map<String,String> getContactLabels() {
        return OneId_RegistrationProcessController.getContactLabels();
    }
    @AuraEnabled
    public static UserInformationWrapper getUserInformationFromEmail(String email, String serviceName){
        List<Contact> existingContacts = OneId_RegistrationProcessController.returnExistingContact(email);
        
        boolean emailAddressAvailable = OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce(email, existingContacts);
        boolean contactExists = existingContacts.size() > 0;
        boolean contactOrUserExists = !emailAddressAvailable || contactExists;
        
        UserInformationWrapper wrapper = new UserInformationWrapper(
        	contactExists ? existingContacts[0] : null, new Invitation__c());
        
        wrapper.showNotifyButton = !(!emailAddressAvailable && !contactExists);
              
        wrapper.createNewInvitation = !contactOrUserExists;
        if(emailAddressAvailable && contactExists){
            Contact con = existingContacts[0];
            Account acc = [SELECT Id, Top_Parent__c	FROM Account WHERE Id =: con.AccountId][0];
        	Invitation__c invitation = new Invitation__c();
            invitation.AccountId__c = acc.Top_Parent__c != null ? acc.Top_Parent__c : con.AccountId;
            invitation.Business_Fax__c = con.Fax;
            invitation.Business_Phone__c = con.Phone;
            invitation.Email__c = con.Email;
            invitation.First_Name__c = con.FirstName;
            invitation.Last_Name__c = con.LastName;
            
            invitation.Job_Title__c = con.Title;
            invitation.Mobile_Phone__c = con.MobilePhone;
            invitation.Salutation__c = con.Salutation;
            wrapper.invitation = invitation;    
        	wrapper.contact = null;
        }
        
        if(!emailAddressAvailable && !contactExists){
            //internal user
            wrapper.invitation = null;    
        	wrapper.contact = null;
        }
         system.debug(contactOrUserExists);
        system.debug(emailAddressAvailable);
        system.debug(wrapper);
        return wrapper;
}
    public class UserInformationWrapper{
        @AuraEnabled
        public boolean createNewInvitation{get;set;}
        @AuraEnabled
        public boolean showNotifyButton{get;set;}
        @AuraEnabled
        public Invitation__c invitation {get;set;}
        @AuraEnabled
        public Contact contact {get;set;}
        public UserInformationWrapper(Contact contact, Invitation__c invitation){
            this.contact = contact;
            this.invitation = invitation;
        }
    }
}
public without sharing class OneIdForgotPasswordController {
	public OneIdForgotPasswordController() {

    }

    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        System.debug('basto1p -> forgotPassword username='+username);

        Boolean success;
        
        try {
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            
            
            List<User> users = [Select u.Username,u.firstName, u.Id, u.Email, u.IsActive , u.ContactID, U.UID__c
                                    From User u 
                                    where (u.Email = :username )
                                    and (IsActive = true OR Portal_User_Frozen_Checkbox__c = true)
                                    and ContactID != ''];
      		
            system.debug('resetPassword users: ' + users);
            
            if (users == null || users.size() == 0)
                throw new IECApplicationException(username + ' is not a valid email for existing users');
            
            //success = Site.forgotPassword(users[0].Username);
            
            
            users[0].IsActive = true;
            users[0].Portal_User_Frozen_Checkbox__c = false;     
            update users;
            
            success = Comm_User_Helper.resetPassword(username, //email in this case
                                                             Comm_User_Helper.ONEIDENTITY, 
                                                             false);
			

            if (success) {
                System.debug('basto1p -> forgotPassword RESET SUCCESS username='+username);
                ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                if(!Test.isRunningTest())
                	aura.redirect(checkEmailRef);
            }
            else{
                System.debug('basto1p -> forgotPassword NOT RESET username='+username);
            }
            
            return null;
        }
        catch (Exception ex) {
            System.debug('basto1p -> forgotPassword ERROR ON RESET username='+username);
            if(serviceName == 'ISSP'){
                return Label.ISSP_Registration_generalError;    
            }else{                
            return Label.OneId_PasswordResetFail;
        }
            
        }
    }
}
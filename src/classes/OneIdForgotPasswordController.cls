public without sharing class OneIdForgotPasswordController {
	public OneIdForgotPasswordController() {

    }

    // OneIdEnh CSP-ID002: entry point for older methods without service name
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        return forgotPassword(username, checkEmailUrl, '');
    }

    // OneIdEnh CSP-ID002: new entry point with service name
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl, String serviceName) {
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
            
            
            
            success = Comm_User_Helper.resetPassword(username, //email in this case
                                                             Comm_User_Helper.ONEIDENTITY, 
                                                             false,
                                                     		 serviceName);  // OneIdEnh CSP-ID002: added service name
			

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
            return Label.OneId_PasswordResetFail;
        }
    }
}
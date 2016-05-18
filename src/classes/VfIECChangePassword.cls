public without sharing class VfIECChangePassword {

    public String currentPassword { get; set; }
    public String newPassword { get; set; }
    public String confirmNewPassword { get; set; }

    /**
     * Constructor
     */
    public VfIECChangePassword() { 
}
    
    /**
     * Changes the user's password
     */
    public Pagereference changePassword() {
        
        try {
            // validate fields
            List<String> errMsgs = new List<String>();
            
            if (currentPassword == null || currentPassword == '')
                errMsgs.add('The Current password field is mandatory.');
            if (newPassword == null || newPassword == '')
                errMsgs.add('The New password field is mandatory.');
            if (confirmNewPassword == null || confirmNewPassword == '')
                errMsgs.add('The Confirm new password field is mandatory.');
                
            if (errMsgs.size() > 0) {
                for (String errMsg : errMsgs)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
                return null;
            }
            else {

                if(!test.isRunningTest())Comm_User_Helper.updateUsersGUID(UserInfo.getUserId());
                return Site.changePassword(newPassword, confirmNewPassword, currentPassword);

            }
        }
        catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
}
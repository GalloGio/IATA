global class AzureRegistrationHandler implements Auth.RegistrationHandler{
        class RegHandlerException extends Exception{}

        global boolean canCreateUser(Auth.UserData data) {
            return true;
        }

        // called when a user first uses SSO to login
        global User createUser(Id portalId, Auth.UserData data){
        // retrieves user record using email address from AD
        List<User> users = [SELECT Id FROM User WHERE Email = :data.email AND IsPortalEnabled = FALSE];
        if (users.size() > 1)
            throw new RegHandlerException('Multiple Users with Please contact an administrator.');
        //EMAIL IS USED AS THE KEY BETWEEN AZURE AND SFDC, IF THIS CHANGES IN AZURE THEN USER WILL NOT BE FOUND: User.Email must be updated
        return users.get(0);
    }

    // called each time a user logs in via SSO
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
    }
}
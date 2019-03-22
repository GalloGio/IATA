public without sharing class WithoutSharingOperations {
	
	/*** AMSU-163 ***/
    public static void updateUserSync(String conId, Boolean isActive, String email, String profileId, String firstCommunity){
        list <User> usersToUpdate = [Select u.Id, u.IsActive, u.IsPortalEnabled, u.Email, u.Contact.Email, u.Community__c, u.ProfileId
                                            from User u where contactId =:conId];
        if (!usersToUpdate.isEmpty()){
            for(User u : usersToUpdate){
                u.IsActive = isActive;
                u.IsPortalEnabled = true;
                if (profileId != ''){
                    u.ProfileId = profileId;
                } 
                u.Email = email;
                string userName = ISSP_Utilities.buildPortalUserName(email);
                u.Username = userName;
                if(firstCommunity != '')
                    u.Community__c = firstCommunity;
            }

            update usersToUpdate;
        }
    }

    public static void upsertContacts(List<Contact> cons) {
        upsert cons;
    }

    /**
     * Workaround to create Portal User by Internal Users
     * without sharing - class
     */
    public static ID insertUser(User usr){
        insert usr;
        return usr.id;
    }
}
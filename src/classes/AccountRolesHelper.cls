public class AccountRolesHelper {
    public static void updateName(list<Account_Roles__c> newAccRoles) {
        for(Account_Roles__c roles : newAccRoles){
            roles.Name = roles.Sector__c + ' - ' + roles.Category__c;
        }
    }
}
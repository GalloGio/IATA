public class AccountRolesHelper {
	public static void updateName(list<Account_Roles__c> newAccRoles) {
		for(Account_Roles__c roles : newAccRoles){
			if(roles.Sector__c != null || roles.Category__c != null){
				roles.Name = roles.Sector__c + ' - ' + roles.Category__c;
			}
		}
	}
}

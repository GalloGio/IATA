public with sharing class OneId_Fred_AddNewUser_CTRL {
	
	@AuraEnabled
	public static PrimaryUser isFredPrimaryUser() {
		// is currenct user a Fred Primary user? = has FRED primary permission set
		PrimaryUser pu = new PrimaryUser();
		Integer n = [SELECT Count() FROM PermissionSetAssignment WHERE PermissionSet.name = 'FRED_Primary_User' AND AssigneeId =: UserInfo.getUserId()];
		

		One_Id_Service_Provider_Config__c config = [select id, Max_Number_Of_Primary_User__c, Max_Number_Of_Secondary_User__c, Service_Provider_Name__c, Service_Bundle__r.name, Customer_Type_Activation__c  FROM One_Id_Service_Provider_Config__c  WHERE Service_Provider_Name__c = 'FRED' LIMIT 1];

		// Get account linked to primary user - To block account selection
		Integer nbOfPrimaryInAccount = 0;
		Integer nbOfSecondaryInAccount = 0;
            User u = [SELECT AccountId FROM User WHERE Id =: UserInfo.getUserId()];
            if(u.AccountId != null) {
                // To change when implemnting another primary
                list<PermissionSetAssignment> primaries = [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId =: u.AccountId];
                set<Id> primarySet = new set<Id>();
                for(PermissionSetAssignment p : primaries)
                	primarySet.add(p.AssigneeId);

                nbOfPrimaryInAccount = primaries.size();

                nbOfSecondaryInAccount = [SELECT count() FROM User WHERE id NOT IN : primarySet AND AccountId =: u.AccountId];
            }

		Integer nbSecondary = [SELECT Count() FROM PermissionSetAssignment WHERE PermissionSet.name != 'FRED_Primary_User' AND AssigneeId =: UserInfo.getUserId()];
		pu.isFredPrimaryUser = n > 0;
		pu.primaryUserId = UserInfo.getUserId();
		pu.nbOfPrimaryInAccount = nbOfPrimaryInAccount;
		pu.nbOfSecondaryInAccount = nbSecondary;
		pu.maxPrimary = (Integer) config.Max_Number_Of_Primary_User__c;
		pu.maxSecondary = (Integer) config.Max_Number_Of_Secondary_User__c;

		return pu;
	}

	public class PrimaryUser {
		@AuraEnabled
		Boolean isFredPrimaryUser {get; set;}
		@AuraEnabled
		String primaryUserId {get; set;}
		@AuraEnabled
		Integer nbOfPrimaryInAccount {get; set;}
		@AuraEnabled
		Integer nbOfSecondaryInAccount {get; set;}
		@AuraEnabled
		Integer maxPrimary {get; set;}
		@AuraEnabled
		Integer maxSecondary {get; set;}
	}

	 @AuraEnabled
    public static List <Connected_App_Roles__c> getroles (String connectedapp) {

        List <Connected_App_Roles__c> values = new List <Connected_App_Roles__c>();

        try{
            List<One_Id_App_Role_Config__c> roles = OneIdProvisioningDAO.getAppRolesListForAppicker(connectedapp);

            if(! roles.isEmpty()) {

                for(One_Id_App_Role_Config__c role : roles) {
                    Connected_App_Roles__c aDummy = new Connected_App_Roles__c();
                    aDummy.Role__c = role.Role_Name__c;
                    aDummy.Description__c = role.Role_Description__c;
                    values.add(aDummy);
                }

            }
        }catch(Exception err){
            System.debug(err);
        }

    	return values;
    }

}
public without sharing class PortalInvitationHelper {
	
	public static List<E_and_F_Contact_Role_Detail__c> getEFContactRoleDetails(String contactId, String RTDevName){
		String query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, Account_name__c, E_F_Account_Role_Detail__c, E_F_Account_Role_Detail__r.RecordTypeId, E_F_Account_Role_Detail__r.RecordType.DeveloperName, E_F_Account_Role_Detail__r.Account_Role__c, E_F_Account_Role_Detail__r.Account_Role__r.Global_ID__c ' +
						'FROM E_and_F_Contact_Role_Detail__c ' + 
						'WHERE ContactFunctionalRole__c = \'E&F\'';
		if(contactId != null)
			query += ' AND Contact_Id__c =: contactId';
		if(RTDevName != null)
			query += ' AND RecordType.DeveloperName =: RTDevName';

		return Database.query(query);
	}
}
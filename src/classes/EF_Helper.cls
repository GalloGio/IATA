//class needs to be without sharing because a Portal user
// can be invited to work on behalf of another account
// and we want to avoid having to create Apex Sharing
public without sharing class EF_Helper {

	private static final String EFAPPS='E&F APPS';

	public static E_and_F_Account_Role_Detail__c getEFAccontRoleDetail(Id accountRoleId) {
		return [SELECT Id FROM E_and_F_Account_Role_Detail__c WHERE Account_Role__c =: accountRoleId];
	}

	public static List<E_and_F_Account_Role_Detail__c> getAccountContactRoles(Id contactId) {
		String query = 'SELECT Account_Role__c, Account_Role__r.Account_Name__c, Account_Role__r.Account__c FROM E_and_F_Account_Role_Detail__c WHERE Account_Role__r.Functional_Role__c = \'E&F\'';
		if(String.isNotBlank(contactId)) query += ' AND ID IN (SELECT E_F_Account_Role_Detail__c FROM E_and_F_Contact_Role_Detail__c WHERE RecordType.DeveloperName = \'Service_Admin\' AND Contact_Role__r.Contact__c =: contactId)';

		return Database.query(query);
	}

	public static List<E_and_F_Contact_Role_Detail__c> getEFContactRoleDetails(String contactId, String RTDevName){
		String query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, Account_name__c, E_F_Account_Role_Detail__c, E_F_Account_Role_Detail__r.RecordTypeId, E_F_Account_Role_Detail__r.RecordType.DeveloperName, E_F_Account_Role_Detail__r.Account_Role__c, E_F_Account_Role_Detail__r.Account_Role__r.Global_ID__c ' +
						'FROM E_and_F_Contact_Role_Detail__c ' +
						'WHERE ContactFunctionalRole__c = \'E&F\'';

		if(contactId != null) query += ' AND Contact_Id__c =: contactId';
		if(RTDevName != null) query += ' AND RecordType.DeveloperName =: RTDevName';

		return Database.query(query);
	}

	public static void requestAccessEF(String applicationId, String applicationName, User userAux) {
		List<Invitation__c> inv = [SELECT Id, AccountId__c, AccountRoleId__c, Role__c FROM Invitation__c WHERE Email__c =: userAux.Contact.Email AND ServiceId__r.Name =: EFAPPS ORDER BY CreatedDate DESC];

		if(inv.isEmpty()){
			throw new PortalServiceException('The user has no invitation for this service.');
		} else {
			Invitation__c i = inv[0];
			//create Account Contact Role
			Account_Contact_Role__c acr = new Account_Contact_Role__c();
			acr.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'Functional');
			acr.Account__c = i.AccountId__c;
			acr.Account_Role__c = i.AccountRoleId__c;
			acr.Contact__c = userAux.ContactId;
			acr.Service_Rendered__c = 'Other';
			acr.Functional_Role__c = 'E&F';
			acr.Status__c = 'Active';
			insert acr;

			//create E&F Contact Role Detail
			E_and_F_Contact_Role_Detail__c crd = new E_and_F_Contact_Role_Detail__c();
			crd.Contact_Role__c = acr.Id;
			crd.CurrencyIsoCode = userAux.CurrencyIsoCode;
			crd.E_F_Account_Role_Detail__c = getEFAccontRoleDetail(i.AccountRoleId__c).Id;
			if(i.Role__c == 'Service Admin') crd.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Contact_Role_Detail__c', 'Service_Admin');
			else crd.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('E_and_F_Contact_Role_Detail__c', 'Standard_User');
			insert crd;
		}

		//create service access right Access Granted
		ISSP_AvailableServices.newAppsRequest2(applicationId, applicationName, userAux.ContactId, '', false, '');
	}

	public static void createInvite(Map<String, String> fields) {
		Invitation__c i = new Invitation__c();
		for(String key : fields.keyset()) {
			i.put(key, fields.get(key));
		}
		insert i;
	}

	private class PortalServiceException extends Exception {}
}
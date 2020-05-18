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
		String query = 'SELECT Id, RecordTypeId, RecordType.DeveloperName, Account_name__c, E_F_Account_Role_Detail__c, E_F_Account_Role_Detail__r.RecordTypeId, E_F_Account_Role_Detail__r.RecordType.DeveloperName, E_F_Account_Role_Detail__r.Account_Role__c, E_F_Account_Role_Detail__r.Account_Role__r.Account__c ' +
						'FROM E_and_F_Contact_Role_Detail__c ' +
						'WHERE ContactFunctionalRole__c = \'E&F\'';

		if(contactId != null) query += ' AND Contact_Id__c =: contactId';
		if(RTDevName != null) query += ' AND RecordType.DeveloperName =: RTDevName';

		return Database.query(query);
	}

	//We need to change the logic to fetch the list of contacts for E&F APPS
	//The entire method needs to be replicated in order to benefit from the sharing
	@AuraEnabled
	public static List<PortalServicesCtrl.ContactWrapper> getContacts(String contactId, String searchKey, String filter1, String filter1_2, String filter2, String offset){
		String access_granted=PortalServicesCtrl.PORTAL_ACCESS_GRANTED;
		String access_requested=PortalServicesCtrl.PORTAL_ACCESS_REQUESTED;
		String access_denied=PortalServicesCtrl.PORTAL_ACCESS_DENIED;

		String query = String.format(
			'SELECT {0} , Portal_Application__r.Name ' +
			'FROM Portal_Application_Right__c ' +
			'where Portal_Application__r.Name =:EFAPPS '+
			'and (Right__c =:access_granted or Right__c =:access_requested or Right__c =:access_denied) '+
			'and Portal_Application__r.Hide_on_Homepage__c = false ',
			new List<String>{
				String.join(new PortalApplicationRight_Sel().getSObjectFieldListForWithContactInfo(), ', ')
			}
		);

		if(String.isNotBlank(searchKey)) query += ' AND (contact__r.name LIKE \'{0}}\' OR contact__r.email LIKE \'{0}}\' OR contact__r.account.IATACode__c LIKE \'{0}}\' OR contact__r.account.BillingCity LIKE \'{0}}\' OR contact__r.account.IATA_ISO_Country__r.Name LIKE \'{0}}\' )'.replace('{0}', '%'+searchkey+'%');

		if(String.isNotBlank(filter1) && filter1 != 'All'){
			if(String.isNotBlank(filter1_2)) query += 'AND contact__r.account.IATACode__c = :filter1 AND contact__r.account.BillingCity = :filter1_2';
			else query += 'AND contact__r.account.IATA_ISO_Country__r.Name = :filter1';
		}

		if(String.isNotBlank(filter2) && filter2 != 'All'){
			query += 'AND Right__c = :filter2';
		}

		if(String.isNotBlank(offset)){
			query += ' ORDER BY Portal_Application_Right__c.Contact__r.Name ASC LIMIT '+PortalApplicationRight_Sel.CONTACTSBATCH+' OFFSET '+offset;
		}

		List<Portal_Application_Right__c> auxServicesList = Database.query(query);


		Set<String> contactIds = new Set<String>();
		for (Portal_Application_Right__c par : auxServicesList) {
			contactIds.add(par.contact__c);
		}

		for( user u:[SELECT ContactId FROM User WHERE ContactId IN :contactIds]){
			PortalServicesCtrl.contactWithUserSet.add(u.ContactId);
		}

		List<PortalServicesCtrl.ContactWrapper> appsGrantedList = new List<PortalServicesCtrl.ContactWrapper>();
		for(Portal_Application_Right__c par : auxServicesList) {
			PortalServicesCtrl.ContactWrapper sw = new PortalServicesCtrl.ContactWrapper(par);

			if(sw.isInactive || ((sw.isEasyPayService && !sw.cannotBeManagedByPortalAdmin) ||
				(sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin && par.right__c != PortalServicesCtrl.PORTAL_ACCESS_GRANTED) ||
				(!sw.isEasyPayService && sw.cannotBeManagedByPortalAdmin)
				)) {
				continue;
			}

			appsGrantedList.add(sw);
		}

		return appsGrantedList;
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
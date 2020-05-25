public with sharing class EF_APPS_SCIMUser extends SCIMUser {

	private class SCIMException extends Exception {}

	//add honorificPrefix as required for E&F APPS payload
	public class Name{
		public String formatted;
		public String familyName;
		public String givenName;
		public String honorificPrefix;
	}

	public Name name;

	public EF_APPS_SCIMUser(String familyName, String givenName, String externalid, String email, String displayName, String preferredLanguage, String title, Boolean active) {
		super(null, familyName, givenName, externalid, email, null, displayName, null, null, preferredLanguage, null, title, active);

		//schemas
		schemas.add('urn:scim:schemas:extension:enterprise:1.0');
		//Mulesoft uses PUT instead of Patch
		HttpCall.HTTP_METHOD_PATCH = 'PUT';

		User u = [SELECT Id, Contact.Phone, Contact.MobilePhone, ContactId, Contact.Salutation FROM User WHERE ContactId =: externalid LIMIT 1];

		if(u == null) throw new SCIMException('User not found');

		String conId = String.valueOf(u.ContactId).left(15);
		List<E_and_F_Contact_Role_Detail__c> cRole = EF_Helper.getEFContactRoleDetails(conId, null);

		if(cRole.isEmpty()) throw new SCIMException('Not an E&F User');

		E_and_F_Contact_Role_Detail__c cd = cRole[0];

		//emails
		SCIMUser.Emails e = new SCIMUser.Emails();
		e.value = email;
		e.type = 'work';
		e.primary = true;

		this.emails = new List<SCIMUser.Emails>{e};

		//phoneNumbers
		List<PhoneNumbers> phones = new List<PhoneNumbers>();
		if (u.Contact.Phone != null) {
			SCIMUser.PhoneNumbers workPhone = new SCIMUser.PhoneNumbers();
			workPhone.value = u.Contact.Phone;
			workPhone.type = 'work';
			phones.add(workPhone);
		}
		if (u.Contact.MobilePhone != null) {
			SCIMUser.PhoneNumbers mobilePhone = new SCIMUser.PhoneNumbers();
			mobilePhone.value = u.Contact.MobilePhone;
			mobilePhone.type = 'mobile';
			phones.add(mobilePhone);
		}

		if(!phones.isEmpty()) this.phoneNumbers = phones;

		//name
		super.name = null;
		this.name = new Name();
		if (familyName != null) this.name.familyName = familyName;
		if (givenName != null) this.name.givenName = givenName;
		if (u.Contact.Salutation != null) this.name.honorificPrefix = u.Contact.Salutation;

		//entitlements
		List<SCIMUser.Entitlements> entitlementsList = new List<SCIMUser.Entitlements>();

		//name
		SCIMUser.Entitlements e1 = new SCIMUser.Entitlements();
		e1.type = 'name';
		e1.value = cd.Account_name__c;
		entitlementsList.add(e1);

		//accountType
		SCIMUser.Entitlements e2 = new SCIMUser.Entitlements();
		e2.type = 'accountType';
		e2.value = cd.E_F_Account_Role_Detail__r.RecordType.DeveloperName == 'Operator' ? 'AIRCRAFT_OPERATOR' : 'CLIENT';
		entitlementsList.add(e2);

		//globalId
		SCIMUser.Entitlements e3 = new SCIMUser.Entitlements();
		e3.type = 'globalId';
		e3.value = cd.E_F_Account_Role_Detail__r.Account_Role__r.Account__r.Global_ID__c;
		entitlementsList.add(e3);

		//externalSystems
		SCIMUser.Entitlements e4 = new SCIMUser.Entitlements();
		e4.type = 'externalSystems';
		e4.value = 'EFAPPS';
		entitlementsList.add(e4);

		//administrator - do a query to all the contact's E&F Contact Role Details to know if it is an administrator or not
		List<E_and_F_Contact_Role_Detail__c> adminList = EF_Helper.getEFContactRoleDetails(conId, 'Service_Admin');
		SCIMUser.Entitlements e5 = new SCIMUser.Entitlements();
		e5.type = 'administrator';
		e5.value = ''+(!adminList.isEmpty());
		entitlementsList.add(e5);

		if(!entitlementsList.isEmpty()) this.entitlements = entitlementsList;
	}

}
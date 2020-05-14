public with sharing class EF_APPS_SCIMUser extends SCIMUser {

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

		User u = [SELECT Id, Phone, MobilePhone, ContactId, Contact.Salutation FROM User WHERE Email =: email LIMIT 1];
		List<E_and_F_Contact_Role_Detail__c> efcrdList = new List<E_and_F_Contact_Role_Detail__c>();
		E_and_F_Contact_Role_Detail__c efcrd;
		String conId;
		if(u != null && u.ContactId != null){
			conId = String.valueOf(u.ContactId).left(15); //to be sure that it as the same length as the formula field
			efcrdList = EF_Helper.getEFContactRoleDetails(conId, null);
			if(!efcrdList.isEmpty()) efcrd = efcrdList.get(0);
		}

		//emails
		if (email != null) {
			SCIMUser.Emails e = new SCIMUser.Emails();
			e.value = email;
			e.type = 'work';
			e.primary = true;

			this.emails = new List<SCIMUser.Emails>{e};
		}

		//phoneNumbers
		if(u != null){
			if (u.Phone != null) {
				SCIMUser.PhoneNumbers workPhone = new SCIMUser.PhoneNumbers();
				workPhone.value = u.Phone;
				workPhone.type = 'work';
				this.phoneNumbers = new List<SCIMUser.PhoneNumbers>{workPhone};
			}
			if (u.MobilePhone != null) {
				SCIMUser.PhoneNumbers mobilePhone = new SCIMUser.PhoneNumbers();
				mobilePhone.value = u.MobilePhone;
				mobilePhone.type = 'mobile';
				if(this.phoneNumbers == null)
					this.phoneNumbers = new List<SCIMUser.PhoneNumbers>{mobilePhone};
				else
					this.phoneNumbers.add(mobilePhone);
			}
		}

		//name
		super.name = null;
		this.name = new Name();
		if (familyName != null) this.name.familyName = familyName;
		if (givenName != null) this.name.givenName = givenName;
		if (u.ContactId != null && u.Contact.Salutation != null) this.name.honorificPrefix = u.Contact.Salutation;

		//entitlements
		if (efcrd != null) {
			List<SCIMUser.Entitlements> entitlementsList = new List<SCIMUser.Entitlements>();
			//name
			if(efcrd.Account_name__c != null){
				SCIMUser.Entitlements e1 = new SCIMUser.Entitlements();
				e1.type = 'name';
				e1.value = efcrd.Account_name__c;
				entitlementsList.add(e1);
			}
			if(efcrd.E_F_Account_Role_Detail__c != null){
				//accountType
				if(efcrd.E_F_Account_Role_Detail__r.RecordTypeId != null && efcrd.E_F_Account_Role_Detail__r.RecordType.DeveloperName != null){
					SCIMUser.Entitlements e2 = new SCIMUser.Entitlements();
					e2.type = 'accountType';
					e2.value = efcrd.E_F_Account_Role_Detail__r.RecordType.DeveloperName == 'Operator' ? 'AIRCRAFT_OPERATOR' : 'CLIENT';
					entitlementsList.add(e2);
				}
				//globalId
				if(efcrd.E_F_Account_Role_Detail__r.Account_Role__c != null && efcrd.E_F_Account_Role_Detail__r.Account_Role__r.Account__c != null){
					SCIMUser.Entitlements e3 = new SCIMUser.Entitlements();
					e3.type = 'globalId';
					e3.value = efcrd.E_F_Account_Role_Detail__r.Account_Role__r.Account__c;
					entitlementsList.add(e3);
				}
			}
			//externalSystems
			SCIMUser.Entitlements e4 = new SCIMUser.Entitlements();
			e4.type = 'externalSystems';
			e4.value = 'E&F APPS';
			entitlementsList.add(e4);
			//administrator - do a query to all the contact's E&F Contact Role Details to know if it is an administrator or not
			List<E_and_F_Contact_Role_Detail__c> adminList = EF_Helper.getEFContactRoleDetails(conId, 'Service_Admin');
			SCIMUser.Entitlements e5 = new SCIMUser.Entitlements();
			e5.type = 'administrator';
			e5.value = adminList.isEmpty() ? 'false' : 'true';
			entitlementsList.add(e5);

			if(!entitlementsList.isEmpty())this.entitlements = entitlementsList;
		}

		//schemas
		schemas.add('urn:scim:schemas:extension:enterprise:1.0');

		//Mulesoft uses PUT instead of Patch
		HttpCall.HTTP_METHOD_PATCH = 'PUT';
	}

}
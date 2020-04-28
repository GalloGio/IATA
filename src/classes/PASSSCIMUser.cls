global with sharing class PASSSCIMUser extends SCIMUser {

	public class Entitlements {
		public String type;
		public String value;
		public String display;
		public Boolean primary;
	}


	public class Name{ 
		public String formatted;
		public String familyName;
		public String givenName;
		public String honorificPrefix;
	}


	public class enterpriseExtension{
		public String employeeNumber;
		public String costCenter;
		public String organization;
		public String division;
		public String department;
		public Manager manager;
	}

	public class Manager{
		public String managerId;
		public String displayName;
	}

	public List<String> schemas;
	public String externalId; 
	public Name name;
	public String displayName;
	public String userType;
	public String preferredLanguage;
	public List<Entitlements> entitlements;
	public List<Groups> groups;
	public List<Roles> roles;


	public PASSSCIMUser(String userName, String familyName, String givenName, String externalid, String email) {

		super(userName, familyName, givenName, externalid, email);

		super.getSchemas().add('urn:scim:schemas:extension:enterprise:1.0');

		super.name = null;
		this.name = new Name();
		if (familyName != null) this.name.familyName = familyName;
		if (givenName != null) this.name.givenName = givenName;

		if (email != null) {
				fillUpSCIMMessage(email);
		}

	}

	@TestVisible
	private void fillUpSCIMMessage(String email){
		User userIn = [SELECT Id, name, contact.account.RecordType.DeveloperName,AccountId, contact.account.X8585_Code__c, contact.account.Country_ISO_Code__c, contact.account.name, contact.account.IATACode__c, contact.account.sector__c, contact.account.category__c,FederationIdentifier, SmallPhotoUrl ,createdDate,lastModifiedDate,contact.Phone,CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, Contact.Title, Contact.MobilePhone, Contact.Fax, contact.Salutation from user where email = :email and IsActive = true limit 1];


		Contact ctt;
		List<AMS_Accreditation_Contact__c> amsContactList = [SELECT Id,PASS_admin__c, PASS_user__c FROM AMS_Accreditation_Contact__c WHERE Contact__c =:userIn.contactId];

		if(amsContactList.isEmpty()){
			ctt = [SELECT Id,Title,Email FROM Contact WHERE Id =:userIn.contactId];
		}
		if(userIn != null){
			if(!amsContactList.isEmpty()){
				PhoneNumbers mobile = new PhoneNumbers();
				mobile.value =  userIn.Contact.MobilePhone;
				mobile.type = 'mobile';

				PhoneNumbers work = new PhoneNumbers();
				work.value =  userIn.Contact.Phone;
				work.type = 'work';

				PhoneNumbers fax = new PhoneNumbers();
				fax.value =  userIn.Contact.Fax;
				fax.type = 'fax';

				phoneNumbers = new List<PhoneNumbers>{mobile, work, fax};

				this.title = userIn.Contact.title;

				this.preferredLanguage = userIn.LanguageLocaleKey;

				if(this.entitlements == null) {
					this.entitlements = new List<Entitlements>();
				}

				Entitlements enCode = new Entitlements();  
				Entitlements enRequestedRole = new Entitlements(); 
				Entitlements enName = new Entitlements();

				enCode.type = 'iataCode';
				enCode.value = userIn.contact.Account.IATACode__c;
				this.entitlements.add(enCode);

				enRequestedRole.type = 'Requested Role';
				if(amsContactList[0].PASS_admin__c){
					enRequestedRole.value = 'PASS Admin';
				}
				else{
					enRequestedRole.value = 'PASS User';
				}
				
				
				this.entitlements.add(enRequestedRole);

				enName.type = 'NAME';
				enName.value = userIn.contact.account.name;
				this.entitlements.add(enName);

				if (email != null) {
					SCIMUser.Emails e = new SCIMUser.Emails();
					e.value = email;
					e.type = 'home';
					e.primary = false;
		
					SCIMUser.Emails e2 = new SCIMUser.Emails();
					e2.value = email;
					e2.type = 'work';
					e2.primary = true;
		
					super.Emails = new List<SCIMUser.Emails>{e,e2};
				}
				this.displayName = userIn.name;
				
				Entitlements enExtSystem = new Entitlements();
				enExtSystem.type = 'externalSystems';
				enExtSystem.value = 'Postal Accounts Settlement System (PASS)';
				this.entitlements.add(enExtSystem);
			}
			else{

				this.title = userIn.Contact.title;

				this.preferredLanguage = userIn.LanguageLocaleKey;

				this.entitlements = new List<Entitlements>();

				Entitlements enCode = new Entitlements();  
				Entitlements enRequestedRole = new Entitlements(); 
				Entitlements enName = new Entitlements();

				enCode.type = 'iataCode';
				enCode.value = userIn.contact.Account.IATACode__c;
				this.entitlements.add(enCode);

				enRequestedRole.type = 'Requested Role';
				if(ctt.Title == 'PASS Admin'){
					enRequestedRole.value = 'PASS Admin';
				}
				else{
					enRequestedRole.value = 'PASS User';
				}
				
				this.entitlements.add(enRequestedRole);

				enName.type = 'NAME';
				enName.value = userIn.contact.account.name;
				this.entitlements.add(enName);

				if (ctt.email != null) {
					SCIMUser.Emails e = new SCIMUser.Emails();
					e.value = email;
					e.type = 'home';
					e.primary = false;
		
					SCIMUser.Emails e2 = new SCIMUser.Emails();
					e2.value = email;
					e2.type = 'work';
					e2.primary = true;
		
					super.Emails = new List<SCIMUser.Emails>{e,e2};
				}
				this.displayName = userIn.name;
				
				Entitlements enExtSystem = new Entitlements();
				enExtSystem.type = 'externalSystems';
				enExtSystem.value = 'Postal Accounts Settlement System (PASS)';
				this.entitlements.add(enExtSystem);
			}

			

		}
	}
}

global with sharing class FREDSCIMUser extends SCIMUser {

/***
	Some of attributes were removed to be compliant to Mulesoft specs for FRED
*/

	public class Entitlements {
		public String type;
		public String value;
		public String display;
		public Boolean primary;
	}


	public class Name{ //OK
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
	public String externalId; //OK
	public Name name;
	public String displayName;
	public String userType;
	public String preferredLanguage;
	public List<Entitlements> entitlements;
	public List<Groups> groups;
	public List<Roles> roles;


	public FREDSCIMUser(String userName, String familyName, String givenName, String externalid, String email) {

		super(userName, familyName, givenName, externalid, email);

		super.getSchemas().add('urn:scim:schemas:extension:enterprise:1.0');

		super.name = null;
		this.name = new Name();
		if (familyName != null) this.name.familyName = familyName;
		if (givenName != null) this.name.givenName = givenName;

		if (email != null) {
			try {
				fillUpSCIMMessage(email);

			}catch(exception err){System.debug(err);}
		}

	}


	private void fillUpSCIMMessage(String email){
		User userIn = [SELECT Id, name, contact.account.RecordType.DeveloperName,AccountId, contact.account.X8585_Code__c, contact.account.Country_ISO_Code__c, contact.account.name, contact.account.IATACode__c, contact.account.sector__c, contact.account.category__c,FederationIdentifier, SmallPhotoUrl ,createdDate,lastModifiedDate,contact.Phone,CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, Contact.Title, Contact.MobilePhone, Contact.Fax, contact.Salutation from user where email = :email and IsActive = true limit 1];


		Boolean isPrimaryUser;

		// If there is an Invitation__c related to this provisioning request, retrieve the role from the Invitation__c record
		// This query will have to be updated when developing One Id generics as the Invitation__c object will have an additional field for the service and the same user could receive several invitations for different services
		List<Invitation__c> invitations = [SELECT Role__c FROM Invitation__c WHERE Email__c =: email AND ServiceId__c = null LIMIT 1];

		if(!invitations.isEmpty()){
			isPrimaryUser = invitations[0].Role__c == 'Primary';
		}
		else{
			// Check if the some user in the account has FRED primary permission set. If not, this user we'll be primary
			Integer nbOfPrimaryInAccount = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId =: userIn.AccountId];
			isPrimaryUser = nbOfPrimaryInAccount == 0;
		}


		if(userIn != null){
			this.name.honorificPrefix = userIn.contact.Salutation;

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
			Entitlements enIcaoCode = new Entitlements();
			Entitlements enRequestedRole = new Entitlements();
			Entitlements enName = new Entitlements();
			Entitlements enAccountType = new Entitlements();
			Entitlements enCountryCode = new Entitlements();

			enCode.type = 'CODE';
			enCode.value = userIn.contact.AccountId;
			this.entitlements.add(enCode);

			enRequestedRole.type = 'Requested Role';
			enRequestedRole.value = isPrimaryUser || userIn.contact.account.RecordType.DeveloperName == 'Verifiers' ? 'PRIMARY_USER' : 'SECONDARY_USER';
			this.entitlements.add(enRequestedRole);

			enName.type = 'NAME';
			enName.value = userIn.contact.account.name;
			this.entitlements.add(enName);

			enAccountType.type = 'ACCOUNT_TYPE';

			if(userIn.contact.account.RecordType.DeveloperName == 'IATA_Airline' || userIn.contact.account.RecordType.DeveloperName == 'Operator') {
				enAccountType.value = 'AIRCRAFT_OPERATOR';

				enIcaoCode.type = 'ICAO_CODE';
				enIcaoCode.value = userIn.contact.account.X8585_Code__c;
				this.entitlements.add(enIcaoCode);

			} else if(userIn.contact.account.RecordType.DeveloperName == 'ICAO_Member_State') {
				enAccountType.value = 'ICAO_MEMBER_STATE';

				enCountryCode.type = 'COUNTRY_CODE';
				enCountryCode.value = userIn.contact.account.Country_ISO_Code__c;
				this.entitlements.add(enCountryCode);
			} else if(userIn.contact.account.RecordType.DeveloperName == 'Verifiers') {
				enAccountType.value = 'VERIFIER';
			}
			this.entitlements.add(enAccountType);

			Entitlements enExtSystem = new Entitlements();
			enExtSystem.type = 'External Systems';
			enExtSystem.value = 'FRED_PLUS';
			this.entitlements.add(enExtSystem);


			this.displayName = userIn.name;

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
		}
	}
}
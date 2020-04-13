global with sharing class PASSSCIMUser extends SCIMUser {
/***
	Some of attributes are commented to be compliant to Mulesoft specs for PASS
*/

	/*
	public class Addresses {
		public String streetAddress;
		public String locality;
		public String region;
		public String postalCode;

		public String country;
		public string type;
		public Boolean primary;
	}*/

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

	/*
	public class Emails { //OK
		public String type;
		public String display;
		public Boolean primary;
		public String value;
	}
	*/

	/*
	public class PhoneNumbers {
		public String type;
		public String value;
	}
	*/
	/*
	public class Photos {
		public String type;
		public String value;
	}*/

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
	//private String enterprise;

	// Public fields to serialize / deserialize
	public List<String> schemas;
	//public String id;
	//public String userName;
	public String externalId; //OK
	public Name name;
	public String displayName;
	//public String nickName;
	//public List<SCIMUser.Emails> emails;
	//public List<PhoneNumbers> phoneNumbers;
	//public List<Photos> photos;
	public String userType;
	public String preferredLanguage;
	//public String locale;
	//public Boolean active;
	//public String title;
	public List<Entitlements> entitlements;
	public List<Groups> groups;
	public List<Roles> roles;
	//public String timezone;

	//public enterpriseExtension enx;

	//public List<Addresses> addresses;


	public PASSSCIMUser(String userName, String familyName, String givenName, String externalid, String email) {

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

	@TestVisible
	private void fillUpSCIMMessage(String email){
		//basto1p added new required field for IFG
		User userIn = [SELECT Id, name, contact.account.RecordType.DeveloperName,AccountId, contact.account.X8585_Code__c, contact.account.Country_ISO_Code__c, contact.account.name, contact.account.IATACode__c, contact.account.sector__c, contact.account.category__c,FederationIdentifier, SmallPhotoUrl ,createdDate,lastModifiedDate,contact.Phone,CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, Contact.Title, Contact.MobilePhone, Contact.Fax, contact.Salutation from user where email = :email and IsActive = true limit 1];


		//Boolean isPrimaryUser;

		// If there is an Invitation__c related to this provisioning request, retrieve the role from the Invitation__c record
		// This query will have to be updated when developing One Id generics as the Invitation__c object will have an additional field for the service and the same user could receive several invitations for different services
		/*List<Invitation__c> invitations = [select Role__c from Invitation__c where Email__c =: email limit 1];

		if(!invitations.isEmpty()){
			isPrimaryUser = invitations[0].Role__c == 'Primary';
		}
		else{
			// Check if the some user in the account has PASS primary permission set. If not, this user we'll be primary
			Integer nbOfPrimaryInAccount = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'PASS_User_Prov' AND Assignee.AccountId =: userIn.AccountId];
			isPrimaryUser = nbOfPrimaryInAccount == 0;
		}*/

		Contact ctt;
		List<AMS_Accreditation_Contact__c> amsContactList = [SELECT Id,PASS_admin__c, PASS_user__c FROM AMS_Accreditation_Contact__c WHERE Contact__c =:userIn.contactId];

		if(amsContactList.isEmpty()){
			ctt = [SELECT Id,Title,Email FROM Contact WHERE Id =:userIn.contactId];
		}
		if(userIn != null){
			if(!amsContactList.isEmpty()){
				System.debug('AMS_Accreditation_Contact__c exists, automated process');
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

				Entitlements enCode = new Entitlements();  // IATA CODE
				Entitlements enRequestedRole = new Entitlements(); // PASS ADMIN OR USER
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
				System.debug('Manual Creation');

				this.title = userIn.Contact.title;

				this.preferredLanguage = userIn.LanguageLocaleKey;

				this.entitlements = new List<Entitlements>();

				Entitlements enCode = new Entitlements();  // IATA CODE
				Entitlements enRequestedRole = new Entitlements(); // PASS ADMIN OR USER
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

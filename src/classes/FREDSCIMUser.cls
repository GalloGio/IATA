global with sharing class FREDSCIMUser extends SCIMUser {

/*** 
	Some of attributes are commented to be compliant to Mulesoft specs for FRED
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


    public class Name { //OK
        public String formatted;
        public String familyName;
        public String givenName;
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


    public FREDSCIMUser(String userName, String familyName, String givenName, String externalid, String email) {
        
        super(userName, familyName, givenName, externalid, email);
        
        super.getSchemas().add('urn:scim:schemas:extension:enterprise:1.0');
 
     	if (email != null) {
            try { 
                fillUpSCIMMessage(email);

            }catch(exception err){System.debug(err);}
        }

    } 


    private void fillUpSCIMMessage(String email){

        //basto1p added new required field for IFG
        User userIn = [SELECT Id, name, contact.account.RecordType.DeveloperName,AccountId, contact.account.ICAO_designator__c, contact.account.Country_ISO_Code__c, contact.account.name, contact.account.IATACode__c, contact.account.sector__c, contact.account.category__c,FederationIdentifier, SmallPhotoUrl ,createdDate,lastModifiedDate,Phone,CommunityNickname, TimeZoneSidKey,LanguageLocaleKey,Title,MobilePhone from user where email = :email and IsActive = true limit 1];

        // Check if the user has FRED primary permission set
        Integer nbOfPrimaryInAccount = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId =: userIn.Id];
        Boolean isPrimaryUser = nbOfPrimaryInAccount > 0;

        if(userIn != null){
            //this.id = userIn.id;
 
            //this.nickName = userIn.CommunityNickname;
            /*
            PhoneNumbers  phones = new PhoneNumbers();
            phones.type = 'mobile';
            phones.value = userIn.MobilePhone;

            List<phoneNumbers> phoneNumbersList= new List<phoneNumbers>();
            phoneNumbersList.add(phones);
            PhoneNumbers = phoneNumbersList;
            */

            //this.title = userIn.title;

            this.preferredLanguage = userIn.LanguageLocaleKey;
            //this.active = true;
            //this.timezone = userIn.TimeZoneSidKey;

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
            enRequestedRole.value = isPrimaryUser ? 'PRIMARY_USER' : 'SECONDARY_USER';
            this.entitlements.add(enRequestedRole);

            enName.type = 'NAME';
            enName.value = userIn.contact.account.name;
            this.entitlements.add(enName);

            enAccountType.type = 'ACCOUNT_TYPE';

            if(userIn.contact.account.RecordType.DeveloperName == 'IATA_Airline' || userIn.contact.account.RecordType.DeveloperName == 'Operator') {
            	 enAccountType.value = 'AIRCRAFT_OPERATOR';

            	 enIcaoCode.type = 'ICAO_CODE';
            	 enIcaoCode.value = userIn.contact.account.ICAO_designator__c;
            	 this.entitlements.add(enIcaoCode);
            	
            } else if(userIn.contact.account.RecordType.DeveloperName == 'ICAO_Member_State') {
            	enAccountType.value = 'ICAO_MEMBER_STATE';

            	enCountryCode.type = 'COUNTRY_CODE';
            	enCountryCode.value = userIn.contact.account.Country_ISO_Code__c;
            	this.entitlements.add(enCountryCode);
            } else if(userIn.contact.account.RecordType.DeveloperName == 'Verifiers') {
            	 enAccountType.value = 'ICAO_MEMBER_STATE';
            } 
            this.entitlements.add(enAccountType);

            Entitlements enExtSystem = new Entitlements();
			enExtSystem.type = 'External Systems';
            enExtSystem.value = 'FRED_PLUS';
            this.entitlements.add(enExtSystem);
            

			/*
            Photos aPhoto = new Photos();
            aPhoto.type = 'photo';
            aPhoto.value = userIn.SmallPhotoUrl;
            this.photos = new List<Photos>();
            this.photos.add(aPhoto);
            */

            this.displayName = userIn.name;

            //this.locale = userIn.LanguageLocaleKey;
        
            /*this.addresses = new List<Addresses>();
            Addresses address = new Addresses();
            address.country = '';
            address.region = '';
            this.addresses.add(address);
            */
            
            /*enterpriseExtension anEx = new enterpriseExtension();
            anEx.organization = userIn.contact.account.name;
            this.enx = anEx;
            */

         
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
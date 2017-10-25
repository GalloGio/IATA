global with sharing class COPASCIMUser extends SCIMUser {

    public class Addresses {
        public String streetAddress;
        public String locality;
        public String region;
        public String postalCode;
      
        public String country;
        public string type;
        public Boolean primary;
    }


    public class Entitlements {
        public String type;
        public String value;
        public String display;
        public Boolean primary;
    }


    public class Name {
        public String formatted;
        public String familyName;
        public String givenName;
    }

    public class Emails {
        public String type;
        public String display;
        public Boolean primary;
        public String value;
    }


    public class PhoneNumbers {
        public String type;
        public String value;
    }

    public class Photos {
        public String type;
        public String value;
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
    //private String enterprise;

    // Public fields to serialize / deserialize
    public List<String> schemas;
    public String id;
    public String userName;
    public String externalId;
    public Name name;
    public String displayName;
    public String nickName;
    public List<Emails> emails;
    public List<PhoneNumbers> phoneNumbers;
    public List<Photos> photos;
    public String userType;
    public String preferredLanguage;
    public String locale;
    public Boolean active;
    public String title;
    public List<Entitlements> entitlements;
    public List<Groups> groups;
    public List<Roles> roles;
    public String timezone;
    
    public enterpriseExtension enx;

    public List<Addresses> addresses;


    public COPASCIMUser(String userName, String familyName, String givenName, String externalid, String email) {
        
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
        User userIn = [select name, id,contact.account.name, contact.account.IATACode__c, contact.account.sector__c, contact.account.category__c,FederationIdentifier, SmallPhotoUrl ,createdDate,lastModifiedDate,Phone,CommunityNickname, TimeZoneSidKey,LanguageLocaleKey,Title,MobilePhone from user where email = :email and IsActive = true limit 1];

        if(userIn != null){
            this.id = userIn.id;
 
            this.nickName = userIn.CommunityNickname;

            PhoneNumbers  phones = new PhoneNumbers();
            phones.type = 'mobile';
            phones.value = userIn.MobilePhone;
 
            List<phoneNumbers> phoneNumbersList= new List<phoneNumbers>();
            phoneNumbersList.add(phones);
            PhoneNumbers = phoneNumbersList;

            this.title = userIn.title;

            this.preferredLanguage = userIn.LanguageLocaleKey;
            this.active = true;
            this.timezone = userIn.TimeZoneSidKey;

            Entitlements enA = new Entitlements();
            enA.value = userIn.contact.account.Sector__c;
            enA.type = 'Account Sector';

            Entitlements enB = new Entitlements();
            enB.value = userIn.contact.account.Category__c;
            enB.type = 'Account Category';
            
            //basto1p added new required field for IFG
            Entitlements enC = new Entitlements();
            enC.value = userIn.contact.account.IATACode__c;
            enC.type = 'Account Code';
          

			Entitlements enDa = new Entitlements();
            enDa.value = userIn.contact.account.id;
            enDa.type = 'Account Id';			

            if(this.entitlements == null) {
                this.entitlements = new List<Entitlements>();
                this.entitlements.add(enA);
                this.entitlements.add(enB);
                this.entitlements.add(enC);
				this.entitlements.add(enDa);
            }else{

                this.entitlements.add(enA);
                this.entitlements.add(enB);
                this.entitlements.add(enC);
				this.entitlements.add(enDa);
            }
			
            Photos aPhoto = new Photos();
            aPhoto.type = 'photo';
            aPhoto.value = userIn.SmallPhotoUrl;
            this.photos = new List<Photos>();
            this.photos.add(aPhoto);

            this.displayName = userIn.name;

            this.locale = userIn.LanguageLocaleKey;
        
            this.addresses = new List<Addresses>();
            Addresses address = new Addresses();
            address.country = '';
            address.region = '';
            this.addresses.add(address);
            
            enterpriseExtension anEx = new enterpriseExtension();
            anEx.organization = userIn.contact.account.name;
            this.enx = anEx;
            
 

        }

    }
}
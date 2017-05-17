public class GenericSCIMUser extends SCIMUser {

	public GenericSCIMUser(){
		this(null, null, null, null, null, null);
	}

	public GenericSCIMUser(String userName, String familyName, String givenName, String externalid, String email, String entitlement) {
        super(userName, familyName, givenName, externalid, email, entitlement);

        schemas.add('urn:scim:schemas:extension:enterprise:1.0');
        
     	if (email != null) {
            SCIMUser.Emails emails = new SCIMUser.Emails();
            emails.value = email;
            List<SCIMUser.Emails> emailsList = new List<SCIMUser.Emails>();
            emailsList.add(emails);
            this.emails = emailsList;
            try {
                fillUpSCIMMessage(email);
            }catch(exception err){System.debug(err);}
        }
	}




	private void fillUpSCIMMessage(String email){


	    User userIn = [select id,Contact_Account_Name__c, Portal_App_Role__c,FederationIdentifier, SmallPhotoUrl ,createdDate,lastModifiedDate,Phone,CommunityNickname, TimeZoneSidKey,LanguageLocaleKey,Title,MobilePhone from user where email = :email and IsActive = true limit 1];

	    if(userIn != null){
	        this.id = userIn.id;

	        this.meta = new Meta();

	        //this.meta.created = String.valueOf(userIn.createdDate);
	        //this.meta.lastModified = String.valueOf(userIn.lastModifiedDate);
	        this.nickName = userIn.CommunityNickname;

	        SCIMUser.PhoneNumbers  phones = new SCIMUser.PhoneNumbers();
	        phones.type = 'mobile';
	        phones.value = userIn.MobilePhone;

	        List<SCIMUser.phoneNumbers> phoneNumbersList= new List<SCIMUser.phoneNumbers>();
	        phoneNumbersList.add(phones);
	        this.PhoneNumbers = phoneNumbersList;

	        this.title = userIn.title;

	        this.preferredLanguage = userIn.LanguageLocaleKey;
	        this.active = true;
	        this.timezone = userIn.TimeZoneSidKey;

	        SCIMUser.Entitlements enA = new SCIMUser.Entitlements();
	        enA.value = userIn.Contact_Account_Name__c;
	        enA.type = 'Account Name';

	        SCIMUser.Entitlements enB = new SCIMUser.Entitlements();
	        enB.value = userIn.Portal_App_Role__c;
	        enB.type = 'Role';

	        if(this.entitlements == null) {
	            this.entitlements = new List<SCIMUser.Entitlements>();
	            this.entitlements.add(enA);
	            this.entitlements.add(enB);
	        }else{

	            this.entitlements.add(enA);
	        }
	        SCIMUser.Photos aPhoto = new SCIMUser.Photos();
	        aPhoto.type = 'photo';
	        aPhoto.value = userIn.SmallPhotoUrl;
	        this.photos = new List<SCIMUser.Photos>();
	        this.photos.add(aPhoto);

	        this.displayName = '';

	        this.locale = '';
	        //Enterprise
	        /*


	            "urn:scim:schemas:extension:enterprise:1.0": {
	            "employeeNumber": "701984",
	            "costCenter": "4130",
	            "organization": "Universal Studios",
	            "division": "Theme Park",
	            "department": "Tour Operations",
	            "manager": {
	              "managerId": "26118915-6090-4610-87e4-49d8ca9f808d",
	              "displayName": "John Smith"
	            }
	          },


	         this.enterprise = new SCIMUser.Enterprise();
	         this.enterprise.organization = userIn.Contact_Account_Name__c;
	         this.enterprise.costCenter = '';

	        enterprise a = new SCIMUser.Enterprise();
	        a.organization = userIn.Contact_Account_Name__c;
	        this.extension = new Map<String, Enterprise>();
	        this.extension.put('urn:scim:schemas:extension:enterprise:1.0',a);

	        */
	        //this.enterprise = '\"urn:scim:schemas:extension:enterprise:1.0\":{\"organization\":\"' + userIn.Contact_Account_Name__c +'\"}}';
	        this.addresses = new List<SCIMUser.Addresses>();
	        SCIMUser.Addresses address = new SCIMUser.Addresses();
	        address.country = '';
	        address.region = '';
	        this.addresses.add(address);


	    }

	}
}
public with sharing class GDI_SCIMUser extends SCIMUser {
	
	public GDI_SCIMUser(String userName, String lastName, String firstName, String externalid, String email, String properties) {
		super(userName, lastName, firstName, externalid, email);

		schemas.add('urn:scim:schemas:extension:enterprise:1.0');

		if (lastName != null || firstName != null) this.displayName = firstName + ' ' + lastName;

		if (email != null) { 
		    SCIMUser.Emails scimEmail = new SCIMUser.Emails();
		    scimEmail.value = email;
		    scimEmail.type = 'work';
		    scimEmail.primary = true;

		    this.emails = new List<SCIMUser.Emails>{scimEmail};
		}

		if (properties != null) {
		    Map<String, String> propertyMap = (Map<String, String>) JSON.deserialize(properties, Map<String,String>.class);

			List<SCIMUser.Entitlements> entitlementsList = new List<SCIMUser.Entitlements>();
		    for (String property: propertyMap.keySet()) {

		    	if (property == 'language') this.preferredLanguage = propertyMap.get(property);
		    	else if (property == 'Phone') {
		    		SCIMUser.PhoneNumbers phoneNumber = new SCIMUser.PhoneNumbers();
		    		phoneNumber.type = 'work';
		    		phoneNumber.value = propertyMap.get(property);
		    		
		    		this.phoneNumbers = new List<SCIMUser.PhoneNumbers>{phoneNumber};
		    	} else {
		    		SCIMUser.Entitlements scimEntitlement = new SCIMUser.Entitlements();

		    		scimEntitlement.type = property;
		    		scimEntitlement.value = propertyMap.get(property);

		    		entitlementsList.add(scimEntitlement);
		    	}
		    }

		    this.entitlements = entitlementsList;
		}

		HttpCall.HTTP_METHOD_PATCH = 'PUT';
	}
}
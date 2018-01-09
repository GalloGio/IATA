public class ANG_IEPSCIMUser extends SCIMUser {
	public ANG_IEPSCIMUser(String userName, String familyName, String givenName, String externalid, String email, String properties) {
		super(userName, familyName, givenName, externalid, email);
		schemas.add('urn:scim:schemas:extension:enterprise:1.0');

		if ((familyName != null) || (givenName != null))  this.displayName = givenName + ' ' + familyName;

		if (email != null) { 
		    SCIMUser.Emails e = new SCIMUser.Emails();
		    e.value = email;
		    e.type = 'work';
		    e.primary = true;

		    this.emails = new List<SCIMUser.Emails>{e};
		}

		System.debug(loggingLevel.FINEST, '____ [cls ANG_IEPSCIMUser - constructor] properties - ' + properties);

		if (properties != null) {
		    Map<String, String> propertyMap = (Map<String, String>)JSON.deserialize(properties, Map<String,String>.class);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_IEPSCIMUser - constructor] propertyMap - ' + propertyMap);

			List<SCIMUser.Entitlements> entitlementsList = new List<SCIMUser.Entitlements>();
		    for(String property : propertyMap.keySet()){

		    	if(property == 'language') this.preferredLanguage = propertyMap.get(property);
		    	else{
		    		SCIMUser.Entitlements e = new SCIMUser.Entitlements();

		    		e.type = property;
		    		e.value = propertyMap.get(property);

		    		entitlementsList.add(e);
		    	}
		    }
		    this.entitlements = entitlementsList;
		}
		
		//Easy Pay uses PUT instead of Patch		
		HttpCall.HTTP_METHOD_PATCH = 'PUT';
	}
}
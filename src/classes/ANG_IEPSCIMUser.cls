public class ANG_IEPSCIMUser extends SCIMUser {
	public ANG_IEPSCIMUser(String userName, String familyName, String givenName, String externalid, String email, String entitlement, String language) {
		super(userName, familyName, givenName, externalid, email, entitlement);
		schemas.add('urn:scim:schemas:extension:enterprise:1.0');

		if ((familyName != null) || (givenName != null))  this.displayName = givenName + ' ' + familyName;

		if(language != null) this.preferredLanguage = language;

		if (email != null) { 
		    SCIMUser.Emails e = new SCIMUser.Emails();
		    e.value = email;
		    e.type = 'work';
		    e.primary = true;

		    this.emails = new List<SCIMUser.Emails>{e};
		}

		System.debug(loggingLevel.FINEST, '____ [cls ANG_IEPSCIMUser - constructor] entitlement - ' + entitlement);

		if (entitlement != null) {
		    Map<String, String> entitlements = (Map<String, String>)JSON.deserialize(entitlement, Map<String,String>.class);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_IEPSCIMUser - constructor] entitlements - ' + entitlements);

			List<SCIMUser.Entitlements> entitlementsList = new List<SCIMUser.Entitlements>();
		    for(String entitlementType : entitlements.keySet()){
		    	SCIMUser.Entitlements e = new SCIMUser.Entitlements();

		    	e.type = entitlementType;
		    	e.value = entitlements.get(entitlementType);

		    	entitlementsList.add(e);
		    }
		    this.entitlements = entitlementsList;
		}
		
		//Easy Pay uses PUT instead of Patch		
		HttpCall.HTTP_METHOD_PATCH = 'PUT';
	}
}
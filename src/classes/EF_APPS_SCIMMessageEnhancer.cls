public with sharing class EF_APPS_SCIMMessageEnhancer extends SCIMMessageEnhancer{

	public EF_APPS_SCIMMessageEnhancer(){ }

	public EF_APPS_SCIMMessageEnhancer(String messageType){

		super(messageType);
	}

	public override SCIMUser enhanceMessage(Process.PluginRequest request){

		String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
		String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
		String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
		String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
        String properties = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_PROPERTIES);
        
        SCIMUser sUsr = new SCIMUser(userName, lastName, firstName, externalId, email);

		if (properties != null) {
			Map<String, String> propertyMap = (Map<String, String>)JSON.deserialize(properties, Map<String,String>.class);
			System.debug(loggingLevel.FINE, '____ [cls EF_APPS_SCIMMessageEnhancer - constructor] propertyMap - ' + propertyMap);

			List<SCIMUser.Entitlements> entitlementsList = new List<SCIMUser.Entitlements>();
			for(String property : propertyMap.keySet()){

				/*if(property == 'language') sUsr.preferredLanguage = propertyMap.get(property);
				else{*/
                SCIMUser.Entitlements e = new SCIMUser.Entitlements();

                e.type = property;
                e.value = propertyMap.get(property);

                entitlementsList.add(e);
				//}
			}
			sUsr.entitlements = entitlementsList;
		}

		//Mulesoft uses PUT instead of Patch 
		HttpCall.HTTP_METHOD_PATCH = 'PUT';

		return sUsr;
	}
}
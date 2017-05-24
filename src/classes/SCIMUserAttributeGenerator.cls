global class SCIMUserAttributeGenerator {

	public static final String PARAM_FIRSTNAME = 'firstName';
	public static final String PARAM_LASTNAME = 'lastName';
	public static final String PARAM_EMAIL = 'email';
	public static final String PARAM_USERNAME = 'username';
	public static final String PARAM_EXTERNALID = 'externalId';
	public static final String PARAM_ENTITLEMENT = 'entitlement';
	public static final String PARAM_PROPERTIES = 'properties';

	public static final String PARAM_ID = 'id';
	public static final String PARAM_DISPLAYNAME = 'displayName';
	public static final String PARAM_NICKNAME = 'nickName';
	public static final String PARAM_USERTYPE = 'userType';
	public static final String PARAM_PREFERREDLANGUAGE = 'preferredLanguage';
	public static final String PARAM_LOCALE = 'locale';
	public static final String PARAM_TITLE = 'title';
	public static final String PARAM_ACTIVE = 'active';

	private static Map<String,String> ReplaceKeyMap = new Map<String,String>{
		'enx' => 'urn:scim:schemas:extension:enterprise:1.0'
		};

	global SCIMUser getMappedAttributes(Process.PluginRequest request){
		
		SCIMUser user = new SCIMUser();
		String messageType = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_ENTITLEMENT);

		if(String.isNotBlank(messageType)){

			System.debug(loggingLevel.FINEST, '____ [cls SCIMUserAttributeGenerator - getMappedAttributes] messageType - ' + messageType);

			SCIM_App_Messages_Definition__c config = SCIM_App_Messages_Definition__c.getValues(messageType);

			if(config != null){

				Type t = Type.forName(config.Apex_Class_Name__c);

				if(t.newInstance() instanceof SCIMMessageEnhancer){

					SCIMMessageEnhancer instance = (SCIMMessageEnhancer) t.newInstance();
					user = instance.enhanceMessage(request);
				}
			}
		}else {
			SCIMMessageEnhancer instance = new SCIMMessageEnhancer();
			user = instance.enhanceMessage(request);
		}

		return user;
	}

	global String getSerializedAttributes(SCIMUser user){

		String json = System.JSON.serialize(user, true);

		String jsonTransformed = jsonReplaceAll(json);

		return jsonTransformed;
	}
 
	private String jsonReplaceAll(String json){
		for(String key : ReplaceKeyMap.keySet()){
			json = json.replaceAll('"'+key+'":', '"'+ReplaceKeyMap.get(key)+'":');
		}
		return json;
	}
}

public with sharing class EF_APPS_SCIMMessageEnhancer extends SCIMMessageEnhancer{

	public EF_APPS_SCIMMessageEnhancer(){ }

	public EF_APPS_SCIMMessageEnhancer(String messageType){

		super(messageType);
	}

	public override SCIMUser enhanceMessage(Process.PluginRequest request){

		String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
		String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
		String displayName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_DISPLAYNAME);
		String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
		String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
		String preferredLanguage = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_PREFERREDLANGUAGE);
		String title = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_TITLE);
		Boolean active = (Boolean)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_ACTIVE);

		return new EF_APPS_SCIMUser(lastName, firstName, externalid, email, displayName, preferredLanguage, title, active);
	}
}
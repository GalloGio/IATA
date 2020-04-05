global virtual with sharing class PASSMessageEnhancer extends SCIMMessageEnhancer{

	public PASSMessageEnhancer(){}

	public PASSMessageEnhancer(String messageType){

		super(messageType);
	}

	 public override SCIMUser enhanceMessage(Process.PluginRequest request){

		String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
		String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
		String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
		String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
		String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);

		PASSSCIMUser PASSUser = new PASSSCIMUser(userName, lastName, firstName, externalId, email);

		return PASSUser;
	}

}

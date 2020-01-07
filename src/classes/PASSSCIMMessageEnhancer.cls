public with sharing class PASSSCIMMessageEnhancer extends SCIMMessageEnhancer {
	public PASSSCIMMessageEnhancer(){}

	public PASSSCIMMessageEnhancer(String messageType){

		super(messageType);
	}

	 public override SCIMUser enhanceMessage(Process.PluginRequest request){

		String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
		String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
		String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
		String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
		String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);

		PASSSCIMUser newSCIMUser = new PASSSCIMUser(userName, lastName, firstName, externalId, email);

		system.debug('@@ JCFF Entitlement FRED1: '+ newSCIMUser);

		return newSCIMUser;
	}
}
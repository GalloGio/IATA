public with sharing class GDI_SCIMMessageEnhancer extends SCIMMessageEnhancer {
	
	public GDI_SCIMMessageEnhancer() {}

	public GDI_SCIMMessageEnhancer(String messageType) {   
        super(messageType);
    }

    public override SCIMUser enhanceMessage(Process.PluginRequest request) {
    	String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
        String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
        String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
        String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
        String properties = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_PROPERTIES);
        
        GDI_SCIMUser newSCIMUser = new GDI_SCIMUser(userName, lastName, firstName, externalId, email, properties);
        
        return newSCIMUser;
    }
}
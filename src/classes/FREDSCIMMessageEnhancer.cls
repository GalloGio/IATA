public with sharing class FREDSCIMMessageEnhancer  extends SCIMMessageEnhancer{

	public FREDSCIMMessageEnhancer(){}
    
    public FREDSCIMMessageEnhancer(String messageType){
        
        super(messageType);
    } 

	 public override SCIMUser enhanceMessage(Process.PluginRequest request){

        String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
        String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
        String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
        String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
        
        FREDSCIMUser newSCIMUser = new FREDSCIMUser(userName, lastName, firstName, externalId, email);
       
        system.debug('@@ Entitlement FRED1: '+newSCIMUser);
        
        return newSCIMUser;
    }
}
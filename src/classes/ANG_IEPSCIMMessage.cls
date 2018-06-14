public with sharing class ANG_IEPSCIMMessage extends SCIMMessageEnhancer{
            
    public ANG_IEPSCIMMessage(){ }
        
    public ANG_IEPSCIMMessage(String messageType){
        
        super(messageType);
    } 
    
    public override SCIMUser enhanceMessage(Process.PluginRequest request){

        String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
        String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
        String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
        String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
        String properties = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_PROPERTIES);
        
        return new ANG_IEPSCIMUser(userName, lastName, firstName, externalId, email, properties);
    }
}
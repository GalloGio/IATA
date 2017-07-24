public with sharing class COPASCIMMessageEnhancer extends SCIMMessageEnhancer{
    
    public COPASCIMMessageEnhancer(){}
    
    public COPASCIMMessageEnhancer(String messageType){
        
        super(messageType);
    } 
    
    public override SCIMUser enhanceMessage(Process.PluginRequest request){

        String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
        String firstName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
        String lastName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
        String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
        
        COPASCIMUser newSCIMUser = new COPASCIMUser(userName, lastName, firstName, externalId, email);
        
        return newSCIMUser;
    }
}
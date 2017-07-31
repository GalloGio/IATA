global virtual with sharing class SCIMMessageEnhancer {
    
    public final String messageType;
    
    public SCIMMessageEnhancer(){
        
    }
    public SCIMMessageEnhancer(String messageType){
        
        this.messageType = messageType;
    }
    
     
    global virtual SCIMUser enhanceMessage(Process.PluginRequest request){

    	String userName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERNAME);
    	String familyName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_FIRSTNAME);
    	String givenName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LASTNAME);
    	String externalid = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EXTERNALID);
    	String email = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_EMAIL);
    	String id = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_ID);
    	String displayName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_DISPLAYNAME);
    	String nickName = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_NICKNAME);
    	String userType = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_USERTYPE);
    	String preferredLanguage = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_PREFERREDLANGUAGE);
    	String locale = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_LOCALE);
    	String title = (String)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_TITLE);
    	Boolean active = (Boolean)request.inputParameters.get(SCIMUserAttributeGenerator.PARAM_ACTIVE);

    	return new SCIMUser(userName, familyName, givenName, externalid, email, id, displayName, nickName, userType, preferredLanguage, locale, title, active);
    }
    
}
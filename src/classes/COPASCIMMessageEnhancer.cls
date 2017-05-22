public with sharing class COPASCIMMessageEnhancer extends SCIMMessageEnhancer{
    
    public COPASCIMMessageEnhancer(){}
    
    public COPASCIMMessageEnhancer(String messageType){
    	
    	super(messageType);
    } 
    
    public override SCIMUser enhanceMessage(SCIMUser scimuserIn){
    	
    	COPASCIMUser newSCIMUser = new COPASCIMUser(scimuserIn.userName,  scimuserIn.name.familyName, scimuserIn.name.givenName, scimuserIn.externalId, scimuserIn.emails.get(0).value, '');
    	
    	return newSCIMUser;
    }
}
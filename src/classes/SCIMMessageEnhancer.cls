global abstract with sharing class SCIMMessageEnhancer {
	
	public final String messageType;
	
	public SCIMMessageEnhancer(){
		
	}
	public SCIMMessageEnhancer(String messageType){
		
		this.messageType = messageType;
	}
	
	 
	global abstract SCIMUser enhanceMessage(SCIMUser scimuserIn);
    
}
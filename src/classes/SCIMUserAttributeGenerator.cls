global class SCIMUserAttributeGenerator {

    public static final String PARAM_FIRSTNAME = 'firstName';
    public static final String PARAM_LASTNAME = 'lastName';
    public static final String PARAM_EMAIL = 'email';
    public static final String PARAM_USERNAME = 'username';
    public static final String PARAM_EXTERNALID = 'externalId';
    public static final String PARAM_ENTITLEMENT = 'entitlement';
    
    private static Map<String,String> ReplaceKeyMap = new Map<String,String>{
    	'enx' => 'urn:scim:schemas:extension:enterprise:1.0'
    	};

    global SCIMUser getMappedAttributes(Process.PluginRequest request){
        String userName = (String)request.inputParameters.get(PARAM_USERNAME);
        String firstName = (String)request.inputParameters.get(PARAM_FIRSTNAME);
        String lastName = (String)request.inputParameters.get(PARAM_LASTNAME);
        String externalid = (String)request.inputParameters.get(PARAM_EXTERNALID);
        String email = (String)request.inputParameters.get(PARAM_EMAIL);
        String messageType = (String)request.inputParameters.get(PARAM_ENTITLEMENT);
		        
        SCIMUser user = new SCIMUser(userName, lastName, firstName, externalid, email, '');
		SCIMUser userEnhanced = null;
		
		if(String.isNotBlank(messageType)){
			
			System.debug('********* messageType = ' + messageType);
			
			SCIM_App_Messages_Definition__c config = SCIM_App_Messages_Definition__c.getValues(messageType);
			
			if(config != null){
				
		     	Type t = Type.forName(config.Apex_Class_Name__c);
	        	
	        	if(t.newInstance() instanceof SCIMMessageEnhancer){
	        		
	        		SCIMMessageEnhancer instance = (SCIMMessageEnhancer) t.newInstance();
	        		
	        		userEnhanced = instance.enhanceMessage(user);
	        		
	        	}			
			}
			
		}
				
        return userEnhanced == null ? user : userEnhanced;
    }

    global String getSerializedAttributes(SCIMUser user){
    	
    	String json = System.JSON.serialize(user, true);
        
        System.debug('********* json = ' + json);
        
        String jsonTransformed = jsonReplaceAll(json);
        
        System.debug('********* jsonTransformed = ' + jsonTransformed);
        
        return jsonTransformed;
    }
 
    private String jsonReplaceAll(String json){
        for(String key : ReplaceKeyMap.keySet()){
            json = json.replaceAll('"'+key+'":', '"'+ReplaceKeyMap.get(key)+'":');
        }
        return json;
    }
}

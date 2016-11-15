public class AMS_TriggerExecutionManager {
    
    public static Boolean checkExecution(Schema.SObjectType sObjType, String triggerExecuting){
    	    	
    	try {
    		
    		if(sObjType != null && triggerExecuting != null) {
    			
		    	AMS_Trigger_Execution_Manager__c manager = AMS_Trigger_Execution_Manager__c.getInstance();
		    	
		    	if(manager == null) {
		    		
		    		return true;
		    	}
		    	
		    	if(manager.All__c) {
		    		
		    		return false;
		    	}
		    	
		    	String triggers = (String) manager.get(sObjType.getDescribe().getName().replace('__c', '_c')+'_Triggers__c');
		    	
		    	if(triggers == null || triggers == '') {
		    		
		    		return true;
		    	}
		    	
		    	if(triggers.toUpperCase().contains(triggerExecuting.toUpperCase())) {
		    		
		    		return false;
		    	}
    		}
    	}catch (Exception e) {
    		
    		system.debug(e.getMessage());
    		return true;
    	}
    	
    	return true;
    }
}
public class AMS_TriggerExecutionManager {
    
    public static Boolean checkExecution(Schema.SObjectType sObjType, String triggerExecuting){

    	String triggerField;

    	try {
    		
    		if(sObjType != null && triggerExecuting != null) {
    			
		    	AMS_Trigger_Execution_Manager__c manager = AMS_Trigger_Execution_Manager__c.getInstance();
		    	
		    	if(manager == null) return true;		    	
		    	if(manager.All__c) return false;
		    	
		    	triggerField = sObjType.getDescribe().getName().replace('__c', '_c')+'_Triggers__c';
		    	String triggers = (String) manager.get(triggerField);
		    	
		    	if(triggers == null || triggers == '') return true;
		    	
		    	if(triggers.toUpperCase().contains(triggerExecuting.toUpperCase())) return false;
    		}
    	}catch (Exception e) {
    		System.debug(loggingLevel.ERROR, '____ [cls AMS_TriggerExecutionManager - checkExecution] There\'s no setting configured for '+sObjType.getDescribe().getLabelPlural()+'. Please create a field called '+triggerField+' on the Trigger Execution Manager custom setting.');
    	}
    	
    	return true;
    }
}
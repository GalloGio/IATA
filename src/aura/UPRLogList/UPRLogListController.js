({
	doInit : function(component, event, helper) {
        var action = component.get("c.getRequestLogs");
        var recordToLookUp = component.get("v.record");
        action.setParams({"record": recordToLookUp});
        
        action.setCallback(this, function(actionResult) {
            component.set("v.logs", actionResult.getReturnValue());            
        });
        $A.enqueueAction(action);
	}
})
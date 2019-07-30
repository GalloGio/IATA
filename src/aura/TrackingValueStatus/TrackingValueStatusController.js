({
    doInit : function(component, event, helper) {
        var currentStage = component.get("v.stage");
        var splitStages = currentStage.split(":");
        var finalStage = splitStages[splitStages.length-1];
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getOldNewStatus");
        
        action.setParams({  
            recordId : component.get("v.processOrchestratorId"),
            Status: finalStage
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.ProcessOrchestratorStepAction', response.getReturnValue());
                
                var ProcessOrchestratorStepActionListSize = component.get("v.ProcessOrchestratorStepAction").length;
                if(pageSize > ProcessOrchestratorStepActionListSize){
                    pageSize = ProcessOrchestratorStepActionListSize;
                }
                component.set("v.totalSize", ProcessOrchestratorStepActionListSize);
                
            }
        });
        $A.enqueueAction(action);
        
    }, 
    
    
    
})
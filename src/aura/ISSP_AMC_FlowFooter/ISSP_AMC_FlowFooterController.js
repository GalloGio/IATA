({
    doInit : function (component, event, helper) {
        var action = component.get("c.getStageWithStatusMap");
        action.setParams({ "processOrchestratorId" : component.get("v.processOrchestratorId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var currentStage = component.get("v.stage");
                var splitStages = currentStage.split(":");
                var finalStage = splitStages[splitStages.length-1].replace('_', ' ');
                component.set("v.stage", finalStage);
                
                
                var returnValue = response.getReturnValue();
                var stageA_Status = "";
                var stageB_Status = "";
                var stageC_Status = "";
                var stageD_Status = "";
                var stageE_Status = "";
                var stageF_Status = "";
                
                for(var specialKey in returnValue){
                    var keyMap = specialKey.split("#");
                    var key = keyMap[0];
                    // key is Stage
                    // returnValue[specialKey] is the Status
                    if(key == "STAGE A"){
                        stageA_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE B"){
                        stageB_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE C"){
                        stageC_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE D"){
                        stageD_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE E"){
                        stageE_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE F"){
                        stageF_Status = returnValue[specialKey];
                    }
                }

                /*
                if(finalStage == "Stage B" && 
                   (stageA_Status != "Completed" || 
                    stageB_Status != "Completed")){
                    component.set("v.nextVariant", "destructive");
                }
                else {
                    component.set("v.nextVariant", "brand");
                }
                */

                if(finalStage == "Stage D" && 
                        (stageA_Status != "Completed" || 
                         stageB_Status != "Completed" || 
                         stageC_Status != "Completed" || 
                         stageD_Status != "Completed")){
                    component.set("v.nextVariant", "destructive");
                }
                else {
                    component.set("v.nextVariant", "brand");
                }
                
                if(finalStage == "Stage F" && 
                        (stageA_Status != "Completed" || 
                         stageB_Status != "Completed" || 
                         stageC_Status != "Completed" || 
                         stageD_Status != "Completed" || 
                         stageE_Status != "Completed" || 
                         stageF_Status != "Completed")){
                    component.set("v.finishVariant", "destructive");
                }
                else {
                    component.set("v.finishVariant", "brand");
                }
                
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
    },
    previousAction : function(component, event, helper) {
        var navigate = component.get("v.navigateFlow");
        navigate("BACK");		
    },
    nextAction : function(component, event, helper) {
        var navigate = component.get("v.navigateFlow");
        navigate("NEXT");		
    },
    finishAction : function(component, event, helper) {
        var navigate = component.get("v.navigateFlow");
        navigate("FINISH");		
    }
})
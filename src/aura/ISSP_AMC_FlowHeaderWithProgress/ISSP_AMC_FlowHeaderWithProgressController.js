({
    doInit : function (component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.getStageWithStatusMap");
        action.setParams({ "processOrchestratorId" : component.get("v.processOrchestratorId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                var newMap = [];
                //var newMapProcessStep = [];
                var returnValue = response.getReturnValue();
                for(var specialKey in returnValue){
                    var keyMap = specialKey.split("#");
                    var key = keyMap[0];
                	newMap.push({value:returnValue[specialKey], key:key, tooltip:keyMap[1]});
                    //newMapProcessStep.push({value:key, key:keyMap[1]});
                }
                component.set("v.stageWithStatusMap", newMap);

                var currentStage = component.get("v.CurrentStage");
                var splitStages = currentStage.split(":");
                var finalStage = splitStages[splitStages.length-1].replace('_', ' ');
                component.set("v.CurrentStage", finalStage);

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
        component.set("v.showSpinner",false);
    }
})
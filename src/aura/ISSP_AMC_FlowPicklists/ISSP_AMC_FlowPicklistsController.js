({
	doInit : function(component, event, helper){

        var currentStage = component.get("v.CurrentStage");
        var splitStages = currentStage.split(":");
        var currentStageValue = splitStages[splitStages.length-1]
        component.set("v.CurrentStage", currentStageValue);

        var action = component.get("c.getPicklistsFromProcessOrchestrator");
        action.setParams({ "processOrchestratorId" : component.get("v.processOrchestratorId"), "stage" : currentStageValue });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var optList = [];
                var returnValue = response.getReturnValue();
                for(var picklistCounter in returnValue){
                    var picklistInfo = returnValue[picklistCounter];
                    var newMap = [];

                    for(var key in picklistInfo.pickListValueMap){
                        newMap.push({label:picklistInfo.pickListValueMap[key], value:key});
                    }

                    optList.push({
                        stepActionId: picklistInfo.stepActionId, 
                        stepActionName: picklistInfo.stepActionName, 
                        stepStatus: picklistInfo.stepStatus,
                        pickListValueMap: newMap
                    });
                }

                component.set("v.picklists", optList);

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
    handleChange : function(component, event, helper) {
        console.log("event", event.getParam("value"));
        var stepActionId = event.getParam("value").split("#")[0];
        var stepStatus = event.getParam("value").split("#")[1];

        var action = component.get("c.updateStepAction");
        action.setParams({ "stepActionId" : stepActionId, "stepStatus" : stepStatus });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var appEvent = $A.get("e.c:ISSP_AMC_RefreshProgressEvent");
                /*
                var dataParam = 
                {
                    Operation : 'AMPOPUP_OP_SET_VIEW_MODE',
                    ViewMode  : 'VIEW_MOD_TYP_SIMPLE_AMEND',
                    BookingId : component.get('v.bookingId')
                }
                appEvent.setParams({
                    "data" : dataParam
                });
                */
                appEvent.fire();

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
	}
})
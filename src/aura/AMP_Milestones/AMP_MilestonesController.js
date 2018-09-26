({
    doInit : function(component, event, helper) {
        
        // var action = component.get("c.getObjectiveName");
        // // console.log(component.get("v.accountId"));
        // // console.log(component.get("v.activityId"));
        // if( component.get("v.activityId") !== '') {
        //
        // 	action.setParams({
        // 			"objectiveId": component.get("v.activityId")
        // 	});
        // 	//Set up the callback
        // 	var self = this;
        // 	action.setCallback(this, function(actionResult) {
        // 			component.set("v.objectiveName", actionResult.getReturnValue());
        // 	});
        // 	$A.enqueueAction(action);
        // }
    },
    backToActivities : function(component, event, helper) {
        var showMilestonesEvent = component.getEvent("showMilestones");
        showMilestonesEvent.setParams({ "issue": '', "index":'' }).fire();
    },
    addMilestone : function(component, event, helper ){
        var activity = component.get("v.activity");
        
        if(activity.Status__c == 'Cancelled' || activity.Status__c == 'Delivered') {
            $A.createComponents([
                ["ui:message",{
                    "title" : "Activity is " + activity.Status__c,
                    "severity" : "error",
                }],
                ["ui:outputText",{
                    "value" : "Because of that you cannot create a new milestone"
                }]
                
            ],
                                function(components, status){
                                    if (status === "SUCCESS") {
                                    }
                                    var message = components[0];
                                    var outputText = components[1];
                                    // set the body of the ui:message to be the ui:outputText
                                    message.set("v.body", outputText);
                                    var body = component.get("v.body");
                                    body.push(message);
                                    component.set("v.body", body);
                                }
                               );
        } else {
            
            var milestones = component.get("v.milestones");
            var mstone = component.get("v.newMilestone");
            mstone.WhatId = component.get("v.activity").Id;
            var newMilestone = JSON.parse(JSON.stringify(mstone));
            milestones.unshift(newMilestone);
            component.set("v.milestones", milestones);
        }
    },
    
    handlePress : function(cmp) {
        console.log("button pressed");
    },
    handleUpdateMilestone : function(component, event, helper) {
        // console.log("handleDeleteActivity");
        var milestone = event.getParam("task");
        var index = parseInt(event.getParam("index"));
        var isNewLine = false;
        
        var action = component.get("c.upsertMilestone");
        action.setParams({
            "milestone": milestone
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                milestone = action.getReturnValue();
                console.log('success');
                var milestones = component.get("v.milestones");
                milestones[index] = milestone; // replace the line with the one returned from the database
                
                milestones.sort(function(a,b) { 
                console.log("teste:" + new Date(a.ActivityDate).getTime() );
                    return new Date(a.ActivityDate).getTime() - new Date(b.ActivityDate).getTime() 
                });
                
                component.set("v.milestones", milestones);                
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors: ' + JSON.stringify(errors));
                
                console.log("firing error event for index [" + index + "] and milestone id [" + milestone.Id + "] w message " + errors[0].pageErrors[0].message);
                
                var errorEvent = $A.get("e.c:AMP_KAPActivityError");
                errorEvent.setParams({ "errorMessage": errors[0].pageErrors[0].message, "index":index, "milestoneId": milestone.Id });
                errorEvent.fire();
                
            }
            //  console.log(action.response);
        });
        
        $A.enqueueAction(action);
    },
    
    showDeletePopup : function(component, event, helper) {
        component.set("v.showDeletionCheck", true);
        //pass the issue attribute passed from the event to a component attribute
        var task = event.getParam("task");
        component.set("v.milestoneToDelete", task);
    },

    hideDeletePopup : function(component, event, helper) {
        component.set("v.showDeletionCheck", false);
    },

    handleDeleteMilestone : function(component, event, helper) {
        console.log("handleDeleteMilestone");
        var milestone = component.get("v.milestoneToDelete");
        if(milestone == null){
            milestone = event.getParam("task");
            console.log(JSON.stringify(milestone));
        }
        var milestones = component.get("v.milestones");
        
        if(milestone.Id === undefined) {
            
            milestones.shift(); // the last item of the list is the unsaved, so we can pop()
            component.set("v.milestones", milestones);
            
        }
        else {
            
            var action = component.get("c.deleteMilestone");
            action.setParams({
                "milestone": milestone
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Remove only the deleted issue from view
                    var items = [];
                    for (var i = 0; i < milestones.length; i++) {
                        if(milestones[i]!==milestone) {
                            items.push(milestones[i]);
                        }
                    }
                    component.set("v.milestones", items);
                    // Other client-side logic
                }
            });
            $A.enqueueAction(action);
        }
        //hide the delete popup
        component.set("v.showDeletionCheck", false);
    }
})
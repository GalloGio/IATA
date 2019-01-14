({
    doInit : function(component, event, helper) {

        helper.filterView(component);
        helper.getTasks(component);
        helper.getCanEdit(component);
        helper.fetchDivisionValues(component);

    },
    setActivityId : function(component, event, helper) {
        var idx = event.getSource().get("id");
        console.log('ms: ' + idx);
    },
    showHistory : function(component, event, helper) {
        var filterView = component.get("v.filterView");
        filterView = 'history';
        component.set("v.filterView", filterView);
        helper.filterView(component);

        var currentButton = component.find("currentButton");
        $A.util.removeClass(currentButton, "slds-button--brand");
        var historyButton = component.find("historyButton");
        $A.util.addClass(historyButton, "slds-button--brand");
    },
    showCurrent : function(component, event, helper) {
        var filterView = component.get("v.filterView");
        filterView = 'current';
        component.set("v.filterView", filterView);
        helper.filterView(component);

        var currentButton = component.find("currentButton");
        $A.util.addClass(currentButton, "slds-button--brand");
        var historyButton = component.find("historyButton");
        $A.util.removeClass(historyButton, "slds-button--brand");
    },
    addActivity : function(component, event, helper ){
        var activities = component.get("v.activities");
        var newActivity = JSON.parse(JSON.stringify(component.get("v.newActivity")));

        activities.unshift(newActivity);

        component.set("v.activities", activities);
    },
    handleUpdateActivity : function(component, event, helper) {
        var activity = event.getParam("issue");
        var index = parseInt(event.getParam("index"));
        var isNewLine = false;
        if(activity.Id === undefined) isNewLine = true;
        if (activity.Account__c === 'accountId') { activity.Account__c = component.get("v.accountId");}

        var action = component.get("c.upsertActivity");
        action.setParams({
            "activity": activity
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                activity = action.getReturnValue();
                console.log('success');
                var activities = component.get("v.activities");
                activities[index] = activity; // replace the line with the one returned from the database
                component.set("v.activities", activities);

                helper.filterView(component);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors: ' + JSON.stringify(errors));

                console.log("firing error event for index [" + index + "] and activity id [" + activity.Id + "] w message " + errors[0].pageErrors[0].message);

                var errorEvent = $A.get("e.c:AMP_KAPActivityError");
                errorEvent.setParams({ "errorMessage": errors[0].pageErrors[0].message, "index":index, "activityId": activity.Id });
                errorEvent.fire();

            }

        });

        $A.enqueueAction(action);
    },

    showDeletePopup : function(component, event, helper) {
        component.set("v.showDeletionCheck", true);
        //pass the activity attribute passed from the event to a component attribute (AMP_UpdateIssueOrPriority, 
        //in this event there are two params registered, issue and index)
        var activity = event.getParam("issue");
        console.log(JSON.stringify(activity));
        component.set("v.activityToDelete", activity);
    },

    hideDeletePopup : function(component, event, helper) {
        component.set("v.showDeletionCheck", false);
    },


    handleDeleteActivity : function(component, event, helper) {
        console.log("handleDeleteActivity");
        var activity = component.get("v.activityToDelete");
        console.log(JSON.stringify(activity));
        if(activity == null){
            activity = event.getParam("issue");
            console.log(JSON.stringify(activity));
        }
        var activities = component.get("v.activities");

        if(activity.Id === undefined) {

            activities.shift(); // the last item of the list is the unsaved, so we can shift()
            component.set("v.activities", activities);

        }
        else {
            var action = component.get("c.deleteActivity");
            action.setParams({
                "activity": activity
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Remove only the deleted issue from view
                    var items = [];
                    for (var i = 0; i < activities.length; i++) {
                        if(activities[i]!==activity) {
                            items.push(activities[i]);
                        }
                    }
                    component.set("v.activities", items);

                    helper.filterView(component);
                }
            });
            $A.enqueueAction(action);
        }
        //hide the delete popup
        component.set("v.showDeletionCheck", false);
    },
    handleShowMilestones : function(component, event, helper) {

        var activity = event.getParam("issue");

        if(activity === '') {
            component.set("v.isActivityMode", true);
            helper.filterView(component);
        }
        if(activity.Id !== '') {
            component.set("v.activity", activity);
            component.set("v.activityId", activity.Id);

            helper.getActivityName(component);

            var bu = component.get("v.milestonesBackup");
            var items = new Array();
            for(var i = 0; i < bu.length; i++) {
                if(activity.Id === bu[i].WhatId) {
                    items.push(bu[i]);
                }
            }

            component.set("v.milestones", items);
            component.set("v.isActivityMode", false);
        }

    },
    setAM : function(component, event, helper) {
        component.set("v.isActivityMode", false);
    },
    setMM : function(component, event, helper) { component.set("v.isActivityMode", true);}
})
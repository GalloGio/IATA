({
	doInit : function(component, event, helper) {

		helper.filterView(component);
		helper.getTasks(component);

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
	},
	showCurrent : function(component, event, helper) {
		var filterView = component.get("v.filterView");
		filterView = 'current';
		component.set("v.filterView", filterView);
		helper.filterView(component);
	},
	addActivity : function(component, event, helper ){
		var activities = component.get("v.activities");
		var newActivity = JSON.parse(JSON.stringify(component.get("v.newActivity")));
		// console.log(JSON.stringify(activities));
		// console.log(newActivity);
		activities.push(newActivity);
		// console.log(JSON.stringify(activities));
		// console.log(activities);
		component.set("v.activities", activities);
	},
	handleUpdateActivity : function(component, event, helper) {
		// console.log("handleDeleteActivity");
		var activity = event.getParam("issue");
		var index = parseInt(event.getParam("index"));
		var isNewLine = false;
		if(activity.Id === undefined) isNewLine = true;
		if (activity.Account__c === 'accountId') { activity.Account__c = component.get("v.accountId");}
		console.log('save: ' + JSON.stringify(activity));

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
					//  console.log(action.response);
		});

	 $A.enqueueAction(action);
 },
 // TODO: fix the handling of hidden items
	handleDeleteActivity : function(component, event, helper) {
		console.log("handleDeleteActivity");
		var activity = event.getParam("issue");
		var activities = component.get("v.activities");

	if(activity.Id === undefined) {

		activities.pop(); // the last item of the list is the unsaved, so we can pop()
		console.log(JSON.stringify(activities));
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
						 // Other client-side logic
				 }
		 });
		 $A.enqueueAction(action);
	 }
 },
 // TODO: fix the handling of hidden items
	handleShowMilestones : function(component, event, helper) {
		// console.log("handleShowMilestones");
			// helper.getTasks(component);
		var activity = event.getParam("issue");
		// console.log(JSON.stringify(activity));
		// var activities = component.get("v.activities");
	if(activity === '') {
			component.set("v.isActivityMode", true);
			helper.filterView(component);
	}
	if(activity.Id !== '') {
		component.set("v.activity", activity);
		component.set("v.activityId", activity.Id);
		console.log(component.get("v.activityId"));
		helper.getActivityName(component);
		console.log(component.get("v.activityName"));
		var bu = component.get("v.milestonesAll");
		var items = new Array();
		for(var i = 0; i < bu.length; i++) {
			if(activity.Id === bu[i].WhatId) {
				items.push(bu[i]);
			}
		}
		// console.log(JSON.stringify(bu));
		// console.log(JSON.stringify(items));
		component.set("v.milestones", items);
		component.set("v.isActivityMode", false);
	}

},
	setAM : function(component, event, helper) {
		// $A.createComponent(
		// 			 "AMP_Milestones",
		// 			 {
		// 					 "accountId": component.get("v.accountId"),
		// 					 "activityId": "Press Me",
		// 					//  "press": cmp.getReference("c.handlePress")
		// 			 },
		// 			 function(newButton){
		// 					 //Add the new button to the body array
		// 					 if (component.isValid()) {
		// 							 var body = component.get("v.body");
		// 							 body.push(newButton);
		// 							 component.set("v.body", body);
		// 					 }
		// 			 }
		// 	 );
		component.set("v.isActivityMode", false);
	},
	setMM : function(component, event, helper) { component.set("v.isActivityMode", true);}
})
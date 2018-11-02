({
	filterView : function(component) {
		var action = component.get("c.getObjectives");
		var filterView = component.get("v.filterView");
		var items = new Array();
		var today = new Date();
		action.setParams({
				"accountId": component.get("v.accountId")
		});
		//Set up the callback
		var self = this;
		action.setCallback(this, function(actionResult) {
			var activities = actionResult.getReturnValue();
			for(var i = 0; i < activities.length; i++) {
				var dlYear = parseInt(activities[i].Deadline__c.substring(activities[i].Deadline__c.lenght-4,4));
				if(filterView == 'current') {
					if(dlYear >= today.getFullYear() ) {
						items.push(activities[i]);
					}
				} else {
					if(dlYear < today.getFullYear() ) {
						items.push(activities[i]);
					}

				}
			}
				component.set("v.activities", items);
		});
		$A.enqueueAction(action);
	},
	getTasks : function(component) {
		var action = component.get("c.getTasksByAccount");
		// var filterView = component.get("v.filterView"); 
		// var items = new Array();
		// var today = new Date();
		action.setParams({
				"accountId": component.get("v.accountId")
		});
		//Set up the callback
		var self = this;
		action.setCallback(this, function(actionResult) {
			var milestones = actionResult.getReturnValue();
			// for(var i = 0; i < activities.length; i++) {
			// 	var dlYear = parseInt(activities[i].Deadline__c.substring(activities[i].Deadline__c.lenght-4,4));
			// 	if(filterView == 'current') {
			// 		if(dlYear >= today.getFullYear() ) {
			// 			items.push(activities[i]);
			// 		}
			// 	} else {
			// 		if(dlYear < today.getFullYear() ) {
			// 			items.push(activities[i]);
			// 		}
			//
			// 	}
			// }
				component.set("v.milestonesBackup", milestones);
		});
		$A.enqueueAction(action);
	},
	getActivityName : function(component) {
		var action = component.get("c.getObjectiveName");
		// console.log(component.get("v.accountId"));
		// console.log(component.get("v.activityId"));
		if( component.get("v.activityId") !== '') {

			action.setParams({
				"objectiveId": component.get("v.activityId")
			});
			//Set up the callback
			// var self = this;
			action.setCallback(this, function(actionResult) {
				component.set("v.activityName", actionResult.getReturnValue());
				console.log(actionResult.getReturnValue());
			});
			$A.enqueueAction(action);
		}

	},
    getCanEdit: function(component) {
        var action;

        action = component.get("c.getCanEdit");
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            // console.log(JSON.stringify(actionResult.getReturnValue()));
            component.set("v.canEdit", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
	},

	fetchDivisionValues: function(component){
		// Fetching piclist values by record type it's only possible (at this time) by calling the REST ui-api
		// from apex there is no such thing (only all values for taht picklist), normally visualforce pages do it automatically by using tag <apex:inputField />
		// and that's why I'll fallow the previous implementation and create the list hadcoded!
		var decisionValues = [];
		decisionValues.push('APCS');
        decisionValues.push('CS');
        decisionValues.push('DG');
        decisionValues.push('FDS');
        decisionValues.push('MACS');
        decisionValues.push('MER');
        decisionValues.push('SFO');

		component.set("v.divisionValues", decisionValues);

	}
	
})
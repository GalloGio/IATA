({
	fetchIssues : function(component) {
		//Fetch the expense list from the Apex controller
		var action = component.get("c.getIssuesAndPriorities");
		var accountId = component.get("v.accountId");
		// component.set("v.editMode", false);

		var showAllCheckBox = component.find("showAllCheckBox");
		var showAll = showAllCheckBox.get("v.value");
		action.setParams({
				"accountId": accountId
			});
			action.setCallback(this, function(a) {
				 var issues = a.getReturnValue();
				 var backup = new Array();
				 var filteredIssues = new Array();
				 var state = a.getState();
				 if (component.isValid() && state === "SUCCESS") {


				 for(var i = 0; i < issues.length; i++) {
					 backup.push(issues[i]);

					 if(showAll || issues[i].Status__c == 'Open') {
						 filteredIssues.push(issues[i]);
					 }
				 }
				component.set("v.issuesBackup",backup);
				component.set("v.issues", filteredIssues);

				 }
				 else if (state === "ERROR") {}
			});
			$A.enqueueAction(action);
	},
	sortIssues : function (component, fieldname,reverse) {
		var backup = component.get("v.issuesBackup");
		backup.sort(function(a,b) {
			// special treatment for Priority
			var rating = {'High':1,'Medium':2,'Low':3};
			if(fieldname == 'AM_Level_of_importance__c') {
				if( rating[a[fieldname]] < rating[b[fieldname]]) return 1;
				else return -1;
			}
			if (a[fieldname] === undefined) return 1;
			if (b[fieldname] === undefined) return -1;

			// checkboxes
			var checkbox = (typeof a[fieldname] === 'boolean');
			if(checkbox) {
				if (a[fieldname] < b[fieldname]) return 1;
				else return -1;
			}

			if (a[fieldname].toLowerCase() < b[fieldname].toLowerCase()) return 1;
			else return -1;
		});
		if (reverse < 0) backup.reverse();
		component.set("v.issuesBackup",backup);
		this.refreshIssues(component);
	},
	refreshIssues : function(component) {
		var issues = component.get("v.issuesBackup");
		var filteredIssues = new Array();

		var showAllCheckBox = component.find("showAllCheckBox");
		var showAll = showAllCheckBox.get("v.value");
		for(var i = 0; i < issues.length; i++) {
			if(showAll || issues[i].Status__c == 'Open') {
				filteredIssues.push(issues[i]);
			}
		}
		component.set("v.issues", filteredIssues);

	},
	upsert : function(component, issue, callback) {
		var action = component.get("c.saveIssue");
		action.setParams({
		"issue": issue
		});
		if (callback) {
		action.setCallback(this, callback);
		}
		$A.enqueueAction(action);
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
	}

})
({
	doInit: function(component, event, helper) {
		helper.fetchIssues(component);
	},
	refreshIssues : function(component, event, helper) {
		helper.refreshIssues(component);
	},
	jsLoaded: function(component, event, helper) {
		$('.slds-th__action').click(function() {
			$(this).parents('th').addClass('slds-is-sorted--asc');
			var fieldname = $(this).data('fieldname');
			var currentSortOrder = component.get('v.sortOrder');
			var reverse = 1;
			if(fieldname === currentSortOrder) {
				fieldname = fieldname+'desc';
				reverse *= -1;
			}

			component.set("v.sortOrder",fieldname);
			helper.sortIssues(component,fieldname,reverse);
		});

	},
	addIssue : function(component, event, helper ){
		var issues = component.get("v.issues");
		var newIssue = JSON.parse(JSON.stringify(component.get("v.newIssue")));
		// console.log(JSON.stringify(issues));
		// console.log(newIssue);
		issues.push(newIssue);
		// console.log(JSON.stringify(issues));
		// console.log(issues);
		component.set("v.issues", issues);
	},
	handleUpdateIssue : function(component, event, helper) {
		// console.log("handleDeleteIssue");
		var issue = event.getParam("issue");
		var index = parseInt(event.getParam("index"));
		var isNewLine = false;
		if(issue.Id === undefined) isNewLine = true;
	 if (issue.Account__c === 'accountId') { issue.Account__c = component.get("v.accountId");}
	 console.log('save: ' + JSON.stringify(issue));

	 var action = component.get("c.upsertIssue");
	 action.setParams({
	 "issue": issue
	 });
	 action.setCallback(this, function(response){
				var state = response.getState();
				if (component.isValid() && state === "SUCCESS") {
					issue = action.getReturnValue();
						console.log('success');
						var issues = component.get("v.issues");
						issues[index] = issue; // replace the line with the one returned from the database
						component.set("v.issues", issues);

						if(isNewLine) {

							var backup = component.get("v.backup");
							backup.push(issue);
							component.set("v.backup", backup);
						}

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
	handleDeleteIssue : function(component, event, helper) {
		console.log("handleDeleteIssue");
		var issue = event.getParam("issue");
		var issues = component.get("v.issues");

	if(issue.Id === undefined) {

		issues.pop(); // the last item of the list is the unsaved, so we can pop()
		console.log(JSON.stringify(issues));
		component.set("v.issues", issues);

	}
	else {

		var action = component.get("c.deleteIssue");
		 action.setParams({
				 "issue": issue
		 });
		 action.setCallback(this, function(response) {
				 var state = response.getState();
				 if (state === "SUCCESS") {
						 // Remove only the deleted issue from view
						 var items = [];
						 for (var i = 0; i < issues.length; i++) {
								 if(issues[i]!==issue) {
										 items.push(issues[i]);
								 }
						 }
						 component.set("v.issues", items);
						 // Other client-side logic
				 }
		 });
		 $A.enqueueAction(action);
	 }
	}
})
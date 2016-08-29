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
            if(currentSortOrder === undefined) {
                currentSortOrder = fieldname;
            }
            
            var reverse = 1;
            if(fieldname === currentSortOrder) {
                currentSortOrder = fieldname+'desc';
                reverse *= -1;
            } else {
                currentSortOrder = fieldname;
            }

            component.set("v.sortOrder",currentSortOrder);
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
                
                helper.fetchIssues(component);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors: ' + JSON.stringify(errors));
                
                console.log("firing error event for index [" + index + "] and account role id [" + issue.Id + "] w message " + errors[0].pageErrors[0].message);
                
                var errorEvent = $A.get("e.c:AMP_IssueOrPriorityError");
                errorEvent.setParams({ "errorMessage": errors[0].pageErrors[0].message, "index":index, "issueId": issue.Id });
                errorEvent.fire();
            }
            
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
                    
                    
                    helper.fetchIssues(component);
                }
            });
            $A.enqueueAction(action);
        }
    }
})
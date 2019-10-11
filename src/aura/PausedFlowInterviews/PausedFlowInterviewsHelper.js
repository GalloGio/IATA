({
    populateTable : function(component, event, helper) {
        var action = component.get("c.getInterviews");
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Push interviews fetched by the Apex controller to the component
                var recordRelations = response.getReturnValue();
                var interviews = [];
                for (var i = 0; i < recordRelations.length; i++) {
                    interviews.push(
                        {
                            Id: recordRelations[i].Id,
                            InterviewLabel: recordRelations[i].InterviewLabel,
                            PauseLabel: recordRelations[i].PauseLabel,
                            CurrentElement: recordRelations[i].CurrentElement,
                            PausedDate: recordRelations[i].CreatedDate,
                            PausedBy: recordRelations[i].Owner.Name
                        });
                }
                component.set('v.Interviews', interviews);
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
        }));
        $A.enqueueAction(action);
    },
    
    handleFlow: function (component, id, action) {
       
        // On resume, render the interview in a modal
        $A.createComponent("lightning:flow", {"onstatuschange": component.get("c.statusChange")},
            function (content, status) {
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        body: content,
                        showCloseButton: true,
                        closeCallback: function () {
                            $A.get('e.force:refreshView').fire();
                        }
                    }).then(function(overlay) {
                        // Use to close the modal later
                        component.set("v.overlay", overlay);
                    });
                    if (action === "resume") {
                    	content.resumeFlow(id);
                    }
                    else if (action === "start") {
                    	content.startFlow("Claim");
                	}
                }
            });
    },
                           
    handleDelete: function (component, event, helper, id) {
        
        // On delete, pass the interview ID to the Apex controller        
        var action = component.get("c.deleteInterview");
        action.setParams({
            interviewId: id
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Automatically refresh the table
                helper.populateTable(component, event, helper);
            } else if (state === "ERROR") {
                var errors = response.getError();
                //console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
    
})
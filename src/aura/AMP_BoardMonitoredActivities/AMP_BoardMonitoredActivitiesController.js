({
    doInit : function(component, event, helper) {
        helper.getRelatedBMAList(component);
        helper.getCanEdit(component);
    },
    handleUpdateBMAs : function(component, event, helper) {
        var comment = event.getParam("comment");
        var index = parseInt(event.getParam("index"));

        console.log('update comment ' + JSON.stringify(comment));
        var action = component.get("c.upsertComment");
        action.setParams({
            "comment": comment
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var bmas = component.get("v.boardMonitoredActivities");

            if (component.isValid() && state === "SUCCESS") {
                // comment = action.getReturnValue();
                var bma = action.getReturnValue();
                console.log('success');
                console.log(JSON.stringify(bma));
                // console.log(JSON.stringify(bmas[index]));
                // if(bmas[index].Comments__r[0] === undefined) {
                //     bmas[index].Comments__r.push(comment);
                // }
                // bmas[index].Comments__r[0] = comment; // replace the line with the one returned from the database
                bmas[index] = bma;
                component.set("v.boardMonitoredActivities", bmas);

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors: ' + JSON.stringify(errors));

                var errorEvent = $A.get("e.c:AMP_BMActivityError");
                errorEvent.setParams({ "errorMessage": errors[0].pageErrors[0].message, "index":index, "bmaId": bmas[index].Id });
                errorEvent.fire();
                /*if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }*/
            }
            console.log(action.response);
        });

        $A.enqueueAction(action);
    }
})

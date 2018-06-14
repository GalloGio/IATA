({
    doInit: function(component, event, helper) {
        helper.getRelatedAccountList(component);
        // helper.getCanEdit(component);
    },
    addAccountRole : function(component, event, helper ){
        var relatedAccounts = component.get("v.relatedAccounts");
        console.log(JSON.stringify(relatedAccounts));
        var newAccountRole = JSON.parse(JSON.stringify(component.get("v.newAccountRole")));
        // console.log(JSON.stringify(relatedAccounts));
        console.log(newAccountRole);
        relatedAccounts.push(newAccountRole);
        // console.log(JSON.stringify(relatedAccounts));
        // console.log(relatedAccounts);
        component.set("v.relatedAccounts", relatedAccounts);
    },
    handleUpdateAccount : function(component, event, helper) {
        // console.log("handleDeleteAccount");
        var accountRole = event.getParam("accountRole");
        var index = parseInt(event.getParam("index"));
        var accountRole = event.getParam("accountRole");

        var isNewLine = false;
        if(accountRole.Id === undefined) isNewLine = true;

        // if (accountRole.Account__c === 'accountId') { accountRole.Account__c = component.get("v.accountId");}
        console.log('save: ' + JSON.stringify(accountRole));
        var action = component.get("c.upsertAccount");
        action.setParams({
            "accountRole": accountRole
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var relatedAccount = action.getReturnValue();
                console.log(index);
                console.log('success: ' +JSON.stringify(relatedAccount));
                var relatedAccounts = component.get("v.relatedAccounts");
                relatedAccounts[index] = relatedAccount; // replace the line with the one returned from the database
                component.set("v.relatedAccounts", relatedAccounts);

                helper.getRelatedAccountList(component);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                console.log('errors: ' + JSON.stringify(errors));

                console.log("firing error event for index [" + index + "] and account role id [" + accountRole.Id + "] w message " + errors[0].pageErrors[0].message);

                var errorEvent = $A.get("e.c:AMP_OwnershipError");
                errorEvent.setParams({ "errorMessage": errors[0].pageErrors[0].message, "index":index, "accountRoleId": accountRole.Id });
                errorEvent.fire();

            }

        });

        $A.enqueueAction(action);
        /*
         */
    },
    // TODO: fix the handling of hidden items
    handleDeleteAccount : function(component, event, helper) {
        console.log("handleDeleteAccount");
        var accountRole = event.getParam("accountRole");
        var relatedAccounts = component.get("v.relatedAccounts");

        if(accountRole.Id === undefined) {

            relatedAccounts.pop(); // the last item of the list is the unsaved, so we can pop()
            //console.log(JSON.stringify(relatedAccounts));
            component.set("v.relatedAccounts", relatedAccounts);

        }
        else {

            var action = component.get("c.deleteAccount");
            action.setParams({
                "accountRole": accountRole
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    // Remove only the deleted account from view
                    var items = [];
                    for (var i = 0; i < relatedAccounts.length; i++) {
                        if(relatedAccounts[i]!==accountRole) {
                            items.push(relatedAccounts[i]);
                        }
                    }
                    component.set("v.relatedAccounts", items);

                    helper.getRelatedAccountList(component);
                }
            });
            $A.enqueueAction(action);
        }

    }
})
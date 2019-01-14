({
	search : function(component, event, helper) {
        // Unvalidate component when user tries to change input

        var userInputValue = component.get("v.userInput");
        var resultDiv = component.find('results');

        if(userInputValue.length > 2) {
            component.set("v.searched", true);
            component.set("v.searching", true);

            var action = component.get("c.searchAccounts");
            action.setParams({
            	'search' : userInputValue,
            	'customerType' : component.get('v.customerType'),
            	'fieldsToQuery' : component.get('v.fieldNames'),
            	'fieldsToSearch' : component.get('v.searchFields'),
            	'filters' : component.get('v.filters')
            });

            action.setCallback(this, function(a) {
                var accounts = a.getReturnValue().accList;
                component.set("v.totalResult" , a.getReturnValue().totalResults);

                if(accounts != undefined && accounts.length > 0) {
                    component.set("v.accounts", accounts);
                } else {
                    component.set("v.accounts",[{'Name':$A.get("{!$Label.c.OneId_NoResults}")}]);
                }

                component.set("v.searching", false);

                // Show suggestion box
                if(!$A.util.hasClass(resultDiv, 'slds-is-open')) $A.util.addClass(resultDiv, 'slds-is-open');
            });
            $A.enqueueAction(action);

        } else {
            $A.util.removeClass(resultDiv, 'slds-is-open');
        }

	},
    
    reset : function (c) {
        c.set('v.userInput', '');
        c.set('v.searched', false);
        $A.util.removeClass(c.find('results'), 'slds-is-open');
    },
    suggestionSelected: function(c, e) {
        var selectedAccountName = e.currentTarget.dataset.value;

        if(selectedAccountName != $A.get("{!$Label.c.OneId_NoResults}")) { 
            // Set input with selected value
            //var userInputCmp = c.find("userInput");
            c.set("v.userInput", selectedAccountName);

            c.getEvent("itemSelected")
            .setParams({
                "state" : "accountSelected",
                "account" : c.get("v.accounts")[e.currentTarget.dataset.rowIndex]
            }).fire(); 
        }else{
            c.getEvent("itemSelected")
            .setParams({
                "state" : "noAccount",
                "account" : {Name : c.get("v.userInput")}
            }).fire();
        }

        // Hide suggestion box
        $A.util.removeClass(c.find('results'), 'slds-is-open');
    },
    createNew : function (c) {
        c.set("v.account.Name", c.get("v.userInput"));

        c.getEvent("itemSelected")
        .setParams({
            "state" : 'createNew',
            "account" : {Name : c.get("v.userInput")}
        })
        .fire(); 
    }
})
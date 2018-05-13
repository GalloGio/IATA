({
/**
    When a user type inside the search box
*/
	search : function(component, event, helper) {

        // Unvalidate component when user tries to change input
        component.set("v.isValid", false);
        var userInputValue = component.get("v.inputValue");
        var resultDiv = component.find('results');

        if($A.util.isEmpty(userInputValue) || userInputValue.length < 2) {
            // Hide suggestion box
            $A.util.removeClass(resultDiv, 'slds-is-open');
        } else {
            // Call Adress Doctor when user input at least 3 characters
            // When user search on input field call Address doctor to get suggestion for validation of address
            var action = component.get("c.getSuggestedAddress");
            action.setParams({
                "userInput": userInputValue,
                "countryCode":component.get("v.countryCode")
            });

            action.setCallback(this, function(a) {
                var suggestions = a.getReturnValue();
                //suggestions = [];
                if(suggestions != undefined && suggestions.length > 0) {
                    component.set("v.response", suggestions);
                } else {
                    var noResult = {'addressComplete':'No result found...', 'deliveryAddressLines':userInputValue};
                    suggestions.push(noResult);
                    component.set("v.response",suggestions);
                }
                // Show suggestion box
                if(! $A.util.hasClass(resultDiv, 'slds-is-open')) $A.util.addClass(resultDiv, 'slds-is-open');
            });
            $A.enqueueAction(action);
        }
	},
/**
    When a user select a sugestion from the suggestion box
*/
    suggestionSelected: function(component, event, helper) {
        var suggestionSelected = event.currentTarget;

        // Set input with selected value
        var response = component.get("v.response");
        var index = parseInt(suggestionSelected.dataset.value);
        component.set("v.inputValue", response[index].deliveryAddressLines);

        // Hide suggestion box
        $A.util.removeClass(component.find("results"), 'slds-is-open');
        // Validate component input
        component.set("v.isValid", true);

        var cmpEvent = component.getEvent("addressSelected");
        cmpEvent.setParams({
            "addressType" : component.get("v.type"),
            "addressSelected" : response[index] });
        cmpEvent.fire();        
    }    
})
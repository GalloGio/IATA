({
	search : function(c) {

        var userInputValue = c.get("v.inputValue");
        var resultDiv = c.find('results');

        if($A.util.isEmpty(userInputValue) || userInputValue.length < 3) {
            // Hide suggestion box
            $A.util.removeClass(resultDiv, 'slds-is-open');
        } else {
            // Call Address Doctor when user input at least 3 characters
            // When user search on input field call Address doctor to get suggestion for validation of address
            c.set("v.searching", true);
            var action = c.get("c.quickSearch");
            action.setParams({
                "userInput": userInputValue,
                "countryCode":c.get("v.countryCode")
            });

            action.setCallback(this, function(a) {
                var suggestions = a.getReturnValue();
                
                //suggestions = [];
                if(suggestions != undefined && suggestions.length > 0) {
                    c.set("v.response", suggestions);
                } else {
                    var noResult = {'street':userInputValue};
                    suggestions.push(noResult);
                    c.set("v.response",suggestions);
                }

                c.set("v.searching", false);
                // Show suggestion box
                if(! $A.util.hasClass(resultDiv, 'slds-is-open')) $A.util.addClass(resultDiv, 'slds-is-open');
            });
            $A.enqueueAction(action);
        }
	},
/**
    When a user select a sugestion from the suggestion box
*/
    suggestionSelected: function(c, e) {
        var suggestionSelected = e.currentTarget;

        // Set input with selected value
        var response = c.get("v.response");
        var index = parseInt(suggestionSelected.dataset.value);
        c.set("v.inputValue", response[index].street);

        // Hide suggestion box
        $A.util.removeClass(c.find("results"), 'slds-is-open');

        var cmpEvent = c.getEvent("addressSelected");
        cmpEvent.setParams({
            "addressType" : c.get("v.type"),
            "addressSelected" : response[index] });
        cmpEvent.fire();        
    },
    closeResults : function (c) {

        // Hide suggestion box
        $A.util.removeClass(c.find("results"), 'slds-is-open');

        // send param with change of street
        var cmpEvent = c.getEvent("addressSelected");
        cmpEvent.setParams({
            "addressType" : c.get("v.type"),
            "addressSelected" : { 'street' : c.get("v.inputValue") } 
        });
        cmpEvent.fire();
    }
})

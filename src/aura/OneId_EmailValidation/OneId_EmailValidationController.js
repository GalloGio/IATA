({
	checkTerms: function(component, event, helper) {
        // Check fields validity
        if (component.get("v.Terms") && helper.validateEmail(component)) {
            helper.checkUsername(component);
        }
    }
})
({
    showHelpMessageIfInvalid: function(component, event) {
		var required = component.get("v.required");
		var value    = component.get("v.value");
		var validity = component.get("v.validity");

		var cmp = component.get("v.this");
		var innerComponents = cmp.find(cmp.getLocalId());
		var allValid = true;

		if (innerComponents != undefined) {
			if (innerComponents.length) {
				allValid = innerComponents.reduce(function (validSoFar, inputCmp) {
					inputCmp.showHelpMessageIfInvalid();
					return validSoFar && !inputCmp.get('v.validity').valueMissing;
				}, true);
			} else {
				innerComponents.showHelpMessageIfInvalid();
				allValid = !innerComponents.get('v.validity').valueMissing;
			}
		}

		if (!allValid || (required && (value === undefined || value == null || value == ''))) {
			validity.valueMissing = true;
			component.set("v.showError", true);
			validity.valid = false;
		} else {
			validity.valueMissing = false;
			validity.valid = true;
		}
		component.set("v.validity", validity);
	}
})
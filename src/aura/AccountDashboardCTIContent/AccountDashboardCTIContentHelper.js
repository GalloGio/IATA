({
	getUIThemeDescription: function (component) {
		var action = component.get("c.getUIThemeDescription");
		action.setCallback(this, function (a) {
			component.set("v.UIThemeDescription", a.getReturnValue());
			if (a.getReturnValue() == "Theme4d") {
				component.set("v.UIThemeisLEX", true);
			} else {
				component.set("v.UIThemeisLEX", false);
			}
		});
		$A.enqueueAction(action);
	},
});

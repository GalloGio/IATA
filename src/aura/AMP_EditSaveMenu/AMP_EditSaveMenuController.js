({
    updateTriggerLabel: function(cmp, event) {
        var triggerCmp = cmp.find("trigger");
        if (triggerCmp) {
            var source = event.getSource();
            var label = source.get("v.label");
            triggerCmp.set("v.label", label);
        }
    },
    clickEdit: function (component, event) {
        var clickEditEvent = component.getEvent("editMenuClick");
        clickEditEvent.fire();
    },
    clickDelete: function (component, event) {
        var clickDeleteEvent = component.getEvent("deleteMenuClick");
        clickDeleteEvent.fire();
    }
})
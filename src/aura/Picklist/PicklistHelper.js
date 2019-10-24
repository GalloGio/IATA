({
    initLabel: function(component) {
        var currentId = component.get("v.value");
        if (currentId != null && currentId != '') {
            var item = document.getElementById(currentId);
            if (item != null) {
                $A.util.addClass(item, "slds-is-selected");
                component.set("v.valueLabel", item.dataset.label);
            } else {
                component.get("v.options").forEach(function(option) {
                    if (option.value == currentId) {
                        component.set("v.valueLabel", option.label);
                    }
                })
            }
        }
    },
    resetHiddenItems: function(component) {
        var options = component.get("v.options");
        for (var i in options) {
            var currentId = options[i].value;
            var item = document.getElementById(currentId);
            $A.util.removeClass(item, 'slds-hide');
        }
    },
    closeListBox: function(component, event) {
        var container = component.find("input-container");
        $A.util.removeClass(container, 'slds-is-open');
        component.set("v.listBoxVisible", false);

        if (!component.get("v.itemSelected")) {
            this.initLabel(component);
        }

        if (component.get('v.required') && (component.get("v.value") == null || component.get("v.value") == '')) {
            component.set("v.showError", true);
        }
    }
})
({
    doRender: function(component, event, helper) {
        if (!component.get("v.rendered")) {
            helper.initLabel(component);
            component.set("v.rendered", true);
        }
    },
    clearSelection: function(component, event, helper) {
        component.set("v.value", null);
        component.set("v.valueLabel", null);
        component.set("v.selItem", null);
        component.set("v.itemSelected", false);
    },
    togglePicklist: function(component, event, helper) {
        var container = component.find("input-container");
        if (!component.get("v.listBoxVisible") && !component.get("v.disabled")) {
            if (component.get("v.itemSelected") || component.get("v.valueLabel") == '') {
                helper.resetHiddenItems(component);
            }

            $A.util.addClass(container, 'slds-is-open');
            component.set("v.listBoxVisible", true);
        }
    },
    selectItem: function(component, event, helper) {
        var currentId = event.currentTarget.dataset.id;
        var lastId = component.get("v.value");

        component.set("v.valueLabel", event.currentTarget.dataset.label);
        component.set("v.itemSelected", true);
        component.set("v.showError", false);

        var i = event.currentTarget.dataset.index;
        if (i) {
            var options = component.get("v.options");
            var item = options[i];
            component.set("v.selItem", item);
        }

        if (currentId != lastId) {
            var item = document.getElementById(currentId);
            $A.util.addClass(item, "slds-is-selected");

            component.set("v.value", currentId);

            // onChange event
            var changeAction = component.get("v.onChange");
            if (changeAction != null) {
                $A.enqueueAction(changeAction);
            }

            if (lastId != null && lastId != '') {
                var lastItem = document.getElementById(lastId);
                $A.util.removeClass(lastItem, "slds-is-selected");
            }
        }
    },
    onInputChange: function(component, event, helper) {
        var text = event.currentTarget.value;
        component.set("v.valueLabel", text);
        component.set("v.itemSelected", false);

        if (!component.get('v.listBoxVisible')) {
            var container = component.find("input-container");
            $A.util.addClass(container, 'slds-is-open');
            component.set("v.listBoxVisible", true);
        }

        var options = component.get("v.options");
        for (var i in options) {
            var currentId = options[i].value;
            var currentLabel = options[i].label;
            var item = document.getElementById(currentId);
            if (currentLabel.toUpperCase().includes(text.toUpperCase())) {
                $A.util.removeClass(item, 'slds-hide');
            } else {
                $A.util.addClass(item, 'slds-hide');
            }
        }
    },
    changeOptions: function(component, event, helper) {
        var oldValue = component.get("v.value");
        var found = false;
        var options = component.get("v.options");
        for (var i in options) {
            var currentId = options[i].value;
            var currentLabel = options[i].label;
            var item = document.getElementById(currentId);
            if (currentId == oldValue) {
                found = true;
                $A.util.addClass(item, "slds-is-selected");
                component.set("v.valueLabel", currentLabel);
                component.set("v.itemSelected", true);
            }
        }
        if (!found) {
            component.set("v.valueLabel", "");
            component.set("v.itemSelected", false);
            component.set("v.value", "");
        }
    }
})
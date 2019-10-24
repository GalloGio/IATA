({
    afterRender: function (component, helper) {
        this.superAfterRender();

        helper.windowClick = $A.getCallback(function(event) {
            if (component.isValid() &&
            (event.target != null &&
            event.target.id != ('picklist-input-' + component.getGlobalId()) &&
            component.get("v.listBoxVisible"))) {
                helper.closeListBox(component, event);
            }
        });
        document.addEventListener('click',helper.windowClick);
    },
})
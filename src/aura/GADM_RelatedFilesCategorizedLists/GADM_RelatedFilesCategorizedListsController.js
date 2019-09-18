/**
 * Created by ppop on 8/7/2019.
 */
({
    initializeComponent: function(component, event, helper) {

        if (component.get("v.isPopup")) {
            component.set("v.cssStyle", ".uiMenu {z-index:0} .oiHeader a.homeIcon {z-index:0} .forceIcon .slds-icon_xx-small {width: 1.5rem; height: 1.5rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 0px !important} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 0px; background-color: transparent;}");
        }
        let action = component.get('c.getFiles');
        action.setParams({
            'objectIds': component.get("v.objectIds")
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.files", response.getReturnValue());
                component.set("v.fileCategories", [...new Set(response.getReturnValue().map(x => x['category']))]);
            }
        });
        $A.enqueueAction(action);
    },
})
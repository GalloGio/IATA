/**
 * Created by ppop on 8/7/2019.
 */
({
    initializeComponent: function(component, event, helper) {
        if (component.get("v.isPopup")) {
            /*HTML hack, read the comment on cssstyle attribute*/
            component.set("v.cssStyle", ".uiMenu {z-index:0} .oiHeader a.homeIcon {z-index:0} .forceIcon .slds-icon_xx-small {width: 1.5rem; height: 1.5rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 0px !important} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 0px; background-color: transparent;}");
        }
        let action = component.get('c.getFiles');
        action.setParams({
            'objectIds': component.get("v.objectIds")
        });
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                let result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {
                    component.set("v.files", result);

                    let categories = [];

                    for(let i =0; i < result.length; i++) {
                        if(categories.indexOf(result[i].category) >= 0) {
                            //item is already in categories
                        }else{
                           categories.push(result[i].category);
                        }
                    }
                    component.set("v.fileCategories", categories);
                }

            }
        });
        $A.enqueueAction(action);
    },
})
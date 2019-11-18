({
    init : function(component, event, helper) {
        helper.handleTrackUsage(component, event);
        helper.handleGetUserInformation(component, event);
    },

    trackUsage : function(component, event, helper) {
        helper.handleTrackUsage(component, event);
    },

    activateTab : function(component, event, helper) {
        helper.handleActivateTab(component, event);
    },

})
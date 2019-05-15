({
    init : function(component, event, helper) {
        helper.handleTrackUsage(component, event);
        helper.handleGetUserInformation(component, event);
    },

    trackUsage : function(component, event, helper) {
        helper.handleTrackUsage(component, event);
    },

    getUserInformation : function(component, event, helper) {
        helper.handleGetUserInformation(component, event);
    },


})
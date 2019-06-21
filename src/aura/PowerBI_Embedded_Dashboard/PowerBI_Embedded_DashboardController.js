({
    init : function(component, event, helper) {
        let dashboard = component.get('v.dashboard');
        helper.getReportDetails(component, event, dashboard);
        helper.handleTrackUsage(component, event);
    },

    back : function(component, event, helper) {
        helper.handBack(component, event);
    },
})
({
    init : function(component, event, helper) {
        let dashboard = component.get('v.dashboard');
        helper.getReportDetails(component, event, dashboard);
        helper.applyCSS(component);
    },

    back : function(component, event, helper) {
        helper.handBack(component, event);
    },


})
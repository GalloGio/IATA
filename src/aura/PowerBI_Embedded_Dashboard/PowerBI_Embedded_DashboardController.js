({

    init : function(component, event, helper) {
        debugger;
        let dashboard = component.get('v.dashboard');
        console.log('dashboard:: ', JSON.stringify(dashboard));
        //helper.getUserDetail(component, event);
        helper.getReportDetails(component, event, dashboard);
        helper.handleTrackUsage(component, event);
    },

    back : function(component, event, helper) {
        helper.handBack(component, event);
    },
})
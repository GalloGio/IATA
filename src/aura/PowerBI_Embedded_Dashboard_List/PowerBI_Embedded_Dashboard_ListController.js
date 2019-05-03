({

    init: function(component, event) {
        let dashboards = component.get('v.dashboards');
        console.log('dashboards:: ' + JSON.stringify(dashboards));
    },

    listBack : function(component, event, helper) {
        helper.handleListBack(component, event);
    },

    backEvent : function(component, event, helper) {
        helper.handleBackEvent(component, event);
    },

    show : function(component, event, helper) {
        helper.handleShowDashboard(component, event);
    },




})
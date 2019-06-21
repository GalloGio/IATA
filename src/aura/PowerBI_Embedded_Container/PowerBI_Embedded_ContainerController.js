({
    init : function(component, event, helper) {
        helper.getAvailableDashboards(component, event);
    },

    showDashboardCategory : function(component, event, helper) {
        helper.handleShowDashboardCategory(component, event);
        let key = event.currentTarget.id;
        helper.handleTrackUsage(component, event, component.get('v.dashboardCategories')[key].key);
    },
    backEvent : function(component, event, helper) {
        helper.handleBackEvent(component, event);
    },

    hideDashboard : function(component, event) {
        component.set('v.showDashboard', false);
        component.set('v.showCategories', true);
    },

})
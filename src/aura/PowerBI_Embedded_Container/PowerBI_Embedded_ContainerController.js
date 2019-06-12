({
    init : function(component, event, helper) {
        //helper.getAccessToken(component, event);
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

    /*hideDashboardList : function(component, event) {
        component.set('v.showDashboardCategory', false);
        component.set('v.showWorkspaces', true);
    },*/








    showDashboard : function(component, event, helper) {
        helper.handleShowDashboard(component, event);
    },

    hideDashboard : function(component, event) {
        component.set('v.showDashboard', false);
        component.set('v.showWorkspaces', true);
    }


})
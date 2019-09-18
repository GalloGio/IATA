({
    init : function(component, event, helper) {
        helper.getAvailableCategories(component, event);
    },

    showCategory : function(component, event, helper) {
        helper.handleShowCategory(component, event);
        let key = event.currentTarget.id;
         console.log('>>>>');
        console.log(component.get('v.selectedDashboardCategory'));
        helper.handleTrackUsage(component, event, component.get('v.categories')[key].name);
    },

    backEvent : function(component, event, helper) {
        helper.handleBackEvent(component, event);
    },

    hideDashboard : function(component, event) {
        component.set('v.showDashboard', false);
        component.set('v.showCategories', true);
    },
})
({

    handleListBack : function(component, event) {
        let backListEvent = component.getEvent('backListEvent');
        backListEvent.fire();
    },

    handleBackEvent : function(component, event) {
        component.set('v.showDashboard', false);
        component.set('v.showDashboards', true);
    },

    handleShowDashboard : function(component, event) {
        let key = event.currentTarget.id;
        component.set('v.selectedDashboard', component.get('v.dashboards')[key]);

        component.set('v.showDashboards', false);
        component.set('v.showDashboard', true);
    },

    toggleSpinner : function(component) {
        component.set('v.showSpinner', ! component.get('v.showSpinner'));
    },


})
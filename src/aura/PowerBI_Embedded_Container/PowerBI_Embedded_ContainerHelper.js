({

    getAvailableDashboards : function(component, event) {
        this.toggleSpinner(component, event);
        let action = component.get('c.getAvailableDashboardCategoriesForUser');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const dashboardCategories = response.getReturnValue();
                if(! $A.util.isEmpty(dashboardCategories)) {

                    let dashboards = [];
                    for(let key in dashboardCategories) {
                        dashboards.push({key:key, value:dashboardCategories[key]});
                    }

                    component.set('v.dashboardCategories', dashboards);
                    this.toggleSpinner(component, event);

                }else{
                    console.log('getAvailableDashboards error');
                    this.toggleSpinner(component, event);
                    this.showToast(component, 'error', 'Unexpected error', $A.get("$Label.c.GADM_PowerBI_no_categories"));
                }

            }else{
                console.log('getAvailableDashboards error');
                this.toggleSpinner(component, event);
                this.showToast(component, 'error', 'Unexpected error', $A.get("$Label.c.GADM_PowerBI_no_categories"));

            }
        });
        $A.enqueueAction(action);
    },


    handleShowDashboardCategory : function(component, event) {
        let key = event.currentTarget.id;
        component.set('v.selectedDashboardCategory', component.get('v.dashboardCategories')[key].value);

        component.set('v.showCategories', false);
        component.set('v.showDashboardCategory', true);
    },

    handleBackEvent : function(component, event) {
        component.set('v.showDashboardCategory', false);
        component.set('v.showCategories', true);
    },


    toggleSpinner : function(component, event) {
        component.set('v.showSpinner', !component.get('v.showSpinner'));
    },


    handleTrackUsage : function(component, event, category) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action = component.get('c.checkSessionCache');
        let key = category.replace(/ /g, '');
        action.setParams({
            'userId' : userId,
            'key' : key
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var isKeyInCache = response.getReturnValue();
                if(! isKeyInCache) {
                    //key not yet present in cache - fire event
                    var trackUsageEvent = component.getEvent('serviceUsageEvent');
                    trackUsageEvent.setParams({
                        'UserId' : userId,
                        'Key' : key,
                        'Target' : key,
                        'Service' : 'GADM',
                        'Type' : 'Page'
                    });
                    trackUsageEvent.fire();
                }else{
                   //key is present in cache
                   console.log('key present in session cache');
                }
            } else {
                //unable to track usage
                console.log('handleTrackUsage error - unable to track usage');
            }
        });
        $A.enqueueAction(action);
    },


    showToast : function(component, type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },


})
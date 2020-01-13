({

    getAvailableCategories : function(component, event) {
        this.toggleSpinner(component, event);
        let action = component.get('c.getCategories');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const categoryWrappers = response.getReturnValue();
                if(! $A.util.isEmpty(categoryWrappers)) {

                    component.set('v.categories', categoryWrappers);
                    let self = this;

                    window.setTimeout(
                        $A.getCallback(function() {
                            console.log('waiting...');
                            component.set('v.showCategories', true);
                            self.toggleSpinner(component, event);
                        }), 2000
                    );

                }else{
                    console.log('getAvailableCategories - no categories found');
                    component.set('v.showCategories', true);
                    this.toggleSpinner(component, event);
                }
            }else{
                component.set('v.showCategories', true);
                this.toggleSpinner(component, event);
                this.showToast(component, 'error', 'Unexpected error', $A.get("$Label.c.GADM_PowerBI_categories_error"));

            }
        });
        $A.enqueueAction(action);
    },

    handleShowCategory : function(component, event) {
        let key = event.currentTarget.id;
        component.set('v.selectedDashboardCategory', component.get('v.categories')[key]);

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
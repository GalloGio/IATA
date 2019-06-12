({

    saveNewCacheEntry : function(component, event) {
        var userId = event.getParam('UserId');
        var target = event.getParam('Target');
        var key = event.getParam('Key');

        var action = component.get('c.saveNewCacheEntry');
        action.setParams({
            userId : userId,
            key : key
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var keySavedInCache = response.getReturnValue();
                if(keySavedInCache === true) {
                    this.saveServiceUsage(component, event);
                }else{
                    console.log('unable to save in cache');
                }
            }else{
                console.log('handleServiceUsageEvent error');
            }
        });
        $A.enqueueAction(action);
    },

    saveServiceUsage : function(component, event) {
        var userId = event.getParam('UserId');
        var target = event.getParam('Target');
        var service = event.getParam('Service');
        var type = event.getParam('Type');
        var key = event.getParam('Key');
        var action = component.get('c.saveUsageTracking');
        action.setParams({
            'userId' : userId,
            'target' : target,
            'service' : service,
            'type' : type,
            'key' : key
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS') {
                var usageTracked = response.getReturnValue();
                if(usageTracked === true) {
                    console.log('tab view tracked successfully')
                }
            }else{
                console.log('handleUsageTrackingAppEvent error');
            }
        });
        $A.enqueueAction(action);
    },


})
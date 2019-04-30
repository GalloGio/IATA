({

    handleTrackUsage : function(component, event) {
        var selectedTab = component.get('v.tabId');
        var tabName = this.getTabName(selectedTab);
        var tabNameNoSpaces = tabName.replace(/ /g, '');
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        var action = component.get('c.checkSessionCache');
        action.setParams({
            'userId' : userId,
            'key' : tabNameNoSpaces
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
                        'Key' : tabNameNoSpaces,
                        'Target' : tabName,
                        'Service' : 'GADM',
                        'Type' : 'Page'
                    });
                    trackUsageEvent.fire();
                }else{
                   //key is present in cache
                   console.log('key present in session cache');
                }
            } else {
                console.log('handleTrackUsage error');
            }
        });
        $A.enqueueAction(action);
    },


    getTabName : function(tabId) {
        var tabMap = new Map();
        tabMap.set('1', 'HOME');
        tabMap.set('2', 'DATA SUBMISSION');
        tabMap.set('3', 'DATA SUBMISSION RESULTS');
        tabMap.set('4', 'USER MANAGEMENT');
        tabMap.set('5', 'PORTAL USAGE');
        tabMap.set('6', 'DASHBOARDS');

        var result = tabMap.get(tabId);
        return tabMap.get(tabId);
    },

})
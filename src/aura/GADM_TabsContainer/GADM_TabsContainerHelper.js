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
        tabMap.set('5', 'DASHBOARDS');

        var result = tabMap.get(tabId);
        return tabMap.get(tabId);
    },

    handleGetUserInformation : function(component, event) {
        let id = $A.get('$SObjectType.CurrentUser.Id');
        let action = component.get('c.getUserGrantedRoles');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const grantedRoles = response.getReturnValue();
                if(! $A.util.isEmpty(grantedRoles)) {

                    let isDataSubmitter = false;
                    let isDataConsumer = false;
                    let isPowerUser = false;
                    let isSuperUser = false;

                    for(let i in grantedRoles) {

                        if(grantedRoles[i].Name === 'Service Power User') {
                            isPowerUser = true;
                            continue;
                        }

                         if(grantedRoles[i].Name === 'Service Super User') {
                            isSuperUser = true;
                            continue;
                        }

                        if(grantedRoles[i].Name === 'GADM Data Submitter') {
                            isDataSubmitter = true;
                            continue;
                        }

                        if(grantedRoles[i].Name === 'GADM Data Consumer') {
                            isDataConsumer = true;
                            continue;
                        }

                    }

                    if(isDataSubmitter) {
                        component.set('v.isDataSubmissionVisible', true);
                        component.set('v.isDataSubmissionResultVisible', true);
                    }

                    if(isDataConsumer) {
                        component.set('v.isDashboardsVisible', true);
                    }

                    if(isPowerUser || isSuperUser) {
                        component.set('v.isDataSubmissionResultVisible', true);
                    }

                    component.set('v.doDisplayTab', true);

                }else{
                    console.log('handleGetUserInformation error - empty user granted roles retrieved');

                }

            }else{
                console.log('handleGetUserInformation error - cannot retrieve user granted roles');

            }

        });
        $A.enqueueAction(action);
    },

    handleActivateTab : function(component, event) {
        let tab = event.getSource();
        switch(tab.get('v.id')) {

            case "1" :
                this.createNewComponent('c:Service_Notification_List', tab);
                break;

            case "2" :
                this.createNewComponent('c:File_Upload', tab);
                break;

            case "3" :
                this.createNewComponent('c:Data_Submission_List', tab);
                break;

            case "4" :
                this.createNewComponent('c:GADM_ExternalUserContactList', tab);
                break;

            case "5" :
                this.createNewComponent('c:PowerBI_Embedded_Container', tab);
                break;
        }
    },


    createNewComponent : function(name, target) {
        let self = this;
        $A.createComponent(
        name,
        {},
        function(contentComponent, status, error){
            if(status === 'SUCCESS') {
                target.set('v.body', contentComponent);
            }else if(status === 'ERROR'){
                //show error
                console.log('error:: ' + error);
                self.showMessage('error', 'Unexpected error!', 'Unable to create component!');

            }
        });
    },


    showMessage : function(type, title, message) {
        let action = $A.get('e.force:showToast');
        action.setParams({
            title: title,
            message: message,
            type: type
        });
        action.fire();
    },

})
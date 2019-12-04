({

    doInit : function(component, event, helper) {
        helper.handleInit(component, event);
    },

    back : function(component, event) {
        let myEvent = component.getEvent("Back_EVT");
        myEvent.setParams({
            'dataModified' : component.get('v.dataModified'),
            'page' : 'detail'
        });
        myEvent.fire();
    },

    save : function(component, event, helper) {
        helper.handleSave(component, event);
    },

    checkUserCount : function(component, event, helper) {
        helper.handleUserCountCheck(component, event);
    },


})
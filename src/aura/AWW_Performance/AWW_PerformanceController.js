({
    doInit : function(component, event, helper) {
        helper.initTable(component);
        helper.fetchData(component);
    },
    handleRowAction : function(component, event, helper) {
        var modalCmp = component.find('manage-record');
        var record = event.getParam('row');
        console.log(record);
        modalCmp.showModal(record);
    },  
    new : function(component, event, helper) {
        var modalCmp = component.find('manage-record');
        var record = {
            'Account__c': component.get('v.accountId'),
            'sobjectType': 'Objective__c'
        };
        modalCmp.showModal(record);
    },
    refreshTab : function(component, event, helper) {
        if(event.getParam('tabName') == 'performance_measures') {
            helper.fetchData(component);
        }
    }   
})
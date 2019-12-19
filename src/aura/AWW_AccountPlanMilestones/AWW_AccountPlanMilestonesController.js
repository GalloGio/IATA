({
    doInit : function(component, event, helper) {
        helper.initTable(component);
    },
    showMilestones : function(component, event, helper) {
        var args = event.getParam('arguments');
        component.set('v.accountPlanId', args.accountPlanId);
        component.set('v.activityName', args.activityName);
        helper.fetchData(component);
    },
    refreshTab : function(component, event, helper) {
        if(event.getParam('tabName') == 'milestones') {
            helper.fetchData(component);
        }
    },
    back : function(component, event, helper) {
        var backToActivities = component.getEvent('closeMilestones');
        backToActivities.fire();
    },
    new : function(component, event, helper) {
        var modalCmp = component.find('manage-record');
        var record = {
            'WhatId': component.get('v.accountPlanId'),
            'sObjectType': 'Task'
        };
        modalCmp.showModal(record);
    },
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action').name;
        switch (action) {
            case 'edit_milestone':
                helper.editRecord(component, event);
                break;
            case 'delete_milestone':
                helper.deleteRecord(component, event);
                break;
        }
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    }  
})
({
    doInit : function(component,event,helper) {
        helper.initTable(component);
        helper.fetchData(component);
    },
    viewCurrent : function(component,event,helper) {
        component.set('v.activityView', 'current');
        component.set('v.data', component.get('v.currentData'));
        if(component.get('v.sortBy')) {
            helper.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
        }
    },
    viewHistory : function(component,event,helper) {
        component.set('v.activityView', 'history');
        component.set('v.data', component.get('v.historyData'));
        if(component.get('v.sortBy')) {
            helper.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
        }
    },
    refreshTab : function(component,event,helper) {
        if(event.getParam('tabName') == 'account_plan') {
            helper.fetchData(component);
        }
    },
    handleRowAction : function(component,event,helper) {
        var action = event.getParam('action').name;
        switch (action) {
            case 'edit_row':
                helper.editRecord(component, event);
                break;
            case 'delete_row':
                helper.deleteRecord(component, event);
                break;
            case 'show_milestones':
                helper.showMilestones(component, event);
                break;
        }
    },
    new : function(component,event,helper) {
        helper.newRecord(component,event);
    },
    closeMilestones : function(component,event,helper) {
        component.set('v.milestoneView',false);
    },
    print : function(component,event,helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AMP_KeyAccountPlanPrintable?accountId=' +  accountId);
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    }  
})
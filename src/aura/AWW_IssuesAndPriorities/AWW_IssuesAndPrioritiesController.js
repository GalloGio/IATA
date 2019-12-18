({
    doInit : function(component, event, helper) {
        helper.initTable(component);
        helper.fetchHaveAMPIssuesAndPriorities(component);
        helper.fetchData(component);
    },
    newRecord : function(component, event, helper) {
        var modalCmp = component.find('manage-record');
        var record = {
            'Account__c': component.get('v.accountId'),
            'sobjectType': 'Objective__c'
        };
        modalCmp.showModal(record);
    },
    handleRowAction : function(component, event, helper) {
        var action = event.getParam('action').name;
        switch (action) {
            case 'edit_issue':
                helper.editRecord(component, event);
                break;
            case 'delete_issue':
                helper.deleteRecord(component, event);
                break;
        }
    },
    refreshIssues : function(component, event, helper) {
        var val = component.find('showClosed').get('v.checked');
        helper.refreshIssues(component,val);
    },
    refreshTab : function(component, event, helper) {
        if(event.getParam('tabName') == 'issues_and_priorities') {
            helper.fetchData(component);
        }
    },
    export : function(component, event, helper) {
        var accountId = component.get('v.accountId');
        var action = component.get('c.getReportId');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var path = '/'+ response.getReturnValue() +'?isdtp=p1&pv0=' + accountId + '&export=1&enc=UTF-8&xf=xls';
                window.open(path, '_blank');
            }
        });

        $A.enqueueAction(action);
    },
    printClosed : function(component, event, helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AMP_IssuesAndPriorities_Printable?accountId=' +  accountId + '&showClosed=1');
        var popup = component.find('popup-print');
        $A.util.addClass(popup, 'slds-hide');
    },
    printOpen : function(component, event, helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AMP_IssuesAndPriorities_Printable?accountId=' +  accountId);
        var popup = component.find('popup-print');
        $A.util.addClass(popup, 'slds-hide');
    },
    showPrintPopup : function(component, event, helper) {
        var popup = component.find('popup-print');
        $A.util.removeClass(popup, 'slds-hide');
    },
    hidePrintPopup : function(component, event, helper) {
        var popup = component.find('popup-print');
        $A.util.addClass(popup, 'slds-hide');
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    }
})
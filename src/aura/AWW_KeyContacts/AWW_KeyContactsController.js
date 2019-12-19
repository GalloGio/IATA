({
    init : function(component, event, helper) {
        helper.initTable(component);
        helper.loadContacts(component);
    },
    printKeyContacts : function(component, event, helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AMP_KeyContacts_Printable?isWWAccount=true&accountId=' +  accountId);
    },
    showPopUp : function(component, event, helper) {
        var popup = component.find('popup-warning');
        $A.util.removeClass(popup, 'slds-hide');
    },
    hidePopUp : function(component, event, helper) {
        var popup = component.find('popup-warning');
        $A.util.addClass(popup, 'slds-hide');
    },
    openReport : function(component, event, helper) {
        var accountId = component.get('v.accountId');
        var action = component.get('c.getReportId');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var path = '/'+ response.getReturnValue() +'?isdtp=p1&pv0=' + accountId + '&pv1=' + accountId + '&pv2=' + accountId + '&export=1&enc=UTF-8&xf=xls';
                var popup = component.find('popup-warning');
                $A.util.addClass(popup, 'slds-hide');
                window.open(path, '_blank');
            }
        });

        $A.enqueueAction(action);
    },
    search : function(component, event, helper) {
        helper.handleSearch(component);
    },
    sortContacts : function(component, event, helper) {
        if(event.target.dataset.sortable == 'false') {
            return;
        }

        var currentSortField = component.get('v.sortField');
        var sortField = event.target.title;
        var ascOrder = true;

        if(currentSortField == sortField) {
            var currentOrder = component.get('v.ascOrder');
            ascOrder = !currentOrder;
        } else {
            component.set('v.sortField', sortField);
        }     

        component.set('v.ascOrder', ascOrder);
        helper.sortRecords(component, event.target.dataset.fieldname, ascOrder);
    }
})
({
    init : function(component, event, helper) {
        helper.initTable(component);
    },
    show : function(component, event, helper) {
        helper.handleVisibility(component, 'show');
        component.set('v.selectedAction', 'add');
    },
    hide : function(component, event, helper) {
        helper.handleVisibility(component, 'hide');
        helper.resetFilters(component);
    },
    changeAction : function(component, event, helper) {
        helper.handleActionChange(component, event);
    },
    search : function(component, event, helper) {
        var validSearch = helper.validateInput(component);

        if(validSearch) {
            helper.handleSearch(component);
        }
    },
    save : function(component, event, helper) {
        helper.askConfirmation(component);
    },
    confirmation : function(component, event, helper) {
        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            helper.handleSave(component);
        }
    },
    updateSelectedRows : function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsCount', selectedRows.length);
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    }
})
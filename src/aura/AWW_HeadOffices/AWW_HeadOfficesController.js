({
    init : function(component, event, helper) {
        helper.initTable(component);
        helper.loadHeadOffices(component, helper);
    },
    showManageHierarchy : function(component, event, helper) {
        var modalCmp = component.find('manageHierarchyCmp');
        modalCmp.showModal();
    },
    refreshTab : function(component, event, helper) {
        if(event.getParam('tabName') == 'head_offices') {
            helper.loadHeadOffices(component);
            component.set('v.sortBy','');
            component.set('v.sortDirection','');
        }
    },
    handleRowAction : function(component, event, helper) {
        var modalCmp = component.find('viewHierarchyCmp');
        var topParentId = event.getParam('row').accountId;
        modalCmp.openHierarchy(topParentId);
    },
    search : function(component, event, helper) {
        helper.handleSearch(component, helper);
    },
    resetFilter : function(component, event, helper) {
        helper.handleResetFilter(component);
    }, 
    print : function(component,event,helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AWW_HeadOffices_Printable?Id=' +  accountId);
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection,helper);
    }
})
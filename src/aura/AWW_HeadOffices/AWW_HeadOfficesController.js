({
    init : function(component, event, helper) {
        helper.initTable(component);
        helper.loadHeadOffices(component);
    },
    showManageHierarchy : function(component, event, helper) {
        var modalCmp = component.find('manageHierarchyCmp');
        modalCmp.showModal();
    },
    refreshTab : function(component, event, helper) {
        if(event.getParam('tabName') == 'head_offices') {
            helper.loadHeadOffices(component);
        }
    },
    handleRowAction : function(component, event, helper) {
        var modalCmp = component.find('viewHierarchyCmp');
        var topParentId = event.getParam('row').accountId;
        modalCmp.openHierarchy(topParentId);
    },
    search : function(component, event, helper) {
        helper.handleSearch(component);
    },
    resetFilter : function(component, event, helper) {
        helper.handleResetFilter(component);
    }, 
    print : function(component,event,helper) {
        var accountId = component.get('v.accountId');
        window.open('/apex/AWW_HeadOffices_Printable?Id=' +  accountId);
    }
})
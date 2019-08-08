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
    },
    changeTableSize : function(component,event,helper) {
        component.set("v.totalPages", Math.ceil(component.get('v.data').length/component.get("v.pageSize")));
        component.set("v.currentPageNumber",1);
        helper.buildData(component);
    },

    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component);
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component);
    }
})
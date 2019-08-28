({
    doInit : function(component,event,helper) {
        helper.initTable(component);
        helper.fetchData(component);
    },
    handleRowAction : function(component,event,helper) {
        var action = event.getParam('action').name;
        switch (action) {
            case 'remove_record':
                helper.deleteRecord(component, event);
                break;
            case 'edit_record':
                helper.editRecord(component, event);
                break;
        }
    },
    refreshTab : function(component,event,helper) {
        if(event.getParam('tabName') == 'ownership') {
            helper.fetchData(component);
        }
    },
    add : function(component,event,helper) {
        var modal = component.find('owners-edit');
        modal.showModal('Subsidiary','Add',{});
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
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
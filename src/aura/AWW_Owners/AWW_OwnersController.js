({
    doInit : function(component,event,helper) {
        helper.initTable(component);
        helper.fetchData(component);
    },
    doRefresh: function(component,event,helper) {
        helper.initTable(component);
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
        modal.showModal('Owner','Add',{});
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    }
})
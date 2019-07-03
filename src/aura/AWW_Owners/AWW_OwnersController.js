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
        modal.showModal('Owner','Add',{});
    }
})
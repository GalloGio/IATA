({
    handleModalVisibility : function(component, event, helper) {
        var args = event.getParam('arguments');
        
        if(args && args.recordId) {
            component.set('v.recordId', args.recordId);
            helper.showModal(component);
        } else {
            helper.hideModal(component);
        }
    }, 
    delete : function(component, event, helper) {
        var record = {
            sObjectType : 'Task',
            Id : component.get('v.recordId')
        };

        helper.handleDelete(component, record);
    }
})
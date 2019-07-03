({
    doInit : function(component, event, helper) {
        helper.initPicklists(component);
        component.set('v.errorMessage', null);
    },
    handleModalVisibility : function(component, event, helper) {
        var args = event.getParam('arguments');
        
        if(args && args.record) {
            helper.showModal(component, args.record);
        } else {
            helper.hideModal(component);
        }
    },
    save : function(component, event, helper) {
        if(helper.handleValidations(component)) {
            helper.askConfirmation(component);
        }
    },
    confirmation : function(component, event, helper) {
        if(event.getParam('action') != 'performance_edit') {
            return;
        }

        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            helper.handleSave(component);
        }
    }
})
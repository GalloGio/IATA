({
    doInit : function(component, event, helper) {
        helper.loadDropdowns(component);
    },
    handleModalVisibility : function(component, event, helper) {
        var args = event.getParam('arguments');
        component.set('v.errorMessage', null);
        if(args && args.record) {
            helper.showModal(component, args.record);
        } else {
            helper.hideModal(component);
        }
    },
    save : function(component,event,helper) {
        if(helper.handleValidations(component)) {
            helper.askConfirmation(component);
        }
    },
    confirmation : function(component, event, helper) {
        if(event.getParam('action') != 'milestone_edit') {
            return;
        }
        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            component.set('v.errorMessage', null);
            helper.handleSave(component);
        }
    }
})
({
    doInit : function(component, event, helper) {
        helper.initPicklists(component);
    },
    handleModalVisibility : function(component, event, helper) {
        var args = event.getParam('arguments');
        
        if(args && args.record) {
            helper.showModal(component, args.record);
            component.set('v.renderLookup',false);
            component.set('v.renderLookup',true);
        } else {
            helper.hideModal(component);
        }
    },
    handleAccountIssueIdUpdate : function(component, event, helper) {
        var record = component.get('v.record');
        record.issueId = event.getParam('sObjectId');
        component.set('v.record', record);
    },
    handleAccountIssueIdClear : function(component, event, helper) {
        var record = component.get('v.record');
        record.issueId = null;
        component.set('v.record', record);
    },
    save : function(component,event,helper) {
        if(helper.handleValidations(component)) {
            helper.askConfirmation(component);
        }
    }, 
    confirmation : function(component,event,helper) {
        if(event.getParam('action') != 'account_plan_edit') {
            return;
        }
        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            component.set('v.errorMessage', null);
            helper.handleSave(component);
        }
    }
})
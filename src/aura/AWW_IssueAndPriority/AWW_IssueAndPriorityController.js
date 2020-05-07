({
    doInit : function(component, event, helper) {
        helper.loadDropdowns(component);
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
    save : function(component,event,helper) {
        var nameCmp = component.find('recordName');
        var descriptionCmp = component.find('recordDescription');
        
        if(nameCmp.reportValidity() && descriptionCmp.reportValidity()) {
            helper.askConfirmation(component);
        }
    },
    confirmation : function(component, event, helper) {
        if(event.getParam('action') != 'issue_priority_edit') {
            return;
        }
        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            component.set('v.errorMessage', null);      
            helper.handleSave(component);            
        }
    },  
    cleanCheckboxes : function(component, event, helper) {
        var cbs = component.find("amCheckbox");
        var checkCmp1 = event.getSource();
        for (var i = 0; i < cbs.length; i++) {
            cbs[i].set("v.checked", false);
        }
        checkCmp1.set("v.checked", true);
    }
})
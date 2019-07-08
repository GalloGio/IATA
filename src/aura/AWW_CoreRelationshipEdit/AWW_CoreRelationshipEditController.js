({
    changeTab : function(component, event, helper) {
        helper.handleTabChange(component, event);
    },
    handleModalVisibility : function(component, event, helper) {
        var args = event.getParam('arguments');
        
        if(args && args.record) {
            helper.showModal(component);
            helper.initRecord(component, args.record);
        } else {
            helper.hideModal(component);
        }
    },
    save : function(component,event,helper) {
        helper.askConfirmation(component);
    },
    confirmation : function(component, event, helper) {
        if(event.getParam('action') != 'core_relations_edit') {
            return;
        }
        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            var sfRecord = helper.convertToSFRecord(component);
            helper.handleSave(component,sfRecord);
        }
    },
    checkboxPaxSelect : function(component, event, helper) {
        var value = event.getSource().get('v.name');
        var checked = event.getSource().get('v.checked');
        var record = component.get('v.record');
        var res;

        if(checked) {
            res = helper.handleCheck(record.External_Entities_PAX__c,value);
        } else {
            res = helper.handleUncheck(record.External_Entities_PAX__c,value);
        }

        record.External_Entities_PAX__c = res;
        component.set('v.record', record);
    },    
    checkboxCargoSelect : function(component, event, helper) {
        var value = event.getSource().get('v.name');
        var checked = event.getSource().get('v.checked');
        var record = component.get('v.record');
        var res;

        if(checked) {
            res = helper.handleCheck(record.External_Entities_CARGO__c,value);
        } else {
            res = helper.handleUncheck(record.External_Entities_CARGO__c,value);
        }

        record.External_Entities_CARGO__c = res;
        component.set('v.record', record);
    }
})
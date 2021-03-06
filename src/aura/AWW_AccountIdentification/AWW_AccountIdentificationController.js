({
    doInit : function(component, event, helper) {
        helper.getAccount(component);
        helper.getCanEditOtherTypeofSubsidiaries(component);
        helper.getHaveAMPAgencyManagement(component);
    },
    otherTypeofSubsidiariesOnclick : function(component) {
        component.set('v.otherTypeofSubsidiariesOldValue',component.get('v.record').Other_Type_of_Subsidiaries__c);
        component.set('v.otherTypeofSubsidiariesToEdit',true);
    },
    otherTypeofSubsidiariesCancel : function(component, event) {
        setTimeout(
            $A.getCallback(function() {
                if(component.get('v.canCancel')){
                    var myRecord = component.get('v.record');
                    myRecord.Other_Type_of_Subsidiaries__c = component.get('v.otherTypeofSubsidiariesOldValue');
                    var myRecord = component.set('v.record',myRecord);
                    component.set('v.otherTypeofSubsidiariesToEdit',false);
                }
            }), 500
        );
    },
    otherTypeofSubsidiariesSave : function(component, event, helper) {
        component.set('v.canCancel',false);
        var spinner = component.find('app-spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        helper.saveOtherTypeofSubsidiaries(component);
    }
})
({
    doInit : function(component, event, helper) {
        helper.getAccount(component);
    },
    backToClassic : function(component, event, helper) {
        window.location.href = '/' + component.get('v.accountId');
    }
})
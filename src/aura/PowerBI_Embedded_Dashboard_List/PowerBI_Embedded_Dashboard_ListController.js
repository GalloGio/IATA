({

    init: function(component, event) {
        console.log(component.get("v.category"));
    },

    listBack : function(component, event, helper) {
        helper.handleListBack(component, event);
    },

    backEvent : function(component, event, helper) {
        helper.handleBackEvent(component, event);
    },

    show : function(component, event, helper) {
        helper.handleShowDashboard(component, event);
    },
    showDocuments : function(component, event, helper) {
            helper.handleShowDocuments(component, event);
     },
})
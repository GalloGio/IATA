({
    doInit: function(component) {
    },
    
    closeModal: function(component) {
        $A.get("e.force:closeQuickAction").fire();
    }
});
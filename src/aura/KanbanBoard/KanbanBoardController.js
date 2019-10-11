({
    doInit: function(component, event, helper) {
        var action = component.get("c.getKanbanWrap");
        action.setParams({
            "objName":component.get("v.objName"),
            "objFields":component.get("v.objFields"),
            "kanbanField":component.get("v.kanbanPicklistField"),
            "kanbanColumns":component.get("v.kanbanColumns"),
            "searchText":component.get("v.searchText")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.dir(response.getReturnValue());
                component.set("v.kanbanData", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    doView: function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:navigateToSObject");
        editRecordEvent.setParams({
            "recordId": event.target.id
        });
        editRecordEvent.fire();
    },
    allowDrop: function(component, event, helper) {
        event.preventDefault();
    },
    
    drag: function (component, event, helper) {

        event.dataTransfer.setData("text", event.target.id);
    },
    
    drop: function (component, event, helper) {
        event.preventDefault();
        var data = event.dataTransfer.getData("text");
        var tar = event.target;
        while(tar.tagName != 'ul' && tar.tagName != 'UL')
            tar = tar.parentElement;
        tar.appendChild(document.getElementById(data));
        document.getElementById(data).style.backgroundColor = "#97c6ed";
        helper.updatePickVal(component,data,component.get("v.kanbanPicklistField"),tar.getAttribute('data-Pick-Val'));
    },
    
    handleSearchClick: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },

    closeMessage: function (component, event, helper) {
        component.set("v.message", '');
        $A.get('e.force:refreshView').fire();
    }
})
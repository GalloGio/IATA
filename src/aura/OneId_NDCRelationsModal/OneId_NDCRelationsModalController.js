({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Airline Name', fieldName: 'AirlineName', type: 'text', editable: false, typeAttributes: { required: true }}
        ]);
        helper.init(component);
    },
    
    updateSelectedRows : function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsList', selectedRows);
    },
    
    handleCreateRelation : function(component, event, helper) {
        var selectedRows = component.get('v.selectedRowsList');
        var toastEvent = $A.get("e.force:showToast");
        
        if(selectedRows.length === 0) {
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "No airlines selected."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.createRelations');
            action.setParams({
                "airlines" : JSON.stringify(selectedRows)
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var toastEventCallback = $A.get("e.force:showToast");
                if(state === 'SUCCESS' && component.isValid()){
                    toastEventCallback.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Related airlines successfully added."
                    });
                    toastEventCallback.fire();
                    component.find('overlayLib').notifyClose();
                } else {
                    toastEventCallback.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Error during creation."
                    });
                    toastEventCallback.fire();
                    
                }
            });
            $A.enqueueAction(action);
        }
    }
    
})
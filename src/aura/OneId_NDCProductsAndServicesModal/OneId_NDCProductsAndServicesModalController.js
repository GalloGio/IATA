({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Product Or Service Name', fieldName: 'ProdName', type: 'text', editable: false, typeAttributes: { required: true }}
        ]);
        helper.getUnaddedProducts(component);
    },
    
    updateSelectedRows : function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsList', selectedRows);
    },
    
    handleAddProduct : function(component, event, helper) {
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
            var action = component.get('c.createProducts');
            action.setParams({
                "products" : JSON.stringify(selectedRows)
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                var toastEventCallback = $A.get("e.force:showToast");
                if(state === 'SUCCESS' && component.isValid()){
                    toastEventCallback.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Products and services successfully added."
                    });
                    toastEventCallback.fire();
                    component.find('overlayLib').notifyClose();
                } else {
                    toastEventCallback.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Error during adding."
                    });
                    toastEventCallback.fire();
                    
                }
            });
            $A.enqueueAction(action);
        }
    }
    
})
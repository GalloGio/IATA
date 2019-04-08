({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Product Or Service Name', fieldName: 'ProdName', type: 'text', editable: false, typeAttributes: { required: true }}
        ]);
        helper.getProducts(component);
    },
    
    updateSelectedRows : function(component, event) {
        var selectedRows = event.getParam('selectedRows');
        component.set('v.selectedRowsList', selectedRows);
    },
    
    deleteSelectedRecords : function(component, event, helper) {
        var selectedRows = component.get('v.selectedRowsList');
        var toastEvent = $A.get("e.force:showToast");
        
        if(selectedRows.length === 0) {
            toastEvent.setParams({
                "title": "Error!",
                "type": "error",
                "message": "No products or services selected."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.deleteProducts');
            action.setParams({
                "products" : JSON.stringify(selectedRows)
            });
            action.setCallback(this, function(response){
                var toastEventCallback = $A.get("e.force:showToast");
                var state = response.getState();
                if(state === 'SUCCESS' && component.isValid()){
                    toastEventCallback.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Related products and services successfully deleted."
                    });
                    component.set('v.loaded', false);
                    helper.getProducts(component);
                }else{
                    toastEventCallback.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Error during deletion."
                    });                    
                }
                toastEventCallback.fire();
            });
            $A.enqueueAction(action);
        }
        
    },
    
    handleShowProductModal : function(component, event, helper) {
        var modalBody;
        $A.createComponent("c:OneId_NDCProductsAndServicesModal", {},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       body: modalBody, 
                       showCloseButton: true,
                       closeCallback: function() {
                           component.set('v.loaded', false);
                           helper.getProducts(component);
                       }
                   })
               }                               
           });
    }
    
})
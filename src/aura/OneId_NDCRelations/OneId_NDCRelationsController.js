({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Company Name', fieldName: 'AirlineName', type: 'text', editable: false, typeAttributes: { required: true }}
        ]);
        helper.getUserInfo(component);
        helper.init(component);
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
                "message": "No airlines selected."
            });
            toastEvent.fire();
        } else {
            var action = component.get('c.deleteRelations');
            action.setParams({
                "relations" : JSON.stringify(selectedRows)
            });
            action.setCallback(this, function(response){
                var toastEventCallback = $A.get("e.force:showToast");
                var state = response.getState();
                if(state === 'SUCCESS' && component.isValid()){
                    toastEventCallback.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Related airlines successfully deleted."
                    });
                    component.set('v.loaded', false);
                    helper.init(component);
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
    
    handleShowModal : function(component, event, helper) {
        var modalBody;
        $A.createComponent("c:OneId_NDCRelationsModal", {},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       body: modalBody, 
                       showCloseButton: true,
                       closeCallback: function() {
                           component.set('v.loaded', false);
                           helper.init(component);
                       }
                   })
               }                               
           });
    }
    
})
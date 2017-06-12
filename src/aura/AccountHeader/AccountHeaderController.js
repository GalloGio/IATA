({
    doInit: function(component, event, helper) {
        var canEdit = component.get("c.getCanEdit");        
        canEdit.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var vals = response.getReturnValue()
                component.set("v.canEdit", vals[0]);
                component.set("v.canEdit2", vals[1]);
            }
            else {
                alert("You have no Access to Sanctions");
            }
                });
        $A.enqueueAction(canEdit);
    },
    
    switchToEditMode: function(component, event, helper) {
        var editID = event.target.id
        var account = component.get("v.account");
        component.set("v.SanctionNotice2", account.SanctionNotice2__c);
        if(editID=='edit2'){
            component.set("v.isEditMode2", true);
        }
    },
    
    cancelEditMode : function(component, event, helper) {
    var  cancelID = event.target.id;
        if(cancelID=='cancel2'){
            component.set("v.account.SanctionNotice2__c",component.get("v.SanctionNotice2"));            
            component.set("v.isEditMode2", false);
        }
    },
    
    save : function(component, event, helper) {
    var  saveID = event.target.id;
        if(saveID=='save2'){
            var save = component.get("c.saveRecord");
            save.setParams({
                 "recordDetail": component.get("v.account")
            });
            $A.enqueueAction(save);
            component.set("v.isEditMode2", false);
        }
    },
})
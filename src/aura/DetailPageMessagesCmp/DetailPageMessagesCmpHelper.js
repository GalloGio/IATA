({
	getMessages : function(component) {
		var vrecordId = component.get("v.recordId");
        var vobjectName;
        if(vrecordId) {
            vobjectName = component.get("v.sObjectName");
        } else {
            vrecordId = component.get("v.paramRecordId");
            vobjectName = component.get("v.paramObjectName");
        }
        
        var action = component.get("c.getMessages");
        action.setParams({
            recordId : vrecordId,
            objectName : vobjectName
        });
        
        action.setCallback(this, function(r) {
            var state = r.getState();
            if(component.isValid() && state == 'SUCCESS') {
                console.log(r.getReturnValue());
            	component.set("v.messages", r.getReturnValue());    
            }
        });
        
        $A.enqueueAction(action);
	}
})
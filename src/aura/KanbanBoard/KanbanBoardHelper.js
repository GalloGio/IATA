({
	updatePickVal : function(component, recId, pField, pVal) {
		var action = component.get("c.getUpdateStage");
        action.setParams({
            "recId":recId,
            "kanbanField":pField,
            "kanbanNewValue":pVal
        });

        action.setCallback(this, function(response){
            var state = response.getState();

            if (state === "SUCCESS") {

                console.log(response.getReturnValue());
                document.getElementById(recId).style.backgroundColor = "#b2ed97";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 300);
                component.set("v.type", 'success');
                component.set("v.message", 'Updated Successfully!');
                $A.get('e.force:refreshView').fire();

            } else if (state === "ERROR") {

                console.log(response.getError());
                document.getElementById(recId).style.backgroundColor = "#ed9997";
                setTimeout(function(){ document.getElementById(recId).style.backgroundColor = ""; }, 300);
                component.set("v.type", 'error');
                component.set("v.message", 'You encountered some errors when trying to save this record. There\'s a problem saving this record. You might not have permission to edit it, or it might have been deleted or archived. Contact your administrator for help.');
                $A.get('e.force:refreshView').fire();
            }

        });
        $A.enqueueAction(action);
	}
})
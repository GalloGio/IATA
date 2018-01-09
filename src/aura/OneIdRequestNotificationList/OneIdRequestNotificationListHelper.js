({
	getUserApps : function(component) {
		var action = component.get("c.getUserApps");
		
		action.setCallback(this, function(response){
			var state = response.getState();
			
			if(state ==="SUCCESS"){
				console.log("SUCCESS");
				console.log(JSON.stringify(response.getReturnValue()));
				component.set('v.requestlist',response.getReturnValue());
				console.log(component.get('v.requestlist'));
			} 
			else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
		});

		$A.enqueueAction(action);
	},
})
({
	
	fetchDivisionValues: function(component, currentDivision){
		var action = component.get("c.getDivisionValues");
		var divOpts = [];
		
		action.setCallback(this, function(response){
			if(response.getState() == "SUCCESS"){
				var allValues = response.getReturnValue();

				if(allValues != undefined && allValues.length > 0){
					divOpts.push({
						label: "--None--",
						value: ""
					});
									
				}

				for(var i = 0; i < allValues.length; ++i){

					console.log(allValues[i]);

					if(allValues[i] == currentDivision){
						divOpts.push({
						label: allValues[i],
						value: allValues[i],
						selected: "true"
					});

					}

					divOpts.push({
						label: allValues[i],
						value: allValues[i]
					});
				}

				component.find("divisionList").set("v.options", divOpts);
			}
		});
		$A.enqueueAction(action);
	},
})
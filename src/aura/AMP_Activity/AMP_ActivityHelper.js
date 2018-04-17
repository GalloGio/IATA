({
	
	fillDivisionOptions: function(component, allValues, currentDivision){
		var divOpts = [];

		if(allValues != undefined && allValues.length > 0){
			divOpts.push({
				label: "--None--",
				value: ""
			});
		}

		for(var i = 0; i < allValues.length; ++i){

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
})
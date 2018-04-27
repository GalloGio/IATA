({

	fillDivisionOptions: function(component, decisionValues, currentDivision){
		var divOpts = [];

		if(decisionValues != undefined && decisionValues.length > 0){
			divOpts.push({
				label: "--None--",
				value: ""
			});
		}

		for(var i = 0; i < decisionValues.length; ++i){

			if(decisionValues[i] == currentDivision){
				divOpts.push({
				label: decisionValues[i],
				value: decisionValues[i],
				selected: "true"
			});

			}else{

				divOpts.push({
					label: decisionValues[i],
					value: decisionValues[i]
				});
			}
		}

		component.find("divisionList").set("v.options", divOpts);
	}

})
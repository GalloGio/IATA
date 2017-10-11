({
	getAppTerms : function(component) {
		var action = component.get("c.getAppTerms");

		var appname = component.get("v.appname");
		
		action.setParams({selectedapp : appname});

		action.setCallback(this, function(a) {
			var results = a.getReturnValue();
			if(results[0] == 'None Found'){
				results[0] = '';
				results[1] = $A.get("$Label.c.OneId_NoTermsFound");
				component.set("v.appinfo", results);
			}else{
				component.set("v.appinfo", results);
			}
			console.log(results[0]);
			console.log(component.get("v.appinfo"));
		});
    	$A.enqueueAction(action);
	},
	getUrlParameter : function(component) {
		console.log("param");
		var pageUrl = decodeURIComponent(window.location.search.substring(1));
		var URLVariables = pageUrl.split('&');
		var parameterName;

		for(var i= 0; i<URLVariables.length;i++){
			parameterName = URLVariables[i].split('=');

			if(parameterName[0]=="app"){
				component.set('v.appname',parameterName[1]);
			}
		}
	}
})
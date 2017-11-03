({
	getCanView : function(component) {
		var action;
        action = component.get("c.canViewSalesfigures");
        //Set up the callback
        var self = this;
        action.setCallback(this, function(actionResult) {
            // console.log(JSON.stringify(actionResult.getReturnValue()));
            component.set("v.canRead", actionResult.getReturnValue());
        });
        $A.enqueueAction(action);
	},
	getServices : function(component) {
		var action = component.get("c.getAccountServices");
		var accountId = component.get("v.accountId");

		action.setParams({
				"accountId": accountId
			});
			action.setCallback(this, function(a) {
				 var services = a.getReturnValue();
				 var state = a.getState();

				 if (component.isValid() && state === "SUCCESS") {
					var serviceWrappers = new Array();
					for(var i = 0; i < services.length; i++) {
						var rowspan = 1;
						if(i+1 < services.length) {
							for(var j=i+1; j < services.length; j++) {
								if(services[i].Service__r.Service_Publication__c == services[j].Service__r.Service_Publication__c) {
									rowspan++;
								}
							}
						}

						if(i>0 && services[i].Service__r.Service_Publication__c == services[i-1].Service__r.Service_Publication__c) {
							rowspan = 0;
						}
						var sWrapper = {
							rowspan : rowspan,
							Service_Publication : services[i].Service__r.Service_Publication__c,
							Id : services[i].Service__c,
							Name : services[i].Service__r.Name,
							Active : services[i].Active__c
						};

						serviceWrappers.push(sWrapper);
					}
					console.log(JSON.stringify(serviceWrappers));
					component.set("v.AccountServicesWrapper", serviceWrappers);
				 }
				 else if (state === "ERROR") {}
			});
			$A.enqueueAction(action);
	}
})
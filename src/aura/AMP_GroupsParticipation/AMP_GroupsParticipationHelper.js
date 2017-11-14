({
	getReportId : function(component, event) {
		var action = component.get("c.getReportId");
		// var accountId = component.get("v.accountId");


		// action.setParams({
		// 		"accountId": accountId
		// 	});
			action.setCallback(this, function(a) {
				var reportId = a.getReturnValue();

				var state = a.getState();
				//  var ParticipantWrappers = new Array();
				if (component.isValid() && state === "SUCCESS") {
					 component.set("v.reportId", reportId);

				}
				else if (state === "ERROR") {}
			});
			$A.enqueueAction(action);
	}
})

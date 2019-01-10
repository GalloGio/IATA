({
	getInterestsList : function(cmp) {
		// Retrieve interest list from custom settings
		var action = cmp.get("c.getInterestList");
		console.log(_userInfo.getUserInfo());
		action.setParams({
			"individualId" : _userInfo.getUserInfo().individualId
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result != null) {
				console.log(result);
				cmp.set("v.interests",result );
            } else {
				console.log("error");
			}
        });
		$A.enqueueAction(action);
	},

	saveInterests : function(cmp, pardotID, individualId, userChoice) {
		// Retrieve subscritpion list from custom settings
		var action = cmp.get("c.updateInterest");
		action.setParams({
			"prospectID":  pardotID,
			"email":  _userInfo.getUserInfo().email,
			"interests" : userChoice,
			"individualId" : individualId,
        });
        //updateInterest(String prospectID, list<String> interests) {
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            if(result != null) {
					this.showToast("success", "Success","Information updated");
            } else {
					this.showToast("error", "Error", "An error occurs");
			}
        });
		$A.enqueueAction(action);
	},

	showToast : function(type, title, msg) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": type,
			"title": title,
			"message": msg
		});
		toastEvent.fire();
	}
})
({
	retrieveUserInfo : function(cmp) {
		
		// Create lead + individual
		var isGuest = true;
		var userInfo = _userInfo.getUserInfo();

		if(userInfo.individualId == undefined || userInfo.individualId == '') {
			// Logged in user
			isGuest = false;
		}
		_userInfo.setIsGuest(isGuest);
		
		var action = cmp.get("c.retrieveUserInfo");
        action.setParams({
			"individualId":  userInfo.individualId,
			"isGuest" : isGuest
        });

        action.setCallback(this, function(a) {
			var result = a.getReturnValue();
            if(result != null) {
				var userInfoObj = JSON.parse(result);

				// Set all global variable to be used by all components
				if(userInfoObj != undefined && userInfoObj.individual != null) {
					_userInfo.setEmail(userInfoObj.individual.Email__c);
					_userInfo.setIndividualID(userInfoObj.individual.Id);
					_userInfo.setIndividualObj(userInfoObj.individual);
					_userInfo.setPardotID(userInfoObj.prospectId);
					_userInfo.setSubscriptions(userInfoObj.subscriptions);
					_userInfo.setSalesforceId(userInfoObj.salesforceId);
					//_userInfo.setInterests(userInfoObj.prospectId);
				}
            } else {
				console.log("GDPR Helper error: Problem while trying to load user info");
			}
			console.log("USER INFO:");
			console.log(_userInfo.getUserInfo());
        });
		$A.enqueueAction(action);
	},
})
({
	doInit : function(cmp, evt, hlp) {
		//Check if we are in are registrered user context or in guest
		var sPageURL = decodeURIComponent(window.location.pathname.substring(1));
		if (sPageURL.indexOf('guest') !== -1) { //guest context
            cmp.set("v.isGuest", true);
		}
	},

	logout : function(cmp, evt, hlp) {
		if(cmp.get("v.isGuest")) {
			// For guest: kill validation of the token by removing in individual record the token of validity date time
			var action = cmp.get("c.killToken");
			action.setParams({
				"individualId" : _userInfo.getUserInfo().individualId
			});
			action.setCallback(this, function(a) {
					var result = a.getReturnValue();
				if(result) {
					// Redirec to IATA.org
					window.location.replace("https://www.iata.org/pages/default.aspx");
				} else {
					console.log("error");
				}
			});
			$A.enqueueAction(action);
		} else {
			// For registered user = redirect to OneIdendtity home page
			window.location.replace("https://www.iata.org/pages/default.aspx");
		}
	}
})
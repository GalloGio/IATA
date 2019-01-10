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

            // Kill token 
            var action = cmp.get("c.killToken");
            action.setParams({
                "individualId":"0PK0D000000Pc5S" //TODO Dynamic
            });
    
            action.setCallback(this, function(resp) {
                var result = resp.getReturnValue();
              
                if(result){
					// If operation success
					window.location.replace("https://www.iata.org/pages/default.aspx");
                } else {
					console.log("error");
					window.location.replace("https://www.iata.org/pages/default.aspx");
				}
            });
			$A.enqueueAction(action); 
		} else {
			// For registered user =Y redirect to OneIdendtity home page
			window.location.replace("https://www.iata.org/pages/default.aspx");
		}
	}
})
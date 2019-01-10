({
	doInit : function(cmp, evt, hlp) {

		var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
		var sParameterName;
        var i;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 
            if (sParameterName[0] == 'indId') { 
				sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
				cmp.set("v.iid", sParameterName[1]);
            }
		}
		hlp.getPickListValues(cmp);
		hlp.retrieveUserInfo(cmp);
		cmp.set("v.prospect", {});
	},

	save: function(cmp, evt, hlp) {
		hlp.saveUserInfo(cmp);
	},

	initGDPR : function(cmp, evt, hlp) {
		/*
		_userInfo.setPardotID('56308118');
		_userInfo.setEmail('iata.fred.dev+1@gmail.com');
		*/
	}

	
})
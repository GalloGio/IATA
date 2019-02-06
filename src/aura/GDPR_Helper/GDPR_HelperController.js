({
	initGDPR : function(cmp, evt, hlp) {
		// Extract information from URL
		var sPageURL = decodeURIComponent(window.location.search.substring(1));
        var sURLVariables = sPageURL.split('&');
		var sParameterName;

        for (var i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 
            if (sParameterName[0] == 'indId') { 
				sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
				_userInfo.setIndividualID(sParameterName[1]);
            }
		}
		hlp.retrieveUserInfo(cmp, evt);
	}
})
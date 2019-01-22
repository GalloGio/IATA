({
	doInit : function(cmp, evt, hlp) {
		hlp.getPickListValues(cmp);
		hlp.retrieveUserInfo(cmp);
		cmp.set("v.prospect", {});
	},

	save: function(cmp, evt, hlp) {
		hlp.saveUserInfo(cmp);
	},
})
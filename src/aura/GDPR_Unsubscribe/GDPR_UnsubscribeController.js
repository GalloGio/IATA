({
	doInit : function(cmp, evt, hlp) {
		cmp.set("v.opted_out", cmp.get("v.unsubscribe"));
	},

	changeUnsubscribe : function(cmp, evt, hlp) {
		cmp.set("v.localLoading", true);
		hlp.subscribe(cmp);
	},

	handleEVT_GDPR_OptOutSync : function(cmp, evt, hlp) {
		cmp.set("v.opted_out", evt.getParam("optout"));
		cmp.set("v.unsubscribe", evt.getParam("optout"));
	},

})
({
	doInit: function(component, event, helper) {
		helper.isIATAMember(component);
		helper.getCanView(component);
		helper.getServices(component);
		helper.getIndustryActivities(component);
    },
})
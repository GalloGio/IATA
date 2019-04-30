({
    init : function(component, event, helper) {
        helper.handleTrackUsage(component, event);
    },

	handleApplicationEvent  : function(cmp, event) {
        var tabIndexReceived = event.getParam("activeTabId");
        cmp.set("v.tabId", tabIndexReceived);
        cmp.set("v.doDisplayTab", true);
        cmp.find("tabs").set("v.selectedTabId", tabIndexReceived);
    },

    trackUsage : function(component, event, helper) {
        helper.handleTrackUsage(component, event);
    },


})
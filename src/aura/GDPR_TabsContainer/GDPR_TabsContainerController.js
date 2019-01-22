({
	handleApplicationEvent  : function(cmp, event) {
                var tabIndexReceived = event.getParam("activeTabId");
                cmp.set("v.tabId", tabIndexReceived);
                cmp.set("v.doDisplayTab", true);
                cmp.find("tabs").set("v.selectedTabId", tabIndexReceived);
        }
})
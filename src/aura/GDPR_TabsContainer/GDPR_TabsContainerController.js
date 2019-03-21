({
	handleApplicationEvent  : function(cmp, event) {
                var tabIndexReceived = event.getParam("activeTabId");
                cmp.set("v.tabId", tabIndexReceived);
                cmp.set("v.doDisplayTab", true);
                cmp.find("tabs").set("v.selectedTabId", tabIndexReceived);

                // Change request: Display data provacy management tab only for regstred user
                cmp.set("v.isRegisteredUser", ! _userInfo.getUserInfo().isGuest);
        }
})
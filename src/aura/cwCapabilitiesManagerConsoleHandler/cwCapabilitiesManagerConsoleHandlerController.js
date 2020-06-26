({
    handleCloseEvent : function(component, event) {
        
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
            $A.get('e.force:refreshView').fire();
        })
        .catch(function(error) {
            console.log(error);
        });
        
    }
})
({
    getAllTabInfo: function(component) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getAllTabInfo().then(function(response) {
            var tabs = [];
            response.forEach(element => {
                tabs.push({'tabId' : element.tabId,
                           'tabName' : element.title});
            });
            component.set("v.tabsList", tabs);
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    dispatchTabs: function(workspaceAPI, tabs) {
        return tabs.map(tab => {
            if (tab.closeable) {
                return this.closeTab(workspaceAPI, tab.tabId);
            }
        });
    },
  
    closeTab: function(workspaceAPI, tabId) {
        return workspaceAPI.closeTab({tabId}).catch(()=>false);
    },
  
    focusTab: function(workspaceAPI, tabId) {
        return workspaceAPI.focusTab({tabId}).catch(()=>false);
    },
  
    refreshTab: function(workspaceAPI, tabId) {
        return workspaceAPI.refreshTab({tabId}).catch(()=>false);
    },
  
  })
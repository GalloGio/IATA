({

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
({
    doInit : function(component, event, helper) {
        var columns = [
            {label: $A.get("{!$Label.c.Tab_Name"), fieldName: 'tabName', type: 'text'},
            {label: $A.get("{!$Label.c.ISSP_AMC_CLOSE}"), type: 'button-icon', typeAttributes: { iconName: 'utility:close', variant: 'bare', name: 'delete_tab', title: $A.get("{!$Label.c.Tab_Close}")}, cellAttributes: { alignment: "center"}},
        ];
        component.set('v.columns', columns)
        helper.getAllTabInfo(component);
    },

    closeTabs: function (component, event, helper) {
        const workspaceAPI = component.find("workspace");
  
        // these return promises, so we can concurrently run them in promise.all
        const isConsoleNavPromise = workspaceAPI.isConsoleNavigation();
        const allTabPromise = workspaceAPI.getAllTabInfo();
  
  
        // execute isConsoleNavPromise and allTabPromise, no need for them to be syncronous
        Promise.all([isConsoleNavPromise, allTabPromise]).then((values) => {
    
            const isConsole = values[0];
            if (!isConsole) return; // early return if not in console.
    
            const allTabs = values[1]; // tabs
            // now go through and close all tabs, return all tabs again for focus and refresh steps.
            return Promise.all(helper.dispatchTabs(workspaceAPI, allTabs)).then(() => allTabs);
    
        }).then((tabs) => {
            if(tabs.length > 0){
                const firstTabId = tabs[0].tabId;
                // focus and refresh. Let any Catch Bubble up.
                Promise.all([helper.focusTab(workspaceAPI, firstTabId), helper.refreshTab(workspaceAPI, firstTabId)]);
            }
            helper.getAllTabInfo(component);
        });
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var workspaceAPI = component.find("workspace");
        var tabId = row.tabId;
        if (action.name == 'delete_tab') {
            // these return promises, so we can concurrently run them in promise.all
            const isConsoleNavPromise = workspaceAPI.isConsoleNavigation();
            const allTabPromise = workspaceAPI.getAllTabInfo();

            Promise.all([isConsoleNavPromise, allTabPromise]).then((values) => {
    
                const isConsole = values[0];
                if (!isConsole) return; // early return if not in console.
                // now go through and close all tabs, return all tabs again for focus and refresh steps.
                return helper.closeTab(workspaceAPI, tabId);
        
            }).then((tabs) => {
                if(tabs.length > 0){
                    const firstTabId = tabs[0].tabId;
                    // focus and refresh. Let any Catch Bubble up.
                    Promise.all([helper.focusTab(workspaceAPI, firstTabId), helper.refreshTab(workspaceAPI, firstTabId)]);
                }
                helper.getAllTabInfo(component);
            });
        }
    },
})
  
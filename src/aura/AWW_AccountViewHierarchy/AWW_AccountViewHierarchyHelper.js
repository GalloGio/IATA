({
    loadHierarchy : function(component, topParentId) {
        var action = component.get('c.getAgencyHierarchy');
        action.setParams({
            'topParentId' : topParentId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log(response.getReturnValue());
                var res = JSON.parse(response.getReturnValue());
                
                component.set('v.gridData', res.hierarchyNodes);
                component.set('v.gridExpandedRows', res.expandedNodes);
                component.find('accountHierarchy').collapseAll();
            }
        });

        $A.enqueueAction(action);
    },
    resetTable : function(component) {
        component.set('v.gridData', undefined);
        component.set('v.gridExpandedRows', undefined);
    }
})
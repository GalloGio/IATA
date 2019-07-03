({
    initTable : function(component) {
        var columns = [
            {label: 'Activity', fieldName: 'Name', type: 'text'},
            {label: 'Type', fieldName: 'Type__c', type: 'text'},
            {label: 'Account Status', fieldName: 'Status__c', type: 'text'}
        ];

        if(component.get('v.canEdit') == true) {
            var actions = [
                {label: 'Edit', name: 'edit_issue', 'iconName': 'utility:edit'}
            ];
            columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        }

        component.set('v.columns', columns);
    },
    fetchData : function(component) {
        var action = component.get('c.getRecords');
        action.setParams({
            accountId: component.get('v.accountId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.data', response.getReturnValue());
            }
        });

        $A.enqueueAction(action);
    }
})
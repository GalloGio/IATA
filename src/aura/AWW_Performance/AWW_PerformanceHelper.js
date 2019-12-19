({
    initTable : function(component) {
        var columns = [
            {label: 'Activity', fieldName: 'Name', type: 'text', sortable : true},
            {label: 'Type', fieldName: 'Type__c', type: 'text', sortable : true},
            {label: 'Account Status', fieldName: 'Status__c', type: 'text', sortable : true}
        ];
        if(component.get('v.canEdit') == true) {
            var actions = [
                {label: 'Edit', name: 'edit_issue', 'iconName': 'utility:edit'}
            ];
            columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        }else if(component.get('v.haveUserAMPIssuesAndPriorities') == true){
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
                if(component.get('v.sortBy')) {
                    this.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
                }
            }
        });

        $A.enqueueAction(action);
    },
    sortData : function(component,fieldName,sortDirection) {
        var data = component.get('v.data');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { return a[fieldName]}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.data', data);
    },
    checkUserHaveAccessRightsAMPIssuesAndPriorities: function(component) {
        var action = component.get('c.getUserAccessRightsAMPIssuesAndPriorities');

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set('v.haveUserAMPIssuesAndPriorities', response.getReturnValue());
            }
            this.initTable(component);
            this.fetchData(component);
        });

        $A.enqueueAction(action);
    }
})
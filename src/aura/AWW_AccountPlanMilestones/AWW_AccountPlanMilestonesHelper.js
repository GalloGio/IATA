({
    initTable : function(component) {
        var columns = [
            {label: 'Milestone' , fieldName: 'Subject__c', type: 'text', sortable : true},
            {label: 'Responsible', fieldName: 'AM_Responsible__c', type: 'text', sortable : true},
            {label: 'Involved', fieldName: 'AM_Involved__c', type: 'text', sortable : true},
            {label: 'Support Required From Account', fieldName: 'AM_Support_Required_from_Account__c', type: 'text', sortable : true},
            {label: 'Milestone Status', fieldName: 'Status', type: 'text', sortable : true},
            {label: 'End Date', fieldName: 'ActivityDate', type: 'date', sortable : true},
            {label: 'Comments', fieldName: 'Description', type: 'text', sortable : true}
        ];

        if(component.get('v.canEdit') == true) {
            var actions = [
                {label: 'Edit', name: 'edit_milestone', 'iconName': 'utility:edit'},
                {label: 'Delete', name: 'delete_milestone', 'iconName': 'utility:delete'}
            ];
            columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        }        

        component.set('v.columns', columns);
    },
    fetchData : function(component) {
        var action = component.get('c.getTasks');
        action.setParams({
            objectiveId : component.get('v.accountPlanId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set('v.data', response.getReturnValue());
                if(component.get('v.sortBy')) {
                    this.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
                }
            }
        });

        $A.enqueueAction(action);
    },
    editRecord : function(component,event) {
        var modalCmp = component.find('manage-record');
        modalCmp.showModal(event.getParam('row'));
    },
    deleteRecord : function(component, event) {
        var modalCmp = component.find('delete-record');
        modalCmp.showModal(event.getParam('row').Id);
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
    }
})
({
    initTable : function(component) {
        var columns = [
            {label: 'Account Name', fieldName: 'ownerLink', type: 'url', sortable : true, typeAttributes: {label: {fieldName: 'ownerName'}, target: '_blank'}},
            {label: 'Owner Type', fieldName: 'ownerType', type: 'text', sortable : true},
            {label: 'Percentage Held', fieldName: 'percentageTable', type: 'percent', sortable : true, typeAttributes : {maximumFractionDigits: 2, minimumFractionDigits: 2}}            
        ];

        if(component.get('v.canEdit') == true) {
            var actions = [  
                {label: 'Edit', name: 'edit_record', iconName: 'utility:edit'},
                {label: 'Remove', name: 'remove_record', iconName: 'utility:delete'}
            ];
            columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        }       

        component.set('v.columns', columns);
    },
    fetchData : function(component) {
        var action = component.get('c.getOwners');
        action.setParams({
            accountId : component.get('v.accountId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.data', result);
                if(component.get('v.sortBy')) {
                    this.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
                }
            }            
        });

        $A.enqueueAction(action);
    },
    deleteRecord : function(component,event) {
        var modalCmp = component.find('delete-record');
        modalCmp.showModal(event.getParam('row').ownershipRecordId);
    },
    editRecord : function(component,event) {
        var modalCmp = component.find('owners-edit');
        var record = event.getParam('row');
        modalCmp.showModal('Owner','Edit',record);
    },
    sortData : function(component,fieldName,sortDirection) {
        var data = component.get('v.data');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { return a[fieldName.replace('Link','Name')]}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.data', data);
    }
})
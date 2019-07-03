({
    initTable : function(component) {
        var columns = [
            {label: 'Account Name', fieldName: 'ownerLink', type: 'url', typeAttributes: {label: {fieldName: 'ownerName'}, target: '_blank'}},
            {label: 'Owner Type', fieldName: 'ownerType', type: 'text'},
            {label: 'Percentage Held', fieldName: 'percentageTable', type: 'percent', typeAttributes : {maximumFractionDigits: 2, minimumFractionDigits: 2}}            
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
    }
})
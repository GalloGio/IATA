({
    initTable : function(component) {
        var columns = [
            {label: 'Activity', fieldName: 'objectiveName', type: 'text'},
            {label: 'Division', fieldName: 'division', type: 'text'},
            {label: 'Description', fieldName: 'description', type: 'text'},
            {label: 'Overall Status', fieldName: 'status', type: 'text'},
            {label: 'End Date', fieldName: 'endDate', type: 'date'},
            {label: 'Account Issue or Priority', fieldName: 'issueName', type: 'text'},
            {label: 'Comment', fieldName: 'comments', type: 'text'}
        ];

        var actions = [
            {label: 'Show Milestones', name: 'show_milestones', 'iconName': 'utility:picklist_type'}  
        ]

        if(component.get('v.canEdit') == true) {
            actions.push({label: 'Edit', name: 'edit_row', 'iconName': 'utility:edit'});
            actions.push({label: 'Delete', name: 'delete_row', 'iconName': 'utility:delete'});            
        }
        
        columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        component.set('v.columns', columns);
    },
    fetchData : function(component) {
        var action = component.get('c.getObjectives');
        action.setParams({
            accountId : component.get('v.accountId')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                var records = response.getReturnValue();
                var historyRecords = [];
                var currentRecords = [];
                var today = new Date().getFullYear();
                for(var i=0; i<records.length; i++) {                
                    var dlYear = parseInt(records[i].endDate);
                    if(dlYear >= today) {
                        currentRecords.push(records[i]);
                    } else {
                        historyRecords.push(records[i]);
                    }                    
                }

                component.set('v.activityView', 'current');
                component.set('v.data', currentRecords);
                component.set('v.historyData', historyRecords);
                component.set('v.currentData', currentRecords);
            }
        });

        $A.enqueueAction(action);
    },
    newRecord : function(component,event) {
        var record = {};
        record.accountId = component.get('v.accountId');
        var modalCmp = component.find('manage-record');
        modalCmp.showModal(record);
    },
    editRecord : function(component,event) {
        var modalCmp = component.find('manage-record');
        modalCmp.showModal(event.getParam('row'));
    },
    deleteRecord : function(component,event) {
        var modalCmp = component.find('delete-record');
        modalCmp.showModal(event.getParam('row').recordId);
    },
    showMilestones : function(component,event) {
        component.set('v.milestoneView',true);
        var modalCmp = component.find('milestones');
        var record = event.getParam('row');
        modalCmp.showMilestones(record.recordId, record.objectiveName);
    }
})
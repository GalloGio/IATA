({
    initTable : function(component) {
        var columns = [
            {label: 'Activity', fieldName: 'objectiveName', type: 'text', sortable : true},
            {label: 'Division', fieldName: 'division', type: 'text', sortable : true},
            {label: 'Description', fieldName: 'description', type: 'text', sortable : true},
            {label: 'Overall Status', fieldName: 'status', type: 'text', sortable : true},
            {label: 'End Date', fieldName: 'endDate', type: 'date', sortable : true},
            {label: 'Account Issue or Priority', fieldName: 'issueName', type: 'text', sortable : true},
            {label: 'Comment', fieldName: 'comments', type: 'text', sortable : true}
        ];

        var actions = [
            {label: 'Show Milestones', name: 'show_milestones', 'iconName': 'utility:picklist_type'}  
        ]

        if(component.get('v.canEdit') == true) {
            actions.push({label: 'Edit', name: 'edit_row', 'iconName': 'utility:edit'});
            actions.push({label: 'Delete', name: 'delete_row', 'iconName': 'utility:delete'});            
        }else if(component.get('v.haveUserAMPIssuesAndPriorities') == true){
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
                if(component.get('v.sortBy')) {
                    this.sortData(component,component.get('v.sortBy'),component.get('v.sortDirection'));
                }
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
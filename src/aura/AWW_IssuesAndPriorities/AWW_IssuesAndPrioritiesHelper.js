({
    initTable : function(component) {
        var columns = [
            {label: 'Name', fieldName: 'Name', type: 'text', sortable : true},
            {label: 'Division', fieldName: 'Division__c', type: 'text', sortable : true},
            {label: 'Source', fieldName: 'AM_Source_Text__c', type: 'text', sortable : true},
            {label: 'Description', fieldName: 'Details__c', type: 'text', sortable : true},
            {label: 'Importance', fieldName: 'AM_Level_of_importance__c', type: 'text', sortable : true},
            {label: 'Status', fieldName: 'Status__c', type: 'text', sortable : true},
            {label: 'Global', fieldName: 'AM_Global__c', fixedWidth: 80, type: 'boolean'},
            {label: 'Regional', fieldName: 'AM_Regional__c', fixedWidth: 85, type: 'boolean'},
            {label: 'Local', fieldName: 'AM_Local__c', fixedWidth: 80, type: 'boolean'},
            {label: 'Issues with IATA', fieldName: 'AM_Issue_with_IATA__c', fixedWidth: 90, type: 'boolean'},
            {label: 'Visible to all IATA', fieldName: 'AM_Public__c', fixedWidth: 90, type: 'boolean'}
        ];

        if(component.get('v.canEdit') == true || component.get('v.haveAMPIssuesAndPriorities') == true) {
            var actions = [
                {label: 'Edit', name: 'edit_issue', 'iconName': 'utility:edit'},
                {label: 'Delete', name: 'delete_issue', 'iconName': 'utility:delete'}
            ];
            columns.push({type: 'action', typeAttributes: {rowActions: actions}});
        }        

        component.set('v.columns', columns);
    },
	sortIssues : function (component, fieldname,reverse) {
		var backup = component.get("v.filteredData");
		backup.sort(function(a,b) {
			// special treatment for Priority
			var rating = {'High':1,'Medium':2,'Low':3};
			if(fieldname == 'AM_Level_of_importance__c') {
				if( rating[a[fieldname]] < rating[b[fieldname]]) return 1;
				else return -1;
			}
			if (a[fieldname] === undefined) return 1;
			if (b[fieldname] === undefined) return -1;

			// checkboxes
			var checkbox = (typeof a[fieldname] === 'boolean');
			if(checkbox) {
				if (a[fieldname] < b[fieldname]) return 1;
				else return -1;
			}

			if (a[fieldname].toLowerCase() < b[fieldname].toLowerCase()) return 1;
			else return -1;
		});
		if (reverse < 0) backup.reverse();
		component.set("v.filteredData",backup);
	},
    fetchData : function(component) {
        var action = component.get('c.getIssuesAndPriorities');
        var accountId = component.get('v.accountId');
        action.setParams({'accountId': accountId});        
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue()
                component.set('v.data', result);
                component.find('showClosed').set('v.checked', false);
                this.refreshIssues(component, false);
            }
        });

        $A.enqueueAction(action);
    },
    fetchHaveAMPIssuesAndPriorities : function(component) {
        var action = component.get('c.getHaveAMPIssuesAndPriorities');     
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();
                component.set('v.haveAMPIssuesAndPriorities', result);
                this.initTable(component);
            }
        });

        $A.enqueueAction(action);
    },
    editRecord : function(component, event, idRow) {
        var modalCmp = component.find('manage-record');
        var data = component.get('v.filteredData');
        for(let i = 0; i < data.length; i++ ){
            if(data[i].Id == idRow){
                modalCmp.showModal(data[i]);
            }
        }
    },
    deleteRecord : function(component, event, idRow) {
        var modalCmp = component.find('delete-record');
        modalCmp.showModal(idRow);
    },
    refreshIssues : function(component, showClosed) {
        var data = component.get('v.data');

        if(showClosed) {
            component.set('v.filteredData', data);
        } else {
            var results = data.filter(row => row.Status__c != 'Closed');
            component.set('v.filteredData', results);
        }

        component.set('v.sortBy', undefined);
        component.set('v.sortDirection', undefined);
    },
    sortData : function(component,fieldName,sortDirection) {
        var data = component.get('v.filteredData');
        var reverse = sortDirection == 'asc' ? 1: -1;
        var key = function(a) { return a[fieldName.replace('Link','Name')]}
        data.sort(function(a,b) {
            var a = key(a) ? key(a) : '';
            var b = key(b) ? key(b) : '';
            return reverse * ((a>b) - (b>a));
        });
        component.set('v.filteredData', data);
    }
})
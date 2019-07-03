({
    initTable : function(component) {
        var columns = [
            {label: 'Milestone' , fieldName: 'Subject__c', type: 'text'},
            {label: 'Responsible', fieldName: 'AM_Responsible__c', type: 'text'},
            {label: 'Involved', fieldName: 'AM_Involved__c', type: 'text'},
            {label: 'Support Required From Account', fieldName: 'AM_Support_Required_from_Account__c', type: 'text'},
            {label: 'Milestone Status', fieldName: 'Status', type: 'text'},
            {label: 'End Date', fieldName: 'ActivityDate', type: 'date'},
            {label: 'Comments', fieldName: 'Description', type: 'text'}
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
    }
})
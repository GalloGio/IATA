({
    initTable : function(component) {
        component.set('v.columns', [
            {label: 'Account Name', fieldName: 'accountLink', type: 'url', sortable : true, typeAttributes: {label: {fieldName: 'accountName'}, target: '_blank'}},
            {label: 'Location Type', fieldName: 'locationType', type: 'text', sortable : true},
            {label: 'IATA Code', fieldName: 'iataCode', type: 'text', sortable : true},            
            {label: 'country', fieldName: 'country', type: 'text', sortable : true}
        ]);        
    },
    handleVisibility : function(component, action) {
        var modal = component.find('manage-modal');
        if(action == 'show') {
            $A.util.removeClass(modal, 'slds-hide');
        } else {
            $A.util.addClass(modal, 'slds-hide');
        }
    },
    resetFilters : function(component) {
        var inputCmp = component.find('enter-search');
        inputCmp.set('v.value', '');
        inputCmp.setCustomValidity('');
        inputCmp.reportValidity();
        component.set('v.data', undefined);
        component.set('v.sortBy', undefined);
        component.set('v.sortDirection', undefined);
    },
    handleActionChange : function(component,event) {
        var currAction = component.get('v.selectedAction');
        var newAction = event.target.dataset.option;

        if(currAction != newAction) {
            component.set('v.selectedAction', newAction);
            component.set('v.data', undefined);
            this.resetFilters(component);
        }
    },
    validateInput : function(component) {
        var inputCmp = component.find('enter-search');
        var inputVal = inputCmp.get('v.value');
        var isValid = true;

        inputCmp.setCustomValidity('');

        if(!inputVal || inputVal.length < 3) {
            inputCmp.setCustomValidity('Please enter at least 3 characters before search.')
            isValid = false;
        }

        inputCmp.reportValidity();
        return isValid;
    },
    handleSearch : function(component) {
        var accountId = component.get('v.accountId');
        var selectedAction = component.get('v.selectedAction');
        var inputCmp = component.find('enter-search');
        var inputVal = inputCmp.get('v.value');

        var action = component.get('c.searchAccounts');
        action.setParams({
            key: inputVal,
            accountId: accountId,
            typeOperation: selectedAction
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                
                component.set('v.data', response.getReturnValue());                
            }   
            this.handleSpinner(component,'hide'); 
        });

        this.handleSpinner(component,'show');
        $A.enqueueAction(action);
    },
    askConfirmation : function(component) {
        var confirmationModal = component.find('confirmationModal');
        confirmationModal.show('Confirmation','Are you sure you want to apply the selected changes?','manage_hierarchy');
    },
    handleConfiramtion : function(event) {
        var decision = event.getParam('decision');

        return decision == 'yes';
    },
    handleSave : function(component) {
        var selectedRows = [];
        var selectedRowsCmp = component.find('search-results').getSelectedRows();
        selectedRowsCmp.forEach(element => {selectedRows.push(element.accountId)});
        var selectedAction = component.get('v.selectedAction');
        var accountId = component.get('v.accountId');

        var action = component.get('c.applyChangesToHierarchy');
        action.setParams({
            'parentId' : accountId,
            'childIds' : selectedRows,
            'operationType' : selectedAction
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.isSuccess) {
                    var refreshTab = component.getEvent('refreshTab');
                    refreshTab.setParams({
                        tabName : 'head_offices'
                    });
                    refreshTab.fire();
                    this.resetFilters(component);
                    this.handleVisibility(component,'hide');
                }
                this.handleSpinner(component,'hide');
            }
        });

        this.handleSpinner(component,'show');
        component.set('v.data', undefined);
        $A.enqueueAction(action);
    },
    handleSpinner : function(component,action) {
        var spinner = component.getEvent('controlSpinner');
        spinner.setParams({'option': action});
        spinner.fire();  
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
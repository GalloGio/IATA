({
    initTable : function(component) {
        component.set('v.columns',[
            {label: 'Account Name', fieldName: 'accountLink', type: 'url', typeAttributes: {label: {fieldName: 'accountName'}, target: '_blank'}},
            {label: 'IATA Code', fieldName: 'iataCode', type: 'text'},
            {label: 'Country', fieldName: 'country', type: 'text'}
        ]);
    },
    initModal : function(component,args) {
        component.set('v.typeOfRecord', args.typeOfRecord);
        component.set('v.operation', args.operation)
        component.set('v.record', args.record);
        
        var header = args.operation + ' ' + args.typeOfRecord;
        component.set('v.header', header);

        if(args.operation == 'Add') {
            component.find('accountNameSearch').set('v.value','');
            component.find('percentageHeld').set('v.value',0);            
        } else {
            var recordName = args.typeOfRecord == 'Owner' ? args.record.ownerName : args.record.accountName;
            component.set('v.searchName',recordName);
            component.find('percentageHeld').set('v.value',args.record.percentage);  
        }       
        component.set('v.data', null);

        var percentageInpt = component.find('percentageHeld');
        percentageInpt.setCustomValidity('');
        percentageInpt.reportValidity();
    },
    showModal : function(component) {
        var modal = component.find('ownership-edit');
        $A.util.removeClass(modal, 'slds-hide');
    },
    hideModal : function(component) {
        var modal = component.find('ownership-edit');
        $A.util.addClass(modal, 'slds-hide');
    },
    handleSearch : function(component,searchTerm) {
        var action = component.get('c.searchBy');
        action.setParams({
            key : searchTerm,
            accountId : component.get('v.accountId'),
            type : component.get('v.typeOfRecord')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.data', result.accounts);
            }
        });

        $A.enqueueAction(action);
    },
    createRecord : function(component,rows) {
        var records = [];
        var operation = component.get('v.operation');
        var typeOfRecord = component.get('v.typeOfRecord');

        for(var i=0; i<rows.length; i++) {
            var record;
            if(operation == 'Add') {
                record = typeOfRecord == 'Owner' ? this.createOwnerRecord(component,rows[i]) : this.createSubsidiaryRecord(component,rows[i]);
            } else {
                record = rows[i];
            }

            if(!record.percentage || record.percentage == 0) {
                delete record.percentage;
        }       

            records.push(record);
        }

        var action = component.get('c.addRecord');
        action.setParams({
            request : JSON.stringify(records)
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var refreshEvt = component.getEvent('refreshTab');
                refreshEvt.setParams({
                    tabName : 'ownership'
                });
                refreshEvt.fire(); 
                this.hideModal(component);
            } else {
                var message = 'Unknown error';
                var errors = response.getError();
                if(errors && Array.isArray(errors) && errors.length > 0 && Array.isArray(errors[0].pageErrors) && errors[0].pageErrors.length > 0) {
                    message = errors[0].pageErrors[0].message;
                }

                component.set('v.errorMessage', message);
            }
            this.handleSpinner(component, 'hide');
        });

        this.handleSpinner(component,'show');
        $A.enqueueAction(action);
    },
    createOwnerRecord : function(component,row) {
        var record = {
            accountId : component.get('v.accountId'),
            ownerId : row.accountId,
            percentage : component.find('percentageHeld').get('v.value')
        }

        if(!row.accountId) {
            record.ownerName = component.find('accountNameSearch').get('v.value');
        }

        return record;
    },
    createSubsidiaryRecord : function(component,row) {
        var record = {
            accountId : row.accountId,
            ownerId : component.get('v.accountId'),
            percentage : component.find('percentageHeld').get('v.value')
        }

        if(!row.accountId) {
            record.accountName = component.find('accountNameSearch').get('v.value');
        }

        return record;
    },
    askConfirmation : function(component) {
        var confirmationModal = component.find('confirmationModal');
        confirmationModal.show('Confirmation','Are you sure you want to apply the selected changes?','ownership_edit');
    },
    handleConfiramtion : function(event) {
        var decision = event.getParam('decision');
        return decision == 'yes';
    },
    handleSpinner : function(component, value) {
        var spinner = component.getEvent('controlSpinner');
        spinner.setParams({'option': value});
        spinner.fire();
    }
})
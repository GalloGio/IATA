({
    handleModalVisibility : function(component,event,helper) {
        var args = event.getParam('arguments');
        
        if(args) {
            helper.initTable(component);
            helper.initModal(component,args);
            helper.showModal(component);
        } else {
            helper.hideModal(component);
        }
    },
    search : function(component,event,helper) {
        var key = component.find('accountNameSearch').get('v.value');
        if(key.length > 2) {
            helper.handleSearch(component,key)
        } else {
            component.set('v.data', null);
        }
    },
    save : function(component,event,helper) {
        helper.askConfirmation(component);
    },
    confirmation : function(component,event,helper) {
        if(event.getParam('action') != 'ownership_edit') {
            return;
        }
        var proceed = helper.handleConfiramtion(event);

        if(proceed) {
            component.set('v.errorMessage', null);
            
            var rows = [];

            if(component.get('v.operation') == 'Edit') {
                var row = component.get('v.record');
                rows.push(row);
            } else {
                var results = component.find('search-results');
                if(results) {
                    rows = results.getSelectedRows();
                } else {
                    rows.push({});
                }    
            }
            
            helper.createRecord(component,rows);
        }
    },
    updateCounter : function(component,event,helper) {
        var results = component.find('search-results');
        if(results) {
            component.set('v.selectedRowsCount',results.getSelectedRows().length);
        }
    }, 
    unselect : function(component,event,helper) {
        var results = component.find('search-results');
        results.set('v.selectedRows',[]);
        component.set('v.selectedRowsCount',0);
    },
    handleSort : function(component,event,helper) {
        var sortBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set('v.sortBy',sortBy);
        component.set('v.sortDirection',sortDirection);
        helper.sortData(component,sortBy,sortDirection);
    }
})
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
            
            var row = {};

            if(component.get('v.operation') == 'Edit') {
                row = component.get('v.record');
            } else {
                var results = component.find('search-results');
                if(results) {
                    var selectedRow = results.getSelectedRows()[0];
                    row = selectedRow ? selectedRow : {};
                }    
            }
            
            helper.createRecord(component,row);
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
    }
})
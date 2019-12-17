({
    handleModalVisibility : function(component,event,helper) {
        var args = event.getParam('arguments');
        component.set("v.isGreaterThanOneHundred", false);
        if(args) {
            helper.initTable(component);
            helper.initModal(component,args);
            helper.initTableRemove(component,args);
            helper.showModal(component);
        } else {
            helper.hideModal(component);
        }
    },
    changeAction : function(component, event, helper) {
        helper.handleActionChange(component, event);
    },
    search : function(component,event,helper) {
        var key = component.find('accountNameSearch').get('v.value');
        if(key.length > 2) {
            helper.handleSearch(component,key)
        } else {
            component.set('v.data', null);
        }
    },
    handleGreaterThanOneHundred : function(component,event,helper) {
        let allRecords = component.get('v.allRecords');
        let totalPercentage = 0;
        let isNew = true;
        for(let i = 0; i < allRecords.length; i++){
            if(allRecords[i].percentage){
                if(component.get('v.whatType') == 'owner'){
                    if(component.get('v.record') && component.get('v.record').ownerName == allRecords[i].ownerName){ 
                            totalPercentage += parseFloat(component.get('v.record.percentage'));
                            isNew = false;
                    }else{
                        totalPercentage += allRecords[i].percentage;
                    }
                }else{

                    if(component.get('v.record') && component.get('v.record').accountName == allRecords[i].accountName){ 
                            totalPercentage += parseFloat(component.get('v.record.percentage'));
                            isNew = false;
                    }else{
                        totalPercentage += allRecords[i].percentage;
                    }
                }
            }
        }
        
        if(isNew){
            totalPercentage += parseInt(component.get('v.record.percentage'));
        }  
        if(component.get('v.record.percentage') <= 100 && totalPercentage <= 100){
            $A.util.removeClass(component.find("greaterThanOneHundred"), "slds-hide");
            component.set("v.isGreaterThanOneHundred", false);
        }else{
            if(totalPercentage > 100){
                component.set("v.isGreaterThanOneHundred", true);
            }
            $A.util.addClass(component.find("greaterThanOneHundred"), "slds-hide");
        }
    },
    save : function(component,event,helper) {
        if(component.get('v.record.percentage') <= 100){
            helper.askConfirmation(component);
            $A.util.removeClass(component.find("greaterThanOneHundred"), "slds-hide");
        }else{
            $A.util.addClass(component.find("greaterThanOneHundred"), "slds-hide");
        }
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
                if(component.get('v.selectedAction') != 'add'){
                    results = component.find('search-results-remove');
                }
                if(results) {
                    rows = results.getSelectedRows();
                } else {
                    rows.push({});
                }    
            }
            if(component.get('v.selectedAction') == 'add'){
                helper.createRecord(component,rows);
            }else{
                helper.removeRecord(component,rows);
            }
        }
    },
    updateCounter : function(component,event,helper) {
        
        var results = component.find('search-results');
        if(component.get('v.selectedAction') != 'add'){
            results = component.find('search-results-remove');
        }
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
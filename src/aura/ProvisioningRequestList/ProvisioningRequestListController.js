({
    doInit: function(cmp, event, helper) {  
        helper.getAllUserProvisioningRequestList(cmp, helper); 
    },
    
    onlyFailedRequests: function(cmp, event, helper){
        helper.getFailedUserProvisioningRequestList(cmp, helper);
    },
    
    refreshView: function(cmp, event, helper){
        var viewSelected = cmp.get("v.view");
        if (viewSelected == "failed"){
            helper.getFailedUserProvisioningRequestList(cmp, helper);
        }
        else if (viewSelected == "all"){
            helper.getAllUserProvisioningRequestList(cmp, helper);
        }
    },
    
    allRequests: function(cmp, event, helper) {
        helper.getAllUserProvisioningRequestList(cmp, helper); 
    },
    
    handleRetry: function(cmp, event, helper) {
        helper.retryFailedRequests(cmp, helper);
    },
    
    handleManuallyComplete: function(cmp, event, helper) {
        helper.manuallyCompleteFailedRequests(cmp, helper);
    },
    
    handleCheckbox: function(cmp, event, helper) {
        helper.updateRequestsSelected(cmp, event);
    },
    
    handlePageChange: function(cmp, event, helper) {
        var newPage = event.getParam("page");
        cmp.set("v.page", newPage)
        
        helper.doPagination(cmp, helper);
    },
    
    handleSearchChange: function(cmp, event, helper) {
        var newSearch = event.getParam("search");
        cmp.set("v.search", newSearch);
        helper.updateListViewBySearch(cmp, helper);
    },
    
    // Have to manually update selectedRequests list because setting
    // value of checkbox doesn't fire changed event
    checkAllCheckBoxes: function(cmp, event, helper) {
        var checkValue = true;
        var requestList = cmp.get("v.selectedRequests");
        requestList = [];
        
        // Get all checkboxes on every row and don't proceed if there are no rows
        var checkboxes = cmp.find("RowSelect");
        if (!checkboxes){
            return;
        }
        if (cmp.get("v.allChecked")){
            checkValue = false;
            cmp.set("v.allChecked", false);
            for (var i = 0; i < checkboxes.length; i++){
                checkboxes[i].set("v.value", checkValue);
            }	
        } else {
            cmp.set("v.allChecked", true);
            for (var i = 0; i < checkboxes.length; i++){
                checkboxes[i].set("v.value", checkValue);
                requestList.push(checkboxes[i].get("v.text"))
            }	
        }
        // Set the requestlist to reflect the checkbox changes
        cmp.set("v.selectedRequests", requestList);
    },
    
    showLog: function(cmp, event, helper) {
        // Hack to pass in record ID
        var id = event.getSource().get("v.target");
        
        var bodyCmp = $A.createComponent(
            "c:UPRLogList",
            {
                "record": id
            },
            function(logList){
                $A.get('e.ui:createPanel').setParams({
                    panelType: 'modal',
                    visible: true,
                    panelConfig: {
                        title: 'Logs for UPR record \'' + id + '\'',
                        body: logList,
                        modalClass:'slds-modal slds-fade-in-open slds-modal--large'
                    }
                }).fire();
            }
        );  
    }
})
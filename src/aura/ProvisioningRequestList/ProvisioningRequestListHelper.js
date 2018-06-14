({
    getFailedUserProvisioningRequestList: function(cmp, helper) {
        var spinner = cmp.find('spinner');
		$A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.getFailedRequests");
        
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS"){ 
                var postSubmitButtons = document.getElementById("onlyFailedButton");
                postSubmitButtons.setAttribute("style", "display: none;");
                var preSubmitButtons = document.getElementById("allRequestsButton");
                preSubmitButtons.setAttribute("style", "display: block;");
                cmp.set("v.view", "failed");
                
                var allRequests = response.getReturnValue();
                cmp.set("v.requests", allRequests);
                var requestsPerPage = cmp.get("v.requestsPerPage");
                var pages = Math.floor(allRequests.length / requestsPerPage);
                cmp.set("v.pages", pages);
                cmp.set("v.page", 0);
                helper.doPagination(cmp, helper);
            }
            else if (state == "ERROR"){
                var errors = response.getError();
                if (errors){
                    console.log(errors[0]);
                }
                else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);        
    },
    
    getAllUserProvisioningRequestList: function(cmp, helper) {
        var spinner = cmp.find('spinner');
		$A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.getAllRequests");
        
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS"){
                var postSubmitButtons = document.getElementById("onlyFailedButton");
                postSubmitButtons.setAttribute("style", "display: block;");
                var preSubmitButtons = document.getElementById("allRequestsButton");
                preSubmitButtons.setAttribute("style", "display: none;");
                cmp.set("v.view", "all");   
                
                var allRequests = response.getReturnValue();
                cmp.set("v.requests", allRequests);
                var requestsPerPage = cmp.get("v.requestsPerPage");
                var pages = Math.floor(allRequests.length / requestsPerPage);
                cmp.set("v.pages", pages);
                cmp.set("v.page", 0);
                helper.doPagination(cmp, helper);
            }
            else if (state == "ERROR"){
                var errors = response.getError();
                if (errors){
                    console.log(errors[0]);
                }
                else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getFailedUserProvisioningRequestListBySearch: function(cmp, helper) {
        var spinner = cmp.find('spinner');
		$A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.getFailedRequestsBySearch");
        var searchKey = cmp.get("v.search");
        action.setParams({
            "searchKey": searchKey
        });
        
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS"){
                var allRequests = response.getReturnValue();
                cmp.set("v.requests", allRequests);
                var requestsPerPage = cmp.get("v.requestsPerPage");
                var pages = Math.floor(allRequests.length / requestsPerPage);
                cmp.set("v.pages", pages);
                cmp.set("v.page", 0);
                helper.doPagination(cmp, helper);
            }
            else if (state == "ERROR"){
                var errors = response.getError();
                if (errors){
                    console.log(errors[0]);
                }
                else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getAllUserProvisioningRequestListBySearch: function(cmp, helper) {
        var spinner = cmp.find('spinner');
		$A.util.removeClass(spinner, "slds-hide");
        var action = cmp.get("c.getAllRequestsBySearch");
        var searchKey = cmp.get("v.search");
        action.setParams({
            "searchKey": searchKey
        });
        
        var self = this;
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS"){
                var allRequests = response.getReturnValue();
                cmp.set("v.requests", allRequests);
                var requestsPerPage = cmp.get("v.requestsPerPage");
                var pages = Math.floor(allRequests.length / requestsPerPage);
                cmp.set("v.pages", pages);
                cmp.set("v.page", 0);
                helper.doPagination(cmp, helper);
            }
            else if (state == "ERROR"){
                var errors = response.getError();
                if (errors){
                    console.log(errors[0]);
                }
                else{
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    retryFailedRequests: function(cmp, helper) {
        var action = cmp.get("c.retryUserProvisioningRequests");
        
        var self = this;
        var failedUprIds = cmp.get("v.selectedRequests");
        
        if(failedUprIds.length == 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "warning",
                    "message": "You must select at least one record"
                });
                toastEvent.fire();
        }else{ 
            
        	action.setParams({"failedRequestList":failedUprIds});
        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state == "SUCCESS"){
                	var emptyArray = [];
                	cmp.set("v.selectedRequests", emptyArray);
                	helper.updateListView(cmp, helper); 
                	var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"message": "Successfully retried records."
                	});
                	toastEvent.fire();
            	}
            	else if (state == "ERROR"){
                	var errors = response.getError();
                	if (errors){
                    	console.log(errors[0]);
                	}
                	else{
                    	console.log("Unknown error");
                	}
            	}
        	});
        }
        $A.enqueueAction(action);
    },
    
    manuallyCompleteFailedRequests: function(cmp, helper) {
        var action = cmp.get("c.manuallyCompleteUserProvisioningRequest");
        
        var self = this;
        var failedUprIds = cmp.get("v.selectedRequests");
        
        if(failedUprIds.length == 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "warning",
                    "message": "You must select at least one record"
                });
                toastEvent.fire();
        }else{        
        
        	action.setParams({"completedRequests":failedUprIds});
        	action.setCallback(this, function(response) {
            	var state = response.getState();
            	if (state == "SUCCESS"){
                
                	var emptyArray = [];
                	cmp.set("v.selectedRequests", emptyArray);
                
                	var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                    	"message": "Successfully set records to manually completed"
                	});
                	toastEvent.fire();
                
                	helper.updateListView(cmp, helper); 
            	}
            	else if (state == "ERROR"){
                	var errors = response.getError();
                	if (errors){
                    	console.log(errors[0]);
                	}
                	else{
                    	console.log("Unknown error");
                	}
            	}
        	});
        }
        $A.enqueueAction(action);
        
    },
    
    updateRequestsSelected: function(cmp, event) {
        
        var id = event.getSource().get("v.text");
        var selectedRequests = cmp.get("v.selectedRequests");
        var indexOfRequest = selectedRequests.indexOf(id);
        if (indexOfRequest >= 0){
            selectedRequests.splice(indexOfRequest, 1);
        }
        else{
            selectedRequests.push(id);
        }
        cmp.set("v.selectedRequests", selectedRequests);
        
    },
    
    updateListView: function(cmp, helper) {
        
        var viewSelected = cmp.get("v.view");
        if (viewSelected == "failed"){
            helper.getFailedUserProvisioningRequestList(cmp, helper);
        }
        else if (viewSelected == "all"){
            helper.getAllUserProvisioningRequestList(cmp, helper);
        }

    },
    
    updateListViewBySearch: function(cmp, helper) {
        
        var viewSelected = cmp.get("v.view");
        if (viewSelected == "failed"){
            helper.getFailedUserProvisioningRequestListBySearch(cmp, helper);
        }
        else if (viewSelected == "all"){
            helper.getAllUserProvisioningRequestListBySearch(cmp, helper);
        }
        
    },
    
    doPagination: function(cmp, helper) {
        var spinner = cmp.find('spinner');
		$A.util.removeClass(spinner, "slds-hide");
        var page = cmp.get("v.page");
        var recordsPerPage = cmp.get("v.requestsPerPage");
        var allRecords = cmp.get("v.requests");
        
        var start = page * recordsPerPage;
        var newPageRecords = allRecords.slice(start, start + (recordsPerPage + 1));
        
        cmp.set("v.pageRequests", newPageRecords);
        var spinner = cmp.find('spinner');
		$A.util.addClass(spinner, "slds-hide");
        
    },
    
    resetList: function(cmp, helper) {
        
        var list = cmp.get("v.selectedRequests");
        list = list.splice(0, list.length);
        cmp.set("v.selectedRequests", list);
        
    }
})
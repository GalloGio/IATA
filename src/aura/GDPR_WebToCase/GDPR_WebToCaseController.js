({
	doInit : function(component, event, helper) {
        component.set("v.requestType", "passenger");
        //Check if contact is DPO
        var checkIfContactIsDPOAction = component.get("c.checkIfContactIsDPO");
        checkIfContactIsDPOAction.setCallback(this, function(response){
        	var state = response.getState();
            
        	if (state === "SUCCESS") {
                var isDPO = response.getReturnValue();
                if(isDPO == null)
                isDPO = false;
                component.set("v.isContactDPO", isDPO);
                component.set("v.showDPOArea", isDPO);
                component.set("v.localLoading", false);
         	}
      	});
       	$A.enqueueAction(checkIfContactIsDPOAction);
        
        //get data privacy rights pick values
        var getDataPrivacyRightsPickValuesAction = component.get("c.getDataPrivacyRightsPickValues");
        getDataPrivacyRightsPickValuesAction.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var dataPrivacyRightsPickValues = response.getReturnValue();
                component.set("v.dataPrivacyRightsPickValues", dataPrivacyRightsPickValues);
                component.set("v.localLoading", false);
            }
        });
        $A.enqueueAction(getDataPrivacyRightsPickValuesAction);
        
        //Get new empty case
        var createEmptyCaseAction = component.get("c.createEmptyCase");
        createEmptyCaseAction.setParams({
            "creatorEmail": _userInfo.getUserInfo().email
        });
        
        createEmptyCaseAction.setCallback(this, function(response){
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var newCaseDPO = response.getReturnValue();
                component.set("v.newCaseDPO", newCaseDPO);
                component.set("v.localLoading", false);
            } else {
                console.log('error');
            }
        });
        $A.enqueueAction(createEmptyCaseAction);
    },
    
    submitCaseButtonHandler : function(component, event, helper) {
        // Check field first
        var canInsertCase = true;
        var controlDPOField = true;

        var controlFields  = helper.controlFields(component);
        if(component.get("v.isContactDPO") && component.get("v.requestType") == "passenger")
            controlDPOField = helper.controlDPOFields(component);

        if(controlFields && controlDPOField){
            component.set("v.localLoading", true);
            var newCaseDPO = component.get("v.newCaseDPO");            
            var showDPOArea = component.get("v.showDPOArea");
            
            var action = component.get("c.submitCase"); 
            action.setParams({
                "caseJSON": JSON.stringify(newCaseDPO),
                "isDPOCase": showDPOArea
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue().severity === 'SUCCESS'){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'dismissable',
                            title: response.getReturnValue().severity,
                            message: 'Case created with success',
                            type: 'success'
                        });
                        toastEvent.fire();
                        component.set("v.submitNewCase", true);
                        // Notify other component to reload case list
                        var refreshCaseList = $A.get("e.c:EVT_GDPR_UpdateCaseList");
                        refreshCaseList.fire();
                    } else if(response.getReturnValue().severity === 'ERROR') {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'dismissable',
                            title: response.getReturnValue().severity,
                            message: response.getReturnValue().message,
                            type: 'error'
                        });
                        toastEvent.fire();
                    }
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                
                component.set("v.localLoading", false);

            });
            $A.enqueueAction(action);
        }else{
            component.set("v.localLoading", false);
        }
    },
    
    submitNewCaseButtonHandler : function (component, event, helper){
        //Clear fields
        var myCase = component.get("v.newCaseDPO");
        myCase.Subject = "";
        myCase.Data_Privacy_Rights__c = '';
        myCase.Description = '';
        myCase.Passenger_Name_PXNM__c = '';
        myCase.Ticket_Number_TDNR__c = '';
        myCase.Date_of_Issue_DAIS__c = null;
        
        component.set("v.newCaseDPO", myCase);
        component.set("v.requestType", "passenger");

        // Display section
        component.set("v.submitNewCase", false);
    },

    onRequestTypeChange : function (cmp, evt, hlp){
        cmp.set("v.showDPOArea", cmp.get("v.requestType") == "passenger");
    },

    
})
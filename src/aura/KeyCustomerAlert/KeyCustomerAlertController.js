({
    doInit : function(component,event,helper) {
        var action = component.get('c.getKeyCustomerAlertInfo');
        var caseId = component.get('v.recordId');
        action.setParams({'caseId': caseId});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                var rt_names = [];
                if(result.developerNames) {
                    for(var i=0; i < result.developerNames.length; i++) {
                        rt_names.push(result.developerNames[i].Record_Type__c);
                    }
                }
                if(result.CaseDetail.Account.Identify_as_Key_Customer__c && rt_names.indexOf(result.CaseDetail.RecordType.Name) >= 0) {
                    component.set('v.showLoading', false);
                }else{
                    var a = component.get('c.gotoURL');
                    $A.enqueueAction(a);
                } 
            }else{
                var a = component.get('c.gotoURL');
                $A.enqueueAction(a);
            } 
        });

        $A.enqueueAction(action);
    },
    gotoURL : function(component, event, helper) {

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url":component.get('v.urlVisualForcePage')+component.get('v.recordId')
        });
        urlEvent.fire(); 
    }
})
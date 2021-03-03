({
    doInit : function(component,event,helper) {
        var action = component.get('c.getCaseInfo');
        var caseId = component.get('v.recordId');
        action.setParams({'caseId': caseId});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var auxPriority = '';
                if(result.Priority == "Emergency"){
                    auxPriority = "Emergency";
                }else{
                    auxPriority = ""; 
                }
                var url='/500/e?retURL=/'+result.Contact.Id+'&cas11=Internal Case&RecordType=012200000000DSO&cas14='+result.Subject+'_Task&00N20000000h4cK='+result.BSPCountry__c+'&cas3_lkid='+result.ContactId+'&00N20000001YFZ5='+result.Region__c+'&00N20000000h8DB='+result.Type_of_customer__c+'&00N20000000zKjz='+result.Owner.Name+'&cas4_lkid='+result.AccountId+'&cas28='+result.CaseNumber+'&00N20000000h1xp='+result.CaseArea__c+'&00N20000000h23T='+result.Reason1__c+'&cas8='+auxPriority;
                component.set('v.urlVisualForcePage',url);
            }
        });

        $A.enqueueAction(action);
    }
})
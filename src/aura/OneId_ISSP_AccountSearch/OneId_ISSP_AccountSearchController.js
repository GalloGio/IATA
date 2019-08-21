({
    onRender : function(component, event, helper) {
        var action = component.get("c.getMetadataCustomerType");
        action.setParams({
            "customerTypeKey": component.get("v.customerType")
        });
        action.setCallback(this, function(a) {
            var metadataCustomerType = a.getReturnValue();

            if(metadataCustomerType.Fields_Targeted_Partial_Match__c !== undefined || metadataCustomerType.Fields_Targeted_Exact_Match__c !== undefined){
	            component.set("v.displayIataCodesInputField", true);
            }
            else{
	            component.set("v.displayIataCodesInputField", false);
            }
        });
        $A.enqueueAction(action);
    },
    search : function(component, event, helper) {
        // Unvalidate component when user tries to change input
        console.log('c.search');
        
        var userInputIataCodesValue = component.get("v.userInputIataCodes");
        var userInputCompanyNameValue = component.get("v.userInputCompanyName");
        var customerType = component.get("v.customerType");
        var countryId = component.get("v.countryId");
        
        var resultDiv = component.find('results');

        if((userInputIataCodesValue !== undefined && userInputIataCodesValue.length > 1) || (userInputCompanyNameValue !== undefined && userInputCompanyNameValue.length > 2)) {
            component.set("v.searched", true);
            component.set("v.searching", true);
            
            let action = component.get("c.searchAccounts");
            
            action.setParams({
                customerTypeKey:customerType,
                countryId:countryId,
                userInputIataCodes:userInputIataCodesValue,
                userInputCompanyName:userInputCompanyNameValue
            });
            
            action.setCallback(this, function(a) {
                if(a.getState() == 'SUCCESS'){
                    let response = a.getReturnValue();
                    
                    component.set("v.totalAccounts" , response.totalAccounts);
                    component.set("v.fieldLabels" , response.fieldLabels);
                    
                    
                    if(response.results != undefined && response.results.length > 0) {
                        component.set("v.foundRecords", response.results);
                    } else {
                        component.set("v.foundRecords",[[$A.get("{!$Label.c.OneId_NoResults}")]]);
                    }
                    
                    if(response.accountIds != null){
                        component.set("v.accountIds",response.accountIds);
                    }
                    
                    // Show suggestion box
                    if(!$A.util.hasClass(resultDiv, 'slds-is-open')) $A.util.addClass(resultDiv, 'slds-is-open');
                }else{
                    let err = a.getError();
                    console.log('ERR: '+err);
                }
                component.set("v.searching", false);
            });
            $A.enqueueAction(action);
            
        } else {
            component.set("v.searching", false);
            $A.util.removeClass(resultDiv, 'slds-is-open');
        }
        
    },
    
    reset : function (c) {
        c.set('v.userInputIataCodes', '');
        c.set('v.userInputCompanyName', '');
        c.set('v.searched', false);
        $A.util.removeClass(c.find('results'), 'slds-is-open');
    },
    
    suggestionSelected: function(c, e) {
        var selectedAccountName = e.currentTarget.dataset.value;
        let selectedAccountIndex = e.currentTarget.dataset.rowIndex;
        
        console.log('suggestionSelected -> '+selectedAccountName)
        
        if(selectedAccountName != $A.get("{!$Label.c.OneId_NoResults}")) {
            // Set input with selected value
            c.set("v.userInputCompanyName", selectedAccountName);
            let accountIds = c.get("v.accountIds");
            
            c.getEvent("itemSelected")
            .setParams({
                "state" : "accountSelected",
                "account" : {Id : accountIds[selectedAccountIndex]}
            }).fire();
        }else{
            c.getEvent("itemSelected")
            .setParams({
                "state" : "noAccount",
                "account" : {Name : c.get("v.userInputCompanyName")}
            }).fire();
        }
        
        // Hide suggestion box
        $A.util.removeClass(c.find('results'), 'slds-is-open');
    },
    
    createNew : function (c) {
        c.set("v.account.Name", c.get("v.userInputCompanyName"));
        
        c.getEvent("itemSelected")
        .setParams({
            "state" : 'createNew',
            "account" : {Name : c.get("v.userInputCompanyName")}
        })
        .fire();
    }
})
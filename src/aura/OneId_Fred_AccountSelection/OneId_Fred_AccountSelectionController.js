({
/**
    Load customer type depending on service provider in URL
*/
	doInit : function(cmp, event, helper) {

    },

    renderPage : function (component, event, helper){
    console.log("@@@@@ SMH_RENDER");
        var state = event.getParam("state");       

        console.info("renderPage - state "+state);
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            var primaryUserAccountID = event.getParam("paramsMap").scu;
            console.info("renderPage - paramsMap ");
            console.info(event.getParam("paramsMap"));
            if(/\S/.test(servName)){
                console.log("@@@@@ SMH_RENDER"+primaryUserAccountID);
                component.set("v.serviceName", servName);
                if(primaryUserAccountID == undefined){ 
                    helper.getCustomerTypeAvailableByServiceName(component);
                }   
            }
            if(/\S/.test(primaryUserAccountID)){
                // coming from "Create New User button" triggered by a primary user => Load account associated
                if(primaryUserAccountID === 'true') 
                    helper.getPartnerAccount(component);
            }
        }
        component.set("v.loaded", true);
    },

/**
    When a user type inside the search box
*/
	onKeyUp : function(component, event, helper) {
		var cardHeight= 77;
        // Unvalidate component when user tries to change input
        component.set("v.isValid", false);
        component.set("v.accountSelected", false);

        if(helper.isMandatoryFieldsOK(component)) {

            // When user search on input field call Address doctor to get suggestion for validation of address
            var userInputCmp = event.currentTarget;
            
            var action = component.get("c.getAccountsByType");
            action.setParams({
            	"customerType":component.get("v.customerType"),
                "userInput":userInputCmp.value
            });

            action.setCallback(this, function(a) {
                var accountSuggested = a.getReturnValue().accList;
                component.set("v.totalResult" , a.getReturnValue().totalAccListNotLimited);
                //suggestions = [];
                console.log(accountSuggested);
                if(accountSuggested != undefined && accountSuggested.length > 0) {
                    component.set("v.response", accountSuggested);
                    // Expand section to display correctly suggestions. nb or record + 3 multiply by height of li=20 in this case
                    component.set("v.suggestionBoxHeight", (accountSuggested.length + 1) * cardHeight );
                   
                } else {
                     console.log('no result');
                    var noResult = {'Name':'No result found...', 'Airline_designator__c':'-', 'ICAO_Member__r.ICAO_Iso_3_Code__c':'-', 'ICAO_Member__r.State_Name__c':'-'};
                    if(component.get("v.customerType")=='ICAO Member State')
                        noResult = {'State_Name__c':'No result found...', 'ICAO_Iso_2_Code__c':'-', 'ICAO_Iso_3_Code__c':'-'};
                    var suggestions = [];
                    suggestions.push(noResult);
                    component.set("v.response",suggestions);

                    component.set("v.suggestionBoxHeight", (2 * cardHeight));
                }
                // Show suggestion box
                var userInputCmpName = userInputCmp.dataset.value;
                var resultDiv = component.find(userInputCmpName);
                if(! $A.util.hasClass(resultDiv, 'slds-is-open'))
                    $A.util.toggleClass(resultDiv, 'slds-is-open');
            });

            if(! $A.util.isEmpty(component.get("v.customerType"))) {
                if($A.util.isEmpty(userInputCmp.value) || userInputCmp.value.length < 2) {
                    // Hide suggestion box
                    var userInputCmpName = userInputCmp.dataset.value;
                    var resultDiv = component.find(userInputCmpName);
                    if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                        $A.util.removeClass(resultDiv, 'slds-is-open');
                    }
                    component.set("v.suggestionBoxHeight", 0);
                    
                } else {
                    // Call search of accounts when user input at least 2 characters
                    $A.enqueueAction(action);
                }
            }
        } else {
             // Hide suggestion box
            var userInputCmpName = userInputCmp.dataset.value;
            var resultDiv = component.find(userInputCmpName);
            if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                $A.util.removeClass(resultDiv, 'slds-is-open');
            }
        }

	},

    typeOfCustomerChanged: function(component, event, helper) {
         console.log(component.get("v.contact").Phone);
        component.set("v.userInput", ""); // Empty input of user
        component.find("typeOfCustomer").set("v.errors", null); // Clear error
        component.set("v.response",[]);
        // Hide suggestion box
        var resultDiv = component.find("agencies");
        if($A.util.hasClass(resultDiv, 'slds-is-open')) {
            $A.util.removeClass(resultDiv, 'slds-is-open');
        }

        if(component.get("v.customerType")=="Aircraft Operator")
            component.set("v.searchPlaceholder","Please enter an account name, IATA code, ICAO code or ICAO member state");
        else if (component.get("v.customerType")=="ICAO Member State")
            component.set("v.searchPlaceholder","Please enter a state name, ISO code in 2 or 3 letters");
        else {
            component.set("v.searchPlaceholder","Please enter an account name");
        }

    },
    
/**
    When a user select a sugestion from the suggestion box
*/
    suggestionSelected: function(component, event, helper) {
        var suggestionSelected = event.currentTarget;
        var accountIndex = suggestionSelected.dataset.rowIndex;

        console.log(suggestionSelected.dataset.value);

        if(suggestionSelected.dataset.value != 'No result found...') { //TODO Compare with custom label
            // Set input with selected value
            //var userInputCmp = component.find("userInput");
            component.set("v.userInput", suggestionSelected.dataset.value);

            // Hide suggestion box
            var resultDiv = component.find("agencies");
            if($A.util.hasClass(resultDiv, 'slds-is-open')) {
                $A.util.removeClass(resultDiv, 'slds-is-open');
            }
            component.set("v.suggestionBoxHeight", 0 );
            component.set("v.accountSelected", true);
            component.set("v.acc", component.get("v.response")[accountIndex]);
        }
    },

    isComponentValid : function(component, event, helper) {
        return component.get("v.isValid");
    },

    submit : function(component, event, helper) {
        // Show spinner during registration process
        $A.util.toggleClass(component.find("mySpinner"), "slds-hide");

        console.log(component.get("v.acc"));
        console.log(component.get("v.contact"));

       var action = component.get("c.registration");
        action.setParams({
            "acc":component.get("v.acc"),
            "con":component.get("v.contact"),
            "selectedCustomerType":component.get("v.customerType")
        });

        action.setCallback(this, function(a) {

            var result = a.getReturnValue();
            // redirect to a new page when registration is done
            if(result) {
                window.location.href = "/identity/s/registrationcomplete?serviceName="+component.get("v.serviceName");
            }
            
            if(!result) {
                $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "title": 'error',
                    "message": 'error'
                });
                toastEvent.fire();
            } 
            console.log(result);
        });
        $A.enqueueAction(action);
    },

    createAccount : function(component, event, helper) {
        // Hide suggestion box
        var resultDiv = component.find("agencies");
        if($A.util.hasClass(resultDiv, 'slds-is-open')) {
            $A.util.removeClass(resultDiv, 'slds-is-open');
        }
         component.set("v.userInput", "No account found");
         component.set("v.createAccountRequested", true);
    },

    goToContactUs : function(component, event, helper) {
        window.location.href = "http://www.iata.org/whatwedo/environment/Pages/FRED+release-subscription.aspx";

    }
})
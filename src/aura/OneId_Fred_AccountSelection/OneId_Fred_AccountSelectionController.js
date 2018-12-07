({

    
/**
    Load customer type depending on service provider in URL
*/
    doInit : function (component, event, helper){
         var urlParamEncoded = window.location.search.substring(1).toString();
        var urlParameters = decodeURIComponent(urlParamEncoded); // Right part after base URL
        var paramsMap = JSON.parse((urlParameters == '') ? '{}' : decodeURIComponent('{"' + urlParamEncoded.replace(new RegExp('&', 'g'), '","').replace(new RegExp('=', 'g'),'":"') + '"}') );
                
        // Get URL parameters
     
            var servName = paramsMap.serviceName;
            var userTypeToCreate = paramsMap.t; //t=1  (for primary) or t=2 (for secondary) 
            var invitationId = paramsMap.token; //Invitation ID
            console.log(invitationId);

            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
                console.log("servname "+servName);
                if(! component.get("v.paramLoaded")) {
                    // Avoid multiple calls
                    component.set("v.paramLoaded", true);
                    var isInvitation = false;
                    if(/\S/.test(invitationId) && invitationId != undefined){
                        isInvitation = true;
                        component.set("v.invitationId", invitationId);
                    }
                    console.log('wwww');
                    console.log(isInvitation);
                    component.set("v.isInvitation", isInvitation)
                    helper.initParams(component, isInvitation, invitationId);
                }
            }
            // If registration comes from FRED (not a guest) by a primary user, I can create another primary or secondary user
            if(/\S/.test(userTypeToCreate) && userTypeToCreate != undefined){
                component.set("v.userTypeToCreate", userTypeToCreate);
            }
           
    },
/**
    When a user type inside the search box
*/
    onKeyUp : function(component, event, helper) {
        // Unvalidate component when user tries to change input        
        component.set("v.isValid", false);
        component.set("v.accountSelected", false);

        if(helper.isMandatoryFieldsOK(component)) {
            component.set("v.searching", true);
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
                if(accountSuggested != undefined && accountSuggested.length > 0) {
                    component.set("v.response", accountSuggested);
                   
                } else {
                    var noResult = {'Name':'No result found...', 'Airline_designator__c':'-', 'ICAO_Member__r.ICAO_Iso_3_Code__c':'-', 'ICAO_Member__r.Name':'-'};
                    if(component.get("v.customerType")=='ICAO Member State')
                        noResult = {'Name':'No result found...', 'ICAO_Iso_2_Code__c':'-', 'ICAO_Iso_3_Code__c':'-'};
                    var suggestions = [];
                    suggestions.push(noResult);
                    component.set("v.response",suggestions);
                }
                // Show suggestion box
                var userInputCmpName = userInputCmp.dataset.value;
                var resultDiv = component.find(userInputCmpName);
                component.set("v.searching", false);
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

    onRender: function(component, event, helper) {
        // Expand div according to suggestion size
        component.set("v.suggestionBoxHeight", component.find("suggestionBoxID").getElement().clientHeight);
    },

    typeOfCustomerChanged: function(component, event, helper) {
        component.set("v.userInput", ""); // Empty input of user
        component.find("typeOfCustomer").set("v.errors", null); // Clear error
        component.set("v.response",[]);
        // Hide suggestion box
        var resultDiv = component.find("agencies");
        if($A.util.hasClass(resultDiv, 'slds-is-open')) {
            $A.util.removeClass(resultDiv, 'slds-is-open');
        }

        if(component.get("v.customerType")=="Aircraft Operator")
            component.set("v.searchPlaceholder","Please enter a Commercial Name");
        else if (component.get("v.customerType")=="ICAO Member State")
            component.set("v.searchPlaceholder","Please enter a State Name, ISO code in 2 or 3 letters");
        else {
            component.set("v.searchPlaceholder","Please enter an Account Name");
        }

    },
    
/**
    When a user select a sugestion from the suggestion box
*/
    suggestionSelected: function(component, event, helper) {
        var suggestionSelected = event.currentTarget;
        var accountIndex = suggestionSelected.dataset.rowIndex;

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

        // If submission is do by a primary
        if(component.get("v.isFredPrimaryUser") && component.get("v.userTypeToCreate") != -1) {
            component.set("v.createPrimary", component.get("v.userTypeToCreate") == 1)
        } 
       var action = component.get("c.registration");
        action.setParams({
            "acc":component.get("v.acc"),
            "con":component.get("v.contact"),
            "selectedCustomerType":component.get("v.customerType"),
            "con":component.get("v.contact"),
            "isGuest" : component.get("v.isGuest"),
            "createPrimary":component.get("v.createPrimary"),
            "userTypeToCreate":component.get("v.userTypeToCreate"),
            "isInvitation":component.get("v.isInvitation")

        });

        action.setCallback(this, function(a) {
            

            var result = a.getReturnValue().success;            
            // redirect to a new page when registration is done
            if(result) {                
                component.getEvent("StepCompletionNotification")
                    .setParams({
                        "stepNumber" : 3,
                        "isComplete" : true,
                         })
                    .fire();

                /*if(component.get("v.isGuest"))
                    window.location.href = "/identity/s/registrationcomplete?serviceName=FRED";
                else {
                    var confirmationPage = '/registrationcomplete?serviceName=FRED';
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                      "url": confirmationPage,
                      "isredirect" :true
                    });
                    urlEvent.fire();
                }*/                
            }
            
            if(!result) {

                console.log(a.getReturnValue());
                //Previous message
                //alert(a.getReturnValue().error);
                var result = confirm(a.getReturnValue().error);
                var txt;
                if (result == true) {
                    window.location.href = 'https://fred.iata.org/contact';
                    txt = 'User redirected...'
                    
                } else {
                    txt = "User canceled the operation...";
                }
                console.log(txt);
                /*
                // Show toast not working as guest (public pages)- Wok only when logged in
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "title": 'Error',
                    "message": a.getReturnValue().error
                });
                toastEvent.fire();
                */
                 console.log('end');
            } 
            $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },

  
    goToContactUs : function(component, event, helper) {
        window.location.href = $A.get("$Label.c.OneId_FRED_ContactUs_Link");
    }
})
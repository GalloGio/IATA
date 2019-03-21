({
    checkUserTrue : function(component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-show');
        var action = component.get("c.checkIfUserExists");      
        var inputEmail = component.find("inputEmail");
        var valueEmail = inputEmail.get("v.value");
        if(valueEmail){
 
            //Clear error
            inputEmail.set("v.errors", null);
            var validEmail = helper.validateEmail(valueEmail);
 
            if(validEmail){
                action.setParams({"email" : valueEmail});
                action.setCallback(this, function(response){
                    var res = response.getReturnValue();
                    if(res){
                        if(res=='FORBID') { // CR1: Check if email is not a disposal email type
                            inputEmail.set("v.errors",[{ message: "Forbidden email address"}]);
                        } else {
                            window.open($A.get('$Label.c.IATA_GDPR_URL')+'/s/confirmation','_top');
                        }
                    }
                });
                $A.enqueueAction(action);
            }else{
                inputEmail.set("v.errors", [{ message: $A.get("$Label.c.ISSP_AMS_Invalid_Email")}]);
            }
        }else{
            // Set error
            inputEmail.set("v.errors", [{message: $A.get("$Label.c.ISSP_EmailError")}]);
        }
    }
})
({
    checkUserTrue : function(component, event, helper) {
 
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-show');
        
        var action = component.get("c.checkIfUserExists");      
        
        var inputEmail = component.find("inputEmail");
 
        var valueEmail = inputEmail.get("v.value");
        console.log('[EMAIL VALUE] - '+valueEmail);
        if(valueEmail){
 
            //Clear error
            inputEmail.set("v.errors", null);
            var validEmail = helper.validateEmail(valueEmail);
            console.log('[EMAIL FORMAT VALID] - '+validEmail);
 
            if(validEmail){
                action.setParams({"email" : valueEmail});
            
                action.setCallback(this, function(response){
                
                    var res = response.getReturnValue();
                    
                    console.log('[USER TYPE] - '+res);
 
                    if(res){
                        window.open($A.get('$Label.c.IATA_GDPR_URL')+'/s/confirmation','_top');
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
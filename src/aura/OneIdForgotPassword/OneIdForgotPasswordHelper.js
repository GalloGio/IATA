({
    handleForgotPassword: function (component, event, helpler) {
        var spinner = component.find("loading");
        $A.util.toggleClass(spinner, "slds-hide");

        console.log('Helper.handleForgotPassword BEGIN');
        
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        console.log('aqui checkEmailUrl ' + checkEmailUrl);
        var action = component.get("c.forgotPassword");

        var serviceName = component.get("v.serviceName");
        if(!$A.util.isEmpty(serviceName)) checkEmailUrl += "?serviceName="+serviceName;

        action.setParams({username:username, checkEmailUrl:checkEmailUrl});
        action.setCallback(this, function(a) {
            console.log('Helper.handleForgotPassword.Callback BEGIN');
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
            else{
                console.log('Helper.handleForgotPassword.Callback: SUCCESS');
            }
            console.log('Helper.handleForgotPassword.Callback END');
            $A.util.toggleClass(spinner, "slds-hide");
       });
        $A.enqueueAction(action);
        
        console.log('Helper.handleForgotPassword END');
    }
})
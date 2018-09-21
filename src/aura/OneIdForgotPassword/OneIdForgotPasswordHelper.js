({
    handleForgotPassword: function (component, event, helpler) {
        var spinner = component.find("loading");
        $A.util.toggleClass(spinner, "slds-hide");

        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var serviceName = component.get("v.serviceName");
        var action = component.get("c.forgotPassword");

        action.setParams({username:username, checkEmailUrl:checkEmailUrl, serviceName:serviceName});
        action.setCallback(this, function(a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue != null) {
               component.set("v.errorMessage",rtnValue);
               component.set("v.showError",true);
            }
            else{
                console.log('Helper.handleForgotPassword.Callback: SUCCESS');
            }
            $A.util.toggleClass(spinner, "slds-hide");
       });
        $A.enqueueAction(action);
    }
})
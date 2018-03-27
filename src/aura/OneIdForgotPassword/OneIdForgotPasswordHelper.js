({
    handleForgotPassword: function (component, event, helpler) {
        console.log('Helper.handleForgotPassword BEGIN');        
        var username = component.find("username").get("v.value");
        var checkEmailUrl = component.get("v.checkEmailUrl");
        var serviceName = component.get("v.serviceName");
        console.log('aqui serviceName ' + serviceName);
        var action = component.get("c.forgotPassword");

        action.setParams({username:username, checkEmailUrl:checkEmailUrl, serviceName:serviceName});
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
       });
        $A.enqueueAction(action);
        
        console.log('Helper.handleForgotPassword END');
    }
})
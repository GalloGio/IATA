({
    initialize: function(component, event, helper) {
        $A.get("e.siteforce:registerQueryEventMap").setParams({"qsToEvent" : helper.qsToEventMap}).fire();   
        
        helper.getIsUsernamePasswordEnabled(component, event, helper);
        helper.getIsSelfRegistrationEnabled(component, event, helper);
        helper.getCommunityForgotPasswordUrl(component, event, helper);
        helper.getCommunitySelfRegisterUrl(component, event, helper);
        helper.getSiteCompleteUrl(component, event, helper);
        
        //helper.getSanctionCountry(component, event, helper, getElementById("clientIpAddressAjax").value);
        //helper.getSanctionCountry(component, event, helper);
        helper.getShow90Days(component, event, helper);
    },
    
    onChangeClientIpAddress: function (component, event, helpler) {
        alert('Change ClientIpAddress');
    },
    
    getClientIpAddress: function(component, event, helper){
        //For now ajax request is synchronous because the getSanctionCountry method needs the ip
        ////TODO: change to use events in order to avoid synchornous deprecated ajax calls
        helper.getClientIpAddressAjax(component, event, helper);
        
        helper.getSanctionCountry(component, event, helper, $("#clientIpAddressAjax").val());
    },
    
    handleLogin: function (component, event, helpler) {
        helpler.handleLogin(component, event, helpler);
    },
    
    setStartUrl: function (component, event, helpler) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helpler){
        //checks for "enter" key
        if (event.getParam('keyCode')===13) {
            helpler.handleLogin(component, event, helpler);
        }
    },
    
    navigateToForgotPassword: function(cmp, event, helper) {
        var forgotPwdUrl = cmp.get("v.communityForgotPasswordUrl");
        if ($A.util.isUndefinedOrNull(forgotPwdUrl)) {
            forgotPwdUrl = cmp.get("v.forgotPasswordUrl");
        }
        var attributes = { url: forgotPwdUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    },
    
    navigateToSelfRegister: function(cmp, event, helper) {
        var selrRegUrl = cmp.get("v.communitySelfRegisterUrl");
        if (selrRegUrl == null) {
            selrRegUrl = cmp.get("v.selfRegisterUrl");
        }
    
        var attributes = { url: selrRegUrl };
        $A.get("e.force:navigateToURL").setParams(attributes).fire();
    }
})
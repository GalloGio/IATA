({
    jsLoaded:function(component, event, helper) {
        console.log('Jquery Loaded...');
        //jq$ = jQuery.noConflict();
        
        $(document).ready(function() {
            //Configure events
			$('#clientIpAddressAjax').change(function(){
                console.log('Handle input Change: clientIpAddressAjax.change.'); 
                
                console.log('onChangeClientIpAddressAjax: call getSanctionCountry on assynchronous call back !!');
                console.log('$("#clientIpAddressAjax").val='+$("#clientIpAddressAjax").val());
                helper.getSanctionCountry(component, event, helper, $("#clientIpAddressAjax").val());
                
                console.log('After action: helper.getSanctionCountry'); 
            }),
            $.getJSON("https://jsonip.com/?callback=?", function (data) {                    
                        //console.log('data.ip ' + data.ip);                    
                        helper.getFindLocation(data.ip,component);
            });
            console.log('JQuery EVENTS Configured...');
         });
         
    },

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
    
   /* getClientIpAddress: function(component, event, helper){
        console.log('getClientIpAddress call getSanctionCountry on Synchronous ip adress get.');
        
        helper.getClientIpAddressAjax(component, event, helper);
        console.log('getClientIpAddress.AFTER AJAX CALL');
        
        //If ajax schyncronous
        console.log('component.v.clientIpAddress='+component.get("v.clientIpAddress"));
        helper.getSanctionCountry(component, event, helper, component.get("v.clientIpAddress"));
    },*/
    
    handleLogin: function (component, event, helper) {
        console.log('handleLogin');
        helper.handleLogin(component, event, helper);
    },
    
    setStartUrl: function (component, event, helper) {
        var startUrl = event.getParam('startURL');
        if(startUrl) {
            component.set("v.startUrl", startUrl);
        }
    },
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if(event.getParams().keyCode == 13){
            helper.handleLogin(component, event, helper);
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
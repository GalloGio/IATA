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
        helper.getIsUsernamePasswordEnabled(component, event, helper);
        helper.getIsSelfRegistrationEnabled(component, event, helper);
        helper.getCommunityForgotPasswordUrl(component, event, helper);
        helper.getCommunitySelfRegisterUrl(component, event, helper);

        
        helper.getShow90Days(component, event, helper);

        $A.get("e.c:oneIdURLParams").setParams({"state":"fetch"}).fire();
        
        setTimeout(function(){
            component.set("v.loaded", true);
        }, 2000);
    },
   
    renderPage : function (component, event, helper){
        var state = event.getParam("state");

        console.info("renderPage - state "+state);
        if(state == "answer"){
            var servName = event.getParam("paramsMap").serviceName;
            var redirect_uri = event.getParam("paramsMap").redirect_uri;
            var startURL = event.getParam("paramsMap").startURL;

            if(/\S/.test(servName)){
                component.set("v.serviceName", servName);
                                
                var labelHelpLink = $A.getReference("$Label.c.OneId_" + servName + "_Troubleshooting_Link");
                var labelHelp = $A.getReference("$Label.c.OneId_" + servName + "_Troubleshooting");
                var labelTerms = $A.getReference("$Label.c.OneId_" + servName + "_Terms_Of_Use_Link");
                component.set("v.labelHelpLink", labelHelpLink);
                component.set("v.labelHelp", labelHelp);
                component.set("v.labelTermsOfUseLink", labelTerms);
            }
            
            if(/mobilesdk/.test(redirect_uri)){
                //prevent redirection
                component.set("v.startURL", 'mobileApp');
            }else if(/\S/.test(startURL)){
                component.set("v.startUrl", startURL);
            }

        }
        
        component.set("v.loaded", true);
    },
    
    handleLogin: function (component, event, helper) {
        helper.handlePreLogin(component, event, helper);
    },

    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        if(event.getParams().keyCode == 13){
	        helper.handlePreLogin(component, event, helper);
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
({
	doInit : function(component, event, helper) {
		helper.getHostURL(component, event);
        helper.getCommunityName(component, event);

         window.addEventListener("message", function(event) {
            var vfOrigin = component.get('v.vfHost');
            var commName = component.get("v.commName");
            if (event.origin !== vfOrigin) {
                // Not the expected origin: Reject the message!
                return;
            }

             if (event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'NOK') {
                var div = component.find("captchaError");
                $A.util.removeClass(div, 'hide');
                component.set("v.Terms", false);
            } else if (event.data.action == 'alohaCallingCAPTCHA' && event.data.alohaResponseCAPTCHA == 'OK') {
                component.set("v.captchaOK", true);
                var div = component.find("captchaError");
                $A.util.addClass(div, 'hide');
                var page2 = component.find('page-2');
                $A.util.removeClass(page2, 'page-invisible');

                // Notify registration component taht step 1 is valid
                helper.notifyStepCompletion(component);
                component.find("email").set("v.disabled", true);
                component.find("termsaccepted").set("v.disabled", true);
                component.set("v.showCaptcha", false);

            } else if (event.data.action == 'iframeResize') {
                if (event.data.alohaCallingCreateAccountOK == 'AccountContactAndUserSuccess' ||
                    event.data.alohaCallingCreateAccountOK == 'ReturnToLogin') {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    //if(confirm("my text here")){
                    setTimeout(function() {
                        urlEvent.setParams({
                            //"url": vfOrigin + '/' + commName + '/s/login/'
                            "url": $A.get("$Label.c.OneId_URL_javaScript") + '/s/login/'
                        });
                        urlEvent.fire();
                    }, 15000);
                    //} 
                } 
                //var thisWidth = jQuery('.cLightningRegistrationProcess').width();
                //var styl = "width:" + thisWidth + "px; height:" + event.data.height + "px;";
                var styl = "height:" + event.data.height + "px;";
                component.set("v.captchaIframeHeight", styl);
                var page2 = component.find('page-2');
                $A.util.addClass(page2, 'page-invisible');
            } else if (event.data.action == 'callIframeResizeCallback') {
                 jQuery('.captchaIframe').removeAttr('height');
                var captchaIframeHeight;
                var numb = 0;
                if(component.get("v.captchaIframeHeight") !== undefined){
                    var asd = component.get("v.captchaIframeHeight");
                    numb = asd.match(/\d/g);
                    numb = numb.join("");
                }
                if (event.data.height == null) {
                    captchaIframeHeight = "height: 0px;";
                } 
                if(event.data.height && event.data.height.length>0){ 
                    captchaIframeHeight = "height:" + event.data.height + "px;";
                }
                component.set("v.captchaIframeHeight", captchaIframeHeight); 
            }
        }, false);
	},

	checkTerms: function(component, event, helper) {
        // Check fields validity
        if (component.get("v.Terms") && helper.validateEmail(component)) {
            var userValid = helper.checkUsername(component);

            // In case of invtation (verifier)
            if(component.get("v.isVerifierInvitation") && userValid)
                helper.notifyStepCompletion(component);

        }
    },

    renderPage : function (component, event, helper){
        // Get URL parameters
        var state = event.getParam("state");       
        if(state == "answer"){
            var invitationId = event.getParam("paramsMap").token; //Verifier Invitation ID
            // When a verifier receive an email from FRED with invitationID (created thru API by FRED in SF) 
            if(/\S/.test(invitationId) && invitationId != undefined){
                // email should be disabled and captcha not visible
                component.find("email").set("v.disabled", true);
                component.set("v.showCaptcha", true);
                component.set("v.isVerifierInvitation", true);
            }
        }
    },
})
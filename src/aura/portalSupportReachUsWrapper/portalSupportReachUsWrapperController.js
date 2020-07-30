({
    doInit: function (component, event, helper) {
        jQuery("document").ready(function () {
        });

    },

    //Begins chat for Online Default option
    startChatDefault: function (component, event, helper) {
		document.cookie = "apex__chatlanguage=" + component.get("v.liveAgentOnlineDefaultIdLanguage") + "; path=/";
        liveagent.startChat(component.get("v.liveAgentOnlineDefault"));
    },

    //Begins chat for selected country language
    startChatWithLanguage: function (component, event, helper) {
		document.cookie = "apex__chatlanguage=" + component.get("v.liveAgentOnlineWithCountryLanguage") + "; path=/";
        liveagent.startChat(component.get("v.liveAgentOnlineWithCountry"));
    },

    //Begins chat for portal language
    startChatNoLanguage: function (component, event, helper) {
		document.cookie = "apex__chatlanguage=" + component.get("v.liveAgentOnlineNoCountryLanguage") + "; path=/";
        liveagent.startChat(component.get("v.liveAgentOnlineNoCountry"));
    },

    //To toggle the spinner
    toggleSpinner: function (component, event, helper) {
        component.set("v.loaded", !component.get('v.loaded'));
    },

    //sets record type and country from web component event
    setRecordTypeAndCountry: function (component, event, helper) {
        var rtAndCountry = JSON.parse(JSON.stringify(event.getParam('recordTypeAndCountry')));
        component.set("v.caseRecordType", rtAndCountry.RecordType);
        component.set("v.country", rtAndCountry.Country);
    },

    //sets contact data from web component event
    setContactInfo: function (component, event, helper) {
        var contactdata = JSON.parse(JSON.stringify(event.getParam('myliveAgentContactInfo')));
        component.set("v.contact", contactdata);
    },

    //prepares live agent chat under many possible cases.
    handleLiveAgentChangeEvent: function (component, event, helper) {
        var data = JSON.parse(JSON.stringify(event.getParam('allData')));
        component.set("v.topic", data.Topic);
        component.set("v.isEmergency", data.Emergency);
        component.set("v.caseRecordType", data.recordTypeAndCountry.RecordType);
        component.set("v.country", data.recordTypeAndCountry.Country);
        component.set("v.countryISO", data.CountryISO);
        component.set("v.contact", data.Contact);
        
        component.set("v.showLAButtons", data.showChat);
        //must disconnect and delete in order to re-deploy
        if ((typeof liveagent == "object")) {
            liveagent.disconnect();
            delete liveagent;
            delete liveAgentDeployment;
        }
        if(data.showChat===true){            
            component.set("v.isTopicLiveAgent", false);
            component.set("v.isNoCountryLiveAgent", false);
            component.set("v.isWithCountryLiveAgent", false);
            data.myliveAgentButtonInfo.forEach(function (laButton) {
                var btnLabel= $A.get("$Label.c.CSP_Chat_base_Label").replace('$0',laButton.Language__c);

                if (laButton.Button_Per_Topic__c == true) {
                    component.set("v.liveAgentOnlineDefault", laButton.ButtonId__c);
                    component.set("v.isTopicLiveAgent", true);
                    component.set("v.liveAgentOnlineDefaultIdLanguage", btnLabel);
                    component.set("v.liveAgentOnlineDefaultName", laButton.Name);
                } else if (laButton.Language__c == "English") {
                    component.set("v.liveAgentOnlineNoCountry", laButton.ButtonId__c);
                    component.set("v.isNoCountryLiveAgent", true);
                    component.set("v.liveAgentOnlineNoCountryLanguage", btnLabel);
                    component.set("v.liveAgentOnlineNoCountryName", laButton.Name);
                }
                if (!laButton.Button_Per_Topic__c && laButton.Language__c != "English") {
                    component.set("v.liveAgentOnlineWithCountry", laButton.ButtonId__c);
                    component.set("v.isWithCountryLiveAgent", true);
                    component.set("v.liveAgentOnlineWithCountryLanguage", btnLabel);
                    component.set("v.liveAgentOnlineWithCountryName", laButton.Name);
                }
            });
            
            //re-deploys live agent
            jQuery.getScript(component.get("v.deploymentUrl"))
            .done(function (script, textStatus) {
                helper.liveAgentDefaultHandler(component, event);
            })
            .fail(function (jqxhr, settings, exception) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": $A.get("$Label.c.csp_LiveAgentBadConfig"),
                    "type": "Error"
                });
                toastEvent.fire();
            });
        }
    },  
})
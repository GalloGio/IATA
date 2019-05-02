({
    doInit: function (component, event, helper) {
        jQuery("document").ready(function () {
            console.log('Scripts loaded');
        });
    },

    startChatDefault: function (component, event, helper) {
        liveagent.startChat(component.get("v.liveAgentOnlineDefault"));
    },

    startChatWithLanguage: function (component, event, helper) {
        liveagent.startChat(component.get("v.liveAgentOnlineWithCountry"));
    },

    startChatNoLanguage: function (component, event, helper) {
        liveagent.startChat(component.get("v.liveAgentOnlineNoCountry"));
    },

    showoptions: function (component, event, helper) {
        component.set("v.showOptions", true);
    },

    closeoptions: function (component, event, helper) {

        component.set("v.showOptions", false);
        component.set("v.isWithCountryLiveAgent", false);
        component.set("v.liveAgentOnlineWithCountry", '');
        component.set("v.isNoCountryLiveAgent", false);
        component.set("v.liveAgentOnlineNoCountry", '');
        component.set("v.isTopicLiveAgent", false);
        component.set("v.liveAgentOnlineDefault", '');

    },

    toggleSpinner: function (component, event, helper) {
        component.set("v.loaded", !component.get('v.loaded'));
    },

    handlefilterChangeEvent: function (component, event, helper) {
        var data = JSON.parse(JSON.stringify(event.getParam('myliveAgentButtonInfo')));
        console.log(data);
        if ((typeof liveagent == "object")) {
            liveagent.disconnect();
            delete liveagent;
            delete liveAgentDeployment;
        }

        data.forEach(function (laButton) {
            if (laButton.Button_Per_Topic__c == true) {
                component.set("v.liveAgentOnlineDefault", laButton.ButtonId__c);
                component.set("v.isTopicLiveAgent", true);
                component.set("v.liveAgentOnlineDefaultIdLanguage", laButton.Language__c.toUpperCase());
            } else if (laButton.Language__c == "EN" || laButton.Language__c == "en") {
                component.set("v.liveAgentOnlineNoCountry", laButton.ButtonId__c);
                component.set("v.isNoCountryLiveAgent", true);
                component.set("v.liveAgentOnlineNoCountryLanguage", laButton.Language__c.toUpperCase());
            }
            if (!laButton.Button_Per_Topic__c && (laButton.Language__c != "EN" || laButton.Language__c != "en")) {
                component.set("v.liveAgentOnlineWithCountry", laButton.ButtonId__c);
                component.set("v.isWithCountryLiveAgent", true);
                component.set("v.liveAgentOnlineWithCountryLanguage", laButton.Language__c.toUpperCase());
            }
        });

        jQuery.getScript(component.get("v.deploymentUrl"))
            .done(function (script, textStatus) {
                helper.liveAgentDefaultHandler(component, event);
            })
            .fail(function (jqxhr, settings, exception) {
                console.log(exception);
            });
    },
})
({
    doInit: function (component, event, helper) {
        jQuery("document").ready(function () {
        });

    },

    //Begins chat for Online Default option
    startChatDefault: function (component, event, helper) {
        liveagent.startChat(component.get("v.liveAgentOnlineDefault"));
    },

    //Begins chat for selected country language
    startChatWithLanguage: function (component, event, helper) {
        liveagent.startChat(component.get("v.liveAgentOnlineWithCountry"));
    },

    //Begins chat for portal language
    startChatNoLanguage: function (component, event, helper) {
        liveagent.startChat(component.get("v.liveAgentOnlineNoCountry"));
    },

    //Opens the Options panel
    showOptions: function (component, event, helper) {
        component.set("v.showOptions", true);
    },

    //Closes the Options panel and resets variables to their default value
    closeOptions: function (component, event, helper) {

        component.set("v.showOptions", false);
        component.set("v.isWithCountryLiveAgent", false);
        component.set("v.liveAgentOnlineWithCountry", '');
        component.set("v.isNoCountryLiveAgent", false);
        component.set("v.liveAgentOnlineNoCountry", '');
        component.set("v.isTopicLiveAgent", false);
        component.set("v.liveAgentOnlineDefault", '');

    },

    //To toggle the spinner
    toggleSpinner: function (component, event, helper) {
        component.set("v.loaded", !component.get('v.loaded'));
    },

    //Sets the topic and subtopic from web component event
    setTopicSubtopic: function (component, event, helper) {
        var categoriesData = JSON.parse(JSON.stringify(event.getParam('categorization')));
        component.set("v.topic", categoriesData.Topic);
        component.set("v.subTopic", categoriesData.SubTopic);
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
        component.set("v.category", data.categorization.Category);
        component.set("v.topic", data.categorization.Topic);
        component.set("v.subTopic", data.categorization.SubTopic);
        component.set("v.isEmergency", data.Emergency);
        component.set("v.caseRecordType", data.recordTypeAndCountry.RecordType);
        component.set("v.country", data.recordTypeAndCountry.Country);
        component.set("v.countryISO", data.CountryISO);
        component.set("v.contact", data.Contact);
        component.set("v.isQuestion", data.Question);
        component.set("v.phoneNumber", data.PhoneNumber);

        if (component.get("v.isEmergency") == false && (component.get("v.phoneNumber") == undefined || component.get("v.phoneNumber") == '')) {
            component.set("v.showPhoneNumber", false);
        } else {
            component.set("v.showPhoneNumber", true);
        }

        //must disconnect and delete in order to re-deploy
        if ((typeof liveagent == "object")) {
            liveagent.disconnect();
            delete liveagent;
            delete liveAgentDeployment;
        }
        if (data.Emergency) {
            var emergency = $A.get("$Label.c.LVA_CallUsThruPhoneNum") + '\n'
                + $A.get("$Label.c.LVA_CallUsEmergencyPhoneNumber") + '\n\n'
                + $A.get("$Label.c.LVA_CallUsAvailableHours") + '\n'
                + $A.get("$Label.c.LVA_CallUsEmergencyAvailableHours") + '\n';
            component.set("v.callCenterInfo_Label", emergency);
        } else {
            var emergency2 = $A.get("$Label.c.LVA_CallUsThruPhoneNum") + '\n'
                + component.get("v.phoneNumber").PhoneNumber + '\n\n'
                + $A.get("$Label.c.LVA_CallUsAvailableHours") + '\n'
                + component.get("v.phoneNumber").AvailableHours + '\n';
            component.set("v.callCenterInfo_Label", emergency2);
        }

        if(data.myliveAgentButtonInfo && data.myliveAgentButtonInfo.length > 0){
            component.set("v.showLAButtons", true);
        }else{
            component.set("v.showLAButtons", false);
        }

        data.myliveAgentButtonInfo.forEach(function (laButton) {
            if (laButton.Button_Per_Topic__c == true) {
                component.set("v.liveAgentOnlineDefault", laButton.ButtonId__c);
                component.set("v.isTopicLiveAgent", true);
                component.set("v.liveAgentOnlineDefaultIdLanguage", laButton.Language__c.toUpperCase());
                component.set("v.liveAgentOnlineDefaultName", laButton.Name);
            } else if (laButton.Language__c == "EN" || laButton.Language__c == "en") {
                component.set("v.liveAgentOnlineNoCountry", laButton.ButtonId__c);
                component.set("v.isNoCountryLiveAgent", true);
                component.set("v.liveAgentOnlineNoCountryLanguage", laButton.Language__c.toUpperCase());
                component.set("v.liveAgentOnlineNoCountryName", laButton.Name);
            }
            if (!laButton.Button_Per_Topic__c && (laButton.Language__c != "EN" && laButton.Language__c != "en")) {
                component.set("v.liveAgentOnlineWithCountry", laButton.ButtonId__c);
                component.set("v.isWithCountryLiveAgent", true);
                component.set("v.liveAgentOnlineWithCountryLanguage", laButton.Language__c.toUpperCase());
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
    },

    redirectCreateCase: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var country = (component.get("v.countryISO") == '' ? '' : '&countryISO=' + component.get("v.countryISO"));
        urlEvent.setParams({
            "url": "/support-reach-us-create-new-case?category=" + component.get("v.category")
                + '&topic=' + component.get("v.topic")
                + '&subtopic=' + component.get("v.subTopic")
                + country
                + '&concerncase=' + !component.get("v.isQuestion")
                + '&emergency=' + component.get("v.isEmergency")
        });
        urlEvent.fire();
    },
})
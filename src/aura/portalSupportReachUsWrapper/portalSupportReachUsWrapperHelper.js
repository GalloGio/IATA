({

    liveAgentDefaultHandler: function (component, event) {
        liveagent.enableLogging();
        if ((typeof liveagent === "object")) {

            if (component.get("v.isTopicLiveAgent")) {
                liveagent.showWhenOnline(component.get("v.liveAgentOnlineDefault"), document.getElementById("liveAgentOnlineDefaultId"));
                liveagent.showWhenOffline(component.get("v.liveAgentOnlineDefault"), document.getElementById("liveAgentOfflineDefaultId"));
            }
            if (component.get("v.isNoCountryLiveAgent")) {
                liveagent.showWhenOnline(component.get("v.liveAgentOnlineNoCountry"), document.getElementById("liveAgentOnlineNoCountryId"));
                liveagent.showWhenOffline(component.get("v.liveAgentOnlineNoCountry"), document.getElementById("liveAgentOfflineNoCountryId"));
            }
            if (component.get("v.isWithCountryLiveAgent")) {
                liveagent.showWhenOnline(component.get("v.liveAgentOnlineWithCountry"), document.getElementById("liveAgentOnlineWithCountryId"));
                liveagent.showWhenOffline(component.get("v.liveAgentOnlineWithCountry"), document.getElementById("liveAgentOfflineWithCountryId"));
            }

            liveagent.init(component.get("v.endpoint"), component.get("v.deploymentId"), component.get("v.organizationId"));

        } else {
            console.log('CTRL timeout to init live agent');
        }
    }
})
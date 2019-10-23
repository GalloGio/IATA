({
    //Live agent handler to fully initiate the correct live agent
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

            var date = new Date();
            var userContact = component.get("v.contact");
            var topicLabel = component.get("v.topic");
            var subTopicLabel = component.get("v.subTopic");
            var caseRecordTypeId = component.get("v.caseRecordType");
            var country = component.get("v.country");
            var isEmergency = component.get("v.isEmergency");

            liveagent.setName(userContact.FirstName);
            liveagent.enableLogging();
            liveagent.addCustomDetail('#Contact', userContact.Name);
            liveagent.addCustomDetail('#Account', userContact.Account.Name);
            liveagent.addCustomDetail('#Sector', userContact.Account.Sector__c == undefined ? '' : userContact.Account.Sector__c);
            liveagent.addCustomDetail('#Category', userContact.Account.Category__c == undefined ? '' : userContact.Account.Category__c);
            liveagent.addCustomDetail('Case Subject', 'Chat with IATA Customer Service ' + (date.getMonth() + 1) + '/' + date.getDate() + '/' + date.getFullYear());
            liveagent.addCustomDetail('#Topic', topicLabel);
            liveagent.addCustomDetail('#Subtopic', subTopicLabel);
            liveagent.addCustomDetail('Case Status', 'Open');
            liveagent.addCustomDetail('Case Origin', 'Chat');
            liveagent.addCustomDetail('Case Priority', isEmergency ? 'Emergency':'Normal');
            liveagent.addCustomDetail('userContactId', userContact.Id);
            liveagent.addCustomDetail('userAccountId', userContact.Account.Id);
            liveagent.addCustomDetail('caseRTId', caseRecordTypeId);
            liveagent.addCustomDetail('caseCountryConcerned', country).saveToTranscript('Country_Concerned__c');
            //liveagent.addCustomDetail('buttonlanguage', '{!buttonLanguage}');
            liveagent.addCustomDetail('#TopicEN', topicLabel).saveToTranscript('Topic__c');
            liveagent.addCustomDetail('#SubtopicEN', subTopicLabel).saveToTranscript('Subtopic__c');

            liveagent.findOrCreate('Case')
                .map('RecordTypeId', 'caseRTId', false, true, true)
                .map('Origin', 'Case Origin', false, true, true)
                .map('Status', 'Case Status', false, true, true)
                .map('Subject', 'Case Subject', false, true, true)
                .map('Country_concerned_by_the_query__c', 'caseCountryConcerned', false, true, true)
                .map('Priority', 'Case Priority', false, true, true)
                .map('Topic__c', '#TopicEN', false, true, true)
                .map('Subtopic__c', '#SubtopicEN', false, true, true)
                .showOnCreate()
                .saveToTranscript('Case');
            liveagent.findOrCreate('Contact').map('Id', 'userContactId', true, true, false).linkToEntity('Case', 'ContactId').saveToTranscript('Contact');
            liveagent.findOrCreate('Account').map('Id', 'userAccountId', true, true, false).linkToEntity('Case', 'AccountId').saveToTranscript('Account');
            liveagent.setChatWindowHeight(680);
            liveagent.setChatWindowWidth(400);
            liveagent.init(component.get("v.endpoint"), component.get("v.deploymentId"), component.get("v.organizationId"));

        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "message": $A.get("$Label.c.csp_LiveAgentTimeout"),
                "type": "Error"
            });
            toastEvent.fire();
        }
    }
})
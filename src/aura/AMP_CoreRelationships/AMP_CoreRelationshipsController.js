({
	doInit : function(component, event, helper) {
		var act = component.get("c.getGroups");
		var action = component.get("c.getParticipants");
		var accountId = component.get("v.accountId");

var account = component.get("v.account");
console.log(JSON.stringify(account));

		action.setParams({
		 		"accountId": accountId
	 	});
	 	act.setCallback(this, function(a) {
			var groups = a.getReturnValue();
			var state = a.getState();

			if (component.isValid() && state === "SUCCESS") {
				component.set("v.Groups", groups);
		 }
		// 		 else if (state === "ERROR") {}
		});

	 	action.setCallback(this, function(a) {
        var participants = a.getReturnValue();
		// var groupNames = component.get("v.GroupNames");
		var groups = component.get("v.Groups");
        // console.log(JSON.stringify(participants));
        var state = a.getState();
        var ParticipantWrappers = new Array();
        // var ParticipantWrappers = component.get("v.ParticipantWrappers");
        if (component.isValid() && state === "SUCCESS") {
					for(var j = 0; j < groups.length; j++) {
						var found = false;
						for(var i = 0; i < participants.length; i++) {
							 if(participants[i].Local_Governance__c === groups[j].Id) {
								found = true;
								var pWrapper = {
									GroupId : participants[i].Local_Governance__c,
									GroupName : participants[i].Local_Governance__r.Name,
									Role : participants[i].Participant_Type__c.replace(/^\d+\s/,''),
									Salutation : participants[i].Contact__r.Salutation,
									FirstName : participants[i].Contact__r.FirstName,
									LastName : participants[i].Contact__r.LastName,
									Title : participants[i].Contact__r.Title,
									Representing : participants[i].Representing__c
								};
								if(pWrapper.Representing !== undefined) {
								   console.log('rep');
								   component.set("v.representativesFound", true);
								}
								ParticipantWrappers.push(pWrapper);
							 }
							//  console.log(ParticipantWrappers[j].groupName);
						}
						if(!found ) {
							var pWrapper = {
								GroupId : groups[j].Id,
								GroupName : groups[j].Name,
								Role : 'Not at this time'
							};
							ParticipantWrappers.push(pWrapper);
						}

					 }
				}
					// 		component.set("v.Participants", participants);
				component.set("v.ParticipantWrappers", ParticipantWrappers);

		// 		 else if (state === "ERROR") {}
		 	});
			$A.enqueueAction(act);
			$A.enqueueAction(action);

	}
})
({
	doInit : function(component, event, helper) {
		var act = component.get("c.getGroupNames");
		var action = component.get("c.getParticipants");
		var accountId = component.get("v.accountId");

var account = component.get("v.account");
console.log(JSON.stringify(account));

		action.setParams({
		 		"accountId": accountId
	 	});
	 	act.setCallback(this, function(a) {
			var groupNames = a.getReturnValue();
			var state = a.getState();

			if (component.isValid() && state === "SUCCESS") {
				component.set("v.GroupNames", groupNames);
		 }
		// 		 else if (state === "ERROR") {}
		});

	 	action.setCallback(this, function(a) {
        var participants = a.getReturnValue();
				var groupNames = component.get("v.GroupNames");
        // console.log(JSON.stringify(participants));
        var state = a.getState();
        var ParticipantWrappers = new Array();
        // var ParticipantWrappers = component.get("v.ParticipantWrappers");
        if (component.isValid() && state === "SUCCESS") {
					for(var j = 0; j < groupNames.length; j++) {
						var found = false;
						for(var i = 0; i < participants.length; i++) {
							 if(participants[i].Local_Governance__r.Name === groupNames[j]) {
								found = true;
								var pWrapper = {
									GroupId : participants[i].Local_Governance__c,
									GroupName : participants[i].Local_Governance__r.Name,
									Role : participants[i].Participant_Type__c.replace(/^\d+\s/,''),
									Salutation : participants[i].Contact__r.Salutation,
									FirstName : participants[i].Contact__r.FirstName,
									LastName : participants[i].Contact__r.LastName,
									Title : participants[i].Contact__r.Title
								};
								ParticipantWrappers.push(pWrapper);
							 }
							//  console.log(ParticipantWrappers[j].groupName);
						}
						if(!found ) {
							var pWrapper = {
							 GroupName : groupNames[j],
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
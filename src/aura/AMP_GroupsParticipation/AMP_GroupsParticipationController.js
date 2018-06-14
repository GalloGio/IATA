({
	doInit : function(component, event, helper) {
		helper.getReportId(component);
		var action = component.get("c.getParticipants");
		var accountId = component.get("v.accountId");


		action.setParams({
				"accountId": accountId
			});
			action.setCallback(this, function(a) {
				 var participants = a.getReturnValue();

				 var state = a.getState();
				 var ParticipantWrappers = new Array();
				 if (component.isValid() && state === "SUCCESS") {
					 var previousName = '';
                     var previousUnder = '';
					 for(var i = 0; i < participants.length; i++) {
						 var rowspan = 1;
						 if(i+1 < participants.length) {
							 for(var j=i+1; j < participants.length; j++) {
								 if(participants[i].Local_Governance__r.Name == participants[j].Local_Governance__r.Name) {
									 rowspan++;
								 }
							 }
						 }

						 if(i>0 && participants[i].Local_Governance__r.Name == participants[i-1].Local_Governance__r.Name) {
							 rowspan = 0;
						 }

						//  if(i+1 < participants.length &&
						// 	 participants[i+1].Local_Governance__r.Name == participants[i].Local_Governance__r.Name) {
						// 		 console.log('sama');
						// 	 }
						// 	 if(i>0 && participants[i+1].Local_Governance__r.Name == participants[i].Local_Governance__r.Name) {
						//
						// 	 }
						var currentUnder = participants[i].Local_Governance__r.AM_Under__r.Name;
						var ownerName = '';
						if(participants[i].Local_Governance__r.Group_Owner__r !== undefined) {
							ownerName = participants[i].Local_Governance__r.Group_Owner__r.Name;
						}

						 var pWrapper = {
							 Rowspan : rowspan,
                             Under : previousUnder != currentUnder ? currentUnder : '',
							 GroupId : participants[i].Local_Governance__c,
							 GroupName : participants[i].Local_Governance__r.Name,
							 GroupOwner : ownerName != '' ? ownerName : participants[i].Local_Governance__r.Group_Owner_Text__c,
							 Mission : participants[i].Local_Governance__r.Mission__c,
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
                         previousUnder = currentUnder;
					 }

						// component.set("v.participants", participants);

						component.set("v.ParticipantWrappers", ParticipantWrappers);

				 }
				 else if (state === "ERROR") {}
			});
			$A.enqueueAction(action);
	},
	jsLoaded : function(component, event, helper) {}
})
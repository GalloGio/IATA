({
    doInit: function(component, event, helper) {       
        var action = component.get("c.getParticipantWrappers");
        var accountId = component.get("v.accountId");

        var account = component.get("v.account");        

        action.setParams({
            "accountId": accountId
        });

        action.setCallback(this, function(a) {
            var participants = a.getReturnValue();
            var state = a.getState();            

            var ParticipantWrappers = new Array();

            if (component.isValid() && state === "SUCCESS") {
                for (var j = 0; j < participants.length; j++) {
                    if (!participants[j].found) {
                        var pWrapper = {
                            GroupId: participants[j].groupId,
                            GroupName: participants[j].groupName,
                            Role: 'Not at this time'
                        };
						console.log('pWrapper -- ' + pWrapper);
						ParticipantWrappers.push(pWrapper);
					}
					else{
						var pWrapper = {
							GroupId: participants[j].groupId,
							GroupName: participants[j].groupName,
							Role: participants[j].role.replace(/^\d + \s/, ''),
							Salutation: participants[j].salutation,
							FirstName: participants[j].firstName,
							LastName: participants[j].lastName,
							Title: participants[j].title,
							Representing: participants[j].representing
							};
						console.log('pWrapper -- ' + pWrapper);
						ParticipantWrappers.push(pWrapper);
					} 				
                }
            }
            component.set("v.ParticipantWrappers", ParticipantWrappers);
            // 		 else if (state === "ERROR") {}
        });
        
        $A.enqueueAction(action);
    }
})
({

	getUserInformation: function(cmp) {
        var action = cmp.get("c.getUserInformation");
        action.setParams({
			"serviceName": cmp.get("v.serviceName")
		});
		action.setCallback(this, function(resp) {
			var params = resp.getReturnValue();
            console.log('ooo'+params);
            cmp.set("v.isGuest", params.isGuest);
            cmp.set("v.isServiceUser", params.isServiceUser);
            cmp.set("v.isServiceEligible", params.isServiceEligible);
        });
		$A.enqueueAction(action);
	},
    
     openStep: function(cmp, step) {
         var section = 'section'+step;
        var sec = cmp.find(section);
         
        if(! $A.util.hasClass(sec, "slds-is-open")) {
            $A.util.removeClass(cmp.find('section1'), 'slds-is-open');
            $A.util.removeClass(cmp.find('section2'), 'slds-is-open');
            $A.util.removeClass(cmp.find('section3'), 'slds-is-open');
            $A.util.toggleClass(sec, 'slds-is-open');
        }
        cmp.set("v.activeSection", step);
     },

      loadInvitationInfo: function(cmp, invitationId) {
          // Get invitation info and fill fiels but let it editable
              var action = cmp.get("c.loadInvitationInfo");
                  action.setParams({            
                  "invitationId": invitationId
              });
              action.setCallback(this, function(resp) {
                var invitationWrap = resp.getReturnValue();
                // Fill contact
                cmp.set("v.contact", invitationWrap);
                //cmp.set("v.account", invitationWrap.account);
              });
              $A.enqueueAction(action);
        },
})
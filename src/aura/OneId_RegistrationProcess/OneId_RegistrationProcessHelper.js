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
            if(cmp.get("v.serviceName") == 'NDCMM' && !params.isGuest){
                cmp.set("v.contact", params.con);
                cmp.set("v.account", params.acc);
           }
        });
		$A.enqueueAction(action);
	},

     openStep: function(cmp, step) {
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
                //Fill accountId for GADM
                let accountId = invitationWrap.AccountId;
                let serviceName = cmp.get('v.serviceName');
                if(! $A.util.isEmpty(accountId) && serviceName === 'GADM') {
                    cmp.set('v.gadmAccountId', accountId);
                }
              });
              $A.enqueueAction(action);
        },

      redirectToCustomerPortal : function(component, event) {
          var action = component.get("c.getCustomerPortalUrl");

          action.setCallback(this, function(a){
              var rtnValue = a.getReturnValue();
              if (rtnValue !== null && rtnValue !== undefined) {
                  window.location.href = rtnValue;
              }
          });
          $A.enqueueAction(action);

      },
})
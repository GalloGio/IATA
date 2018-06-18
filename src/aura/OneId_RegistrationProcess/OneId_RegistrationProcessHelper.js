({
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

      loadVerifierInfo: function(cmp, invitationId) {
          // Get invitation info and fill fiels but let it editable
              var action = cmp.get("c.loadVerifierInfo");
                  action.setParams({            
                  "invitationId": invitationId
              });
              action.setCallback(this, function(resp) {
                var verifierWrap = resp.getReturnValue();
                // Fill contact
                cmp.set("v.contact", verifierWrap);
                //cmp.set("v.account", verifierWrap.account);
              });
              $A.enqueueAction(action);
        },
})
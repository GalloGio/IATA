({
	doInit : function(c, e, h) {
    	h.contactLabels(c);
    	h.jobFunctionOptions(c);    	
	},

    jsLoaded: function(c, e, h){
        // if jsloads and we have a country, place flags
        var country = c.get("v.userCountry");
        c.set("v.hasJquery", true);
        if(!$A.util.isEmpty(country)) h.placePhoneFlags(country);
    },

    changedCountry : function(c, e , h){
        if(c.get("v.hasJquery")) h.placePhoneFlags(c.get("v.userCountry"));
    },
    
    validateNumber : function(c, e, h){
        var input = c.find(e.getSource().getLocalId());
        input.set("v.value", input.get("v.value").replace(/[^0-9+]|(?!^)\+/g, ''));
    },

	checkCompletion : function(c, e, h) {
		
		// When notify check if all fields are filled
		if(h.checkRequiredFields(c)) {
			var cmpEvent = c.getEvent("StepCompletionNotification");
            cmpEvent.setParams({
                "stepNumber" : 2,
                "isComplete" : true,
                 });
            cmpEvent.fire();
		}
	},

	checkPowerUser : function(component, event) {
	    let isPowerUser = event.getSource().get('v.value');
	    let gadmPowerUserEvent = component.getEvent('GADM_PowerUser');
	    gadmPowerUserEvent.setParams({
	        'isPowerUser' : isPowerUser
        });
        gadmPowerUserEvent.fire();
    },

    loadInvitation : function(component, event, helper) {
        let invitationId = event.getParam('value');
        let serviceName = component.get('v.serviceName');
        if(! $A.util.isEmpty(invitationId) && serviceName === 'GADM') {
            helper.getInvitationDetails(component, invitationId);
        }

    },

})
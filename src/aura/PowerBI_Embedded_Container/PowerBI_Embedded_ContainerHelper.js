({
	toggleSpinner : function(component, event) {
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    },

})
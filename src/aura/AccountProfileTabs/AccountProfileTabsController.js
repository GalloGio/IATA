({
	toggleTab: function(component, event, helper) {
    	$A.util.toggleClass(element, "slds-tabs__content slds-show");//Note element can be found using find function for with your aura Id
    },
    toggle : function(component, event, helper) {
        //var toggleText = component.find("text");
        //$A.util.toggleClass(toggleText, "toggle");
        var src = event.getSource();
        alert("Source: " + src);
    }

})
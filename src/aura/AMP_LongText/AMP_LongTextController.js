({
	showMore : function(component, event, helper) {
        var text = component.find("text");
        $A.util.removeClass(text, 'slds-truncate');
        $A.util.addClass(text, 'popup');
        component.set("v.truncate",false);
        var showMore = component.find("show-more-button");
        $A.util.addClass(showMore, 'slds-hide');
        var showLess = component.find("show-less-button");
        $A.util.removeClass(showLess, 'slds-hide');
        $A.util.addClass(showLess, 'popup-button');
    },
    showLess : function(component, event, helper) {
        var text = component.find("text");
        $A.util.addClass(text, 'slds-truncate');
        $A.util.removeClass(text, 'popup');
		component.set("v.truncate",true);
        var showMore = component.find("show-more-button");
        $A.util.removeClass(showMore, 'slds-hide');
        var showLess = component.find("show-less-button");
        $A.util.addClass(showLess, 'slds-hide');
        $A.util.removeClass(showLess, 'popup-button');
    }
})
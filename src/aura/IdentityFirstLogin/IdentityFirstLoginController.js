({
	doInit : function(component, event, helper) {
console.log('doInit');
        console.log('window.location.pathname ' + window.location.pathname);
        var sPageURL = 'padding'+ window.location;
        console.log('sPageURL ' + sPageURL);
        var action = component.get("c.checkLogin");
        action.setParams({ data : sPageURL });
        action.setCallback(this, function(a) {
            var results = a.getReturnValue();
            console.log('results' + results);
        });
        console.log('depois');
        $A.enqueueAction(action);
	}
})
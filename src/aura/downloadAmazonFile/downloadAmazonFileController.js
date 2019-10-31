({
    doInit : function(component, event, helper) {
        
        var getExpiringLinkAction = component.get("c.getExpiringLinkWithRecId");
        getExpiringLinkAction.setParams({
            "recId": component.get("v.recordId")
        });
        getExpiringLinkAction.setCallback(this, function (response1) {
            var state = response1.getState();
            if (state === "SUCCESS") {
                var link = response1.getReturnValue().replace("&amp;", "&");

                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": link
                });
                
                urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(getExpiringLinkAction);
        

    }
})

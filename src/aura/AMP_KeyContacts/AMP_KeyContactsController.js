({
	doInit: function(component, event, helper) {
	 //Fetch the expense list from the Apex controller
	//  helper.getContactList(component);
	 var action = component.get("c.getKeyContacs");
	 var accountId = component.get("v.accountId");
	 action.setParams({
				 "AccountId": accountId
			 });
			 action.setCallback(this, function(a) {
					 component.set("v.contacts", a.getReturnValue());
			 });
			 $A.enqueueAction(action);
}
})
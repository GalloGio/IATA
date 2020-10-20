({
	myAction : function(component, event, helper) {
		
	},
  handleFilterChange: function(component, event) {
    let action = event.getParam('action');
    let cmpTarget = component.find('attachmentContainer');
    $A.util.toggleClass(cmpTarget, 'attachmentsClosed');
  }
})
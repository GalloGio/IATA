({
   init : function(component, event, helper) {
      
      helper.populateTable(component, event, helper);
   },
    
   handleMenuSelect: function(component, event, helper) {
      // Figure out which action was selected
    
      var interviewAction = event.getParam("value").split(".");
     
      if(interviewAction.includes("resume")) {
         helper.handleFlow(component, interviewAction[0], "resume");
      } else if(interviewAction.includes("delete")) {
         helper.handleDelete(component, event, helper, interviewAction[0]);
      } else if(interviewAction.includes("start")) {
         helper.handleFlow(component, interviewAction[0], "start");
      }
   },
   
    
   statusChange : function (component, event) {
   		if(event.getParam("status") === "FINISHED") {
      		var outputVariables = event.getParam("outputVariables");
      		var outputVar;
      		for(var i = 0; i < outputVariables.length; i++) {
        		outputVar = outputVariables[i];
         		if(outputVar.name === "CaseId") {
            		var urlEvent = $A.get("e.force:navigateToSObject");
            		urlEvent.setParams({
               			"recordId": outputVar.value,
               			"isredirect": "true"
            		});       
         		}
      		}
            urlEvent.fire();
   		}
	}
})
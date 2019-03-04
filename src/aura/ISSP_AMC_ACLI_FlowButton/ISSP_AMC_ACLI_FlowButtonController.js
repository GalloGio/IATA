({
    doInit : function (component, event, helper) {
        var action = component.get("c.getStageWithStatusMap");

        action.setParams({ "processOrchestratorId" : component.get("v.processOrchestratorId") });

        var self = this;

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var currentStage = component.get("v.stage");
                var splitStages = currentStage.split(":");
                var finalStage = splitStages[splitStages.length-1].replace('_', ' ');
                component.set("v.stage", finalStage);

                var returnValue = response.getReturnValue();
                var stageA_Status = "";
                var stageB_Status = "";
                var stageC_Status = "";
                var stageD_Status = "";
                var stageE_Status = "";
                var stageF_Status = "";

                for(var specialKey in returnValue){
                    var keyMap = specialKey.split("#");
                    var key = keyMap[0];
                    // key is Stage
                    // returnValue[key] is the Status
                    if(key == "STAGE A"){
                        stageA_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE B"){
                        stageB_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE C"){
                        stageC_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE D"){
                        stageD_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE E"){
                        stageE_Status = returnValue[specialKey];
                    }
                    else if (key == "STAGE F"){
                        stageF_Status = returnValue[specialKey];
                    }
                }

                if((stageA_Status != "Completed" ||
                     stageB_Status != "Completed" ||
                     stageC_Status != "Completed" ||
                     stageD_Status != "Completed" ||
                     stageE_Status != "Completed")){
                    component.set("v.assignmentLetterVariant", "destructive");
                }
                else {
                    component.set("v.assignmentLetterVariant", "neutral");
                }

                if((stageA_Status != "Completed" ||
                     stageB_Status != "Completed" ||
                     stageC_Status != "Completed")){
                    component.set("v.requestApprovalVariant", "destructive");
                }
                else {
                    component.set("v.requestApprovalVariant", "neutral");
                }

                // You would typically fire a event here to trigger
                // client-side notification that the server-side
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                 var action2 = component.get("c.disableButton");

               action2.setParams({ "caseId" : component.get("v.caseRecordId")});
               action2.setCallback(self, function(response) {
               var state = response.getState();

               if (state === "SUCCESS") {
                   var options =  response.getReturnValue();
                   if(options == false){
                       component.set("v.sendCaseVariant", "neutral");
                   }
               }
               else {
                   console.log("Failed with state: " + response.getError()[0].message);
               }
               //var appEvent = $A.get("e.c:ISSP_AMC_RefreshProgressEvent");
               //appEvent.fire();
               });

               $A.enqueueAction(action2);
        });

        $A.enqueueAction(action);
    },

	requestApproval : function(component, event, helper) {
        var action = component.get("c.requestForApproval");

        action.setParams({ 
            "processOrchestratorId" : component.get("v.processOrchestratorId"),
            "stage" : component.get("v.stage")
        });


        action.setCallback(this, function(response) {
    		component.find('notifLib').showNotice({
                "variant": "info",
                "header": "Request for Approval",
                "message": "The case was requested for approval.",
                closeCallback: function() {
                    //$A.get('e.force:refreshView').fire();
                }
            });
            $A.get('e.force:refreshView').fire();
        });

        $A.enqueueAction(action);
	},

	createRelatedCase : function(component, event, helper) {
        component.set("v.showSpinner",true);

         var action = component.get("c.createRelatedCases");
         
         action.setParams({ "caseId" : component.get("v.caseRecordId"),
                            "stage" : component.get("v.stage")});
            action.setCallback(this, function(response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    helper.showToast("success", "Case created with sucess");
                }
                else {
                    console.log("Failed with state: " + response.getError()[0].message);
                }
                $A.get('e.force:refreshView').fire();
                 component.set("v.showSpinner",false);
            });

            $A.enqueueAction(action);
        /*component.find('notifLib').showNotice({
            "variant": "info",
            //"title": "titulo optimo",
            "header": "Create Related Case",
            "message": "Related Case was created.",
            closeCallback: function() {
                //alert('You closed the alert!');
            }
        });*/

        /*var action = component.get("c.createRelatedCases");
        action.setParams({ "caseId" : component.get("v.caseRecordId") });
        $A.enqueueAction(action);*/
	},
	sendAssignmentLetter : function(component, event, helper) {
	
        var workspaceAPI = component.find("workspace");

        //var letterUrl = 'https://composer.congamerge.com?SolMgr=1&sessionId=' + {!API.Session_ID} + '&serverUrl=' + {!API.Partner_Server_URL_290} + '&Id=' + {!caseRecordId} + '&QueryId=[Participation]a7z0D00000004w5?pv0=' + {!caseRecordId} + '&AttachmentParentId=' + {!caseRecordId};
        var caseId = component.get("v.caseRecordId");
        //var apiServer = component.get("v.apiServerPartner");
        //var c = $A.get("!API.Partner_Server_URL_370");
        //{!API.Partner_Server_URL_370}
        var cenas = '/apex/APXTConga4__Conga_Composer?serverUrl=' + $A.get("!API.Partner_Server_URL_370") + '&id=' + caseId + '&QueryId=[Participation]a7z0D00000004w5?pv0=' + caseId + '&AttachmentParentId=' + caseId + '&TemplateGroup=Conga+templates';
        //var url = component.set("v.url", cenas);
        window.open(cenas);
       
        /*workspaceAPI.openSubtab({
                parentTabId: workspaceAPI.getTabInfo,
                url: cenas,
                focus: true
        });*/
	},

	sendCase : function(component, event, helper){
        component.set("v.showSpinner",true);
        var caseSucc = $A.get("$Label.c.ISSP_AMC_CASE_SYNC");
        var caseErrorSync = $A.get("$Label.c.ISSP_AMC_SYN_CONNECTION");

         var action = component.get("c.sendCaseCtr");

         action.setParams({ "caseId" : component.get("v.caseRecordId")});
            action.setCallback(this, function(response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var errorMessageByStatus =  response.getReturnValue();

                    if(errorMessageByStatus == null){
                        helper.showToast("success", caseSucc);
                    }
                    else{

                        for(var status in errorMessageByStatus){
                            var detail = errorMessageByStatus[status];
                            if(status == '400' || status == '401'){
                                helper.showToast("error", detail);
                            }
                        }
                    }
                }
                else {
                    console.log("Failed with state: " + response.getError()[0].message);
                    helper.showToast("error", caseErrorSync);
                }
                $A.get('e.force:refreshView').fire();
                 component.set("v.showSpinner",false);

                 var action2 = component.get("c.disableButton");

                action2.setParams({ "caseId" : component.get("v.caseRecordId")});
                action2.setCallback(self, function(response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var options =  response.getReturnValue();
                    if(options == true){
                        component.set("v.sendCaseVariant", "destructive");
                    }
                }
                else {
                    console.log("Failed with state: " + response.getError()[0].message);
                }
                var appEvent = $A.get("e.c:ISSP_AMC_RefreshProgressEvent");
                appEvent.fire();
                });

                $A.enqueueAction(action2);
            });

            $A.enqueueAction(action);
	},

    /*startProcess : function(component, event, helper){
        var flow = component.find("flow");
        var inputVariables = [
            {
                //recordId : component.get("v.caseRecordId"),
                //type : "SObject",
                //recordId : { "Id" : component.get("v.caseRecordId")}
                //value : component.get("v.recordId")
            }
        ];
        flow.startFlow("ACLI_Processes");
        //alert(recordId);
    }*/
})
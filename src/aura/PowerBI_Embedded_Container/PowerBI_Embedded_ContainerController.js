({
    init : function(component, event, helper) {
        // get access token
        console.log('PowerBI_Embeded_Container init');

        var action = component.get("c.getAccessToken");
        helper.toggleSpinner(component, event);
        action.setCallback(this, function(a){
            if(a.getState() === "SUCCESS"){
                var accessToken = a.getReturnValue();
                component.set('v.accessToken', accessToken);
                console.log('got access token... ' + JSON.stringify(accessToken));
                // access token ok, get workspaces
                var action2 = component.get("c.getAllDashboards");
                action2.setParams({
                    "accessToken" : accessToken
                });
                action2.setCallback(this, function(a){
                    if(a.getState() === "SUCCESS"){
                        var workspaces = a.getReturnValue();

                        for(var i in workspaces) {
                            if(workspaces[i].dashboards != undefined) {
                                $A.createComponent(
                                    "c:PowerBI_Embedded_Dashboard_List",
                                    {
                                        "workspace": workspaces[i].workspace,
                                        "dashboards": workspaces[i].dashboards,
                                        "accessToken" : accessToken
                                    },
                                    function(newInp, status, errorMessage){
                                        if (status === "SUCCESS") {
                                            console.log('newInp:: ' + newInp);
                                            var workspacesArea = component.get("v.workspacesArea");
                                            workspacesArea.push(newInp);
                                            component.set("v.workspacesArea", workspacesArea);
                                        }
                                        else if (status === "INCOMPLETE") {
                                            console.log("No response from server or client is offline.")
                                        }
                                            else if (status === "ERROR") {
                                                console.log("Error1: " + errorMessage);
                                            }
                                    }
                                ); }
                        }
                    } else {
                        console.log('got some error getting workspaces ');
                    }
                     helper.toggleSpinner(component, event);
                });
                $A.enqueueAction(action2);

                //var compBody = component.get("v.body");
                //var compRef = component;
                //

            } else {
                console.log('error occured in cont, check server');
            }
        });

        $A.enqueueAction(action);
    },


    handleDashboardClicked: function(component, event, helper) {
        /*var url = event.getParam("dashboard").embedUrl;
        var embedUrl = event.getParam("dashboard").embedUrl;
        var objectId = event.getParam("dashboard").id;*/

        $A.createComponent(
                    "c:PowerBI_Embedded_Dashboard",
            {
                "accessToken": component.get("v.accessToken"),
                "embedUrl": event.getParam("dashboard").embedUrl,
                "objectId": event.getParam("dashboard").id
            },
            function(newInp, status, errorMessage){
                /*helper.toggleSpinner(component, event);*/
                if (status === "SUCCESS") {

                    var dashboardArea = [];
                    dashboardArea.push(newInp);
                    component.set("v.dashboardArea", dashboardArea);

                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                }
                else if (status === "ERROR") {
                    console.log("Error2: " + errorMessage);
                }

            }
        );

        component.set("v.dashboardShown", true);
        /*helper.toggleSpinner(component, event);*/
    },


    hideDashboard: function(component, event, helper) {
		component.set("v.dashboardShown", false);
    }
})
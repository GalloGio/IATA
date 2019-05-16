({

    getAvailableDashboards : function(component, event) {
        debugger;
        this.toggleSpinner(component, event);
        let action = component.get('c.getAvailableDashboardCategoriesForUser');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const dashboardCategories = response.getReturnValue();
                if(! $A.util.isEmpty(dashboardCategories)) {

                    let dashboards = [];
                    for(let key in dashboardCategories) {
                        dashboards.push({key:key, value:dashboardCategories[key]});
                    }

                    component.set('v.dashboardCategories', dashboards);
                    this.toggleSpinner(component, event);

                    /*let withCategories = [];
                    let categories = new Set();

                    let withRoles = [];
                    let roles = new Set();
                    for(let category in dashboardCategories) {
                        if(dashboardCategories[category].Category__c) {
                            withCategories.push(dashboardCategories[category]);
                            categories.add(dashboardCategories[category].Category__c);
                        }else{
                            if(dashboardCategories[category].Contact_Role_Service__r.Contact_Role__r.Name) {
                                withRoles.push(dashboardCategories[category]);
                                roles.add(dashboardCategories[category].Contact_Role_Service__r.Contact_Role__r.Name);
                            }
                        }
                    }

                    let categoryMap = new Map();
                    for(let obj in withCategories) {
                        addValuesToKey(withCategories[obj].Category__c, withCategories[obj]);
                    }

                    function addValuesToKey(key, value) {
                        categoryMap[key] = categoryMap[key] || [];
                        categoryMap[key].push(value);
                    }

                    let result = [];
                    for(let [key, value] of categoryMap.entries()) {
                        result.push({a:key, b:value});
                    }

                    component.set('v.dashboardsWithCategories', result);
                    component.set('v.dashboardsWithRoles', withRoles);*/

                }else{
                    //TODO:handle error
                    console.log('getAvailableDashboards error');
                    this.toggleSpinner(component, event);
                }

            }else{
                //TODO:handle error
                console.log('getAvailableDashboards error');
                this.toggleSpinner(component, event);

            }
        });
        $A.enqueueAction(action);
    },

    getAccessToken : function(component, event) {
        this.toggleSpinner(component, event);

        let action = component.get("c.getAccessToken");
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const oauth = response.getReturnValue();
                if(! $A.util.isEmpty(oauth)) {

                    const accessToken = oauth.access_token;
                    /*const expiresOn = oauth.expires_on;
                    const refreshToken = oauth.refresh_token;*/

                    /*component.set('v.accessToken', accessToken);
                    component.set('v.expiresOn', expiresOn);
                    component.set('v.refreshToken', refreshToken);*/

                    console.log('accessToken:: ' + accessToken);
                    /*console.log('expiresOn:: ' + expiresOn);
                    console.log('refreshToken:: ' + refreshToken);*/
                    this.getWorkspaces(component, event, accessToken);
                }else{

                }
            }else{
                this.toggleSpinner(component, event);
                console.log('getAccessToken error with state: ' + state)
            }

        });

        $A.enqueueAction(action);
    },


    getWorkspaces : function(component, event, accessToken) {
        let action = component.get('c.getAllDashboards');
        action.setParams({
            'accessToken' : accessToken
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const allWorkspaces = response.getReturnValue();
                console.log('allWorkspaces:: ', allWorkspaces);
                if(allWorkspaces) {
                    let nonEmptyWorkspaces = component.get('v.workspaces');
                    for(let i in allWorkspaces) {
                        if(allWorkspaces[i].dashboards != undefined) {
                            nonEmptyWorkspaces.push(allWorkspaces[i]);
                        }
                    }
                    component.set('v.workspaces', nonEmptyWorkspaces);
                    this.toggleSpinner(component, event);
                }else{
                    console.log('no PowerBI workspaces retrieved');
                }
            }else{
                console.log('getWorkspaces error with state: ' + state);
            }

        });
        $A.enqueueAction(action);
    },


    handleShowDashboardCategory : function(component, event) {
        let key = event.currentTarget.id;
        component.set('v.selectedDashboardCategory', component.get('v.dashboardCategories')[key].value);

        component.set('v.showWorkspaces', false);
        component.set('v.showDashboardCategory', true);
    },

    handleBackEvent : function(component, event) {
        component.set('v.showDashboardCategory', false);
        component.set('v.showWorkspaces', true);
    },

    handleShowDashboard : function(component, event) {
        this.toggleSpinner(component, event);
        let action = component.get('c.getAccessToken');
        const myName = event.currentTarget.name;
        const myId = event.currentTarget.id;
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(result) {
                    const accessToken = result.access_token;
                    const dashboard = component.get("v.workspaces")[myName].dashboards[myId];
                    const embedUrl = dashboard.embedUrl;
                    const objectId = dashboard.id;

                    console.log('embedUrl:: ', embedUrl);
                    console.log('objectId:: ', objectId);

                    setTimeout(
                        $A.getCallback(
                            function() {
                                $A.createComponent(
                                  "aura:html",
                                  {
                                      tag: "iframe",
                                      HTMLAttributes:{"frameBorder": "0", "src": "/apex/PowerBI_Dashboard?embedUrl="+encodeURIComponent('https://app.powerbi.com/reportEmbed?reportId=&groupId=bb322fe5-1f26-4bc6-892a-811d6a625ba1&w=2')+'&accessToken='+accessToken+'&objectId='+objectId
                                                      ,"width": 947.5, "height": 800, "scrolling": "no"}
                                  },
                                  function(iframe){
                                      component.set('v.showWorkspaces', false);
                                      component.set('v.showDashboard', true);
                                      var container = component.find('iframe');
                                      if (container.isValid()) {
                                          var body = container.get("v.body");
                                          body = [];
                                          body.push(iframe);
                                          container.set("v.body", body);
                                      }
                                  }

                                );
                                var spinner = component.find('spinner');
                                $A.util.toggleClass(spinner, 'slds-hide');

                            }

                        )
                    );

                }else{
                    //TODO:handle error
                }
            }else{
                //TODO:handle error
                console.log('handleShowDashboard error with state: ' + state);
            }
        });
        $A.enqueueAction(action);

    },

    toggleSpinner : function(component, event) {
        component.set('v.showSpinner', !component.get('v.showSpinner'));
    },


})
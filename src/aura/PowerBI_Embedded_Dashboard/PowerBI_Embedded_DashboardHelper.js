({

    getReportDetails : function(component, event, dashboard) {
        this.toggleSpinner(component, event);
        if(! $A.util.isEmpty(dashboard.Url__c)) {

            let url = dashboard.Url__c;
            let groupStart = url.indexOf('groupId=');
            let reportStart = url.indexOf('reportId=');
            let groupId = url.substr(groupStart+8,36);
            let reportId = url.substr(reportStart+9, 36);
            this.getUserDetail(component, event, groupId, reportId);

        }else{
            this.showToast('error', 'Unexpected error!', 'Init error.');
            this.toggleSpinner(component, event);
        }
    },

    getUserDetail : function(component, event, groupId, reportId) {
        let action = component.get('c.getUserDetail');
        action.setParams({
            'userId' : $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {

                const userDetail = response.getReturnValue();
                if(! $A.util.isEmpty(userDetail)) {

                    if(! $A.util.isEmpty(userDetail.Federation_ID__c)) {

                        component.set('v.userDetail', userDetail);
                        let federationId = userDetail.Federation_ID__c;
                        this.getAccessToken(component, event, federationId, groupId, reportId);

                    }else{
                        console.log('getUserDetail - empty federationId');
                        this.showToast('error', 'Unexpected error!', 'Unable to get federationId.');
                        this.toggleSpinner(component, event);
                    }

                }else{
                    console.log('getUserDetail - empty userDetail');
                    this.showToast('error', 'Unexpected error!', 'Unable to get user details.');
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getUserDetail error');
                this.showToast('error', 'Unexpected error!', 'Unable to get user details.');
                this.toggleSpinner(component, event);
            }
        });
        $A.enqueueAction(action);

    },

    getAccessToken : function(component, event, federationId, groupId, reportId) {

        //groupId = 'bb322fe5-1f26-4bc6-892a-811d6a625ba1';
        //reportId = '3a12085d-f7ea-49ef-a3e0-ec6bafbc7f0a';

        let action = component.get("c.getAccessToken");
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const oauth = response.getReturnValue();
                if(! $A.util.isEmpty(oauth)) {
                    if(! $A.util.isEmpty(oauth.access_token)) {
                        const accessToken = oauth.access_token;
                        //this.getDatasetDetail(component, event, accessToken, '472737e1-7e1a-4ded-988e-dbcac9293415');
                        //this.getReportDataset(component, event, accessToken, reportId); //383c83c1-c3d7-4b6f-ac7d-b2be2d644118
                        this.getEmbedToken(component, event, accessToken, federationId, groupId, reportId, '383c83c1-c3d7-4b6f-ac7d-b2be2d644118');
                    }else{
                        console.log('getAccessToken error - no access token');
                        this.showToast('error', 'Unexpected error!', 'Unable to get application access token.');
                        this.toggleSpinner(component, event);
                    }

                }else{
                    console.log('getAccessToken error - empty response');
                    this.showToast('error', 'Unexpected error!', 'Unable to get application access token.');
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getAccessToken error - error in response');
                this.showToast('error', 'Unexpected error!', 'Unable to get application access token.');
                this.toggleSpinner(component, event);
            }
        });

        $A.enqueueAction(action);
    },


    getReportDataset : function(component, event, accessToken, reportId) {
        let action = component.get('c.getReportsDetails');
        action.setParams({
            'accessToken' : accessToken,
            'reportId' : reportId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();

                if(! $A.util.isEmpty(result)) {
                    let datasetId = result.datasetId;
                    this.getDatasetDetail(component, event, accessToken, datasetId);
                }else{
                    //TODO:error
                }

                console.log('reports details result:: ' + JSON.stringify(result));
                this.toggleSpinner(component, event);
            }else{
                //TODO:error
                console.log('getReportsDetails error');
                this.toggleSpinner(component, event);
            }

        });
        $A.enqueueAction(action);
    },


    getDatasetDetail : function(component, event, accessToken, datasetId) {
        let action = component.get('c.getDataset');
        action.setParams({
            'accessToken' : accessToken,
            'datasetId' : datasetId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                console.log('getDatasetDetail result:: ' + JSON.stringify(result));
                this.toggleSpinner(component, event);
            }else{
                //TODO:error
                console.log('getDatasetDetail error');
                this.toggleSpinner(component, event);
            }

        });
        $A.enqueueAction(action);
    },



    getEmbedToken : function(component, event, accessToken, federationId, groupId, reportId, datasetId) {
        let action = component.get('c.getEmbedToken');
        action.setParams({
            'accessToken' : accessToken,
            'federationId' : federationId,
            'groupId' : groupId,
            'reportId' : reportId,
            'datasetId' : datasetId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();
                if(! $A.util.isEmpty(result)) {

                    console.log('embed token result:: ' + JSON.stringify(result));

                    if(! $A.util.isEmpty(result.token)) {
                        let embedToken = result.token;
                        this.getDashboard(component, event, embedToken, groupId, reportId);
                        //this.toggleSpinner(component, event);
                    }else{
                        console.log('getEmbedToken error');
                        this.showToast('error', 'Unexpected error!', 'Unable to get report embed token.');
                        this.toggleSpinner(component, event);
                    }
                }else{
                    console.log('getEmbedToken error');
                    this.showToast('error', 'Unexpected error!', 'Unable to get report embed token.');
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getEmbedToken error');
                this.showToast('error', 'Unexpected error!', 'Unable to get report embed token.');
                this.toggleSpinner(component, event);
            }

        });
        $A.enqueueAction(action);
    },


    getDashboard : function(component, event, embedToken, groupId, reportId) {
        const accessToken = embedToken;
        const objectId = reportId;
        let self = this;
        setTimeout(
            $A.getCallback(
                function() {
                    $A.createComponent(
                      "aura:html",
                      {
                          tag: "iframe",
                          HTMLAttributes:{"frameBorder": "0", "src": "/apex/PowerBI_Dashboard?embedUrl="+encodeURIComponent('https://app.powerbi.com/reportEmbed?reportId=' + reportId + '&groupId=' + groupId)+'+&accessToken='+accessToken+'&objectId='+objectId
                                                                                                          ,"width": 947, "height": 800, "scrolling": "no"}
                          /*HTMLAttributes:{"frameBorder": "0", "src": "/apex/PowerBI_Dashboard?embedUrl="+encodeURIComponent('https://app.powerbi.com/reportEmbed?reportId=39d42f7a-0a92-49cc-aef8-1a6c851143dd&groupId=bb322fe5-1f26-4bc6-892a-811d6a625ba1&w=2')+'&accessToken='+accessToken+'&objectId='+objectId
                                          ,"width": 947.5, "height": 800, "scrolling": "no"}*/
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
                    let spinner = component.find('spinner');
                    self.toggleSpinner(component, event);

                }

            )
        );

    },

    handBack : function(component, event) {
        let backEvent = component.getEvent('backEvent');
        backEvent.fire();
    },

    showToast : function(type, title, message) {
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    toggleSpinner : function(component, event) {
        component.set('v.showSpinner', ! component.get('v.showSpinner'));
    },


})
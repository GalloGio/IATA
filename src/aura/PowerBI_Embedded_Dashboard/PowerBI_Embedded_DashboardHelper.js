({

    getReportDetails : function(component, event, dashboard) {
        this.toggleSpinner(component, event);
        if(! $A.util.isEmpty(dashboard.Url__c)) {

            let url = dashboard.Url__c;
            let groupStart = url.indexOf('groupId=');
            let reportStart = url.indexOf('reportId=');
            let groupId = url.substr(groupStart+8, 36);
            let reportId = url.substr(reportStart+9, 36);
            this.getAccessToken(component, event, groupId, reportId);

        }else{
            this.showToast('error', 'Unexpected error!', 'Init error.');
            this.toggleSpinner(component, event);
        }
    },



    getAccessToken : function(component, event, groupId, reportId) {

        let action = component.get("c.getAccessToken");
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const oauth = response.getReturnValue();
                if(! $A.util.isEmpty(oauth)) {
                    if(! $A.util.isEmpty(oauth.access_token)) {
                        const accessToken = oauth.access_token;
                        this.getReportDataset(component, event, accessToken, groupId, reportId);

                    }else{
                        console.log('getAccessToken error - no access token');
                        this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_access_token"));
                        this.toggleSpinner(component, event);
                    }

                }else{
                    console.log('getAccessToken error - empty response');
                    this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_access_token"));
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getAccessToken error - error in response');
                this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_access_token"));
                this.toggleSpinner(component, event);
            }
        });

        $A.enqueueAction(action);
    },


    getReportDataset : function(component, event, accessToken, groupId, reportId) {
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
                    this.getDatasetDetail(component, event, accessToken, datasetId, groupId, reportId);
                }else{
                    console.log('getReportsDetails error');
                    this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_report_detail"));
                    this.toggleSpinner(component, event);
                }

            }else{
                console.log('getReportsDetails error');
                this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_report_detail"));
                this.toggleSpinner(component, event);
            }

        });
        $A.enqueueAction(action);
    },


    getDatasetDetail : function(component, event, accessToken, datasetId, groupId, reportId) {
        let action = component.get('c.getDataset');
        action.setParams({
            'accessToken' : accessToken,
            'datasetId' : datasetId
        });
        action.setCallback(this, function(response){
            const state = response.getState();
            if(state === 'SUCCESS') {
                const result = response.getReturnValue();

                if(! $A.util.isEmpty(result)) {
                    //if identity is needed -> dashboard with user security
                    let identityNeeded = result.isEffectiveIdentityRequired;

                    if(identityNeeded === 'true') {
                        //get embed token - dashboard with user security
                        let tokenType = 'Embed';
                        this.getUserDetail(component, event, groupId, reportId, accessToken, datasetId, tokenType);
                    }else{
                        //get dashboard - dashboard without user security
                        let tokenType = 'Aad';
                        this.getDashboard(component, event, accessToken, groupId, reportId, tokenType);
                    }
                }else{
                    console.log('getDatasetDetail error');
                    this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_dataset_detail"));
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getDatasetDetail error');
                this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_dataset_detail"));
                this.toggleSpinner(component, event);
            }
        });
        $A.enqueueAction(action);
    },

    getUserDetail : function(component, event, groupId, reportId, accessToken, datasetId, tokenType) {
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

                        this.getEmbedToken(component, event, accessToken, federationId, groupId, reportId, datasetId, tokenType);

                    }else{
                        console.log('getUserDetail - empty federationId');
                        this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_federation_Id"));
                        this.toggleSpinner(component, event);
                    }

                }else{
                    console.log('getUserDetail - empty userDetail');
                    this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_user_detail"));
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getUserDetail error');
                this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_user_detail"));
                this.toggleSpinner(component, event);
            }
        });
        $A.enqueueAction(action);

    },



    getEmbedToken : function(component, event, accessToken, federationId, groupId, reportId, datasetId, tokenType) {
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

                    if(! $A.util.isEmpty(result.token)) {
                        let embedToken = result.token;
                        this.getDashboard(component, event, embedToken, groupId, reportId, tokenType);

                    }else{
                        console.log('getEmbedToken error');
                        this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_embed_token"));
                        this.toggleSpinner(component, event);
                    }
                }else{
                    console.log('getEmbedToken error');
                    this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_embed_token"));
                    this.toggleSpinner(component, event);
                }
            }else{
                console.log('getEmbedToken error');
                this.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_embed_token"));
                this.toggleSpinner(component, event);
            }

        });
        $A.enqueueAction(action);
    },


    getDashboard : function(component, event, embedToken, groupId, reportId, tokenType) {

        const accessToken = embedToken;
        const objectId = reportId;
        let self = this;
        setTimeout(
            $A.getCallback(
                function() {
                    let width = component.find("iframe").getElement().getBoundingClientRect().width;
                    $A.createComponent(
                      "aura:html",
                      {
                          tag: "iframe",
                          HTMLAttributes:{"frameBorder": "0", "src": "/apex/PowerBI_Dashboard?embedUrl="+encodeURIComponent('https://app.powerbi.com/reportEmbed?reportId=' + reportId + '&groupId=' + groupId)+'+&accessToken='+accessToken+'&objectId='+objectId+'&tokenType='+tokenType
                                                                                                          ,"width": width, "height": (width-60)*0.48/*0.59 for full width with scrollbar*/, "scrolling": "no"}
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
                          }else{
                              console.log('getDashboard error');
                              self.showToast('error', 'Unexpected error.', $A.get("$Label.c.GADM_PowerBI_no_dashboard"));
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
    applyCSS: function(component){
        /*HTML hack, read the comment on cssstyle attribute*/
        component.set("v.cssStyle", ".modal-header {padding-bottom:0rem; border-bottom: 0px solid #e9ecef} .slds-text-heading_medium, .slds-text-heading--medium {display:none;} .uiMenu {z-index:0} .oiHeader a.homeIcon {z-index:0} .forceIcon .slds-icon_xx-small {width: 1.5rem; height: 1.5rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 0px !important} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 0px; background-color: transparent;}");
    },
})
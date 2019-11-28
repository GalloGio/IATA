({

    handleListBack : function(component, event) {
        let backListEvent = component.getEvent('backListEvent');
        backListEvent.fire();
    },

    handleBackEvent : function(component, event) {
        component.set('v.showDashboard', false);
        component.set('v.showDashboards', true);
    },

    handleShowDashboard : function(component, event) {
        let key = event.currentTarget.id;
        component.set('v.selectedDashboard', component.get('v.category').permissions[key]);

        this.handleShowModal(component, event);

    },
    handleShowDocuments : function(component, event) {
            let key = event.currentTarget.id;
            component.set('v.selectedDashboard', component.get('v.category').permissions[key]);

            this.handleShowModalDocuments(component, event);
     },

     handleTrackDashboardUsage : function(component, event) {
         var userId = $A.get("$SObjectType.CurrentUser.Id");
         let dashboard = component.get('v.selectedDashboard').permission;
         var action = component.get('c.checkSessionCache');
         let key = dashboard.Id;
         action.setParams({
             'userId' : userId,
             'key' : key
         });
         action.setCallback(this, function(response){
             var state = response.getState();
             if(state === 'SUCCESS') {
                 var isKeyInCache = response.getReturnValue();
                 if(! isKeyInCache) {
                     //key not yet present in cache - fire event
                     var trackUsageEvent = component.getEvent('serviceUsageEvent');
                     trackUsageEvent.setParams({
                         'UserId' : userId,
                         'Key' : dashboard.Id,
                         'Target' : dashboard.Name,
                         'Service' : 'GADM',
                         'Type' : 'Dashboard'
                     });
                     trackUsageEvent.fire();
                 }else{
                    //key is present in cache
                    console.log('key present in session cache');
                 }
             } else {
                 console.log('handleTrackUsage error');
             }
         });
         $A.enqueueAction(action);
     },

    toggleSpinner : function(component) {
        component.set('v.showSpinner', ! component.get('v.showSpinner'));
    },

    handleShowModal: function(component, evt) {
        var modalBody;
        let self = this;
        $A.createComponent("c:PowerBI_Embedded_Dashboard", {dashboard:component.get('v.selectedDashboard').permission},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   component.find('overlayLib').showCustomModal({
                       header: component.get('v.selectedDashboard').permission.Name,
                       body: modalBody,
                       showCloseButton: true,
                       cssClass: "slds-modal_large",
                       closeCallback: function() {
                           /*HTML hack, read the comment on cssstyle attribute*/
                           component.set("v.cssStyle", ".modal-header {padding-bottom:1rem; border-bottom: 1px solid #e9ecef} .slds-text-heading_medium, .slds-text-heading--medium {display:block;} .uiMenu {z-index:10} .oiHeader a.homeIcon {z-index:9} .forceIcon .slds-icon_xx-small {width: 0.875rem; height: 0.875rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 7px 16px !important;} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 15px; background-color: #eb3014;}");
                       }
                   })
                   //track dashboard usage
                   self.handleTrackDashboardUsage(component, event);
               }
           });
    },

    handleShowModalDocuments: function(component, evt) {
            var modalBody;
            $A.createComponent("c:GADM_RelatedFilesCategorizedLists", {objectIds:component.get('v.selectedDashboard').permission.Id, isPopup:true},
               function(content, status) {
                   if (status === "SUCCESS") {
                       modalBody = content;
                       component.find('overlayLibDocs').showCustomModal({
                           header: component.get('v.selectedDashboard').permission.Name,
                           body: modalBody,
                           showCloseButton: true,
                           cssClass: "slds-modal_large",
                           closeCallback: function() {
                               /*HTML hack, read the comment on cssstyle attribute*/
                               component.set("v.cssStyle", ".uiMenu {z-index:10} .oiHeader a.homeIcon {z-index:9} .forceIcon .slds-icon_xx-small {width: 0.875rem; height: 0.875rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 7px 16px !important;} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 15px; background-color: #eb3014;}");
                           }
                       })
                   }
               });
        }
})
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

        //component.set('v.showDashboards', false);
        //component.set('v.showDashboard', true);
        this.handleShowModal(component, event);

    },
    handleShowDocuments : function(component, event) {
            let key = event.currentTarget.id;
            component.set('v.selectedDashboard', component.get('v.category').permissions[key]);

            //component.set('v.showDashboards', false);
            //component.set('v.showDashboard', true);
            this.handleShowModalDocuments(component, event);
     },
    toggleSpinner : function(component) {
        component.set('v.showSpinner', ! component.get('v.showSpinner'));
    },
    handleShowModal: function(component, evt) {
        var modalBody;
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
                           component.set("v.cssStyle", ".uiMenu {z-index:10} .oiHeader a.homeIcon {z-index:9} .forceIcon .slds-icon_xx-small {width: 0.875rem; height: 0.875rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 7px 16px !important;} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 15px; background-color: #eb3014;}");
                       }
                   })
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
                               component.set("v.cssStyle", ".uiMenu {z-index:10} .oiHeader a.homeIcon {z-index:9} .forceIcon .slds-icon_xx-small {width: 0.875rem; height: 0.875rem} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton {padding: 7px 16px !important;} button.uiButton, .salesforceIdentityLoginBody button.sfdc_button.uiButton, input.uiButton {margin-top: 15px; background-color: #eb3014;}");
                           }
                       })
                   }
               });
        }
})
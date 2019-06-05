import { LightningElement, api } from 'lwc';

import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService';
import { updateRecord } from 'lightning/uiRecordApi';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_Services_ManageService from '@salesforce/label/c.CSP_Services_ManageService';
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';

export default class PortalServicesAccessGrantedCard extends NavigationMixin(LightningElement) {

    @api service;

    label = {
        CSP_Services_ManageService,
        CSP_Services_GoToService
    };

    goToManageServiceButtonClick(event){
        let serviceAux = JSON.parse(JSON.stringify(this.service));
        //console.log(serviceAux);

        let params = {};
        params.serviceId = serviceAux.recordService.Id;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "manage-service"
            }})
        .then(url => navigateToPage(url, params));
    }

    goToServiceButtonClick(event){
        //because proxy.......
        let serviceAux = JSON.parse(JSON.stringify(this.service));
        //console.log(serviceAux);

        //attributes stored on element that is related to the event
        let appUrlData = serviceAux.Application_Start_URL__c
        let appFullUrlData = serviceAux.Portal_Application__r.Application_URL__c;
        let openWindowData = serviceAux.Portal_Application__r.New_Window__c;
        let requestable = serviceAux.Portal_Application__r.Requestable__c
        let recordId = serviceAux.Id;
        
        // update Last Visit Date on record
        // Create the recordInput object
        const fields = {};
        fields.Id = recordId;
        fields.Last_Visit_Date__c = new Date().toISOString();
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                //console.info('Updated Last Visit Date successfully!');
            })
        
        let myUrl = appUrlData;
        
        //verifies if the event target contains all data for correct redirection
        if (openWindowData !== undefined) {
            //determines if the link is to be opened on a new window or on the current
            if (openWindowData === "true") {
                if (appUrlData !== 'undefined') {
                    myUrl = appUrlData.replace("/", "");
                } else if (appFullUrlData !== 'undefined') {
                    myUrl = appFullUrlData;
                }

                //start the spinner
                //this.toggleSpinner();

                //is this link a requestable Service?
                if (requestable === "true") {
                    //method that redirects the user to the old portal maintaing the same loginId
                    goToOldPortalService({ myurl: myUrl })
                        .then(result => {
                            //stop the spinner
                            this.toggleSpinner();
                            //open new tab with the redirection
                            window.open(result);
                        })
                        .catch(error => {
                            //throws error
                            this.error = error;
                        });
                } else {
                    //stop the spinner
                    //this.toggleSpinner();
                    //open new tab with the redirection
                    window.open(myUrl);
                }
            } else {
                //keep the spinner on until the page redirects
                //this.toggleSpinner();
                //redirects on the same page
                window.location.href = myUrl;
            }
            
        }


    }


}
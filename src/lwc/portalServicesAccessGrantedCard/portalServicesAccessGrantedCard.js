import { LightningElement, api } from 'lwc';

import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService';
import updateLastModifiedService from '@salesforce/apex/PortalServicesCtrl.updateLastModifiedService';

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

    goToServiceButtonClick(){
        //because proxy.......
        let serviceAux = JSON.parse(JSON.stringify(this.service)).recordService;

        //attributes stored on element that is related to the event
        let appUrlData = serviceAux.Application_URL__c
        let appFullUrlData = serviceAux.Application_URL__c;
        let openWindowData = serviceAux.New_Window__c;
        let requestable = serviceAux.Requestable__c
        let recordId = serviceAux.Id;
        
        // update Last Visit Date on record
        updateLastModifiedService({ serviceId: recordId })
        
        let myUrl = appUrlData;
        
        //verifies if the event target contains all data for correct redirection
        if (openWindowData !== undefined) {
            //determines if the link is to be opened on a new window or on the current
            if (openWindowData === true) {
                if (appUrlData !== 'undefined') {
                    myUrl = appUrlData.replace("/", "");
                } else if (appFullUrlData !== 'undefined') {
                    myUrl = appFullUrlData;
                }

                //is this link a requestable Service?
                if (requestable === true) {
                    //method that redirects the user to the old portal maintaing the same loginId
                    goToOldPortalService({ myurl: myUrl })
                        .then(result => {
                            //open new tab with the redirection
                            window.open(result);
                        });
                } else {
                    //open new tab with the redirection
                    window.open(myUrl);
                }
            } else {
                //redirects on the same page
                window.location.href = myUrl;
            }
            
        }


    }


}
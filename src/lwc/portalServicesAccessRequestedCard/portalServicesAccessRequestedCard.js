import { LightningElement, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_Services_ManageService from '@salesforce/label/c.CSP_Services_ManageService';
import CSP_Services_AccessRequested from '@salesforce/label/c.CSP_Services_AccessRequested';

export default class PortalServicesAccessRequestedCard extends NavigationMixin(LightningElement) {

    @api service;

    label = {
        CSP_Services_ManageService,
        CSP_Services_AccessRequested
    };

    goToManageServiceButtonClick(event){
        //beacause proxy.......
        let serviceAux = JSON.parse(JSON.stringify(this.service));

        let params = {};
        params.serviceId = serviceAux.Portal_Application__c;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "manage-service"
            }})
        .then(url => navigateToPage(url, params));
    }

}
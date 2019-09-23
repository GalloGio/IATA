import { LightningElement, api, track } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_Services_ManageService from '@salesforce/label/c.CSP_Services_ManageService';
import CSP_Services_AccessRequested from '@salesforce/label/c.CSP_Services_AccessRequested';
import ISSP_Access_Under_Provisioning from '@salesforce/label/c.ISSP_Access_Under_Provisioning';

export default class PortalServicesAccessRequestedCard extends NavigationMixin(LightningElement) {

    @api service;

    @track rightSlotLabel;

    label = {
        CSP_Services_ManageService,
        CSP_Services_AccessRequested,
        ISSP_Access_Under_Provisioning
    };

    connectedCallback() {
        let serviceAux = JSON.parse(JSON.stringify(this.service));
        this.rightSlotLabel = serviceAux.btnLabel;
    }

    goToManageServiceButtonClick(event) {
        //beacause proxy.......
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

}

import { LightningElement, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_Services_ServiceInformation from '@salesforce/label/c.CSP_Services_ServiceInformation';
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';

export default class PortalServicesAvailableServicesListCard extends NavigationMixin(LightningElement) {

    @api service;

    label = {
        CSP_Services_ServiceInformation,
        CSP_Services_GoToService
    };

    goToServiceInformationButtonClick(event){
        //because proxy.......
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

    enableServiceButtonClick(event){
        console.log('TODO enableServiceButtonClick :D');


        //figure out if the user is admin or normal user, then open the correspondent popup for the type of user and the appropriate service.

    }


}
import { LightningElement, api,track } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_Services_ServiceInformation from '@salesforce/label/c.CSP_Services_ServiceInformation';
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';

export default class PortalServicesAvailableServicesListCard extends NavigationMixin(LightningElement) {

    @api
    get service(){
        return this.trackedService;
    }
    set service(val){
        this.trackedService=val;
    }
    @track trackedService;

    @track showConfirm=false;

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
        this.showConfirm=true;     
    }

    requestComplete(event){
        if(event.detail.success){
           this.dispatchEvent(new CustomEvent('servicegranted', { detail: {serviceId:this.trackedService}}));// sends to parent the service that was requested with success
        
        }else{

            this.showConfirm = false;
        }
    }

    get serviceInfo(){
        let serv=JSON.parse(JSON.stringify(this.trackedService));        
        return serv;
    }

}
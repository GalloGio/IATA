import { LightningElement, api,track } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_Services_ServiceInformation from '@salesforce/label/c.CSP_Services_ServiceInformation';
import CSP_Services_GoToService from '@salesforce/label/c.CSP_Services_GoToService';
import CSP_L2_Requested_Modal_Title from '@salesforce/label/c.CSP_L2_Requested_Modal_Title';
import CSP_L2_Requested_Modal_Message from '@salesforce/label/c.CSP_L2_Requested_Modal_Message';
import CSP_L2_Requested_Modal_Cancel from '@salesforce/label/c.CSP_L2_Requested_Modal_Cancel';
import CSP_L2_Requested_Modal_Complete from '@salesforce/label/c.CSP_L2_Requested_Modal_Complete';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesAvailableServicesListCard extends NavigationMixin(LightningElement) {
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

    @api
    get service(){
        return this.trackedService;
    }
    set service(val){
        this.trackedService=val;
    }
    @track trackedService;

    @track showConfirm=false;

    //Level 2 registration variables
    @api requiresSecondLevelRegistration;
    @api isFirstLevelUser;
    level2RegistrationTrigger = 'service';
    isTriggeredByRequest = true;
    
    @track displaySecondLevelRegistrationPopup = false;
    @track displaySecondLevelRegistration = false;

    // labels
    label = {
        CSP_Services_ServiceInformation,
        CSP_Services_GoToService,
        CSP_L2_Requested_Modal_Title, 
        CSP_L2_Requested_Modal_Message,
        CSP_L2_Requested_Modal_Cancel,
        CSP_L2_Requested_Modal_Complete
    };

	get hasIcon(){
        return this.service.recordService.Application_icon_URL__c !== undefined;
	}
	
    cancelSecondLevelRegistration(){
        this.displaySecondLevelRegistrationPopup = false;
        this.displaySecondLevelRegistration = false;
    }

    showSecondLevelRegistration(){
        this.displaySecondLevelRegistrationPopup = false;
        this.displaySecondLevelRegistration = true;
    }

    secondLevelRegistrationCompletedAction1(){
        navigateToPage(CSP_PortalPath,{});
    }

    secondLevelRegistrationCompletedAction2(){
        navigateToPage("services?tab=availableServices");
    }

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
        // check if user is Level 1 and if service requests L2
        if(this.requiresSecondLevelRegistration && this.isFirstLevelUser){
            this.displaySecondLevelRegistrationPopup = true;
        }
        else{
        this.showConfirm=true;     
    }
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
import { LightningElement } from 'lwc';

//import labels
import CSP_Services_MyServicesHelpText from '@salesforce/label/c.CSP_Services_MyServicesHelpText';

export default class PortalServicesMyServices extends LightningElement {

    label = {
        CSP_Services_MyServicesHelpText
    };

    handleGoToAvailableServicesTab(event){
        this.dispatchEvent(
            new CustomEvent('gotoavailableservicestab')
        );
    }

}
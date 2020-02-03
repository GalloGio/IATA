import { LightningElement } from 'lwc';

//import labels
import CSP_Services_AvailableServicesHelpText from '@salesforce/label/c.CSP_Services_AvailableServicesHelpText';

export default class PortalServicesAvailableServices extends LightningElement {

    constructor() {
        super();
        this.handleScroll();
    }

    label = {
        CSP_Services_AvailableServicesHelpText
    };

    handleScroll() {
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    }


}
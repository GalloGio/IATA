import { LightningElement } from 'lwc';

//import labels
import CSP_Services_RequestServiceBannerTitle from '@salesforce/label/c.CSP_Services_RequestServiceBannerTitle';
import CSP_Services_RequestServiceBannerSubtitle from '@salesforce/label/c.CSP_Services_RequestServiceBannerSubtitle';
import CSP_Services_RequestServiceBannerButton from '@salesforce/label/c.CSP_Services_RequestServiceBannerButton';

export default class PortalServicesRequestBanner extends LightningElement {

    label = {
        CSP_Services_RequestServiceBannerTitle,
        CSP_Services_RequestServiceBannerSubtitle,
        CSP_Services_RequestServiceBannerButton
    };

    goToRequestServiceButtonClick(event){
        this.dispatchEvent(
            new CustomEvent('gotoavailableservicestab')
        );
    }

}
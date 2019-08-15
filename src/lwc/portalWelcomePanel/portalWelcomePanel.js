/**
 * Created by ukaya01 on 09/08/2019.
 */

import { LightningElement, track } from 'lwc';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import { navigateToPage } from'c/navigationUtils';

export default class PortalWelcomePanel extends LightningElement {


    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    serviceIcon = CSP_PortalPath + 'service_recolor.png';
    uptodateIcon = CSP_PortalPath + 'uptodate_recolor.png';
    offerIcon = CSP_PortalPath + 'offer_recolor.png';
    supportIcon = CSP_PortalPath + 'support_recolor.png';
    arrowIcon = CSP_PortalPath + 'arrow_right_recolor.png';
    bgImage = CSP_PortalPath + 'left_panel.png';
    @track backgroundStyle;

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.bgImage + '");background-position: center;background-repeat: no-repeat;background-size: cover;';
    }

    handleNavigateToFAQ(){
        navigateToPage('https://portal.iata.org/faq/');
    }

}

import { LightningElement, track } from 'lwc';

//import labels
import TreasuryDashboardServiceName from '@salesforce/label/c.Treasury_Dashboard_Service_Name';
import TreasuryDashboardHeaderText from '@salesforce/label/c.Treasury_Dashboard_Header_Text';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';


export default class PortalTreasuryDashboardHeader extends LightningElement {

    labels = {
        TreasuryDashboardServiceName,
        TreasuryDashboardHeaderText
    };

    //link to header image
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/AdvancedSearchBackground.jpg';

    @track backgroundStyle;

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;'
    }


}
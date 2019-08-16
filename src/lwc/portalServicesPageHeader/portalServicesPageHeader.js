import { LightningElement, track } from 'lwc';

//import labels
import CSP_Search_Services_Placeholder from '@salesforce/label/c.CSP_Search_Services_Placeholder';
import CSP_Services_HeaderTitle from '@salesforce/label/c.CSP_Services_HeaderTitle';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesPageHeader extends LightningElement {

    label = {
        CSP_Search_Services_Placeholder,
        CSP_Services_HeaderTitle
    };

    //links for images
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/ServicesBackground.jpg';

    @track backgroundStyle;

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;'
    }

}

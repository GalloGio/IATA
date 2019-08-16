import { LightningElement, track } from 'lwc';

//import labels
import CSP_Search_Support_Placeholder from '@salesforce/label/c.CSP_Search_Support_Placeholder';
import CSP_Support_HeaderTitle from '@salesforce/label/c.CSP_Support_HeaderTitle';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSupportPageHeader extends LightningElement {

    label = {
        CSP_Search_Support_Placeholder,
        CSP_Support_HeaderTitle
    };

    //links for images
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/FAQsBackground.jpg';

    @track backgroundStyle;

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;'
    }

}

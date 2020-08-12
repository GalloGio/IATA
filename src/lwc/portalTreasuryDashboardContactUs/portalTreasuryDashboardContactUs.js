
import { LightningElement, track, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalTreasuryDashboardContactUs extends NavigationMixin(LightningElement) {

    @track supportReachUsCreateNewCaseURL;
    @track loading = true;


    conversationImageURL = CSP_PortalPath + 'CSPortal/Images/Icons/messageBallons.svg';

    connectedCallback() {

    }


    redirectToSupport(event) {
        event.preventDefault();
        event.stopPropagation();

        let params = {topic : 'TD'
        };

        navigateToPage(this.supportReachUsCreateNewCaseURL, params);
    }

}
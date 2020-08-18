
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
        this.loading=false;
    }


    redirectToSupport(event) {
        event.preventDefault();
        event.stopPropagation();
        this.loading=true;
        let params = {topic : 'TD'
        };

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-reach-us"
            }})
            .then(url => {
                navigateToPage(url, params);
            });
    }

}
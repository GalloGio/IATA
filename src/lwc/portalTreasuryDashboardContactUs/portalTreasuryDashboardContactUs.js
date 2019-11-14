
import { LightningElement, track, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalTreasuryDashboardContactUs extends NavigationMixin(LightningElement) {

    @track supportReachUsURL;
    @api category;
    @api topic;
    @api subTopic;

    conversationImageURL = CSP_PortalPath + 'CSPortal/Images/Icons/messageBallons.svg';

    connectedCallback() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-reach-us"
            }})
        .then(url => this.supportReachUsURL = url);

    }


    redirectToSupport(event) {
        event.preventDefault();
        event.stopPropagation();

        let params = {};
        if(this.category !== undefined && this.category !== null) {
            params.category = this.category;
        }
        if(this.topic !== undefined && this.topic !== null) {
            params.topic = this.topic;
        }
        if(this.subTopic !== undefined && this.subTopic !== null) {
            params.subtopic = this.subTopic;
        }

        navigateToPage(this.supportReachUsURL, params);
    }

}
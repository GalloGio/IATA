import { LightningElement, track, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//custom labels
import CSP_FAQReachUsBanner_ButtonText from '@salesforce/label/c.CSP_FAQReachUsBanner_ButtonText';
import CSP_FAQReachUsBanner_Title from '@salesforce/label/c.CSP_FAQReachUsBanner_Title';
import CSP_FAQReachUsBanner_Text from '@salesforce/label/c.CSP_FAQReachUsBanner_Text';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalFAQReachUsBanner extends NavigationMixin(LightningElement) {

    // Labels to use in the template
    label = {
        CSP_FAQReachUsBanner_ButtonText,
        CSP_FAQReachUsBanner_Title,
        CSP_FAQReachUsBanner_Text
    };

    @track supportReachUsURL;
    @api category;
    @api topic;
    @api subTopic;
    @api redirectObject;

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

        if (this.redirectObject !== undefined) {
            if (this.redirectObject.topic !== undefined && this.redirectObject.topic !== null && this.redirectObject.topic !== '') {
                params.topic = this.redirectObject.topic;
            }           
        } else {           
            if (this.topic !== undefined && this.topic !== null && this.topic !== '') {
                params.topic = this.topic;
            }            
        }

        navigateToPage(this.supportReachUsURL, params);
    }
}

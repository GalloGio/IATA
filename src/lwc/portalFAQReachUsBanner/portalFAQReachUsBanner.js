import { LightningElement, track, api } from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';
import getAuthConfig from '@salesforce/apex/CSP_Utils.getAuthConfig';

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
        
        
        getAuthConfig()
            .then(results => {
                //constructs support contact us link
                this.supportReachUsURL = results.selfRegistrationUrl.substring(0, results.selfRegistrationUrl.indexOf(CSP_PortalPath)+CSP_PortalPath.length)+'support-reach-us';
        });
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

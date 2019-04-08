import { LightningElement, track, api } from 'lwc';

//images
import PORTAL_RESOURCES from '@salesforce/resourceUrl/csPortalResources';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//custom labels
import CSP_FAQReachUsBanner_Title from '@salesforce/label/c.CSP_FAQReachUsBanner_Title';
import CSP_FAQReachUsBanner_Text from '@salesforce/label/c.CSP_FAQReachUsBanner_Text';

export default class PortalFAQReachUsBanner extends NavigationMixin(LightningElement) {

    // Labels to use in the template
    label = {
        CSP_FAQReachUsBanner_Title,
        CSP_FAQReachUsBanner_Text
    };

    @track reachUs = 'Reach Us';
    @track supportReachUsURL;
    @api topic;
    @api subTopic;

    conversationImageURL = PORTAL_RESOURCES + '/images/conversation_image.png';

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
        if(this.topic !== undefined && this.topic !== null) {
            params.T = this.topic;
        }
        if(this.subTopic !== undefined && this.subTopic !== null) {
            params.ST = this.subTopic;
        }

        navigateToPage(this.supportReachUsURL, params);
    }
}
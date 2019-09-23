import { LightningElement, track } from 'lwc';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalFAQPage extends NavigationMixin(LightningElement) {
    @track category;
    @track topic;
    @track subTopic;

    connectedCallback() {
        //get the parameters for this page
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.category !== undefined){              
            this.category = pageParams.category;
        }         
    }

    topicSelected(event) {
        this.topic = event.detail.options;
    }

    subTopicSelected(event) {
        this.subTopic = event.detail.options;
    }
}
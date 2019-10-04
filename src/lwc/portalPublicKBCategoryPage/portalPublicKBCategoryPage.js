import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalPublicKBCategoryPage extends NavigationMixin(LightningElement) {
    @track category;
    @track language;
    @track topic;
    @track subTopic;

    connectedCallback() {
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined) {              
            if(pageParams.category !== undefined) this.category = pageParams.category;
            if(pageParams.language !== undefined) this.language = pageParams.language;
        }         
    }

    topicSelected(event) {
        this.topic = event.detail.options;
    }

    subTopicSelected(event) {
        this.subTopic = event.detail.options;
    }
}
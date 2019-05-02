import { LightningElement, api, wire, track } from 'lwc';
import getArticlesFromSubtopic from '@salesforce/apex/PortalFAQsCtrl.getArticlesFromSubtopic';
export default class PortalFAQArticleAccordion extends LightningElement {
    @api topicName;
    @track articles;

    connectedCallback() {
        console.log(this.topicName);
        
    }

    @wire(getArticlesFromSubtopic, { selectedSubtopic : '$topicName' })
    wiredRecentCases(results) {
        if (results.data) {            
            console.log(results.data);
            this.articles = JSON.parse(JSON.stringify(results.data));
        } else if (results.error) {
            this.error = results.error;
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        console.log(openSections);
        
    }
}
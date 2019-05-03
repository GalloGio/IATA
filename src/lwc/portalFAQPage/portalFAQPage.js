import { LightningElement, track } from 'lwc';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalFAQPage extends NavigationMixin(LightningElement) {
    @track category;
    @track topic;
    @track subTopic;
    @track childs;
    @track topicTiles;
    @track accordionMap;

    connectedCallback() {
        //get the parameters for this page
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.category !== undefined){              
            this.category = pageParams.category;
        }         
    }         

    subTopicSelected(event) {
        this.topic = event.detail.topic;
        this.subTopic = event.detail.subtopic;
    }
}
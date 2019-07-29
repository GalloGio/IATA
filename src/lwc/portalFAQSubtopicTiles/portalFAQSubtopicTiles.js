import { LightningElement, api, track } from 'lwc';
import getFAQsInfo from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';

export default class PortalFAQSubtopicTiles extends LightningElement {
    @track error;
    @track loading = true;
    @track topicTiles;
    @track subTopicTiles;
    @track accordionMap;
    @api category;
    @track topic;
    @track counter = 0;

    connectedCallback() {
        getFAQsInfo()
            .then(results => {
                let result = JSON.parse(JSON.stringify(results));
            
                this.topicTiles = [];
                this.accordionMap = []; //Save all Data Category visibility information. Contains category(Tile), childs(Subtopic), topicLabel, topicName
                let tempTopicOptions = [];
                let tempAccordionMap = [];
                
                let tempCategoryName = this.category; //Contains selected category from portalFAQPage
        
                Object.keys(result).forEach(function (el) {                
                    tempAccordionMap[result[el].topicName] = result[el];

                    if(tempCategoryName === result[el].categoryName) {
                        tempTopicOptions.push({ label: result[el].topicLabel, value: result[el].topicName, open: false, class: 'slds-p-around_medium customCardTitleBox cursorPointer borderStyle cardStyle' });
                    }
                });
    
                this.topicTiles = tempTopicOptions;
                this.accordionMap = tempAccordionMap;
    
                this.loading = false;
            })
            .catch(error => {
                this.error = error;
            }
        ); 
    }

    topicSelected(event) {        
        let topicName = event.target.attributes.getNamedItem('data-item').value;
        
        this.topic = topicName;
        
        let topicVals = JSON.parse(JSON.stringify(this.topicTiles));
        
        Object.keys(topicVals).forEach(function (el) {
            if(topicName === topicVals[el].value && topicVals[el].open === false) {
                topicVals[el].open = true;
                topicVals[el].class = 'slds-p-around_medium customCardTitleBox cursorPointer customBorderlessCardWhite borderStyle';
            } else {
                topicVals[el].open = false;
                topicVals[el].class = 'slds-p-around_medium customCardTitleBox cursorPointer borderStyle cardStyle';
            }
        });

        this.topicTiles = topicVals;

        let tempSubTopics = [];
        let subtopicVals = JSON.parse(JSON.stringify(this.accordionMap[topicName].childs)); //Get subtopics under each topic
        
        Object.keys(subtopicVals).forEach(function (el) {            
            tempSubTopics.push({ label: el, value: subtopicVals[el], class: "slds-p-left_small slds-m-around_small text-xsmall slds-p-vertical_x-small slds-p-right_small cursorPointer" });
        });

        this.subTopicTiles = [];
        this.subTopicTiles = tempSubTopics.reverse();

        //portalFAQPage handles the event and send parameters to portalFAQArticleAccordion to show the articles under selected topic  
        let topicInfo = {
            topic: this.topic,
            counter: this.counter++
        };      
        this.selectedEvent('topicselected', topicInfo);
    }
    
    subTopicSelected(event) {        
        let subtopicName = event.target.attributes.getNamedItem('data-name').value;
        
        let tempSubTopics = [];
        let subtopicVals = JSON.parse(JSON.stringify(this.accordionMap[this.topic].childs)); //Get subtopics under each topic

        Object.keys(subtopicVals).forEach(function (el) {        
            if(subtopicName === subtopicVals[el]) {
                tempSubTopics.push({ label: el, value: subtopicVals[el], class: "slds-p-left_small slds-m-around_small text-xsmall slds-p-vertical_x-small slds-p-right_small cursorPointer selectedSubTopic" });
            } else {
                tempSubTopics.push({ label: el, value: subtopicVals[el], class: "slds-p-left_small slds-m-around_small text-xsmall slds-p-vertical_x-small slds-p-right_small cursorPointer" });
            }
        });

        this.subTopicTiles = [];
        this.subTopicTiles = tempSubTopics.reverse();      
        
        //portalFAQPage handles the event and send parameters to portalFAQArticleAccordion to show the articles under selected subtopic
        let subtopicInfo = {
            topic: this.topic,
            subtopic: subtopicName
        };   
        this.selectedEvent('subtopicselected', subtopicInfo);
    }

    selectedEvent(eventName, params) {
        const selectedEvent = new CustomEvent(eventName, {
            detail: {
                options: params
            }
        });

        this.dispatchEvent(selectedEvent);
    }
}
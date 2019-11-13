import { LightningElement, api, track } from 'lwc';
import getFAQsInfoByLanguage from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfoByLanguage';

export default class PortalFAQSubtopicTiles extends LightningElement {
    @track error;
    @track loading = true;
    @track topicTiles;
    @track subTopicTiles;
    @track accordionMap;
    @track topic;
    @track counter = 0;

    @api category;
    @api language;
    @track _faqObject = {};

    @api
    get faqObject() {
        return this._faqObject;
    }
    set faqObject(value) {
        let _value = JSON.parse(JSON.stringify(value));
        this._faqObject = _value;
    }

    connectedCallback() {
        this.category = this._faqObject.category;
        this.language = this._faqObject.language;

        getFAQsInfoByLanguage({ lang : this.language })
            .then(results => {
                let result = JSON.parse(JSON.stringify(results));
                
                this.topicTiles = [];
                this.accordionMap = []; //Save all Data Category visibility information. Contains category(Tile), childs(Subtopic), topicLabel, topicName
                let tempTopicOptions = [];
                let tempAccordionMap = [];
                
                let tempCategoryName = this._faqObject.category; //Contains selected category from portalFAQPage
        
                Object.keys(result).forEach(function (el) {
                    if(tempCategoryName === result[el].categoryName) {
                        tempAccordionMap[result[el].topicName] = result[el];
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

        let categorySelected = topicVals.filter(topic => topic.open === true); //Check if a topic is selected

        let tempSubTopics = [];
        let subtopicVals = JSON.parse(JSON.stringify(this.accordionMap[topicName].childs)); //Get subtopics under each topic
        
        Object.keys(subtopicVals).forEach(function (el) {            
            tempSubTopics.push({ label: el, value: subtopicVals[el], class: "slds-p-left_small slds-m-around_small text-xsmall slds-p-vertical_x-small slds-p-right_small cursorPointer" });
        });

        this.subTopicTiles = [];
        this.subTopicTiles = tempSubTopics;

        let __faqObject = JSON.parse(JSON.stringify(this._faqObject));
        __faqObject.category = categorySelected.length > 0 ? '' : this.category;
        __faqObject.topic = categorySelected.length > 0 ? topicName : '';
        __faqObject.subtopic = '';

        const selectedEvent = new CustomEvent('categorieschange', { detail: __faqObject });
        this.dispatchEvent(selectedEvent);
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
        this.subTopicTiles = tempSubTopics;

        let __faqObject = JSON.parse(JSON.stringify(this._faqObject));
        __faqObject.category = '';
        __faqObject.topic = '';
        __faqObject.subtopic = subtopicName;

        const selectedEvent = new CustomEvent('categorieschange', { detail: __faqObject });
        this.dispatchEvent(selectedEvent);
    }
}
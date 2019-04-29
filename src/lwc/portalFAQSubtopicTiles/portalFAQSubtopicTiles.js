import { LightningElement, api, track, wire } from 'lwc';
import getFAQsInfo from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';

export default class PortalFAQSubtopicTiles extends LightningElement {
    @track loading = true;
    @track topicTiles;
    @track subTopicTiles;
    @track accordionMap;
    @api categoryName;

    @wire(getFAQsInfo)
    wiredFAQsInfo(results) {
        if (results.data) {
            let result = JSON.parse(JSON.stringify(results.data));
            console.log('result', result);
            
            this.topicTiles = [];
            this.accordionMap = []; //Save all Data Category visibility information. Contains category(Tile), childs(Subtopic), topicLabel, topicName
            let tempTopicOptions = [];
            let tempAccordionMap = [];
            console.log(this.categoryName);
            
            let tempCategoryName = this.categoryName;
    
            Object.keys(result).forEach(function (el) {
                tempAccordionMap[result[el].topicName] = result[el];
                if(tempCategoryName === result[el].categoryName) {
                    tempTopicOptions.push({ label: result[el].topicLabel, value: result[el].topicName });
                }
            });
            
            this.topicTiles = tempTopicOptions;
            this.accordionMap = tempAccordionMap;            
    
            this.loading = false;
        } else if (results.error) {
            console.log('error', error);
        }
    } 

    handleSectionToggle(event) {
        console.log(event.detail.openSections);
        
        let tempSubTopics = [];
        let vals = JSON.parse(JSON.stringify(this.accordionMap[event.detail.openSections].childs)); //Get subtopics under each topic

        Object.keys(vals).forEach(function (el) {
            tempSubTopics.push({ label: el, value: vals[el] });
        });

        this.subTopicTiles = [];
        this.subTopicTiles = tempSubTopics;
    }
    
    handleSubTopic(event) {
        console.log(event.target.attributes.getNamedItem('data-name').value);

        event.preventDefault();
        const selectedEvent = new CustomEvent('topicselected', { detail: event.target.attributes.getNamedItem('data-name').value });
        
        this.dispatchEvent(selectedEvent);
    }
}
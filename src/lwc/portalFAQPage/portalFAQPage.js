import { LightningElement,track } from 'lwc';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalFAQPage extends NavigationMixin(LightningElement) {

    @track categoryName = '';
    @track topicName = '';

    connectedCallback(){

        //get the parameters for this page
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.category !== undefined){ 
            console.log(pageParams.category);
                       
            this.categoryName = pageParams.category;
            console.log(this.categoryName);
        }
    }

    handleTopicSelected(event) {
        this.topicName = event.detail;
        console.log(this.topicName);
        
    }
}
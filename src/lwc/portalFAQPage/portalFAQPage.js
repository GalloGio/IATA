import { LightningElement, track } from 'lwc';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalFAQPage extends NavigationMixin(LightningElement) {

    @track faqObject = {};

    connectedCallback() {
        let _faqObject = { category: '', topic: '', subtopic: '' };

        //get the parameters for this page
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.category !== undefined){
            _faqObject.category = pageParams.category;
        }
        
        this.faqObject = _faqObject;        
    }

    categoriesChange(event) {
        this.faqObject = event.detail;
    }
}
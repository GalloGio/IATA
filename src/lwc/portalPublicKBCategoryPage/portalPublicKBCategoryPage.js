import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage } from'c/navigationUtils';

export default class PortalPublicKBCategoryPage extends NavigationMixin(LightningElement) {
    @track faqObject = {};

    connectedCallback() {
        let _faqObject = { category: '', topic: '', subtopic: '', language: '' };

        let pageParams = getParamsFromPage();

        if(pageParams !== undefined) {              
            if(pageParams.category !== undefined) _faqObject.category = pageParams.category;
            if(pageParams.language !== undefined) _faqObject.language = pageParams.language;
        }
        
        this.faqObject = _faqObject;
    }

    categoriesChange(event) {
        this.faqObject = event.detail;
    }
}
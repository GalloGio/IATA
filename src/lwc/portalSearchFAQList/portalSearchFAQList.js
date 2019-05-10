import { LightningElement, api, track } from 'lwc';
import getFaqsList from '@salesforce/apex/PortalFAQsCtrl.getFaqsList';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_FAQs_Title from '@salesforce/label/c.CSP_FAQs_Title';

export default class PortalSearchCasesList extends LightningElement {
    
    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_FAQs_Title
    };
    
    @track dataRecords = false;
    @track filteringObject;
    @track loading = true;
    @track error;
    @track data;
    @track columns = [
        {label: 'Title', fieldName: 'Title', type: 'text'},
        {label: '', fieldName: '', cellAttributes:
                { iconName: 'utility:forward', iconPosition: 'right' }}
    ];

    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }

    set filteringObjectParent(value) {
        this.filteringObject = value;
        this.searchWithNewFilters();
    }
    
    get showComponent() {
        return this.toggleComponent();
    }

    get dataRecords() {
        return this.dataRecords;
    }    

    toggleComponent() {
        return this.filteringObject !== undefined && 
            this.filteringObject.showAllComponents && 
            this.filteringObject.faqsComponent.show && 
            this.filteringObject.faqsComponent.searchable;
    }

    searchWithNewFilters() {
        if(this.toggleComponent()) {
            this.loading = true;
            getFaqsList({ refinedSearchSerialized : JSON.stringify(this.filteringObject) })
            .then(results => {
                if(results && results.length > 0) {
                    this.data = results;
                    this.dataRecords = true;
                } else {
                    this.dataRecords = false; 
                }
                this.loading = false;
            })
            .catch(error => {
                this.error = error;
                this.loading = false;
                this.dataRecords = false;
            });            
        }
    } 
}
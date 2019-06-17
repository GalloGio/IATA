import { LightningElement, api, track } from 'lwc';
import getFaqsList from '@salesforce/apex/PortalFAQsCtrl.getFaqsList';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';
//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_FAQs_Title from '@salesforce/label/c.CSP_FAQs_Title';
import CSP_Title from '@salesforce/label/c.CSP_Title';

export default class PortalSearchCasesList extends NavigationMixin(LightningElement) {
    
    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_FAQs_Title,
        CSP_Title
    };
    
    @track dataRecords = false;
    @track filteringObject;
    @track loading = true;
    @track error;
    @track data;

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
            getFaqsList({ refinedSearchSerialized : JSON.stringify(this.filteringObject), moreFields : false })
                .then(results => {
                    if(results.length) {
                        this.data = JSON.parse(JSON.stringify(results));                        
                        this.dataRecords = true;
                    } else {
                        this.dataRecords = false; 
                    }
                    this.loading = false;
                });            
        }
    }
    
    goToFAQPage() {
        let params = {};        
        params.q = this.filteringObject.searchText; // SEARCH TERM
        
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
    
    goToArticle(event) {
        let params = {};
        params.q = this.filteringObject.searchText; // SEARCH TERM
        params.id1 = event.target.attributes.getNamedItem('data-item').value; // SPECIFIC SELECTED ARTICLE

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
}
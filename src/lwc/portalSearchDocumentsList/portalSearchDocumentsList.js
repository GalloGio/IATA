import { LightningElement, api, track } from 'lwc';
import getSearchDocuments from '@salesforce/apex/PortalDocumentsController.getSearchDocuments';

export default class PortalSearchDocumentsList extends LightningElement {
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
    
    get rendered() {
        return this.toggleComponent();
    }

    get dataRecords() {
        return this.dataRecords;
    }    

    toggleComponent() {
        return this.filteringObject !== undefined &&
            this.filteringObject.showAllComponents &&
            this.filteringObject.documentsComponent.show &&
            this.filteringObject.documentsComponent.searchable;
    }

    searchWithNewFilters() {
        if(this.toggleComponent()) {
            this.loading = true;
            getSearchDocuments({ searchKey : this.filteringObject.searchText })
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
import { LightningElement, api, track } from 'lwc';
import getSearchDocuments from '@salesforce/apex/PortalDocumentsController.getSearchDocuments';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_Documents from '@salesforce/label/c.CSP_Documents';

export default class PortalSearchDocumentsList extends LightningElement {
    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_Documents
    };    
    @track dataRecords = false;
    @track filteringObject;
    @track loading = true;
    @track error;
    @track data;
    @track columns;

    fieldLabels = [
        'Title'
    ];

    connectedCallback() {
        getSelectedColumns({ sObjectType : 'ContentVersion', sObjectFields : this.fieldLabels })
        .then(results => {           
                this.columns = [
                    {label: results.Title, fieldName: 'Title', type: 'text'},
                    {label: '', fieldName: '', cellAttributes: { iconName: 'utility:forward', iconPosition: 'right' }}
                ];
        })
        .catch(error => {
            this.error = error;
        }); 
    }

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
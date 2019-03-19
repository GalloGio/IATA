import { LightningElement, api, track } from 'lwc';
import getFilteredCases from '@salesforce/apex/PortalCasesCtrl.getFilteredCases';

export default class PortalSearchCasesList extends LightningElement {
    @track dataRecords = false;
    @track filteringObject;
    @track loading = true;
    @track error;
    @track data;
    @track columns = [
        {label: 'Case Number', fieldName: 'CaseNumber', type: 'text', sortable: true},
        {label: 'Type of case', fieldName: 'Type_of_case_Portal__c', type: 'text'},
        {label: 'Subject', fieldName: 'Subject', type: 'text'},
        {label: 'Country concerned', fieldName: 'Country_concerned_by_the_query__c', type: 'text'},
        {label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}},
        {label: 'Status', fieldName: 'Portal_Case_Status__c', type: 'text'}
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
            this.filteringObject.casesComponent.show && 
            this.filteringObject.casesComponent.searchable;
    }  

    searchWithNewFilters() {
        if(this.toggleComponent()) {
            this.loading = true;
            getFilteredCases({ searchKey : this.filteringObject.searchText })
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
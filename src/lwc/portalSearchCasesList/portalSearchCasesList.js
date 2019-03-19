import { LightningElement, api, track } from 'lwc';
import getFilteredCases from '@salesforce/apex/PortalCasesCtrl.getFilteredCases';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';

export default class PortalSearchCasesList extends LightningElement {
    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_Cases
    };    
    @track dataRecords = false;
    @track filteringObject;
    @track loading = true;
    @track error;
    @track data;
    @track columns;
    fieldLabels = [
        'CaseNumber', 'Type_of_case_Portal__c', 'Subject', 'Country_concerned_by_the_query__c', 'CreatedDate', 'Portal_Case_Status__c' 
    ];

    connectedCallback() {
        getSelectedColumns({ sObjectType : 'Case', sObjectFields : this.fieldLabels })
        .then(results => {           
                this.columns = [
                    {label: results.CaseNumber, fieldName: 'CaseNumber', type: 'text'},
                    {label: results.Type_of_case_Portal__c, fieldName: 'Type_of_case_Portal__c', type: 'text'},
                    {label: results.Subject, fieldName: 'Subject', type: 'text'},
                    {label: results.Country_concerned_by_the_query__c, fieldName: 'Country_concerned_by_the_query__c', type: 'text'},
                    {label: results.CreatedDate, fieldName: 'CreatedDate', type: 'date', typeAttributes: {year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}},
                    {label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text'}
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
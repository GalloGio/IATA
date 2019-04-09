import { LightningElement, track, wire } from 'lwc';

import getRecentCases from '@salesforce/apex/PortalCasesCtrl.getRecentCases';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_NoCases1 from '@salesforce/label/c.CSP_NoCases1';
import CSP_NoCases2 from '@salesforce/label/c.CSP_NoCases2';
import CSP_RecentCases from '@salesforce/label/c.CSP_RecentCases';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_Question1 from '@salesforce/label/c.CSP_Question1';
import CSP_Question2 from '@salesforce/label/c.CSP_Question2';

export default class RecentCases extends NavigationMixin(LightningElement) {
    label = {
        CSP_NoCases1,
        CSP_NoCases2,
        CSP_RecentCases,
        CSP_SeeAll,
        CSP_Question1,
        CSP_Question2
    };
    @track error;
    @track data;
    @track columns;
    @track loading = true;
    fieldLabels = [
        'CaseNumber', 'Type_of_case_Portal__c', 'Subject', 'Country_concerned_by_the_query__c', 'Portal_Case_Status__c'
    ];
    @track casesListUrl;

    connectedCallback() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "cases-list",
            }})
        .then(url => this.casesListUrl = url);

        getSelectedColumns({ sObjectType : 'Case', sObjectFields : this.fieldLabels })
        .then(results => {           
                this.columns = [
                    {label: results.CaseNumber, fieldName: 'CaseNumber', type: 'text'},
                    {label: results.Type_of_case_Portal__c, fieldName: 'Type_of_case_Portal__c', type: 'text'},
                    {label: results.Subject, fieldName: 'Subject', type: 'text'},
                    {label: results.Country_concerned_by_the_query__c, fieldName: 'Country_concerned_by_the_query__c', type: 'text'},
                    {label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text', cellAttributes: {class: {fieldName: 'Portal_Case_Status__c'}}}
                ];
        })
        .catch(error => {
            this.error = error;
        });      
    }

    @wire(getRecentCases, { seeAll : false })
    wiredRecentCases(results) {
        this.loading = true;
        if (results.data) {
            this.data = results.data.records;
            this.loading = false;
        } else if (results.error) {
            this.error = results.error;
            this.loading = false;
        }
    }

    get dataRecords() {
        return (this.data && this.data.length) > 0 ? true : false;
    }

    seeAllCases(event) {
        event.preventDefault();
        event.stopPropagation();

        navigateToPage(this.casesListUrl, {});
    }
}
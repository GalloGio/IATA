import { LightningElement, track, wire } from 'lwc';
import getRecentCases from '@salesforce/apex/PortalCasesCtrl.getRecentCases';
import CSP_NoCases1 from '@salesforce/label/c.CSP_NoCases1';
import CSP_NoCases2 from '@salesforce/label/c.CSP_NoCases2';
import ISSP_CountryConcerned from '@salesforce/label/c.ISSP_CountryConcerned';
import CSP_CaseNumber from '@salesforce/label/c.CSP_CaseNumber';
import CSP_TypeOfCase from '@salesforce/label/c.CSP_TypeOfCase';
import CurrencyCenter_Subject from '@salesforce/label/c.CurrencyCenter_Subject';
import Created_Date from '@salesforce/label/c.Created_Date';
import CSP_Status from '@salesforce/label/c.CSP_Status';
import CSP_RecentCases from '@salesforce/label/c.CSP_RecentCases';

export default class RecentCases extends LightningElement {
    label = {
        CSP_NoCases1,
        CSP_NoCases2,
        ISSP_CountryConcerned,
        CSP_CaseNumber,
        CSP_TypeOfCase,
        CurrencyCenter_Subject,
        Created_Date,
        CSP_Status,
        CSP_RecentCases
    };
    
    @track error;
    @track data;
    @track columns = [
        { label: this.label.CSP_CaseNumber, fieldName: 'CaseNumber', type: 'text' },
        { label: this.label.CSP_TypeOfCase, fieldName: 'Type_of_case_Portal__c', type: 'text' },
        { label: this.label.CurrencyCenter_Subject, fieldName: 'Subject', type: 'text' },
        { label: this.label.ISSP_CountryConcerned, fieldName: 'Country_concerned_by_the_query__c', type: 'text' },
        { label: this.label.Created_Date, fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
        { label: this.label.CSP_Status, fieldName: 'Portal_Case_Status__c', type: 'text' }
    ];
    @track loading = true;

    @wire(getRecentCases)
    wiredRecentCases(results) {
        this.loading = true;
        if (results.data) {
            this.data = results.data;
            this.loading = false;
        } else if (results.error) {
            this.error = results.error;
            this.loading = false;
        }
    }

    get dataRecords() {
        return (this.data && this.data.length) > 0 ? true : false;
    }
}
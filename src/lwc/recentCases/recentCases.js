import { LightningElement, track, wire } from 'lwc';
import getRecentCases from '@salesforce/apex/PortalCasesCtrl.getRecentCases';

export default class RecentCases extends LightningElement {
    @track error;
    @track data;
    @track columns = [
        { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
        { label: 'Type of case', fieldName: 'Type_of_case_Portal__c', type: 'text' },
        { label: 'Subject', fieldName: 'Subject', type: 'text' },
        { label: 'Country concerned', fieldName: 'Country_concerned_by_the_query__c', type: 'text' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: { year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit" } },
        { label: 'Status', fieldName: 'Portal_Case_Status__c', type: 'text' }
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
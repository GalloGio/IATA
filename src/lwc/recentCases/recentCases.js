import { LightningElement, track, wire, api } from 'lwc';

import getRecentCases from '@salesforce/apex/PortalCasesCtrl.getRecentCases';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

import CSP_RecentCases from '@salesforce/label/c.CSP_RecentCases';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_RecentCases_Support from '@salesforce/label/c.CSP_RecentCases_Support';
import CSP_RecentCases_HelpText from '@salesforce/label/c.CSP_RecentCases_HelpText';
import CSP_RecentCases_HelpText2 from '@salesforce/label/c.CSP_RecentCases_HelpText2';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class RecentCases extends NavigationMixin(LightningElement) {
    label = {
        CSP_RecentCases,
        CSP_SeeAll,
        CSP_RecentCases_Support,
        CSP_RecentCases_HelpText,
        CSP_RecentCases_HelpText2
    };

    @track data;
    @track columns;
    @track loading = true;
    fieldLabels = [
        'CaseNumber', 'Type_of_case_Portal__c', 'Subject', 'Country_concerned__c', 'Portal_Case_Status__c'
    ];
    @track casesListUrl;

    @track homePageLocal = true;
    @api
    get homePage() {
        return this.homePageLocal;
    }

    set homePage(value) {
       this.homePageLocal = value;
    }

    @api specialCase = false;

    @track title = "";
    @track helpText = "";
    @track titleCss = "";
    @track cardBodyContent;
    @track rowHeight = "";

    connectedCallback() {

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "cases-list",
            }
        })
        .then(url => this.casesListUrl = url);

        getSelectedColumns({ sObjectType: 'Case', sObjectFields: this.fieldLabels })
        .then(results => {
            if(this.homePageLocal === true){
                this.title = this.label.CSP_RecentCases;
                this.titleCss = "text-small";
                this.cardBodyContent = "cardBodyContent";
                this.rowHeight = "";
                this.columns = [
                    { label: results.CaseNumber, fieldName: 'CaseURL', type: 'url', initialWidth: 137, typeAttributes: {label: {fieldName: 'CaseNumber'}, target:'_self',tooltip: {fieldName: 'CaseNumber'}} },
                    { label: results.Type_of_case_Portal__c, fieldName: 'Type_of_case_Portal__c', type: 'text', initialWidth: 130 },
                    { label: results.Subject, fieldName: 'CaseURL', type: 'url', typeAttributes: {label: {fieldName: 'Subject'}, target:'_self',tooltip:{fieldName: 'Subject'}}, cellAttributes: {class: 'slds-text-title_bold text-black'} },
                    { label: results.Country_concerned__c, fieldName: 'Country', type: 'text' },
                    { label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text', initialWidth: 140, cellAttributes: { class: { fieldName: 'statusClass' } } }
                ];
            } else {
                this.title = this.label.CSP_RecentCases_Support;
                this.helpText = this.label.CSP_RecentCases_HelpText;
                this.helpText2 = this.label.CSP_RecentCases_HelpText2;
                this.titleCss = "text-medium text-bold slds-align_absolute-center";
                this.cardBodyContent = "cardBodyContentSmall";
                this.rowHeight = "rowHeight";
                this.columns = [
                    { label: results.CaseNumber, fieldName: 'CaseURL', type: 'url', initialWidth: 130, typeAttributes: {label: {fieldName: 'CaseNumber'}, target:'_self'} },
                    { label: results.Subject, fieldName: 'CaseURL', type: 'url', typeAttributes: {label: {fieldName: 'Subject'}, target:'_self'}, cellAttributes: {class: 'slds-text-title_bold text-black'} },
                    { label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text', initialWidth: 120, cellAttributes: { class: { fieldName: 'statusClass' } } }
                ];
            }
            
        });

    }

    @wire(getRecentCases, { limitView: true, seeAll: false, specialCaseOption: '$specialCase' })
    wiredRecentCases(results) {
        this.loading = true;
        if (results.data) {
            let allDataAux = JSON.parse(JSON.stringify(results.data));
            let urlMap = JSON.parse(allDataAux.url);

            for(let i = 0; i < allDataAux.records.length; i++) {
                let row = allDataAux.records[i];
                row.CaseURL = urlMap[row.Id];
                row.Country = row.Country_concerned_by_the_query__c;
                row.statusClass= row.Status.replace(/\s/g, '').replace(/_|-|\./g, '');
            }
            this.data = allDataAux.records;

            if (this.data.length === 0 && this.specialCase){
                this.dispatchEvent(new CustomEvent('checkemptylist'));
            }

            this.loading = false;
        } else if (results.error) {
            this.loading = false;
            if(this.specialCase) this.dispatchEvent(new CustomEvent('checkemptylist'));
        }
    }

    get dataRecords() {
        return (this.data && this.data.length) > 0 ? true : false;
    }

    get dataRecordsSeeAll() {
        return (this.data && this.data.length && this.homePageLocal) > 0 ? true : false;
    }

    seeAllCases(event) {
        event.preventDefault();
        event.stopPropagation();

        navigateToPage(this.casesListUrl, {});
    }

    get tableClass(){
        return this.specialCase?'slds-p-top_x-small':'';
    }

}

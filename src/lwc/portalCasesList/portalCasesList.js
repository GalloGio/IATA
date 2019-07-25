import { LightningElement, track } from 'lwc';

//import other js utils
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//import apex methods
import getRecentCases from '@salesforce/apex/PortalCasesCtrl.getRecentCases';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';

//import labels
import CSP_NoCases1 from '@salesforce/label/c.CSP_NoCases1';
import CSP_NoCases2 from '@salesforce/label/c.CSP_NoCases2';
import CSP_RecentCases from '@salesforce/label/c.CSP_RecentCases';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_Question1 from '@salesforce/label/c.CSP_Question1';
import CSP_Question2 from '@salesforce/label/c.CSP_Question2';
import Created_By from '@salesforce/label/c.Created_By';
import CSP_MyCases from '@salesforce/label/c.CSP_MyCases';
import CSP_CompanyCases from '@salesforce/label/c.CSP_CompanyCases';
import CSP_SearchingOn from '@salesforce/label/c.CSP_SearchingOn';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCasesList extends NavigationMixin(LightningElement) {
    
    //assets 
    noCasesImg = CSP_PortalPath + 'CSPortal/Images/Icons/nocases.svg';

    label = {
        CSP_NoCases1,
        CSP_NoCases2,
        CSP_RecentCases,
        CSP_SeeAll,
        CSP_Question1,
        CSP_Question2,
        Created_By,
        CSP_MyCases,
        CSP_CompanyCases,
        CSP_SearchingOn
    };
    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    @track data;
    @track allData;
    @track columns;
    @track loading = true;
    fieldLabels = [
        'CaseNumber', 'Type_of_case_Portal__c', 'Subject', 'Country_concerned__c', 'LastModifiedDate', 'Portal_Case_Status__c'
    ];
    @track isAdmin;
    @track pageNumber = 1;
    @track totalPages;
    @track pageSize = 10;
    @track pageList = [];
    @track seeAll = false;
    @track caseListName = CSP_CompanyCases;
    @track cacheableAllData = '';
    @track cacheableData = '';
    @track cacheablePage = '';
    @track cacheableList = '';
    @track cacheableTotalPage = '';
    @track cacheablePageList = '';

    connectedCallback() {
        getSelectedColumns({ sObjectType : 'Case', sObjectFields : this.fieldLabels })
        .then(results => {
                this.columns = [
                    {label: results.CaseNumber, fieldName: 'CaseURL', type: 'url', initialWidth: 135, typeAttributes: {label: {fieldName: 'CaseNumber'}, target:'_self'}},
                    {label: results.Type_of_case_Portal__c, fieldName: 'Type_of_case_Portal__c', type: 'text', initialWidth: 135},
                    {label: results.Subject, fieldName: 'CaseURL', type: 'url', initialWidth: 350, typeAttributes: {label: {fieldName: 'Subject'}, target:'_self'}, cellAttributes: {class: 'slds-text-title_bold text-black'}},
                    {label: Created_By, fieldName: 'CreatedBy', type: 'text'},
                    {label: results.LastModifiedDate, fieldName: 'LastModifiedDate', type: 'date', typeAttributes: {year: "numeric", month: "short", day: "2-digit", hour: "2-digit", minute: "2-digit"}},
                    {label: results.Country_concerned__c, fieldName: 'Country', type: 'text'},
                    {label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text', initialWidth: 140, cellAttributes: {class: {fieldName: 'statusClass'}}}
                ];
                /*Column 'Created By' is only visible by Portal Admin on list 'My Company Cases'*/
                this.columnsAux = this.columns[3];
                this.columns = this.columns.slice(0, 3).concat(this.columns.slice(4));
        });
        
        this.renderCases();
    }

    renderCases() {        
        getRecentCases({ limitView: false, seeAll: this.seeAll })
            .then(results => {
                let allDataAux = JSON.parse(JSON.stringify(results));
                let urlMap = JSON.parse(allDataAux.url);
                
                for(let i = 0; i < allDataAux.records.length; i++) {
                    let row = allDataAux.records[i];
                    row.CaseURL = urlMap[row.Id];
                    row.CreatedBy = row.CreatedBy.Name;
                    row.Country = row.Country_concerned_by_the_query__c;
                    row.statusClass= row.Status.replace(/\s/g, '').replace(/_|-|\./g, '');
                }
                
                this.allData = allDataAux.records;     
                this.totalPages = Math.ceil(allDataAux.totalItemCount / this.pageSize);
                this.isAdmin = allDataAux.userAdmin;
                this.loading = false;
                this.buildData();
            })
            .catch(error => {
                this.loading = false;
            }
        );         
    }

    get dataRecords() {
        return (this.data && this.data.length) > 0 ? true : false;
    }

    get isAdminUser() {
        return this.isAdmin;
    }

    rerenderCases() {
        if(this.isAdmin) {
            this.loading = true;
            /*Clear cacheable data when toggle between lists*/
            this.clearCache();
            
            if(!this.seeAll) {
                this.columns = this.columns.slice(0, 3).concat([this.columnsAux]).concat(this.columns.slice(3)); /*Inserting 'Created By' column*/
                this.caseListName = CSP_MyCases;
                this.seeAll = true;
                this.pageNumber = 1;            
            } else {
                this.columns = this.columns.slice(0, 3).concat(this.columns.slice(4)); /*Removing 'Created By' column*/
                this.caseListName = CSP_CompanyCases;
                this.seeAll = false;
                this.pageNumber = 1;
            }
        }

        this.renderCases();
    }

    /*SEARCH METHODS*/
    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey && event.target.value.length > 0) {
            /*Caching non-filtered list, original one*/
            this.cacheableAllData = this.cacheableAllData === '' ? this.allData : this.cacheableAllData;
            this.cacheableData = this.cacheableData === '' ? this.data : this.cacheableData;
            this.cacheablePage = this.cacheablePage === '' ? this.pageNumber : this.cacheablePage;
            this.cacheableList = this.cacheableList === '' ? this.caseListName : this.cacheableList;
            this.cacheableTotalPage = this.cacheableTotalPage === '' ? this.totalPages : this.cacheableTotalPage;
            this.cacheablePageList = this.cacheablePageList === '' ? this.pageList : this.cacheablePageList;    

            this.handleSearch(event.target.value);
        }
    }

    handleInputChange(event) {
        if(event.target.value === '') {            
            /*Retrieving non-filtered list, original one*/
            this.allData = this.cacheableAllData !== '' ? this.cacheableAllData : this.allData;
            this.data = this.cacheableData !== '' ? this.cacheableData : this.data;
            this.pageNumber = this.cacheablePage !== '' ? this.cacheablePage : this.pageNumber;
            this.caseListName = this.cacheableList !== '' ? this.cacheableList : this.caseListName;
            this.totalPages = this.cacheableTotalPage !== '' ? this.cacheableTotalPage : this.totalPages;
            this.pageList = this.cacheablePageList !== '' ? this.cacheablePageList : this.pageList;

            /*Clear cacheable data when finish the search*/
            this.clearCache();
        }
    }

    handleSearch(text) {
        this.loading = true;
        let currentData = [];
        let allDataAux = JSON.parse(JSON.stringify(this.cacheableAllData));

        for(let i = 0; i < allDataAux.length; i++) {
            if(allDataAux[i].CaseNumber.includes(text) || allDataAux[i].Subject.includes(text)) {
                currentData.push(allDataAux[i]);
            }
        }

        this.allData = currentData;
        this.totalPages = Math.ceil(currentData.length / this.pageSize);
        this.pageNumber = 1;

        this.loading = false;

        this.buildData();
    }

    clearCache() {
        this.cacheableAllData = '';
        this.cacheableData = '';
        this.cacheablePage = '';
        this.cacheableList = '';
        this.cacheableTotalPage = '';
        this.cacheablePageList = '';
    }
    /*SEARCH METHODS*/
    
    /*PAGINATION METHODS*/
    handlePreviousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.buildData();
    }

    handleNextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.buildData();
    }
    
    handleFirstPage() {
        this.pageNumber = 1;
        this.buildData();
    }

    handleLastPage() {
        this.pageNumber = this.totalPages;
        this.buildData();
    }

    handleSelectedPage(event) {
        this.pageNumber = event.detail;
        this.buildData();
    }
    
    buildData() {
        let currentData = [];
        let currentPageNumber = this.pageNumber;
        let currentPageSize = this.pageSize;
        let currentAllData = this.allData;
        let x = (this.pageNumber - 1) * this.pageSize;
        
        for(; x <= (currentPageNumber * currentPageSize) - 1; x++) {         
            if(currentAllData[x]) {
            	currentData.push(currentAllData[x]);
            }
        }

        this.data = currentData;
             
        this.generatePageList();
    }

    generatePageList() {
        let currentPageList = [];
        let currentTotalPages = this.totalPages;        
        
        if (currentTotalPages > 1) {
            if(currentTotalPages <= 10) {
                let counter = 2;
                for(; counter < currentTotalPages; counter++) {
                    currentPageList.push(counter);
                }
            } else {
                if(this.pageNumber < 5) {
                    currentPageList.push(2, 3, 4, 5, 6);
                } else {
                    if(this.pageNumber > (currentTotalPages - 5)) {
                        currentPageList.push(currentTotalPages-5, currentTotalPages-4, currentTotalPages-3, currentTotalPages-2, currentTotalPages-1);
                    } else {
                        currentPageList.push(this.pageNumber-2, this.pageNumber-1, this.pageNumber, this.pageNumber+1, this.pageNumber+2);
                    }
                }
            }
        }
        
        this.pageList = currentPageList;
    }
    
    navigateToLinkOne(event) {
        let params = {};
        params.q = 'case';

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
    navigateToLinkTwo(event) {
        let params = {};
        params.q = 'case';

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
}
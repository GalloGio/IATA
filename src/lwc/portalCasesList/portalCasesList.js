import { LightningElement, track } from 'lwc';

//import other js utils
import { NavigationMixin } from 'lightning/navigation';

//import apex methods
import getFilteredCasesResultsPage from '@salesforce/apex/PortalCasesCtrl.getFilteredCasesResultsPage';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import getCountryList from '@salesforce/apex/PortalSupportReachUsCtrl.getCountryList';
import companyCasesContactsPicklist from '@salesforce/apex/PortalCasesCtrl.companyCasesContactsPicklist';

//import labels
import CSP_RecentCases from '@salesforce/label/c.CSP_RecentCases';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import Created_By from '@salesforce/label/c.Created_By';
import CSP_MyCases from '@salesforce/label/c.CSP_MyCases';
import CSP_CompanyCases from '@salesforce/label/c.CSP_CompanyCases';
import CSP_SearchingOn from '@salesforce/label/c.CSP_SearchingOn';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalCasesList extends NavigationMixin(LightningElement) {

    label = {
        CSP_RecentCases,
        CSP_SeeAll,
        Created_By,
        CSP_MyCases,
        CSP_CompanyCases,
        CSP_SearchingOn
    };

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    fieldLabels = [
        'CaseNumber', 'Type_of_case_Portal__c', 'Subject', 'Country_concerned__c', 'LastModifiedDate', 'Portal_Case_Status__c'
    ];

    @track columns; // shows the current used datatable columns
    @track loading = true; //page loading

    @track filteringObject = {
        searchText : "",
        casesComponent : {
            loading : true,
            nrResults : 0, 
            caseTypeFilter : "",
            caseCountryFilter : "",
            caseContactFilter : ""
        }
    };

    @track casesList = [];

    @track columns;

    pageNumber = -1;
    totalResults = 0;

    @track isAdminUser = false; //stores the boolean if the current user is admin or not

    @track loadingMoreResults = false; //loading more results to the datatable

    @track viewCasesFiltersModal = false; //toggle for the popup

    @track countryPickOptions = []; 
    @track contactPickOptions = [];

    connectedCallback() {

        isAdmin({})
        .then(results => {
            this.isAdminUser = results;
        });

        getCountryList()
        .then(result => {
            let myResult = JSON.parse(JSON.stringify(result));
            let myCountryOptions = [];
            let auxmyCountryOptions = [];
            Object.keys(myResult).forEach(function (el) {
                auxmyCountryOptions.push({ label: myResult[el], value: el });
            });
            //used to order alphabetically
            auxmyCountryOptions.sort((a, b) => { return (a.label).localeCompare(b.label) });
            myCountryOptions = myCountryOptions.concat(auxmyCountryOptions);
            this.countryPickOptions = this.getPickWithAllValue(myCountryOptions);
        });

        companyCasesContactsPicklist({})
        .then(result => {
            this.contactPickOptions = this.getPickWithAllValue(result);
        });

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

        this.resetPagination();
        this.searchWithNewFilters();

        document.addEventListener('scroll', () => {
            this.casesScrollListener();
        }, this);

    }

    casesScrollListener(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let casesListAux = JSON.parse(JSON.stringify(this.casesList));

        //if the component is highlighted, and it's not loading and still have more results to fetch, verifies if the scroll is in the 
        // right position to call the next batch of results
        if(this.loading === false && this.loadingMoreResults === false
            && (casesListAux.length < filteringObjectAux.casesComponent.nrResults) && filteringObjectAux.casesComponent.nrResults > 0 ){
            
            let divToTop = this.template.querySelectorAll('.endOfTableCases')[0].getBoundingClientRect().top;
            let windowSize = window.innerHeight;
            let offset = (windowSize/10)*2; // 20% of the screen size to get more sesults

            if(divToTop < windowSize-offset){
                // update table
                this.searchWithNewFilters();
                this.loadingMoreResults = true;
            }
        }

    }

    get viewResults(){
        let casesListAux = JSON.parse(JSON.stringify(this.casesList)); 
        return casesListAux !== undefined && casesListAux.length > 0;
    }

    searchWithNewFilters() {
        if(this.filteringObject !== undefined) {
            
            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

            filteringObjectAux.casesComponent.nrResults = 0;

            if(this.pageNumber < 0 ){
                this.loading = true;
            }else{
                this.loadingMoreResults = true;
            }
            
            this.filteringObject = filteringObjectAux;

            this.retrieveResultsFromServer();
            
        }
    }

    resetPagination(){
        this.pageNumber = -1;
        this.totalResults = 0;
        this.casesList = [];
    }

    retrieveResultsFromServer(){

        let requestedPageNumber = this.pageNumber + 1;
        this.pageNumber = requestedPageNumber;

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let params = { searchKey : JSON.stringify(filteringObjectAux) , requestedPage : requestedPageNumber+'' , isAdminUser : this.adminView };
        //console.log(params);
        getFilteredCasesResultsPage(params)
        .then(results => {

            if(results.records && results.records.length > 0) {
                let allDataAux = JSON.parse(JSON.stringify(results));
                //console.log(allDataAux);
                let urlMap = JSON.parse(allDataAux.url);

                for(let i = 0; i < allDataAux.records.length; i++) {
                    let row = allDataAux.records[i];
                    row.CaseURL = urlMap[row.Id];
                    row.Country = row.Country_concerned_by_the_query__c;
                    row.CreatedBy = row.CreatedBy.Name;
                    row.statusClass= row.Status.replace(/\s/g, '').replace(/_|-|\./g, '');
                }

                let casesListAux = this.casesList.concat(allDataAux.records);
                this.casesList = casesListAux;

            }else{
                this.casesList = [];
            }

            filteringObjectAux.casesComponent.nrResults = results.totalItemCount;
            
            if(this.pageNumber < 1 ){
                this.loading = false;
            }else{
                this.loadingMoreResults = false;
            }

            this.filteringObject = filteringObjectAux;
        })
        .catch(error => {
            //something went wrong, stop loading
            filteringObjectAux.casesComponent.nrResults = 0;
            this.loading = false;

            this.filteringObject = filteringObjectAux;

            this.casesList = [];
            this.loadingMoreResults = false;
        });

    }

    handleKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            //search again
            this.resetPagination();
            this.searchWithNewFilters();
        }
    }

    handleInputChange(event) {      
        //update filtering object
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux.searchText = event.target.value;
        this.filteringObject = filteringObjectAux;
    }


    @track normalView = true; //stores if the user is viewing it's own cases
    @track adminView = false; //stores if the user is viewing company cases

    get viewNormalUserCasesTableViewButton(){
        return this.adminView === true && this.isAdminUser === true;
    }

    get viewAdminUserCasesTableViewButton(){
        return this.normalView === true && this.isAdminUser === true;
    }

    get viewContactsFilterPicklist(){
        return this.isAdminUser === true && this.adminView === true;
    }

    changeToUserCasesTableView(){
        this.loading = true;

        this.normalView = true;
        this.adminView = false;

        this.resetFiltersMethod();

        this.columns = this.columns.slice(0, 3).concat(this.columns.slice(4)); /*Removing 'Created By' column*/

        this.resetPagination();
        this.searchWithNewFilters();
    }

    changeToAdminCasesTableView(){
        this.loading = true;

        this.normalView = false;
        this.adminView = true;

        this.resetFiltersMethod();

        this.columns = this.columns.slice(0, 3).concat([this.columnsAux]).concat(this.columns.slice(3)); /*Inserting 'Created By' column*/

        this.resetPagination();
        this.searchWithNewFilters();
    }

    //used to store the filter options while the popup is open
    countryFiltersTemp = '';
    contactFiltersTemp = '';

    openCasesFilterModal(){
        this.viewCasesFiltersModal = true;
    }

    closeCasesFilterModal(){
        this.viewCasesFiltersModal = false;
    }

    countryPickOnchangeHandler(event){
        let selectedValue = event.detail.value;
        this.countryFiltersTemp = selectedValue;
    }

    //handles contact selection
    contactPickOnchangeHandler(event) {
        let selectedValue = event.detail.value;
        this.contactFiltersTemp = selectedValue;
    }

    applyFilters(event){
        //update filtering object
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux.casesComponent.caseCountryFilter = this.countryFiltersTemp;
        filteringObjectAux.casesComponent.caseContactFilter = this.contactFiltersTemp;
        this.filteringObject = filteringObjectAux;

        //close modal
        this.viewCasesFiltersModal = false;

        //search again
        this.resetPagination();
        this.searchWithNewFilters();
    }

    resetFilters(event){
        this.resetFiltersMethod();

        //close modal
        this.viewCasesFiltersModal = false;

        //search again
        this.resetPagination();
        this.searchWithNewFilters();
    }

    resetFiltersMethod(){
        this.countryFiltersTemp = '';
        this.contactFiltersTemp = '';

        //update filtering object
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux.searchText = '';
        filteringObjectAux.casesComponent.caseCountryFilter = this.countryFiltersTemp;
        filteringObjectAux.casesComponent.caseContactFilter = this.contactFiltersTemp;
        this.filteringObject = filteringObjectAux;
    }

    getPickWithAllValue(picklist){
        let picklistAux = [{checked: false, label: '', value: ''}];
        return picklistAux.concat(picklist);
    }
    
}
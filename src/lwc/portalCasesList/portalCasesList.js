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
import CSP_Filter from '@salesforce/label/c.CSP_Filter';
import CSP_Filtered from '@salesforce/label/c.CSP_Filtered';
import CSP_Search_Case_Country from '@salesforce/label/c.CSP_Search_Case_Country';
import ISSP_Contact from '@salesforce/label/c.ISSP_Contact';
import CSP_DateFrom from '@salesforce/label/c.CSP_DateFrom';
import CSP_DateTo from '@salesforce/label/c.CSP_DateTo';
import CSP_RemoveAllFilters from '@salesforce/label/c.CSP_RemoveAllFilters';
import CSP_Apply from '@salesforce/label/c.CSP_Apply';
import CSP_FAQReachUsBanner_ButtonText from '@salesforce/label/c.CSP_FAQReachUsBanner_ButtonText';

export default class PortalCasesList extends NavigationMixin(LightningElement) {

    @track label = {
        CSP_RecentCases,
        CSP_SeeAll,
        Created_By,
        CSP_MyCases,
        CSP_CompanyCases,
        CSP_SearchingOn,
        CSP_Filter,
        CSP_Filtered,
        CSP_Search_Case_Country,
        ISSP_Contact,
        CSP_DateFrom,
        CSP_DateTo,
        CSP_RemoveAllFilters,
        CSP_FAQReachUsBanner_ButtonText,
        CSP_Apply
    };

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    filterIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/filter.svg';
    filteredIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/filtered.svg';

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
            caseContactFilter : "",
            dateFromFilter : "",
            dateToFilter : ""
        }
    };

    @track casesList = [];

    @track columns;

    pageNumber = -1;
    totalResults = 0;

    @track isAdminUser = false; //stores the boolean if the current user is admin or not

    @track viewCasesFiltersModal = false; //toggle for the popup

    @track countryPickOptions = [];
    @track contactPickOptions = [];

    @track normalView = true; //stores if the user is viewing it's own cases
    @track adminView = false; //stores if the user is viewing company cases
    @track filtered = false;

    @track paginationObject = {
        totalItems: 10,
        currentPage: 1,
        pageSize: 10,
        maxPages: 3
    }

    get viewNormalUserCasesTableViewButton() {
        return this.adminView === true && this.isAdminUser === true;
    }

    get viewAdminUserCasesTableViewButton(){
        return this.normalView === true && this.isAdminUser === true;
    }

    get viewContactsFilterPicklist(){
        return this.isAdminUser === true && this.adminView === true;
    }

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
                {label: results.CaseNumber, fieldName: 'CaseURL', type: 'url', initialWidth: 135, typeAttributes: {label: {fieldName: 'CaseNumber'}, target:'_self', tooltip: {fieldName: 'CaseNumber'}}},
                {label: results.Type_of_case_Portal__c, fieldName: 'Type_of_case_Portal__c', type: 'text', initialWidth: 135, cellAttributes: {class: 'cellHidden'}},
                {label: results.Subject, fieldName: 'CaseURL', type: 'url', initialWidth: 350, typeAttributes: {label: {fieldName: 'Subject'}, target:'_self', tooltip: {fieldName: 'Subject'}}, cellAttributes: {class: 'slds-text-title_bold text-black'}},
                {label: ISSP_Contact, fieldName: 'ContactName', type: 'text'},
                {label: results.LastModifiedDate, fieldName: 'LastModifiedDate', type: 'date', typeAttributes: {year: "numeric", month: "short", day: "2-digit", hour: "2-digit", minute: "2-digit"}, cellAttributes: {class: 'cellHidden'}},
                {label: results.Country_concerned__c, fieldName: 'Country', type: 'text', cellAttributes: {class: 'cellHidden'}},
                {label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text', initialWidth: 140, typeAttributes: {target:'_self'}, cellAttributes: {class: {fieldName: 'statusClass' }}}
            ];
            /*Column 'Created By' is only visible by Portal Admin on list 'My Company Cases'*/
            this.columnsAux = this.columns[3];
            this.columns = this.columns.slice(0, 3).concat(this.columns.slice(4));
        });

        this.resetPagination();
        this.searchWithNewFilters();

    }

    get viewResults() {
        let casesListAux = JSON.parse(JSON.stringify(this.casesList));
        return casesListAux !== undefined && casesListAux.length > 0;
    }

    searchWithNewFilters() {
        if(this.filteringObject !== undefined) {

            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

            filteringObjectAux.casesComponent.nrResults = 0;

                this.loading = true;

            this.filteringObject = filteringObjectAux;

            this.retrieveResultsFromServer();

        }
    }

    resetPagination() {
        this.paginationObject = {
            totalItems: this.casesList.length,
            currentPage: 1,
            pageSize: 10,
            maxPages: 3
        }
        this.pageNumber = -1;
        this.totalResults = 0;
        this.casesList = [];
    }

    retrieveResultsFromServer() {
        if (this.pageNumber < 0) {
            //first call
            let requestedPageNumber = this.pageNumber + 1;
            this.pageNumber = requestedPageNumber;
        }
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let params = { searchKey: JSON.stringify(filteringObjectAux), requestedPage: this.pageNumber + '', isAdminUser: this.adminView };
        getFilteredCasesResultsPage(params)
            .then(results => {
                if (results.records && results.records.length > 0) {
                    let allDataAux = JSON.parse(JSON.stringify(results));

                    let urlMap = JSON.parse(allDataAux.url);

                    for (let i = 0; i < allDataAux.records.length; i++) {
                        let row = allDataAux.records[i];
                        row.CaseURL = urlMap[row.Id];
                        row.Country = row.Country_concerned_by_the_query__c;
                        row.ContactName = row.Contact.Name;
                        row.statusClass = row.Status.replace(/\s/g, '').replace(/_|-|\./g, '') + ' cellHidden';
                    }

                    let casesListAux = allDataAux.records;
                    this.casesList = casesListAux;
                    let paginationObjectAux = JSON.parse(JSON.stringify(this.paginationObject));
                    paginationObjectAux.totalItems = allDataAux.totalItemCount;
                    this.paginationObject = paginationObjectAux;

                } else {
                    this.casesList = [];
                }


            filteringObjectAux.casesComponent.nrResults = results.totalItemCount;
                this.loading = false;
            this.filteringObject = filteringObjectAux;
        })
        .catch(error => {
            //something went wrong, stop loading
            filteringObjectAux.casesComponent.nrResults = 0;
            this.loading = false;

            this.filteringObject = filteringObjectAux;

                this.casesList = [];
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
    dateFromFiltersTemp = '';
    dateToFiltersTemp = '';

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

    dateFromOnchangeHandler(event) {
        let selectedValue = event.detail.value;
        this.dateFromFiltersTemp = selectedValue;
    }

    dateToOnchangeHandler(event) {
        let selectedValue = event.detail.value;
        this.dateToFiltersTemp = selectedValue;
    }

    applyFilters(){
        this.filtered = true;

        //update filtering object
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux.casesComponent.caseCountryFilter = this.countryFiltersTemp;
        filteringObjectAux.casesComponent.caseContactFilter = this.contactFiltersTemp;
        filteringObjectAux.casesComponent.dateFromFilter = this.dateFromFiltersTemp;
        filteringObjectAux.casesComponent.dateToFilter = this.dateToFiltersTemp;
        this.filteringObject = filteringObjectAux;

        //close modal
        this.viewCasesFiltersModal = false;

        //search again
        this.resetPagination();
        this.searchWithNewFilters();
    }

    resetFilters(){
        this.filtered = false;

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
        this.dateFromFiltersTemp = '';
        this.dateToFiltersTemp = '';

        //update filtering object
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux.searchText = '';
        filteringObjectAux.casesComponent.caseCountryFilter = this.countryFiltersTemp;
        filteringObjectAux.casesComponent.caseContactFilter = this.contactFiltersTemp;
        filteringObjectAux.casesComponent.dateFromFilter = this.dateFromFiltersTemp;
        filteringObjectAux.casesComponent.dateToFilter = this.dateToFiltersTemp;
        this.filteringObject = filteringObjectAux;
    }

    getPickWithAllValue(picklist){
        let picklistAux = [{checked: false, label: 'All', value: ''}];
        return picklistAux.concat(picklist);
    }

    handleSelectedPage(event) {
        //the event contains the selected page
        this.loading = true;
        let requestedPage = event.detail;
        this.pageNumber = requestedPage - 1;
        let paginationObjectAux = JSON.parse(JSON.stringify(this.paginationObject));
        paginationObjectAux.currentPage = requestedPage;
        this.paginationObject = paginationObjectAux;
        this.retrieveResultsFromServer();
	}

	openReachUs() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-reach-us"
            },
        });
    }

}

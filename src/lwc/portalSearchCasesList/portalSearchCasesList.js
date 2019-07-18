import { LightningElement, api, track } from 'lwc';

//import other libraries
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import apex methods
import getFilteredCasesResultsPage from '@salesforce/apex/PortalCasesCtrl.getFilteredCasesResultsPage';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';

export default class PortalSearchCasesList extends NavigationMixin(LightningElement) {

    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        let valueAux = JSON.parse(JSON.stringify(value));

        if(this.filteringObject !== undefined){
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
            this.filteringObject = valueAux;
            //if any changes in these fileds, then apply new search for this component
            if(valueAux.searchText !== filteringObjectAux.searchText || 
                valueAux.casesComponent.highlight !== filteringObjectAux.casesComponent.highlight || 
                valueAux.casesComponent.show !== filteringObjectAux.casesComponent.show || 
                valueAux.casesComponent.caseTypeFilter !== filteringObjectAux.casesComponent.caseTypeFilter || 
                valueAux.casesComponent.caseCountryFilter !== filteringObjectAux.casesComponent.caseCountryFilter ){
                this.resetPagination();
                this.searchWithNewFilters();
            }
        }else{
            this.filteringObject = valueAux;
            this.searchWithNewFilters();
        }
    }

    @api advancedSearch = false;

    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_Cases
    };

    @track filteringObject;

    @track casesList = [];

    @track columns;

    pageNumber = -1;
    totalResults = 0;

    @track isAdmin = false;

    @track loadingMoreResults = false;


    fieldLabels = [
        'CaseNumber', 'Type_of_case_Portal__c', 'Subject', 'Country_concerned__c', 'CreatedDate', 'Portal_Case_Status__c' 
    ];

    connectedCallback() {
        getSelectedColumns({ sObjectType : 'Case', sObjectFields : this.fieldLabels })
        .then(results => {           
            this.columns = [
                {label: results.CaseNumber, fieldName: 'CaseURL', type: 'url', typeAttributes: {label: {fieldName: 'CaseNumber'}, target:'_self'} },
                {label: results.Type_of_case_Portal__c, fieldName: 'Type_of_case_Portal__c', type: 'text'},
                {label: results.Subject, fieldName: 'CaseURL', type: 'url', typeAttributes: {label: {fieldName: 'Subject'}, target:'_self'}, cellAttributes: {class: 'slds-text-title_bold text-black'} },
                {label: results.Country_concerned__c, fieldName: 'Country', type: 'text'},
                {label: results.CreatedDate, fieldName: 'CreatedDate', type: 'date', typeAttributes: {year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}},
                {label: results.Portal_Case_Status__c, fieldName: 'Portal_Case_Status__c', type: 'text'}
            ];
        });

        document.addEventListener('scroll', () => {
            this.casesScrollListener();
        }, this);

    }

    casesScrollListener(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let casesListAux = JSON.parse(JSON.stringify(this.casesList));

        //if the component is highlighted, and it's not loading and still have more results to fetch, verifies if the scroll is in the 
        // right position to call the next batch of results
        if(filteringObjectAux.casesComponent.highlight === true && filteringObjectAux.casesComponent.loading === false && this.loadingMoreResults === false
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

    get showComponent(){
        return this.showComponentBool();
    }

    showComponentBool(){
        return this.filteringObject !== undefined && 
                this.filteringObject.casesComponent.show;
    } 

    searchWithNewFilters() {
        if(this.filteringObject !== undefined) {
            
            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

            if(filteringObjectAux.searchText.length >2){
                filteringObjectAux.casesComponent.nrResults = 0;

                if(this.pageNumber < 0 ){
                    filteringObjectAux.casesComponent.loading = true;
                }else{
                    this.loadingMoreResults = true;
                }
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "casesComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;

                this.retrieveResultsFromServer();
            }else{
                filteringObjectAux.casesComponent.nrResults = 0;
                filteringObjectAux.casesComponent.loading = false;
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "casesComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
            }
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
        getFilteredCasesResultsPage({ searchKey : JSON.stringify(filteringObjectAux) , requestedPage : requestedPageNumber+'' })
        .then(results => {

            if(results.records && results.records.length > 0) {
                let allDataAux = JSON.parse(JSON.stringify(results));
                let urlMap = JSON.parse(allDataAux.url);

                for(let i = 0; i < allDataAux.records.length; i++) {
                    let row = allDataAux.records[i];
                    row.CaseURL = urlMap[row.Id];
                    row.Country = row.Country_concerned_by_the_query__c;            
                }

                let casesListAux = this.casesList.concat(allDataAux.records);
                this.casesList = casesListAux;

            }else{
                this.casesList = [];
            }

            filteringObjectAux.casesComponent.nrResults = results.totalItemCount;
            
            if(this.pageNumber < 1 ){
                filteringObjectAux.casesComponent.loading = false;
            }else{
                this.loadingMoreResults = false;
            }

            const selectedEvent = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "casesComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;
        })
        .catch(error => {
            //something went wrong, stop loading
            filteringObjectAux.casesComponent.nrResults = 0;
            filteringObjectAux.casesComponent.loading = false;

            const selectedEvent = new CustomEvent('filterchanged', { detail : {object: filteringObjectAux, componentName: "casesComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;

            this.casesList = [];
            this.loadingMoreResults = false;
        });

    }

    get resultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.casesComponent.nrResults <= 10){
            returnText = filteringObjectAux.casesComponent.nrResults;
        }else{
            if(filteringObjectAux.casesComponent.highlight === true){
                returnText = filteringObjectAux.casesComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }

    get titleClass(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        return this.advancedSearch === true && filteringObjectAux.casesComponent.highlight === false ? 'slds-p-left_small text-bold cursorPointer' : 'slds-p-left_small text-bold';
    }

    highlightCasesComponent(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if(filteringObjectAux.casesComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = true;
            filteringObjectAux.casesComponent.show = true;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    get showSeeAllLink(){
        return this.advancedSearch === false;
    }

    goToSeeAllCasesButtonClick(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        let params = {};
        params.highlight = 'casesComponent';
        params.searchText = filteringObjectAux.searchText;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "advanced-search"
            }})
        .then(url => navigateToPage(url, params));
    }
}
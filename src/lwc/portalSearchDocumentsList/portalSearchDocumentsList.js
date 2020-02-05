import { LightningElement, api, track } from 'lwc';

//apex methods
import getSearchDocuments from '@salesforce/apex/PortalDocumentsController.getSearchDocuments';

//other libraries
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_Documents from '@salesforce/label/c.CSP_Documents';

export default class PortalSearchDocumentsList extends NavigationMixin(LightningElement) {
    
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
                valueAux.documentsComponent.highlight !== filteringObjectAux.documentsComponent.highlight || 
                valueAux.documentsComponent.show !== filteringObjectAux.documentsComponent.show ||
                valueAux.documentsComponent.documentCategoryFilter !== filteringObjectAux.documentsComponent.documentCategoryFilter ||
                valueAux.documentsComponent.documentProductCategoryFilter !== filteringObjectAux.documentsComponent.documentProductCategoryFilter || 
                valueAux.documentsComponent.documentCountryFilter !== filteringObjectAux.documentsComponent.documentCountryFilter){
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
        CSP_Documents
    };

    //clone of the filtering object passed from the parent
    @track filteringObject;

    @track documentsList = [];

    pageNumber = -1;
    totalResults = 0;

    @track loadingMoreResults = false;

    connectedCallback() {
        
        document.addEventListener('scroll', () => {
            this.documentsScrollListener();
        }, this);
    }

    documentsScrollListener(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let documentsListAux = JSON.parse(JSON.stringify(this.documentsList));

        //if the component is highlighted, and it's not loading and still have more results to fetch, verifies if the scroll is in the 
        // right position to call the next batch of results
        if(filteringObjectAux.documentsComponent.highlight === true && filteringObjectAux.documentsComponent.loading === false && this.loadingMoreResults === false 
            && (documentsListAux.length < filteringObjectAux.documentsComponent.nrResults) && filteringObjectAux.documentsComponent.nrResults > 0 ){
            
            let divToTop = this.template.querySelectorAll('.endOfTableDocuments')[0].getBoundingClientRect().top;
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
        let documentsListAux = JSON.parse(JSON.stringify(this.documentsList)); 
        return documentsListAux !== undefined && documentsListAux.length > 0;
    }
    
    get showComponent(){
        return this.showComponentBool();
    }

    showComponentBool(){
        return this.filteringObject !== undefined && 
                this.filteringObject.documentsComponent.show;
    }

    searchWithNewFilters() {
        if(this.filteringObject !== undefined) {
            
            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
            //filteringObjectAux.faqsComponent.nrResults = 0;

            if(filteringObjectAux.searchText.length >2){

                if(this.pageNumber < 0 ){
                    filteringObjectAux.documentsComponent.loading = true;
                }else{
                    this.loadingMoreResults = true;
                }
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "documentsComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;

                this.retrieveResultsFromServer();
            }else{
                filteringObjectAux.documentsComponent.nrResults = 0;
                filteringObjectAux.documentsComponent.loading = false;
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "documentsComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
            }
        }
    }

    resetPagination(){
        this.pageNumber = -1;
        this.totalResults = 0;
        this.documentsList = [];
    }

    retrieveResultsFromServer(){

        let requestedPageNumber = this.pageNumber + 1;
        this.pageNumber = requestedPageNumber;

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        //String searchKey, String category, String prodCat, String publiCountry, Integer page
        getSearchDocuments({ 
                searchKey :  filteringObjectAux.searchText, 
                category : filteringObjectAux.documentsComponent.documentCategoryFilter, 
                prodCat : filteringObjectAux.documentsComponent.documentProductCategoryFilter,
                publiCountry : filteringObjectAux.documentsComponent.documentCountryFilter,
                requestedPage : requestedPageNumber,
                docId: '' })
        .then(results => {

            if(results.records && results.records.length > 0) {
                let documentsListAux = this.documentsList.concat(results.records);
                this.documentsList = documentsListAux;
            }else{
                this.documentsList = [];
            }

            //only sets the total records number in the first page
            if(this.pageNumber < 1){
                filteringObjectAux.documentsComponent.nrResults = results.totalItemCount;
                this.totalResults = results.totalItemCount;
            }
            
            if(this.pageNumber < 1 ){
                filteringObjectAux.documentsComponent.loading = false;
            }else{
                this.loadingMoreResults = false;
            }

            if(filteringObjectAux.documentsComponent.nrResults === 0 && !filteringObjectAux.documentsComponent.highlight && filteringObjectAux.highlightTopResults){
                filteringObjectAux.documentsComponent.show = false;
            }else if(filteringObjectAux.documentsComponent.nrResults > 0 && !filteringObjectAux.documentsComponent.highlight && filteringObjectAux.highlightTopResults){
                filteringObjectAux.documentsComponent.show = true;
            }
            
            const selectedEvent = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "documentsComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;
        })
        .catch(error => {
            //something went wrong, stop loading
            filteringObjectAux.documentsComponent.nrResults = 0;
            filteringObjectAux.documentsComponent.loading = false;

            const selectedEvent = new CustomEvent('filterchanged', { detail : {object: filteringObjectAux, componentName: "documentsComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;

            this.documentsList = [];
            this.loadingMoreResults = false;
        });

    }
    
    get resultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.documentsComponent.nrResults <= 10){
            returnText = filteringObjectAux.documentsComponent.nrResults;
        }else{
            if(filteringObjectAux.documentsComponent.highlight === true){
                returnText = filteringObjectAux.documentsComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }

    get titleClass(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        return this.advancedSearch === true && filteringObjectAux.documentsComponent.highlight === false ? 'slds-p-left_small text-bold cursorPointer' : 'slds-p-left_small text-bold';
    }

    highlightDocumentsComponent(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if(filteringObjectAux.documentsComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = true;
            filteringObjectAux.documentsComponent.show = true;
            filteringObjectAux.profileComponent.highlight = false;
            filteringObjectAux.profileComponent.show = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    get showSeeAllLink(){
        return this.advancedSearch === false;
    }

    goToSeeAllDocumentsButtonClick(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        let params = {};
        params.highlight = 'documentsComponent';
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

    renderDocument(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        let params = {};
        params.searchText = filteringObjectAux.searchText; // SEARCH TERM
        params.docId = event.target.attributes.getNamedItem('data-item').value; // SPECIFIC SELECTED DOCUMENT

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "documents-search"
            }})
        .then(url => navigateToPage(url, params));
    }
}

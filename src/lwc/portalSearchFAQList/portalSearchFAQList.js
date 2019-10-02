import { LightningElement, api, track } from 'lwc';

//import apex methods
import getFilteredFAQsResultsPage from '@salesforce/apex/PortalFAQsCtrl.getFilteredFAQsResultsPage';

//import other libraries
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_FAQs_Title from '@salesforce/label/c.CSP_FAQs_Title';
import CSP_Title from '@salesforce/label/c.CSP_Title';

export default class PortalSearchFAQList extends NavigationMixin(LightningElement) {
    
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
                valueAux.faqsComponent.highlight !== filteringObjectAux.faqsComponent.highlight || 
                valueAux.faqsComponent.show !== filteringObjectAux.faqsComponent.show || 
                valueAux.faqsComponent.faqCategoryFilter !== filteringObjectAux.faqsComponent.faqCategoryFilter ||
                valueAux.faqsComponent.faqTopicFilter !== filteringObjectAux.faqsComponent.faqTopicFilter || 
                valueAux.faqsComponent.faqSubtopicFilter !== filteringObjectAux.faqsComponent.faqSubtopicFilter){
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
        CSP_FAQs_Title,
        CSP_Title
    };
    
    //clone of the filtering object passed from the parent
    @track filteringObject;

    @track faqsList =[];

    pageNumber = -1;
    totalResults = 0;

    @track loadingMoreResults = false;

    connectedCallback() {

        document.addEventListener('scroll', () => {
            this.faqsScrollListener();
        }, this);

    }

    faqsScrollListener(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let faqsListAux = JSON.parse(JSON.stringify(this.faqsList));

        //if the component is highlighted, and it's not loading and still have more results to fetch, verifies if the scroll is in the 
        // right position to call the next batch of results
        if(filteringObjectAux.faqsComponent.highlight === true && filteringObjectAux.faqsComponent.loading === false && this.loadingMoreResults === false 
            && (faqsListAux.length < filteringObjectAux.faqsComponent.nrResults) && filteringObjectAux.faqsComponent.nrResults > 0 ){
            
            let divToTop = this.template.querySelectorAll('.endOfTableFaqs')[0].getBoundingClientRect().top;
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
        let faqsListAux = JSON.parse(JSON.stringify(this.faqsList)); 
        return faqsListAux !== undefined && faqsListAux.length > 0;
    }
    
    get showComponent(){
        return this.showComponentBool();
    }

    showComponentBool(){
        return this.filteringObject !== undefined && 
                this.filteringObject.faqsComponent.show;
    }

    searchWithNewFilters() {
        if(this.filteringObject !== undefined) {
            
            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
            //filteringObjectAux.faqsComponent.nrResults = 0;

            if(filteringObjectAux.searchText.length >2){

                if(this.pageNumber < 0 ){
                    filteringObjectAux.faqsComponent.loading = true;
                }else{
                    this.loadingMoreResults = true;
                }
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "faqsComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;

                this.retrieveResultsFromServer();
            }else{
                filteringObjectAux.faqsComponent.nrResults = 0;
                filteringObjectAux.faqsComponent.loading = false;
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "faqsComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
            }
        }
    }

    resetPagination(){
        this.pageNumber = -1;
        this.totalResults = 0;
        this.faqsList = [];
    }

    retrieveResultsFromServer(){

        let requestedPageNumber = this.pageNumber + 1;
        this.pageNumber = requestedPageNumber;

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        getFilteredFAQsResultsPage({ searchKey : JSON.stringify(filteringObjectAux) , requestedPage : requestedPageNumber+'' })
        .then(results => {

            if(results.records && results.records.length > 0) {
                let faqsListAux = this.faqsList.concat(results.records);
                this.faqsList = faqsListAux;
            }else{
                this.faqsList = [];
            }

            //only sets the total records number in the first page
            if(this.pageNumber < 1){
                filteringObjectAux.faqsComponent.nrResults = results.totalItemCount;
                this.totalResults = results.totalItemCount;
            }
            
            if(this.pageNumber < 1 ){
                filteringObjectAux.faqsComponent.loading = false;
            }else{
                this.loadingMoreResults = false;
            }

            const selectedEvent = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "faqsComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;
        })
        .catch(error => {
            //something went wrong, stop loading
            filteringObjectAux.faqsComponent.nrResults = 0;
            filteringObjectAux.faqsComponent.loading = false;

            const selectedEvent = new CustomEvent('filterchanged', { detail : {object: filteringObjectAux, componentName: "faqsComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;

            this.faqsList = [];
            this.loadingMoreResults = false;
        });

    }

    get resultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.faqsComponent.nrResults <= 10){
            returnText = filteringObjectAux.faqsComponent.nrResults;
        }else{
            if(filteringObjectAux.faqsComponent.highlight === true){
                returnText = filteringObjectAux.faqsComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }

    get titleClass(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        return this.advancedSearch === true && filteringObjectAux.faqsComponent.highlight === false ? 'slds-p-left_small text-bold cursorPointer' : 'slds-p-left_small text-bold';
    }

    highlightFaqsComponent(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if(filteringObjectAux.faqsComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = true;
            filteringObjectAux.faqsComponent.show = true;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    get showSeeAllLink(){
        return this.advancedSearch === false;
    }

    goToSeeAllFAQsButtonClick(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        let params = {};
        params.highlight = 'faqsComponent';
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

    renderArticle(event) {
        let params = {};
        params.q = this.filteringObject.searchText; // SEARCH TERM
        params.id1 = event.target.attributes.getNamedItem('data-item').value; // SPECIFIC SELECTED ARTICLE

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }

}
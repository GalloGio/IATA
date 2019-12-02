import { LightningElement, api, track } from 'lwc';

//import apex methods
import getUserFilteredServices from '@salesforce/apex/PortalServicesCtrl.getUserFilteredServices';

//import external libraries
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_Services_Title from '@salesforce/label/c.CSP_Services_Title';
import CSP_Name from '@salesforce/label/c.CSP_Name';

export default class PortalSearchServicesList extends NavigationMixin(LightningElement) {

    //these are the filters passed from the search
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
                valueAux.servicesComponent.highlight !== filteringObjectAux.servicesComponent.highlight || 
                valueAux.servicesComponent.show !== filteringObjectAux.servicesComponent.show){
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
        CSP_Services_Title,
        CSP_Name
    };
    
    //clone of the filtering object passed from the parent
    @track filteringObject;

    @track servicesList = [];

    pageNumber = -1;
    totalResults = 0;

    @track loadingMoreResults = false;

    @track columns = [
        {label: 'Name', fieldName: 'Application_Name__c', type: 'text'},
        {label: '', fieldName: '', cellAttributes:
                { iconName: 'utility:forward', iconPosition: 'right' }}
    ];

    connectedCallback() {
        document.addEventListener('scroll', () => {
            this.servicesScrollListener();
        }, this);
    }

    servicesScrollListener(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let servicesListAux = JSON.parse(JSON.stringify(this.servicesList));

        //if the component is highlighted, and it's not loading and still have more results to fetch, verifies if the scroll is in the 
        // right position to call the next batch of results
        if(filteringObjectAux.servicesComponent.highlight === true && filteringObjectAux.servicesComponent.loading === false && this.loadingMoreResults === false
            && (servicesListAux.length < filteringObjectAux.servicesComponent.nrResults) && filteringObjectAux.servicesComponent.nrResults > 0 ){
            
            let divToTop = this.template.querySelectorAll('.endOfTableServices')[0].getBoundingClientRect().top;
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
        let servicesListAux = JSON.parse(JSON.stringify(this.servicesList)); 
        return servicesListAux !== undefined && servicesListAux.length > 0;
    }
    
    get showComponent(){
        return this.showComponentBool();
    }

    showComponentBool(){
        return this.filteringObject !== undefined && 
                this.filteringObject.servicesComponent.show;
    }

    searchWithNewFilters() {
        if(this.filteringObject !== undefined) {
            
            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
            if(filteringObjectAux.searchText.length >2){
                filteringObjectAux.servicesComponent.nrResults = 0;

                if(this.pageNumber < 0 ){
                    filteringObjectAux.servicesComponent.loading = true;
                }else{
                    this.loadingMoreResults = true;
                }
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "servicesComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;

                this.retrieveResultsFromServer();
            }else{
                filteringObjectAux.servicesComponent.nrResults = 0;
                filteringObjectAux.servicesComponent.loading = false;
                const selectedEventLoading = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "servicesComponent" }});
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
            }
        }
    }

    resetPagination(){
        this.pageNumber = -1;
        this.totalResults = 0;
        this.servicesList = [];
    }

    retrieveResultsFromServer(){

        let requestedPageNumber = this.pageNumber + 1;
        this.pageNumber = requestedPageNumber;

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        getUserFilteredServices({ searchKey : JSON.stringify(filteringObjectAux) , requestedPage : requestedPageNumber+'' })
        .then(results => {

            if(results.records && results.records.length > 0) {
                let servicesListAux = this.servicesList.concat(results.records);
                this.servicesList = servicesListAux;
            }else{
                this.servicesList = [];
            }

            filteringObjectAux.servicesComponent.nrResults = results.totalItemCount;
            
            if(this.pageNumber < 1 ){
                filteringObjectAux.servicesComponent.loading = false;
            }else{
                this.loadingMoreResults = false;
            }

            if(filteringObjectAux.servicesComponent.nrResults === 0 && !filteringObjectAux.servicesComponent.highlight && filteringObjectAux.highlightTopResults){
                filteringObjectAux.servicesComponent.show = false;
            }else if(filteringObjectAux.servicesComponent.nrResults > 0 && !filteringObjectAux.servicesComponent.highlight && filteringObjectAux.highlightTopResults){
                filteringObjectAux.servicesComponent.show = true;
            }
            
            const selectedEvent = new CustomEvent('filterchanged', { detail : { object: filteringObjectAux, componentName: "servicesComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;
        })
        .catch(error => {
            //something went wrong, stop loading
            filteringObjectAux.servicesComponent.nrResults = 0;
            filteringObjectAux.servicesComponent.loading = false;

            const selectedEvent = new CustomEvent('filterchanged', { detail : {object: filteringObjectAux, componentName: "servicesComponent" }});
            this.dispatchEvent(selectedEvent);

            this.filteringObject = filteringObjectAux;

            this.servicesList = [];
            this.loadingMoreResults = false;
        });

    }

    get resultsText(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if(filteringObjectAux.servicesComponent.nrResults <= 10){
            returnText = filteringObjectAux.servicesComponent.nrResults;
        }else{
            if(filteringObjectAux.servicesComponent.highlight === true){
                returnText = filteringObjectAux.servicesComponent.nrResults;
            }else{
                returnText = '10+';
            }
        }
        return returnText;
    }

    get titleClass(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        return this.advancedSearch === true && filteringObjectAux.servicesComponent.highlight === false ? 'slds-p-left_small text-bold cursorPointer' : 'slds-p-left_small text-bold';
    }

    highlightServicesComponent(event){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if(filteringObjectAux.servicesComponent.highlight === false){
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = true;
            filteringObjectAux.servicesComponent.show = true;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.highlight = false;
            filteringObjectAux.profileComponent.show = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    get showSeeAllLink(){
        return this.advancedSearch === false;
    }

    goToSeeAllServicesButtonClick(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        let params = {};
        params.highlight = 'servicesComponent';
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

    goToManageServiceButtonClick(event) {
        let params = {};
        params.serviceId = event.target.attributes.getNamedItem('data-item').value;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "manage-service"
            }})
        .then(url => navigateToPage(url, params));
    }


}

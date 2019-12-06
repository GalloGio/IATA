import { LightningElement, track, api} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import custom labels
import CSP_Search_AdvancedSearch from '@salesforce/label/c.CSP_Search_AdvancedSearch';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import CSP_Search_NoResults_text3 from '@salesforce/label/c.CSP_Search_NoResults_text3';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSearchBar extends NavigationMixin(LightningElement) {

    //these are the filters passed from the search
    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        this.filteringObject = value;
        
        this.setColumnsClass();
    }

    @api placeholder;

    label = {
        CSP_Search_AdvancedSearch,
        CSP_Search_NoResults_text1,
        CSP_Search_NoResults_text2,
        CSP_Search_NoResults_text3
    }

    @track showHoverResults = false;

    @track showBackdrop = false;

    timeout = null;

    @track searchText = "";
    
    //clone of the filtering object passed from the parent
    @track filteringObject;

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';

    @track loadingTypehead = false;

    @track leftColumnClass = '';
    @track rightColumnClass = '';

    @track noResultsClass = 'display: none;';
    @track resultsClass = 'display: none;';

    setColumnsClass(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        this.leftColumnClass = 'slds-col slds-size_1-of-1 slds-large-size_2-of-3';
        this.rightColumnClass = 'slds-col slds-size_1-of-1 slds-large-size_1-of-3';

        if((filteringObjectAux.casesComponent.show || filteringObjectAux.faqsComponent.show) && (!filteringObjectAux.documentsComponent.show && !filteringObjectAux.servicesComponent.show)){
            this.leftColumnClass = 'slds-col slds-size_1-of-1';
            this.rightColumnClass = 'slds-col slds-size_1-of-1';
        }

        if((!filteringObjectAux.casesComponent.show && !filteringObjectAux.faqsComponent.show) && (filteringObjectAux.documentsComponent.show || filteringObjectAux.servicesComponent.show)){
            this.leftColumnClass = 'slds-col slds-size_1-of-1';
            this.rightColumnClass = 'slds-col slds-size_1-of-1';
        }

    }

    closeSearch(){
        this.searchText = "";
        this.showHoverResults = false;
        this.showBackdrop = false;
    }

    onkeyupSearchInput(event){
        let keyEntered = event.keyCode;
        //console.log(keyEntered);

        //if enter
        if(this.filteringObject.advancedSearch && keyEntered === 13){
            this.navigateToAdvancedSearchPage();
        } 

        //if escape
        if(keyEntered === 27){
            this.closeSearch();
        }
    }

    goToAdvancedSearch(event){
        event.preventDefault();
        event.stopPropagation();
        this.navigateToAdvancedSearchPage();
    }

    navigateToAdvancedSearchPage(){
        let params = {};
        if(this.searchText !== '') {
            params.searchText = this.searchText;
        }

        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                pageName: "advanced-search"
            }})
        .then(url => navigateToPage(url, params));
    }

    onclickSearchInput(){
        this.showBackdrop = true;
    }
    onchangeSearchInput(event){
        this.searchText = event.target.value;
        
        this.showCross = this.searchText.length > 0;

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        this.loadingTypehead = true;

        // Make a new timeout set to go off in 1500ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();

            this.loadingTypehead = false;

            if(this.searchText.length > 0){
                this.showHoverResults = true;
                let objAux = JSON.parse(JSON.stringify(this.filteringObject));

                objAux.searchText = this.searchText + "";
                objAux.showAllComponents = true;
                this.filteringObject = objAux;
                //console.log(objAux);
            }else{
                this.showHoverResults = false;
            }


        }, 1500, this);

    }

    handlefilterchanged(event){

        let eventObject = JSON.parse(JSON.stringify(event.detail.object));
        let eventComponentName = JSON.parse(JSON.stringify(event.detail.componentName));

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux[eventComponentName] = eventObject[eventComponentName];

        this.filteringObject = filteringObjectAux;

        this.updateResultsDiv();
    }

    updateResultsDiv(){
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if(this.searchText.length > 2 && filteringObjectAux.servicesComponent.nrResults === 0 && filteringObjectAux.casesComponent.nrResults === 0 &&
            filteringObjectAux.faqsComponent.nrResults === 0 && filteringObjectAux.documentsComponent.nrResults === 0 && 
            !filteringObjectAux.servicesComponent.loading && !filteringObjectAux.casesComponent.loading &&
            !filteringObjectAux.faqsComponent.loading && !filteringObjectAux.casesComponent.loading){
            this.noResultsClass = '';
            this.resultsClass = 'display: none;';
        }else{
            this.noResultsClass = 'display: none;';
            this.resultsClass = '';
        }
        
    }

    removeTextSearch() {
        this.filteringObject.searchText = '';
        this.searchText = '';
        this.showCross = false;
    }

}

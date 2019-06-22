import { LightningElement, track, api} from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

//import custom labels
import CSP_Search_AdvancedSearch from '@salesforce/label/c.CSP_Search_AdvancedSearch';

export default class PortalSearchBar extends NavigationMixin(LightningElement) {

    label = {
        CSP_Search_AdvancedSearch
    }

    @track showHoverResults = false;

    @track showBackdrop = false;

    timeout = null;

    @track searchText = "";

    @api placeholder;
    
    //clone of the filtering object passed from the parent
    @track filteringObject;

    //these are the filters passed from the search
    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        this.filteringObject = value;
    }

    searchIconUrl = '/csportal/s/CSPortal/Images/Icons/searchColored.svg';

    @track loadingTypehead = false;

    closeSearch(){
        this.searchText = "";
        this.showHoverResults = false;
        this.showBackdrop = false;
    }

    onkeyupSearchInput(event){
        let keyEntered = event.keyCode;
        //console.log(keyEntered);

        //if enter
        if(keyEntered === 13){
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
            type: "standard__namedPage",
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

}
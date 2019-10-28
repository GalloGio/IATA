import { LightningElement, api, track } from 'lwc';

//import other libraries
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//import apex methods
import getFilteredProfileResultsPage from '@salesforce/apex/PortalProfileCtrl.getFilteredProfileResultsPage';
import getSelectedColumns from '@salesforce/apex/CSP_Utils.getSelectedColumns';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import ICCS_Profile from '@salesforce/label/c.ICCS_Profile';
import CSP_Search_Case_Type from '@salesforce/label/c.CSP_Search_Case_Type';
import CSP_Portal_Status from '@salesforce/label/c.CSP_Portal_Status';
import Company from '@salesforce/label/c.Company';

export default class PortalSearchProfileList extends NavigationMixin(LightningElement) {

    @api
    get filteringObjectParent() {
        return this.filteringObject;
    }
    set filteringObjectParent(value) {
        let valueAux = JSON.parse(JSON.stringify(value));

        if (this.filteringObject !== undefined) {
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
            this.filteringObject = valueAux;
            //if any changes in these fileds, then apply new search for this component
            if (valueAux.searchText !== filteringObjectAux.searchText ||
                valueAux.profileComponent.highlight !== filteringObjectAux.profileComponent.highlight ||
                valueAux.profileComponent.show !== filteringObjectAux.profileComponent.show ||
                valueAux.profileComponent.profileTypeFilter !== filteringObjectAux.profileComponent.profileTypeFilter ||
                valueAux.profileComponent.profileCountryFilter !== filteringObjectAux.profileComponent.profileCountryFilter ||
                valueAux.profileComponent.profileStatusFilter !== filteringObjectAux.profileComponent.profileStatusFilter) {
                this.resetPagination();
                this.searchWithNewFilters();
            }
        } else {
            this.filteringObject = valueAux;
            this.searchWithNewFilters();
        }
    }

    @api advancedSearch = false;

    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        ICCS_Profile,
        CSP_Search_Case_Type,
        CSP_Portal_Status,
        Company
    };

    @track filteringObject;

    @track profileList = [];

    @track columns;

    @track offSetLimiter = 0;

    pageNumber = -1;
    totalResults = 0;

    listAccounts = [];
    listContacts = [];

    @track isAdmin = false;

    @track loadingMoreResults = false;

    fieldLabels = [
        'Name', 'User_Portal_Status__c', 'Country__c',
    ];

    connectedCallback() {
        getSelectedColumns({ sObjectType: 'Contact', sObjectFields: this.fieldLabels })
            .then(results => {
                this.columns = [
                    { label: results.Name, fieldName: 'profileUrl', type: 'url', typeAttributes: { label: { fieldName: 'profileName' }, target: '_self' } },
                    { label: this.label.CSP_Portal_Status, fieldName: 'profilePortalStatus', type: 'text' },
                    { label: results.Country__c, fieldName: 'profileCountry', type: 'text' },
                    { label: this.label.CSP_Search_Case_Type, fieldName: 'profileType', type: 'text' },
                ];
            });

        document.addEventListener('scroll', () => {
            this.profileScrollListener();
        }, this);

    }

    profileScrollListener() {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let profileListAux = JSON.parse(JSON.stringify(this.profileList));
        //if the component is highlighted, and it's not loading and still have more results to fetch, verifies if the scroll is in the 
        // right position to call the next batch of results
        if (filteringObjectAux.profileComponent.highlight === true && filteringObjectAux.profileComponent.loading === false && this.loadingMoreResults === false
            && (profileListAux.length < filteringObjectAux.profileComponent.nrResults) && filteringObjectAux.profileComponent.nrResults > 0) {

            let divToTop = this.template.querySelectorAll('.endOfTableProfile')[0].getBoundingClientRect().top;
            let windowSize = window.innerHeight;
            let offset = (windowSize / 10) * 2; // 20% of the screen size to get more sesults

            if (divToTop < windowSize - offset) {
                // update table
                this.loadingMoreResults = true;
                this.loadMoreResults();
            }
        }

    }

    get viewResults() {
        let profileListAux = JSON.parse(JSON.stringify(this.profileList));
        return profileListAux !== undefined && profileListAux.length > 0;
    }

    get showComponent() {
        return this.showComponentBool();
    }

    showComponentBool() {
        return this.filteringObject !== undefined &&
            this.filteringObject.profileComponent.show;
    }

    searchWithNewFilters() {
        if (this.filteringObject !== undefined) {
            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

            if (filteringObjectAux.searchText.length > 2) {
                filteringObjectAux.profileComponent.nrResults = 0;

                if (this.pageNumber < 0) {
                    filteringObjectAux.profileComponent.loading = true;
                } else {
                    this.loadingMoreResults = true;
                }
                const selectedEventLoading = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "profileComponent" } });
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
                this.retrieveResultsFromServer();
            } else {
                filteringObjectAux.profileComponent.nrResults = 0;
                filteringObjectAux.profileComponent.loading = false;
                const selectedEventLoading = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "profileComponent" } });
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
            }
        }
    }

    resetPagination() {
        this.pageNumber = -1;
        this.totalResults = 0;
        this.profileList = [];
    }

    retrieveResultsFromServer() {

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        getFilteredProfileResultsPage({ profileFilterWrapper: JSON.stringify(filteringObjectAux) })
            .then(myResults => {
                let results = JSON.parse(JSON.stringify(myResults));
                let recordsString = JSON.parse(results.recordsString);
                
                filteringObjectAux.profileComponent.nrResults = recordsString.length;

                this.listAccounts = recordsString.filter(obj => obj.profileType === this.label.Company);
                this.listContacts = recordsString.filter(obj => obj.profileType === 'Contact');

                if (recordsString && recordsString.length > 10) {
                    let slicedContactProfileList = this.listContacts.length > 5 ? this.listContacts.slice(0, 10 - this.listAccounts.slice(0, 5).length) : this.listContacts;
                    let slicedAccountProfileList = this.listAccounts.length > 5 ? this.listAccounts.slice(0, 10 - slicedContactProfileList.length) : this.listAccounts;

                    let profileListAux = slicedContactProfileList.concat(slicedAccountProfileList);
                    this.profileList = profileListAux;
                }else{
                    let profileListAux = this.listAccounts.concat(this.listContacts);
                    this.profileList = profileListAux;
                }

                if (this.pageNumber < 1) {
                    filteringObjectAux.profileComponent.loading = false;
                } else {
                    this.loadingMoreResults = false;
                }

                if (filteringObjectAux.profileComponent.nrResults === 0 && !filteringObjectAux.profileComponent.highlight && filteringObjectAux.highlightTopResults) {
                    filteringObjectAux.profileComponent.show = false;
                } else if (filteringObjectAux.profileComponent.nrResults > 0 && !filteringObjectAux.profileComponent.highlight && filteringObjectAux.highlightTopResults) {
                    filteringObjectAux.profileComponent.show = true;
                }

                const selectedEvent = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "profileComponent" } });
                this.dispatchEvent(selectedEvent);

                this.filteringObject = filteringObjectAux;
            })
            .catch(error => {
                //something went wrong, stop loading
                filteringObjectAux.profileComponent.nrResults = 0;
                filteringObjectAux.profileComponent.loading = false;

                const selectedEvent = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "profileComponent" } });
                this.dispatchEvent(selectedEvent);

                this.filteringObject = filteringObjectAux;

                this.profileList = [];
                this.loadingMoreResults = false;
            });

    }

    loadMoreResults() {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let requestedPageNumber = this.pageNumber + 1;
        this.pageNumber = requestedPageNumber;
        let slicedContactProfileList=[];
        let slicedAccountProfileList=[];
        if (this.profileList.length < filteringObjectAux.profileComponent.nrResults) {
            slicedContactProfileList = this.listContacts.slice(0, 5 * (this.pageNumber+1));
            slicedAccountProfileList = this.listAccounts.slice(0, 5 * (this.pageNumber+1));
        }
        let profileListAux = slicedContactProfileList.concat(slicedAccountProfileList);
        this.profileList = profileListAux;
        
        this.loadingMoreResults = false;
    }

    get resultsText() {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let returnText = '';
        if (filteringObjectAux.profileComponent.nrResults <= 10) {
            returnText = filteringObjectAux.profileComponent.nrResults;
        } else {
            if (filteringObjectAux.profileComponent.highlight === true) {
                returnText = filteringObjectAux.profileComponent.nrResults;
            } else {
                returnText = '10+';
            }
        }
        return returnText;
    }

    get titleClass() {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        return this.advancedSearch === true && filteringObjectAux.profileComponent.highlight === false ? 'slds-p-left_small text-bold cursorPointer' : 'slds-p-left_small text-bold';
    }

    highlightProfileComponent(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if (filteringObjectAux.profileComponent.highlight === false) {
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = false;
            filteringObjectAux.faqsComponent.show = false;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.highlight = true;
            filteringObjectAux.profileComponent.show = true;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    get showSeeAllLink() {
        return this.advancedSearch === false;
    }

    goToSeeAllProfileButtonClick(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        let params = {};
        params.highlight = 'profileComponent';
        params.searchText = filteringObjectAux.searchText;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "advanced-search"
            }
        })
            .then(url => navigateToPage(url, params));
    }
}

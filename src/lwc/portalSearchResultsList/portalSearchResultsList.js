import { LightningElement, api, track } from 'lwc';

//import apex methods
import portalGlobalSearch from '@salesforce/apex/PortalGlobalSearchCtrl.portalGlobalSearch';

//import other libraries
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//import labels
import CSP_SeeAll from '@salesforce/label/c.CSP_SeeAll';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import CSP_FAQs_Title from '@salesforce/label/c.CSP_FAQs_Title';
import CSP_Title from '@salesforce/label/c.CSP_Title';
import ISSP_See_more from '@salesforce/label/c.ISSP_See_more';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';
import ISSP_AvailableServices_Service from '@salesforce/label/c.ISSP_AvailableServices_Service';
import CSP_Breadcrumb_FAQ_Title from '@salesforce/label/c.CSP_Breadcrumb_FAQ_Title';
import CSP_Documents from '@salesforce/label/c.CSP_Documents';
import ICCS_Profile from '@salesforce/label/c.ICCS_Profile';

export default class PortalSearchResultList extends NavigationMixin(LightningElement) {

    @api userInfo = {};

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
                valueAux.faqsComponent.highlight !== filteringObjectAux.faqsComponent.highlight ||
                valueAux.faqsComponent.show !== filteringObjectAux.faqsComponent.show ||
                valueAux.faqsComponent.faqCategoryFilter !== filteringObjectAux.faqsComponent.faqCategoryFilter ||
                valueAux.faqsComponent.faqTopicFilter !== filteringObjectAux.faqsComponent.faqTopicFilter ||
                valueAux.faqsComponent.faqSubtopicFilter !== filteringObjectAux.faqsComponent.faqSubtopicFilter) {
                this.searchWithNewFilters();
            }
        } else {
            this.filteringObject = valueAux;
            this.searchWithNewFilters();
        }
    }

    goToAdvancedSearch(event) {
        event.preventDefault();
        event.stopPropagation();
        this.navigateToAdvancedSearchPage();
    }

    navigateToAdvancedSearchPage() {
        let params = {};
        if (this.searchText !== '') {
            params.searchText = this.filteringObject.searchText;
        }

        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                pageName: "advanced-search"
            }
        })
            .then(url => navigateToPage(url, params));
    }

    @api advancedSearch = false;
    @api menuSearch = this.menuSearch;

    @api
    reloadData() {
        this.filteringObject.searchText = '';
    }

    label = {
        CSP_NoSearchResults,
        CSP_SeeAll,
        CSP_FAQs_Title,
        CSP_Title,
        ISSP_See_more,
        CSP_PortalPath,
        CSP_Cases,
        ISSP_AvailableServices_Service,
        CSP_Breadcrumb_FAQ_Title,
        CSP_Documents,
        ICCS_Profile
    };

    //clone of the filtering object passed from the parent
    @track filteringObject = {};
    @track menuSearch;
    @track searchText;
    @track numberOfResults;

    @track resultsList2 = [];

    pageNumber = -1;
    totalResults = 9;

    @track loadingMoreResults = false;

    @track caseResults = [];
    @track faqsResults = [];
    @track documentsResults = [];
    @track servicesResults = [];
    @track profilesResults = [];

    @track searchResultsAggregation = [];

    get viewResults() {
        let resultsListAux = JSON.parse(JSON.stringify(this.resultsList2));
        return resultsListAux !== undefined && resultsListAux.length > 0;
    }

    get showComponent() {
        return this.showComponentBool();
    }

    showComponentBool() {
        return this.filteringObject !== undefined &&
            this.filteringObject.faqsComponent.show;
    }

    searchWithNewFilters() {
        if (this.filteringObject !== undefined) {

            //put the component and the results number into loading mode
            let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
            //filteringObjectAux.faqsComponent.nrResults = 0;

            if (filteringObjectAux.searchText.length > 2) {
                if (this.pageNumber < 0) {
                    filteringObjectAux.faqsComponent.loading = true;
                } else {
                    this.loadingMoreResults = true;
                }
                const selectedEventLoading = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "faqsComponent" } });
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;

                this.retrieveResultsFromServer();
            } else {
                filteringObjectAux.faqsComponent.nrResults = 0;
                filteringObjectAux.faqsComponent.loading = false;
                const selectedEventLoading = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "faqsComponent" } });
                this.dispatchEvent(selectedEventLoading);
                this.filteringObject = filteringObjectAux;
            }
        }
    }

    retrieveResultsFromServer() {

        this.caseResults = [];
        this.faqsResults = [];
        this.servicesResults = [];
        this.documentsResults = [];
        this.profilesResults = [];

        let requestedPageNumber = this.pageNumber + 1;
        this.pageNumber = requestedPageNumber;

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));

        if (!filteringObjectAux.advancedSearch) {
            filteringObjectAux.guestUser = !filteringObjectAux.advancedSearch;
        }

        this.resultsList2 = [];

        filteringObjectAux.faqsComponent.loading = true;
        this.loadingMoreResults = true;

        const selectedEvent = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "faqsComponent" } });
        this.dispatchEvent(selectedEvent);

        let searchCases = new Promise((resolve, reject) => {
            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });
        let searchFAQS = new Promise((resolve, reject) => {
            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });
        let searchServices = new Promise((resolve, reject) => {
            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });
        let searchDocuments = new Promise((resolve, reject) => {
            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });
        let searchProfiles = new Promise((resolve, reject) => {
            let error = false;
            if (!error)
                resolve();
            else
                reject();
        });

        if (filteringObjectAux.casesComponent.show) {
            searchCases = new Promise((resolve, reject) => {
                portalGlobalSearch({ filterWrapperAux: JSON.stringify(filteringObjectAux), searchObject: 'Cases' })
                    .then(results => {
                        if (results && results.records && results.records.length > 0) {
                            this.caseResults = JSON.parse(JSON.stringify(results.records));
                        }
                        let error = false;
                        if (!error)
                            resolve(this.caseResults);
                        else
                            reject();
                    });
            });
        }

        if (filteringObjectAux.faqsComponent.show) {
            searchFAQS = new Promise((resolve, reject) => {
                portalGlobalSearch({ filterWrapperAux: JSON.stringify(filteringObjectAux), searchObject: 'FAQS' })
                    .then(results => {
                        if (results && results.records && results.records.length > 0) {
                            this.faqsResults = JSON.parse(JSON.stringify(results.records));
                        }
                        let error = false;
                        if (!error)
                            resolve(this.faqsResults);
                        else
                            reject();
                    });
            });
        }

        if (filteringObjectAux.servicesComponent.show) {
            searchServices = new Promise((resolve, reject) => {
                portalGlobalSearch({ filterWrapperAux: JSON.stringify(filteringObjectAux), searchObject: 'Services' })
                    .then(results => {
                        if (results && results.records && results.records.length > 0) {
                            this.servicesResults = JSON.parse(JSON.stringify(results.records));
                        }
                        let error = false;
                        if (!error)
                            resolve(this.servicesResults);
                        else
                            reject();
                    });
            });
        }

        if (filteringObjectAux.documentsComponent.show) {
            searchDocuments = new Promise((resolve, reject) => {
                portalGlobalSearch({ filterWrapperAux: JSON.stringify(filteringObjectAux), searchObject: 'Documents' })
                    .then(results => {
                        if (results && results.records && results.records.length > 0) {
                            this.documentsResults = JSON.parse(JSON.stringify(results.records));
                        }
                        let error = false;
                        if (!error)
                            resolve(this.documentsResults);
                        else
                            reject();
                    });
            });
        }

        if (filteringObjectAux.profileComponent.show) {
            searchProfiles = new Promise((resolve, reject) => {
                portalGlobalSearch({ filterWrapperAux: JSON.stringify(filteringObjectAux), searchObject: 'Profiles' })
                    .then(results => {
                        if (results && results.recordsString && results.recordsString !== '') {
                            let allProfileResultsUnparsed = [];
                            let allProfileResultsParsed = [];
                            allProfileResultsUnparsed = JSON.parse(results.recordsString);
                            for (let i in allProfileResultsUnparsed) {
                                allProfileResultsParsed.push(allProfileResultsUnparsed[i]);
                            }
                            this.profilesResults = allProfileResultsParsed;
                        }
                        let error = false;
                        if (!error)
                            resolve(this.profilesResults);
                        else
                            reject();
                    });
            });
        }

        //Show Spinner, Show Options Panel, Get Live Agent, Scroll window down, Hide Spinner
        Promise.all([
            searchCases,
            searchFAQS,
            searchServices,
            searchDocuments,
            searchProfiles]).then(results => {
                this.searchResultsBuilder();
            }).catch(error => {
                //something went wrong, stop loading
                filteringObjectAux.faqsComponent.nrResults = 0;
                filteringObjectAux.faqsComponent.loading = false;

                const selectedEvent = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "faqsComponent" } });
                this.dispatchEvent(selectedEvent);

                this.filteringObject = filteringObjectAux;

                this.resultsList2 = [];
                this.loadingMoreResults = false;
            });

    }

    searchResultsBuilder() {

        let retrievedAccounts = [];
        let retrievedContacts = [];
        let aggregateResults = [];

        for (let i = 0; i < this.filteringObject.numberOfResults && i < this.profilesResults.length; i++) {
            if (this.profilesResults[i].profileType === 'Company') {
                retrievedAccounts.push(this.profilesResults[i]);
            } else {
                retrievedContacts.push(this.profilesResults[i]);
            }
        }

        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        filteringObjectAux.faqsComponent.show = true;

        for (let i = 0; i < this.filteringObject.numberOfResults; i++) {

            if (this.caseResults && this.caseResults.length > i && aggregateResults.length < this.filteringObject.numberOfResults) {
                let caseRes = {
                    "id": this.caseResults[i].Id,
                    "category": this.label.CSP_Cases,
                    "title": this.caseResults[i].CaseNumber,
                    "description": this.caseResults[i].Subject,
                    "class": "categId-1",
                    "url": "case-details?caseId=" + this.caseResults[i].Id
                };
                aggregateResults.push(caseRes);
            }
            if (this.faqsResults && this.faqsResults.length > i && aggregateResults.length < this.filteringObject.numberOfResults) {
                let faq = {
                    "id": this.faqsResults[i].Id,
                    "category": this.label.CSP_Breadcrumb_FAQ_Title,
                    "title": this.faqsResults[i].Title,
                    "description": "",
                    "class": "categId-2",
                    "url": 'q=' + filteringObjectAux.searchText + '&id1=' + this.faqsResults[i].Id
                };
                aggregateResults.push(faq);
            }
            if (this.servicesResults && this.servicesResults.length > i && aggregateResults.length < this.filteringObject.numberOfResults) {
                let serviceRes = {
                    "id": this.servicesResults[i].Id,
                    "category": this.label.ISSP_AvailableServices_Service,
                    "title": this.servicesResults[i].Name,
                    "description": this.servicesResults[i].Description__c,
                    "class": "categId-3",
                    "url": "manage-service?serviceId=" + this.servicesResults[i].Id
                }
                aggregateResults.push(serviceRes);
            }
            if (this.documentsResults && this.documentsResults.length > i && aggregateResults.length < this.filteringObject.numberOfResults) {
                let doc = {
                    "id": this.documentsResults[i].Id,
                    "category": this.label.CSP_Documents,
                    "title": this.documentsResults[i].Title,
                    "description": this.documentsResults[i].Description,
                    "class": "categId-5",
                    "url": "documents-search?searchText=" + filteringObjectAux.searchText + "&docId=" + this.documentsResults[i].Id
                }
                aggregateResults.push(doc);
            }
            if (retrievedAccounts && retrievedAccounts.length > i && aggregateResults.length < this.filteringObject.numberOfResults) {
                let acc = {
                    "id": retrievedAccounts[i].profileId,
                    "category": this.label.ICCS_Profile,
                    "title": retrievedAccounts[i].profileName,
                    "description": retrievedAccounts[i].profileType,
                    "class": "categId-4",
                    "url": retrievedAccounts[i].profileUrl
                }
                aggregateResults.push(acc);
            }
            if (retrievedContacts && retrievedContacts.length > i && aggregateResults.length < this.filteringObject.numberOfResults) {
                let cont = {
                    "id": retrievedContacts[i].profileId,
                    "category": this.label.ICCS_Profile,
                    "title": retrievedContacts[i].profileName,
                    "description": retrievedContacts[i].profileType,
                    "class": "categId-4",
                    "url": retrievedContacts[i].profileUrl
                }
                aggregateResults.push(cont);
            }
        }

        this.searchResultsAggregation = aggregateResults;

        this.resultsList2 = aggregateResults;

        //only sets the total records number in the first page
        filteringObjectAux.faqsComponent.nrResults = aggregateResults.length;
        this.totalResults = aggregateResults.length;

        filteringObjectAux.faqsComponent.loading = false;
        this.loadingMoreResults = false;

        if (filteringObjectAux.faqsComponent.nrResults === 0 && !filteringObjectAux.faqsComponent.highlight && filteringObjectAux.highlightTopResults) {
            filteringObjectAux.faqsComponent.show = false;
        } else if (filteringObjectAux.faqsComponent.nrResults > 0 && !filteringObjectAux.faqsComponent.highlight && filteringObjectAux.highlightTopResults) {
            filteringObjectAux.faqsComponent.show = true;
        }

        const selectedEvent = new CustomEvent('filterchanged', { detail: { object: filteringObjectAux, componentName: "faqsComponent" } });
        this.dispatchEvent(selectedEvent);
        this.filteringObject = filteringObjectAux;
    }

    highlightfaqsComponent(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        if (filteringObjectAux.faqsComponent.highlight === false) {
            filteringObjectAux.highlightTopResults = false;
            filteringObjectAux.servicesComponent.highlight = false;
            filteringObjectAux.servicesComponent.show = false;
            filteringObjectAux.casesComponent.highlight = false;
            filteringObjectAux.casesComponent.show = false;
            filteringObjectAux.faqsComponent.highlight = true;
            filteringObjectAux.faqsComponent.show = true;
            filteringObjectAux.documentsComponent.highlight = false;
            filteringObjectAux.documentsComponent.show = false;
            filteringObjectAux.profileComponent.highlight = false;
            filteringObjectAux.profileComponent.show = false;
            const selectedEvent = new CustomEvent('highlightfilterchanged', { detail: filteringObjectAux });
            this.dispatchEvent(selectedEvent);
        }
    }

    renderArticle(event) {
        let filteringObjectAux = JSON.parse(JSON.stringify(this.filteringObject));
        let url = event.target.attributes.getNamedItem('data-url').value;
        let category = event.target.attributes.getNamedItem('data-category').value;
        let thePage;
        let params = {};
        if (category === 'Cases') {
            thePage = 'case-details'
            params.caseId = url.replace('case-details?caseId=', '');
        }
        if (category === 'FAQ') {
            thePage = filteringObjectAux.advancedSearch ? 'support-view-article' : 'faq-article';
            params.q = filteringObjectAux.searchText;
            params.id1 = url.replace('q=' + filteringObjectAux.searchText + '&id1=', '');
        }
        if (category === 'Documents') {
            thePage = 'documents-search'
            params.searchText = filteringObjectAux.searchText;
            params.docId = url.replace("documents-search?searchText=" + filteringObjectAux.searchText + "&docId=", '');
        }
        if (category === 'Services') {
            thePage = 'manage-service';
            params.serviceId = url.replace('manage-service?serviceId=', '');
        }
        if (category === 'Profile') {
            if (url.includes('company-profile?account=')) {
                thePage = 'company-profile';
                params.account = url.replace(this.label.CSP_PortalPath + 'company-profile?account=', '');
            }
            else if (url.includes('company-profile?tab=contact&contact=')) {
                thePage = 'company-profile';
                params.contact = url.replace(this.label.CSP_PortalPath + 'company-profile?tab=contact&contact=', '');
                params.tab = 'contact';
            }
            else if (url.includes('company-profile')) {
                thePage = 'company-profile';
            }
            else if (url.includes('my-profile')) {
                thePage = 'my-profile';
            }
        }

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: thePage
            }
        })
            .then(url => navigateToPage(url, params));
    }
}

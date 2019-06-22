import { LightningElement, track } from 'lwc';
import { getParamsFromPage } from'c/navigationUtils';
import CSP_SearchDocuments from '@salesforce/label/c.CSP_SearchDocuments';

export default class PortalDocumentsSearchPage extends LightningElement {
    @track label = {
        CSP_SearchDocuments
    };

    @track topResults = true;
    @track category;
    @track documentObject;
    @track searchText = "";
    timeout = null;

    searchIconUrl = '/csportal/s/CSPortal/Images/Icons/searchColored.svg';

    connectedCallback() {
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.category !== undefined) {
            this.category = pageParams.category.replace(/\+/g, ' ');
            this.topResults = false;
        }

        let _documentObject = {
            category : {
                name: this.category,
                noResults: 0,
                loading: true
            },
            topResults : this.topResults, 
            searchText: this.searchText,
            productCategory : '',
            countryOfPublication : ''
        };

        this.documentObject = _documentObject;
    }

    handleHighlightFilter(event){        
        let detailObject = JSON.parse(JSON.stringify(event.detail));

        this.documentObject = detailObject;
    }

    handleFilter(event) {
        let detailObject = JSON.parse(JSON.stringify(event.detail));

        this.documentObject = detailObject;        
    }

    onInputChange(event) {
        this.searchText = event.target.value;

        clearTimeout(this.timeout);

        this.timeout = setTimeout(() => {
            if(this.searchText.length > 3 || this.searchText === '') {
                let _documentObject = JSON.parse(JSON.stringify(this.documentObject));
                _documentObject.searchText = this.searchText;

                this.documentObject = _documentObject;
            }
        }, 1500, this);
    }
}
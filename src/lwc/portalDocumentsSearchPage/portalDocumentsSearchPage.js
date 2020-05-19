import { LightningElement, track } from 'lwc';
import { getParamsFromPage } from'c/navigationUtils';
import CSP_SearchDocuments from '@salesforce/label/c.CSP_SearchDocuments';
import CSP_Search_TypeIn_text1 from '@salesforce/label/c.CSP_Search_TypeIn_text1';
import CSP_Search_TypeIn_text2 from '@salesforce/label/c.CSP_Search_TypeIn_text2';
import CSP_Search_TypeIn_text3 from '@salesforce/label/c.CSP_Search_TypeIn_text3';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalDocumentsSearchPage extends LightningElement {
    @track label = {
        CSP_SearchDocuments,
        CSP_Search_TypeIn_text1,
        CSP_Search_TypeIn_text2,
        CSP_Search_TypeIn_text3
    };

    @track topResults = true;
    @track category = '';
    @track docId = '';
    @track documentObject;
    @track searchText = '';
    @track categories = [];
    @track renderNoResults = true;
    @track loading = true;
    timeout = null;
    @track showCross = false;

    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';
    searchIconNoResultsUrl = '/csportal/s/CSPortal/Images/Icons/searchNoResult.svg';

    connectedCallback() {
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined) {
            if(pageParams.category !== undefined) {
                this.category = pageParams.category;
                this.topResults = false;
            }
            if(pageParams.searchText !== undefined) {
                this.searchText = pageParams.searchText;
                this.docId = pageParams.docId;
                this.onInputChange(this.searchText);
            }
        }

        let _documentObject = {
            categories: [],
            categorySelected: this.category,
            docId: this.docId,
            topResults: this.topResults
        };

        this.documentObject = _documentObject;
        this.categories = _documentObject.categories;
    }

    handleHighlightFilter(event) {
        this.loading = true;
        let detailObject = JSON.parse(JSON.stringify(event.detail));
        this.searchText = '';
        this.documentObject = detailObject;
        this.categories = detailObject.categories;
        this.loading = false;
    }

    handleFilter(event) {
        this.loading = true;
        let detailObject = JSON.parse(JSON.stringify(event.detail));

        this.documentObject = detailObject;
        this.categories = this.documentObject.categories;

        this.resultsToRender();
    }

    categoryFilter(event) {
        this.loading = true;
        let detailCategory = JSON.parse(JSON.stringify(event.detail));
        let detailObject = JSON.parse(JSON.stringify(this.documentObject));

        for(let i = 0; i < detailObject.categories.length; i++) {
            if(detailObject.categories[i].apiName === detailCategory.apiName &&
                (
                    (detailObject.categories[i].noResults !== detailCategory.noResults) ||
                    detailObject.categories[i].searchText !== detailCategory.searchText ||
                    detailObject.categories[i].productCategory !== detailCategory.productCategory ||
                    detailObject.categories[i].countryOfPublication !== detailCategory.countryOfPublication
                )) {
                detailObject.categories[i] = detailCategory;
                break;
            }
        }

        this.documentObject = detailObject;
        this.resultsToRender();
    }

    resultsToRender() {
        let render = true;
        let detailObject = JSON.parse(JSON.stringify(this.documentObject));
        let found = false;
        if(detailObject.categorySelected === '') {
            for(let i = 0; i < detailObject.categories.length; i++) {
                if(detailObject.categories[i].noResults !== 0) {
                    found = true;
                    break;
                }
            }
        } else {
            for(let i = 0; i < detailObject.categories.length; i++) {
                if(detailObject.categorySelected === detailObject.categories[i].apiName && detailObject.categories[i].noResults !== 0) {
                    found = true;
                    break;
                }
            }
        }

        if(found) {
            render = false;
        }
        this.renderNoResults = render;
        this.loading = false;
    }

    filterInputChange(event) {
        this.searchText = event.target.value;

        this.onInputChange(this.searchText);
    }

    onInputChange(param) {
        this.loading = true;
        this.searchText = param;
        this.showCross = this.searchText.length>0;

        clearTimeout(this.timeout);

        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {

            if(this.searchText.length > 2 || this.searchText === '') {
                let _documentObject = JSON.parse(JSON.stringify(this.documentObject));
                for(let i = 0; i < _documentObject.categories.length; i++) {
                    _documentObject.categories[i].searchText = this.searchText;
                }

                this.documentObject = _documentObject;
                let _categories = JSON.parse(JSON.stringify(this.categories));
                for(let i = 0; i < _categories.length; i++) {
                    _categories[i].searchText = this.searchText;
                }
                this.categories = _categories;
            }
            this.loading = false;
        }, 1500, this);
    }

    removeTextSearch(){
        this.onInputChange('');
    }
    
    showCategory(event) {
        //Handles category selection from category's results( right panel)
        let categoryName = event.detail.category;
        let __documentObject = JSON.parse(JSON.stringify(this.documentObject));


        __documentObject.refreshFilter=true;
        if(__documentObject.categorySelected !== categoryName ||__documentObject.refreshFilter===true ) {            
            __documentObject.categorySelected = categoryName;
            __documentObject.topResults = false;
            for(let i = 0; i < __documentObject.categories.length; i++) {
                if(__documentObject.categories[i].apiName === categoryName) {
                    __documentObject.categories[i].topResults = false;
                    __documentObject.categories[i].productCategory = '';
                    __documentObject.categories[i].countryOfPublication = '';
                    __documentObject.categories[i].show = true;
                } else {
                    __documentObject.categories[i].show = false;
                }
            }               
        }


        this.loading = true;        


        this.documentObject = __documentObject;
        this.categories = this.documentObject.categories;


        this.resultsToRender();
    }
}
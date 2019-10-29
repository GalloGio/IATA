import { LightningElement, api, track } from 'lwc';
import getSearchDocuments from '@salesforce/apex/PortalDocumentsController.getSearchDocuments';
import getContentDistribution from '@salesforce/apex/CSP_Utils.getContentDistribution';
import CSP_Search_Documents_ProdType from '@salesforce/label/c.CSP_Search_Documents_ProdType';
import IDCard_Description from '@salesforce/label/c.IDCard_Description';
import CSP_Documents_PubliCountry from '@salesforce/label/c.CSP_Documents_PubliCountry';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import CSP_Search_NoResults_text3 from '@salesforce/label/c.CSP_Search_NoResults_text3';	
import CurrencyCenter_Open from '@salesforce/label/c.CurrencyCenter_Open';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalDocumentsCategory extends LightningElement {
    @track label = {
        CSP_Search_Documents_ProdType,
        IDCard_Description,
        CSP_Documents_PubliCountry,
        CSP_Search_NoResults_text1,
        CSP_Search_NoResults_text2,
        CSP_Search_NoResults_text3,
        CurrencyCenter_Open
    };
    @track documentsList = [];
    @track _documentObject;
    @track page = 0;
    @track loadingMoreResults = false;
    @track concatValues = [];
    @track totalResults = 0;

    searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';

    @api
    get documentObject() {
        return this._documentObject; 
    }
    set documentObject(value) {
        let _value = JSON.parse(JSON.stringify(value));
        
        if(this._documentObject !== undefined) {
            let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

            this._documentObject = _value;
            if((_value.topResults !== __documentObject.topResults ||
                _value.searchText !== __documentObject.searchText ||
                _value.productCategory !== __documentObject.productCategory ||
                _value.countryOfPublication !== __documentObject.countryOfPublication) ||
                _value.show !== __documentObject.show) {

                this.resetPagination();
                this.searchDocuments();
            }
        } else {
            this._documentObject = _value;
            this.searchDocuments();
        }
    }

    get documentsResults() {
        return this.documentsList.length > 0;
    }

    connectedCallback() {
        document.addEventListener('scroll', () => {
            this.scrollListener();
        }, this);
    }

    scrollListener() {
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));
        let totalLength = this.concatValues.length;

        if(__documentObject.topResults === false && this.loadingMoreResults === false && totalLength < this.totalResults) {
            let divToTop = this.template.querySelectorAll('.endOfTable')[0].getBoundingClientRect().top;
            let windowSize = window.innerHeight;
            let offset = (windowSize/10) * 1;

            if(divToTop < windowSize-offset) {                
                this.page = this.page + 1;
                this.loadingMoreResults = true;
                this.searchDocuments();
            }
        }
    }

    resetPagination(){
        this.page = 0;
        this.totalResults = 0;
        this.concatValues = [];
    }

    searchDocuments() {
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

        let getSearchDocumentsObj = { 
            searchKey : this._documentObject.searchText,
            category : this._documentObject.apiName, 
            prodCat : this._documentObject.productCategory,
            publiCountry : this._documentObject.countryOfPublication,
            requestedPage : this.page,
            docId: this._documentObject.docId
        };

        getSearchDocuments(getSearchDocumentsObj)
            .then(results => {
                if(results.records.length > 0) {
                    let docs = JSON.parse(JSON.stringify(results.records));
                    if(this.page === 0) this.totalResults = results.totalItemCount;
                    
                    let docsMap = {};
                    Object.keys(docs).forEach(function (el) {
                        if([docs[el].Document_Category__c] !== undefined) {
                            docsMap[docs[el].Document_Category__c] = docsMap[docs[el].Document_Category__c] || [];
                            docsMap[docs[el].Document_Category__c].push({
                                id: docs[el].Id, 
                                title: docs[el].Title, 
                                desc: docs[el].Description, 
                                prodCat: docs[el].Product_Category__c, 
                                countryPubli: docs[el].Country_of_publication__c !== undefined ? docs[el].Country_of_publication__c.replace(/;/g, ', ') : '', 
                                category: docs[el].Document_Category__c, 
                                language: docs[el].Language__c, 
                                filetype: docs[el].FileType, 
                                open: docs[el].Id === __documentObject.docId ? true : false});
                        }
                    });
                    
                    let tempDocs = {};
                    tempDocs = JSON.parse(JSON.stringify(docsMap));

                    let docsList = [];
                    for(let key in tempDocs) {
                        if (tempDocs.hasOwnProperty(key)) {
                            
                            let labelForKey = this._documentObject.name;

                            if(this._documentObject.topResults === false) { // INFINITE SCROLL
                                this.concatValues = this.concatValues.concat(tempDocs[this._documentObject.apiName]);
                                docsList.push({ key: key, label : labelForKey, value: this.concatValues, noResults: this.totalResults });
                                __documentObject.noResults = this.totalResults;
                            } else {
                                let noResults = results.totalItemCount > 10 ? '10+' : results.totalItemCount;
                                docsList.push({ key: key, label : labelForKey, value: tempDocs[key], noResults: noResults });
                                if(__documentObject.apiName === key) {
                                    __documentObject.noResults = noResults;
                                }
                            }
                        }
                    }


                    
                    const selectedEvent = new CustomEvent('categoryfilter', { bubbles: true, detail: __documentObject });
                    this.dispatchEvent(selectedEvent);

                    this.documentsList = docsList;
                    this.loadingMoreResults = false;
                } else {
                    __documentObject.noResults = 0;
                    const selectedEvent = new CustomEvent('categoryfilter', { bubbles: true, detail: __documentObject });
                    this.dispatchEvent(selectedEvent);

                    this.documentsList = [];
                }
                this.loading = false;
            })
            .catch(error => {
                this.loading = false;
                this.documentsList = [];
            }
        );
    }

    openRecordDetail(event) {
        let recordIndex = event.target.dataset.item;
        let docs = JSON.parse(JSON.stringify(this.documentsList));

        Object.keys(docs).forEach(function (el) {
            let values = docs[el].value;
            
            for(let key in values) {
                if(recordIndex === values[key].id && values[key].open === false) {
                    values[key].open = true;
                } else {
                    values[key].open = false;
                }
            }
        });

        this.documentsList = docs;
    }

    viewDocument(event) {
        this.loading = true;
        let url = event.target.dataset.url;
        if(url !== undefined && url.length>0){
             url = url.trim();
            if(url.substring(0,4) !== 'http')
                url = 'https://' + url;   
       
            window.open(url, '_blank'); 

        } else{
        getContentDistribution({ documentName: event.target.dataset.name, documentId: event.target.dataset.item })
            .then(results => {
                window.open(results.DistributionPublicUrl, '_blank');
                });
        }
        this.loading = false;
    }

    downloadDocument(event) {
        this.loading = true;
        getContentDistribution({ documentName: event.target.dataset.name, documentId: event.target.dataset.item })
            .then(results => {
                window.open(results.ContentDownloadUrl, '_self');
                this.loading = false;});
    }

    categorySelected(event) {
        let categoryName = event.target.dataset.item;
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

        if(__documentObject.categorySelected !== categoryName) {
            
            __documentObject.categorySelected = categoryName;
            __documentObject.topResults = false;
            /*for(let i = 0; i < __documentObject.categories.length; i++) {
                if(__documentObject.categories[i].apiName === categoryName) {
                    __documentObject.categories[i].topResults = false;
                    __documentObject.categories[i].productCategory = '';
                    __documentObject.categories[i].countryOfPublication = '';
                }
            }*/

    
            const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
            this.dispatchEvent(selectedEvent);
    
        }
    }
}
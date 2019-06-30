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
    @track loading = true;
    @track documentsList = [];
    @track _documentObject;
    @track page = 0;
    @track loadingMoreResults = false;
    @track concatValues = [];
    @track totalResults = 0;
    @track firstLoad = true;

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
            if((this.firstLoad === true) || (_value.topResults !== __documentObject.topResults || 
                _value.category.name !== __documentObject.category.name || 
                _value.searchText !== __documentObject.searchText ||
                _value.productCategory !== __documentObject.productCategory ||
                _value.countryOfPublication !== __documentObject.countryOfPublication)) {

                this.loading = true;
                this.resetPagination();
                this.searchDocuments();
            }
        } else {
            this._documentObject = _value;
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
        getSearchDocuments({ 
            searchKey : this._documentObject.searchText,
            category : this._documentObject.category.name,
            prodCat : this._documentObject.productCategory,
            publiCountry : this._documentObject.countryOfPublication,
            requestedPage : this.page
        })
            .then(results => {
                let docs = JSON.parse(JSON.stringify(results.records));
                let docsByCategory = JSON.parse(JSON.stringify(results.documentsMap));                
                if(this.page === 0) this.totalResults = results.totalItemCount;
                
                let docsMap = {};
                Object.keys(docs).forEach(function (el) {
                    docsMap[docs[el].Document_Category__c] = docsMap[docs[el].Document_Category__c] || [];
                    docsMap[docs[el].Document_Category__c].push({ id: docs[el].Id, title: docs[el].Title, desc: docs[el].Description, prodCat: docs[el].Product_Category__c, countryPubli: docs[el].Country_of_publication__c.replace(/;/g, ', '), category: docs[el].Document_Category__c, language: docs[el].Language__c, filetype: docs[el].FileType, open: false });
                });

                let tempDocs = {};
                tempDocs = JSON.parse(JSON.stringify(docsMap));
                
                let __documentObject = JSON.parse(JSON.stringify(this._documentObject));
                let docsList = [];
                for(let key in tempDocs) {
                    if (tempDocs.hasOwnProperty(key)) {
                        if(this._documentObject.topResults === false) { // INFINITE SCROLL
                            this.concatValues = this.concatValues.concat(tempDocs[this._documentObject.category.name]);
                            docsList.push({ key: key, value: this.concatValues, noResults: docsByCategory[key] });
                            __documentObject[key].noResults = docsByCategory[key];
                        } else {
                            let noResults = docsByCategory[key] > 10 ? '10+' : docsByCategory[key];
                            docsList.push({ key: key, value: tempDocs[key], noResults: noResults });
                            __documentObject[key].noResults = noResults;
                        }
                    }
                }
                
                const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
                this.dispatchEvent(selectedEvent);

                this.documentsList = docsList;
                this.firstLoad = false;
                this.loading = false;
                this.loadingMoreResults = false;
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
        getContentDistribution({ documentName: event.target.dataset.name, documentId: event.target.dataset.item })
            .then(results => {
                window.open(results.DistributionPublicUrl, '_blank');
                this.loading = false;});
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
        
        if(__documentObject.category.name !== categoryName) {
            __documentObject.topResults = false;
            __documentObject.category.name = categoryName;
            __documentObject.productCategory = '';
            __documentObject.countryOfPublication = '';

            const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
            this.dispatchEvent(selectedEvent);
        }
    }
}
import { LightningElement, api, track } from 'lwc';
import getSearchDocumentsWithBookmarks from '@salesforce/apex/PortalDocumentsController.getSearchDocumentsWithBookmarks';
import toggleBookmarkDocument from '@salesforce/apex/PortalDocumentsController.toggleBookmarkDocument';
import getContentDistribution from '@salesforce/apex/CSP_Utils.getContentDistribution';
import CSP_Search_Documents_ProdType from '@salesforce/label/c.CSP_Search_Documents_ProdType';
import IDCard_Description from '@salesforce/label/c.IDCard_Description';
import CSP_Documents_PubliCountry from '@salesforce/label/c.CSP_Documents_PubliCountry';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import CSP_Search_NoResults_text3 from '@salesforce/label/c.CSP_Search_NoResults_text3';	
import ISSP_View from '@salesforce/label/c.ISSP_View';
import CSP_LastUpdate from '@salesforce/label/c.CSP_LastUpdate';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_Search_Case_Type from '@salesforce/label/c.CSP_Search_Case_Type';
import CSP_DocumentBookmarkAdded from '@salesforce/label/c.CSP_DocumentBookmarkAdded';
import CSP_DocumentBookmarkRemoved from '@salesforce/label/c.CSP_DocumentBookmarkRemoved';
import CSP_Success from '@salesforce/label/c.CSP_Success';
import CSP_BookmarkDocAddToolTip from '@salesforce/label/c.CSP_BookmarkDocAddToolTip';
import CSP_BookmarkDocRemToolTip from '@salesforce/label/c.CSP_BookmarkDocRemToolTip';
import PKB2_js_error from '@salesforce/label/c.PKB2_js_error';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class PortalDocumentsCategory extends LightningElement {
    @track label = {
        CSP_Search_Documents_ProdType,
        IDCard_Description,
        CSP_Documents_PubliCountry,
        CSP_Search_NoResults_text1,
        CSP_Search_NoResults_text2,
        CSP_Search_NoResults_text3,
        CSP_LastUpdate,
        CSP_Search_Case_Type,
        CSP_DocumentBookmarkAdded,
        CSP_DocumentBookmarkRemoved,
        CSP_BookmarkDocAddToolTip,
        CSP_BookmarkDocRemToolTip,
        CSP_Success,
        PKB2_js_error,
        ISSP_View
    };
    @track documentsList = [];
    @track _documentObject;
    @track page = 0;
    @track loadingMoreResults = false;
    @track concatValues = [];
    @track totalResults = 0;

    isSpecialBodyCard=true;

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
                _value.show === true) {

                this.resetPagination();
                this.searchDocuments();
            }
        } else {
            this._documentObject = _value;
            this.searchDocuments();
        }
    }

    get documentsResults() {
        return this.documentsList.length > 0 && this.documentObject.show;
    }

    connectedCallback() {
        document.addEventListener('scroll', () => {
            this.scrollListener();
        }, this);
    }

    renderedCallback(){        
        this.toggleUnderline(this.documentsList.length>0);
    }

    toggleUnderline(add){
        //Display the underline for all but the last line in the list
        this.template.querySelectorAll('.cellDefault').forEach((elem, key, arr)=>{
            if (key <= (arr.length - 5)){ 
                if(add) elem.classList.add('underLined');               
            } else {
                elem.classList.remove('underLined');
            }
        });

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
   

    @api
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

        getSearchDocumentsWithBookmarks(getSearchDocumentsObj)
            .then(results => {
                let docs = JSON.parse(results.recordsString);
                if(docs.length>0) {
                    if(this.page === 0) this.totalResults = results.totalItemCount;
                    
                    let docsMap = {};
                    Object.keys(docs).forEach(function (el) {
                        if([docs[el].record.Document_Category__c] !== undefined) {
                            docsMap[docs[el].record.Document_Category__c] = docsMap[docs[el].record.Document_Category__c] || [];
                            docsMap[docs[el].record.Document_Category__c].push({
                                Id: docs[el].record.Id, 
                                Title: docs[el].record.Title, 
                                Description: docs[el].record.Description, 
                                Product_Category__c: docs[el].record.Product_Category__c, 
                                Country_of_publication__c: docs[el].record.Country_of_publication__c !== undefined ? docs[el].record.Country_of_publication__c.split(";").join(", ") : '', 
                                Document_Category__c: docs[el].record.Document_Category__c, 
                                Language__c: docs[el].record.Language__c, 
                                LastModifiedDate: new Date(docs[el].record.LastModifiedDate.substring(0,docs[el].record.LastModifiedDate.indexOf('.'))).toLocaleDateString(),                            
								ContentUrl: docs[el].record.ContentUrl,
                                bookMarked: docs[el].isBookmarked,
                                ContentDocumentId: docs[el].record.ContentDocumentId,
                                FileType: docs[el].record.FileType,
                                isLink: docs[el].record.FileType === 'LINK' ? true : false,
                                open: docs[el].record.Id === __documentObject.docId ? true : false});
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
                                if(this._documentObject.show === true) {
                                    __documentObject.noResults = this.totalResults;
                                } else {
                                    __documentObject.noResults = this.totalResults > 10 ? '10+' : this.totalResults;
                                }
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
                if(recordIndex === values[key].Id && values[key].open === false) {
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
		let url = event.target.dataset.url;

        if(url !== undefined && url.length>0){
            this.viewDocument(event);
        } else{
			this.loading = true;
			getContentDistribution({ documentName: event.target.dataset.name, documentId: event.target.dataset.item })
				.then(results => {
					window.open(results.ContentDownloadUrl, '_self');
					this.loading = false;});
		  }
    }

    categorySelected(event) {
        let categoryName = event.target.dataset.item;
    
        const selectedEvent = new CustomEvent('showcategory', { detail: {category:categoryName} });
        this.dispatchEvent(selectedEvent);

        document.body.scrollTop = 0; // For Safari
        document.documentElement.scrollTop = 0; // For Chrome, Firefox, IE and Opera
    }

    bookmarkDoc(event){
        let doc=event.target.dataset.item;
        let selectDoc =this.documentsList[0].value.find(element => element.ContentDocumentId == doc);
        selectDoc.bkloading=true;
        toggleBookmarkDocument({
            docId:doc
        }).then(val=>{
            selectDoc.bookMarked=!selectDoc.bookMarked;
            const event = new ShowToastEvent({
                title: this.label.CSP_Success,
                variant:'success',
                mode:'pester',
                message: selectDoc.bookMarked ? this.label.CSP_DocumentBookmarkAdded:this.label.CSP_DocumentBookmarkRemoved.replace('#doc',selectDoc.Title),
            });
            this.dispatchEvent(event);
            selectDoc.bkloading=false;
            
            this.dispatchEvent(new CustomEvent('refreshlist', { bubbles: true, composed: true }));
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: this.label.PKB2_js_error,
                variant:'error',
                mode:'pester',
                message: error,
            });
            this.dispatchEvent(event);

            selectDoc.bkloading=false;
        });
    }
}

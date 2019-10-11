import { LightningElement, api, track } from 'lwc';
import getDocumentsCategories from '@salesforce/apex/CSP_Utils.getPickListValues';
import CSP_Search_TopResults from '@salesforce/label/c.CSP_Search_TopResults';

export default class PortalDocumentsFilters extends LightningElement {
    @track label = {
        CSP_Search_TopResults
    };
    @track _documentObject;
    @track lstTiles;
    @track loading = true;
    @track topicValues;
    @track typeValues;
    @track countryValues;
    renderas = false;

    @api
    get documentObject() {
        return this._documentObject;
    }
    set documentObject(value) {
        let _value = JSON.parse(JSON.stringify(value));

        if(this._documentObject !== undefined) {
            let __documentObjectOld = JSON.parse(JSON.stringify(this._documentObject));

            this._documentObject = _value;
            if(_value.topResults !== __documentObjectOld.topResults || _value.categorySelected !== __documentObjectOld.categorySelected || _value.show !== __documentObjectOld.show) {
                this.renderFilters(_value.categorySelected);
            }

            let modifiedCategories = [];
            let __documentObject = JSON.parse(JSON.stringify(this._documentObject.categories));
            for(let i = 0; i < __documentObjectOld.categories.length; i++) {
                for(let j = 0; j < __documentObject.length; j++) {
                    if(__documentObjectOld.categories[i].name === __documentObject[j].name && __documentObjectOld.categories[i].noResults !== __documentObject[j].noResults) {
                        modifiedCategories.push({ name: __documentObject[j].name, noResults: __documentObject[j].noResults, loading: false });
                        break;
                    }
                }
            }
            if (modifiedCategories.length > 0) this.updateTiles(modifiedCategories);
        } else {
            this._documentObject = _value;
        }
    }

    get typePicklistValues() {
        return this.typeValues;
    }

    get countryPicklistValues() {
        return this.countryValues;
    }

    connectedCallback() {        
        // DOCUMENT CATEGORY PICKLIST VALUES
        getDocumentsCategories({ sobj : 'ContentVersion', field : 'Document_Category__c' }) 
        .then(results => {           
            let docs = JSON.parse(JSON.stringify(results));            
            
            let tempDocs = [];
            let tempCategory = this._documentObject !== undefined && this._documentObject.categorySelected !== undefined ? this._documentObject.categorySelected : undefined;
            
            Object.keys(docs).forEach(function (el) {
                if(tempCategory !== undefined && tempCategory === docs[el].label) {
                    tempDocs.push({ categoryName : docs[el].label, open: true, noResults: 0, class: 'slds-p-around_medium customCardTitleBox customBorderlessCardWhite', show: true });
                } else {
                    tempDocs.push({ categoryName : docs[el].label, open: false, noResults: 0, class: 'slds-p-around_medium customCardTitleBox cursorPointer cardStyle', show: false });
                }
            });
            let __documentObject = JSON.parse(JSON.stringify(this._documentObject));
            for(let key in tempDocs) {
                if (tempDocs.hasOwnProperty(key)) {
                    __documentObject.categories.push({ 
                        name: tempDocs[key].categoryName, 
                        noResults: 0, 
                        loading: false, 
                        searchText: '', 
                        productCategory: '', 
                        countryOfPublication: '', 
                        topResults: __documentObject.categorySelected !== '' ? false : true, 
                        docId: __documentObject.docId !== '' ? __documentObject.docId : '',
                        show: tempDocs[key].show
                    });
                }
            }
            
            const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
            this.dispatchEvent(selectedEvent);
            
            this.lstTiles = tempDocs;
            this.loading = false;
        });

        // PRODUCT CATEGORY PICKLIST VALUES
        this.typeValues = [];
        getDocumentsCategories({ sobj : 'ContentVersion', field : 'Product_Category__c' })
        .then(results => {
            this.typeValues = this.renderPicklistValues(JSON.parse(JSON.stringify(results)));
        });

        // COUNTRY OF PUBLICATION PICKLIST VALUES
        this.countryValues = [];
        getDocumentsCategories({ sobj : 'ContentVersion', field : 'Country_of_publication__c' })
        .then(results => {
            this.countryValues = this.renderPicklistValues(JSON.parse(JSON.stringify(results)));
        });
    }

    renderPicklistValues(options) {
        let values = [];
        let allValues = [{ label: 'All', value: '', checked: false }];

        Object.keys(options).forEach(function (el) {
            values.push({ label: options[el].label, value : options[el].value });
        });

        return allValues.concat(values);
    }

    updateTiles(modifiedCategories) {
        let topicVals = JSON.parse(JSON.stringify(this.lstTiles));

        Object.keys(topicVals).forEach(function (el) {
            Object.keys(modifiedCategories).forEach(function (elem) {
                if(modifiedCategories[elem].name === topicVals[el].categoryName && modifiedCategories[elem].noResults !== topicVals[el].noResults) {
                    topicVals[el].noResults = modifiedCategories[elem].noResults;
                }
            });
        });
        
        this.lstTiles = topicVals;
    }

    handleTopSearch() {
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));
        
        if(__documentObject.topResults === false || __documentObject.categories.find(obj => obj.searchText !== '').searchText !== '') {
            __documentObject.categorySelected = '';
            __documentObject.topResults = true;

            for(let i = 0; i < __documentObject.categories.length; i++) {
                __documentObject.categories[i].topResults = true;
                __documentObject.categories[i].show = true;
                __documentObject.categories[i].countryOfPublication = '';
                __documentObject.categories[i].productCategory = '';
                __documentObject.categories[i].searchText = '';
                __documentObject.categories[i].docId = '';
            }
            
            const selectedEvent = new CustomEvent('highlightfilter', { detail: __documentObject });
            this.dispatchEvent(selectedEvent);
        }
    }

    renderFilters(category) {
        let topicVals = JSON.parse(JSON.stringify(this.lstTiles));

        Object.keys(topicVals).forEach(function (el) {
            if(category !== undefined && category === topicVals[el].categoryName) {
                topicVals[el].open = true;
                topicVals[el].class = 'slds-p-around_medium customCardTitleBox customBorderlessCardWhite';
            } else {
                topicVals[el].open = false;
                topicVals[el].class = 'slds-p-around_medium customCardTitleBox cursorPointer cardStyle';
            }
        });

        this.lstTiles = topicVals;        
    }

    categorySelected(event) {
        let categoryName = event.target.dataset.item;
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));
        if(__documentObject.categorySelected !== categoryName) {            
            __documentObject.categorySelected = categoryName;
            __documentObject.topResults = false;
            for(let i = 0; i < __documentObject.categories.length; i++) {
                if(__documentObject.categories[i].name === categoryName) {
                    __documentObject.categories[i].show = true;
                    __documentObject.categories[i].topResults = false;
                    __documentObject.categories[i].productCategory = '';
                    __documentObject.categories[i].countryOfPublication = '';
                } else {
                    __documentObject.categories[i].show = false;
                }
            }

            const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
            this.dispatchEvent(selectedEvent);
    
        }
    }

    handleTypePicklist(event) {
        let prodCat = event.detail.value;
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

        for(let i = 0; i < __documentObject.categories.length; i++) {
            if(__documentObject.categories[i].name === __documentObject.categorySelected) {
                __documentObject.categories[i].productCategory = prodCat;
                break;
            }
        }

        const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
        this.dispatchEvent(selectedEvent);
    }
    
    handleCountryPicklist(event) {
        let publiCountry = event.detail.value;
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

        for(let i = 0; i < __documentObject.categories.length; i++) {
            if(__documentObject.categories[i].name === __documentObject.categorySelected) {
                __documentObject.categories[i].countryOfPublication = publiCountry;
                break;
            }
        }

        const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
        this.dispatchEvent(selectedEvent);
    }
}
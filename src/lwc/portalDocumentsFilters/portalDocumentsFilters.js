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
    @track localTiles;
    renderas = false;

    @api
    get documentObject() {
        return this._documentObject;
    }
    set documentObject(value) {
        let _value = JSON.parse(JSON.stringify(value));

        if(this._documentObject !== undefined) {
            let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

            this._documentObject = _value;
            if(_value.topResults !== __documentObject.topResults || _value.category.name !== __documentObject.category.name) {
                this.renderFilters(_value.category.name);
            }

            let modifiedCategories = [];
            for(let key in this._documentObject) {
                if (this._documentObject.hasOwnProperty(key)) {
                    if((this.localTiles[key] !== undefined && this.localTiles[key] !== null) && this.localTiles[key].noResults !== this._documentObject[key].noResults) {
                        modifiedCategories.push({ name: this._documentObject[key].name, noResults: this._documentObject[key].noResults, loading: false });
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
            let tempCategory = this._documentObject !== undefined && this._documentObject.category.name !== undefined ? this._documentObject.category.name : undefined;
            
            Object.keys(docs).forEach(function (el) {                 
                if(tempCategory !== undefined && tempCategory === docs[el].label) {
                    tempDocs.push({ categoryName : docs[el].label, open: true, noResults: 0, class: 'slds-p-around_medium customCardTitleBox customBorderlessCardWhite' });
                } else {
                    tempDocs.push({ categoryName : docs[el].label, open: false, noResults: 0, class: 'slds-p-around_medium customCardTitleBox cursorPointer cardStyle' });
                }
            });
            let __documentObject = JSON.parse(JSON.stringify(this._documentObject));
            let localTiles = {};
            for(let key in tempDocs) {
                if (tempDocs.hasOwnProperty(key)) {
                    __documentObject[tempDocs[key].categoryName] = { name: tempDocs[key].categoryName, noResults: 0, loading: false };
                    localTiles[tempDocs[key].categoryName] = { name: tempDocs[key].categoryName, noResults: 0, loading: false };
                }
            }
            this.localTiles = localTiles;
            
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
        
        if(__documentObject.topResults === false) {
            __documentObject.category.name = undefined;
            __documentObject.topResults = true;
            __documentObject.productCategory = '';
            __documentObject.countryOfPublication = '';

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
        
        if(__documentObject.category.name !== categoryName) {
            __documentObject.category.name = categoryName;
            __documentObject.topResults = false;
            __documentObject.productCategory = '';
            __documentObject.countryOfPublication = '';

            const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
            this.dispatchEvent(selectedEvent);
        }
    }

    handleTypePicklist(event) {
        let prodCat = event.detail.value;
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

        __documentObject.productCategory = prodCat;
        const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
        this.dispatchEvent(selectedEvent);
    }
    
    handleCountryPicklist(event) {
        let publiCountry = event.detail.value;
        let __documentObject = JSON.parse(JSON.stringify(this._documentObject));

        __documentObject.countryOfPublication = publiCountry;
        const selectedEvent = new CustomEvent('filter', { detail: __documentObject });
        this.dispatchEvent(selectedEvent);
    }
}
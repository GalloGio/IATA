import { LightningElement, track } from 'lwc';
import getDocumentsCategories from '@salesforce/apex/CSP_Utils.getPickListValues';
import CSP_DocumentsLabel from '@salesforce/label/c.CSP_Documents';
import CSP_DocumentsSelCat from '@salesforce/label/c.CSP_DocumentsSelCat';
import CSP_DocumentsAll from '@salesforce/label/c.CSP_DocumentsAll';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalDocumentsTiles extends NavigationMixin(LightningElement) {
    @track label = {
        CSP_DocumentsLabel,
        CSP_DocumentsSelCat,
        CSP_DocumentsAll
    };
    @track lstTiles = [];
    @track loading = true;
    iconFolder = CSP_PortalPath + 'CSPortal/Images/Support/Documents.svg';

    connectedCallback() {
        getDocumentsCategories({ sobj : 'ContentVersion', field : 'Document_Category__c' })
        .then(results => {           
            let docs = JSON.parse(JSON.stringify(results));
            let tempDocs = [];
            let iconFolderAux = this.iconFolder;
            
            Object.keys(docs).forEach(function (el) { 
                tempDocs.push({ categoryName : docs[el].label, imageURL: iconFolderAux });
            });

            this.lstTiles = tempDocs;
            this.loading = false;
        });
    }

    seeDocuments(event) {
        let selectedCategory = event.target.dataset.item;

        let params = {};
        if(selectedCategory !== undefined && selectedCategory !== null) {
            params.category = selectedCategory;
        }

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "documents-search"
            }})
        .then(url => navigateToPage(url, params));
    }
}
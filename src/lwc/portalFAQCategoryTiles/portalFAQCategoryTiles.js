import { LightningElement, track, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage, navigateToPage } from'c/navigationUtils';

import getFaqsStructure from '@salesforce/apex/DescribeDataCategoryGroupStructures.getFaqsStructure';
import getPublicFaqsStructure from '@salesforce/apex/DescribeDataCategoryGroupStructures.getPublicFaqsStructure';
import isGuestUser from '@salesforce/apex/CSP_Utils.isGuestUser';

import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';
import CSP_FAQ_Subtitle from '@salesforce/label/c.CSP_FAQ_Subtitle';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalFAQCategoryTiles extends NavigationMixin(LightningElement) {

    label = {
        CSP_FAQ_HeaderTitle,
        CSP_FAQ_Subtitle
    };
    @api renderWithIcons;
    @track lstTiles = [];
    @track loading = true;
    @track guestUser = false;
    @track userLanguage = 'en_US';

    iconsBaseLink = CSP_PortalPath + 'CSPortal/Images/FAQ/';
    iconsExtension = '.svg';
    
    connectedCallback() {
        let pageParams = getParamsFromPage();

        if(pageParams !== undefined && pageParams.language !== undefined) {              
            this.userLanguage = pageParams.language;
        }    

        isGuestUser().then(results => {            
            if(results) { 
                this.guestUser = true;
                this.retrievePublicFaqsStructure();
            } else {
                this.retrieveFaqsStructure();
            }
        });
    }

    retrieveFaqsStructure() {
        getFaqsStructure()
        .then(results => {
            if(results.length) {
                let resultsAux = JSON.parse(JSON.stringify(results));
                
                for(let i = 0; i < resultsAux.length; i++){
                    if(i === 0 || i === 1){
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-2 slds-p-vertical_xx-small slds-text-align_center';
                    }else{
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-3 slds-large-size_1-of-3 slds-p-vertical_xx-small slds-text-align_center';
                    }
                    resultsAux[i].imageURL = this.iconsBaseLink + resultsAux[i].categoryName + this.iconsExtension;
                }
                this.lstTiles = resultsAux; 
            }
            this.loading = false;
        });
    }

    retrievePublicFaqsStructure() {        
        getPublicFaqsStructure({ lang : this.userLanguage + '' })
        .then(results => {
            if(results.length) {
                let resultsAux = JSON.parse(JSON.stringify(results));
                
                for(let i = 0; i < resultsAux.length; i++){
                    if(i === 0 || i === 1){
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-2 slds-p-vertical_xx-small slds-text-align_center';
                    }else{
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-3 slds-large-size_1-of-3 slds-p-vertical_xx-small slds-text-align_center';
                    }
                    resultsAux[i].imageURL = this.iconsBaseLink + resultsAux[i].categoryName + this.iconsExtension;
                }
                this.lstTiles = resultsAux; 
            }
            this.loading = false;
        });
    }

    handleTileButtonClick(event) {
        let selectedCategory = event.target.dataset.item;

        let params = {};
        if(selectedCategory !== undefined && selectedCategory !== null) {
            params.category = selectedCategory;
        }

        let pageName;
        if(!this.guestUser) {
            pageName = 'support-view-category';
        } else {
            pageName = 'faq-category';
            params.language = this.userLanguage;
        }    

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: pageName
            }})
        .then(url => navigateToPage(url, params));
    }

}

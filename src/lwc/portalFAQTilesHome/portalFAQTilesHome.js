import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { navigateToPage } from 'c/navigationUtils';

import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';

import isGuestUser from '@salesforce/apex/CSP_Utils.isGuestUser';

import getFaqsStructure from '@salesforce/apex/DescribeDataCategoryGroupStructures.getFaqsStructure';
import getPublicFaqsStructure from '@salesforce/apex/DescribeDataCategoryGroupStructures.getPublicFaqsStructure';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class portalFAQTilesHome extends NavigationMixin(LightningElement) {

    @track labels = {
        CSP_FAQ_HeaderTitle
    };

    @track loading = true;
    @track lstTiles = [];
    @track userLanguage = 'en_US';

    iconsBaseLink = CSP_PortalPath + 'CSPortal/Images/FAQ/';
    iconsExtension = '.svg';

    @track showFaqTiles = true;

    connectedCallback() {

        isGuestUser().then(results => {
            if (results) {
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
                if (results.length <= 0)
                    this.showFaqTiles = false;
                this.treatFAQData(results);
            });
    }

    retrievePublicFaqsStructure() {
        getPublicFaqsStructure({ lang: this.userLanguage + '' })
            .then(results => {
                if (results.length <= 0)
                    this.showFaqTiles = false;
                this.treatFAQData(results);
            });
    }

    treatFAQData(results) {
        if (results.length) {
            let resultsAux = JSON.parse(JSON.stringify(results));

            for (let i = 0; i < resultsAux.length; i++) {
                resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-' + resultsAux.length + ' slds-large-size_1-of-' + resultsAux.length + ' slds-p-vertical_xx-small slds-text-align_center';

                resultsAux[i].imageURL = this.iconsBaseLink + resultsAux[i].categoryName + this.iconsExtension;
            }
            this.lstTiles = resultsAux;
        }
        this.loading = false;
    }

    handleTileButtonClick(event) {
        let selectedCategory = event.target.dataset.item;

        let params = {};
        if (selectedCategory !== undefined && selectedCategory !== null) {
            params.category = selectedCategory;
        }

        let pageName;
        if (!this.guestUser) {
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
            }
        })
            .then(url => navigateToPage(url, params));
    }

}
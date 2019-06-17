import { LightningElement, track, api } from 'lwc';
import getCategoryTiles from '@salesforce/apex/PortalFAQsCtrl.getCategoryTiles';

import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';
import CSP_FAQ_Subtitle from '@salesforce/label/c.CSP_FAQ_Subtitle';

export default class PortalFAQCategoryTiles extends NavigationMixin(LightningElement) {

    label = {
        CSP_FAQ_HeaderTitle,
        CSP_FAQ_Subtitle
    };
    @api renderWithIcons;
    @track lstTiles = [];

    iconsBaseLink = '/csportal/s/CSPortal/Images/FAQ/';
    iconsExtension = '.svg';
    
    connectedCallback() {                
        getCategoryTiles()
        .then(results => {
            let resultsAux = JSON.parse(JSON.stringify(results));

            if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                let i;
                for(i = 0; i < resultsAux.length; i++){
                    if(i === 0 || i === 1){
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-2 slds-p-vertical_xx-small slds-text-align_center';
                    }else{
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-3 slds-large-size_1-of-3 slds-p-vertical_xx-small slds-text-align_center';
                    }
                    resultsAux[i].imageURL = this.iconsBaseLink + resultsAux[i].categoryName + this.iconsExtension;
                }
                this.lstTiles = resultsAux;                
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

    handleTileButtonClick(event){
        let selectedCategory = event.target.dataset.item;

        let params = {};
        if(selectedCategory !== undefined && selectedCategory !== null) {
            params.category = selectedCategory;
        }

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-view-category"
            }})
        .then(url => navigateToPage(url, params));
    }

}
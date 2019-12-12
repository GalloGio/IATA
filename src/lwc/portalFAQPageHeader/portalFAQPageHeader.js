import { LightningElement, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

//import labels
import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import { getParamsFromPage, navigateToPage } from'c/navigationUtils';
import getFaqsStructure from '@salesforce/apex/DescribeDataCategoryGroupStructures.getFaqsStructure';
import isGuestUser from '@salesforce/apex/CSP_Utils.isGuestUser';

export default class PortalFAQPageHeader extends NavigationMixin(LightningElement) {

    label = {
        CSP_FAQ_HeaderTitle
    };

    @track iconLink;
    @track category = '';
    @track categoryValue = '';
    @track categoriesOptions = [];

    @track guestUser = false;

    connectedCallback() {
        //get the parameters for this page
        this.pageParams = getParamsFromPage();
        
        if(this.pageParams.category !== undefined && this.pageParams.category !== '') {

            isGuestUser().then(results => {
                this.guestUser = results;
            });

            getFaqsStructure({})
            .then(results => {
                //because proxy.......
                let resultsAux = JSON.parse(JSON.stringify(results));
                
                let categoriesOptions = [];
                if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                    let i;
                    for(i = 0; i < resultsAux.length; i++){
                        categoriesOptions.push({ value: resultsAux[i].categoryName, label: resultsAux[i].categoryLabel });

                        if(resultsAux[i].categoryName === this.pageParams.category){
                            this.category = resultsAux[i].categoryLabel;
                            this.categoryValue = resultsAux[i].categoryName;
                            this.iconLink = CSP_PortalPath + 'CSPortal/Images/FAQ/' + this.pageParams.category + '.svg';
                        }

                    }
                }
                
                this.categoriesOptions = categoriesOptions;
            });
        }        
    }

    handleChangeCategory(event) {
        let category = event.detail.value;

        let params = {};
        let pageName = this.guestUser ? 'faq-category' : 'support-view-category';
        params.category = category;
        this.categoryValue = category;

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: pageName
            }})
        .then(url => navigateToPage(url, params));
        
    }
}
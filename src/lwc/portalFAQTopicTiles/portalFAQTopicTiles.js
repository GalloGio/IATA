import { LightningElement, track } from 'lwc';
import getCategoryTiles from '@salesforce/apex/PortalFAQsCtrl.getCategoryTiles';

//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from'c/navigationUtils';

export default class PortalFAQTopicTiles extends NavigationMixin(LightningElement) {

    @track lstTiles = [];

    //links for images
    iconsBaseLink = '/csportal/s/CSPortal/Images/FAQ/';
    iconsExtension = '.svg';
    
    connectedCallback() {
        getCategoryTiles({})
        .then(results => {
            //because proxy.......
            let resultsAux = JSON.parse(JSON.stringify(results));
            console.log(resultsAux);

            //let lstCategories = [];

            /*let iAux;
            for(iAux = 0; iAux < resultsAux.length; iAux++){
                let found = false;
                let jAux;
                for(jAux = 0; jAux < lstCategories.length; jAux++){
                    if(resultsAux[iAux].categoryName === lstCategories[jAux].categoryName){
                        found = true;
                    }
                }
                if(found === false){
                    resultsAux.push(resultsAux[iAux]);
                }

            }*/

            //console.log(lstCategories);

            if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                let i;
                for(i = 0; i < resultsAux.length; i++){
                    if(i === 0 || i === 1){
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-large-size_1-of-2 slds-p-vertical_xx-small';
                    }else{
                        resultsAux[i].class = 'slds-col slds-size_1-of-1 slds-medium-size_1-of-3 slds-large-size_1-of-3 slds-p-vertical_xx-small';
                    }
                    resultsAux[i].imageURL = this.iconsBaseLink + resultsAux[i].categoryName + this.iconsExtension;
                }
                this.lstTiles = resultsAux;
            }
        })
        .catch(error => {
            this.error = error;
            this.loading = false;
            this.dataRecords = false;
        });
    }

    handleTileButtonClick(event){
        let selectedCategory = event.target.dataset.item;

        //console.log(selectedCategory);

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
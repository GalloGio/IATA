import { LightningElement, track } from 'lwc';

//import labels
import CSP_FAQ_HeaderTitle from '@salesforce/label/c.CSP_FAQ_HeaderTitle';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import { getParamsFromPage } from'c/navigationUtils';
import getFaqsStructure from '@salesforce/apex/DescribeDataCategoryGroupStructures.getFaqsStructure';

export default class PortalFAQPageHeader extends LightningElement {

    label = {
        CSP_FAQ_HeaderTitle
    };

    @track iconLink;
    @track category = '';

    connectedCallback() {
        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if(this.pageParams.category !== undefined && this.pageParams.category !== '') {

            getFaqsStructure({})
            .then(results => {
                //because proxy.......
                let resultsAux = JSON.parse(JSON.stringify(results));

                if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                    let i;
                    for(i = 0; i < resultsAux.length; i++){
                        if(resultsAux[i].categoryName === this.pageParams.category){
                            this.category = resultsAux[i].categoryLabel;
                            this.iconLink = CSP_PortalPath + 'CSPortal/Images/FAQ/' + this.pageParams.category + '.svg';
                            break;
                        }
                    }
                }
            });
        }
    }
}

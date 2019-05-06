import { LightningElement, track, api } from 'lwc';

import getBreadcrumbs from '@salesforce/apex/PortalBreadcrumbCtrl.getBreadcrumbs';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage, getPageName } from'c/navigationUtils';

//import labels
import CSP_Breadcrumb_Home_Title from '@salesforce/label/c.CSP_Breadcrumb_Home_Title';
import CSP_Breadcrumb_Support_Title from '@salesforce/label/c.CSP_Breadcrumb_Support_Title';
import CSP_Breadcrumb_Support_ReachUs from '@salesforce/label/c.CSP_Breadcrumb_Support_ReachUs';

export default class PortalBreadcrumbs extends NavigationMixin(LightningElement) {

    // Expose the labels to use in the template.
    labels = {
        CSP_Breadcrumb_Home_Title,
        CSP_Breadcrumb_Support_Title,
        CSP_Breadcrumb_Support_ReachUs
    };

    //Used to replace last breadcrumb with given label
    @api lastBreadcrumbLabel;

    //Used to display the breadcrumbs in brighter colors (white)
    @api showInWhite = false;

    @track lstBreadcrumbs = [];

    pagename = '';

    connectedCallback() {
        
        this.pagename = getPageName();
        //console.log(this.pagename);

        let classNameAllBreadCrumbs = 'text-linkBlue';
        let classNameLastBreadCrumb = 'text-black';
        if(this.showInWhite){
            classNameAllBreadCrumbs = 'text-white';
            classNameLastBreadCrumb = 'text-transparent';
        }

        if(this.pagename !== undefined && this.pagename !== ''){
            getBreadcrumbs({ pageName : this.pagename })
                .then(results => {
                    //console.log(results);
                    let resultsAux = results;
                    if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                        for(let i = 0; i < resultsAux.length; i++){
                            if(!resultsAux[i].Replace_With_Param__c){
                                resultsAux[i].RealLabel = this.labels[resultsAux[i].MasterLabel];
                                resultsAux[i].TextClass = classNameAllBreadCrumbs + ' cursorPointer';
                            }
                            
                            resultsAux[i].separatorClass = classNameLastBreadCrumb;

                            resultsAux[i].showSeparator = true;

                            if(i === (resultsAux.length -1) && resultsAux[i].Replace_With_Param__c){
                                resultsAux[i].RealLabel = this.lastBreadcrumbLabel;
                            }

                            if(i === (resultsAux.length -1)){
                                resultsAux[i].showSeparator = false;
                                resultsAux[i].TextClass = classNameLastBreadCrumb + ' cursorPointer';
                            }
                        }
                    }
                    //console.log(resultsAux);
                    this.lstBreadcrumbs = resultsAux;
                })
                .catch(error => {
                    console.log('error: ' , error);
                });
        }

    }

    navigateToBreadcrumb(event){
        let clickedBreadcrumbName = event.target.dataset.item;
        clickedBreadcrumbName = clickedBreadcrumbName.split('_').join('-');

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: clickedBreadcrumbName
            }})
        .then(url => navigateToPage(url, {}));
    }

}
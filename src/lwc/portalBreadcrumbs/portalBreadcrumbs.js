import { LightningElement, track, api } from 'lwc';

import getBreadcrumbs from '@salesforce/apex/PortalBreadcrumbCtrl.getBreadcrumbs';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage, getPageName } from'c/navigationUtils';

//import labels
import CSP_Breadcrumb_Home_Title from '@salesforce/label/c.CSP_Breadcrumb_Home_Title';
import CSP_Breadcrumb_Support_Title from '@salesforce/label/c.CSP_Breadcrumb_Support_Title';
import CSP_Breadcrumb_Support_ReachUs from '@salesforce/label/c.CSP_Breadcrumb_Support_ReachUs';
import CSP_Breadcrumb_FAQ_Title from '@salesforce/label/c.CSP_Breadcrumb_FAQ_Title';
import CSP_Breadcrumb_Services_Title from '@salesforce/label/c.CSP_Breadcrumb_Services_Title';

export default class PortalBreadcrumbs extends NavigationMixin(LightningElement) {

    // Expose the labels to use in the template.
    labels = {
        CSP_Breadcrumb_Home_Title,
        CSP_Breadcrumb_Support_Title,
        CSP_Breadcrumb_Support_ReachUs,
        CSP_Breadcrumb_FAQ_Title,
        CSP_Breadcrumb_Services_Title
    };

    //Used to replace last breadcrumb with given label
    @api
    get lastBreadcrumbLabel() {
        return this.finalLabel;
    }
    set lastBreadcrumbLabel(value) {
       this.finalLabel = value;
       this.processLstBreadcrumbs();
    }

    @track finalLabel;

    //Used to display the breadcrumbs in brighter colors (white)
    @api showInWhite = false;

    @track lstBreadcrumbs = [];

    pagename = '';

    connectedCallback() {
        
        this.pagename = getPageName();
        //console.log(this.pagename);

        this.classNameAllBreadCrumbs = 'text-linkBlue';
        this.classNameLastBreadCrumb = 'text-black';
        if(this.showInWhite){
            this.classNameAllBreadCrumbs = 'text-white';
            this.classNameLastBreadCrumb = 'text-transparent';
        }

        if(this.pagename !== undefined && this.pagename !== ''){
            getBreadcrumbs({ pageName : this.pagename })
                .then(results => {
                    //console.log(results);
                    this.results = results;
                    this.processLstBreadcrumbs();
                    
                })
                .catch(error => {
                    console.log('PortalBreadcrumbs connectedCallback getBreadcrumbs error: ' , error);
                });
        }

    }

    processLstBreadcrumbs(){

        //because proxy.......
        if(this.results !== undefined){
            let resultsAux = JSON.parse(JSON.stringify(this.results));

            if(resultsAux !== undefined && resultsAux !== null && resultsAux.length > 0){
                for(let i = 0; i < resultsAux.length; i++){
                    if(!resultsAux[i].Replace_With_Param__c){
                        resultsAux[i].RealLabel = this.labels[resultsAux[i].MasterLabel];
                        resultsAux[i].TextClass = this.classNameAllBreadCrumbs + ' cursorPointer';
                    }
                    
                    resultsAux[i].separatorClass = this.classNameLastBreadCrumb;

                    resultsAux[i].showSeparator = true;
                    resultsAux[i].clickable = true;

                    if(i === (resultsAux.length -1) && resultsAux[i].Replace_With_Param__c){
                        resultsAux[i].RealLabel = this.finalLabel;
                    }

                    if(i === (resultsAux.length -1)){
                        resultsAux[i].showSeparator = false;
                        resultsAux[i].TextClass = this.classNameLastBreadCrumb + '';
                        resultsAux[i].clickable = false;
                    }
                }
            }

            this.lstBreadcrumbs = resultsAux;
            //console.log('processLstBreadcrumbs', this.lstBreadcrumbs);
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
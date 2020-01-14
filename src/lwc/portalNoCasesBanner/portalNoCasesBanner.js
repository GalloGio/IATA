import { LightningElement } from 'lwc';

//import other js utils
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

//import labels
import CSP_NoCases1 from '@salesforce/label/c.CSP_NoCases1';
import CSP_NoCases2 from '@salesforce/label/c.CSP_NoCases2';
import CSP_Question1 from '@salesforce/label/c.CSP_Question1';
import CSP_Question2 from '@salesforce/label/c.CSP_Question2';

//Community Path
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalNoCasesBanner extends NavigationMixin(LightningElement) {

    //assets 
    noCasesImg = CSP_PortalPath + 'CSPortal/Images/Icons/nocases.svg';

    label = {
        CSP_NoCases1,
        CSP_NoCases2,
        CSP_Question1,
        CSP_Question2
    };

    navigateToLinkOne(event) {
        let params = {};
        params.q = 'case';

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }
    navigateToLinkTwo(event) {
        let params = {};
        params.q = 'case';

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "comm__namedPage",
            attributes: {
                pageName: "support-view-article"
            }})
        .then(url => navigateToPage(url, params));
    }

}
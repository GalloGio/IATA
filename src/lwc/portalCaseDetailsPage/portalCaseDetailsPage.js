import { LightningElement, track } from 'lwc';

import getOscarProgress from '@salesforce/apex/portal_OscarProgressBar.getOscarProgress';

import { getParamsFromPage } from'c/navigationUtils';

export default class PortalCaseDetailsPage extends LightningElement {

    @track displayOscarProgressBar = false;
    @track progressStatusList = [];

    connectedCallback() {

        this.pageParams = getParamsFromPage();

        if(this.pageParams.caseId !== undefined){
            this.getProgressBarStatus();
        }

    }

    getProgressBarStatus() {
        getOscarProgress({ caseId : this.pageParams.caseId })
        .then(results => {
            if (results.length > 0){
                this.displayOscarProgressBar = true;
                this.progressStatusList = results;
            }
        });

    }

}
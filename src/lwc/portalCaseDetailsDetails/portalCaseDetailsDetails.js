import { LightningElement, track } from 'lwc';
import getCaseById from '@salesforce/apex/PortalCasesCtrl.getCaseById';

import { getParamsFromPage } from'c/navigationUtils';

export default class PortalCaseDetailsDetails extends LightningElement {

    @track loading = true;
    @track caseDetails ;
    @track caseId;

    @track showCaseDetailsSection = false;
    @track showDocumentsSection = false;

    @track lstDocuments;
    

    connectedCallback() {

        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if(this.pageParams.caseId !== undefined){
            this.caseId = this.pageParams.caseId;
            getCaseById({ caseId : this.pageParams.caseId })
                .then(results => {
                    //console.log(results);
                    this.caseDetails = results;
                    this.loading = false;
                })
                .catch(error => {
                    console.log('error: ' , error);
                    this.loading = false;
                });
        }
    }

    get hasTopic(){
        return this.caseDetails !== undefined && this.caseDetails.Topic__c !== undefined;
    }

    get hasSubtopic(){
        return this.caseDetails !== undefined && this.caseDetails.Subtopic__c !== undefined;
    }

    get hasRegion(){
        return this.caseDetails !== undefined && this.caseDetails.Region__c !== undefined;
    }

    get hasCountryConcerned(){
        return this.caseDetails !== undefined && this.caseDetails.Country_concerned__c !== undefined;
    }

    get hasAccountConcerned(){
        return this.caseDetails !== undefined && this.caseDetails.Account_Concerned__r !== undefined && this.caseDetails.Account_Concerned__r.IATACode__c !== undefined;
    }

    get hasTypeOfCasePortal(){
        return this.caseDetails !== undefined && this.caseDetails.Type_of_case_Portal__c !== undefined;
    }

    get hasDescription(){
        return this.caseDetails !== undefined && this.caseDetails.Description !== undefined;
    }

    get hasDocuments(){
        return this.lstDocuments !== undefined && this.lstDocuments !== null && this.lstDocuments.length > 0;
    }

    toggleCaseDetailsSection(){
        this.showCaseDetailsSection = !this.showCaseDetailsSection;
    }

    toggleDocumentsDetailsSection(){
        this.showDocumentsSection = !this.showDocumentsSection;
    }

}
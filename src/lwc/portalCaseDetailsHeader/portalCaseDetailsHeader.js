import { LightningElement, track } from 'lwc';
import getCaseById from '@salesforce/apex/PortalCasesCtrl.getCaseById';
import removeRecipient from '@salesforce/apex/PortalCasesCtrl.removeRecipient';
import addNewRecipient from '@salesforce/apex/PortalCasesCtrl.addNewRecipient';
import getOscarProgress from '@salesforce/apex/portal_OscarProgressBar.getOscarProgress';
import getSurveyLink from '@salesforce/apex/PortalCasesCtrl.getSurveyLink';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getParamsFromPage } from'c/navigationUtils';

//custom label
import CSP_PendingCustomerCase_Warning from '@salesforce/label/c.CSP_PendingCustomerCase_Warning';
import ISSP_Survey from '@salesforce/label/c.ISSP_Survey';
import Open from '@salesforce/label/c.Open';
import CSP_RecipientsQuestion from '@salesforce/label/c.CSP_RecipientsQuestion';
import CSP_Recipients from '@salesforce/label/c.CSP_Recipients';
export default class PortalHomeCalendar extends LightningElement {

    @track loading = true;
    @track caseDetails ;

    @track showManageRecipientsPopup = false;
    @track manageRecipientsOkButtonDisabled = false;
    @track lstRecipients;
    @track newRecipient = '';
    @track haveRecipients = false;
    @track CaseStatusClass = '';
    @track surveyLink;

    @track pendingCustomerCase = false;
    pendingCustomerCaseWarningLabel = CSP_PendingCustomerCase_Warning;

    @track displayOscarProgressBar = false;
    @track progressStatusList = [];
    
    @track labels = {
        ISSP_Survey,
        Open,
        CSP_RecipientsQuestion,
        CSP_Recipients
    }

    connectedCallback() {
        //get the parameters for this page
        this.pageParams = getParamsFromPage();

        if(this.pageParams.caseId !== undefined){
            this.getCaseByIdJS();
        }
        
        if(this.pageParams.caseId !== undefined){
            this.getProgressBarStatus();
        }

	this.getSurveyLink();
    }

    getCaseByIdJS(){
        getCaseById({ caseId : this.pageParams.caseId })
        .then(results => {
            this.caseDetails = results;

            if(this.caseDetails.CreatedBy === undefined){
                this.caseDetails.CreatedBy.Name = 'IATA Internal User';
            }

            if(results.E2CP__AdditionalCC__c !== undefined 
                && results.E2CP__AdditionalCC__c !== null && 
                    results.E2CP__AdditionalCC__c !== ''){
                
                let lstAdditionalCCTemp = results.E2CP__AdditionalCC__c.split(';');
                let lstAdditionalCCFinal = [];
                for(let i = 0 ; i < lstAdditionalCCTemp.length; i++){
                    if(lstAdditionalCCTemp[i] !== ''){
                        lstAdditionalCCFinal.push({email : lstAdditionalCCTemp[i], id : i});
                        this.haveRecipients = true;
                    }
                }
                this.lstRecipients = lstAdditionalCCFinal;

            }else{
                this.lstRecipients = [];
                this.haveRecipients = false;
            }

            console.log('results.Status: ' , results.Status);

            this.loading = false;
            this.pendingCustomerCase = results.Status === 'Pending customer';

            this.CaseStatusClass = results.Status.replace(/\s/g, '').replace(/_|-|\./g, '');

            console.log('pendingCustomerCase: ' , this.pendingCustomerCase);
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
        });
        
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

    openManageRecipientsPopup(){
        this.showManageRecipientsPopup = true;
    }

    closeManageRecipientsPopup(){
        this.showManageRecipientsPopup = false;
    }
    

    addNewRecipientButtonClick(){

        let inputCmp = this.template.querySelector(".newRecipientTextInput");
        let emailIsValid = inputCmp.checkValidity();

        if(emailIsValid){
            let value = inputCmp.value;
            this.loading = true;

            addNewRecipient({ caseId : this.caseDetails.Id, newRecipientEmail : value })
            .then(results => {
                if(results.success === true){
                    //show success toast
                    const toastEvent = new ShowToastEvent({
                        title: "SUCCESS",
                        message: results.returnMessage,
                        variant: "success",
                    });
                    this.dispatchEvent(toastEvent);
                    this.newRecipient = '';
                    inputCmp.value = '';

                    this.getCaseByIdJS();
                }else{
                    //show error toast
                    const toastEvent = new ShowToastEvent({
                        title: "ERROR",
                        message: results.returnMessage,
                        variant: "error",
                    });
                    this.dispatchEvent(toastEvent);

                    this.loading = false;
                }

            })
            .catch(error => {
                console.log('error: ' , error);
                this.loading = false;
            });

        }else{
            inputCmp.reportValidity();
        }
    }

    removeRecipient(event){
        this.loading = true;

        let itemNum = event.target.dataset.item;

        removeRecipient({ caseId : this.caseDetails.Id, recipientEmail : this.lstRecipients[itemNum].email })
        .then(results => {
            if(results.success === true){
                //show success toast
                const toastEvent = new ShowToastEvent({
                    title: "SUCCESS",
                    message: results.returnMessage,
                    variant: "success",
                });
                this.dispatchEvent(toastEvent);

                this.getCaseByIdJS();
            }else{
                //show error toast
                const toastEvent = new ShowToastEvent({
                    title: "ERROR",
                    message: results.returnMessage,
                    variant: "error",
                });
                this.dispatchEvent(toastEvent);

                this.loading = false;
            }
        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
        });

    }


    getSurveyLink() {
        getSurveyLink({ caseId: this.pageParams.caseId })
            .then(result => {
                this.surveyLink = result;
            })
            .catch(error => {
                this.surveyLink = undefined;
            });
    }


}

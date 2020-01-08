import { LightningElement, track,api } from 'lwc';
import idOfUser from '@salesforce/user/Id';
import getCaseById from '@salesforce/apex/PortalCasesCtrl.getCaseById';
import removeRecipient from '@salesforce/apex/PortalCasesCtrl.removeRecipient';
import addNewRecipient from '@salesforce/apex/PortalCasesCtrl.addNewRecipient';
import getHideForClosedCases from '@salesforce/apex/PortalCasesCtrl.getHideForClosedCases';
import getOscarProgress from '@salesforce/apex/portal_OscarProgressBar.getOscarProgress';
import isUserLevelOne from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.isUserLevelOne';
import getSurveyLink from '@salesforce/apex/PortalCasesCtrl.getSurveyLink';
import searchContacts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchContacts';
import searchAccounts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchAccounts';
import getProfile from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.getProfile';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getParamsFromPage } from'c/navigationUtils';

//custom label
import CSP_PendingCustomerCase_Warning from '@salesforce/label/c.CSP_PendingCustomerCase_Warning';
import ISSP_Survey from '@salesforce/label/c.ISSP_Survey';
import Open from '@salesforce/label/c.Open';
import CSP_RecipientsQuestion from '@salesforce/label/c.CSP_RecipientsQuestion';
import CSP_Recipients from '@salesforce/label/c.CSP_Recipients';
import ISSP_Case_Closed_More_Than_2_Months from '@salesforce/label/c.ISSP_Case_Closed_More_Than_2_Months';
import ISSP_CaseNumber from '@salesforce/label/c.ISSP_CaseNumber';
import ISSP_Subject from '@salesforce/label/c.ISSP_Subject';
import CSP_Status from '@salesforce/label/c.CSP_Status';
import CSP_CreatedOn from '@salesforce/label/c.CSP_CreatedOn';
import CSP_LastUpdate from '@salesforce/label/c.CSP_LastUpdate';
import CSP_Manage_Recipients from '@salesforce/label/c.CSP_Manage_Recipients';
import CSP_CaseDetails from '@salesforce/label/c.CSP_Case_Details';
import CSP_AddOrRemove_Recipients from '@salesforce/label/c.CSP_AddOrRemove_Recipients';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_EmailAddress from '@salesforce/label/c.Email_address';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';

export default class PortalHomeCalendar extends LightningElement {

    @track loading = true;
    @track caseDetails ;

    @track showManageRecipientsPopup = false;
    @track manageRecipientsOkButtonDisabled = false;
    @track lstRecipients = [];
    @track newRecipient = '';
    @track haveRecipients = false;
    @track isExpired = false;
    @track expiredCard;
    @track CaseStatusClass = '';
    @track surveyLink;

    @track pendingCustomerCase = false;
    pendingCustomerCaseWarningLabel = CSP_PendingCustomerCase_Warning;

	//is the user a Level1 user? If he has not completed level 2 registration he is not
	@track Level1User = false;


	//the logged user's id
    userId = idOfUser;
    
    @track displayOscarProgressBar = false;
    @track progressStatusList = [];

    //variable to control error class sent to child component
    @track requiredClass;

    //stores emails to be sent to case creation
    caseEmails = [];
    
    @track labels = {
        ISSP_Survey,
        Open,
        CSP_RecipientsQuestion,
	CSP_Recipients,
	ISSP_CaseNumber,
	ISSP_Subject,
        CSP_AddOrRemove_Recipients,
	ISSP_Case_Closed_More_Than_2_Months,
	CSP_Status,
	CSP_CreatedOn,
    CSP_NoSearchResults,
	CSP_LastUpdate,
        CSP_Manage_Recipients,
        CSP_CaseDetails,
	CSP_EmailAddress
    }

    //Icons
    infoIcon = CSP_PortalPath + 'CSPortal/Images/Icons/info.svg';   

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

	this.isLevelOneUser();
	this.getRelatedAccounts();
    	this.getRelatedContacts();
    }   

	isLevelOneUser(){
        isUserLevelOne({userId: this.userId}).then(result => {
            this.Level1User = result;
        }).catch(error => {
            //throws error
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.PKB2_js_error,
                    message: this.label.ISSP_ANG_GenericError,
                    variant: 'error'
                })
            );
            // eslint-disable-next-line no-console
            console.log('Error: ', error);
        });
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

            this.loading = false;
            this.pendingCustomerCase = results.Status === 'Pending customer';
            document.title = CSP_CaseDetails+"_"+this.caseDetails.CaseNumber;

            this.CaseStatusClass = results.Status.replace(/\s/g, '').replace(/_|-|\./g, '');

        })
        .catch(error => {
            console.log('error: ' , error);
            this.loading = false;
        });
        
        getHideForClosedCases({ caseId : this.pageParams.caseId })
        .then(results => {
            this.isExpired = results; //Disable

            const selectedEvent = new CustomEvent("sendexpired", {
                detail: this.isExpired
              });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        })
        .catch(e => {
            console.log(e);
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

    //get the profile of the user
    getProfile() {
        getProfile()
            .then(result => {
                this.agentProfile = JSON.parse(JSON.stringify(result)).includes('ISS Portal Agency');
                if (!JSON.parse(JSON.stringify(result)).includes('Admin')) {
                    this.setPortalUserIATACode();
                }
            });
    }

    //gets related accounts and sets them in global var
    getRelatedAccounts() {
        //activate spinner
        this.loading = true;
        searchAccounts({ searchTerm: null })
            .then(relatedAccountsResult => {

                let allresults = JSON.parse(JSON.stringify(relatedAccountsResult));
                this.relatedAccounts = allresults;

                if (allresults.length === 1) {
                    this.singleresult = allresults;
                } else if (allresults.length === 0) {
                    this.singleresult = [{ title: this.label.CSP_NoSearchResults }];
                }
                this.getProfile();

                //activate spinner
                this.loading = false;
            });
    }

    //gets related contacts and sets them in global var
    getRelatedContacts() {
        //activate spinner
        this.loading = true;
        searchContacts({ searchTerm: null })
            .then(relatedContactsResult => {
                this.relatedContacts = JSON.parse(JSON.stringify(relatedContactsResult));
				this.relatedContacts = this.relatedContacts.filter(obj => obj.id !== this.caseDetails.ContactId); //remove self if case owner
                //deactivate spinner
                this.loading = false;
            });
    }

    //shows results upon clicking the search.
    showEmailResults() {
        this.template.querySelector('[data-id="emaillookup"]').setSearchResults(this.relatedContacts);
    }

    //performs search based on the input - minimum of 3 keystrokes - 300ms per search (check child component)
    handleContactSearch(event) {
        searchContacts(event.detail)
            .then(results => {
				results = results.filter(obj => obj.id !== this.caseDetails.ContactId); //remove self if case owner
                this.template.querySelector('[data-id="emaillookup"]').setSearchResults(results);
                this.requiredClass = '';
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Search could not be performed',
                        message: 'An error occured. Please refresh the page or contact administration',
                        variant: 'error'
                    })
                );
                //Errors usually are due to session timeout.
                // eslint-disable-next-line no-console
                console.log('Lookup Error: ' + error);
            });
    }

    openManageRecipientsPopup(){
        this.showManageRecipientsPopup = true;
    }

    closeManageRecipientsPopup(){
        this.showManageRecipientsPopup = false;
    }
    
	get hasSurveyLink() {
        return this.surveyLink && this.surveyLink.length > 0;
    }

    addNewRecipientButtonClick(){
        let inputCmp = this.template.querySelector('[data-id="emaillookup"]').getSelection()[0].subtitle;
        let comp = this.template.querySelector('[data-id="emaillookup"]');
        comp.focus();

        this.loading = true;    
        addNewRecipient({ caseId : this.caseDetails.Id, newRecipientEmail : inputCmp })
            .then(results => {
                if(results.success === true){

                    //show success toast
                    const toastEvent = new ShowToastEvent({
                        title: "SUCCESS",
                        message: results.returnMessage,
                        variant: "success",
                    });
                    this.getCaseByIdJS();
                    this.dispatchEvent(toastEvent);
                    this.loading = false;

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
                this.getCaseByIdJS();
                this.dispatchEvent(toastEvent);
                
                this.loading = false;
                
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


    get manageRecipients(){
        return !this.Level1User;
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

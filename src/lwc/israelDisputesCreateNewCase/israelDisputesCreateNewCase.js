import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CASE_OBJECT from '@salesforce/schema/Case';

import searchAccounts from '@salesforce/apex/IsraelDisputesCreateNewCaseCtrl.searchAccounts';
import isBeforeFifteenth from '@salesforce/apex/IsraelDisputesCreateNewCaseCtrl.isBeforeFifteenth';

//reusing controller for portalSupportReachUsCreateNewCase since required functionality fits
import searchContacts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchContacts';
import insertCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.insertCase';

import csp_CreateNewCaseMainInputEmailsTopLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputEmailsTopLabel';
import csp_errorCreatingCase from '@salesforce/label/c.csp_errorCreatingCase';
import IDCard_FillAllFields from '@salesforce/label/c.IDCard_FillAllFields';
import CSP_Deduction_Notice_Israel_Description from '@salesforce/label/c.CSP_Deduction_Notice_Israel_Description';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class IsraelDisputesCreateNewCase extends LightningElement {

    label = {
        csp_CreateNewCaseMainInputEmailsTopLabel,
        csp_errorCreatingCase,
        IDCard_FillAllFields,
        CSP_Deduction_Notice_Israel_Description,
    }

    calendarIcon = CSP_PortalPath + 'CSPortal/Images/Icons/calendar.svg'; 

    childComponent;
    
    //stores emails to be sent to case creation
    caseEmails = [];

    @track objectInfo;
    @track recTypeId;

    //spinner controller
    @track loading = true;

    //is before 15th controller
    @track isBeforeFifteenth = true;

    //goes true to show modal once case is created
    @track bShowModal = false;

    //error gatherer
    @track errors = [];

    //current typed recipient on input
    @track newRecipient;

    //items from email recipient
    @track lstRecipients = [];

    //parameters for case creation
    @track email = "";
    @track requestType = "";
    @track reasonDeduction = "";
    @track docNumber = "";
    @track issueDate = "";
    @track amountDisputed = "";
    @track caseNumber;
    @track isEmergencyCase = false;

    //variable to control error class sent to child component
    @track requiredClass;

    //variable used to set the lookup input for the lookup component
    @track singleresult;

    @track relatedAccounts;

    @track relatedContacts;

    @track caseID;
    //Same as doInit() on aura
    connectedCallback() {
        this.getRelatedAccounts();
        this.getRelatedContacts();
        this.getIsBeforeFifteenth();
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT,})
    objInfo({data}) {
        if(data) {
            const rtInfos = data.recordTypeInfos;
            this.recTypeId = Object.keys(rtInfos).find(rti => rtInfos[rti].name === 'Disputes (Israel only)');
        }
    }

    get requestTypeOptions() {
        return [
            { label: 'Deduction', value: 'Deduction' },
            { label: 'Addition', value: 'Addition' },
        ];
    }

    //gets related contacts and sets them in global var
    getRelatedContacts() {
        //activate spinner
        this.loading = true;
        searchContacts({ searchTerm: null })
            .then(relatedContactsResult => {
                this.relatedContacts = JSON.parse(JSON.stringify(relatedContactsResult));
                //deactivate spinner
                this.loading = false;
            });
    }

    //shows results upon clicking the search.
    showIataResults() {
        this.template.querySelector('[data-id="iatalookup"]').setSearchResults(this.relatedAccounts);
    }

    //shows results upon clicking the search.
    showEmailResults() {
        this.template.querySelector('[data-id="emaillookup"]').setSearchResults(this.relatedContacts);
    }

    //performs search based on the input - minimum of 3 keystrokes - 300ms per search (check child component)
    handleContactSearch(event) {
        searchContacts(event.detail)
            .then(results => {
                this.template.querySelector('[data-id="emaillookup"]').setSearchResults(results);
                this.requiredClass = '';
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.csp_SearchNotPerformed,
                        message: this.label.ISSP_ANG_GenericError,
                        variant: 'error'
                    })
                );
                //Errors usually are due to session timeout.
                // eslint-disable-next-line no-console
                console.log('Lookup Error: ' + error);
            });
    }

    //checks if it's before 15th midnight or after
    getIsBeforeFifteenth() {
        //activate spinner
        this.loading = true;
        isBeforeFifteenth()
            .then(result => {
                this.isBeforeFifteenth = result;
                //activate spinner
                this.loading = false;
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

                //activate spinner
                this.loading = false;
            });
    }

    handleIataSearch(event) {
        searchAccounts(event.detail)
            .then(results => {
                this.template.querySelector('[data-id="iatalookup"]').setSearchResults(results);
                this.requiredClass = '';
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.csp_SearchNotPerformed,
                        message: this.label.ISSP_ANG_GenericError,
                        variant: 'error'
                    })
                );
                //Errors usually are due to session timeout.
                // eslint-disable-next-line no-console
                console.log('Lookup Error: ' + error);
            });
    }

    //grabs recipient
    handleRecipient(event) {
        this.newRecipient = event.target.value;
    }

    //grabs email
    handleEmail(event) {
        this.email = event.target.value;
    }

    //grabs request type
    handleRequestType(event) {
        this.requestType = event.target.value;
    }

    //grabs reason for deduction
    handleReasonDeduction(event) {
        this.reasonDeduction = event.target.value;
    }

    //grabs document number
    handleDocNumber(event) {
        this.docNumber = event.target.value;
    }

    //grabs issue date
    handleIssueDate(event) {
        this.issueDate = event.target.value;
    }

    //grabs amount disputed
    handleAmountDisputed(event) {
        this.amountDisputed = event.target.value;
    }

    //adds recipient to list of recipients
    addNewRecipientButtonClick() {

        let inputCmp = this.template.querySelector('[data-id="emaillookup"]').getSelection()[0].subtitle;
        let comp = this.template.querySelector('[data-id="emaillookup"]');

        let lstAdditionalCCFinal = this.lstRecipients;
        let value = inputCmp;
        inputCmp = '';
        comp.focus();

        if (!lstAdditionalCCFinal.some(recipient => recipient.email === value)) {
            lstAdditionalCCFinal.push({ email: value });
            this.caseEmails.push(value);
        }
        this.lstRecipients = lstAdditionalCCFinal;
    }

    //removes recipient from list
    removeRecipient(event) {

        let lstAdditionalCCFinal = this.lstRecipients;
        let itemVal = event.target.dataset.item;
        if (lstAdditionalCCFinal.some(recipient => recipient.email === itemVal)) {
            lstAdditionalCCFinal = lstAdditionalCCFinal.filter(recipient => recipient.email !== itemVal);
            this.caseEmails = this.caseEmails.filter(item => item !== itemVal);
        }
        this.lstRecipients = lstAdditionalCCFinal;
    }

    //validate fields and finish creating the case.
    finishCreatingCase(event) {

        var error = false;
        if (this.template.querySelector('[data-id="iatalookup"]').getSelection().length === 0) {
            this.requiredClass = ' slds-has-error';
            error = true;
        } else {
            this.childComponent = this.template.querySelector('[data-id="iatalookup"]').getSelection()[0];
            this.errors = [];
            this.requiredClass = '';
        }

        if (this.newRecipient !== undefined && this.newRecipient !== '') {
            error = true;
        }
        if (this.email.trim() === '') {
            let textinput = this.template.querySelector('[data-id="email"]');
            textinput.className += ' slds-has-error';
            error = true;
        }
        if (this.requestType.trim() === '') {
            let textinput = this.template.querySelector('[data-id="reqtype"]');
            textinput.className += ' slds-has-error';
            error = true;
        }
        if (this.reasonDeduction.trim() === '') {
            let textarea = this.template.querySelector('lightning-textarea');
            textarea.className += ' slds-has-error';
            error = true;
        }
        if (this.docNumber.trim() === '') {
            let textinput = this.template.querySelector('[data-id="docnumber"]');
            textinput.className += ' slds-has-error';
            error = true;
        }
        if (this.issueDate.trim() === '') {
            let textinput = this.template.querySelector('[data-id="docissuedate"]');
            textinput.className += ' slds-has-error';
            error = true;
        }
        if (this.amountDisputed.trim() === '') {
            let textinput = this.template.querySelector('[data-id="amountdisputed"]');
            textinput.className += ' slds-has-error';
            error = true;
        }
        if (error === true){
            this.showErrorToast();
        }
        else {
            //create the Case record
            let cse = { 'sobjectType': 'Case' };
            cse.IATAcode__c = this.childComponent.extraFields.iataCode;
            cse.Reason1__c = this.requestType;
            cse.Airline_E_mail__c = this.email;
            cse.Airline__c = this.childComponent.title;
            cse.Description = this.reasonDeduction;
            cse.Document_number__c = this.docNumber;
            cse.Reporting_date__c = this.issueDate;
            cse.Amount_disputed__c = this.amountDisputed;
            cse.Subject = 'On-line Deduction Form';
            cse.Status = 'Open';
            cse.RecordTypeId = this.recTypeId;
            cse.Origin = 'Portal';
            cse.CaseArea__c = 'Dispute';
            cse.Visible_on_ISS_Portal__c = true;

            this.loading = true;
            insertCase({ caseToInsert: cse, recipientsToAdd: this.caseEmails })
                .then(result => {
                    this.caseNumber = result.CaseNumber;
                    this.caseID = result.Id;
                    this.loading = false;

                    //Open the modal upon case insert with the success message.
                    //Promise to let JS identify the place to scroll
                    //Pop up shows -> scrolls up to the Pop-up.
                    let showSuccessModal = new Promise((resolve, reject) => {
                        this.openModal();

                        let errorInsert = false;
                        if (!errorInsert)
                            resolve();
                        else
                            reject();
                    });

                    let scrollWindowUp = new Promise((resolve, reject) => {
                        let divToTop = this.template.querySelectorAll('.topOfModal')[0].offsetTop;
                        window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });

                        let errorScroll = false;
                        if (!errorScroll)
                            resolve();
                        else
                            reject();
                    });

                    let willScrollUp = function () {
                        Promise.all([
                            showSuccessModal,
                            scrollWindowUp]);
                    }

                    //Execute async actions
                    willScrollUp();
                })
                .catch(errormsg => {
                    this.loading = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.csp_errorCreatingCase,
                            message: JSON.parse(JSON.stringify(errormsg)),
                            variant: 'error',
                            mode: 'pester'
                        })
                    );
                });
        }
    }

    //opens Success modal
    openModal() {
        // to open modal window set 'bShowModal' track value as true
        this.bShowModal = true;
    }

    //Simple navigate to the reach us page.
    navigateToHome() {
        window.location.href = CSP_PortalPath;
    }

    //Simple navigate to the case details of the created case.
    navigateToCase() {
        window.location.href = CSP_PortalPath + "case-details?caseId=" + this.caseID;
    }

    //Error toaster
    showErrorToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: this.label.csp_errorCreatingCase,
                message: this.label.IDCard_FillAllFields,
                variant: 'error'
            })
        );
        let scrollobjective = this.template.querySelector('[data-id="caseDetails"]');
        scrollobjective.scrollIntoView({ behavior: 'smooth' });
    }
}
import { LightningElement, track } from 'lwc';
import idOfUser from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getParamsFromPage } from 'c/navigationUtils';
import getAllPickListValues from '@salesforce/apex/PortalFAQsCtrl.getFAQsInfo';
import searchAccounts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchAccounts';
import getContact from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.getContact';
import searchContacts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchContacts';
import createCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.createCase';
import getProfile from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.getProfile';
import insertCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.insertCase';
import isUserLevelOne from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.isUserLevelOne';
import createCaseTD from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.createCaseTreasuryDashboard';

// Import custom labels 
import csp_CreateNewCaseTopSubLabel from '@salesforce/label/c.csp_CreateNewCaseTopSubLabel';
import csp_CreateNewCaseTopLabel from '@salesforce/label/c.csp_CreateNewCaseTopLabel';
import csp_CreateNewCaseTopSubSubLabel from '@salesforce/label/c.csp_CreateNewCaseTopSubSubLabel';
import csp_CreateNewCaseMainTopLabel from '@salesforce/label/c.IDCard_CaseDetails';
import csp_CreateNewCaseMainPicklistLabel from '@salesforce/label/c.csp_CreateNewCaseMainPicklistLabel';
import csp_CreateNewCaseMainInputTopLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputTopLabel';
import csp_CreateNewCaseMainInputSubLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputSubLabel';
import csp_CreateNewCaseMainInputBoxTopLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputBoxTopLabel';
import csp_CreateNewCaseMainInputBoxSubLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputBoxSubLabel';
import csp_CreateNewCaseMainInputEmailsTopLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputEmailsTopLabel';
import csp_CreateNewCaseMainInputEmailsSubLabel from '@salesforce/label/c.csp_CreateNewCaseMainInputEmailsSubLabel';
import csp_searchIataCodeLocationNamePlaceHolder from '@salesforce/label/c.csp_searchIataCodeLocationNamePlaceHolder';
import csp_CaseTracking from '@salesforce/label/c.csp_CaseTracking';
import csp_ToastWarningRecipientNotFound from '@salesforce/label/c.csp_ToastWarningRecipientNotFound';
import csp_searchEmailRecipientPlaceholder from '@salesforce/label/c.csp_searchEmailRecipientPlaceholder';
import csp_CaseCreatedSuccess from '@salesforce/label/c.csp_CaseCreatedSuccess';
import csp_ViewCaseSummary from '@salesforce/label/c.csp_ViewCaseSummary';
import csp_GoToSupport from '@salesforce/label/c.csp_GoToSupport';
import csp_CaseBeingWorked from '@salesforce/label/c.csp_CaseBeingWorked';
import csp_CaseResponseGuarantee from '@salesforce/label/c.csp_CaseResponseGuarantee';
import csp_Category from '@salesforce/label/c.csp_SupportReachUs_Category';
import csp_Subtopic from '@salesforce/label/c.csp_Subtopic';
import csp_Topic from '@salesforce/label/c.ISSP_F2CTopic';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';
import CSP_Support from '@salesforce/label/c.CSP_Support';
import CSP_CaseNumber from '@salesforce/label/c.CSP_CaseNumber';
import csp_Concern_Label from '@salesforce/label/c.csp_Concern_Label';
import csp_errorCreatingCase from '@salesforce/label/c.csp_errorCreatingCase';
import csp_CreateNewCaseAddAttachment from '@salesforce/label/c.csp_CreateNewCaseAddAttachment';
import ISSP_ANG_GenericError from '@salesforce/label/c.ISSP_ANG_GenericError';
import IDCard_FillAllFields from '@salesforce/label/c.IDCard_FillAllFields';
import PKB2_js_error from '@salesforce/label/c.PKB2_js_error';
import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import csp_SearchNotPerformed from '@salesforce/label/c.csp_SearchNotPerformed';
// Import standard salesforce labels
import csp_caseNumber from '@salesforce/schema/Case.CaseNumber';
import csp_caseSubject from '@salesforce/schema/Case.Subject';
import csp_caseDescription from '@salesforce/schema/Case.Description';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSupportReachUsCreateNewCase extends LightningElement {
    //label construct
    label = {
        csp_CreateNewCaseTopLabel,
        csp_CreateNewCaseTopSubLabel,
        csp_CreateNewCaseTopSubSubLabel,
        csp_CreateNewCaseMainTopLabel,
        csp_CreateNewCaseMainPicklistLabel,
        csp_CreateNewCaseMainInputTopLabel,
        csp_CreateNewCaseMainInputSubLabel,
        csp_CreateNewCaseMainInputBoxTopLabel,
        csp_CreateNewCaseMainInputBoxSubLabel,
        csp_CreateNewCaseMainInputEmailsTopLabel,
        csp_CreateNewCaseMainInputEmailsSubLabel,
        csp_searchIataCodeLocationNamePlaceHolder,
        csp_searchEmailRecipientPlaceholder,
        csp_ToastWarningRecipientNotFound,
        csp_CaseCreatedSuccess,
        csp_CaseBeingWorked,
        csp_CaseResponseGuarantee,
        csp_GoToSupport,
        csp_Category,
        csp_CaseTracking,
        csp_ViewCaseSummary,
        csp_Topic,
        csp_CreateNewCaseAddAttachment,
        CSP_Support,
        CSP_Cases,
        CSP_CaseNumber,
        csp_Subtopic,
        csp_caseNumber,
        csp_caseSubject,
        csp_Concern_Label,
        csp_caseDescription,
        csp_errorCreatingCase,
        ISSP_ANG_GenericError,
        IDCard_FillAllFields,
        PKB2_js_error,
        CSP_NoSearchResults,
        csp_SearchNotPerformed
    }

    //spinner controller
    @track loading = true;

    //error gatherer
    @track errors = [];

    //current typed recipient on input
    @track newRecipient;

    //items from email recipient
    @track lstRecipients = [];

    //parameters for case creation
    @track description = "";
    @track subject = "";
    @track caseNumber;
    @track isEmergencyCase = false;

    //variable to control error class sent to child component
    @track requiredClass;

    //variable used to set the lookup input for the lookup component
    @track singleresult;

    //goes true to show modal once case is created
    @track bShowModal = false;

    //does the user have an Agent profile?
    @track agentProfile;

    //does the user have an Agent profile?
    @track relatedAccounts;

    @track relatedContacts;

    //is the user a Level1 user? If he has not completed level 2 registration he is not
    @track Level1User = false;

    //store parameters in globals for later use
    category;
    topic;
    subtopic;
    categoryLabel;
    topicLabel;
    @track subtopicLabel;
    countryISO;

    //for Treasury Dashboard
    recordTypeId;
    customTD = false;

    //childComponent data
    childComponent;

    //stores emails to be sent to case creation
    caseEmails = [];

    //stores initiated case
    caseInitiated;

    //the logged user's id
    userId = idOfUser;

    //Same as doInit() on aura
    connectedCallback() {
        this.isLevelOneUser();
        this.validateEntryParameters();
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

    //validates the entry parameters coming from the URL. 
    //If one is not in accordance you are redirected back to support reach us page.
    validateEntryParameters() {

        //re-use of getAllPickListValues for support reach us component
        getAllPickListValues()
            .then(result => {

                //JSON parse and stringify turns the result more readable 
                this.myResult = JSON.parse(JSON.stringify(result));
                this.metadatatree = JSON.parse(JSON.stringify(result));

                //getParamsFromPage grabs the data from the URL
                let pageParams = getParamsFromPage();
                if (pageParams !== null
                    && 'category' in pageParams
                    && pageParams.category !== ''
                    && 'topic' in pageParams
                    && pageParams.topic !== ''
                    && 'subtopic' in pageParams
                    && pageParams.subtopic !== '') {

                    //store all data in global variables
                    this.category = pageParams.category;
                    this.topic = pageParams.topic;
                    this.subtopic = pageParams.subtopic;
                    if (pageParams.countryISO === undefined || pageParams.countryISO === '') {
                        this.countryISO = ''
                    } else {
                        this.countryISO = pageParams.countryISO;
                    }

                    //Auxiliary Map
                    const map = new Map();
                    //Array to consume category options
                    let myCategoryOptions = [];
                    let myTopicOptions = [];
                    let mySubTopicOptions = [];

                    //builds lists of the categorizations
                    for (const item of this.myResult) {
                        if (!map.has(item.categoryLabel) && item.categoryLabel !== 'All') {
                            map.set(item.categoryLabel, true);
                            myCategoryOptions.push({
                                label: item.categoryLabel,
                                value: item.categoryName
                            });
                        }
                        if (!map.has(item.topicLabel) && item.categoryName === this.category) {
                            map.set(item.topicLabel, true);
                            myTopicOptions.push({
                                label: item.topicLabel,
                                value: item.topicName
                            });
                        }
                        if (!map.has(item.childs) && item.topicName === this.topic) {
                            Object.keys(item.childs).forEach(function (el) {
                                mySubTopicOptions.push({
                                    label: el, value: item.childs[el]
                                });
                            })
                        }
                    }

                    //validates that the entry parameters exist in the lists
                    if (myCategoryOptions.some(obj => obj.value === pageParams.category)
                        && myTopicOptions.some(obj => obj.value === pageParams.topic)
                        && mySubTopicOptions.some(obj => obj.value === pageParams.subtopic)) {

                        this.isEmergencyCase = pageParams.emergency === 'true';
                        this.isConcernCase = pageParams.concerncase === 'true';
                        this.categoryLabel = myCategoryOptions.find(obj => obj.value === pageParams.category).label;
                        this.topicLabel = myTopicOptions.find(obj => obj.value === pageParams.topic).label;
                        this.subtopicLabel = mySubTopicOptions.find(obj => obj.value === pageParams.subtopic).label;

                        //all ok parameters exist
                        //initialize the case
                        this.createCase();

                        //stop the spinner
                        this.loading = false;

                    } else {
                        //get redirected back to the support reach us page
                        this.navigateToSupport();
                    }
                //custom Treasury Dashboard
                } else if(pageParams !== null&& 'recordTypeId' in pageParams && pageParams.recordTypeId !== '') {
                            this.customTD = true;
                            this.recordTypeId = pageParams.recordTypeId;
                            this.createCaseTD();

                } else {
                    //get redirected back to the support reach us page
                    this.navigateToSupport();
                }

            })
            .catch(error => {
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


    //create the case and initialize it. No DML operation yet.
    createCase() {
        createCase({ countryiso: this.countryISO, isConcernCase: this.isConcernCase, topic: this.topic, subtopic: this.subtopic })
            .then(createCaseResult => {
                this.caseInitiated = JSON.parse(JSON.stringify(createCaseResult));
                console.log(this.caseInitiated);
            });
    }

    createCaseTD() {
        createCaseTD({recordTypeId: this.recordTypeId})
            .then(result => {
                this.caseInitiated = JSON.parse(JSON.stringify(result));
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

    //get the profile of the user
    getProfile() {
        getProfile()
            .then(result => {
                this.agentProfile = JSON.parse(JSON.stringify(result)).includes('ISS Portal Agency');
				if(this.agentProfile === true) 
					this.setPortalUserIATACode();
            });
    }

    setPortalUserIATACode() {
        getContact()
            .then(result => {
                let contactResults = JSON.parse(JSON.stringify(result));
                this.singleresult = this.relatedAccounts.filter(x => x.id === contactResults.AccountId);
            });
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

    //performs the search for the IATA code Accounts. Uses lookup child component.
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

    //class reset once you click on the input again.
    removeRequired() {
        this.requiredClass = '';
    }

    //grabs subject
    handleSubject(event) {
        this.subject = event.target.value;
    }

    //grabs description
    handleDescription(event) {
        this.description = event.target.value;
    }

    //grabs recipient
    handleRecipient(event) {
        this.newRecipient = event.target.value;
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

        if (this.agentProfile) {
            this.checkForErrors();
        }

        if (this.newRecipient !== undefined && this.newRecipient !== '') {
            this.showWarningToast();
        }
        else if (this.subject.trim() === '') {
            let textinput = this.template.querySelector('[data-id="subject"]');
            textinput.className += ' slds-has-error';
            this.showErrorToast();
        }
        else if (this.description.trim() === '') {
            let textarea = this.template.querySelector('lightning-textarea');
            textarea.className += ' slds-has-error';
            this.showErrorToast();
        }
        else {

            const record = { 'sobjectType': 'Case' };
            //only for custom Treasury Dashboard case
            if(this.customTD) {

                record.RecordTypeId = this.caseInitiated.RecordTypeId;
                record.Origin = this.caseInitiated.Origin;
                record.Status = this.caseInitiated.Status;
                record.Description = this.description
                record.Subject = this.subject

                this.customTD = false;

            //for all other cases
            }else{

                this.caseInitiated.Description = '';
                //Add to the Case Record (created beforehand) and add the required fields for the insert
                if (this.isConcernCase) {
                    this.caseInitiated.Description += '--' + this.label.csp_Concern_Label + '--\n\n'
                }

                this.caseInitiated.Description += this.label.csp_Category + ' - '
                    + this.categoryLabel + ' \n'
                    + this.label.csp_Topic + ' - '
                    + this.topicLabel + ' \n'
                    + this.label.csp_Subtopic + ' - '
                    + this.subtopicLabel + ' \n\n'
                    + this.label.csp_caseDescription.fieldApiName + ' - '
                    + this.description;
                this.caseInitiated.Subject = this.subject;

                if (this.agentProfile) {
                    record.IATAcode__c = this.childComponent.title;
                }

                if (this.isEmergencyCase) {
                    record.Priority = 'Emergency';
                }

                record.IsComplaint__c = this.isConcernCase;
                if (this.caseInitiated.RecordTypeId !== undefined && this.caseInitiated.RecordTypeId !== '') {
                    record.RecordTypeId = this.caseInitiated.RecordTypeId;
                }
                record.BSPCountry__c = this.caseInitiated.BSPCountry__c;
                record.Region__c = this.caseInitiated.Region__c;
                record.Country_concerned_by_the_query__c = this.caseInitiated.Country_concerned_by_the_query__c;
                record.Origin = this.caseInitiated.Origin;
                record.Status = this.caseInitiated.Status;
                record.IFAP_Country_ISO__c = this.caseInitiated.IFAP_Country_ISO__c.toUpperCase();
                record.Subject = this.caseInitiated.Subject;
                record.Description = this.caseInitiated.Description;

                let topicEn = '';
                let subtopicEn = '';

                let pageParams = getParamsFromPage();
                let metadatatreeAux = JSON.parse(JSON.stringify(this.metadatatree));
                for(let ii = 0; ii < metadatatreeAux.length; ii++){
                    if(metadatatreeAux[ii].categoryName === pageParams.category && metadatatreeAux[ii].topicName === pageParams.topic ){
                        topicEn = metadatatreeAux[ii].topicLabelEn;
                        subtopicEn = metadatatreeAux[ii].childsEn[pageParams.subtopic];
                    }
                }

                record.Topic__c = topicEn;
                record.Subtopic__c = subtopicEn;
            }

            this.loading = true;
            let process = event.target.attributes.getNamedItem('data-id').value;
            //Yes. You can pass the record itself. Yes. It's doable. Yes, i know. It's awsome! Like Thor's Hammer! :D
            insertCase({ caseToInsert: record, recipientsToAdd: this.caseEmails })
                .then(result => {
                    this.caseNumber = result.CaseNumber;
                    this.caseID = result.Id;
                    this.loading = false;

                    //Open the modal upon case insert with the success message if is the Create Case button pressed.
                    if (process === 'Show_Success') {
                        //Promise to let JS identify the place to scroll
                        //Pop up shows -> scrolls up to the Pop-up.
                        let showSuccessModal = new Promise((resolve, reject) => {
                            this.openModal();

                            let error = false;
                            if (!error)
                                resolve();
                            else
                                reject();
                        });

                        let scrollWindowUp = new Promise((resolve, reject) => {
                            let divToTop = this.template.querySelectorAll('.topOfModal')[0].offsetTop;
                            window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });

                            let error = false;
                            if (!error)
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
                    }
                    else if (process === 'Add_Attachment') {
                        window.location.href = CSP_PortalPath + "case-details?caseId=" + this.caseID + '&Att=true';
                    }
                })
                .catch(error => {
                    this.loading = false;

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: this.label.csp_errorCreatingCase,
                            message: JSON.parse(JSON.stringify(error)),
                            variant: 'error',
                            mode: 'pester'
                        })
                    );
                });
        }
    }

    //checks if the input is not fullfilled for the Agents.
    checkForErrors() {
        this.childComponent = this.template.querySelector('[data-id="iatalookup"]').getSelection();

        if (this.childComponent.length === 0) {
            this.requiredClass = ' slds-has-error';

            throw new Error(this.showErrorToast());
        } else {
            this.errors = [];
            this.requiredClass = '';
        }
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

    //Warning toaster
    showWarningToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Warning!',
                message: this.label.csp_ToastWarningRecipientNotFound,
                variant: 'warning'
            })
        );
    }

    //opens Success modal
    openModal() {
        // to open modal window set 'bShowModal' track value as true
        this.bShowModal = true;
    }

    //Simple navigate to the reach us page.
    navigateToSupport() {
        window.location.href = CSP_PortalPath + "support-reach-us";
    }

    //Simple navigate to the case details of the created case.
    navigateToCase() {
        window.location.href = CSP_PortalPath + "case-details?caseId=" + this.caseID;
    }

    //it really, really, really navigates to all cases. Promise!
    navigateToAllCases() {
        window.location.href = CSP_PortalPath + "cases-list";
    }

    goBackToSupportReachUs() {
        window.location.href = CSP_PortalPath + "support-reach-us?category="
            + this.category + "&topic=" + this.topic + "&subtopic=" + this.subtopic;
    }
}
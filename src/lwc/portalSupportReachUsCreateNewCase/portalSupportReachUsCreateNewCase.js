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

// Import standard salesforce labels
import csp_caseNumber from '@salesforce/schema/Case.CaseNumber';
import csp_caseSubject from '@salesforce/schema/Case.Subject';
import csp_caseDescription from '@salesforce/schema/Case.Description';

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
        PKB2_js_error
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

    //store parameters in globals for later use
    category;
    topic;
    subtopic;
    categoryLabel;
    topicLabel;
    @track subtopicLabel;
    countryISO;

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
        this.validateEntryParameters();
        this.getRelatedAccounts();
        this.getRelatedContacts();

    }

    //validates the entry parameters coming from the URL. 
    //If one is not in accordance you are redirected back to support reach us page.
    validateEntryParameters() {

        //re-use of getAllPickListValues for support reach us component
        getAllPickListValues()
            .then(result => {

                //JSON parse and stringify turns the result more readable 
                this.myResult = JSON.parse(JSON.stringify(result));

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
                    if (this.countryISO === undefined || this.countryISO === '') {
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
                        this.redirectSupport();
                    }
                } else {
                    //get redirected back to the support reach us page
                    this.redirectSupport();
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

    redirectSupport() {
        window.history.back();
    }

    //create the case and initialize it. No DML operation yet.
    createCase() {
        createCase({ countryiso: this.countryISO, isConcernCase: this.isConcernCase, topic: this.topic, subtopic: this.subtopic })
            .then(createCaseResult => {
                this.caseInitiated = JSON.parse(JSON.stringify(createCaseResult));
            });
    }

    //gets related accounts and sets them in global var
    getRelatedAccounts() {
        //activate spinner
        this.loading = true;
        searchAccounts({ searchTerm: null })
            .then(relatedAccountsResult => {
                this.relatedAccounts = JSON.parse(JSON.stringify(relatedAccountsResult));
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
                if (!JSON.parse(JSON.stringify(result)).includes('Admin')) {
                    this.setPortalUserIATACode();
                }
            });
    }

    setPortalUserIATACode() {
        getContact()
            .then(result => {
                this.singleresult = this.relatedAccounts.find(x => x.id === JSON.parse(JSON.stringify(result)).Account.Id);
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

        let inputCmp = this.template.querySelector('[data-id="emaillookup"]').getSelection()[0].title;
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

            const record = { 'sobjectType': 'Case' };

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
            record.Topic__c = this.topic;
            record.Subtopic__c = this.subtopic;
            record.IFAP_Country_ISO__c = this.caseInitiated.IFAP_Country_ISO__c.toUpperCase();
            record.Subject = this.caseInitiated.Subject;
            record.Description = this.caseInitiated.Description;

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
                        this.openModal();
                    }
                    else if (process === 'Add_Attachment') {
                        window.location.href = "/csportal/s/case-details?caseId=" + this.caseID + '&Att=true';
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
        window.location.href = "/csportal/s/support-reach-us";
    }

    //Simple navigate to the case details of the created case.
    navigateToCase() {
        window.location.href = "/csportal/s/case-details?caseId=" + this.caseID;
    }

    //it really, really, really navigates to all cases. Promise!
    navigateToAllCases() {
        window.location.href = "/csportal/s/cases-list";
    }
}
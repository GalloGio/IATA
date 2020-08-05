import { LightningElement, track,api,wire } from 'lwc';
import idOfUser from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage,navigateToPage } from 'c/navigationUtils';
import searchAccounts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchAccounts';
import searchContacts from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.searchContacts';
import createCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.createCase';
import insertCase from '@salesforce/apex/PortalSupportReachUsCreateNewCaseCtrl.insertCase';
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
import CSP_SubmitAsQuery from '@salesforce/label/c.CSP_SubmitAsQuery';
import CSP_SubmitAsEmergency from '@salesforce/label/c.CSP_SubmitAsEmergency';

import CSP_SupportReachUs_Compliment from '@salesforce/label/c.csp_ComplimentInfo';
import CSP_SupportReachUs_ComplimentInfo from '@salesforce/label/c.csp_Compliment';
import csp_SupportReachUs_Concern_Label from '@salesforce/label/c.csp_Concern_Label';
import csp_SupportReachUs_Compliment_Label from '@salesforce/label/c.csp_Compliment_Label';
import CSP_Submit from '@salesforce/label/c.CSP_Submit';
import CSP_DescSubtitleCC from '@salesforce/label/c.CSP_DescSubtitleCC';
import CSP_SubjectSubtitleCC from '@salesforce/label/c.CSP_SubjectSubtitleCC';

import CSP_SupportReachUs_GoToSupport from '@salesforce/label/c.csp_GoToSupport';
import CSP_SupportReachUs_GoToHomepage from '@salesforce/label/c.csp_GoToHomepage';
// Import standard salesforce labels
import csp_caseNumber from '@salesforce/schema/Case.CaseNumber';
import csp_caseSubject from '@salesforce/schema/Case.Subject';
import csp_caseDescription from '@salesforce/schema/Case.Description';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalSupportReachUsCreateNewCase extends NavigationMixin(LightningElement) {
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
        csp_caseNumber,
        csp_caseSubject,
        csp_Concern_Label,
        csp_caseDescription,
        csp_errorCreatingCase,
        ISSP_ANG_GenericError,
        IDCard_FillAllFields,
        PKB2_js_error,
        CSP_NoSearchResults,
        csp_SearchNotPerformed,
        CSP_SubmitAsQuery,
        CSP_SubmitAsEmergency,
        CSP_SupportReachUs_Compliment,
        CSP_SupportReachUs_ComplimentInfo,
        CSP_SupportReachUs_GoToSupport,
        CSP_SupportReachUs_GoToHomepage,
        csp_SupportReachUs_Concern_Label,
        csp_SupportReachUs_Compliment_Label,
        CSP_Submit,
        CSP_DescSubtitleCC,
        CSP_SubjectSubtitleCC
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
    @track _isEmergencyCase = false;
    @track hasEmergencyOption = false;

    //variable to control error class sent to child component
    @track requiredClass;

    //variable used to set the lookup input for the lookup component
    @track singleresult;

    //goes true to show modal once case is created
    @track bShowModal = false;

    //does the user have an Agent profile?
    @track agentProfile;

    //does the user have an Agent profile?
    @track relatedAccounts=[];

    @track relatedContacts=[];
	
    get relatedAccountsShow(){
        return (this.agentProfile && this.relatedAccounts.length) && !this.isCompliment; 
    }

    //is the user a Level1 user? If he has not completed level 2 registration he is not
    @track Level1User = false;

    //store parameters in globals for later use
    @api
    get topic(){
        return this._topic;
    }
    set topic(value){
        this._topic=value;
        if(this._topic !=null)
        this.createCaseCheck();
    }

    @api
    get countryISO(){
        return this._countryISO;
    }
    set countryISO(value){
        this._countryISO=value;
        if(this._countryISO !=null){
            this.createCaseCheck();
        }
    }

    @api
    get showEmergency(){
        return this._hasEmergencyOption;
    }
    set showEmergency(value){
        this._hasEmergencyOption=value;
    }

    @api
    get isEmergencyCase(){
        return this._isEmergencyCase;
    }
    set isEmergencyCase(value){
        this._isEmergencyCase=value;
    }

    @api
    get userInfo(){
        return this.userContact;
    }
    set userInfo(value){
        this.userContact=value;
        if(this.userContact !=null){

            this.agentProfile = this.userContact.Profile.Name.includes('ISS Portal Agency');
            
            if(this.agentProfile === true && this.relatedAccounts.length>0 ) 
            this.singleresult = this.relatedAccounts.filter(x => x.id === this.userContact.Contact.AccountId);
            
            
            if(this.relatedContacts.length>0){
                this.relatedContacts = this.relatedContacts.filter(obj => obj.id !== this.userContact.ContactId);
            }
        }
        
    }

    @api
    get isL1(){
        return this.Level1User;
    }
    set isL1(value){
        this.Level1User=value;
    }
    @track _topic;
    @track _countryISO;
    @track _hasEmergencyOption=false;
    @track showConfirmBox=false;

    @track isConcernCase=false;
    @track isCompliment=false;

    @track _isComplimentComplaint=false;

    @api 
    get specialCase(){
        return this._isComplimentComplaint
    }
    set specialCase(value){
        this.customTD=!value; //override if special case is identified
        this._isComplimentComplaint=value;
    };

    @api 
    get topicEn(){
        return this._topicEn;
    }
    set topicEn(value){
        this._topicEn=value;
    };

    subtopic;
    topicLabel;
    @track originBtn='';
    @track subtopicLabel;
    _topicEn='';

    @track feedbackType=null;
    get feedbackOptions(){
        return [
            {
                label:this.label.csp_SupportReachUs_Compliment_Label,
                value:'compliment'
            },
            {
                label:this.label.csp_SupportReachUs_Concern_Label,
                value:'complaint'
            }
        ]
    }
    //countryISO;
	

   
    customTD = false;

    //childComponent data
    childComponent;

    //stores emails to be sent to case creation
    caseEmails = [];

    //stores initiated case
    caseInitiated;

    //the logged user's id
    userId = idOfUser;




    //gets related contacts and sets them in global var
    @wire(searchContacts, { searchTerm: null })
    wiregetRelatedContacts(result){
        //activate spinner
        if(result.data){
            let contactList = JSON.parse(JSON.stringify(result.data));
            if(this.userContact){
                this.relatedContacts = contactList.filter(obj => obj.id !== this.userContact.ContactId);
            }else{
                this.relatedContacts = contactList;
            }
        }
          
    }

    @wire(searchAccounts, { searchTerm: null })
    wiregetRelatedAccounts(result){
        //activate spinner
        if(result.data){
            this.relatedAccounts = result.data;
            
            if (this.relatedAccounts.length === 1) {
                this.singleresult = this.relatedAccounts;
            } else if(this.agentProfile === true && this.userContact.Contact !== undefined){                   
                this.singleresult = this.relatedAccounts.filter(x => x.id === this.userContact.Contact.AccountId);
                
            }else if (this.relatedAccounts.length === 0) {
                this.singleresult = [{ title: this.label.CSP_NoSearchResults }];
            }           

            //activate spinner
            this.loading = false;
        }
          
    }

    //Same as doInit() on aura
    connectedCallback() {      
        let pageParams = getParamsFromPage();
        if(pageParams !== null&& 'recordTypeId' in pageParams && pageParams.recordTypeId !== '') {
            this.customTD = true;
            this.recordTypeId = pageParams.recordTypeId;
            this.createCaseTD(); 
        }

    }



    get sujectSubTitle(){
        return this._isComplimentComplaint===true? this.label.CSP_SubjectSubtitleCC: this.label.csp_CreateNewCaseMainInputSubLabel
    }

    get descriptSubTitle(){
        return this._isComplimentComplaint===true? this.label.CSP_DescSubtitleCC: this.label.csp_CreateNewCaseMainInputBoxSubLabel
    }

    createCaseCheck(){
        if(this.recordTypeId !=null){
            this.createCaseTD();
        }else if( this.countryISO !== undefined && this.countryISO != '' && this.topic!== undefined && this.topic!='' ){
            this.createCase();
        }


    }

    //create the case and initialize it. No DML operation yet.
    createCase() {
        createCase({ countryiso: this.countryISO, isConcernCase: this.isConcernCase, topic: this.topic})
            .then(createCaseResult => {
                this.caseInitiated = JSON.parse(JSON.stringify(createCaseResult));
                this.loading=false;
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.csp_SearchNotPerformed,
                        message: this.label.ISSP_ANG_GenericError,
                        variant: 'error'
                    })
                );
                this.loading=true;
            });
    }

    createCaseTD() {
        createCaseTD({recordTypeId: this.recordTypeId})
            .then(result => {
                this.caseInitiated = JSON.parse(JSON.stringify(result));
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
				results = results.filter(obj => obj.id !== this.userContact.ContactId);
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
                console.error('Lookup Error: ' + error);
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
        
        this.originBtn= event.target.attributes.getNamedItem('data-id').value;
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
        else if (this.specialCase ===true && this.feedbackType ===null) {
            let textinput = this.template.querySelector('[data-id="feedback-type"]');
            textinput.className += ' missing-value';
            this.showErrorToast();
        }
        else if (this.description.trim() === '') {
            let textarea = this.template.querySelector('lightning-textarea');
            textarea.className += ' slds-has-error';
            this.showErrorToast();
        }else if(this._isEmergencyCase){
            this.showConfirmBox=true;
        }
        else { // if no error found 
            this.loading = true; 
            if(this.specialCase){ // In case of feedback mode (complaint/ compliment)

                let topic= this.isConcernCase?this.topic:'';
                createCase({ countryiso: this.countryISO, isConcernCase: this.isConcernCase, topic: topic})
                    .then(createCaseResult => {
                        this.caseInitiated = JSON.parse(JSON.stringify(createCaseResult));
                        this.prepareCaseRecord();                
                    });
            } else {
                this.prepareCaseRecord();
            }
        }
    }

    closeConfirmBox(){
        this.showConfirmBox=false;
    }
    
    removeEmergency(){
        
        this._isEmergencyCase=false;
        this.prepareCaseRecord();

    }

    prepareCaseRecord(){
        this.closeConfirmBox();
        const record = { 'sobjectType': 'Case' };
        //only for custom Treasury Dashboard case
        if(this.customTD) {

            record.RecordTypeId = this.caseInitiated.RecordTypeId;
            record.Origin = this.caseInitiated.Origin;
            record.Status = this.caseInitiated.Status;
            record.Description = this.description
            record.Subject = this.subject

            this.customTD = false;

        
        }else if(this.isCompliment){ //for compliments 

            record.RecordTypeId = this.caseInitiated.RecordTypeId;
            record.Subject = this.subject;
            record.Compliment__c = true;
            record.Description = this.description + '\n-COMPLIMENT-';
            record.BSPCountry__c = this.caseInitiated.Country_concerned_by_the_query__c;

        }else{//for all other cases
            //double check to make sure the topic is never empty
            if(this._topicEn==undefined ||this._topicEn==''||this._topicEn==null  ){
                this.showErrorToast();
                return;
            }else{

                record.Topic__c = this._topicEn;
            }

            this.caseInitiated.Description = '';
            //Add to the Case Record (created beforehand) and add the required fields for the insert
            if (this.isConcernCase) {
                this.caseInitiated.Description += '--' + this.label.csp_Concern_Label + '--\n\n'
            }

            this.caseInitiated.Description += this.description;
            this.caseInitiated.Subject = this.subject;
            
            if (this.agentProfile && this.childComponent) {
                record.IATAcode__c = this.childComponent.getSelection()[0].title;
            }

            if (this._isEmergencyCase) {
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
        }

        this.submitCase(record);
    }

    //Submits the case record to the server
    submitCase(record){  
        
        this.loading = true;        
        //Yes. You can pass the record itself. Yes. It's doable. Yes, i know. It's awsome! Like Thor's Hammer! :D
        insertCase({ caseToInsert: record, recipientsToAdd: this.caseEmails })
            .then(result => {
                this.caseNumber = result.CaseNumber;
                this.caseID = result.Id;
                this.loading = false;

                //Open the modal upon case insert with the success message if is the Create Case button pressed.
                if (this.originBtn === 'Show_Success') {
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
                else if (this.originBtn === 'Add_Attachment') {
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

    //checks if the input is not fullfilled for the Agents.
    checkForErrors() {
        this.childComponent = this.template.querySelector('[data-id="iatalookup"]');

        if (this.childComponent && this.childComponent.getSelection().length === 0) {
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

    handleIsEmergency(event){
        this._isEmergencyCase=event.detail.value;
    }

    //opens Success modal
    openModal() {
        // to open modal window set 'bShowModal' track value as true
        this.bShowModal = true;
    }

    //Simple navigate to the reach us page.
    navigateToHomePage() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        })
            .then(url => navigateToPage(url, {}));
    }
    //Simple navigate to the reach us page.
    navigateToSupport() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-reach-us"
            }
        })
            .then(url => navigateToPage(url, {}));
    }

    //Simple navigate to the case details of the created case.
    navigateToCase() {
       
        let params={caseId:this.caseID};
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "support-reach-us"
            }
        })
            .then(url => navigateToPage(url, params));
    }

    //it really, really, really navigates to all cases. Promise!
    navigateToAllCases() {
       

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "cases-list"
            }
        })
            .then(url => navigateToPage(url, {}));
    }


    handleInputValueChange(event){


        this.feedbackType=event.target.value;

        if(this.feedbackType=='compliment'){
            this.isCompliment=true;
            this.isConcernCase=false;
        }else{
            this.isCompliment=false;
            this.isConcernCase=true;
        }
        let textinput = this.template.querySelector('[data-id="feedback-type"]');
        textinput.classList.remove('missing-value');
    }
}
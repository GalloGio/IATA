/**
 * Created by ukaya01 on 29/07/2019.
 */


/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track, wire}         from 'lwc';
import { navigateToPage, getParamsFromPage }    from 'c/navigationUtils';
import { loadScript, loadStyle }                from 'lightning/platformResourceLoader';
import RegistrationUtils                        from 'c/registrationUtils';
import { ShowToastEvent }                       from 'lightning/platformShowToastEvent';

import getConfig                                from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getConfig';
import getUserInformationFromEmail              from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail';
import register                                 from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.simulateRegister';
import getCustomerTypePicklists                 from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists';
import getMetadataCustomerType                  from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getMetadataCustomerType';
import getDomainAccounts                        from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getDomainAccounts';
import isGuest                                  from '@salesforce/user/isGuest';

/* ==============================================================================================================*/
/* External Resources
/* ==============================================================================================================*/
import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';
import PhoneFormatter                           from '@salesforce/resourceUrl/InternationalPhoneNumberFormat';
import PhoneFormatterS                          from '@salesforce/resourceUrl/InternationalPhoneNumberFormatS';
import jQuery                                   from '@salesforce/resourceUrl/jQuery172';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import Login                                    from '@salesforce/label/c.login';
import CSP_Create_New_Account_Info              from '@salesforce/label/c.CSP_Create_New_Account_Info'
import CSP_Change_Email                         from '@salesforce/label/c.CSP_Change_Email';
import CSP_Invalid_Email                        from '@salesforce/label/c.CSP_Invalid_Email';
import ISSP_Next                                from '@salesforce/label/c.ISSP_Next';
import OneId_Account_Creation                   from '@salesforce/label/c.OneId_Account_Creation';
import CSP_Registration_Existing_User_Message   from '@salesforce/label/c.CSP_Registration_Existing_User_Message';
import CSP_Privacy_Policy                       from '@salesforce/label/c.CSP_Privacy_Policy';
import OneId_CheckEmail                         from '@salesforce/label/c.OneId_CheckEmail';
import CSP_Registration_Disabled_Message        from '@salesforce/label/c.CSP_Registration_Disabled_Message';
import CSP_Submit                               from '@salesforce/label/c.CSP_Submit';
import CSP_Success                              from '@salesforce/label/c.CSP_Success';
import CSP_Forgot_Password_Retry_Title          from '@salesforce/label/c.CSP_Forgot_Password_Retry_Title';
import CSP_Registration_Retry_Message           from '@salesforce/label/c.CSP_Registration_Retry_Message';
import CSP_Try_Again                            from '@salesforce/label/c.CSP_Try_Again';
import CSP_PortalPath                           from '@salesforce/label/c.CSP_PortalPath';


export default class PortalRegistrationFirstLevel extends LightningElement {

    /* ==============================================================================================================*/
    /* Attributes
    /* ==============================================================================================================*/

    @track isSelfRegistrationEnabled = false;
    @track isRegistrationComplete = false;
    @track displayContactForm = false;
    @track displayTermsAndUsage = false;
    @track userCountry = "";
    @track userCountryCode = "";
    @track isSanctioned = false;
    @track isLoading = true;
    @track config = {};
    @track userInfo = {}
    @track registrationForm = { "email" : "",
                                "firstName" : "",
                                "lastName" : "",
                                "country" : "",
                                "phone" : "",
                                "sector" : "",
                                "category" : "",
                                "extraChoice" : "",
                                "language" : "",
                                "selectedCustomerType" : "",
                                "termsAndUsage" : false,
                                "domainAccountId" : ""
                              };
    @track errorMessage = "";
    @track displayError = false;
    @track displaySubmitError = false;
    @track isEmailFieldReadOnly = false;
    @track isFrozen = false;
    @track countryOptions = [];
    @track languageOptions = [];
    @track companyOptions = [];
    //@track phoneInitialized = false;
    @track isSelfRegistrationDisabled = false;
    @track sector = { label : "", options : [], display : false };
    @track category = { label : "", options : [], display : false };
    @track extraQuestion = { label : "", options : [], display : false };
    phoneInputInitialized = false;
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';
    successIcon = CSP_PortalPath + 'check2xGreen.png';
    @track jsLoaded = false;


    _labels = {
        Login,
        CSP_Create_New_Account_Info,
        CSP_Change_Email,
        CSP_Invalid_Email,
        ISSP_Next,
        OneId_Account_Creation,
        CSP_Registration_Existing_User_Message,
        CSP_Privacy_Policy,
        OneId_CheckEmail,
        CSP_Registration_Disabled_Message,
        CSP_Submit,
        CSP_Success,
        CSP_Forgot_Password_Retry_Title,
        CSP_Registration_Retry_Message,
        CSP_Try_Again,
        CSP_PortalPath
    }

    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    get displayToU(){
        if(this.displayContactForm || this.displayTermsAndUsage){
            return true;
        }else{
            return false;
        }
    }

    get displayCompanyCbx(){
        if(this.userInfo.hasExistingContact == false && this.companyOptions.length > 1){
            return true;
        }else{
            return false;
        }
    }

    @track selectedCustomerType = null;

    @track selectedMetadataCustomerType = {};

    @wire(getCustomerTypePicklists, {leaf:'$selectedCustomerType'})
    getPickLists({ error, data }){
        if (data) {
            var result = JSON.parse(JSON.stringify(data));
            console.log('picklist data: ', result);
            var that = this;

            this.sector = { label : "", options : [], display : false};
            this.category = { label : "", options : [], display : false};
            this.extraQuestion = { label : "", options : [], display : false};

            result.forEach(function (data) {

                var opts = [];
                var obj = {};

                data.picklistOptions.forEach(function (data) {
                        opts.push({ 'label': data.label, 'value': data.key });
                });

                obj.label = data.picklistLabel;
                obj.options = opts;
                obj.display = true;
                console.log('obj: ', obj);
                if(data.picklistName == "Sector"){
                    that.sector = obj;
                }else if(data.picklistName == "Category"){
                    that.category = obj;
                }else{
                    that.extraQuestion = obj;
                }

            });
            this.isLoading = false;
        } else if (error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
            this.isLoading = false;
        }
    };

    @wire(getMetadataCustomerType, {customerTypeKey:'$selectedCustomerType'})
    getCustomerType({ error, data }) {
        if (data) {
            var result = JSON.parse(JSON.stringify(data));
            console.log('metadata: ', result);
            this.selectedMetadataCustomerType = result;
            /*
            if(result.Type__c == 'Sector'){
                console.log(1);
                this.registrationForm.sector = result.MasterLabel;
                this.registrationForm.category = "";
            }else if(result.Type__c == 'Category'){
                console.log(2);
                this.registrationForm.category = result.MasterLabel;
            }else{
                console.log(3);
                this.registrationForm.sector = "";
                this.registrationForm.category = "";
            }
            */
        } else if (error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('error: ', error);
        }
    }

    /* ==============================================================================================================*/
    /* Lifecycle Hooks
    /* ==============================================================================================================*/

    connectedCallback() {

        const RegistrationUtilsJs = new RegistrationUtils();

        RegistrationUtilsJs.checkUserIsSystemAdmin().then(result=> {
            if(result == false && isGuest == false){
                navigateToPage(CSP_PortalPath,{});
                return;
            }
        });

        Promise.all([
            loadScript(this, jQuery),
            loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
            loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
        ]).then(function(){
            console.log('jsLoaded');
            this.jsLoaded = true;

            RegistrationUtilsJs.getUserLocation().then(result=> {
                this.isSanctioned = result.isRestricted;
                this.userCountryCode = result.countryCode;
                this.userCountry = result.countryId;
                this.registrationForm.country = result.countryId;
                if(this.isSanctioned == true){
                    //navigate to error page
                    navigateToPage(CSP_PortalPath + 'restricted-login');
                }else{

                    //getConfig
                    getConfig().then(result => {
                        var config = JSON.parse(JSON.stringify(result));
                        console.log('config: ', config);
                        this.config = config;
                        this._formatCountryOptions(config.countryInfo.countryList);
                        this.languageOptions = config.languageList;
                        this.isSelfRegistrationEnabled = config.isSelfRegistrationEnabled;
                        if(this.isSelfRegistrationEnabled == false){
                            this.isSelfRegistrationDisabled = true;
                            this.isLoading = false;
                            return;
                        }else{
                            //check localStorage
                            console.log('localStorage: ', localStorage);
                            if (localStorage.length > 0) {
                                this._restoreState();
                            }else{

                                let pageParams = getParamsFromPage();
                                if(pageParams !== undefined){
                                    if(pageParams.language !== undefined){
                                        this.registrationForm.language = pageParams.language.toLowerCase();;
                                    }

                                    if(pageParams.email !== undefined){
                                        this.registrationForm.email = decodeURIComponent(pageParams.email);
                                        //this.isEmailFieldReadOnly = true;
                                        //this.displayContactForm = true;
                                        //this._initializePhoneInput();
                                        this.handleNext(null);
                                        return;
                                    }

                                }

                                this.isLoading = false;
                            }
                        }


                    })
                    .catch(error => {
                        console.log('Error: ', JSON.parse(JSON.stringify(error)));
                        this.isLoading = false;
                    });
                }
            });

        }.bind(this));

    }

    renderedCallback() {
        /*
        if (this.phoneInputInitialized) {
            return;
        }
        this.phoneInputInitialized = true;
        */
    }

    /* ==============================================================================================================*/
    /* Event Handlers
    /* ==============================================================================================================*/

    handleFormKeyPress(event){
        if(event.keyCode === 13){
            var submitButton = this.template.querySelector('[data-id="submitButton"]');
            if(submitButton){
                if(submitButton.disabled == false){
                    this.handleSubmit();
                }
            }
        }
    }

    handleNavigateToLogin() {

        if(this.userInfo.hasExistingUser){
            if(this.userInfo.hasExistingUser == true && this.registrationForm.email.length > 0){
                let params = {};
                params.email = this.registrationForm.email;
                params.redirect = 1;
                navigateToPage(CSP_PortalPath + 'login',params);
            }else{
                navigateToPage(CSP_PortalPath + 'login');
            }
        }else{
            navigateToPage(CSP_PortalPath + 'login');
        }

    }

    handleChangeEmail(event){
        this.isEmailFieldReadOnly = false;
        this.displayContactForm = false;
        this.displayTermsAndUsage = false;
        this._clearForm(this.registrationForm.email);
        this._showSubmitError(false,"");
    }

    handleEmailChange(event) {
        this.registrationForm.email = event.target.value;
        var nextBtn = this.template.querySelector('[data-id="nextButton"]');
        this._showEmailValidationError(false, "");

        if (this.registrationForm.email !== '' && this.registrationForm.email !== null && this.registrationForm.email.length > 0) {
            nextBtn.classList.remove('containedButtonDisabled');
            nextBtn.classList.add('containedButtonLogin');
            nextBtn.disabled = false;
        } else {
            nextBtn.classList.remove('containedButtonLogin');
            nextBtn.classList.add('containedButtonDisabled');
            nextBtn.disabled = true;
        }

        if(event.keyCode === 13 && nextBtn.disabled == false){
            this.handleNext();
        }

    }


    handleNext(event){

        this.isLoading = true;
        const RegistrationUtilsJs = new RegistrationUtils();

        RegistrationUtilsJs.checkEmailIsValid(`${this.registrationForm.email}`).then(result=> {
            console.log('result: ', result);
            if(result == false){
                this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
                this.isLoading = false;
            }else{
                let anonymousEmail = 'iata' + this.registrationForm.email.substring(this.registrationForm.email.indexOf('@'));
                RegistrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result=> {
                    if(result == 'true'){
                       //todo:disposable email alert!
                        this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
                        this.isLoading = false;
                    }else{
                        //todo:check if the email address is associated to a contact and/or a user
                        //1) If there is an existing contact & user with that email -> The user is redirected to the login page,
                        //but the "E-Mail" field is pre-populated and, by default, not editable.
                        //The user can click a Change E-Mail link to empty the E-Mail field and set it editable again.
                        //2) If there is an existing contact but not a user with that email -> Terms and conditions and submit
                        //button is displayed on the form.
                        getUserInformationFromEmail({ email : this.registrationForm.email}).then(result => {
                            var userInfo = JSON.parse(JSON.stringify(result));
                            console.log('userInfo: ', userInfo);
                            this.userInfo = userInfo;
                            if(userInfo.hasExistingContact == true){
                                if(userInfo.hasExistingUser == true){
                                    //todo:navigate to Login Page with email parameter
                                    /*
                                    let params = {};
                                    params.email = this.registrationForm.email;
                                    params.redirect = 1;
                                    navigateToPage(CSP_PortalPath + 'login',params);
                                    */
                                    //todo: display message of existing user
                                    this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
                                    this.isLoading = false;
                                }else{
                                    //todo:show Terms and Usage field to proceed submit
                                    this.displayTermsAndUsage = true;
                                    this.isEmailFieldReadOnly = true;
                                    this.isLoading = false;
                                }
                            }else{
                                if(userInfo.isEmailAddressAvailable == true){
                                    //todo: show form

                                    if(this.userCountry != ""){
                                        this.registrationForm.country = this.userCountry;
                                    }

                                    this.displayContactForm = true;
                                    this.isEmailFieldReadOnly = true;
                                    this.isLoading = false;
                                    this._initializePhoneInput();
                                    getDomainAccounts({ email : this.registrationForm.email}).then(result => {
                                        var domainAccounts = JSON.parse(JSON.stringify(result));
                                        console.log('domainAccounts: ', domainAccounts);
                                        this.companyOptions = domainAccounts;
                                    });
                                }else{
                                    //todo: inform user to pick another email
                                    this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
                                    this.isLoading = false;
                                }
                            }
                        })
                        .catch(error => {
                            console.log('Error: ', error);
                            this.isLoading = false;
                        });
                    }
                });
            }
        });
    }

    handleSubmit(event){

        console.log('Form: ', JSON.parse(JSON.stringify(this.registrationForm)));
        console.log('Customer Type : ', JSON.parse(JSON.stringify(this.selectedMetadataCustomerType)));

        this.isLoading = true;
        //todo: validate & add country code to the phone number

        var contactId = this.userInfo.contactId;
        var accountId = this.userInfo.accountId;
        //if there is an account selection based on the email domain, use it for registration.
        if(this.registrationForm.domainAccountId.length > 0){
            accountId = this.registrationForm.domainAccountId;
        }else{
            if(this.userInfo.hasExistingContact == false && this.companyOptions.length == 1){
                accountId = this.companyOptions[0].value;
            }
        }

        register({ registrationForm : JSON.stringify(this.registrationForm),
                   customerType : JSON.stringify(this.selectedMetadataCustomerType),
                   contactId : contactId,
                   accountId : accountId
                 }).then(result => {
            var dataAux = JSON.parse(JSON.stringify(result));
            console.log('dataAux: ', dataAux);
            if(dataAux.isSuccess == true){
                //todo: show success message
                this.isRegistrationComplete = true;
                this.isLoading = false;
            }else{
                this.isLoading = false;
                this._showSubmitError(true, 'Error Creating User');
            }

        })
        .catch(error => {
            var dataAux = JSON.parse(JSON.stringify(error));
            console.log(dataAux);
            this._showSubmitError(true, 'Error Creating User');
            this.isLoading = false;
        });

    }

    handleCountryChange(event){
        this.registrationForm.country = event.detail.value;
        this._checkForMissingFields();
    }

    handleCompanyChange(event){
        this.registrationForm.domainAccountId = event.detail.value;
        this._checkForMissingFields();
    }

    handleInputValueChange(event){
        //todo: dynamic input change checker
        var inputName = event.target.name;
        var inputValue = event.target.value;
        this.registrationForm[inputName] = inputValue;
        //todo: if input is required => clear submit error message
        this.template.querySelector('[data-id="' + inputName + 'Div"]').classList.remove('slds-has-error');
        if(this.displaySubmitError){
            if(event.target.required){
                this._showSubmitError(false,"");
            }
        }

        this._checkForMissingFields();

    }

    handleTouChange(event){
        var inputValue = event.target.checked;
        this.registrationForm.termsAndUsage = inputValue;
        this._checkForMissingFields();

    }


    handleSectorChange(event){

        this.isLoading = true;

        if(this.selectedCustomerType == event.target.value){
            this._checkForMissingFields();
            this.isLoading = false;
            return;
        }

        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType != null){
            //clear error messages
            if(this.displaySubmitError){
                if(event.target.required){
                    this._showSubmitError(false,"");
                }
            }
            this.registrationForm.sector = this.selectedCustomerType;
        }else{
            this.registrationForm.sector = "";
        }

        this.registrationForm.selectedCustomerType = this.selectedCustomerType;
        this.registrationForm.category = "";
        this.registrationForm.extraChoice = "";

        this._checkForMissingFields();
    }

    handleCategoryChange(event){

        if(event.target.value == null){
            this.registrationForm.category = "";
            this._checkForMissingFields();
            return;
        }

        if(this.selectedCustomerType == event.target.value){
            this.registrationForm.category = this.selectedCustomerType;
            this._checkForMissingFields();
            return;
        }

        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType != null){
            //clear error messages
            if(this.displaySubmitError){
                if(event.target.required){
                    this._showSubmitError(false,"");
                }
            }
        }

        this.registrationForm.selectedCustomerType = this.selectedCustomerType;
        this.registrationForm.category = this.selectedCustomerType;

        this._checkForMissingFields();
    }

    handleExtraChoiceChange(event){
        this.isLoading = true;

        if(event.target.value == null){
            this.selectedCustomerType = this.registrationForm.sector;
            this.registrationForm.selectedCustomerType = this.registrationForm.sector;
            this.registrationForm.extraChoice = "";
            this.registrationForm.category = "";
            //this.category = {};
            this.isLoading = false;
            this._checkForMissingFields();
            return;
        }

        if(this.selectedCustomerType == event.target.value){
            this._checkForMissingFields();
            this.isLoading = false;
            return;
        }

        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType != null){
            //clear error messages
            if(this.displaySubmitError){
                if(event.target.required){
                    this._showSubmitError(false,"");
                }
            }
        }

        this.registrationForm.selectedCustomerType = this.selectedCustomerType;
        this.registrationForm.extraChoice = this.selectedCustomerType;
        this.registrationForm.category = "";

        this._checkForMissingFields();
    }

    handleCustomerTypeChange(event) {
        console.log('source: ', event.source);
        console.log('target: ', event.target);
        console.log('detail: ', event.detail);

        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType == '- Select -'){
            this.selectedCustomerType = null;
        }else{
            if(this.displaySubmitError){
                if(event.target.required){
                    this._showSubmitError(false,"");
                }
            }
        }

        this.registrationForm.selectedCustomerType = this.selectedCustomerType;

    }

    handlePreferredLanguageChange(event){
        this.registrationForm.language = event.target.value;
    }

    handleLanguageChange(event){
        console.log('handleLanguageChange');
        this.isLoading = true;
        this.registrationForm.language = event.detail;
        var search = location.search;
        var param = new RegExp('language=[^&$]*', 'i');
        if(~search.indexOf('language')){
            search = search.replace(param, 'language=' + this.registrationForm.language );
        }else{
            if(search.length > 0) search += '&';
            search += 'language='+this.registrationForm.language;
        }
        //todo save current state on local session & refresh page
        if(this.registrationForm.email.length > 0){
            let registrationState = {
                registrationForm : this.registrationForm,
                isEmailFieldReadOnly : this.isEmailFieldReadOnly,
                displayContactForm : this.displayContactForm,
                displayTermsAndUsage : this.displayTermsAndUsage,
                sector : this.sector,
                category : this.category,
                extraQuestion : this.extraQuestion,
                selectedCustomerType : this.selectedCustomerType,
                selectedMetadataCustomerType : this.selectedMetadataCustomerType,
                userCountry : this.userCountry,
                userCountryCode : this.userCountryCode,
                isRegistrationComplete : this.isRegistrationComplete,
                companyOptions : this.companyOptions,
                userInfo : this.userInfo
            };

            localStorage.setItem("registrationState", JSON.stringify(registrationState));
        }
        location.search = search;
    }


    /* ==============================================================================================================*/
    /* Helper Methods
    /* ==============================================================================================================*/

    _showEmailValidationError(state, message){
        var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
        this.errorMessage = message;
        this.displayError = state;

        if(state == true){
            emailDiv.classList.add('slds-has-error');
        }else{
            emailDiv.classList.remove('slds-has-error');
        }
    }

    _showSubmitError(state, message){
        var submitDiv = this.template.querySelector('[data-id="submitDiv"]');
        this.errorMessage = message;
        this.displaySubmitError = state;

        if(state == true){
            submitDiv.classList.add('slds-has-error');
        }else{
            submitDiv.classList.remove('slds-has-error');
        }
    }

    _formatCountryOptions(options){
        let dataList = JSON.parse(JSON.stringify(options));
        let optionList = [];
        //optionList.push({ 'label': '', 'value': '' });
        dataList.forEach(function (data) {
            optionList.push({ 'label': data.Name, 'value': data.Id });
        });
        this.countryOptions = optionList;
    }

    _clearForm(email){

        if(email == null ){
            email = "";
        }

        this.registrationForm = { "email" : email,
                                  "firstName" : "",
                                  "lastName" : "",
                                  "country" : "",
                                  "phone" : "",
                                  "sector" : "",
                                  "category" : "",
                                  "extraChoice" : "",
                                  "language" : this.registrationForm.language,
                                  "selectedCustomerType" : "",
                                  "termsAndUsage" : false,
                                  "domainAccountId" : ""
                                };

        this.selectedCustomerType = null;
        this.selectedMetadataCustomerType = null;

    }

    _restoreState(){
        let registrationState = JSON.parse(localStorage.getItem("registrationState"));
        localStorage.removeItem("registrationState");
        console.log('registrationState: ', registrationState);
        this.registrationForm = registrationState.registrationForm;
        this.isEmailFieldReadOnly = registrationState.isEmailFieldReadOnly;
        this.displayContactForm = registrationState.displayContactForm;
        this.displayTermsAndUsage = registrationState.displayTermsAndUsage;
        this.selectedCustomerType = registrationState.selectedCustomerType;
        this.sector = registrationState.sector;
        this.category = registrationState.category;
        this.extraQuestion = registrationState.extraQuestion;
        this.selectedMetadataCustomerType = registrationState.selectedMetadataCustomerType;
        this.userCountry = registrationState.userCountry;
        this.userCountryCode = registrationState.userCountryCode;
        this.isRegistrationComplete = registrationState.isRegistrationComplete;
        this.userInfo = registrationState.userInfo;
        this.companyOptions = registrationState.companyOptions;
        this.isLoading = false;

        if(this.displayContactForm){
            this._checkForMissingFields();
            this._initializePhoneInput();
        }

    }

    async _checkForMissingFields(){

        let isValid = true;
        let form = this.registrationForm;
        if(this.userInfo.hasExistingContact == true){
            if(form.email.length < 1 || form.termsAndUsage != true){
                isValid = false;
            }
        }else{
            if(form.email.length < 1 || form.firstName.length < 1 || form.lastName.length < 1 || form.language.length < 1
                || form.termsAndUsage != true || form.sector.length < 1){
                    isValid = false;
            }

            if(this.displayCompanyCbx == true && form.domainAccountId.length < 1){
                isValid = false;
            }

            if(form.sector == 'General_Public_Sector' && form.extraChoice.length < 1){
                isValid = false;
            }else if(form.sector != 'General_Public_Sector' && form.category.length < 1){
                isValid = false;
            }
        }

        await (this.template.querySelector('[data-id="submitButton"]'));
        var submitButton = this.template.querySelector('[data-id="submitButton"]');
        if(isValid == true){
            if(submitButton.disabled == true){
                submitButton.classList.remove('containedButtonDisabled');
                submitButton.classList.add('containedButtonLogin');
                submitButton.disabled = false;
            }
        }else{
            submitButton.classList.remove('containedButtonLogin');
            submitButton.classList.add('containedButtonDisabled');
            submitButton.disabled = true;
        }

    }
    /*
    async _renderSubmitButton(state){
        await (this.template.querySelector('[data-id="submitButton"]'));
        var submitButton = this.template.querySelector('[data-id="submitButton"]');
        if(state == true){
            submitButton.classList.remove('containedButtonDisabled');
            submitButton.classList.add('containedButtonLogin');
            submitButton.disabled = false;
        }else{
            submitButton.classList.remove('containedButtonLogin');
            submitButton.classList.add('containedButtonDisabled');
            submitButton.disabled = true;
        }
        if(this.displayContactForm){
            this._initializePhoneInput();
        }
    }
    */

    async _initializePhoneInput(){

        await(this.jsLoaded == true);
        await(this.template.querySelector('[data-id="phone"]'));

        var input = this.template.querySelector('[data-id="phone"]');
        var countryCode = this.userCountryCode;
        console.log('countryCode: ', countryCode);

        window.intlTelInput(input,{
            initialCountry: countryCode,
            preferredCountries: [countryCode],
            placeholderNumberType : "FIXED_LINE",
            //utilsScript: this.utilsPath,
            /*autoPlaceholder : "aggressive"*/
        });

    }

}
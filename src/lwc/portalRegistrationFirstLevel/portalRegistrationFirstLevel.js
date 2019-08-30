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
import isGuest                                  from '@salesforce/user/isGuest';

/* ==============================================================================================================*/
/* External Resources
/* ==============================================================================================================*/
import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';
import PhoneFormatter                           from '@salesforce/resourceUrl/InternationalPhoneNumberFormat';
import PhoneFormatterS                          from '@salesforce/resourceUrl/InternationalPhoneNumberFormatS';
import jQuery                                   from '@salesforce/resourceUrl/jQuery172';
import jquery321minStandard                     from '@salesforce/resourceUrl/jquery321minStandard';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import InvalidMailFormatLabel                   from '@salesforce/label/c.ISSP_AMS_Invalid_Email';
import LoginLabel                               from '@salesforce/label/c.Login';
import EmailLabel                               from '@salesforce/label/c.Email';
import CreateNewAccountLabel                    from '@salesforce/label/c.OneId_Account_Creation';
import NextLabel                                from '@salesforce/label/c.ISSP_Next';
import SubmitLabel                              from '@salesforce/label/c.CSP_Submit';
import AcceptTermsLabel                         from '@salesforce/label/c.ISSP_Registration_acceptGeneralConditions';
import AcceptTermsErrorLabel                    from '@salesforce/label/c.CSP_Accept_Terms_Error';
//import TouLabel                                 from '@salesforce/label/c.CSP_Privacy_Policy';
import RegistrationCompleteLabel                from '@salesforce/label/c.OneId_RegistrationComplete';
import CheckEmailLabel                          from '@salesforce/label/c.OneId_CheckEmail';
import CSP_PortalPath                           from '@salesforce/label/c.CSP_PortalPath';
import TroubleshootingLabel                     from '@salesforce/label/c.OneId_CSP_Troubleshooting';

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
                                "termsAndUsage" : false
                              };
    @track errorMessage = "";
    @track displayError = false;
    @track displaySubmitError = false;
    @track isEmailFieldReadOnly = false;
    @track isFrozen = false;
    @track countryOptions = [];
    @track languageOptions = [];
    //@track phoneInitialized = false;
    @track isSelfRegistrationDisabled = false;
    @track sector = { label : "", options : [], display : false };
    @track category = { label : "", options : [], display : false };
    @track extraQuestion = { label : "", options : [], display : false };
    phoneInputInitialized = false;
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';
    @track jsLoaded = false;

    _labels = {
        LoginLabel,
        EmailLabel,
        CreateNewAccountLabel,
        NextLabel,
        SubmitLabel,
        AcceptTermsLabel,
        AcceptTermsErrorLabel,
        //TouLabel,
        RegistrationCompleteLabel,
        CheckEmailLabel,
        DisabledRegistrationLabel : 'Portal Registration is currently disabled. Thank you for your understanding.',
        TroubleshootingLabel,
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
                this.userCountry = result.country;
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
                        this._renderCountryOptions(config.countryInfo.countryList);
                        this._renderLanguageOptions(config.languageList);
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
                                        this._renderEmailInput();
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
        this.template.querySelector('[data-id="emailInput"]').classList.remove('inputBackgroundGrey');

        if (this.registrationForm.email !== '' && this.registrationForm.email !== null && this.registrationForm.email.length > 0) {
            nextBtn.classList.remove('containedButtonDisabled');
            nextBtn.classList.add('containedButtonLogin');
            nextBtn.disabled = false;
        } else {
            nextBtn.classList.remove('containedButtonLogin');
            nextBtn.classList.add('containedButtonDisabled');
            nextBtn.disabled = true;
        }
    }

    handleEmailFocusOut(event){
        if(this.registrationForm.email.length > 0){
            this.template.querySelector('[data-id="emailInput"]').classList.add('inputBackgroundGrey');
        }else{
            this.template.querySelector('[data-id="emailInput"]').classList.remove('inputBackgroundGrey');
        }
    }

    handleNext(event){

        this.isLoading = true;
        const RegistrationUtilsJs = new RegistrationUtils();

        RegistrationUtilsJs.checkEmailIsValid(`${this.registrationForm.email}`).then(result=> {
            console.log('result: ', result);
            if(result == false){
                this._showEmailValidationError(true, InvalidMailFormatLabel);
                this.isLoading = false;
            }else{
                let anonymousEmail = 'iata' + this.registrationForm.email.substring(this.registrationForm.email.indexOf('@'));
                RegistrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result=> {
                    if(result == 'true'){
                       //todo:disposable email alert!
                        this._showEmailValidationError(true, InvalidMailFormatLabel);
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
                                    this._showEmailValidationError(true, 'You are trying to register with an existing user,'
                                        + ' please change the email or click login button to go to the login page');
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
                                    this.displayContactForm = true;
                                    this.isEmailFieldReadOnly = true;
                                    this.isLoading = false;
                                    this._initializePhoneInput();
                                }else{
                                    //todo: inform user to pick another email??s
                                    this._showEmailValidationError(true, InvalidMailFormatLabel);
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

        const inputValidation = [...this.template.querySelectorAll('input')]
            .reduce((validSoFar, inputCmp) => {
                if(inputCmp.checkValidity() == false){
                    var inputDiv = this.template.querySelector('[data-id="' + inputCmp.name + 'Div"]');
                    inputDiv.classList.add('slds-has-error');
                }
                return validSoFar && inputCmp.checkValidity();
            }, true);


        const selectValidation = [...this.template.querySelectorAll('lightning-combobox')]
             .reduce((validSoFar, comboboxCmp) => {
                 if(comboboxCmp.checkValidity() == false){
                    console.log('invalid');
                 }
                 comboboxCmp.reportValidity();
                 return validSoFar && comboboxCmp.checkValidity();
             }, true);



        let form = this.registrationForm;
        if(this.userInfo.hasExistingContact){
            if(form.email.length < 1 || form.termsAndUsage != true){
                this._showSubmitError(true, 'Please fill all the required fields!');
                this.isLoading = false;
                return;
            }
        }else{
            if(form.email.length < 1 || form.firstName.length < 1 || form.lastName.length < 1 || form.language.length < 1
                || form.termsAndUsage != true || form.sector.length < 1 || form.category.length < 1){
                    //todo: this check fails for General Public -> Student
                    this._showSubmitError(true, 'Please fill all the required fields!');
                    this.isLoading = false;
                    return;
            }
        }

        //todo: validate & add country code to the phone number

        //todo: for sector =  other and general public -> must implement logic to retrieve sector & category from the final customerTypeMetadata selection
        register({ registrationForm : JSON.stringify(this.registrationForm),
                   customerType : JSON.stringify(this.selectedMetadataCustomerType),
                   contactId : this.userInfo.contactId,
                   accountId : this.userInfo.accountId
                 }).then(result => {
            var dataAux = JSON.parse(JSON.stringify(result));
            console.log('dataAux: ', dataAux);
            if(dataAux.isSuccess == true){
                //todo: show success message
                this.isRegistrationComplete = true;
            }else{
                this._showSubmitError(true, 'Error Creating User');
            }
            this.isLoading = false;
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
    }

    handleInputValueChange(event){
        //todo: dynamic input change checker
        var inputName = event.target.name;
        var inputValue = event.target.value;
        this.registrationForm[inputName] = inputValue;
        this.template.querySelector('[data-id="' + inputName + '"]').classList.remove('inputBackgroundGrey');
        //todo: if input is required => clear submit error message
        this.template.querySelector('[data-id="' + inputName + 'Div"]').classList.remove('slds-has-error');
        if(this.displaySubmitError){
            if(event.target.required){
                this._showSubmitError(false,"");
            }
        }

    }

    handleInputFocusOut(event){
        //todo:dynamic input focus out checker
        var inputName = event.target.name;
        if(this.registrationForm[inputName].length > 0){
            this.template.querySelector('[data-id="' + inputName + '"]').classList.add('inputBackgroundGrey');
        }else{
            this.template.querySelector('[data-id="' + inputName + '"]').classList.remove('inputBackgroundGrey');
        }
    }

    handleTouChange(event){
        var inputValue = event.target.checked;
        this.registrationForm.termsAndUsage = inputValue;
        this._renderSubmitButton(inputValue);
    }


    handleSectorChange(event){
        this.isLoading = true;
        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType == '- Select -'){
            this.selectedCustomerType = null;
        }else{
            //clear error messages
            if(this.displaySubmitError){
                if(event.target.required){
                    this._showSubmitError(false,"");
                }
            }
        }

        this.registrationForm.selectedCustomerType = this.selectedCustomerType;
        this.registrationForm.sector = this.selectedCustomerType;
        this.registrationForm.category = "";
    }

    handleCategoryChange(event){
        if(event.target.value == null){
            return;
        }
        this.isLoading = true;
        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType == '- Select -'){
            this.selectedCustomerType = null;
        }else{
            //clear error messages
            if(this.displaySubmitError){
                if(event.target.required){
                    this._showSubmitError(false,"");
                }
            }
        }

        this.registrationForm.selectedCustomerType = this.selectedCustomerType;
        this.registrationForm.category = this.selectedCustomerType;
    }

    handleExtraChoiceChange(event){
        if(event.target.value == null){
            return;
        }
        this.isLoading = true;
        this.selectedCustomerType = event.target.value;
        if(this.selectedCustomerType == '- Select -'){
            this.selectedCustomerType = null;
        }else{
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
                selectedMetadataCustomerType : this.selectedMetadataCustomerType
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

    _renderCountryOptions(options){
        let dataList = JSON.parse(JSON.stringify(options));
        let optionList = [];
        optionList.push({ 'label': '', 'value': '' });
        dataList.forEach(function (data) {
            optionList.push({ 'label': data.Name, 'value': data.Id });
        });
        this.countryOptions = optionList;
    }

    _renderLanguageOptions(options){
        var lowerCaseLangOpts = options.map(function(a) {
            a.value = a.value.toLowerCase();
            return a;
        });
        this.languageOptions = lowerCaseLangOpts;
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
                                  "termsAndUsage" : false
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

        this.isLoading = false;

        if(this.registrationForm.email.length > 0){
            this._renderEmailInput();
        }

        if(this.displayContactForm){
            this._renderSubmitButton(this.registrationForm.termsAndUsage);
        }

    }

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

    async _renderEmailInput(){
        await (this.template.querySelector('[data-id="emailInput"]'));
        this.handleEmailFocusOut(null);
    }

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
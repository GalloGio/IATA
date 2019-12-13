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
//import getUserInformationFromAdditionalEmail    from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromAdditionalEmail';
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

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import Login                                    from '@salesforce/label/c.Login';
import CSP_Email                                from '@salesforce/label/c.CSP_Email';
import CSP_Registration_Description             from '@salesforce/label/c.CSP_Registration_Description'
import CSP_Change_Email                         from '@salesforce/label/c.CSP_Change_Email';
import CSP_Invalid_Email                        from '@salesforce/label/c.CSP_Invalid_Email';
import CSP_Next                                 from '@salesforce/label/c.CSP_Next';
import OneId_Account_Creation                   from '@salesforce/label/c.OneId_Account_Creation';
import CSP_Registration_Existing_User_Message   from '@salesforce/label/c.CSP_Registration_Existing_User_Message';
import CSP_Privacy_Policy                       from '@salesforce/label/c.CSP_Privacy_Policy';
import CSP_Check_Email                          from '@salesforce/label/c.CSP_Check_Email';
import CSP_Registration_Disabled_Message        from '@salesforce/label/c.CSP_Registration_Disabled_Message';
import CSP_Submit                               from '@salesforce/label/c.CSP_Submit';
import CSP_Success                              from '@salesforce/label/c.CSP_Success';
import CSP_Forgot_Password_Retry_Title          from '@salesforce/label/c.CSP_Forgot_Password_Retry_Title';
import CSP_Registration_Retry_Message           from '@salesforce/label/c.CSP_Registration_Retry_Message';
import CSP_Try_Again                            from '@salesforce/label/c.CSP_Try_Again';
import CSP_Troubleshooting_Info                 from '@salesforce/label/c.CSP_Troubleshooting_Info';
import CSP_Troubleshooting                      from '@salesforce/label/c.CSP_Troubleshooting';
import CSP_Unexcepted_Error                     from '@salesforce/label/c.CSP_Unexcepted_Error';
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
    @track selectedCountryFlag = "";
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
                                "lmsRedirectFrom" : "",
                                "lmsCourse" : ""
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
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_mark_white.svg';
    successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';
    cancelIcon = CSP_PortalPath + 'CSPortal/Images/Icons/cancel_white.svg';
    @track jsLoaded = false;
    phoneRegExp = /^\(?[+]\)?([()\d]*)$/
    @track rerender = false;


    _labels = {
        Login,
        CSP_Email,
        CSP_Registration_Description,
        CSP_Change_Email,
        CSP_Invalid_Email,
        CSP_Next,
        OneId_Account_Creation,
        CSP_Registration_Existing_User_Message,
        CSP_Privacy_Policy,
        CSP_Check_Email,
        CSP_Registration_Disabled_Message,
        CSP_Submit,
        CSP_Success,
        CSP_Forgot_Password_Retry_Title,
        CSP_Registration_Retry_Message,
        CSP_Try_Again,
        CSP_Troubleshooting_Info,
        CSP_Troubleshooting,
        CSP_Unexcepted_Error,
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

    @track selectedCustomerType = null;

    @track selectedMetadataCustomerType = {};

    @wire(getCustomerTypePicklists, {leaf:'$selectedCustomerType'})
    getPickLists({ error, data }){
        if (data) {
            var result = JSON.parse(JSON.stringify(data));

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
            console.info('error: ', result);
            this.isLoading = false;
        }
    };

    @wire(getMetadataCustomerType, {customerTypeKey:'$selectedCustomerType'})
    getCustomerType({ error, data }) {
        if (data) {
            var result = JSON.parse(JSON.stringify(data));
            this.selectedMetadataCustomerType = result;

        } else if (error) {
            var result = JSON.parse(JSON.stringify(error));
            console.info('error: ', error);
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
            loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
            loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
        ]).then(function(){
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

                        this.config = config;
                        this._formatCountryOptions(config.countryInfo.countryList);
                        this.languageOptions = config.languageList;
                        this.isSelfRegistrationEnabled = config.isSelfRegistrationEnabled;
                        if(this.isSelfRegistrationEnabled == false){
                            this.isSelfRegistrationDisabled = true;
                            this.isLoading = false;
                            //return;
                        }else{
                            //check localStorage
                            if (localStorage.length > 0) {
                                this._restoreState();
                            }else{

                                let pageParams = getParamsFromPage();
                                if(pageParams !== undefined){
                                    if(pageParams.language !== undefined){
                                        this.registrationForm.language = pageParams.language.toLowerCase();
                                    }
                                    if(pageParams.email !== undefined){
                                        this.registrationForm.email = decodeURIComponent(pageParams.email);
                                        //this.isEmailFieldReadOnly = true;
                                        //this.displayContactForm = true;
                                        //this._initializePhoneInput();
                                        this.handleNext(null);
                                        //return;
                                    }
                                    if(pageParams.startURL !== ''){

                                        let prmstr = decodeURIComponent(pageParams.startURL);

                                        prmstr = prmstr.replace('/csportal/s/?','');
console.log('decodeParams: ',prmstr);
                                        
                                        let paramsReturn = {};

                                        if(prmstr !== undefined && prmstr !== null && prmstr !== ''){
                                            let prmarr = prmstr.split("&");
                                            for ( let i = 0; i < prmarr.length; i++) {
                                                let tmparr = prmarr[i].split("=");
                                                paramsReturn[tmparr[0]] = tmparr[1];
                                            }
                                        }
console.log('paramsReturn: ',paramsReturn);
                                        if(paramsReturn.lms !== ''){
                                            this.registrationForm.lmsRedirectFrom = paramsReturn.lms;
                                            this.registrationForm.lmsCourse = paramsReturn.RelayState;
                                            this.registrationForm.lmsCourse = this.registrationForm.lmsCourse.replace('&', '@_@').replace('%26', '@_@').replace('%2526', '@_@');

console.log('this.registrationForm.lmsRedirectFrom: ',this.registrationForm.lmsRedirectFrom);
console.log('this.registrationForm.lmsCourse: ',this.registrationForm.lmsCourse);
                                        }
                                        
                                    }

                                }

                                this.isLoading = false;
                            }
                        }


                    })
                    .catch(error => {
                        console.info('Error: ', JSON.parse(JSON.stringify(error)));
                        this.isLoading = false;
                    });
                }
            });

        }.bind(this));
        
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

            if(result == false){
                this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
                this.isLoading = false;
            }else{
                let anonymousEmail = 'iata' + this.registrationForm.email.substring(this.registrationForm.email.indexOf('@'));
                RegistrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result=> {
                    if(result == 'true'){
                       //disposable email alert!
                        this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
                        this.isLoading = false;
                    }else{
                        //check if the email address is associated to a contact and/or a user
                        //1) If there is an existing contact & user with that email -> The user is redirected to the login page,
                        //but the "E-Mail" field is pre-populated and, by default, not editable.
                        //The user can click a Change E-Mail link to empty the E-Mail field and set it editable again.
                        //2) If there is an existing contact but not a user with that email -> Terms and conditions and submit
                        //button is displayed on the form.
                        getUserInformationFromEmail({ email : this.registrationForm.email, LMSRedirectFrom: this.registrationForm.lmsRedirectFrom}).then(result => {
                            var userInfo = JSON.parse(JSON.stringify(result));

                            this.userInfo = userInfo;
                            if(userInfo.hasExistingContact == true){
                                if(userInfo.hasExistingUser == true){
                                    //display message of existing user
                                    this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
                                    this.isLoading = false;
                                }else{
                                    //show Terms and Usage field to proceed submit
                                    this.displayTermsAndUsage = true;
                                    this.isEmailFieldReadOnly = true;
                                    this.isLoading = false;
                                }
                            }else{
                                if(userInfo.hasExistingUser == true){
                                    //display message of existing user
                                    this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
                                    this.isLoading = false;
                                }else{
                                    if(userInfo.isEmailAddressAvailable == true){
                                        //show form
                                        if(this.userCountry != ""){
                                            this.registrationForm.country = this.userCountry;
                                        }

                                        this.displayContactForm = true;
                                        this.isEmailFieldReadOnly = true;
                                        this.isLoading = false;
                                        this._initializePhoneInput();

                                    }else{
                                        //inform user to pick another email
                                        this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
                                        this.isLoading = false;
                                    }
                                }
                            }
                        })
                        .catch(error => {
                            console.info('Error: ', error);
                            this.isLoading = false;
                        });
                    }
                });
            }
        });
    }

    handleSubmit(event){

        this.isLoading = true;
        if(this.registrationForm.phone.length < 5){
            this.registrationForm.phone = "";
        }

        var contactId = this.userInfo.contactId;
        var accountId = this.userInfo.accountId;

        register({ registrationForm : JSON.stringify(this.registrationForm),
                customerType : JSON.stringify(this.selectedMetadataCustomerType),
                contactId : contactId,
                accountId : accountId,
                userInfo : JSON.stringify(this.userInfo)
                }).then(result => {
            var dataAux = JSON.parse(JSON.stringify(result));

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
            console.info(dataAux);
            this._showSubmitError(true, 'Error Creating User');
            this.isLoading = false;
        });

    }

    handleCountryChange(event){
        this.registrationForm.country = event.detail.value;
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

    handlePhoneInputChange(event){
        this.rerender = false;
        var inputValue = event.target.value;
        if(inputValue == ""){
            inputValue = this.selectedCountryFlag;
        }
        var isValid = this.phoneRegExp.test(inputValue);
        if(isValid == false){
            inputValue = inputValue.replace(/[^0-9()+]|(?!^)\+/g, '');
        }
        this.registrationForm.phone = inputValue;
        this.selectedCountryFlag = this.selectedCountryFlag;
        this.rerender = true;
    }

    handlePhoneInputCountryChange(){
        let input = this.template.querySelector('[data-id="phone"]');
        let iti = window.intlTelInputGlobals.getInstance(input);
        let selectedCountry = iti.getSelectedCountryData();
        let countryCode = "";

        if(selectedCountry.dialCode !== undefined){
            countryCode = "+" + selectedCountry.dialCode;
        }else{
            countryCode = this.selectedCountryFlag;
        }
        let inputValue = this.registrationForm.phone;
        let currentPhoneValue = this.registrationForm.phone;
        //check if previous flag selection exists to prevent overriding phone value on page refresh due to language change
        let newPhoneValue = "";
        if(this.selectedCountryFlag){
            if(currentPhoneValue.includes(this.selectedCountryFlag)){
                newPhoneValue = currentPhoneValue.replace(this.selectedCountryFlag, countryCode);
            }else{
                newPhoneValue = countryCode;
            }
        }else{
            newPhoneValue = countryCode;
        }
        this.selectedCountryFlag = countryCode;
        this.registrationForm.phone = newPhoneValue;
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
                selectedCountryFlag : this.selectedCountryFlag,
                isRegistrationComplete : this.isRegistrationComplete,
                userInfo : this.userInfo
            };

            localStorage.setItem("registrationState", JSON.stringify(registrationState));
        }
        location.search = search;
    }

    handleSnackbarCancel(){
        this.errorMessage = "";
        this.displaySubmitError = false;
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
        this.errorMessage = message;
        this.displaySubmitError = state;

        if(state == true){
            let scrollobjective = this.template.querySelector('[data-id="snackbar"]');
            scrollobjective.scrollIntoView({ behavior: 'smooth' });
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
                                  "termsAndUsage" : false
                                };

        this.selectedCustomerType = null;
        this.selectedMetadataCustomerType = null;

    }

    _restoreState(){
        let registrationState = JSON.parse(localStorage.getItem("registrationState"));
        localStorage.removeItem("registrationState");

        this.registrationForm = registrationState.registrationForm;
        this.isEmailFieldReadOnly = registrationState.isEmailFieldReadOnly;
        this.displayContactForm = registrationState.displayContactForm;
        this.displayTermsAndUsage = registrationState.displayTermsAndUsage;
        this.selectedCustomerType = registrationState.selectedCustomerType;
        //this.sector = registrationState.sector;
        //this.category = registrationState.category;
        //this.extraQuestion = registrationState.extraQuestion;
        this.selectedMetadataCustomerType = registrationState.selectedMetadataCustomerType;
        this.userCountry = registrationState.userCountry;
        this.userCountryCode = registrationState.userCountryCode;
        this.selectedCountryFlag = registrationState.selectedCountryFlag;
        this.isRegistrationComplete = registrationState.isRegistrationComplete;
        this.userInfo = registrationState.userInfo;
        if(this.isRegistrationComplete == false){
            this._checkForMissingFields();
        }
        this.isLoading = false;

        if(this.displayContactForm){
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

        var iti = window.intlTelInput(input,{
            initialCountry: countryCode,
            preferredCountries: [countryCode],
            placeholderNumberType : "FIXED_LINE",
            //utilsScript: this.utilsPath,
            /*autoPlaceholder : "aggressive"*/
        });

        var selectedCountryData = iti.getSelectedCountryData();

        if(!this.selectedCountryFlag){
            this.selectedCountryFlag = "+" + selectedCountryData.dialCode;
            this.registrationForm.phone = "+" + selectedCountryData.dialCode;
        }

        input.addEventListener("countrychange", this.handlePhoneInputCountryChange.bind(this));
    }
}
/**
 * Created by ukaya01 on 28/08/2019.
 */

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track, wire}         from 'lwc';
import { loadScript, loadStyle }                from 'lightning/platformResourceLoader';
import RegistrationUtils                        from 'c/registrationUtils';

import getRegistrationConfirmationConfig        from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getRegistrationConfirmationConfig';
import getCustomerTypePicklists                 from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists';
import getMetadataCustomerType                  from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getMetadataCustomerType';
import updateContactInfo                        from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.updateContactInfo';

/* ==============================================================================================================*/
/* External Resources
/* ==============================================================================================================*/
import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';
import jQuery                                   from '@salesforce/resourceUrl/jQuery172';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import CSP_Submit                               from '@salesforce/label/c.CSP_Submit';
import ISSP_Registration_MyInformation          from '@salesforce/label/c.ISSP_Registration_MyInformation';
import CSP_Troubleshooting_Info                 from '@salesforce/label/c.CSP_Troubleshooting_Info';
import CSP_Troubleshooting                      from '@salesforce/label/c.CSP_Troubleshooting';
import CSP_Unexcepted_Error                     from '@salesforce/label/c.CSP_Unexcepted_Error';
import CSP_PortalPath                           from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRegistrationFirstLevelConfirmation extends LightningElement {

    /* ==============================================================================================================*/
    /* Attributes
    /* ==============================================================================================================*/
    @track isLoading = true;
    @track config = {
        "contactLabelMap" : {
            "Email" : "",
            "FirstName" : "",
            "LastName" : "",
            "Phone" : "",
            "Preferred_Language__c" : ""
        },
        "accountLabelMap" : {
            "Services_Rendered_Country__c" : ""
        },
    };
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
                                "contactId" : ""
                              };
    @track errorMessage = "";
    @track displayError = false;
    @track displaySubmitError = false;
    @track languageOptions = [];
    @track countryOptions = [];
    @track sector = { label : "", options : [], display : false };
    @track category = { label : "", options : [], display : false };
    @track extraQuestion = { label : "", options : [], display : false };
    @track jsLoaded = false;
    @track selectedCustomerType = null;
    @track selectedMetadataCustomerType = {};
    @track userCountryCode = '';
    @track userCountry = '';
    @track selectedCountryFlag = "";
    initialLoad = true;
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_mark_white.svg';
    cancelIcon = CSP_PortalPath + 'CSPortal/Images/Icons/cancel_white.svg';
    phoneRegExp = /^\(?[+]\)?([()\d]*)$/
    @track rerender = false;

    _labels = {
        CSP_Submit,
        ISSP_Registration_MyInformation,
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

    get customerTypeSelectionEnabled(){
        if(this.config.isGeneralPublic == true){
            return false;
        }else{
            return true;
        }
    }

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
            if(this.initialLoad == false){
                this.isLoading = false;
            }

        } else if (error) {
            var result = JSON.parse(JSON.stringify(error));
            console.info('error: ', result);
            if(this.initialLoad == false){
                this.isLoading = false;
            }
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
    connectedCallback(){

        const RegistrationUtilsJs = new RegistrationUtils();

        Promise.all([
            loadScript(this, jQuery),
            loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
            loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
        ]).then(function(){

            this.jsLoaded = true;

            RegistrationUtilsJs.getUserLocation().then(result=> {
                this.userCountryCode = result.countryCode;
                this.userCountry = result.countryId;
                getRegistrationConfirmationConfig().then(result => {
                    var config = JSON.parse(JSON.stringify(result));

                    if(config.contact == null){
                        this.dispatchEvent(new CustomEvent('hideregistrationpopup'));
                        return;
                    }

                    this.config = config;
                    this.registrationForm = this._mapFormFields(config);
                    this.selectedCustomerType = config.selectedCustomerType;

                    Promise.all([
                        this._renderCountryOptions(config.countryInfo.countryList),
                        this._renderLanguageOptions(config.languageList),
                        this._initializePhoneInput()
                    ]).then(function(){
                        this.isLoading = false;
                        this.initialLoad = false;
                        this._checkForMissingFields();
                    }.bind(this));

                })
                .catch(error => {
                    console.info('Error: ', JSON.parse(JSON.stringify(error)));
                    this.isLoading = false;
                });

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

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closeregistrationpopup'));
    }

    handleSubmit(){

        //update contact
        var customerTypeChanged = false;
        this.isLoading = true;

        if(this.config.isGeneralPublic == true){
            if(this.config.selectedCustomerType != this.registrationForm.selectedCustomerType){
                customerTypeChanged = true;
            }

            if(this.config.contact.ISO_Country__c){
                if(this.config.contact.ISO_Country__c != this.registrationForm.country){
                    customerTypeChanged = true;
                }
            }else{
                if(this.registrationForm.country.length > 0){
                    customerTypeChanged = true;
                }
            }
        }

        if(this.registrationForm.phone.length < 5){
            this.registrationForm.phone = "";
        }

        updateContactInfo({ registrationForm : JSON.stringify(this.registrationForm),
                            customerType : JSON.stringify(this.selectedMetadataCustomerType),
                            customerTypeChanged : customerTypeChanged
                          }).then(result => {
            var dataAux = JSON.parse(JSON.stringify(result));

            if(dataAux.isSuccess == true){
                //todo: show success message
                this.dispatchEvent(new CustomEvent('confirmregistration'));
                //this.isLoading = false;
            }else{
                this._showSubmitError(true, 'Error Updating Contact');
                this.isLoading = false;
                this.dispatchEvent(new CustomEvent('hideregistrationpopup'));
            }
        })
        .catch(error => {
            var dataAux = JSON.parse(JSON.stringify(error));
            console.info(dataAux);
            this._showSubmitError(true, 'Error Updating Contact');
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
        input.value = newPhoneValue;
        this.registrationForm.phone = newPhoneValue;
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
        this._checkForMissingFields();
    }

    handleSnackbarCancel(){
        this.errorMessage = "";
        this.displaySubmitError = false;
    }

    /* ==============================================================================================================*/
    /* Helper Methods
    /* ==============================================================================================================*/

    async _checkForMissingFields(){

        let isValid = true;

        if(this.registrationForm.email.length < 1 || this.registrationForm.firstName.length < 1 || this.registrationForm.lastName.length < 1 || this.registrationForm.language.length < 1
            || this.registrationForm.sector.length < 1){
                isValid = false;
        }

        if(this.registrationForm.sector == 'General_Public_Sector' && this.registrationForm.extraChoice.length < 1){
            isValid = false;
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

    _renderCountryOptions(options){
        let dataList = JSON.parse(JSON.stringify(options));
        let optionList = [];
        //optionList.push({ 'label': '', 'value': '' });
        dataList.forEach(function (data) {
            optionList.push({ 'label': data.Name, 'value': data.Id });
        });
        this.countryOptions = optionList;
    }

    _renderLanguageOptions(options){
        this.languageOptions = options;
    }

    async _initializePhoneInput(){

        await(this.jsLoaded == true);
        await(this.template.querySelector('[data-id="phone"]'));
        var input = this.template.querySelector('[data-id="phone"]');

        var countryId = this.registrationForm.country;
        var countryList = this.countryOptions;
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
            if(this.registrationForm.phone.length < 4){
                this.registrationForm.phone = "+" + selectedCountryData.dialCode;
            }
        }

        input.addEventListener("countrychange", this.handlePhoneInputCountryChange.bind(this));

    }

    _mapFormFields(config){
        let formFields = {};
        formFields.email = config.contact.Email;
        formFields.firstName = config.contact.FirstName ? config.contact.FirstName : '';
        formFields.lastName = config.contact.LastName ? config.contact.LastName : '';
        formFields.country = config.contact.ISO_Country__c ? config.contact.ISO_Country__c : '';
        formFields.phone = config.contact.Phone ? config.contact.Phone : '';
        formFields.sector = config.sector ? config.sector : '';
        formFields.category = config.category ? config.category : '';
        formFields.extraChoice = config.extraChoice ? config.extraChoice : '';
        formFields.language = config.contact.Preferred_Language__c ? config.contact.Preferred_Language__c : '';
        formFields.selectedCustomerType = config.selectedCustomerType ? config.selectedCustomerType : '';
        formFields.contactId = config.contact.Id ? config.contact.Id : '';

        if(formFields.phone.length < 1){
            if(formFields.country.length > 0){
                var countryCode = config.countryInfo.countryMap[formFields.country].ISO_Code__c;
                if(countryCode == 'XX'){
                    countryCode = this.userCountryCode ? this.userCountryCode : 'CH';
                    formFields.country = this.userCountry ? this.userCountry : '';
                }
                this.userCountryCode = countryCode;
            }else{
                 formFields.country = this.userCountry ? this.userCountry : '';
            }
        }else{
            if(formFields.country.length > 0){
                var countryCode = config.countryInfo.countryMap[formFields.country].ISO_Code__c;
                if(countryCode == 'XX'){
                    formFields.country = this.userCountry ? this.userCountry : '';
                }
            }else{
                 formFields.country = this.userCountry ? this.userCountry : '';
            }
        }

        return formFields;
    }



}
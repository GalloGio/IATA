/**
 * Created by ukaya01 on 28/08/2019.
 */

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track, wire}         from 'lwc';
import { navigateToPage, getParamsFromPage }    from 'c/navigationUtils';
import { loadScript, loadStyle }                from 'lightning/platformResourceLoader';
import RegistrationUtils                        from 'c/registrationUtils';
import { ShowToastEvent }                       from 'lightning/platformShowToastEvent';

import getRegistrationConfirmationConfig        from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getRegistrationConfirmationConfig';
import getCustomerTypePicklists                 from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists';
import getMetadataCustomerType                  from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getMetadataCustomerType';

/* ==============================================================================================================*/
/* External Resources
/* ==============================================================================================================*/
import PhoneFormatter16                         from '@salesforce/resourceUrl/PhoneFormatter16';
import jQuery                                   from '@salesforce/resourceUrl/jQuery172';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import LoginLabel                               from '@salesforce/label/c.Login';
import EmailLabel                               from '@salesforce/label/c.Email';
import SubmitLabel                              from '@salesforce/label/c.CSP_Submit';
import CSP_PortalPath                           from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRegistrationFirstLevelConfirmation extends LightningElement {

    /* ==============================================================================================================*/
    /* Attributes
    /* ==============================================================================================================*/
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
    countryCode = '';

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
            //this.isLoading = false;
        } else if (error) {
            var result = JSON.parse(JSON.stringify(error));
            console.log('error: ', result);
            //this.isLoading = false;
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
    connectedCallback(){


        Promise.all([
            loadScript(this, jQuery),
            loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
            loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css')
        ]).then(function(){
            getRegistrationConfirmationConfig().then(result => {
                var config = JSON.parse(JSON.stringify(result));
                console.log('config: ', config);
                if(config.contact == null){
                    alert('Failed to find Contact');
                    return;
                }
                this.config = config;
                this.registrationForm = this._mapFormFields(config);
                this.selectedCustomerType = config.selectedCustomerType;
                this._renderCountryOptions(config.countryInfo.countryList);
                this._renderLanguageOptions(config.languageList);
                this.isLoading = false;
                this._renderInputs();
                this._initializePhoneInput();

            })
            .catch(error => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
                this.isLoading = false;
                //todo: should close popup(should not be mandatory if it fails to load)
            });
        }.bind(this));


    }


    /* ==============================================================================================================*/
    /* Event Handlers
    /* ==============================================================================================================*/

    handleCloseModal(){
        console.log('closeregistrationpopup');
        this.dispatchEvent(new CustomEvent('closeregistrationpopup'));
    }

    handleSubmit(){
        //update contact

        if(this.config.selectedCustomerType != this.registrationForm.selectedCustomerType || this.config.contact.ISO_Country__c != this.registrationForm.country){
            console.log('customer type changed');
        }
        console.log('form: ', this.registrationForm);
        this._showSubmitError(true, 'Error!');
        //this.dispatchEvent(new CustomEvent('hideregistrationpopup'));
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

    handleSectorChange(event){
        this.isLoading = true;
        this.selectedCustomerType = event.target.value;
        console.log('selectedCustomerType: ', this.selectedCustomerType);
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
        this.registrationForm.extraChoice = "";
        this.isLoading = false;
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
        this.isLoading = false;
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
        this.isLoading = false;
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
        this.registrationForm.language = event.detail;
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
            a.value = a.label;
            return a;
        });
        this.languageOptions = lowerCaseLangOpts;
    }

    async _renderInputs(){

        await (this.template.querySelector('[data-id="firstName"]'));

        if(this.registrationForm.firstName.length > 0){
            this.template.querySelector('[data-id="firstName"]').classList.add('inputBackgroundGrey');
        }

        if(this.registrationForm.lastName.length > 0){
            this.template.querySelector('[data-id="lastName"]').classList.add('inputBackgroundGrey');
        }

        if(this.registrationForm.phone.length > 0){
            this.template.querySelector('[data-id="phone"]').classList.add('inputBackgroundGrey');
        }

    }

    async _initializePhoneInput(){

        await(this.jsLoaded == true);
        await(this.template.querySelector('[data-id="phone"]'));
        var input = this.template.querySelector('[data-id="phone"]');

        var countryId = this.registrationForm.country;
        var countryList = this.countryOptions;


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

    _mapFormFields(config){
        let formFields = {};
        formFields.email = config.contact.Email;
        formFields.firstName = config.contact.FirstName;
        formFields.lastName = config.contact.LastName;
        formFields.country = config.contact.ISO_Country__c ? config.contact.ISO_Country__c : '';
        formFields.phone = config.contact.Phone ? config.contact.Phone : '';
        formFields.sector = config.sector;
        formFields.category = config.category;
        formFields.extraChoice = config.extraChoice ? config.extraChoice : '';
        formFields.language = config.contact.Preferred_Language__c;
        formFields.selectedCustomerType = config.selectedCustomerType;
        formFields.contactId = config.contact.Id;

        if(formFields.phone.length < 1){
            if(formFields.country.length > 0){
                var countryCode = config.countryInfo.countryMap[formFields.country].ISO_Code__c;
                this.userCountryCode = countryCode;
            }else{
                 this.userCountryCode = 'CH';
             }
        }else{
            //todo:format the phone flag from the value of the existing phone number?! Replace code below
            if(formFields.country.length > 0){
                var countryCode = config.countryInfo.countryMap[formFields.country].ISO_Code__c;
                this.userCountryCode = countryCode;
            }else{
                this.userCountryCode = 'CH';
            }
        }

        console.log('formFields: ', formFields);
        return formFields;
    }



}
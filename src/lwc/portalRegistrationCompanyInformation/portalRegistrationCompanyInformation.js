import { LightningElement,track,api } from 'lwc';

import { loadScript, loadStyle }    from 'lightning/platformResourceLoader';
import RegistrationUtils            from 'c/registrationUtils';

import getMetadataCustomerType      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getMetadataCustomerTypeForL2';
import getCustomerTypePicklists     from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getCustomerTypePicklistsForL2';

import PhoneFormatter16         from '@salesforce/resourceUrl/PhoneFormatter16';
import PhoneFormatter           from '@salesforce/resourceUrl/InternationalPhoneNumberFormat';
import PhoneFormatterS          from '@salesforce/resourceUrl/InternationalPhoneNumberFormatS';
import jQuery                   from '@salesforce/resourceUrl/jQuery172';

//custom labels
import CSP_L2_Create_New_Account            from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L2_Company_Information_Message   from '@salesforce/label/c.CSP_L2_Company_Information_Message';
import CSP_L2_Company_Information           from '@salesforce/label/c.CSP_L2_Company_Information';
import CSP_L2_Trade_Name                    from '@salesforce/label/c.CSP_L2_Trade_Name';
import CSP_L2_Legal_Name                    from '@salesforce/label/c.CSP_L2_Legal_Name';
import CSP_L2_Phone_Number                  from '@salesforce/label/c.CSP_L2_Phone_Number';
import CSP_L2_Email_Address                 from '@salesforce/label/c.CSP_L2_Email_Address';
import CSP_L2_Website                       from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_Back_to_Account_Selection     from '@salesforce/label/c.CSP_L2_Back_to_Account_Selection';
import CSP_L2_Next_Address_Information      from '@salesforce/label/c.CSP_L2_Next_Address_Information';
import CSP_Invalid_Email                    from '@salesforce/label/c.CSP_Invalid_Email';
import CSP_PortalPath                       from '@salesforce/label/c.CSP_PortalPath';
import CSP_L2_Change_Categorization_Warning from '@salesforce/label/c.CSP_L2_Change_Categorization_Warning';

export default class PortalRegistrationCompanyInformation extends LightningElement {
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

    // inputs
    @api account;
    @api originalCustomerType;
    @api customerType;
    @api countryId;
    @api isTriggeredByRequest;

    // customer type
    @track customerTypesList;
    @track isOtherPicklistDisplayed = false;
    @track firstCategorizationPicklist;
    @track secondCategorizationPicklist;
    @track thirdCategorizationPicklist;
    fakeCategoryPicklist;
    @track atLeastTwoPicklists = false;
    @track threePicklists = false;

    @track isCategorizationSearchable;
    // flag to warn user requesting access to a service/topic
    @track isCategorizationModified = false;

    registrationUtilsJs;

    @track localAccount;

    @track jsLoaded = false;

    @track isAddressInformationButtonDisabled;

    @track isEmailValid = true;
    @track displayInvalidEmailMessage = false;


    // labels
    _labels = {
        CSP_L2_Create_New_Account,
        CSP_L2_Company_Information_Message,
        CSP_L2_Company_Information,
        CSP_L2_Trade_Name,
        CSP_L2_Legal_Name,
        CSP_L2_Phone_Number,
        CSP_L2_Email_Address,
        CSP_L2_Website,
        CSP_L2_Back_to_Account_Selection,
        CSP_L2_Next_Address_Information,        
        CSP_Invalid_Email,
        CSP_L2_Change_Categorization_Warning
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    checkEmailValidity(){
        if(this.localAccount.email !== ''){
            this.registrationUtilsJs.checkEmailIsValid(`${this.localAccount.email}`).then(result=> {
                if(result == false){
                    let currentEmailValidity = this.isEmailValid;
                    this.isEmailValid = false;
                    this.checkCompletion(currentEmailValidity);
                }
                else{
                    let anonymousEmail = 'iata' + this.localAccount.email.substring(this.localAccount.email.indexOf('@'));
                    this.registrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result=> {
                        if(result == 'true'){
                            let currentEmailValidity = this.isEmailValid;
                            this.isEmailValid = false;
                            this.checkCompletion(currentEmailValidity);
                        }
                        else{
                            let currentEmailValidity = this.isEmailValid;
                            this.isEmailValid = true;
                            this.checkCompletion(currentEmailValidity);
                        }
                    });
                }
            })
        }
        else{
            let currentEmailValidity = this.isEmailValid;
            this.isEmailValid = true;
            this.checkCompletion(currentEmailValidity);
        }
    }

    checkCompletion(currentEmailValidity){
        var currentCompletionStatus = this.isAddressInformationButtonDisabled;

        this.isAddressInformationButtonDisabled = this.localAccount.legalName === '' 
                                                    || this.localAccount.phone === ''
                                                    || !this.isCategorizationSearchable;

        if(this.isAddressInformationButtonDisabled !== currentCompletionStatus || this.isEmailValid !== currentEmailValidity){
            this.dispatchEvent(new CustomEvent('completionstatus',{detail : (!this.isAddressInformationButtonDisabled && this.isEmailValid)}));
        }
    }

    connectedCallback() {
        this.localAccount = JSON.parse(JSON.stringify(this.account));

        if(this.localAccount.customerType === ''){
            this.localAccount.customerType = this.customerType;
        }

        if(this.localAccount.customerType === 'Student' || this.localAccount.customerType === 'General_Public_Category'){
            this.setCustomerType(null);
        }
        else{
            this.setCustomerType(this.localAccount.customerType);
        }

        this.fakeCategoryPicklist = [];

        this.registrationUtilsJs = new RegistrationUtils();

        Promise.all([
            loadScript(this, PhoneFormatter16 + '/PhoneFormatter/build/js/intlTelInput.js'),
            loadStyle(this, PhoneFormatter16 + '/PhoneFormatter/build/css/intlTelInput.css'),
            loadScript(this, jQuery)
        ]).then(function(){
            this.jsLoaded = true;

            this.registrationUtilsJs.getUserLocation().then(result=> {
                this.userCountryCode = result.countryCode;
                this._initializePhoneInput();
            });

        }.bind(this));

        this.checkEmailValidity();

        this.dispatchEvent(new CustomEvent('scrolltotop'));
    }

@track userCountryCode;

    async _initializePhoneInput(){
        await(this.jsLoaded == true);
        await(this.template.querySelector('[data-id="phone"]'));

        var input = this.template.querySelector('[data-id="phone"]');
        var countryCode = this.userCountryCode;

        window.intlTelInput(input,{
            initialCountry: countryCode,
            preferredCountries: [countryCode],
            placeholderNumberType : "FIXED_LINE"
            //utilsScript: this.utilsPath,
            /*autoPlaceholder : "aggressive"*/
        });
    }

    setCustomerType(customerType){
        this.localAccount.customerType = customerType;
        this.localAccount.customerTypeSector = '';
        this.localAccount.customerTypeCategory = '';

        // Retrieve customer type
        if(customerType != null){
            getMetadataCustomerType({customerTypeKey:this.localAccount.customerType})
                .then(result => {
                    this.isCategorizationSearchable = result != null && result.Search_Option__c === 'User Search';
                    this.localAccount.customerTypeSector = result.Created_Account_Sector__c;
                    this.localAccount.customerTypeCategory = result.Created_Account_Category__c;

                    if(this.isTriggeredByRequest){
                        this.isCategorizationModified = result.DeveloperName !== this.originalCustomerType && this.isCategorizationSearchable;
                    }
                    this.checkCompletion();
                });
        }
        else{
            this.isCategorizationSearchable = false;
            this.checkCompletion();
        }

        // Update customer type picklists
        getCustomerTypePicklists({leaf:this.localAccount.customerType})
            .then(result => {
                this.customerTypesList = [];
                this.isOtherPicklistDisplayed = false;
                this.atLeastTwoPicklists = false;
                this.threePicklists = false;

                let arrayLength = result.length;

                // retrieve the labels to store the sector and the category to be displayed in the address information step
                let labels = [];
                for (let i = 0; i < arrayLength; i++) {
                    let selectedOption;
                    let customerTypesOptions = [];
                    
                    for(let j = 0; j < result[i].picklistOptions.length; j++){
                        if(j === 0){
                            customerTypesOptions.push({
                                label: '',
                                value: result[i].picklistOptions[j].key
                            });
                        }
                        else{
                            customerTypesOptions.push({
                                label: result[i].picklistOptions[j].label,
                                value: result[i].picklistOptions[j].key
                            });
                        }

                        if(result[i].picklistOptions[j].isSelected){
                            labels.push(result[i].picklistOptions[j].label);
                            selectedOption = result[i].picklistOptions[j].key;

                            // We need to know if the Other intermediary picklist is displayed
                            if(result[i].picklistOptions[j].key === 'Other'){
                                this.isOtherPicklistDisplayed = true;
                            }
                        }
                    }

                    let customerTypesItem = {
                        label: result[i].picklistLabel,
                        selectedItem: selectedOption,
                        options: customerTypesOptions
                    };
                    this.customerTypesList.push(customerTypesItem);
                }

                this.firstCategorizationPicklist = this.customerTypesList[0];

                this.atLeastTwoPicklists = this.customerTypesList.length > 1;
                if(this.atLeastTwoPicklists){
                    this.secondCategorizationPicklist = this.customerTypesList[1];
                }
                else{
                    this.secondCategorizationPicklist = null;
                }

                this.threePicklists = this.customerTypesList.length > 2;
                if(this.threePicklists){
                    this.thirdCategorizationPicklist = this.customerTypesList[2];
                }
                else{
                    this.thirdCategorizationPicklist = null;
                }

                this.localAccount.sector = labels.length >= 2 ? labels[labels.length - 2] : '';
                this.localAccount.category = labels.length >= 2 ? labels[labels.length - 1] : '';
            });
    }

    changeCustomerType(event) {
        this.setCustomerType(event.target.value);
    }

    handleInputValueChange(event){
        var inputName = event.target.name;
        var inputValue = event.target.value;
        this.localAccount[inputName] = inputValue;

        if(inputName === 'email'){
            this.displayInvalidEmailMessage = false;
            var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
            emailDiv.classList.remove('slds-has-error');

            this.checkEmailValidity();
        }
        else{
            this.checkCompletion(this.isEmailValid);
        }
    }

    // Navigation methods
    toAccountSelection(){
        this.dispatchEvent(new CustomEvent('gotostep', {detail:'2'}));
    }

    @api
    getEmailValidity(){
        if(!this.isEmailValid){
            this.displayInvalidEmailMessage = true;
            var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
            emailDiv.classList.add('slds-has-error');
            return false;
        }
        return true;
    }

    toAddressInformation(){
        if(this.getEmailValidity()){
            this.dispatchEvent(new CustomEvent('gotostep', {detail:'4'}));
        }
    }

    // @api methods
    @api
    getCompanyInformation(){
        return this.localAccount;
    }
}
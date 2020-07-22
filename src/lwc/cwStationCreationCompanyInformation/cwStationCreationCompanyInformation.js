import { LightningElement,track,api } from 'lwc';

import RegistrationUtils            from 'c/registrationUtils';
import getMetadataCustomerType      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getMetadataCustomerTypeForL2';
import getCustomerTypePicklists     from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getCustomerTypePicklistsForL2';

import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwStationCreationCompanyInformation extends LightningElement {
    icons = resources + "/icons/";
    backimg = this.icons + "back.svg";
    // inputs
    @api account;
    @api originalCustomerType;
    @api customerType;
    @api countryId;
	@api isTriggeredByRequest;
	@api opsHierarchies;
    @api label;

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

    @track isNextButtonDisabled;

    @track isEmailValid = true;
	@track displayInvalidEmailMessage = false;
	
	availableSectors = ['Airline','Airline Supplier','Freight Forwarder','Non-Airline Transportation', 'Infrastructure Partner','Other'];
	availableCategories = ['Cargo only', 'Passenger and Cargo', 'Passenger only', 'IATA Cargo Agent','Non-IATA Freight Forwader','Ground Service Provider','System Solutions Provider','Truck Line','Airport Operator'];

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
        var currentCompletionStatus = this.isNextButtonDisabled;

        this.isNextButtonDisabled = this.localAccount.legalName === '' 
                                                    || this.localAccount.phone === ''
                                                    || !this.isCategorizationSearchable || !this.localAccount.opsHierarchy;

        if(this.isNextButtonDisabled !== currentCompletionStatus || this.isEmailValid !== currentEmailValidity){
            this.dispatchEvent(new CustomEvent('completionstatus',{detail : (!this.isNextButtonDisabled && this.isEmailValid)}));
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

        this.checkEmailValidity();

        this.dispatchEvent(new CustomEvent('scrolltotop'));
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
						let label = result[i].picklistOptions[j].label;
						
                        if(j === 0){
                            customerTypesOptions.push({
                                label: '',
                                value: result[i].picklistOptions[j].key
                            });
                        }
                        else{
							if(this.availableSectors.includes(label) || this.availableCategories.includes(label)){
								customerTypesOptions.push({
									label: label,
									value: result[i].picklistOptions[j].key
								});
							}
                            
                        }

                        if(result[i].picklistOptions[j].isSelected){
                            labels.push(label);
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
    goBack(){
        this.dispatchEvent(new CustomEvent('back'));
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

    goNext(event){
        event.preventDefault();
        if(this.getEmailValidity()){
            this.dispatchEvent(new CustomEvent('next'));
        }
    }

    // @api methods
    @api
    getCompanyInformation(){
        return this.localAccount;
    }
}
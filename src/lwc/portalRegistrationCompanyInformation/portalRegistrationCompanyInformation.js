import { LightningElement,track,api } from 'lwc';

import { loadScript, loadStyle }    from 'lightning/platformResourceLoader';
import RegistrationUtils            from 'c/registrationUtils';

import getMetadataCustomerType      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getMetadataCustomerTypeForL2';
import getCustomerTypePicklists     from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getCustomerTypePicklistsForL2';

//custom labels
import CSP_L2_Create_New_Account            from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L2_Company_Information_Message   from '@salesforce/label/c.CSP_L2_Company_Information_Message';
import CSP_L2_Company_Information           from '@salesforce/label/c.CSP_L2_Company_Information';
import CSP_L2_Company_Name                  from '@salesforce/label/c.CSP_L2_Company_Name';
import CSP_L2_Website                       from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_Back_to_Account_Selection     from '@salesforce/label/c.CSP_L2_Back_to_Account_Selection';
import CSP_L2_Next_Step                     from '@salesforce/label/c.CSP_L2_Next_Step';
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
    @api internalUser;

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

    // labels
    _labels = {
        CSP_L2_Create_New_Account,
        CSP_L2_Company_Information_Message,
        CSP_L2_Website,
        CSP_L2_Next_Step,
        CSP_L2_Change_Categorization_Warning
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    // labels depending on the origin (internal vs portal)
    companyInformation;
    companyName;
    countryLabel;
    backToAccountSelection;

    checkCompletion(){
        var currentCompletionStatus = this.isAddressInformationButtonDisabled;

        this.isAddressInformationButtonDisabled = this.localAccount.name === '' 
                                                    || !this.isCategorizationSearchable;

        if(this.isAddressInformationButtonDisabled !== currentCompletionStatus){
            this.dispatchEvent(new CustomEvent('completionstatus',{detail : (!this.isAddressInformationButtonDisabled)}));
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

        // define labels depending on the origin (internal vs portal)
        if(this.internalUser){
            this.companyInformation = 'Account Information';
            this.companyName = 'Account Name';
            this.countryLabel = CSP_L2_Company_Location;
            this.backToAccountSelection = 'Back to Account Info';
        }
        else{
            this.companyInformation = CSP_L2_Company_Information;            
            this.companyName = CSP_L2_Company_Name;
            this.countryLabel = CSP_L2_Company_Location;
            this.backToAccountSelection = CSP_L2_Back_to_Account_Selection;
        }

        this.registrationUtilsJs = new RegistrationUtils();

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

        this.checkCompletion();
    }

    // Navigation methods
    previous(){
        this.dispatchEvent(new CustomEvent('previous'));
    }

    next(){
        this.dispatchEvent(new CustomEvent('next'));
    }

    // @api methods
    @api
    getCompanyInformation(){
        return this.localAccount;
    }
}
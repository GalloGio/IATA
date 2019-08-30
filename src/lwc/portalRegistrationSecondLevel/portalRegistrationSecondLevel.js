/**
 * Created by mmercier on 30.07.2019.
 */

import { LightningElement, track, wire, api} from 'lwc';

import getContactInfo                   from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getISOCountries                  from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getISOCountries';
import getContactJobFunctionValues      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactJobFunctionValues';
import linkContactToExistingAccount     from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.linkContactToExistingAccount';

import getContactLabels                 from '@salesforce/apex/OneId_RegistrationProcessController.getContactLabels';

import getCustomerTypeFromSectorAndCategory from '@salesforce/apex/GCS_CustomerType.getCustomerTypeFromSectorAndCategory';

import getCustomerTypesList             from '@salesforce/apex/GCS_RegistrationController.getCustomerTypesList';
import getCustomerTypePicklists_Test    from '@salesforce/apex/GCS_AccountCreation.getCustomerTypePicklists_Test';
import getMetadataCustomerType_Test     from '@salesforce/apex/GCS_AccountCreation.getMetadataCustomerType_Test';
import searchAccounts                   from '@salesforce/apex/GCS_RegistrationController.searchAccounts';

//custom labels
import jobTitle                         from '@salesforce/label/c.ISSP_Registration_JobTitle';
import isspEnterIataCode                from '@salesforce/label/c.ISSP_Enter_IATA_Code';
import isspEnterCompanyName             from '@salesforce/label/c.ISSP_Enter_Company_Name';
import companyName                      from '@salesforce/label/c.ISSP_CompanyName';
import isspCountry                      from '@salesforce/label/c.ISSP_Country';
import isspCompanyLocation              from '@salesforce/label/c.ISSP_CompanyLocation';
import select                           from '@salesforce/label/c.ISSP_Select';
import oneIdNoResults                   from '@salesforce/label/c.OneId_NoResults';
import oneIdAccountNotFound             from '@salesforce/label/c.OneId_AccountNotFound';
import oneIdCreateNew                   from '@salesforce/label/c.OneId_CreateNew';
import cancel                           from '@salesforce/label/c.Cancel';
import submit                           from '@salesforce/label/c.ISSP_Submit';

export default class PortalRegistrationSecondLevel extends LightningElement {
    @track openRegistrationModal = true;
    @track openConfirmationModal = false;

    // contact and account information
    @track contactInfo;
    @track contactFound;
    @track functionLabel;
    @track contactLabels;
    @track selectedAccountId = null;
    @track isJobFunctionMissing = false;
    @track isJobTitleMissing = false;

    // job function variables
    @track jobFunctionsPicklistOptions;

    scrollToBottom = false;

    // customer type variables
    @track customerTypePicklistOptions;
    @track selectedCustomerType;
    @track selectedMetadataCustomerType;
    @track isSelectedCustomerTypeNull;
    @track isCustomerTypeGeneralPublic;
    @track displayCountryPicklist;
    @track displayUserSearch;
    @track displayIataCodeSearch;

    // country variables
    @track isoCountriesPicklistOptions;
    @track selectedCountryId = '';

    //search variables
    @track iataCodeInput = '';
    @track accountNameInput ='';
    @track accountFounds = false;
    @track displaySearchResults = false;
    @track displayCreateNew = false;
    @track numberOfFields = 1;
    @track searchResults;

    @track showAccountCreation = false;
    @track showAccountSelection = true;

    // label variables
    _labels = {
        jobTitle,
        isspEnterIataCode,
        isspEnterCompanyName,
        companyName,
        isspCountry,
        isspCompanyLocation,
        select,
        oneIdNoResults,
        oneIdAccountNotFound,
        oneIdCreateNew,
        cancel,
        submit
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    @track isLoading = false;
    get submitDisabled() {
        return this.selectedAccountId == null;
    }

    @track errorMessage = "";

    triggerL2Registration(event){
        this.openRegistrationModal = true;
    }

    renderedCallback() {
        if(this.scrollToBottom){
//            alert('scroll to bottom');
            this.scrollToBottom = false;
                    let scrollobjective = this.template.querySelector('[data-name="searchResultWrapper"]');
                    scrollobjective.scrollIntoView({ behavior: 'smooth' });
        }
    }

    connectedCallback() {

        // Retrieve Contact information
        getContactInfo()
            .then(result => {
                this.contactInfo = result;
                this.contactFound = this.contactInfo != null;

                if(!this.contactFound){
                    return;
                }

                if(this.contactInfo.Title == undefined){
                    this.contactInfo.Title = null;
                }

                // Retrieve contact fields labels
                getContactLabels()
                    .then(result => {
                        this.contactLabels = result;
                        this.functionLabel = result['Membership_Function__c'];
                    })
                    .catch((error) => {
                        alert("Error in getContactLabels : " + error.body.message);
                    });

                // Retrieve Job Functions list
                // Pre-select Job Functions of Contact
                getContactJobFunctionValues({selectedContactJobFunctions : this.contactInfo.Membership_Function__c})
                    .then(result => {
                        this.jobFunctionsPicklistOptions = result;
                    })
                    .catch((error) => {
                        alert("Error in getContactJobFunctionValues : " + error.body.message);
                    });

                getCustomerTypeFromSectorAndCategory({sector : this.contactInfo.Account.Sector__c, category : this.contactInfo.Account.Category__c})
                    .then(result => {
                        this.setCustomerType(result);
                    })
                    .catch((error) => {
                        alert("Error in getCustomerTypeFromSectorAndCategory : " + error.body.message);
                    });

                // Retrieve Iso Countries list
                // Pre-select country of Contact's Account
                getISOCountries({countryId : this.contactInfo.Account.IATA_ISO_Country__r.Id})
                    .then(result => {
                        this.isoCountriesPicklistOptions = result;
                        // Store the "NO COUNTRY" record Id to prevent the user doing the search if the value is selected
                        // This record should be the first on in the list
                        this.noCountryId = result[0].country.Id;
                        this.selectedCountryId = this.contactInfo.Account.IATA_ISO_Country__r.Id;
                     })
                    .catch((error) => {
                        alert("Error in getISOCountries : " + error.body.message);
                    });

            })
            .catch((error) => {
                alert("Error in getContactInfo : " + error.body.message);
            });
    }


    // Events handling

    changeSelectedJobFunctions(event){
        let options = event.target.options;
        var selectedOpts = [];

        for (var i = 0; i < options.length; i++) {
            if (options[i].selected) {
                selectedOpts.push(options[i].value);
            }
        }
        this.contactInfo.Membership_Function__c = selectedOpts.join(';');

        // If job function is not empty, remove the error message potentially displayed
        if(selectedOpts.length > 0){
            this.isJobFunctionMissing = false;
            this.template.querySelector(".jobFunctionDiv").classList.remove('slds-has-error');
        }
    }

    changeTitle(event){
        this.contactInfo.Title = event.target.value;
        // If job title is not empty, remove the error message potentially displayed
        if(event.target.value != ''){
            this.isJobTitleMissing = false;
            this.template.querySelector(".jobTitleDiv").classList.remove('slds-has-error');
        }
    }

    changeSelectedCustomerType(event) {
        this.isLoading = true;

        this.setCustomerType(event.target.value);

        this.resetSearchResults();

        this.isLoading = false;
    }

    setCustomerType(customerType){
        this.selectedCustomerType = customerType;
        if(this.selectedCustomerType == '- Select -'){
            this.selectedCustomerType = null;
            this.selectedMetadataCustomerType = null;
            this.displayCountryPicklist = false;
            this.isCustomerTypeGeneralPublic = false;
            this.displayUserSearch = false;
            this.displayIataCodeSearch = false;
            this.displayCreateNew = false;
        }
        else{
            // Retrieve customer type
            getMetadataCustomerType_Test({customerTypeKey:this.selectedCustomerType})
                .then(result => {
                    this.selectedMetadataCustomerType = result;
                    this.displayCountryPicklist = this.selectedMetadataCustomerType != null && this.selectedMetadataCustomerType.Display_Country__c;
                    this.isCustomerTypeGeneralPublic = this.selectedMetadataCustomerType != null && this.selectedMetadataCustomerType.Parent__c == 'General_Public_Sector';
                    this.displayUserSearch = this.selectedMetadataCustomerType != null && this.selectedMetadataCustomerType.Search_Option__c == 'User Search' && this.selectedCountryId != '' && this.selectedCountryId != this.noCountryId;
                    this.displayIataCodeSearch = this.selectedMetadataCustomerType != null && this.selectedMetadataCustomerType.Fields_Targeted_Partial_Match__c !== undefined || this.selectedMetadataCustomerType.Fields_Targeted_Exact_Match__c !== undefined;
                    this.displayCreateNew = this.selectedMetadataCustomerType != null && this.selectedMetadataCustomerType.Can_Account_Be_Created__c;
                })
                .catch((error) => {
                    alert("Error in getMetadataCustomerType_Test : " + error.body.message);
                });
        }

        // Update customer type picklists
        getCustomerTypePicklists_Test({leaf:this.selectedCustomerType})
            .then(result => {
                this.customerTypePicklistOptions = result;
            })
            .catch((error) => {
                alert("Error in getCustomerTypePicklists_Test : " + error.body.message);
            });
    }

    changeSelectedCountry(event){
        this.selectedCountryId = event.target.value;

        // calling this because the displayUserSearch value is depending on the selectedCountryId
        this.setCustomerType(this.selectedCustomerType);

        this.resetSearchResults();
    }

    searchOnAccountName(event){
        this.accountNameInput = event.target.value;
        this.search();
    }

    searchOnIataCode(event){
        this.iataCodeInput = event.target.value;
        this.search();
    }

    search(){
        this.selectedAccountId = null;

        if(this.iataCodeInput.length >= 2 || this.accountNameInput.length >= 3) {
            this.isLoading = true;

            searchAccounts({
                    customerTypeKey: this.selectedCustomerType,
                    countryId: this.selectedCountryId,
                    userInputIataCodes: this.iataCodeInput,
                    userInputCompanyName: this.accountNameInput
                })
                .then(result => {
                    this.searchResults = result;
                    this.accountFounds = this.searchResults.totalAccounts > 0;
                    this.numberOfFields = this.searchResults.fieldLabels.length;
                    this.displaySearchResults = true;
                    this.isLoading = false;
                    this.scrollToBottom = true;
//                    let scrollobjective = this.template.querySelector('[data-name="searchResultWrapper2"]');
//                    scrollobjective.scrollIntoView({ behavior: 'smooth' });
                })
                .catch((error) => {
                    alert("Error in searchAccounts : " + error.body.message);
                    this.displaySearchResults = false;
                    this.isLoading = false;
                });
        }
        else{
            this.displaySearchResults = false;
        }
        let divElement = this.template.querySelectorAll('.scrollable-body')[0];
        let divToTop = this.template.querySelectorAll('.results')[0].offsetTop;
//        window.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });
//        divElement.scrollTo({ top: divToTop, left: 0, behavior: 'smooth' });
//        divElement.scrollTop = 1520;

    }

    resetSearchResults(){
        this.selectedAccountId = null;
        this.iataCodeInput = '';
        this.accountNameInput = '';
        this.searchResults = null;
        this.displaySearchResults = false;
        this.accountFounds = false;
        this.numberOfFields = 1;
    }

    createNew(){
        this.showAccountSelection = false;
        this.displaySearchResults = false;
        this.showAccountCreation = true;
    }

    selectAccount(event){
        this.selectedAccountId = event.target.getAttribute('data-id');
        this.displaySearchResults = false;
        this.accountNameInput = event.target.getAttribute('data-name');
    }

    submit(){
        if(!this.checkMandatoryFields()){
            return;
        }

        this.isLoading = true;

        // The user selected an existing account
        if(this.selectedAccountId != null){
            linkContactToExistingAccount({con: this.contactInfo, accountId : this.selectedAccountId})
                .then(result => {
                    this.openRegistrationModal = false;
                    this.openConfirmationModal = true;
                    this.isLoading = false;
                })
                .catch(error => {
                    alert("Error in submit : " + error.message);
                    this.isLoading = false;
                });
        }
    }

    closeConfirmationModal(){
        this.dispatchEvent(
            new CustomEvent('closesecondlevelregistration')
        );
        window.location.reload();
    }

    checkMandatoryFields(){
        // Job function
        var functionMissing = !(this.template.querySelector(".jobFunctionInput").validity.valid);
        this.isJobFunctionMissing = functionMissing;
        if(functionMissing){
            this.template.querySelector(".jobFunctionDiv").classList.add('slds-has-error');
        }

        // Job title
        var titleMissing = !(this.template.querySelector(".jobTitleInput").validity.valid);
        this.isJobTitleMissing = titleMissing;
        if(titleMissing){
            this.template.querySelector(".jobTitleDiv").classList.add('slds-has-error');
        }

        // return true if OK
        return !(functionMissing || titleMissing);
    }

    cancel(){
        this.dispatchEvent(
            new CustomEvent('closesecondlevelregistration')
        );
//        window.location.reload();
    }
}